import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:timberr/constants.dart';
import 'package:timberr/screens/home.dart';
import 'package:timberr/Notification/controllers/notification_controller.dart';
import 'package:timberr/services/order_service.dart';
import 'package:timberr/controllers/personalization_controller.dart';
import 'package:timberr/presentation/controllers/sofa_generation_controller.dart';
import 'package:timberr/services/sofa_price_calculator.dart';
import 'package:timberr/models/user_onboarding_data.dart';
import 'package:timberr/controllers/address_controller.dart';

class ConciergePaymentScreen extends StatefulWidget {
  final String? conciergeName;
  final String? conciergeSpecialty;
  final String? conciergePhotoUrl;
  final double? conciergeRating;
  final int? conciergeVisits;
  final String? conciergePhone;
  final String? conciergeEmail;
  final DateTime? selectedDate;
  final TimeOfDay? selectedTime;
  final String? selectedLocation;
  final String? contactPreference;
  final String? contactValue; // The actual phone/email/line/whatsapp value

  const ConciergePaymentScreen({
    super.key,
    this.conciergeName,
    this.conciergeSpecialty,
    this.conciergePhotoUrl,
    this.conciergeRating,
    this.conciergeVisits,
    this.conciergePhone,
    this.conciergeEmail,
    this.selectedDate,
    this.selectedTime,
    this.selectedLocation,
    this.contactPreference,
    this.contactValue,
  });

  @override
  State<ConciergePaymentScreen> createState() => _ConciergePaymentScreenState();
}

class _ConciergePaymentScreenState extends State<ConciergePaymentScreen> {
  bool showSpinner = false;

  // Payment state
  String paymentMethod = 'qr'; // 'qr' | 'line'
  bool showQRCode = true;
  File? paymentScreenshot;
  bool screenshotUploaded = false;
  
  @override
  void initState() {
    super.initState();
    // Initialize notification controller
    Get.put(NotificationController());
  }

  // Booking summary - use passed data or fallback
  String get clientName {
    final currentUser = FirebaseAuth.instance.currentUser;
    return currentUser?.displayName ?? 'Ms. A. Client';
  }
  
  String get conciergeName => widget.conciergeName ?? 'P. Somchai';
  String get visitAddress => widget.selectedLocation ?? '88 Wireless Rd, Lumphini, Pathum Wan, Bangkok';
  
  String get visitSlot {
    if (widget.selectedDate != null && widget.selectedTime != null) {
      final date = widget.selectedDate!;
      final time = widget.selectedTime!;
      final formattedDate = '${_getWeekday(date.weekday)}, ${date.day} ${_getMonth(date.month)} ${date.year}';
      final formattedTime = '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
      return '$formattedDate — $formattedTime';
    }
    return 'Tue, 24 Sep 2025 — 10:30–11:30';
  }
  
  String get contact => widget.contactPreference ?? '+66 8x xxx xxxx';
  final double retainerAmount = 5000.00; // ฿5,000 concierge retainer
  final String transactionId = 'SOFA-${DateTime.now().millisecondsSinceEpoch}';

