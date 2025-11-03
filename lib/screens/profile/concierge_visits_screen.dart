import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:timberr/constants.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:timberr/screens/concierge/concierge_booking_detail_screen.dart';

class ConciergeVisitsScreen extends StatefulWidget {
  const ConciergeVisitsScreen({Key? key}) : super(key: key);

  @override
  State<ConciergeVisitsScreen> createState() => _ConciergeVisitsScreenState();
}

class _ConciergeVisitsScreenState extends State<ConciergeVisitsScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final currentUser = FirebaseAuth.instance.currentUser;

  Color _getStatusColor(String status) {
    switch (status) {
      case 'confirmed':
        return kSeaGreen;
      case 'rejected':
      case 'cancelled':
        return kFireOpal;
      default:
        return kOffBlack;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'confirmed':
        return Icons.check_circle;
      case 'rejected':
      case 'cancelled':
        return Icons.cancel;
      default:
        return Icons.schedule;
    }
  }

  void _viewBookingDetails(Map<String, dynamic> booking, String bookingId) {
    Get.to(
      () => ConciergeBookingDetailScreen(bookingId: bookingId),
      transition: Transition.cupertino,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (currentUser == null) {
      return Scaffold(
        backgroundColor: kBackgroundBeige,
        appBar: AppBar(
          backgroundColor: kBackgroundBeige,
          title: const Text('CONCIERGE VISITS', style: kMerriweatherBold16),
          centerTitle: true,
          elevation: 0,
        ),
        body: const Center(child: Text('Please sign in to view your visits')),
      );
    }

    return Scaffold(
      backgroundColor: kBackgroundBeige,
      appBar: AppBar(
        backgroundColor: kBackgroundBeige,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(Icons.arrow_back_ios_new, color: kOffBlack, size: 20),
        ),
        centerTitle: true,
        title: const Text('CONCIERGE VISITS', style: kMerriweatherBold16),
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('concierge_bookings')
            .where('client_id', isEqualTo: currentUser!.uid)
            .orderBy('created_at', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.event_busy, size: 80, color: kGrey.withOpacity(0.5)),
                  const SizedBox(height: 16),
                  Text(
                    'No Concierge Visits Yet',
                    style: kNunitoSansSemiBold18.copyWith(color: kGrey),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Schedule your first consultation',
                    style: kNunitoSans14.copyWith(color: kTinGrey),
                  ),
                ],
              ),
            );
          }

          final bookings = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: bookings.length,
            itemBuilder: (context, index) {
              final doc = bookings[index];
              final booking = doc.data() as Map<String, dynamic>;
              final bookingId = doc.id;
              final status = booking['status'] ?? 'pending';
              final conciergeName = booking['concierge_name'] ?? 'Concierge';
              final visitDate = booking['visit_date'] ?? '';
              final visitTime = booking['visit_time'] ?? '';
              final createdAt = (booking['created_at'] as Timestamp?)?.toDate() ?? DateTime.now();

              return GestureDetector(
                onTap: () => _viewBookingDetails(booking, bookingId),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _getStatusColor(status).withOpacity(0.3),
                      width: 1,
                    ),
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
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: _getStatusColor(status).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    Icons.support_agent,
                                    color: _getStatusColor(status),
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        conciergeName,
                                        style: kNunitoSansSemiBold18.copyWith(
                                          fontSize: 16,
                                          color: kOffBlack,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        timeago.format(createdAt),
                                        style: kNunitoSans14.copyWith(
                                          color: kTinGrey,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: _getStatusColor(status),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _getStatusIcon(status),
                                  color: Colors.white,
                                  size: 14,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  status.toUpperCase(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Divider(height: 1, color: kChristmasSilver),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(Icons.calendar_today, size: 16, color: kTinGrey),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              visitDate.isNotEmpty ? '$visitDate ${visitTime.isNotEmpty ? '• $visitTime' : ''}' : 'Date not set',
                              style: kNunitoSans14.copyWith(color: kOffBlack),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      if (booking['visit_address'] != null) ...[
                        const SizedBox(height: 8),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.location_on, size: 16, color: kTinGrey),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                booking['visit_address'],
                                style: kNunitoSans14.copyWith(color: kTinGrey),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            'Tap to view details',
                            style: kNunitoSans14.copyWith(
                              color: kSeaGreen,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(Icons.arrow_forward_ios, size: 12, color: kSeaGreen),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}