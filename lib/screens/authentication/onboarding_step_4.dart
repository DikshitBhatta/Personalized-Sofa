import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:timberr/constants.dart';
import 'package:timberr/controllers/onboarding_controller.dart';

class OnboardingStep4 extends StatelessWidget {
  const OnboardingStep4({super.key});

  @override
  Widget build(BuildContext context) {
    final OnboardingController controller = Get.find<OnboardingController>();
    
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
           const SizedBox(height: 10),
        //   Row(
        //     children: [
        //       const Flexible(
        //         child: Divider(
        //           color: kNoghreiSilver,
        //           thickness: 1,
        //           indent: 30,
        //           endIndent: 20,
        //         ),
        //       ),
        //       SvgPicture.asset("assets/furniture_vector.svg"),
        //       const Flexible(
        //         child: Divider(
        //           color: kNoghreiSilver,
        //           thickness: 1,
        //           indent: 20,
        //           endIndent: 30,
        //         ),
        //       ),
        //     ],
        //   ),
        // const SizedBox(height: 60),
        
        // Success Icon
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: kOffBlack,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.check,
            size: 60,
            color: Colors.white,
          ),
        ),
        
        const SizedBox(height: 40),
        
        // Thank You Message
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Text(
            "Thank you!",
            textAlign: TextAlign.center,
            style: kMerriweatherBold24.copyWith(
              fontSize: 32,
            ),
          ),
        ),
        
        // const SizedBox(height: 10),
        
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Text(
            "Your style is taking shape.",
            textAlign: TextAlign.center,
            style: kNunitoSans14.copyWith(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              height: 1.6,
              color: kGraniteGrey,
            ),
          ),
        ),
        
        const SizedBox(height: 30),
        
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 0),
          // padding: const EdgeInsets.only(bottom: 20),
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [
              BoxShadow(
                color: Color(0x408A959E),
                offset: Offset(0, 7),
                blurRadius: 30,
              ),
            ],
          ),
          child: Column(
            children: [
              Text(
                "Let's design a sofa that feels like you.",
                textAlign: TextAlign.center,
                style: kNunitoSansBold18.copyWith(
                  fontSize: 20,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 20),
              
              // Summary of selections
              if (controller.onboardingData.personalityType != null) ...[
                _buildSummaryItem(
                  icon: Icons.person_outline,
                  label: "Personality",
                  value: controller.onboardingData.personalityType!,
                ),
              ],
              
              if (controller.onboardingData.livingStyle != null) ...[
                _buildSummaryItem(
                  icon: Icons.home_outlined,
                  label: "Style",
                  value: controller.onboardingData.livingStyle!,
                ),
              ],
              
              if (controller.onboardingData.livingRoomFeeling != null) ...[
                _buildSummaryItem(
                  icon: Icons.sentiment_satisfied_alt_outlined,
                  label: "Ambience",
                  value: controller.onboardingData.livingRoomFeeling!,
                ),
              ],
              
              if (controller.onboardingData.comfortWords.isNotEmpty) ...[
                _buildSummaryItem(
                  icon: Icons.star_outline,
                  label: "Comfort",
                  value: controller.onboardingData.comfortWords.join(", "),
                ),
              ],
            ],
          ),
        ),
        
        const SizedBox(height: 40),
        
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Text(
            "Your lifestyle is now part of the design story. Let’s begin crafting your sofa.",
            textAlign: TextAlign.center,
            style: kNunitoSans14.copyWith(
              fontSize: 15,
              color: kGrey,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      ],
    ),
    );
  }
  
  Widget _buildSummaryItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 20,
            color: kOffBlack,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: kNunitoSans12Grey.copyWith(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: kNunitoSans14.copyWith(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: kOffBlack,
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