  String _getWeekday(int weekday) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[weekday - 1];
  }

  String _getMonth(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
  }

  // Compress image if size > 1MB
  Future<File> _compressImage(File file) async {
    print('🗜️ Compressing image...');
    
    // Get file size
    final fileSize = await file.length();
    print('📏 Original file size: ${(fileSize / 1024 / 1024).toStringAsFixed(2)} MB');
    
    // If file is less than 1MB, return as is
    if (fileSize < 1024 * 1024) {
      print('✅ File is already < 1MB, no compression needed');
      return file;
    }
    
    // Compress the image
    final targetPath = file.path.replaceAll('.jpg', '_compressed.jpg')
                                .replaceAll('.png', '_compressed.jpg')
                                .replaceAll('.jpeg', '_compressed.jpg');
    
    final result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      targetPath,
      quality: 70, // Lower quality for smaller size
      minWidth: 1024,
      minHeight: 1024,
    );
    
    if (result == null) {
      print('⚠️ Compression failed, using original file');
      return file;
    }
    
    final compressedFile = File(result.path);
    final compressedSize = await compressedFile.length();
    print('✅ Compressed file size: ${(compressedSize / 1024 / 1024).toStringAsFixed(2)} MB');
    
    return compressedFile;
  }

  Future<void> _pickPaymentScreenshot() async {
    final picker = ImagePicker();
    try {
      final XFile? image =
          await picker.pickImage(source: ImageSource.gallery, maxWidth: 1200, imageQuality: 85);
      if (image != null) {
        setState(() {
          paymentScreenshot = File(image.path);
          screenshotUploaded = true;
        });
        _toast(context, 'Payment screenshot uploaded ✔');
      }
    } catch (e) {
      _toast(context, 'Failed to upload screenshot: $e', isError: true);
    }
  }

  Future<void> _processPayment() async {
    if (paymentMethod == 'qr' && !screenshotUploaded) {
      _toast(context, 'Please upload a payment screenshot first.', isError: true);
      return;
    }

    setState(() => showSpinner = true);
    
    try {
      print('🔄 Starting payment processing...');
      
      // Check if user is authenticated
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        print('❌ No authenticated user found');
        setState(() => showSpinner = false);
        _toast(context, 'Please sign in to continue with payment.', isError: true);
        return;
      }
      
      print('✅ User authenticated: ${currentUser.uid}');
      
      // Try to get notification controller safely
      NotificationController? notificationController;
      try {
        notificationController = Get.find<NotificationController>();
        print('✅ Notification controller found');
      } catch (e) {
        print('⚠️ Notification controller not found, creating new one: $e');
        notificationController = Get.put(NotificationController());
      }
      
      final visitParts = visitSlot.split(' — ');
      final visitDate = visitParts.isNotEmpty ? visitParts[0] : visitSlot;
      final visitTime = visitParts.length > 1 ? visitParts[1] : '';
      
      print('📝 Saving booking to Firestore...');
      
      // Convert payment screenshot to base64 for Firestore storage
      String? paymentProofBase64;
      if (paymentMethod == 'qr' && paymentScreenshot != null) {
        try {
          print('📤 Converting payment screenshot to base64...');
          print('🗜️ Compressing image...');
          
          // Compress image first to ensure it's under 1MB
          final compressedFile = await _compressImage(paymentScreenshot!);
          final fileSize = await compressedFile.length();
          print('📏 Compressed file size: ${(fileSize / 1024 / 1024).toStringAsFixed(2)} MB');
          
          // Check if file is under 1MB (Firestore limit for base64 in documents)
          if (fileSize > 1024 * 1024) {
            // If still over 1MB, compress more aggressively
            print('⚠️ File still over 1MB, compressing more...');
            final tempDir = await getTemporaryDirectory();
            final targetPath = '${tempDir.path}/payment_${DateTime.now().millisecondsSinceEpoch}_extra_compressed.jpg';
            
            final result = await FlutterImageCompress.compressAndGetFile(
              compressedFile.absolute.path,
              targetPath,
              quality: 40, // More aggressive compression
              minWidth: 800,
              minHeight: 800,
            );
            
            if (result != null) {
              final extraCompressedFile = File(result.path);
              final extraCompressedSize = await extraCompressedFile.length();
              print('✅ Extra compressed file size: ${(extraCompressedSize / 1024 / 1024).toStringAsFixed(2)} MB');
              
              if (extraCompressedSize < 1024 * 1024) {
                final bytes = await extraCompressedFile.readAsBytes();
                paymentProofBase64 = base64Encode(bytes);
                print('✅ Payment screenshot converted to base64 (${paymentProofBase64.length} chars)');
              } else {
                print('❌ Cannot compress image under 1MB for Firestore');
                _toast(context, 'Image too large. Please choose a smaller image.', isError: true);
                setState(() => showSpinner = false);
                return;
              }
            }
          } else {
            // File is under 1MB, convert to base64
            final bytes = await compressedFile.readAsBytes();
            paymentProofBase64 = base64Encode(bytes);
            print('✅ Payment screenshot converted to base64 (${paymentProofBase64.length} chars)');
          }
        } catch (e) {
          print('❌ Error converting payment screenshot: $e');
          _toast(context, 'Failed to process payment screenshot', isError: true);
          setState(() => showSpinner = false);
          return;
        }
      }
      
      // Store booking in Firestore
      final docRef = await FirebaseFirestore.instance.collection('concierge_bookings').add({
        'client_id': currentUser.uid,
        'client_name': clientName,
        'concierge_name': conciergeName,
        'visit_address': visitAddress,
        'visit_date': visitDate,
        'visit_time': visitTime,
        'contact_method': widget.contactPreference ?? 'Phone', // METHOD: "Phone", "Email", "Line", "WhatsApp"
        'contact': widget.contactValue ?? '', // ACTUAL VALUE: phone number, email, Line ID, WhatsApp number
        'amount': retainerAmount,
        'status': 'pending',
        'payment_method': paymentMethod,
        'payment_proof_base64': paymentProofBase64, // QR code payment screenshot as base64
        'transaction_id': transactionId,
        'created_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
      });
      
      print('✅ Booking saved with ID: ${docRef.id}');
      
      // 🛋️ CREATE SOFA ORDER
      await _createSofaOrder(currentUser.uid);
      
      // Try to send notification to admin
      if (notificationController != null) {
        try {
          print('🔔 Sending notification to admin...');
          
          // Debug: Check admin users first
          print('🔍 Debugging admin users before sending notification...');
          await notificationController.debugAdminUsers();
          
          await notificationController.sendConciergeBookingNotification(
            clientName: clientName,
            conciergeName: conciergeName,
            visitDate: visitDate,
            visitTime: visitTime,
            amount: retainerAmount,
            clientId: currentUser.uid,
          );
          print('✅ Notification sent successfully');
        } catch (notifError) {
          print('⚠️ Notification sending failed (but booking was saved): $notifError');
          print('📋 Notification error details: ${notifError.toString()}');
          // Don't fail the entire process if notification fails
        }
      } else {
        print('⚠️ Notification controller is null, skipping notification');
      }
      
      await Future.delayed(const Duration(seconds: 1)); // simulate processing
      
      print('✅ Payment processing completed successfully');
      
    } catch (e, stackTrace) {
      print('❌ Error processing payment: $e');
      print('📋 Stack trace: $stackTrace');
      setState(() => showSpinner = false);
      _toast(context, 'Payment processing failed: ${e.toString()}', isError: true);
      return;
    }
    
    setState(() => showSpinner = false);
    _showPendingDialog();
  }

  Future<void> _createSofaOrder(String userId) async {
    try {
      print('🛋️ Starting sofa order creation...');
      
      // Get personalization controller
      final personalizationController = Get.find<PersonalizationController>();
      final sofaGenController = Get.find<SofaGenerationController>();
      
      // Check if we have a refined model
      if (sofaGenController.refinedModel.value == null) {
        print('⚠️ No refined model found, skipping order creation');
        return;
      }
      
      final refinedModel = sofaGenController.refinedModel.value!;
      final personalizationData = personalizationController.personalizationData;
      
      print('✅ Got refined model: ${refinedModel.glbUrl}');
      
      // Get material name for sofa name
      String materialName = 'Custom';
      if (personalizationData.styleMaterial?.materialType != null) {
        materialName = personalizationData.styleMaterial!.materialType.toString().split('.').last;
        materialName = materialName[0].toUpperCase() + materialName.substring(1);
      }
      
      // Calculate pricing
      final pricing = SofaPriceCalculator.calculatePrice(personalizationData);
      print('💰 Calculated price: ${pricing.totalPrice}');
      
      // Get delivery address
      String? deliveryAddress;
      try {
        final addressController = Get.find<AddressController>();
        if (addressController.addressList.isNotEmpty) {
          final address = addressController.addressList[addressController.selectedIndex];
          deliveryAddress = '${address.address}, ${address.district}, ${address.city}, ${address.pincode}, ${address.country}';
        }
      } catch (e) {
        print('⚠️ Could not load address: $e');
      }
      
      // Get onboarding data
      UserOnboardingData? onboardingData;
      try {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .get();
        
        if (userDoc.exists && userDoc.data()?['onboarding_data'] != null) {
          onboardingData = UserOnboardingData.fromJson(userDoc.data()!['onboarding_data']);
        }
      } catch (e) {
        print('⚠️ Could not load onboarding data: $e');
      }
      
      // Get user's change preferences note from personalization data
      final userNote = personalizationData.finalPreferences?.changePreferencesNote;
      final orderNote = userNote != null && userNote.isNotEmpty 
          ? 'Concierge order. User note: $userNote'
          : 'Order created via concierge payment';
      
      // Create the order
      print('📝 Creating order in Firestore...');
      final orderId = await OrderService.createOrder(
        sofaName: '$materialName Sofa',
        glbUrl: refinedModel.glbUrl ?? '',
        thumbnailUrl: refinedModel.thumbnailUrl ?? '',
        personalizationData: personalizationData,
        onboardingData: onboardingData,
        totalPrice: pricing.totalPrice,
        basePrice: pricing.basePrice,
        deliveryAddress: deliveryAddress,
        notes: orderNote,
      );
      
      if (orderId != null) {
        print('✅ Sofa order created successfully: $orderId');
      } else {
        print('❌ Failed to create sofa order');
      }
    } catch (e, stackTrace) {
      print('❌ Error creating sofa order: $e');
      print('📋 Stack trace: $stackTrace');
      // Don't fail the entire payment process if order creation fails
      // User can still see their concierge booking
    }
  }

  void _showPendingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (c) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: Row(
          children: [
            const Icon(Icons.task_alt, color: kSeaGreen, size: 22),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Payment Submitted',
                style: kNunitoSansSemiBold18.copyWith(color: kOffBlack),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Thank you—your concierge retainer has been submitted for review.",
              style: kNunitoSans14.copyWith(color: kGrey),
            ),
            SizedBox(height: 12),
            _NoteBox(
              color: kIvoryGradientLight,
              border: kIvoryGradientDark,
              icon: Icons.info_outline,
              text:
                  "Our concierge will verify your payment and confirm the home visit via your preferred contact.",
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              // Close dialog and go to Home
              Navigator.of(c).pop();
              Get.off(() => Home());
            },
            child: Text(
              'Got it',
              style: kNunitoSansSemiBold16.copyWith(color: kOffBlack),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
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
          "Proceed to Payment",
          style: kMerriweatherBold16.copyWith(color: kOffBlack),
        ),
      ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Summary
                _Card(
                  title: 'Concierge Visit Summary',
                  emoji: '🗓️',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _KV(label: 'Client', value: clientName),
                      if (widget.conciergeName != null)
                        _KV(label: 'Concierge', value: conciergeName),
                      if (widget.selectedDate != null || widget.selectedTime != null)
                        _KV(label: 'Preferred Slot', value: visitSlot),
                      if (widget.selectedLocation != null)
                        _KV(label: 'Address', value: visitAddress),
                      if (widget.contactPreference != null)
                        _KV(label: 'Contact', value: contact),
                      const Divider(height: 28),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Concierge Retainer',
                            style: kNunitoSansSemiBold16.copyWith(color: kOffBlack),
                          ),
                          Text(
                            '฿${retainerAmount.toStringAsFixed(2)}',
                            style: kNunitoSansBold18.copyWith(
                              color: kSeaGreen,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Payment method
                Text(
                  'Choose Payment Method',
                  style: kNunitoSansSemiBold18.copyWith(color: kOffBlack),
                ),
                const SizedBox(height: 12),
                _MethodSelector(
                  value: paymentMethod,
                  onChanged: (v) {
                    setState(() {
                      paymentMethod = v;
                      showQRCode = (v == 'qr');
                    });
                  },
                ),
                const SizedBox(height: 20),

                if (showQRCode && paymentMethod == 'qr')
                  _Card(
                    title: 'Scan QR to Pay',
                    emoji: '📱',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // QR block (placeholder)
                        _QRPlaceholder(amount: retainerAmount, transactionId: transactionId),
                        const SizedBox(height: 16),

                        // Upload screenshot
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [kIvoryGradientLight, kIvoryGradientMid, kIvoryGradientDark],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: kIvoryGradientDark.withOpacity(0.5),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(
                                screenshotUploaded ? Icons.check_circle : Icons.upload_file,
                                color: screenshotUploaded ? kSeaGreen : kOffBlack,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                screenshotUploaded
                                    ? 'Payment screenshot uploaded'
                                    : 'Upload payment screenshot',
                                style: kNunitoSansSemiBold16.copyWith(
                                  color: screenshotUploaded ? kSeaGreen : kOffBlack,
                                ),
                              ),
                              const SizedBox(height: 8),
                              if (!screenshotUploaded)
                                ElevatedButton.icon(
                                  onPressed: _pickPaymentScreenshot,
                                  icon: const Icon(Icons.photo_library, color: kLynxWhite),
                                  label: Text(
                                    'Choose Screenshot',
                                    style: kNunitoSansSemiBold16.copyWith(color: kLynxWhite),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: kOffBlack,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                              if (screenshotUploaded && paymentScreenshot != null) ...[
                                const SizedBox(height: 10),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.file(
                                    paymentScreenshot!,
                                    height: 160,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        if (screenshotUploaded)
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _processPayment,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: kSeaGreen,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                'Submit for Review',
                                style: kNunitoSansSemiBold16.copyWith(color: kLynxWhite),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                if (paymentMethod == 'line' && !showQRCode) ...[
                  _Card(
                    title: 'LINE Pay',
                    emoji: '🖤',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const _NoteBox(
                          icon: Icons.info_outline,
                          text:
                              'You will be redirected to LINE Pay to complete the payment for ฿5,000. After success, you’ll return here automatically.',
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _processPayment, // stub—wire to your LINE Pay flow
                            style: ElevatedButton.styleFrom(
                              backgroundColor: kOffBlack,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              'Pay with LINE',
                              style: kNunitoSansSemiBold16.copyWith(color: kLynxWhite),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 16),
                const _NoteBox(
                  icon: Icons.security,
                  text:
                      'Your payment is secured. The retainer is fully credited to your project and refundable if no consultation occurs.',
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),

        // very light “spinner” layer
        if (showSpinner)
          Container(
            color: Colors.black.withOpacity(0.12),
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          ),
      ],
    );
  }

  void _toast(BuildContext context, String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? kFireOpal : kOffBlack,
      ),
    );
  }
}

// ---------- UI Helpers ----------

class _Card extends StatelessWidget {
  final String title;
  final String emoji;
  final Widget child;

  const _Card({required this.title, required this.emoji, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
      decoration: BoxDecoration(
        color: kLynxWhite,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: kOffBlack.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: kNunitoSansBold18.copyWith(color: kOffBlack),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _KV extends StatelessWidget {
  final String label;
  final String value;
  const _KV({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: kNunitoSans14.copyWith(color: kGrey)),
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: 2,
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: kNunitoSansSemiBold16.copyWith(color: kOffBlack),
            ),
          ),
        ],
      ),
    );
  }
}

class _NoteBox extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;
  final Color border;

  const _NoteBox({
    required this.icon,
    required this.text,
    this.color = kIvoryGradientLight,
    this.border = kIvoryGradientDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration:
          BoxDecoration(color: color, borderRadius: BorderRadius.circular(10), border: Border.all(color: border)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: kGrey),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: kNunitoSans14.copyWith(color: kOffBlack),
            ),
          ),
        ],
      ),
    );
  }
}

