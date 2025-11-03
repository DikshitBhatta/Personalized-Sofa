import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:timberr/constants.dart';
import 'package:timberr/models/sofa_order.dart';
import 'package:timberr/services/order_service.dart';
import 'package:timberr/widgets/glb_viewer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:timberr/screens/profile/edit_concierge_booking_screen.dart';
import 'package:timberr/screens/fullscreen_3d_view.dart';

class OrderDetailScreen extends StatefulWidget {
  final String orderId;

  const OrderDetailScreen({super.key, required this.orderId});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> with SingleTickerProviderStateMixin {
  SofaOrder? _order;
  bool _isLoading = true;
  bool _isCancelling = false;
  Map<String, dynamic>? _conciergeBooking;
  TabController? _tabController;

  @override
  void initState() {
    super.initState();
    _loadOrder();
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  Future<void> _loadOrder() async {
    setState(() => _isLoading = true);
    final order = await OrderService.getOrderById(widget.orderId);
    
    // Load associated concierge booking if any
    Map<String, dynamic>? conciergeBooking;
    if (order != null) {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        try {
          // First, check if order has a direct concierge_booking_id reference
          if (order.adminNotes != null && order.adminNotes!.contains('concierge_booking_id:')) {
            final bookingIdMatch = RegExp(r'concierge_booking_id:\s*(\S+)').firstMatch(order.adminNotes!);
            if (bookingIdMatch != null) {
              final bookingId = bookingIdMatch.group(1);
              final bookingDoc = await FirebaseFirestore.instance
                  .collection('concierge_bookings')
                  .doc(bookingId)
                  .get();
              if (bookingDoc.exists) {
                conciergeBooking = bookingDoc.data();
                conciergeBooking!['id'] = bookingDoc.id;
              }
            }
          }
          
          // If no direct reference, query by user and time proximity
          if (conciergeBooking == null) {
            final bookingsSnapshot = await FirebaseFirestore.instance
                .collection('concierge_bookings')
                .where('client_id', isEqualTo: currentUser.uid)
                .orderBy('created_at', descending: true)
                .limit(10)
                .get();
            
            // Find booking created within 1 hour of order creation
            if (bookingsSnapshot.docs.isNotEmpty) {
              for (var doc in bookingsSnapshot.docs) {
                final bookingData = doc.data();
                final bookingTime = (bookingData['created_at'] as Timestamp?)?.toDate();
                
                if (bookingTime != null) {
                  final timeDifference = order.createdAt.difference(bookingTime).abs();
                  // If booking was created within 1 hour of order, consider it linked
                  if (timeDifference.inHours < 1) {
                    conciergeBooking = bookingData;
                    conciergeBooking['id'] = doc.id;
                    break;
                  }
                }
              }
              
              // If no close match found, just use the most recent one
              if (conciergeBooking == null && bookingsSnapshot.docs.isNotEmpty) {
                conciergeBooking = bookingsSnapshot.docs.first.data();
                conciergeBooking['id'] = bookingsSnapshot.docs.first.id;
              }
            }
          }
        } catch (e) {
          print('Error loading concierge booking: $e');
        }
      }
    }
    
    setState(() {
      _order = order;
      _conciergeBooking = conciergeBooking;
      _isLoading = false;
      
      // Debug: Log concierge booking status
      if (conciergeBooking != null) {
        print('✅ Concierge booking found for order ${widget.orderId}');
        print('   Booking ID: ${conciergeBooking['id']}');
        print('   Concierge: ${conciergeBooking['concierge_name']}');
        print('   Status: ${conciergeBooking['status']}');
      } else {
        print('❌ No concierge booking found for order ${widget.orderId}');
      }
      
      // Initialize tab controller if we have concierge booking
      if (_conciergeBooking != null) {
        _tabController = TabController(length: 2, vsync: this);
        print('✅ Tab controller initialized with 2 tabs');
      }
    });
  }

  Future<void> _cancelOrder() async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Cancel Order?'),
        content: const Text('Are you sure you want to cancel this order?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(backgroundColor: kFireOpal),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() => _isCancelling = true);
      final success = await OrderService.cancelOrder(widget.orderId);
      setState(() => _isCancelling = false);

      if (success) {
        Get.snackbar(
          'Success',
          'Order cancelled successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: kCrayolaGreen,
          colorText: Colors.white,
        );
        _loadOrder(); // Reload to get updated status
      } else {
        Get.snackbar(
          'Error',
          'Failed to cancel order',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: kFireOpal,
          colorText: Colors.white,
        );
      }
    }
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

  String _getStatusText(OrderStatus status) {
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

  Widget _buildPreferenceItem(String label, String? value) {
    if (value == null || value.isEmpty) return const SizedBox.shrink();
    
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
            child: Text(
              value,
              style: kNunitoSans14.copyWith(color: kOffBlack),
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
        bottom: _conciergeBooking != null
            ? TabBar(
                controller: _tabController,
                labelColor: kSeaGreen,
                unselectedLabelColor: kTinGrey,
                indicatorColor: kSeaGreen,
                labelStyle: kNunitoSansSemiBold18.copyWith(fontSize: 14),
                tabs: const [
                  Tab(
                    icon: Icon(Icons.chair_rounded, size: 20),
                    text: "Product",
                  ),
                  Tab(
                    icon: Icon(Icons.person_pin_circle_rounded, size: 20),
                    text: "Concierge",
                  ),
                ],
              )
            : null,
      ),
      body: _conciergeBooking != null
          ? TabBarView(
              controller: _tabController,
              children: [
                _buildProductDetails(order, personalization),
                _buildConciergeDetails(),
              ],
            )
          : _buildProductDetails(order, personalization),
    );
  }

  Widget _buildProductDetails(SofaOrder order, personalization) {
    return SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 3D Model Viewer
            if (order.glbUrl != null && order.glbUrl!.isNotEmpty)
              Stack(
                children: [
                  Container(
                    height: 300,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: GlbViewer(
                      assetPath: order.glbUrl!,
                      height: 300,
                      width: double.infinity,
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: IconButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Fullscreen3DView(assetPath: order.glbUrl!),
                          ),
                        );
                      },
                      icon: const Icon(Icons.fullscreen, color: Colors.white),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.black.withOpacity(0.6),
                      ),
                    ),
                  ),
                ],
              )
            else
              Container(
                height: 300,
                width: double.infinity,
                color: kNoghreiSilver,
                child: const Icon(Icons.chair, size: 100, color: kTinGrey),
              ),

            Padding(
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
                          _getStatusText(order.status),
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

                  // Price Information (show only total)
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

                  // Personalization Details
                  Text('PERSONALIZATION DETAILS', style: kNunitoSansBold18),
                  const SizedBox(height: 16),
                  
                  _buildPreferenceItem('Audience Type', personalization.audienceType?.toString().split('.').last.toUpperCase()),
                  _buildPreferenceItem('Usage Pattern', personalization.usageStyle?.usagePattern?.toString().split('.').last),
                  _buildPreferenceItem('Firmness', personalization.usageStyle?.firmnessPreference?.toString().split('.').last),
                  _buildPreferenceItem('Material Type', personalization.styleMaterial?.materialType?.toString().split('.').last),
                  _buildPreferenceItem('Color Code', personalization.personalizationDetails?.colorHex),
                  _buildPreferenceItem('Pattern', personalization.personalizationDetails?.patternType?.toString().split('.').last),
                  _buildPreferenceItem('Leg Type', personalization.personalizationDetails?.legType?.toString().split('.').last),
                  
                  // User's Change Preferences Note
                  if (personalization.finalPreferences?.changePreferencesNote != null && 
                      personalization.finalPreferences!.changePreferencesNote!.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue.withOpacity(0.2)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.note_outlined, color: Colors.blue, size: 18),
                              const SizedBox(width: 8),
                              Text(
                                'YOUR NOTE',
                                style: kNunitoSansSemiBold16.copyWith(color: Colors.blue[700]),
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
                  
                  // Onboarding Data
                  if (order.onboardingData != null) ...[
                    const SizedBox(height: 16),
                    Text('LIFESTYLE PREFERENCES', style: kNunitoSansBold18),
                    const SizedBox(height: 16),
                    _buildPreferenceItem('Personality Type', order.onboardingData!.personalityType),
                    _buildPreferenceItem('Home Type', order.onboardingData!.homeType),
                    _buildPreferenceItem('Living Style', order.onboardingData!.livingStyle),
                    _buildPreferenceItem('Living Room Feeling', order.onboardingData!.livingRoomFeeling),
                    if (order.onboardingData!.comfortWords.isNotEmpty)
                      _buildPreferenceItem('Comfort Words', order.onboardingData!.comfortWords.join(', ')),
                  ],

                  // Admin Notes
                  if (order.adminNotes != null) ...[
                    const SizedBox(height: 24),
                    const Divider(),
                    const SizedBox(height: 16),
                    Text('ADMIN NOTES', style: kNunitoSansBold18),
                    const SizedBox(height: 12),
                    Text(order.adminNotes!, style: kNunitoSans14),
                  ],

                  // Rejection Reason
                  if (order.rejectionReason != null) ...[
                    const SizedBox(height: 24),
                    const Divider(),
                    const SizedBox(height: 16),
                    Text('CANCELLATION REASON', style: kNunitoSansBold18),
                    const SizedBox(height: 12),
                    Text(order.rejectionReason!, style: kNunitoSans14.copyWith(color: kFireOpal)),
                  ],

                  // Cancel Button
                  if (order.status == OrderStatus.pending) ...[
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 60,
                      child: ElevatedButton(
                        onPressed: _isCancelling ? null : _cancelOrder,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kFireOpal,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: _isCancelling
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text(
                                'CANCEL ORDER',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      );
  }

  Widget _buildConciergeDetails() {
    if (_conciergeBooking == null) {
      return const Center(child: Text('No concierge appointment found'));
    }

    final bookingId = _conciergeBooking!['id'] as String;

    // Use StreamBuilder to listen to real-time updates
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('concierge_bookings')
          .doc(bookingId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: kSeaGreen));
        }

        if (snapshot.hasError || !snapshot.hasData || !snapshot.data!.exists) {
          return const Center(child: Text('Error loading concierge details'));
        }

        final booking = {
          'id': snapshot.data!.id,
          ...snapshot.data!.data() as Map<String, dynamic>,
        };

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Concierge Information Card
              Container(
                width: double.infinity,
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x08000000),
                      offset: Offset(0, 4),
                      blurRadius: 16,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                // Concierge Photo
                if (booking['concierge_photo_url'] != null)
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: kSeaGreen.withOpacity(0.2),
                        width: 3,
                      ),
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

          // Appointment Details
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

          // Contact Preference - USER VIEW (shows method name only, not actual phone/email)
          if (booking['contact_method'] != null)
            _buildDetailCard(
              icon: Icons.chat_bubble_outline_rounded,
              iconColor: Colors.blue,
              title: "Preferred Contact",
              details: [
                booking['contact_method'] ?? 'Not specified'
              ],
            ),

          // Payment Information
          if (booking['amount'] != null)
            _buildDetailCard(
              icon: Icons.payment_rounded,
              iconColor: Colors.green,
              title: "Retainer Amount",
              details: [
                '฿${booking['amount'].toStringAsFixed(2)}',
                if (booking['payment_method'] != null)
                  'via ${booking['payment_method']}',
              ],
            ),

          const SizedBox(height: 16),
          
          // Edit Button (only for pending bookings)
          if (booking['status'] == 'pending') ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Get.to(
                      () => EditConciergeBookingScreen(
                        bookingId: booking['id'] ?? '',
                        booking: booking,
                      ),
                      transition: Transition.cupertino,
                    );
                    // StreamBuilder will automatically update
                  },
                  icon: const Icon(Icons.edit, size: 18),
                  label: const Text('Update Appointment'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kSeaGreen,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ],
      ),
    );
      },
    );
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
