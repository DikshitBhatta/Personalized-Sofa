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

  void _navigateToShippingAddress() async {
    // Navigate to Shipping Address screen in selection mode
    final selectedIndex = await Get.to<int>(
      () => const ShippingAddressScreen(isSelectionMode: true),
      transition: Transition.cupertino,
      duration: const Duration(milliseconds: 400),
    );
    
    // If an address was selected (not null)
    if (selectedIndex != null && _addressController.addressList.isNotEmpty) {
      final addr = _addressController.addressList[selectedIndex];
      setState(() {
        _selectedLocation = '${addr.address}, ${addr.city}, ${addr.pincode}';
      });
      print('✅ Selected visit location: $_selectedLocation');
    } else {
      print('❌ No address selected');
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

  Widget _buildInfoChip({
    required IconData icon,
    required String text,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            text,
            style: kNunitoSans14.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader({
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: kSeaGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 20, color: kSeaGreen),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: kNunitoSansSemiBold18.copyWith(
                    color: kOffBlack,
                    fontSize: 17,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: kNunitoSans14.copyWith(
                    color: kGrey,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
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
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: kSeaGreen.withOpacity(0.1),
                    offset: const Offset(0, 2),
                    blurRadius: 8,
                  ),
                ]
              : null,
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
          "SCHEDULE CONCIERGE",
          style: kMerriweatherBold16.copyWith(color: kOffBlack),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Professional Header
            Text(
              "Book Your Design Consultation",
              style: kMerriweatherBold16.copyWith(
                color: kOffBlack,
                fontSize: 20,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Schedule a visit with our expert furniture designer to bring your vision to life",
              style: kNunitoSans14.copyWith(
                color: kGrey,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            
            // Concierge Introduction - More Professional
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: kChristmasSilver.withOpacity(0.3)),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x08000000),
                    offset: Offset(0, 4),
                    blurRadius: 16,
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: kSeaGreen.withOpacity(0.2), width: 3),
                    ),
                    child: const CircleAvatar(
                      radius: 50,
                      backgroundImage: AssetImage('assets/SJ.jpeg'),
                      backgroundColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "Sarah Johnson",
                    style: kNunitoSansSemiBold18.copyWith(
                      color: kOffBlack,
                      fontSize: 20,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "Senior Furniture Design Specialist",
                    style: kNunitoSans14.copyWith(
                      color: kTinGrey,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: _buildInfoChip(
                          icon: Icons.star_rounded,
                          text: "4.9 Rating",
                          color: kSeaGreen,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: _buildInfoChip(
                          icon: Icons.verified_rounded,
                          text: "127 Visits",
                          color: kOffBlack,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: kBackgroundBeige,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.lightbulb_outline_rounded,
                          color: kSeaGreen,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            "Expert in custom sofa design, measurements, and material selection",
                            style: kNunitoSans14.copyWith(
                              color: kOffBlack,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Location Section
            _buildSectionHeader(
              title: "Visit Location",
              subtitle: "Where should Sarah meet you?",
              icon: Icons.location_on_rounded,
            ),
            const SizedBox(height: 16),
            
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
                  boxShadow: _selectedLocation != null
                      ? [
                          BoxShadow(
                            color: kSeaGreen.withOpacity(0.1),
                            offset: const Offset(0, 2),
                            blurRadius: 8,
                          ),
                        ]
                      : null,
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
            
            const SizedBox(height: 32),
            
            // Date & Time Section
            _buildSectionHeader(
              title: "Preferred Date & Time",
              subtitle: "When would you like Sarah to visit?",
              icon: Icons.calendar_today_rounded,
            ),
            const SizedBox(height: 16),
            
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
            
            const SizedBox(height: 32),
            
            // Contact Preference Section
            _buildSectionHeader(
              title: "Contact Preference",
              subtitle: "How should we confirm your appointment?",
              icon: Icons.contact_phone_rounded,
            ),
            const SizedBox(height: 16),
            
            Row(
              children: _contactPreferences.map((preference) {
                final isSelected = _selectedContactPreference == preference;
                IconData icon;
                switch (preference) {
                  case 'Phone':
                    icon = Icons.phone_rounded;
                    break;
                  case 'Email':
                    icon = Icons.email_rounded;
                    break;
                  case 'Line':
                    icon = Icons.chat_bubble_rounded;
                    break;
                  case 'WhatsApp':
                    icon = Icons.message_rounded;
                    break;
                  default:
                    icon = Icons.contact_phone_rounded;
                }
                
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedContactPreference = preference;
                          _contactController.clear();
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: isSelected ? kOffBlack : Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isSelected ? kOffBlack : kChristmasSilver,
                            width: isSelected ? 1.5 : 1,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: kOffBlack.withOpacity(0.15),
                                    offset: const Offset(0, 2),
                                    blurRadius: 8,
                                  ),
                                ]
                              : null,
                        ),
                        child: Column(
                          children: [
                            Icon(
                              icon,
                              color: isSelected ? Colors.white : kTinGrey,
                              size: 22,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              preference,
                              style: kNunitoSans14.copyWith(
                                color: isSelected ? Colors.white : kOffBlack,
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            
            const SizedBox(height: 16),

            // Conditional contact input field
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: Container(
                key: ValueKey(_selectedContactPreference),
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: kChristmasSilver),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _selectedContactPreference == 'Phone' ? 'Phone Number' :
                      _selectedContactPreference == 'Email' ? 'Email Address' :
                      _selectedContactPreference == 'Line' ? 'Line ID' : 'WhatsApp Number',
                      style: kNunitoSans14.copyWith(
                        color: kOffBlack,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      key: ValueKey('contact_input_$_selectedContactPreference'),
                      controller: _contactController,
                      keyboardType: _selectedContactPreference == 'Email'
                          ? TextInputType.emailAddress
                          : TextInputType.phone,
                      style: kNunitoSans14.copyWith(color: kOffBlack),
                      decoration: InputDecoration(
                        hintText: _selectedContactPreference == 'Email' 
                            ? 'you@example.com' 
                            : _selectedContactPreference == 'Phone'
                                ? '+1 (555) 000-0000'
                                : 'Enter your ${_selectedContactPreference.toLowerCase()}',
                        hintStyle: kNunitoSans14.copyWith(color: kGrey),
                        filled: true,
                        fillColor: kBackgroundBeige,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: kSeaGreen, width: 1.5),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        prefixIcon: Icon(
                          _selectedContactPreference == 'Email'
                              ? Icons.email_outlined
                              : Icons.phone_outlined,
                          color: kTinGrey,
                          size: 20,
                        ),
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 40),
            
            // Important Note
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: kSeaGreen.withOpacity(0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: kSeaGreen.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    color: kSeaGreen,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "You'll receive a confirmation within 2 hours of booking",
                      style: kNunitoSans14.copyWith(
                        color: kOffBlack,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Schedule Button
            SizedBox(
              width: double.infinity,
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
                  backgroundColor: _isFormValid() ? kOffBlack : kGrey.withOpacity(0.5),
                  elevation: _isFormValid() ? 2 : 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 18),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Proceed to Payment",
                      style: kNunitoSans16.copyWith(
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.arrow_forward_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
