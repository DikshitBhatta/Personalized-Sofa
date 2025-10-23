import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:timberr/constants.dart';
import 'package:timberr/Notification/controllers/notification_controller.dart';
import 'package:timeago/timeago.dart' as timeago;

class ConciergeBookingManagement extends StatefulWidget {
  const ConciergeBookingManagement({super.key});

  @override
  State<ConciergeBookingManagement> createState() => _ConciergeBookingManagementState();
}

class _ConciergeBookingManagementState extends State<ConciergeBookingManagement> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final NotificationController _notificationController = Get.put(NotificationController());
  
  String _selectedFilter = 'all'; // all, pending, confirmed, rejected

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundBeige,
      appBar: AppBar(
        backgroundColor: kBackgroundBeige,
        title: const Text('Concierge Bookings', style: kMerriweatherBold16),
        centerTitle: true,
        elevation: 0,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            onSelected: (value) {
              setState(() {
                _selectedFilter = value;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'all', child: Text('All Bookings')),
              const PopupMenuItem(value: 'pending', child: Text('Pending')),
              const PopupMenuItem(value: 'confirmed', child: Text('Confirmed')),
              const PopupMenuItem(value: 'rejected', child: Text('Rejected')),
            ],
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: StreamBuilder<QuerySnapshot>(
          stream: _getBookingsStream(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.event_busy, size: 64, color: kGrey),
                    const SizedBox(height: 16),
                    Text(
                      'No concierge bookings found',
                      style: kNunitoSansSemiBold16.copyWith(color: kGrey),
                    ),
                  ],
                ),
              );
            }
            
            final bookings = snapshot.data!.docs;
            
            return ListView.builder(
              itemCount: bookings.length,
              itemBuilder: (context, index) {
                final booking = bookings[index];
                final data = booking.data() as Map<String, dynamic>;
                
                return _BookingCard(
                  bookingId: booking.id,
                  data: data,
                  onStatusChange: _handleStatusChange,
                );
              },
            );
          },
        ),
      ),
    );
  }
  
  Stream<QuerySnapshot> _getBookingsStream() {
    Query query = _firestore.collection('concierge_bookings')
        .orderBy('created_at', descending: true);
    
    if (_selectedFilter != 'all') {
      query = query.where('status', isEqualTo: _selectedFilter);
    }
    
    return query.snapshots();
  }
  
  Future<void> _handleStatusChange(String bookingId, String newStatus, Map<String, dynamic> bookingData) async {
    try {
      // Update booking status
      await _firestore.collection('concierge_bookings')
          .doc(bookingId)
          .update({
        'status': newStatus,
        'updated_at': FieldValue.serverTimestamp(),
      });
      
      // Send notification to user
      final clientId = bookingData['client_id'] as String;
      final conciergeName = bookingData['concierge_name'] as String;
      final visitDate = bookingData['visit_date'] as String;
      final visitTime = bookingData['visit_time'] as String;
      
      if (newStatus == 'confirmed') {
        await _notificationController.sendConciergeConfirmationNotification(
          userId: clientId,
          conciergeName: conciergeName,
          visitDate: visitDate,
          visitTime: visitTime,
        );
        
        Get.snackbar(
          'Booking Confirmed',
          'Client has been notified of the confirmation',
          backgroundColor: kSeaGreen,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
        
      } else if (newStatus == 'rejected') {
        await _notificationController.sendConciergeRejectionNotification(
          userId: clientId,
          conciergeName: conciergeName,
          visitDate: visitDate,
          visitTime: visitTime,
          reason: 'Please contact support to reschedule',
        );
        
        Get.snackbar(
          'Booking Rejected',
          'Client has been notified to reschedule',
          backgroundColor: kFireOpal,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
      
    } catch (e) {
      print('❌ Error updating booking status: $e');
      Get.snackbar(
        'Error',
        'Failed to update booking status',
        backgroundColor: kFireOpal,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}

class _BookingCard extends StatelessWidget {
  final String bookingId;
  final Map<String, dynamic> data;
  final Function(String, String, Map<String, dynamic>) onStatusChange;
  
  const _BookingCard({
    required this.bookingId,
    required this.data,
    required this.onStatusChange,
  });
  
  @override
  Widget build(BuildContext context) {
    final status = data['status'] ?? 'pending';
    final clientName = data['client_name'] ?? 'Unknown Client';
    final conciergeName = data['concierge_name'] ?? 'Unknown Concierge';
    final visitDate = data['visit_date'] ?? '';
    final visitTime = data['visit_time'] ?? '';
    final amount = (data['amount'] ?? 0.0) as double;
    final createdAt = (data['created_at'] as Timestamp?)?.toDate() ?? DateTime.now();
    
    Color statusColor;
    IconData statusIcon;
    
    switch (status) {
      case 'confirmed':
        statusColor = kSeaGreen;
        statusIcon = Icons.check_circle;
        break;
      case 'rejected':
        statusColor = kFireOpal;
        statusIcon = Icons.cancel;
        break;
      default:
        statusColor = kGrey;
        statusIcon = Icons.pending;
    }
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    clientName,
                    style: kNunitoSansSemiBold16.copyWith(color: kOffBlack),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(statusIcon, size: 16, color: statusColor),
                      const SizedBox(width: 4),
                      Text(
                        status.toUpperCase(),
                        style: kNunitoSans12Grey.copyWith(
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Booking details
            _DetailRow(icon: Icons.person, label: 'Concierge', value: conciergeName),
            _DetailRow(icon: Icons.calendar_today, label: 'Date', value: visitDate),
            _DetailRow(icon: Icons.access_time, label: 'Time', value: visitTime),
            _DetailRow(icon: Icons.attach_money, label: 'Amount', value: '฿${amount.toStringAsFixed(2)}'),
            _DetailRow(icon: Icons.schedule, label: 'Requested', value: timeago.format(createdAt)),
            
            if (status == 'pending') ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
              
              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => onStatusChange(bookingId, 'confirmed', data),
                      icon: const Icon(Icons.check, size: 18),
                      label: const Text('Confirm'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kSeaGreen,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => onStatusChange(bookingId, 'rejected', data),
                      icon: const Icon(Icons.close, size: 18),
                      label: const Text('Reject'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kFireOpal,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });
  
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: kTinGrey),
          const SizedBox(width: 8),
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: kNunitoSans12Grey.copyWith(color: kTinGrey),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: kNunitoSans14.copyWith(color: kOffBlack),
            ),
          ),
        ],
      ),
    );
  }
}