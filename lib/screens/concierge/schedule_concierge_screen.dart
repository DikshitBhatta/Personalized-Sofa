import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:timberr/constants.dart';

import 'package:timberr/controllers/address_controller.dart';
import 'package:timberr/screens/profile/shipping_address_screen.dart';
import 'package:timberr/screens/concierge/payment_screen.dart';

class ScheduleConciergeScreen extends StatefulWidget {
  const ScheduleConciergeScreen({super.key});

  @override
  State<ScheduleConciergeScreen> createState() => _ScheduleConciergeScreenState();
}

class _ScheduleConciergeScreenState extends State<ScheduleConciergeScreen> {
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  String? _selectedLocation;
  String _selectedContactPreference = 'Phone';
  
  final List<String> _contactPreferences = ['Phone', 'Email', 'Line', 'WhatsApp'];
  final AddressController _addressController = Get.find();
  final TextEditingController _contactController = TextEditingController();

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
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
      initialTime: const TimeOfDay(hour: 10, minute: 0),
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

  void _navigateToShippingAddress() {
    // Navigate to Shipping Address screen and read selected address from controller
    final future = Get.to(() => const ShippingAddressScreen(), transition: Transition.cupertino, duration: const Duration(milliseconds: 400));
    if (future != null) {
      future.then((_) {
        // After return, check selectedIndex in AddressController
        if (_addressController.addressList.isNotEmpty) {
          final addr = _addressController.addressList[_addressController.selectedIndex];
          setState(() {
            _selectedLocation = '${addr.address}, ${addr.city}, ${addr.pincode}';
          });
        } else {
          // No address selected/added
          setState(() {
            _selectedLocation = null;
          });
        }
      });
    }

  }

