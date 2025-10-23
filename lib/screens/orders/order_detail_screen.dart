import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:timberr/constants.dart';
import 'package:timberr/models/sofa_order.dart';
import 'package:timberr/services/order_service.dart';
import 'package:timberr/widgets/glb_viewer.dart';

class OrderDetailScreen extends StatefulWidget {
  final String orderId;

  const OrderDetailScreen({super.key, required this.orderId});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  SofaOrder? _order;
  bool _isLoading = true;
  bool _isCancelling = false;

  @override
  void initState() {
    super.initState();
    _loadOrder();
  }

  Future<void> _loadOrder() async {
    setState(() => _isLoading = true);
    final order = await OrderService.getOrderById(widget.orderId);
    setState(() {
      _order = order;
      _isLoading = false;
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
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 3D Model Viewer
            if (order.glbUrl != null && order.glbUrl!.isNotEmpty)
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
      ),
    );
  }
}
