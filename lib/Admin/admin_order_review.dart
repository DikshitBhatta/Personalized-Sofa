import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:timberr/constants.dart';

class AdminOrderReview extends StatelessWidget {
  const AdminOrderReview({Key? key}) : super(key: key);

  Color _statusColor(String status) {
    if (status == 'processing') return kOffBlack;
    if (status == 'delivered') return kCrayolaGreen;
    if (status == 'cancelled') return kFireOpal;
    return kTinGrey;
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: kBackgroundBeige,
        appBar: AppBar(
          backgroundColor: kBackgroundBeige,
          title: const Text('Order Review', style: kMerriweatherBold16),
          centerTitle: true,
          elevation: 0,
          bottom: TabBar(
            labelColor: kOffBlack,
            labelStyle: kNunitoSansBold16,
            unselectedLabelColor: kTinGrey,
            unselectedLabelStyle: kNunitoSans14,
            indicator: BoxDecoration(
              color: kOffBlack,
              borderRadius: BorderRadius.circular(4),
            ),
            indicatorSize: TabBarIndicatorSize.label,
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
            _buildOrderList('pending'),
            _buildOrderList('processing'),
            _buildOrderList('delivered'),
            _buildOrderList('cancelled'),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderList(String statusFilter) {
    final orders = FirebaseFirestore.instance
        .collection('orders')
        .where('status', isEqualTo: statusFilter)
        .orderBy('createdAt', descending: true)
        .snapshots();

    return StreamBuilder<QuerySnapshot>(
      stream: orders,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final docs = snap.data?.docs ?? [];
        if (docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.receipt_long, size: 64, color: kTinGrey),
                const SizedBox(height: 16),
                Text('No ${statusFilter} orders', style: kNunitoSansTinGrey18),
              ],
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: docs.length,
          itemBuilder: (context, i) {
            final doc = docs[i];
            final data = doc.data() as Map<String, dynamic>;
            final status = (data['status'] ?? 'pending').toString();
            return Container(
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
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Order #${data['orderNumber'] ?? doc.id.substring(0, 6)}',
                          style: kNunitoSansSemiBold16,
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _statusColor(status),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            status.toUpperCase(),
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
                    Text('Customer: ${data['customerName'] ?? 'Unknown'}', style: kNunitoSans14),
                    Text('Amount: ฿${(data['totalAmount'] ?? 0).toString()}', style: kNunitoSansSemiBold16),
                    if (data['createdAt'] != null)
                      Text(
                        'Date: ${_formatDate(data['createdAt'])}',
                        style: kNunitoSans12Grey,
                      ),
                    const SizedBox(height: 12),
                    if (status == 'pending')
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () => doc.reference.update({'status': 'processing'}),
                              style: ElevatedButton.styleFrom(backgroundColor: kSeaGreen),
                              child: const Text('Approve', style: TextStyle(color: Colors.white)),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () => doc.reference.update({'status': 'cancelled'}),
                              style: ElevatedButton.styleFrom(backgroundColor: kFireOpal),
                              child: const Text('Reject', style: TextStyle(color: Colors.white)),
                            ),
                          ),
                        ],
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

  String _formatDate(dynamic timestamp) {
    if (timestamp == null) return 'Unknown';
    try {
      final date = timestamp.toDate();
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return 'Unknown';
    }
  }
}