  @override
  void dispose() {
    _contactController.dispose();
    super.dispose();
  }
  bool _isFormValid() {
  final contactFilled = _contactController.text.trim().isNotEmpty;
  return _selectedDate != null && 
       _selectedTime != null && 
       _selectedLocation != null &&
       contactFilled;
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kLynxWhite,
      appBar: AppBar(
        backgroundColor: kLynxWhite,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(Icons.arrow_back_ios_new, color: kOffBlack, size: 20),
        ),
        centerTitle: true,
        title: Text(
          "SCHEDULE CONCIERGE",
          style: kMerriweatherBold16.copyWith(color: kOffBlack),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Concierge Introduction
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x10000000),
                    offset: Offset(0, 2),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: kSeaGreen.withOpacity(0.1),
                    child: Text(
                      "SJ",
                      style: kNunitoSansBold24.copyWith(color: kSeaGreen),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Sarah Johnson",
                    style: kNunitoSansSemiBold18.copyWith(color: kOffBlack),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Furniture Design Specialist",
                    style: kNunitoSans14.copyWith(color: kTinGrey),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: kSeaGreen.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star, size: 16, color: kSeaGreen),
                        const SizedBox(width: 4),
                        Text(
                          "4.9 • 127 visits",
                          style: kNunitoSans14.copyWith(
                            color: kSeaGreen,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Sarah will visit your location to help finalize your personalized sofa design and take precise measurements.",
                    textAlign: TextAlign.center,
                    style: kNunitoSans14.copyWith(color: kGrey),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Location Section
            Text(
              "Visit Location",
              style: kNunitoSansSemiBold18.copyWith(color: kOffBlack),
            ),
            const SizedBox(height: 4),
            Text(
              "Where should Sarah meet you?",
              style: kNunitoSans14.copyWith(color: kGrey),
            ),
            const SizedBox(height: 16),
            
            GestureDetector(
              onTap: _navigateToShippingAddress,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: kChristmasSilver),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      color: _selectedLocation != null ? kSeaGreen : kTinGrey,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _selectedLocation ?? "Select delivery location",
                            style: kNunitoSans14.copyWith(
                              color: _selectedLocation != null ? kOffBlack : kTinGrey,
                              fontWeight: _selectedLocation != null ? FontWeight.w600 : FontWeight.normal,
                            ),
                          ),
                          if (_selectedLocation == null)
                            Text(
                              "Use saved shipping address",
                              style: kNunitoSans14.copyWith(color: kGrey),
                            ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios, size: 16, color: kTinGrey),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Date & Time Section
            Text(
              "Preferred Date & Time",
              style: kNunitoSansSemiBold18.copyWith(color: kOffBlack),
            ),
            const SizedBox(height: 4),
            Text(
              "When would you like Sarah to visit?",
              style: kNunitoSans14.copyWith(color: kGrey),
            ),
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: _selectDate,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: kChristmasSilver),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.calendar_today_outlined,
                            color: _selectedDate != null ? kSeaGreen : kTinGrey,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _selectedDate != null
                                  ? "${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}"
                                  : "Select Date",
                              style: kNunitoSans14.copyWith(
                                color: _selectedDate != null ? kOffBlack : kTinGrey,
                                fontWeight: _selectedDate != null ? FontWeight.w600 : FontWeight.normal,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: _selectTime,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: kChristmasSilver),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.access_time_outlined,
                            color: _selectedTime != null ? kSeaGreen : kTinGrey,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _selectedTime != null
                                  ? _selectedTime!.format(context)
                                  : "Select Time",
                              style: kNunitoSans14.copyWith(
                                color: _selectedTime != null ? kOffBlack : kTinGrey,
                                fontWeight: _selectedTime != null ? FontWeight.w600 : FontWeight.normal,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 32),
            
            // Contact Preference Section
            Text(
              "Contact Preference",
              style: kNunitoSansSemiBold18.copyWith(color: kOffBlack),
            ),
            const SizedBox(height: 4),
            Text(
              "How should Sarah confirm the appointment?",
              style: kNunitoSans14.copyWith(color: kGrey),
            ),
            const SizedBox(height: 16),
            
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: _contactPreferences.map((preference) {
                final isSelected = _selectedContactPreference == preference;
                IconData icon;
                switch (preference) {
                  case 'Phone':
                    icon = Icons.phone_outlined;
                    break;
                  case 'Email':
                    icon = Icons.email_outlined;
                    break;
                  case 'Line':
                    icon = Icons.chat_outlined;
                    break;
                  case 'WhatsApp':
                    icon = Icons.message_outlined;
                    break;
                  default:
                    icon = Icons.contact_phone_outlined;
                }
                
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedContactPreference = preference;
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    decoration: BoxDecoration(
                      color: isSelected ? kOffBlack : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? kOffBlack : kChristmasSilver,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          icon,
                          color: isSelected ? Colors.white : kTinGrey,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          preference,
                          style: kNunitoSans14.copyWith(
                            color: isSelected ? Colors.white : kOffBlack,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            
            const SizedBox(height: 16),

            // Conditional contact input field
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: Column(
                key: ValueKey(_selectedContactPreference),
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _selectedContactPreference == 'Phone' ? 'Phone number' :
                    _selectedContactPreference == 'Email' ? 'Email address' :
                    _selectedContactPreference == 'Line' ? 'Line ID' : 'WhatsApp number',
                    style: kNunitoSans14.copyWith(color: kOffBlack),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    key: ValueKey('contact_input_$_selectedContactPreference'),
                    controller: _contactController,
                    keyboardType: _selectedContactPreference == 'Email'
                        ? TextInputType.emailAddress
                        : TextInputType.phone,
                    decoration: InputDecoration(
                      hintText: _selectedContactPreference == 'Email' ? 'you@example.com' : 'Enter contact',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: kChristmasSilver)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),
            
            // Schedule Button
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    // onPressed: _isFormValid()
                    //     ? () {
                    //         // Navigate to payment screen with current summary
                    //         Get.to(() => const ConciergePaymentScreen(), transition: Transition.cupertino);
                    //       }
                    //     : null,
                    onPressed: () {
                      Get.to(() => const ConciergePaymentScreen(), transition: Transition.cupertino);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isFormValid() ? kOffBlack : kGrey,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(
                      "Proceed to Payment",
                      style: kNunitoSans16.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
