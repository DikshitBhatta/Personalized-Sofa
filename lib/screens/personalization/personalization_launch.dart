import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:timberr/constants.dart';
import 'package:timberr/controllers/personalization_controller.dart';
import 'package:timberr/models/personalization_data.dart';
import 'package:timberr/screens/personalization/personalization_flow.dart';
import 'package:timberr/widgets/buttons/custom_elevated_button.dart';

class PersonalizationLaunchScreen extends StatelessWidget {
  final AudienceType? preSelectedAudience;

  const PersonalizationLaunchScreen({super.key, this.preSelectedAudience});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundBeige,
      appBar: AppBar(
        backgroundColor: kBackgroundBeige,
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            Get.back();
          },
          icon: const Icon(Icons.arrow_back_ios_new, color: kOffBlack, size: 20),
        ),
        centerTitle: true,
        title: Text(
          "PERSONALIZE YOUR SOFA",
          style: kMerriweatherBold16.copyWith(color: kOffBlack),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              
              Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      kIvoryGradientLight,
                      kIvoryGradientMid,
                      kIvoryGradientDark,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: kIvoryGradientDark.withOpacity(0.5),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: kIvoryGradientDark.withOpacity(0.2),
                      spreadRadius: 0,
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.chair,
                      size: 60,
                      color: kOffBlack,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "Create Your Perfect Sofa",
                      style: kNunitoSansBold20.copyWith(color: kOffBlack),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Personalized just for you",
                      style: kNunitoSans14.copyWith(color: kGraniteGrey),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 20),
              
              Text(
                "Design your perfect sofa",
                style: kNunitoSansBold24.copyWith(color: kOffBlack),
              ),
              
              const SizedBox(height: 10),
              
              Text(
                "Our personalization process takes few minutes and ensures you get exactly what you need:",
                style: kNunitoSans16.copyWith(color: kTinGrey),
              ),
              
              const SizedBox(height: 24),
              
              _buildFeatureItem("🎯", "Tailored to your needs", "Based on who will use it most"),
              const SizedBox(height: 16),
              _buildFeatureItem("🎨", "Your style choices", "Materials, colors, and details"),
              const SizedBox(height: 16),
              _buildFeatureItem("✨", "Professional quality", "Handcrafted with premium materials"),
              
              const SizedBox(height: 40),
              
              CustomElevatedButton(
                onTap: () {
                  Get.to(() => PersonalizationFlowScreen(preSelectedAudience: preSelectedAudience));
                },
                text: "Start Personalization",
              ),
              
              const SizedBox(height: 16),
              
              Center(
                child: Text(
                  "Takes about 3-5 minutes",
                  style: kNunitoSans14.copyWith(color: kGrey),
                ),
              ),
              
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildFeatureItem(String emoji, String title, String description) {
    return Row(
      children: [
        Text(
          emoji,
          style: const TextStyle(fontSize: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: kNunitoSansSemiBold16.copyWith(color: kOffBlack),
              ),
              Text(
                description,
                style: kNunitoSans14.copyWith(color: kGrey),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
