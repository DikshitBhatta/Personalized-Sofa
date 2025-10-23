import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:timberr/constants.dart';
import 'package:timberr/controllers/onboarding_controller.dart';

class OnboardingIntroScreen extends StatelessWidget {
  const OnboardingIntroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final OnboardingController controller = Get.find<OnboardingController>();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Flexible(
              child: Divider(
                color: kNoghreiSilver,
                thickness: 1,
                indent: 30,
                endIndent: 20,
              ),
            ),
            SvgPicture.asset("assets/furniture_vector.svg"),
            const Flexible(
              child: Divider(
                color: kNoghreiSilver,
                thickness: 1,
                indent: 20,
                endIndent: 30,
              ),
            ),
          ],
        ),
        const Padding(
          padding: EdgeInsets.only(top: 20, left: 30, bottom: 10),
          child: Text(
            "GETTING TO KNOW YOU",
            style: kMerriweatherBold24,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 30, right: 30, bottom: 30),
          child: Text(
            "Before we craft your sofa, let's understand you — your space, your energy, and your way of living.\n\nBecause true comfort begins with character.",
            style: kNunitoSans14.copyWith(
              fontSize: 15,
              height: 1.5,
              color: kGraniteGrey,
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.only(right: 30),
          decoration: const BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Color(0x408A959E),
                offset: Offset(0, 7),
                blurRadius: 30,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 30, top: 30, right: 30),
                child: Text(
                  "You & Your Lifestyle",
                  style: kNunitoSansBold18.copyWith(
                    fontSize: 20,
                  ),
                ),
              ),
              const SizedBox(height: 30),
              
              // Question 1: Personality Type
              _buildQuestion(
                "How would you describe yourself?",
                [
                  _OptionButton(
                    text: "Introvert — I enjoy calm, personal spaces",
                    onTap: () => controller.setPersonalityType("Introvert"),
                    isSelected: controller.onboardingData.personalityType == "Introvert",
                  ),
                  _OptionButton(
                    text: "Extrovert — I love hosting and social energy",
                    onTap: () => controller.setPersonalityType("Extrovert"),
                    isSelected: controller.onboardingData.personalityType == "Extrovert",
                  ),
                  _OptionButton(
                    text: "Balanced — a mix of both",
                    onTap: () => controller.setPersonalityType("Balanced"),
                    isSelected: controller.onboardingData.personalityType == "Balanced",
                  ),
                ],
              ),
              
              // Question 2: Home Type
              _buildQuestion(
                "What kind of home do you live in?",
                [
                  _OptionButton(
                    text: "Apartment",
                    onTap: () => controller.setHomeType("Apartment"),
                    isSelected: controller.onboardingData.homeType == "Apartment",
                  ),
                  _OptionButton(
                    text: "Villa",
                    onTap: () => controller.setHomeType("Villa"),
                    isSelected: controller.onboardingData.homeType == "Villa",
                  ),
                  _OptionButton(
                    text: "Penthouse",
                    onTap: () => controller.setHomeType("Penthouse"),
                    isSelected: controller.onboardingData.homeType == "Penthouse",
                  ),
                  _OptionButton(
                    text: "Loft",
                    onTap: () => controller.setHomeType("Loft"),
                    isSelected: controller.onboardingData.homeType == "Loft",
                  ),
                  _OptionButton(
                    text: "Beach house",
                    onTap: () => controller.setHomeType("Beach house"),
                    isSelected: controller.onboardingData.homeType == "Beach house",
                  ),
                  _OptionButton(
                    text: "Other",
                    onTap: () => controller.setHomeType("Other"),
                    isSelected: controller.onboardingData.homeType == "Other",
                  ),
                ],
              ),
              
              const SizedBox(height: 30),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildQuestion(String question, List<Widget> options) {
    return Padding(
      padding: const EdgeInsets.only(left: 30, right: 30, bottom: 25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question,
            style: kNunitoSansSemiBold16.copyWith(
              color: kOffBlack,
            ),
          ),
          const SizedBox(height: 12),
          ...options,
        ],
      ),
    );
  }
}

class _OptionButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  final bool isSelected;
  
  const _OptionButton({
    required this.text,
    required this.onTap,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? kOffBlack : Colors.transparent,
          border: Border.all(
            color: isSelected ? kOffBlack : kNoghreiSilver,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          text,
          style: kNunitoSans14.copyWith(
            color: isSelected ? Colors.white : kOffBlack,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
