import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:timberr/constants.dart';
import 'package:timberr/controllers/onboarding_controller.dart';

class OnboardingStep2 extends StatefulWidget {
  const OnboardingStep2({super.key});

  @override
  State<OnboardingStep2> createState() => _OnboardingStep2State();
}

class _OnboardingStep2State extends State<OnboardingStep2> {
  final OnboardingController controller = Get.find<OnboardingController>();
  final TextEditingController _guestFeelingController = TextEditingController();
  final TextEditingController _guestImpressionController = TextEditingController();
  final TextEditingController _personalTasteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _guestFeelingController.text = controller.onboardingData.guestFeeling ?? '';
    _guestImpressionController.text = controller.onboardingData.guestImpression ?? '';
    _personalTasteController.text = controller.onboardingData.personalTasteWord ?? '';
  }

  @override
  void dispose() {
    _guestFeelingController.dispose();
    _guestImpressionController.dispose();
    _personalTasteController.dispose();
    super.dispose();
  }

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
            "Your Signature",
            style: kMerriweatherBold24,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 30, right: 30, bottom: 20),
          child: Text(
            "Help us understand the ambience and character you envision for your space.",
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
                  "Personality & Ambience",
                  style: kNunitoSansBold18.copyWith(
                    fontSize: 20,
                  ),
                ),
              ),
              const SizedBox(height: 25),
              
              // Question 1: Living Room Personality
              _buildQuestion(
                "If your living room had a personality, it would be:",
                [
                  _buildGridOptions([
                    ("Calm & Minimal", "Calm & Minimal"),
                    ("Warm & Welcoming", "Warm & Welcoming"),
                    ("Bold & Expressive", "Bold & Expressive"),
                    ("Modern & Sleek", "Modern & Sleek"),
                  ], controller.onboardingData.livingRoomPersonality, (value) {
                    setState(() => controller.setLivingRoomPersonality(value));
                  }),
                ],
              ),
              
              // Question 2: Guest Feeling (text input)
              Padding(
                padding: const EdgeInsets.only(left: 30, right: 30, bottom: 25),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "How do you want people to feel when they enter your space?",
                      style: kNunitoSansSemiBold16.copyWith(
                        color: kOffBlack,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _guestFeelingController,
                      cursorColor: kOffBlack,
                      maxLines: 2,
                      onChanged: (value) => controller.setGuestFeeling(value),
                      decoration: inputDecorationConst.copyWith(
                        labelText: "Your answer",
                        hintText: "e.g., welcomed, relaxed, inspired...",
                        hintStyle: TextStyle(color: kNoghreiSilver),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Question 3: Social Energy Preference
              _buildQuestion(
                "The energy at home feels:",
                [
                  _OptionButton(
                    text: "Quiet and Personal",
                    onTap: () {
                      setState(() => controller.setSocialEnergyPreference("Quiet and personal"));
                    },
                    isSelected: controller.onboardingData.socialEnergyPreference == "Quiet and personal",
                  ),
                  _OptionButton(
                    text: "Balanced",
                    onTap: () {
                      setState(() => controller.setSocialEnergyPreference("Balanced"));
                    },
                    isSelected: controller.onboardingData.socialEnergyPreference == "Balanced",
                  ),
                  _OptionButton(
                    text: "Lively and Social",
                    onTap: () {
                      setState(() => controller.setSocialEnergyPreference("Lively and social"));
                    },
                    isSelected: controller.onboardingData.socialEnergyPreference == "Lively and social",
                  ),
                ],
              ),
              
              // Question 4: Guest Impression (text input)
              Padding(
                padding: const EdgeInsets.only(left: 30, right: 30, bottom: 25),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "The impression you want to leave:",
                      style: kNunitoSansSemiBold16.copyWith(
                        color: kOffBlack,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _guestImpressionController,
                      cursorColor: kOffBlack,
                      maxLines: 2,
                      onChanged: (value) => controller.setGuestImpression(value),
                      decoration: inputDecorationConst.copyWith(
                        labelText: "Your answer",
                        hintText: "e.g., sophisticated, comfortable, unique...",
                        hintStyle: TextStyle(color: kNoghreiSilver),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Question 5: Personal Taste Word (text input)
              Padding(
                padding: const EdgeInsets.only(left: 30, right: 30, bottom: 25),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "How would you describe your personal taste in one word?",
                      style: kNunitoSansSemiBold16.copyWith(
                        color: kOffBlack,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "e.g., timeless, bold, natural, elegant",
                      style: kNunitoSans12Grey.copyWith(
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _personalTasteController,
                      cursorColor: kOffBlack,
                      onChanged: (value) => controller.setPersonalTasteWord(value),
                      decoration: inputDecorationConst.copyWith(
                        labelText: "One word",
                        hintText: "Timeless",
                        hintStyle: TextStyle(color: kNoghreiSilver),
                      ),
                    ),
                  ],
                ),
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
