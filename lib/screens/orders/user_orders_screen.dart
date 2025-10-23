import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:timberr/constants.dart';
import 'package:timberr/controllers/order_controller.dart';
import 'package:timberr/models/sofa_order.dart';
import 'package:timberr/screens/orders/order_detail_screen.dart';
import 'package:timberr/widgets/tabbed/curved_bottom_navbar.dart';

class UserOrdersScreen extends StatelessWidget {
  const UserOrdersScreen({super.key});

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
        return 'PENDING';
      case OrderStatus.processing:
        return 'PROCESSING';
      case OrderStatus.delivered:
        return 'DELIVERED';
      case OrderStatus.cancelled:
        return 'CANCELLED';
    }
  }

  Widget _buildOrderList(List<SofaOrder> orders) {
    if (orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shopping_bag_outlined, size: 64, color: kTinGrey),
            const SizedBox(height: 16),
            Text('No orders found', style: kNunitoSans18.copyWith(color: kTinGrey)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      physics: const BouncingScrollPhysics(),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        return GestureDetector(
          onTap: () {
            Get.to(
              () => OrderDetailScreen(orderId: order.id),
              transition: Transition.cupertino,
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeOut,
            );
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
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
                // Thumbnail Image
                if (order.thumbnailUrl != null)
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                    child: Image.network(
                      order.thumbnailUrl!,
                      height: 150,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        height: 150,
                        color: kNoghreiSilver,
                        child: const Icon(Icons.chair, size: 64, color: kTinGrey),
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
                            child: Text(
                              order.sofaName,
                              style: kNunitoSansBold18,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: _getStatusColor(order.status),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              _getStatusText(order.status),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '฿${order.totalPrice.toStringAsFixed(2)}',
                        style: kNunitoSansSemiBold16.copyWith(color: kSeaGreen),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Order #${order.id.substring(0, 8).toUpperCase()}',
                        style: kNunitoSans12Grey,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${order.createdAt.day}/${order.createdAt.month}/${order.createdAt.year}',
                        style: kNunitoSans12Grey,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final orderController = Get.put(OrderController());

    return DefaultTabController(
      length: 3,
      initialIndex: 0,
      child: PopScope(
        canPop: false,
        onPopInvoked: (_) => kOnExitConfirmation(),
        child: Scaffold(
          backgroundColor: kBackgroundBeige,
          appBar: AppBar(
            backgroundColor: kBackgroundBeige,
            automaticallyImplyLeading: false,
            centerTitle: true,
            title: const Text(
              "MY ORDERS",
              style: kMerriweatherBold16,
            ),
            bottom: TabBar(
              labelColor: kOffBlack,
              labelStyle: kNunitoSansBold18,
              unselectedLabelColor: kTinGrey,
              unselectedLabelStyle: kNunitoSans18,
              indicator: BoxDecoration(
                color: kOffBlack,
                borderRadius: BorderRadius.circular(4),
              ),
              indicatorSize: TabBarIndicatorSize.label,
              indicatorWeight: 2,
              indicatorColor: kOffBlack,
              indicatorPadding: const EdgeInsets.only(left: 16, right: 16, top: 43),
              tabs: const [
                Tab(text: "Processing"),
                Tab(text: "Delivered"),
                Tab(text: "Cancelled"),
              ],
            ),
          ),
          bottomNavigationBar: const CurvedBottomNavBar(selectedPos: 1),
          body: Obx(() => TabBarView(
            physics: const BouncingScrollPhysics(),
            children: [
              // Combine pending and processing orders
              _buildOrderList([
                ...orderController.pendingOrders.value,
                ...orderController.processingOrders.value,
              ]),
              _buildOrderList(orderController.deliveredOrders.value),
              _buildOrderList(orderController.cancelledOrders.value),
            ],
          )),
        ),
      ),
    );
  }
}