class _QRPlaceholder extends StatelessWidget {
  final double amount;
  final String transactionId;
  const _QRPlaceholder({required this.amount, required this.transactionId});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // QR visual placeholder — replace with a real widget (e.g., qr_flutter)
        Container(
          width: 220,
          height: 220,
          decoration: BoxDecoration(
            color: kSnowFlakeWhite,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: kChristmasSilver),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.qr_code, size: 96, color: kGrey),
              const SizedBox(height: 8),
              Text('QR Code', style: kNunitoSans12Grey),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Text(
          'Amount: ฿${amount.toStringAsFixed(2)}',
          style: kNunitoSansBold16.copyWith(color: kSeaGreen),
        ),
        const SizedBox(height: 6),
        Text(
          'Transaction ID: $transactionId',
          style: kNunitoSans12Grey.copyWith(fontFamily: 'monospace'),
        ),
      ],
    );
  }
}

class _MethodSelector extends StatelessWidget {
  final String value;
  final ValueChanged<String> onChanged;

  const _MethodSelector({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration:
          BoxDecoration(color: kLynxWhite, borderRadius: BorderRadius.circular(12), boxShadow: [
        BoxShadow(color: kOffBlack.withOpacity(0.05), blurRadius: 12, offset: const Offset(0, 6)),
      ]),
      child: RadioListTile<String>(
        title: Row(
          children: [
            Icon(Icons.qr_code, color: kOffBlack),
            const SizedBox(width: 8),
            const Text('QR Code Payment'),
          ],
        ),
        subtitle: const Text('Scan to pay with mobile banking / PromptPay'),
        value: 'qr',
        groupValue: value,
        onChanged: (v) => onChanged(v!),
      ),
    );
  }
}
