import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:timberr/constants.dart';
import 'package:timberr/controllers/personalization_controller.dart';
import 'package:timberr/models/personalization_data.dart';
import 'package:timberr/widgets/cards/audience_card.dart';
import 'package:timberr/widgets/progress/personalization_progress_bar.dart';
import 'package:timberr/screens/personalization/personalization_step2.dart';

class PersonalizationStep1Screen extends StatelessWidget {
  PersonalizationStep1Screen({super.key});

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
          "PERSONALIZATION",
          style: kMerriweatherBold16.copyWith(color: kOffBlack),
        ),
      ),
      body: GetBuilder<PersonalizationController>(
        builder: (controller) {
          return Column(
            children: [
              // Progress bar
              PersonalizationProgressBar(
                currentStep: controller.currentStep,
                totalSteps: 4,
                stepCompletionStatus: [
                  controller.isStepComplete(0),
                  controller.isStepComplete(1),
                  controller.isStepComplete(2),
                  controller.isStepComplete(3),
                ],
              ),
              
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Text(
                        controller.getStepTitle(0),
                        style: kNunitoSansBold24.copyWith(color: kOffBlack),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        controller.getStepDescription(0),
                        style: kNunitoSans18.copyWith(color: kTinGrey),
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // Audience selection cards
                      Column(
                        children: [
                          AudienceCard(
                            title: "Adult",
                            description: "Perfect fit and ergonomic support for adults",
                            iconPath: "assets/icons/person_icon.svg",
                            isSelected: controller.personalizationData.audienceType == AudienceType.adult,
                            onTap: () => controller.setAudienceType(AudienceType.adult),
                          ),
                          
                          const SizedBox(height: 16),
                          
                          AudienceCard(
                            title: "Child",
                            description: "Safe and comfortable design for growing children",
                            iconPath: "assets/icons/person_icon.svg",
                            isSelected: controller.personalizationData.audienceType == AudienceType.child,
                            onTap: () => controller.setAudienceType(AudienceType.child),
                          ),
                          
                          const SizedBox(height: 16),
                          
                          AudienceCard(
                            title: "Pet",
                            description: "Durable and pet-friendly materials and design",
                            iconPath: "assets/icons/chair_icon.svg",
                            isSelected: controller.personalizationData.audienceType == AudienceType.pet,
                            onTap: () => controller.setAudienceType(AudienceType.pet),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
              
              // Bottom navigation
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x10000000),
                      offset: Offset(0, -2),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          border: Border.all(color: kChristmasSilver),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: TextButton(
                          onPressed: () => Get.back(),
                          child: Text(
                            "Back",
                            style: kNunitoSansSemiBold16.copyWith(color: kTinGrey),
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(width: 12),
                    
                    Expanded(
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          border: Border.all(color: kChristmasSilver),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: TextButton(
                          onPressed: controller.canProceedToNext() 
                              ? () {
                                  controller.nextStep();
                                  Get.to(() => const PersonalizationStep2Screen());
                                }
                              : () {
                                  Get.snackbar(
                                    "Selection Required",
                                    "Please select who this sofa is for before continuing",
                                    snackPosition: SnackPosition.BOTTOM,
                                  );
                                },
                          child: Text(
                            "Continue",
                            style: kNunitoSansSemiBold16.copyWith(color: kTinGrey),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
