import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:timberr/constants.dart';
import 'package:timberr/controllers/address_controller.dart';
import 'package:timberr/screens/profile/shipping_address_screen.dart';

class EditConciergeBookingScreen extends StatefulWidget {
  final String bookingId;
  final Map<String, dynamic> booking;

  const EditConciergeBookingScreen({
    Key? key,
    required this.bookingId,
    required this.booking,
  }) : super(key: key);

  @override
  State<EditConciergeBookingScreen> createState() => _EditConciergeBookingScreenState();
}

class _EditConciergeBookingScreenState extends State<EditConciergeBookingScreen> {
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  String? _selectedLocation;
  bool _isUpdating = false;

  final AddressController _addressController = Get.find();

  @override
  void initState() {
    super.initState();
    _loadExistingData();
  }

  void _loadExistingData() {
    // Parse existing date
    final visitDate = widget.booking['visit_date'] as String?;
    if (visitDate != null && visitDate.isNotEmpty) {
      try {
        // Try to parse the date string - you may need to adjust format
        // Assuming format like "1 Nov 2025" or similar
        final parts = visitDate.split(' ');
        if (parts.length >= 3) {
          final day = int.tryParse(parts[0]);
          final monthStr = parts[1];
          final year = int.tryParse(parts[2]);
          
          if (day != null && year != null) {
            final monthMap = {
              'Jan': 1, 'Feb': 2, 'Mar': 3, 'Apr': 4,
              'May': 5, 'Jun': 6, 'Jul': 7, 'Aug': 8,
              'Sep': 9, 'Oct': 10, 'Nov': 11, 'Dec': 12,
            };
            final month = monthMap[monthStr];
            if (month != null) {
              _selectedDate = DateTime(year, month, day);
            }
          }
        }
      } catch (e) {
        print('Error parsing date: $e');
      }
    }

    // Parse existing time
    final visitTime = widget.booking['visit_time'] as String?;
    if (visitTime != null && visitTime.isNotEmpty) {
      try {
        // Assuming format like "10:30" or "14:00"
        final parts = visitTime.split(':');
        if (parts.length == 2) {
          final hour = int.tryParse(parts[0]);
          final minute = int.tryParse(parts[1]);
          if (hour != null && minute != null) {
            _selectedTime = TimeOfDay(hour: hour, minute: minute);
          }
        }
      } catch (e) {
        print('Error parsing time: $e');
      }
    }

    // Load existing location
    _selectedLocation = widget.booking['visit_address'] as String?;
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: kOffBlack,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: kOffBlack,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? const TimeOfDay(hour: 10, minute: 0),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: kOffBlack,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: kOffBlack,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  void _navigateToShippingAddress() async {
    final selectedIndex = await Get.to<int>(
      () => const ShippingAddressScreen(isSelectionMode: true),
      transition: Transition.cupertino,
    );
    
    if (selectedIndex != null && _addressController.addressList.isNotEmpty) {
      final addr = _addressController.addressList[selectedIndex];
      setState(() {
        _selectedLocation = '${addr.address}, ${addr.city}, ${addr.pincode}';
      });
    }
  }

  String _formatDate(DateTime date) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  String _formatTime(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _updateBooking() async {
    if (_selectedDate == null || _selectedTime == null || _selectedLocation == null) {
      Get.snackbar(
        'Incomplete',
        'Please select date, time, and location',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: kFireOpal,
        colorText: Colors.white,
      );
      return;
    }

    setState(() => _isUpdating = true);

    try {
      await FirebaseFirestore.instance
          .collection('concierge_bookings')
          .doc(widget.bookingId)
          .update({
        'visit_date': _formatDate(_selectedDate!),
        'visit_time': _formatTime(_selectedTime!),
        'visit_address': _selectedLocation,
        'updated_at': FieldValue.serverTimestamp(),
      });

      Get.back(); // Close screen
      Get.snackbar(
        'Updated',
        'Concierge appointment updated successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: kSeaGreen,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update appointment: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: kFireOpal,
        colorText: Colors.white,
      );
    } finally {
      setState(() => _isUpdating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundBeige,
      appBar: AppBar(
        backgroundColor: kBackgroundBeige,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(Icons.arrow_back_ios_new, color: kOffBlack, size: 20),
        ),
        centerTitle: true,
        title: Text(
          "UPDATE APPOINTMENT",
          style: kMerriweatherBold16.copyWith(color: kOffBlack),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Info Banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade100),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue.shade700, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'You can update your appointment date, time, and location here',
                      style: kNunitoSans14.copyWith(
                        color: Colors.blue.shade900,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Concierge Info (Read-only)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: kChristmasSilver),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: kSeaGreen.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.support_agent, color: kSeaGreen, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Concierge',
                          style: kNunitoSans14.copyWith(color: kTinGrey, fontSize: 12),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.booking['concierge_name'] ?? 'Not assigned',
                          style: kNunitoSansSemiBold18.copyWith(
                            fontSize: 16,
                            color: kOffBlack,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Date & Time Selection
            Text(
              'Select New Date & Time',
              style: kNunitoSansSemiBold18.copyWith(color: kOffBlack),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildDateTimeSelector(
                    icon: Icons.calendar_month_rounded,
                    label: "Date",
                    value: _selectedDate != null
                        ? "${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}"
                        : "Select Date",
                    isSelected: _selectedDate != null,
                    onTap: _selectDate,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildDateTimeSelector(
                    icon: Icons.access_time_rounded,
                    label: "Time",
                    value: _selectedTime != null
                        ? _selectedTime!.format(context)
                        : "Select Time",
                    isSelected: _selectedTime != null,
                    onTap: _selectTime,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Location Selection
            Text(
              'Update Visit Location',
              style: kNunitoSansSemiBold18.copyWith(color: kOffBlack),
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: _navigateToShippingAddress,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _selectedLocation != null ? kSeaGreen : kChristmasSilver,
                    width: _selectedLocation != null ? 1.5 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: _selectedLocation != null 
                            ? kSeaGreen.withOpacity(0.1) 
                            : kBackgroundBeige,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.location_on_rounded,
                        color: _selectedLocation != null ? kSeaGreen : kTinGrey,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _selectedLocation ?? "Select visit location",
                            style: kNunitoSans14.copyWith(
                              color: _selectedLocation != null ? kOffBlack : kTinGrey,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (_selectedLocation == null)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                "Choose from saved addresses",
                                style: kNunitoSans14.copyWith(
                                  color: kGrey,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 16,
                      color: kTinGrey,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),

            // Update Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isUpdating ? null : _updateBooking,
                style: ElevatedButton.styleFrom(
                  backgroundColor: kOffBlack,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 18),
                ),
                child: _isUpdating
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        "Update Appointment",
                        style: kNunitoSans16.copyWith(
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildDateTimeSelector({
    required IconData icon,
    required String label,
    required String value,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? kSeaGreen : kChristmasSilver,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              color: isSelected ? kSeaGreen : kTinGrey,
              size: 22,
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: kNunitoSans14.copyWith(
                color: kGrey,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: kNunitoSans14.copyWith(
                color: isSelected ? kOffBlack : kTinGrey,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
