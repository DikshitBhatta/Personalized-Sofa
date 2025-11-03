import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:timberr/constants.dart';
import 'package:timberr/models/sofa_order.dart';
import 'package:timberr/services/order_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:timberr/Notification/controllers/notification_controller.dart';
import 'package:timberr/screens/fullscreen_3d_view.dart';
import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';


class AdminOrderDetailScreen extends StatefulWidget {
  final String orderId;

  const AdminOrderDetailScreen({super.key, required this.orderId});

  @override
  State<AdminOrderDetailScreen> createState() => _AdminOrderDetailScreenState();
}

class _AdminOrderDetailScreenState extends State<AdminOrderDetailScreen> with TickerProviderStateMixin {
  SofaOrder? _order;
  bool _isLoading = true;
  bool _isProcessing = false;
  Map<String, dynamic>? _conciergeBooking;
  TabController? _tabController;
  final TextEditingController _adminNotesController = TextEditingController();
  final TextEditingController _rejectionReasonController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadOrder();
  }

  @override
  void dispose() {
    _adminNotesController.dispose();
    _rejectionReasonController.dispose();
    _tabController?.dispose();
    super.dispose();
  }

  Future<void> _loadOrder() async {
    setState(() => _isLoading = true);
    final order = await OrderService.getOrderById(widget.orderId);
    
    print('📦 ========== LOADING ORDER ==========');
    print('📦 Loading order: ${order?.id}');
    print('👤 Order user ID: ${order?.userId}');
    print('📅 Order created at: ${order?.createdAt}');
    
    // Load associated concierge booking if any
    Map<String, dynamic>? conciergeBooking;
    if (order != null) {
      try {
        // Query concierge bookings for this order's user
        final bookingsSnapshot = await FirebaseFirestore.instance
            .collection('concierge_bookings')
            .where('client_id', isEqualTo: order.userId)
            .orderBy('created_at', descending: true)
            .limit(10)
            .get();
        
        print('🔍 Found ${bookingsSnapshot.docs.length} concierge bookings for user ${order.userId}');
        
        // Find booking created within 1 hour of order creation
        if (bookingsSnapshot.docs.isNotEmpty) {
          for (var doc in bookingsSnapshot.docs) {
            final bookingData = doc.data();
            final bookingTime = (bookingData['created_at'] as Timestamp?)?.toDate();
            
            print('  📅 Booking ${doc.id}: created_at=$bookingTime, status=${bookingData['status']}');
            
            if (bookingTime != null) {
              final timeDifference = order.createdAt.difference(bookingTime).abs();
              print('    ⏱️ Time difference: ${timeDifference.inMinutes} minutes');
              
              // If booking was created within 1 hour of order, consider it linked
              if (timeDifference.inHours < 1) {
                conciergeBooking = bookingData;
                conciergeBooking['id'] = doc.id;
                print('    ✅ MATCHED! Using this booking (within 1 hour)');
                break;
              }
            }
          }
          
          // If no close match found, just use the most recent one
          if (conciergeBooking == null && bookingsSnapshot.docs.isNotEmpty) {
            conciergeBooking = bookingsSnapshot.docs.first.data();
            conciergeBooking['id'] = bookingsSnapshot.docs.first.id;
            print('  ⚠️ No close match, using most recent booking: ${conciergeBooking['id']}');
          }
        }
        
        if (conciergeBooking != null) {
          print('✅ ✅ ✅ Loaded concierge booking: ${conciergeBooking['id']} (status: ${conciergeBooking['status']})');
        } else {
          print('⚠️ ⚠️ ⚠️ No concierge booking found for this order');
        }
      } catch (e) {
        print('❌ Error loading concierge booking: $e');
        print('❌ Stack trace: ${StackTrace.current}');
      }
    }
    
    print('💾 Setting state with conciergeBooking: ${conciergeBooking != null ? "YES (ID: ${conciergeBooking['id']})" : "NO"}');
    print('📦 ========== END LOADING ORDER ==========');
    
    setState(() {
      _order = order;
      _conciergeBooking = conciergeBooking;
      _adminNotesController.text = order?.adminNotes ?? '';
      _rejectionReasonController.text = order?.rejectionReason ?? '';
      _isLoading = false;
      
      // Initialize tab controller if we have concierge booking
      if (_conciergeBooking != null) {
        // Dispose old controller if it exists
        _tabController?.dispose();
        _tabController = TabController(length: 2, vsync: this);
      }
    });
  }

  Future<void> _updateOrderStatus(OrderStatus newStatus, {String? rejectionReason}) async {
    setState(() => _isProcessing = true);
    
    print('🔍 ========== APPROVE ORDER DEBUG ==========');
    print('🔍 Debug: newStatus = $newStatus');
    print('🔍 Debug: _conciergeBooking = $_conciergeBooking');
    print('🔍 Debug: _conciergeBooking is null? ${_conciergeBooking == null}');
    print('🔍 Debug: Condition check: ${newStatus == OrderStatus.processing && _conciergeBooking != null}');
    
    // When approving order, also approve concierge booking if it exists
    if (newStatus == OrderStatus.processing && _conciergeBooking != null) {
      try {
        final bookingId = _conciergeBooking!['id'];
        print('🔍 Debug: Updating concierge booking with ID: $bookingId');
        
        await FirebaseFirestore.instance
            .collection('concierge_bookings')
            .doc(bookingId)
            .update({
          'status': 'confirmed',
          'updated_at': FieldValue.serverTimestamp(),
        });
        print('✅ ✅ ✅ Concierge booking $bookingId confirmed successfully');
        
        // Update local state immediately
        _conciergeBooking!['status'] = 'confirmed';
      } catch (e) {
        print('❌ Error updating concierge booking: $e');
        print('❌ Stack trace: ${StackTrace.current}');
      }
    } else {
      print('⚠️ ⚠️ ⚠️ Skipping concierge update!');
      print('⚠️ Reason: newStatus=$newStatus, hasBooking=${_conciergeBooking != null}');
      if (_conciergeBooking == null) {
        print('⚠️ _conciergeBooking is NULL - booking was not loaded!');
      }
    }
    print('🔍 ========== END APPROVE ORDER DEBUG ==========');
    
    // Update admin notes to include concierge approval message
    String adminNotes = _adminNotesController.text.isNotEmpty 
        ? _adminNotesController.text 
        : '';
    
    if (newStatus == OrderStatus.processing && _conciergeBooking != null) {
      if (adminNotes.isNotEmpty) {
        adminNotes += '\n\n';
      }
      adminNotes += 'Order approved. The concierge will visit as scheduled.';
    }
    
    final success = await OrderService.updateOrderStatus(
      orderId: widget.orderId,
      status: newStatus,
      adminNotes: adminNotes.isNotEmpty ? adminNotes : null,
      rejectionReason: rejectionReason,
    );

    setState(() => _isProcessing = false);

    if (success) {
      Get.snackbar(
        'Success',
        newStatus == OrderStatus.processing && _conciergeBooking != null
            ? 'Order and concierge visit approved!'
            : 'Order status updated to ${_statusText(newStatus)}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: kCrayolaGreen,
        colorText: Colors.white,
      );
      _loadOrder();
    } else {
      Get.snackbar(
        'Error',
        'Failed to update order status',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: kFireOpal,
        colorText: Colors.white,
      );
    }
  }

  Future<void> _confirmConciergeBooking() async {
    if (_conciergeBooking == null) {
      Get.snackbar(
        'Error',
        'No concierge booking found',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: kFireOpal,
        colorText: Colors.white,
      );
      return;
    }

    setState(() => _isProcessing = true);
    
    print('🔍 ========== CONFIRMING CONCIERGE BOOKING ==========');
    print('🔍 Booking ID: ${_conciergeBooking!['id']}');
    print('🔍 Current Status: ${_conciergeBooking!['status']}');
    
    try {
      final bookingId = _conciergeBooking!['id'];
      
      await FirebaseFirestore.instance
          .collection('concierge_bookings')
          .doc(bookingId)
          .update({
        'status': 'confirmed',
        'updated_at': FieldValue.serverTimestamp(),
      });
      
      print('✅ ✅ ✅ Concierge booking confirmed successfully');
      
      // Update local state
      _conciergeBooking!['status'] = 'confirmed';
      
      // Send notification to user
      try {
        // Safely get or initialize NotificationController
        NotificationController notificationController;
        try {
          notificationController = Get.find<NotificationController>();
        } catch (e) {
          print('⚠️ NotificationController not found, initializing now...');
          notificationController = Get.put(NotificationController());
        }
        
        await notificationController.sendConciergeConfirmationNotification(
          userId: _conciergeBooking!['client_id'] ?? '',
          conciergeName: _conciergeBooking!['concierge_name'] ?? '',
          visitDate: _conciergeBooking!['visit_date'] ?? '',
          visitTime: _conciergeBooking!['visit_time'] ?? '',
        );
        print('📬 Confirmation notification sent to user');
      } catch (e) {
        print('⚠️ Could not send notification: $e');
        // Continue even if notification fails
      }
      
      Get.snackbar(
        'Success',
        'Concierge visit confirmed!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: kCrayolaGreen,
        colorText: Colors.white,
      );
      
      // Reload to update UI
      await _loadOrder();
      
    } catch (e) {
      print('❌ Error confirming concierge booking: $e');
      Get.snackbar(
        'Error',
        'Failed to confirm concierge booking',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: kFireOpal,
        colorText: Colors.white,
      );
    } finally {
      setState(() => _isProcessing = false);
    }
    
    print('🔍 ========== END CONFIRMING CONCIERGE BOOKING ==========');
  }

  void _view3DModel(BuildContext context, String glbUrl) {
    print('🎨 Opening 3D model viewer for: $glbUrl');
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Fullscreen3DView(assetPath: glbUrl),
      ),
    );
  }

  void _showRejectDialog() {
    final reasonController = TextEditingController();
    
    Get.dialog(
      AlertDialog(
        title: const Text('Reject Order'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Please provide a reason for rejection:'),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Enter rejection reason...',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (reasonController.text.isNotEmpty) {
                Get.back();
                _updateOrderStatus(OrderStatus.cancelled, rejectionReason: reasonController.text);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: kFireOpal),
            child: const Text('Reject'),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return kOffBlack;
      case OrderStatus.processing:
        return Colors.blue;
      case OrderStatus.delivered:
        return kCrayolaGreen;
      case OrderStatus.cancelled:
        return kFireOpal;
    }
  }

  String _statusText(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return 'PENDING APPROVAL';
      case OrderStatus.processing:
        return 'IN PRODUCTION';
      case OrderStatus.delivered:
        return 'DELIVERED';
      case OrderStatus.cancelled:
        return 'CANCELLED';
    }
  }

  String _getContactLabel(String? contactMethod) {
    switch (contactMethod) {
      case 'Phone':
        return 'Phone Number';
      case 'Email':
        return 'Email Address';
      case 'Line':
        return 'Line ID';
      case 'WhatsApp':
        return 'WhatsApp Number';
      default:
        return 'Contact';
    }
  }

  // Helper method to display room photo from different sources (base64, URL, or file path)
  Widget _buildRoomPhotoImage(String roomPhotoPath) {
    print('🖼️ Room photo path received: ${roomPhotoPath.substring(0, roomPhotoPath.length > 100 ? 100 : roomPhotoPath.length)}...');
    return _buildSmartImage(roomPhotoPath, width: double.infinity, height: 250);
  }

  // Smart image builder that handles base64, URLs, and file paths
  Widget _buildSmartImage(String imagePath, {BoxFit fit = BoxFit.cover, double? width, double? height}) {
    try {
      // Check if it's a URL (starts with http or https)
      if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
        return Image.network(
          imagePath,
          width: width,
          height: height,
          fit: fit,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              height: height ?? 250,
              width: width,
              color: kBackgroundBeige,
              child: Center(
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                      : null,
                ),
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) => _buildImageError('Failed to load image'),
        );
      }
      
      // Check if it's a local file path
      if (imagePath.startsWith('/') || imagePath.contains(':\\')) {
        final file = File(imagePath);
        if (file.existsSync()) {
          return Image.file(
            file,
            width: width,
            height: height,
            fit: fit,
            errorBuilder: (context, error, stackTrace) => _buildImageError('Image file not found'),
          );
        }
        // File doesn't exist, try base64
      }
      
      // Default: treat as base64 encoded image
      final Uint8List imageBytes = base64Decode(imagePath);
      return Image.memory(
        imageBytes,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) => _buildImageError('Failed to decode image'),
      );
    } catch (e) {
      return _buildImageError('Error loading image');
    }
  }

  Widget _buildImageError(String message) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kNoghreiSilver,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.image_not_supported, size: 48, color: kTinGrey),
          const SizedBox(height: 8),
          Text(message, style: kNunitoSans12Grey, textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isLink = false, bool showColorBox = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: kNunitoSans14.copyWith(color: kTinGrey, fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            flex: 3,
            child: Row(
              children: [
                if (showColorBox && value.startsWith('#')) ...[
                  Container(
                    width: 24,
                    height: 24,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: Color(int.parse(value.substring(1), radix: 16) + 0xFF000000),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: kTinGrey.withOpacity(0.3)),
                    ),
                  ),
                ],
                Expanded(
                  child: isLink
                      ? GestureDetector(
                          onTap: () async {
                            await Clipboard.setData(ClipboardData(text: value));
                            Get.snackbar(
                              'Copied',
                              'GLB URL copied to clipboard',
                              snackPosition: SnackPosition.BOTTOM,
                            );
                          },
                          child: Text(
                            value,
                            style: kNunitoSans14.copyWith(
                              color: Colors.blue,
                              decoration: TextDecoration.underline,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        )
                      : Text(
                          value,
                          style: kNunitoSans14.copyWith(color: kOffBlack),
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: kBackgroundBeige,
        appBar: AppBar(
          backgroundColor: kBackgroundBeige,
          leading: IconButton(
            onPressed: () => Get.back(),
            icon: const Icon(Icons.arrow_back_ios_new, color: kOffBlack, size: 20),
          ),
          centerTitle: true,
          title: const Text("ORDER DETAILS", style: kMerriweatherBold16),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_order == null) {
      return Scaffold(
        backgroundColor: kBackgroundBeige,
        appBar: AppBar(
          backgroundColor: kBackgroundBeige,
          leading: IconButton(
            onPressed: () => Get.back(),
            icon: const Icon(Icons.arrow_back_ios_new, color: kOffBlack, size: 20),
          ),
          centerTitle: true,
          title: const Text("ORDER DETAILS", style: kMerriweatherBold16),
        ),
        body: const Center(child: Text('Order not found')),
      );
    }

    final order = _order!;
    final personalization = order.personalizationData;
    final onboarding = order.onboardingData;

    return Scaffold(
      backgroundColor: kBackgroundBeige,
      appBar: AppBar(
        backgroundColor: kBackgroundBeige,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(Icons.arrow_back_ios_new, color: kOffBlack, size: 20),
        ),
        centerTitle: true,
        title: const Text("ORDER DETAILS", style: kMerriweatherBold16),
        bottom: _tabController != null
            ? TabBar(
                controller: _tabController,
                labelColor: kOffBlack,
                unselectedLabelColor: kTinGrey,
                indicatorColor: kSeaGreen,
                indicatorWeight: 3,
                tabs: const [
                  Tab(
                    icon: Icon(Icons.shopping_bag, size: 20),
                    text: 'Product Details',
                  ),
                  Tab(
                    icon: Icon(Icons.support_agent, size: 20),
                    text: 'Concierge',
                  ),
                ],
              )
            : null,
      ),
      body: _tabController != null
          ? TabBarView(
              controller: _tabController,
              children: [
                _buildProductDetails(order, personalization, onboarding),
                _buildConciergeDetails(),
              ],
            )
          : _buildProductDetails(order, personalization, onboarding),
    );
  }

  Widget _buildProductDetails(SofaOrder order, personalization, onboarding) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    order.sofaName,
                    style: kMerriweatherBold24,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getStatusColor(order.status),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    _statusText(order.status),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Order #${order.id.substring(0, 8).toUpperCase()}',
              style: kNunitoSans14.copyWith(color: kTinGrey),
            ),
            const SizedBox(height: 4),
            Text(
              'Placed on ${order.createdAt.day}/${order.createdAt.month}/${order.createdAt.year}',
              style: kNunitoSans14.copyWith(color: kTinGrey),
            ),

            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),

            // Customer Information
            Text('CUSTOMER INFORMATION', style: kNunitoSansBold18),
            const SizedBox(height: 12),
            _buildInfoRow('Name', order.userName),
            _buildInfoRow('Email', order.userEmail),
            _buildInfoRow('User ID', order.userId),

            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),

            // GLB Download Link
            Text('3D MODEL', style: kNunitoSansBold18),
            const SizedBox(height: 12),
            if (order.glbUrl != null) ...[
              _buildInfoRow('GLB URL (tap to copy)', order.glbUrl!, isLink: true),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _view3DModel(context, order.glbUrl!),
                  icon: const Icon(Icons.view_in_ar, color: Colors.white),
                  label: const Text('View 3D Model', style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kCrayolaGreen,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ] else
              Text('No 3D model available', style: kNunitoSans14.copyWith(color: kTinGrey)),

            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),

            // Pricing (show only total)
            Text('PRICING', style: kNunitoSansBold18),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Total', style: kNunitoSansBold18),
                Text(
                  '฿${order.totalPrice.toStringAsFixed(2)}',
                  style: kNunitoSansBold18.copyWith(color: kSeaGreen),
                ),
              ],
            ),

            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),

            // Delivery Address
            if (order.deliveryAddress != null) ...[
              Text('DELIVERY ADDRESS', style: kNunitoSansBold18),
              const SizedBox(height: 12),
              Text(order.deliveryAddress!, style: kNunitoSans14),
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 16),
            ],

            // Personalization Details (All 8 Steps)
            Text('PERSONALIZATION PREFERENCES (8 Steps)', style: kNunitoSansBold18),
            const SizedBox(height: 16),
            
            _buildPersonalizationSteps(personalization),

            // Room Photo if uploaded
            if (personalization.roomPhotoPath != null && personalization.roomPhotoPath!.isNotEmpty) ...[
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 16),
              Text('ROOM PHOTO UPLOADED', style: kNunitoSansBold18),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () => _showFullScreenImage(context, personalization.roomPhotoPath!, title: 'Room Photo'),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: _buildRoomPhotoImage(personalization.roomPhotoPath!),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Tap to view full size',
                style: kNunitoSans12Grey.copyWith(
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],

            // Customer's Change Preferences Note
            if (personalization.finalPreferences?.changePreferencesNote != null && 
                personalization.finalPreferences!.changePreferencesNote!.isNotEmpty) ...[
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 16),
              Text('CUSTOMER NOTE', style: kNunitoSansBold18),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.amber.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.sticky_note_2_outlined, color: Colors.amber[700], size: 18),
                        const SizedBox(width: 8),
                        Text(
                          'Customer\'s Special Requests',
                          style: kNunitoSansSemiBold16.copyWith(color: Colors.amber[700]),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      personalization.finalPreferences!.changePreferencesNote!,
                      style: kNunitoSans14.copyWith(color: kOffBlack),
                    ),
                  ],
                ),
              ),
            ],

            // Onboarding Data (Lifestyle) - All fields
            if (onboarding != null) ...[
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 16),
              Text('LIFESTYLE PREFERENCES (Onboarding)', style: kNunitoSansBold18),
              const SizedBox(height: 12),
              _buildInfoRow('Personality Type', onboarding.personalityType ?? 'N/A'),
              _buildInfoRow('Home Type', onboarding.homeType ?? 'N/A'),
              _buildInfoRow('Living Style', onboarding.livingStyle ?? 'N/A'),
              _buildInfoRow('Living Room Feeling', onboarding.livingRoomFeeling ?? 'N/A'),
              _buildInfoRow('Relaxation Activity', onboarding.relaxationActivity ?? 'N/A'),
              if (onboarding.comfortWords != null && onboarding.comfortWords.isNotEmpty)
                _buildInfoRow('Comfort Words', onboarding.comfortWords.join(', ')),
            ],

            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),

            // Admin Notes
            Text('ADMIN NOTES', style: kNunitoSansBold18),
            const SizedBox(height: 12),
            TextField(
              controller: _adminNotesController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Add notes for internal reference...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),

            const SizedBox(height: 24),

            // Action Buttons
            if (order.status == OrderStatus.pending) ...[
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isProcessing ? null : () => _updateOrderStatus(OrderStatus.processing),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kSeaGreen,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const Text('APPROVE ORDER', style: TextStyle(color: Colors.white)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isProcessing ? null : _showRejectDialog,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kFireOpal,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const Text('REJECT ORDER', style: TextStyle(color: Colors.white)),
                      ),
                    ),
                  ),
                ],
              ),
            ],

            if (order.status == OrderStatus.processing) ...[
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isProcessing ? null : () => _updateOrderStatus(OrderStatus.delivered),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kCrayolaGreen,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('MARK AS DELIVERED', style: TextStyle(color: Colors.white)),
                ),
              ),
            ],

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  // Build comprehensive personalization steps
  Widget _buildPersonalizationSteps(personalization) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Step 1: Audience Selection
        _buildStepCard(
          stepNumber: 1,
          title: 'Audience Selection',
          icon: Icons.people,
          children: [
            _buildInfoRow('Audience Type', 
              personalization.audienceType?.toString().split('.').last.toUpperCase() ?? 'Not specified'),
          ],
        ),
        
        // Step 2: Usage Style (varies by audience)
        if (personalization.usageStyle != null)
          _buildStepCard(
            stepNumber: 2,
            title: 'Usage Style & Preferences',
            icon: Icons.chair_outlined,
            children: [
              // Adult-specific fields
              if (personalization.usageStyle!.usagePattern != null)
                _buildInfoRow('Usage Pattern', 
                  personalization.usageStyle!.usagePattern.toString().split('.').last.replaceAll(RegExp(r'([A-Z])'), ' \$1').trim()),
              if (personalization.usageStyle!.firmnessPreference != null)
                _buildInfoRow('Firmness Preference', 
                  personalization.usageStyle!.firmnessPreference.toString().split('.').last.toUpperCase()),
              if (personalization.usageStyle!.sofaCapacity != null)
                _buildInfoRow('Capacity', 
                  personalization.usageStyle!.sofaCapacity.toString().split('.').last.toUpperCase()),
              if (personalization.usageStyle!.seatSupport != null)
                _buildInfoRow('Seat Support', 
                  personalization.usageStyle!.seatSupport.toString().split('.').last.replaceAll(RegExp(r'([A-Z])'), ' \$1').trim()),
              
              // Child-specific fields
              if (personalization.usageStyle!.childUsageType != null)
                _buildInfoRow('Child Usage Type', 
                  personalization.usageStyle!.childUsageType.toString().split('.').last.replaceAll(RegExp(r'([A-Z])'), ' \$1').trim()),
              if (personalization.usageStyle!.familyPriority != null)
                _buildInfoRow('Family Priority', 
                  personalization.usageStyle!.familyPriority.toString().split('.').last.replaceAll(RegExp(r'([A-Z])'), ' \$1').trim()),
              if (personalization.usageStyle!.numberOfChildren != null)
                _buildInfoRow('Number of Children', 
                  personalization.usageStyle!.numberOfChildren.toString()),
              if (personalization.usageStyle!.growthAdaptable != null)
                _buildInfoRow('Growth Adaptable', 
                  personalization.usageStyle!.growthAdaptable! ? 'Yes' : 'No'),
              
              // Pet-specific fields (Health)
              if (personalization.usageStyle!.petType != null)
                _buildInfoRow('Pet Type', 
                  personalization.usageStyle!.petType.toString().split('.').last.toUpperCase()),
              if (personalization.usageStyle!.petSize != null)
                _buildInfoRow('Pet Size', 
                  personalization.usageStyle!.petSize.toString().split('.').last.toUpperCase()),
              if (personalization.usageStyle!.temperatureSensitivity != null)
                _buildInfoRow('Temperature Sensitivity', 
                  personalization.usageStyle!.temperatureSensitivity.toString().split('.').last.replaceAll(RegExp(r'([A-Z])'), ' \$1').trim()),
              if (personalization.usageStyle!.heightPreference != null)
                _buildInfoRow('Height Preference', 
                  personalization.usageStyle!.heightPreference.toString().split('.').last.replaceAll(RegExp(r'([A-Z])'), ' \$1').trim()),
              
              // Pet-specific fields (Usage)
              if (personalization.usageStyle!.numberOfPets != null)
                _buildInfoRow('Number of Pets', 
                  personalization.usageStyle!.numberOfPets.toString()),
              if (personalization.usageStyle!.petSeatingStyle != null)
                _buildInfoRow('Pet Seating Style', 
                  personalization.usageStyle!.petSeatingStyle.toString().split('.').last.replaceAll(RegExp(r'([A-Z])'), ' \$1').trim()),
              if (personalization.usageStyle!.petRelaxLocation != null)
                _buildInfoRow('Pet Relax Location', 
                  personalization.usageStyle!.petRelaxLocation.toString().split('.').last.replaceAll(RegExp(r'([A-Z])'), ' \$1').trim()),
              if (personalization.usageStyle!.wearLevel != null)
                _buildInfoRow('Wear Level', 
                  personalization.usageStyle!.wearLevel.toString().split('.').last.toUpperCase()),
            ],
          ),
        
        // Step 3: Style & Material
        if (personalization.styleMaterial != null)
          _buildStepCard(
            stepNumber: 3,
            title: 'Style & Material Selection',
            icon: Icons.texture,
            children: [
              if (personalization.styleMaterial!.materialType != null)
                _buildInfoRow('Material Type', 
                  personalization.styleMaterial!.materialType.toString().split('.').last.replaceAll(RegExp(r'([A-Z])'), ' \$1').trim()),
              if (personalization.styleMaterial!.functionalityTypes != null && 
                  personalization.styleMaterial!.functionalityTypes!.isNotEmpty)
                _buildInfoRow('Functionality Features', 
                  personalization.styleMaterial!.functionalityTypes!
                      .map((e) => e.toString().split('.').last.replaceAll(RegExp(r'([A-Z])'), ' \$1').trim())
                      .join(', ')),
            ],
          ),
        
        // Step 4: Color, Pattern & Details
        if (personalization.personalizationDetails != null)
          _buildStepCard(
            stepNumber: 4,
            title: 'Color & Personalization Details',
            icon: Icons.palette,
            children: [
              if (personalization.personalizationDetails!.colorHex != null)
                _buildInfoRow('Color', 
                  personalization.personalizationDetails!.colorHex!,
                  showColorBox: true),
              if (personalization.personalizationDetails!.pantoneCode != null)
                _buildInfoRow('Pantone Code', 
                  personalization.personalizationDetails!.pantoneCode!),
              if (personalization.personalizationDetails!.patternType != null)
                _buildInfoRow('Pattern Type', 
                  personalization.personalizationDetails!.patternType.toString().split('.').last.toUpperCase()),
              if (personalization.personalizationDetails!.stitchingType != null)
                _buildInfoRow('Stitching Type', 
                  personalization.personalizationDetails!.stitchingType.toString().split('.').last.toUpperCase()),
              if (personalization.personalizationDetails!.legType != null)
                _buildInfoRow('Leg Type', 
                  personalization.personalizationDetails!.legType.toString().split('.').last.toUpperCase()),
              if (personalization.personalizationDetails!.finishType != null)
                _buildInfoRow('Finish Type', 
                  personalization.personalizationDetails!.finishType.toString().split('.').last.toUpperCase()),
            ],
          ),
        
        // Step 5: Comfort Preferences
        if (personalization.comfortPreferences != null)
          _buildStepCard(
            stepNumber: 5,
            title: 'Comfort Preferences',
            icon: Icons.airline_seat_recline_extra,
            children: [
              if (personalization.comfortPreferences!.cushionFirmness != null)
                _buildInfoRow('Cushion Firmness', 
                  personalization.comfortPreferences!.cushionFirmness!),
              if (personalization.comfortPreferences!.seatDepth != null)
                _buildInfoRow('Seat Depth', 
                  personalization.comfortPreferences!.seatDepth!),
              if (personalization.comfortPreferences!.backSupport != null)
                _buildInfoRow('Back Support', 
                  personalization.comfortPreferences!.backSupport! ? 'Yes' : 'No'),
              if (personalization.comfortPreferences!.armrests != null)
                _buildInfoRow('Armrests', 
                  personalization.comfortPreferences!.armrests! ? 'Yes' : 'No'),
              if (personalization.comfortPreferences!.headrest != null)
                _buildInfoRow('Headrest', 
                  personalization.comfortPreferences!.headrest! ? 'Yes' : 'No'),
              if (personalization.comfortPreferences!.tallUsers != null)
                _buildInfoRow('Tall Users Friendly', 
                  personalization.comfortPreferences!.tallUsers! ? 'Yes' : 'No'),
              if (personalization.comfortPreferences!.elderlyFriendly != null)
                _buildInfoRow('Elderly Friendly', 
                  personalization.comfortPreferences!.elderlyFriendly! ? 'Yes' : 'No'),
            ],
          ),
        
        // Step 6: Nice-to-Haves
        if (personalization.niceToHaves != null)
          _buildStepCard(
            stepNumber: 6,
            title: 'Additional Features & Extras',
            icon: Icons.add_circle_outline,
            children: [
              if (personalization.niceToHaves!.extras != null && personalization.niceToHaves!.extras!.isNotEmpty)
                _buildInfoRow('Extras', 
                  personalization.niceToHaves!.extras!.join(', ')),
              if (personalization.niceToHaves!.modularExpandable != null)
                _buildInfoRow('Modular/Expandable', 
                  personalization.niceToHaves!.modularExpandable! ? 'Yes' : 'No'),
              if (personalization.niceToHaves!.features != null && personalization.niceToHaves!.features!.isNotEmpty)
                _buildInfoRow('Features', 
                  personalization.niceToHaves!.features!.join(', ')),
              if (personalization.niceToHaves!.additionalRequests != null)
                _buildInfoRow('Additional Requests', 
                  personalization.niceToHaves!.additionalRequests!),
            ],
          ),
        
        // Step 7: Final Preferences
        if (personalization.finalPreferences != null)
          _buildStepCard(
            stepNumber: 7,
            title: 'Final Preferences & Priorities',
            icon: Icons.star,
            children: [
              if (personalization.finalPreferences!.whatMattersMost != null)
                _buildInfoRow('What Matters Most', 
                  personalization.finalPreferences!.whatMattersMost!),
              if (personalization.finalPreferences!.washableReplaceableCovers != null)
                _buildInfoRow('Washable/Replaceable Covers', 
                  personalization.finalPreferences!.washableReplaceableCovers! ? 'Yes' : 'No'),
              if (personalization.finalPreferences!.ecoFriendly != null)
                _buildInfoRow('Eco-Friendly Preference', 
                  personalization.finalPreferences!.ecoFriendly!),
            ],
          ),
        
        // Step 8: Room Context (if photo uploaded)
        if (personalization.roomPhotoPath != null && personalization.roomPhotoPath!.isNotEmpty)
          _buildStepCard(
            stepNumber: 8,
            title: 'Room Context Photo',
            icon: Icons.photo_camera,
            children: [
              const SizedBox(height: 8),
              Text('Room photo uploaded for context', style: kNunitoSans14.copyWith(color: kTinGrey)),
              const SizedBox(height: 12),
            ],
          ),
      ],
    );
  }

  Widget _buildStepCard({
    required int stepNumber,
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kSeaGreen.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: kSeaGreen,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    '$stepNumber',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Icon(icon, color: kSeaGreen, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: kNunitoSansSemiBold16.copyWith(fontSize: 15),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  // Build concierge details tab
  Widget _buildConciergeDetails() {
    if (_conciergeBooking == null) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Text(
            'No concierge booking associated with this order',
            style: kNunitoSans14,
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    final booking = _conciergeBooking!;
    
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 16),
          
          // Header with Concierge Photo, Name, and Status
          Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x08000000),
                  offset: Offset(0, 2),
                  blurRadius: 8,
                ),
              ],
            ),
            child: Column(
              children: [
                // Concierge Photo
                if (booking['concierge_photo_url'] != null &&
                    booking['concierge_photo_url'].toString().isNotEmpty)
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: kSeaGreen, width: 3),
                    ),
                    child: CircleAvatar(
                      radius: 45,
                      backgroundImage: NetworkImage(
                        booking['concierge_photo_url'],
                      ),
                      backgroundColor: Colors.white,
                    ),
                  )
                else
                  const CircleAvatar(
                    radius: 45,
                    backgroundImage: AssetImage('assets/SJ.jpeg'),
                    backgroundColor: Colors.white,
                  ),
                const SizedBox(height: 16),

                // Concierge Name
                Text(
                  booking['concierge_name'] ?? "Concierge",
                  style: kNunitoSansSemiBold18.copyWith(
                    fontSize: 20,
                    color: kOffBlack,
                  ),
                ),
                const SizedBox(height: 6),

                // Status Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: booking['status'] == 'confirmed'
                        ? kSeaGreen
                        : booking['status'] == 'cancelled'
                            ? kFireOpal
                            : kOffBlack,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    booking['status']?.toString().toUpperCase() ?? 'PENDING',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Appointment Details Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              "APPOINTMENT DETAILS",
              style: kNunitoSansSemiBold18.copyWith(
                fontSize: 16,
                color: kOffBlack,
                letterSpacing: 0.5,
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Date & Time
          if (booking['visit_date'] != null || booking['visit_time'] != null)
            _buildDetailCard(
              icon: Icons.calendar_today_rounded,
              iconColor: kSeaGreen,
              title: "Date & Time",
              details: [
                if (booking['visit_date'] != null) booking['visit_date'],
                if (booking['visit_time'] != null) booking['visit_time'],
              ],
            ),

          // Location
          if (booking['visit_address'] != null)
            _buildDetailCard(
              icon: Icons.location_on_rounded,
              iconColor: Colors.red,
              title: "Visit Location",
              details: [booking['visit_address']],
            ),

          // Contact Preference - ADMIN VIEW (shows full contact details)
          if (booking['contact_method'] != null || booking['contact'] != null)
            Builder(
              builder: (context) {
                // DEBUG: Print all contact-related fields
                print('🔍 ========== CONTACT INFO DEBUG ==========');
                print('🔍 contact_method: ${booking['contact_method']}');
                print('🔍 contact: ${booking['contact']}');
                print('🔍 contact is null? ${booking['contact'] == null}');
                print('🔍 contact is empty? ${booking['contact']?.toString().isEmpty}');
                print('🔍 All booking keys: ${booking.keys.toList()}');
                print('🔍 ========================================');
                
                final hasContactValue = booking['contact'] != null && 
                                       booking['contact'].toString().isNotEmpty;
                final contactMethod = booking['contact_method'];
                
                return _buildDetailCard(
                  icon: Icons.contact_phone_rounded,
                  iconColor: Colors.blue,
                  title: "Contact Information",
                  details: [
                    // Show contact method (e.g., "Phone", "Email", "Line", "WhatsApp")
                    if (contactMethod != null)
                      'Method: $contactMethod',
                    // Show actual contact value (phone number, email, etc.) - ADMIN ONLY
                    if (hasContactValue)
                      '${_getContactLabel(contactMethod)}: ${booking['contact']}'
                    else
                      '⚠️ Contact details not provided',
                  ],
                );
              }
            ),

          // Payment Information - ADMIN VIEW (shows full payment details + QR proof)
          if (booking['amount'] != null)
            _buildPaymentDetailCard(
              booking: booking,
            ),

          const SizedBox(height: 32),
          
          // CONFIRM CONCIERGE BUTTON - For pending bookings only
          if (booking['status'] == 'pending')
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _isProcessing ? null : () => _confirmConciergeBooking(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kSeaGreen,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 2,
                  ),
                  icon: const Icon(Icons.check_circle, color: Colors.white),
                  label: const Text(
                    'CONFIRM CONCIERGE VISIT',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // New widget for payment details with QR code image
  Widget _buildPaymentDetailCard({required Map<String, dynamic> booking}) {
    final paymentMethod = booking['payment_method']?.toString().toUpperCase() ?? 'N/A';
    // ✅ FIXED: Check for base64 field instead of URL field
    final hasQRProof = booking['payment_proof_base64'] != null && 
                       booking['payment_proof_base64'].toString().isNotEmpty;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.payment_rounded,
                  color: Colors.green,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Payment Information',
                style: kNunitoSansSemiBold16.copyWith(
                  color: kOffBlack,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Payment Details
          _buildPaymentInfoRow('Amount', '฿${booking['amount'].toStringAsFixed(2)}'),
          _buildPaymentInfoRow('Payment Method', paymentMethod),
          if (booking['transaction_id'] != null)
            _buildPaymentInfoRow('Transaction ID', booking['transaction_id']),
          
          // QR Code Payment Proof
          if (hasQRProof) ...[
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            Text(
              'Payment Proof (QR Code Screenshot)',
              style: kNunitoSans14.copyWith(
                color: kOffBlack,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () => _showFullImage(context, booking['payment_proof_base64']),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: _buildSmartImage(
                  booking['payment_proof_base64'],
                  height: 200,
                  width: double.infinity,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap to view full size',
              style: kNunitoSans12Grey.copyWith(
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPaymentInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: kNunitoSans14.copyWith(
              color: kGrey,
            ),
          ),
          Text(
            value,
            style: kNunitoSans14.copyWith(
              color: kOffBlack,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  void _showFullScreenImage(BuildContext context, String imagePath, {String title = 'Image'}) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: _buildSmartImage(imagePath, fit: BoxFit.contain),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.white),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.black.withOpacity(0.5),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: kNunitoSansSemiBold16.copyWith(
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Legacy method for backward compatibility
  void _showFullImage(BuildContext context, String imageUrl) {
    _showFullScreenImage(context, imageUrl, title: 'Payment Proof');
  }

  Widget _buildDetailCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required List<String> details,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            offset: Offset(0, 2),
            blurRadius: 8,
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: kNunitoSansSemiBold18.copyWith(
                    fontSize: 15,
                    color: kOffBlack,
                  ),
                ),
                const SizedBox(height: 6),
                ...details.map(
                  (detail) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      detail,
                      style: kNunitoSans14.copyWith(
                        color: kTinGrey,
                        height: 1.4,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
