import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:timberr/constants.dart';
import 'package:timberr/controllers/onboarding_controller.dart';

class OnboardingStep3 extends StatefulWidget {
  const OnboardingStep3({super.key});

  @override
  State<OnboardingStep3> createState() => _OnboardingStep3State();
}

class _OnboardingStep3State extends State<OnboardingStep3> {
  final OnboardingController controller = Get.find<OnboardingController>();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
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
            "YOUR LIFESTYLE",
            style: kMerriweatherBold24,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 30, right: 30, bottom: 20),
          child: Text(
            "These details help us tailor your sofa.",
            style: kNunitoSans14.copyWith(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              height: 1.5,
              color: kGraniteGrey,
            ),
          ),
        ),
        Container(
         margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 0),
          padding: const EdgeInsets.only(bottom: 20),
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
                  "Lifestyle Context",
                  style: kNunitoSansBold18.copyWith(
                    fontSize: 20,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 30, right: 30, top: 8),
                child: Text(
                  "(Optional but valuable)",
                  style: kNunitoSans12Grey.copyWith(
                    fontSize: 13,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
              const SizedBox(height: 25),
              
              // Question 1: Living Arrangement
              _buildQuestion(
                "Who do you live with?",
                [
                  _buildGridOptions([
                    ("Solo", "Alone"),
                    ("Partner", "With partner"),
                    ("Family", "With family"),
                  ], controller.onboardingData.livingArrangement, (value) {
                    setState(() => controller.setLivingArrangement(value));
                  }),
                ],
              ),
              
              // Question 2: Has Pets (toggle)
              Padding(
                padding: const EdgeInsets.only(left: 30, right: 30, bottom: 25),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        "Do you have pets?",
                        style: kNunitoSansSemiBold16.copyWith(
                          color: kOffBlack,
                        ),
                      ),
                    ),
                    Switch(
                      value: controller.onboardingData.hasPets ?? false,
                      onChanged: (value) {
                        setState(() => controller.setHasPets(value));
                      },
                      activeColor: kOffBlack,
                    ),
                  ],
                ),
              ),
              
              // Question 3: Hosting Frequency
              _buildQuestion(
                "How often do you host?",
                [
                  _buildGridOptions([
                    ("Rarely", "Rarely"),
                    ("Occasionally", "Occasionally"),
                    ("Frequently", "Frequently"),
                    ("Very often", "Very often"),
                  ], controller.onboardingData.hostingFrequency, (value) {
                    setState(() => controller.setHostingFrequency(value));
                  }),
                ],
              ),
              
              // Question 4: Sofa Usage Time
              _buildQuestion(
                "How long do you typically spend on your sofa each day?",
                [
                  _OptionButton(
                    text: "Less than 1 hour",
                    onTap: () {
                      setState(() => controller.setSofaUsageTime("Less than 1 hour"));
                    },
                    isSelected: controller.onboardingData.sofaUsageTime == "Less than 1 hour",
                  ),
                  _OptionButton(
                    text: "1-3 hours",
                    onTap: () {
                      setState(() => controller.setSofaUsageTime("1-3 hours"));
                    },
                    isSelected: controller.onboardingData.sofaUsageTime == "1-3 hours",
                  ),
                  _OptionButton(
                    text: "3-5 hours",
                    onTap: () {
                      setState(() => controller.setSofaUsageTime("3-5 hours"));
                    },
                    isSelected: controller.onboardingData.sofaUsageTime == "3-5 hours",
                  ),
                  _OptionButton(
                    text: "More than 5 hours",
                    onTap: () {
                      setState(() => controller.setSofaUsageTime("More than 5 hours"));
                    },
                    isSelected: controller.onboardingData.sofaUsageTime == "More than 5 hours",
                  ),
                ],
              ),
              
              const SizedBox(height: 10),
            ],
          ),
        ),
      ],
    ),
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
  
  Widget _buildGridOptions(
    List<(String, String)> options,
    String? selectedValue,
    Function(String) onSelect,
  ) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options.map((option) => _OptionChip(
        text: option.$1,
        value: option.$2,
        isSelected: selectedValue == option.$2,
        onTap: () => onSelect(option.$2),
      )).toList(),
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
            width: 1.5,
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

class _OptionChip extends StatelessWidget {
  final String text;
  final String value;
  final bool isSelected;
  final VoidCallback onTap;
  
  const _OptionChip({
    required this.text,
    required this.value,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? kOffBlack : Colors.transparent,
          border: Border.all(
            color: isSelected ? kOffBlack : kNoghreiSilver,
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(20),
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
