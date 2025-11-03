import 'package:flutter/material.dart';
import 'package:timberr/constants.dart';

class ConciergeAppointmentDetailScreen extends StatelessWidget {
  final Map<String, dynamic> appointmentData;

  const ConciergeAppointmentDetailScreen({
    Key? key,
    required this.appointmentData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundBeige,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: kOffBlack),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Concierge Appointment",
          style: kNunitoSansSemiBold18.copyWith(color: kOffBlack),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
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
                  if (appointmentData['concierge_photo_url'] != null)
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
                          appointmentData['concierge_photo_url'],
                        ),
                        backgroundColor: Colors.white,
                        onBackgroundImageError: (exception, stackTrace) {
                          // Fallback to default
                        },
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
                    appointmentData['concierge_name'] ?? "Concierge",
                    style: kNunitoSansSemiBold18.copyWith(
                      fontSize: 20,
                      color: kOffBlack,
                    ),
                  ),
                  const SizedBox(height: 6),
                  
                  // Concierge Specialty
                  if (appointmentData['concierge_specialty'] != null)
                    Text(
                      appointmentData['concierge_specialty'],
                      style: kNunitoSans14.copyWith(
                        color: kTinGrey,
                        letterSpacing: 0.3,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  const SizedBox(height: 12),
                  
                  // Rating and Visits
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (appointmentData['concierge_rating'] != null) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: kSeaGreen.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.star_rounded,
                                color: kSeaGreen,
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                "${appointmentData['concierge_rating']} Rating",
                                style: kNunitoSans14.copyWith(
                                  color: kSeaGreen,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      if (appointmentData['concierge_visits'] != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: kOffBlack.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.verified_rounded,
                                color: kOffBlack,
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                "${appointmentData['concierge_visits']} Visits",
                                style: kNunitoSans14.copyWith(
                                  color: kOffBlack,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  
                  // Contact Information
                  if (appointmentData['concierge_phone'] != null ||
                      appointmentData['concierge_email'] != null) ...[
                    const SizedBox(height: 20),
                    const Divider(color: kChristmasSilver),
                    const SizedBox(height: 16),
                    if (appointmentData['concierge_phone'] != null)
                      _buildContactRow(
                        icon: Icons.phone_rounded,
                        label: "Phone",
                        value: appointmentData['concierge_phone'],
                      ),
                    if (appointmentData['concierge_phone'] != null &&
                        appointmentData['concierge_email'] != null)
                      const SizedBox(height: 12),
                    if (appointmentData['concierge_email'] != null)
                      _buildContactRow(
                        icon: Icons.email_rounded,
                        label: "Email",
                        value: appointmentData['concierge_email'],
                      ),
                  ],
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
            if (appointmentData['date'] != null || appointmentData['time'] != null)
              _buildDetailCard(
                icon: Icons.calendar_today_rounded,
                iconColor: kSeaGreen,
                title: "Date & Time",
                details: [
                  if (appointmentData['date'] != null)
                    appointmentData['date'],
                  if (appointmentData['time'] != null)
                    appointmentData['time'],
                ],
              ),

            // Location
            if (appointmentData['location'] != null)
              _buildDetailCard(
                icon: Icons.location_on_rounded,
                iconColor: Colors.red,
                title: "Visit Location",
                details: [appointmentData['location']],
              ),

            // Contact Preference
            if (appointmentData['contact_preference'] != null)
              _buildDetailCard(
                icon: Icons.chat_bubble_outline_rounded,
                iconColor: Colors.blue,
                title: "Preferred Contact",
                details: [appointmentData['contact_preference']],
              ),

            // Additional Notes
            if (appointmentData['notes'] != null &&
                appointmentData['notes'].toString().isNotEmpty)
              Container(
                width: double.infinity,
                margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.shade100),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.notes_rounded,
                          color: Colors.blue.shade700,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "Additional Notes",
                          style: kNunitoSansSemiBold18.copyWith(
                            fontSize: 15,
                            color: Colors.blue.shade900,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      appointmentData['notes'],
                      style: kNunitoSans14.copyWith(
                        color: Colors.blue.shade800,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildContactRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, color: kTinGrey, size: 18),
        const SizedBox(width: 8),
        Text(
          "$label: ",
          style: kNunitoSans14.copyWith(
            color: kTinGrey,
            fontWeight: FontWeight.w600,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: kNunitoSans14.copyWith(color: kOffBlack),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
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
