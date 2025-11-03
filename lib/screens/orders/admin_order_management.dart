import 'package:flutter/material.dart';
import 'package:timberr/constants.dart';
import 'package:timberr/models/sofa_order.dart';
import 'package:timberr/screens/orders/admin_order_detail_screen.dart';
import 'package:timberr/services/order_service.dart';
import 'package:get/get.dart';

class AdminOrderManagement extends StatelessWidget {
  const AdminOrderManagement({Key? key}) : super(key: key);

  Color _statusColor(OrderStatus status) {
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
        return 'PENDING';
      case OrderStatus.processing:
        return 'PROCESSING';
      case OrderStatus.delivered:
        return 'DELIVERED';
      case OrderStatus.cancelled:
        return 'CANCELLED';
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: kBackgroundBeige,
        appBar: AppBar(
          backgroundColor: kBackgroundBeige,
          title: const Text('Custom Sofa Orders', style: kMerriweatherBold16),
          centerTitle: true,
          elevation: 0,
          bottom: TabBar(
            labelColor: Colors.white,
            labelStyle: kNunitoSansBold16,
            unselectedLabelColor: kOffBlack,
            unselectedLabelStyle: kNunitoSans14,
            indicator: BoxDecoration(
              color: kOffBlack,
              borderRadius: BorderRadius.circular(4),
            ),
            indicatorSize: TabBarIndicatorSize.label,
            isScrollable: true,
            tabs: const [
              Tab(text: "Pending"),
              Tab(text: "Processing"),
              Tab(text: "Delivered"),
              Tab(text: "Cancelled"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildOrderList(OrderStatus.pending),
            _buildOrderList(OrderStatus.processing),
            _buildOrderList(OrderStatus.delivered),
            _buildOrderList(OrderStatus.cancelled),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderList(OrderStatus statusFilter) {
    return StreamBuilder<List<SofaOrder>>(
      stream: OrderService.getAllOrders(status: statusFilter),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: kFireOpal),
                const SizedBox(height: 16),
                Text('Error loading orders', style: kNunitoSans18.copyWith(color: kFireOpal)),
                const SizedBox(height: 8),
                Text(snapshot.error.toString(), style: kNunitoSans14.copyWith(color: kTinGrey)),
              ],
            ),
          );
        }

        final orders = snapshot.data ?? [];
        
        if (orders.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.shopping_bag_outlined, size: 64, color: kTinGrey),
                const SizedBox(height: 16),
                Text('No ${_statusText(statusFilter).toLowerCase()} orders', style: kNunitoSans18.copyWith(color: kTinGrey)),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: orders.length,
          itemBuilder: (context, index) {
            final order = orders[index];
            return GestureDetector(
              onTap: () {
                Get.to(
                  () => AdminOrderDetailScreen(orderId: order.id),
                  transition: Transition.cupertino,
                  duration: const Duration(milliseconds: 600),
                  curve: Curves.easeOut,
                );
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Thumbnail
                    if (order.thumbnailUrl != null)
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                        child: Image.network(
                          order.thumbnailUrl!,
                          height: 120,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            height: 120,
                            color: kNoghreiSilver,
                            child: const Icon(Icons.chair, size: 48, color: kTinGrey),
                          ),
                        ),
                      ),
                    
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      order.sofaName,
                                      style: kNunitoSansSemiBold16,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Order #${order.id.substring(0, 8).toUpperCase()}',
                                      style: kNunitoSans12Grey,
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: _statusColor(order.status),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  _statusText(order.status),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text('Customer: ${order.userName}', style: kNunitoSans14),
                          Text('Email: ${order.userEmail}', style: kNunitoSans12Grey),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '฿${order.totalPrice.toStringAsFixed(2)}',
                                style: kNunitoSansSemiBold16.copyWith(color: kSeaGreen),
                              ),
                              Text(
                                '${order.createdAt.day}/${order.createdAt.month}/${order.createdAt.year}',
                                style: kNunitoSans12Grey,
                              ),
                            ],
                          ),
                          
                          // Quick Actions for Pending Orders
                          if (order.status == OrderStatus.pending) ...[
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () async {
                                      await OrderService.updateOrderStatus(
                                        orderId: order.id,
                                        status: OrderStatus.processing,
                                        adminNotes: 'Order approved and in production',
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: kSeaGreen,
                                      padding: const EdgeInsets.symmetric(vertical: 8),
                                    ),
                                    child: const Text(
                                      'Approve',
                                      style: TextStyle(color: Colors.white, fontSize: 12),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () async {
                                      await OrderService.updateOrderStatus(
                                        orderId: order.id,
                                        status: OrderStatus.cancelled,
                                        rejectionReason: 'Order cancelled by admin',
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: kFireOpal,
                                      padding: const EdgeInsets.symmetric(vertical: 8),
                                    ),
                                    child: const Text(
                                      'Reject',
                                      style: TextStyle(color: Colors.white, fontSize: 12),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
