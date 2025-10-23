import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:timberr/constants.dart';
import 'package:timberr/models/sofa_order.dart';
import 'package:timberr/services/order_service.dart';

class AdminOrderDetailScreen extends StatefulWidget {
  final String orderId;

  const AdminOrderDetailScreen({super.key, required this.orderId});

  @override
  State<AdminOrderDetailScreen> createState() => _AdminOrderDetailScreenState();
}

class _AdminOrderDetailScreenState extends State<AdminOrderDetailScreen> {
  SofaOrder? _order;
  bool _isLoading = true;
  bool _isProcessing = false;
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
    super.dispose();
  }

  Future<void> _loadOrder() async {
    setState(() => _isLoading = true);
    final order = await OrderService.getOrderById(widget.orderId);
    setState(() {
      _order = order;
      _adminNotesController.text = order?.adminNotes ?? '';
      _rejectionReasonController.text = order?.rejectionReason ?? '';
      _isLoading = false;
    });
  }

  Future<void> _updateOrderStatus(OrderStatus newStatus, {String? rejectionReason}) async {
    setState(() => _isProcessing = true);
    
    final success = await OrderService.updateOrderStatus(
      orderId: widget.orderId,
      status: newStatus,
      adminNotes: _adminNotesController.text.isNotEmpty ? _adminNotesController.text : null,
      rejectionReason: rejectionReason,
    );

    setState(() => _isProcessing = false);

    if (success) {
      Get.snackbar(
        'Success',
        'Order status updated to ${_statusText(newStatus)}',
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

  Widget _buildInfoRow(String label, String value, {bool isLink = false}) {
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
      ),
      body: SingleChildScrollView(
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
              if (order.glbUrl != null)
                _buildInfoRow('GLB URL (tap to copy)', order.glbUrl!, isLink: true)
              else
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

              // Personalization Details (Step 1-8)
              Text('PERSONALIZATION PREFERENCES', style: kNunitoSansBold18),
              const SizedBox(height: 16),
              
              // Step 1: Audience
              Text('Step 1: Audience', style: kNunitoSansSemiBold16),
              const SizedBox(height: 8),
              _buildInfoRow('Audience Type', personalization.audienceType?.toString().split('.').last.toUpperCase() ?? 'N/A'),
              
              // Step 2: Usage Style
              if (personalization.usageStyle != null) ...[
                const SizedBox(height: 12),
                Text('Step 2: Usage Style', style: kNunitoSansSemiBold16),
                const SizedBox(height: 8),
                _buildInfoRow('Usage Pattern', personalization.usageStyle!.usagePattern?.toString().split('.').last ?? 'N/A'),
                _buildInfoRow('Firmness', personalization.usageStyle!.firmnessPreference?.toString().split('.').last ?? 'N/A'),
                _buildInfoRow('Capacity', personalization.usageStyle!.sofaCapacity?.toString().split('.').last ?? 'N/A'),
              ],
              
              // Step 3: Style & Material
              if (personalization.styleMaterial != null) ...[
                const SizedBox(height: 12),
                Text('Step 3: Style & Material', style: kNunitoSansSemiBold16),
                const SizedBox(height: 8),
                _buildInfoRow('Material Type', personalization.styleMaterial!.materialType?.toString().split('.').last ?? 'N/A'),
              ],
              
              // Step 4: Color & Details
              if (personalization.personalizationDetails != null) ...[
                const SizedBox(height: 12),
                Text('Step 4: Color & Details', style: kNunitoSansSemiBold16),
                const SizedBox(height: 8),
                _buildInfoRow('Color Code', personalization.personalizationDetails!.colorHex ?? 'N/A'),
                _buildInfoRow('Pattern', personalization.personalizationDetails!.patternType?.toString().split('.').last ?? 'N/A'),
                _buildInfoRow('Stitching', personalization.personalizationDetails!.stitchingType?.toString().split('.').last ?? 'N/A'),
                _buildInfoRow('Leg Type', personalization.personalizationDetails!.legType?.toString().split('.').last ?? 'N/A'),
                _buildInfoRow('Finish', personalization.personalizationDetails!.finishType?.toString().split('.').last ?? 'N/A'),
              ],

              // Onboarding Data (Lifestyle)
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
                if (onboarding.comfortWords.isNotEmpty)
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
      ),
    );
  }
}
