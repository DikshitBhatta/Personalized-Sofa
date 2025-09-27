import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:get/get.dart';
import 'package:timberr/constants.dart';
import 'package:timberr/screens/home.dart';

class ConciergePaymentScreen extends StatefulWidget {
  const ConciergePaymentScreen({super.key});

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

  // Dummy booking summary (replace with real data)
  final String clientName = 'Ms. A. Client';
  final String conciergeName = 'P. Somchai';
  final String visitAddress = '88 Wireless Rd, Lumphini, Pathum Wan, Bangkok';
  final String visitSlot = 'Tue, 24 Sep 2025 — 10:30–11:30';
  final String contact = '+66 8x xxx xxxx';
  final double retainerAmount = 5000.00; // ฿5,000 concierge retainer
  final String transactionId = 'SOFA-${DateTime.now().millisecondsSinceEpoch}';

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
    await Future.delayed(const Duration(seconds: 2)); // simulate processing
    setState(() => showSpinner = false);

    _showPendingDialog();
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
                      _KV(label: 'Concierge', value: conciergeName),
                      _KV(label: 'Preferred Slot', value: visitSlot),
                      _KV(label: 'Address', value: visitAddress),
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
      child: Column(
        children: [
          RadioListTile<String>(
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
          const Divider(height: 1),
          RadioListTile<String>(
            title: Row(
              children: [
                Icon(Icons.payment, color: kOffBlack),
                const SizedBox(width: 8),
                const Text('LINE Pay'),
              ],
            ),
            subtitle: const Text('Pay through LINE application'),
            value: 'line',
            groupValue: value,
            onChanged: (v) => onChanged(v!),
          ),
        ],
      ),
    );
  }
}
