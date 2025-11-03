import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:timberr/constants.dart';
import 'package:timberr/screens/profile/edit_concierge_booking_screen.dart';
import 'package:timeago/timeago.dart' as timeago;

class ConciergeBookingDetailScreen extends StatefulWidget {
  final String bookingId;

  const ConciergeBookingDetailScreen({
    Key? key,
    required this.bookingId,
  }) : super(key: key);

  @override
  State<ConciergeBookingDetailScreen> createState() =>
      _ConciergeBookingDetailScreenState();
}

class _ConciergeBookingDetailScreenState
    extends State<ConciergeBookingDetailScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: kOffBlack, size: 20),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Concierge Booking',
          style: kNunitoSansSemiBold18.copyWith(
            color: kOffBlack,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('concierge_bookings')
            .doc(widget.bookingId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: kSeaGreen),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 64,
                    color: kFireOpal,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading booking',
                    style: kNunitoSansSemiBold18.copyWith(
                      color: kOffBlack,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    snapshot.error.toString(),
                    style: kNunitoSans14.copyWith(color: kTinGrey),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 64,
                    color: kTinGrey,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Booking not found',
                    style: kNunitoSansSemiBold18.copyWith(
                      color: kOffBlack,
                    ),
                  ),
                ],
              ),
            );
          }

          final booking = {
            'id': snapshot.data!.id,
            ...snapshot.data!.data() as Map<String, dynamic>,
          };

          return _buildBookingDetails(booking);
        },
      ),
    );
  }

  Widget _buildBookingDetails(Map<String, dynamic> booking) {
    return RefreshIndicator(
      onRefresh: () async {
        // StreamBuilder will automatically refresh
        await Future.delayed(const Duration(milliseconds: 500));
      },
      color: kSeaGreen,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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

                  // Created timestamp
                  if (booking['created_at'] != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      'Booked ${timeago.format((booking['created_at'] as Timestamp).toDate())}',
                      style: kNunitoSans14.copyWith(
                        color: kTinGrey,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 24),

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
                      // StreamBuilder will automatically update after edit
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

            // Additional Notes if any
            if (booking['notes'] != null &&
                booking['notes'].toString().isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  "ADDITIONAL NOTES",
                  style: kNunitoSansSemiBold18.copyWith(
                    fontSize: 16,
                    color: kOffBlack,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(horizontal: 16),
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
                child: Text(
                  booking['notes'],
                  style: kNunitoSans14.copyWith(
                    color: kOffBlack,
                    height: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ],
        ),
      ),
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
