import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:timberr/constants.dart';
import 'package:timberr/controllers/onboarding_controller.dart';

class OnboardingStep1 extends StatefulWidget {
  const OnboardingStep1({super.key});

  @override
  State<OnboardingStep1> createState() => _OnboardingStep1State();
}

class _OnboardingStep1State extends State<OnboardingStep1> {
  final OnboardingController controller = Get.find<OnboardingController>();
  final TextEditingController _locationController = TextEditingController();
  final List<String> _selectedComfortWords = [];

  @override
  void initState() {
    super.initState();
    _locationController.text = controller.onboardingData.location ?? '';
    _selectedComfortWords.addAll(controller.onboardingData.comfortWords);
  }

  @override
  void dispose() {
    _locationController.dispose();
    super.dispose();
  }

  void _toggleComfortWord(String word) {
    setState(() {
      if (_selectedComfortWords.contains(word)) {
        _selectedComfortWords.remove(word);
      } else {
        if (_selectedComfortWords.length < 3) {
          _selectedComfortWords.add(word);
        } else {
          Get.snackbar(
            "Maximum reached",
            "You can select up to 3 comfort words",
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: kOffBlack,
            colorText: Colors.white,
            margin: const EdgeInsets.all(20),
          );
        }
      }
      controller.setComfortWords(_selectedComfortWords);
    });
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
            "KNOW YOU BETTER",
            style: kMerriweatherBold24,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 30, right: 30, bottom: 20),
          child: Text(
            "Your space. Your style. Perfectly Understood.",
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
                  "You & Your Lifestyle",
                  style: kNunitoSansBold18.copyWith(
                    fontSize: 20,
                  ),
                ),
              ),
              const SizedBox(height: 25),
              
              // Question 1: Personality Type
              _buildQuestion(
                "How would you describe yourself?",
                [
                  _PersonalityOptionButton(
                    title: "Introvert",
                    subtitle: "I enjoy calm, personal spaces",
                    onTap: () {
                      setState(() => controller.setPersonalityType("Introvert"));
                    },
                    isSelected: controller.onboardingData.personalityType == "Introvert",
                  ),
                  _PersonalityOptionButton(
                    title: "Extrovert",
                    subtitle: "I love hosting and social energy",
                    onTap: () {
                      setState(() => controller.setPersonalityType("Extrovert"));
                    },
                    isSelected: controller.onboardingData.personalityType == "Extrovert",
                  ),
                  _PersonalityOptionButton(
                    title: "Balanced",
                    subtitle: "A mix of both",
                    onTap: () {
                      setState(() => controller.setPersonalityType("Balanced"));
                    },
                    isSelected: controller.onboardingData.personalityType == "Balanced",
                  ),
                ],
              ),
              
              // Question 2: Home Type
              _buildQuestion(
                "What best describes your livig space?",
                [
                  _buildGridOptions([
                    ("Apartment", "Apartment"),
                    ("Villa", "Villa"),
                    ("Penthouse", "Penthouse"),
                    ("Loft", "Loft"),
                    ("Beach house", "Beach house"),
                    ("Other", "Other"),
                  ], controller.onboardingData.homeType, (value) {
                    setState(() => controller.setHomeType(value));
                  }),
                ],
              ),
              
              // Question 3: Living Style
              _buildQuestion(
                "Which style reflects your home’s character?",
                [
                  _buildGridOptions([
                    ("Contemporary", "Contemporary"),
                    ("Classic", "Classic"),
                    ("Minimal", "Minimal"),
                    ("Eclectic", "Eclectic"),
                    ("Coastal", "Resort"),
                    ("Transitional", "Transitional"),
                  ], controller.onboardingData.livingStyle, (value) {
                    setState(() => controller.setLivingStyle(value));
                  }),
                ],
              ),
              
              // // Question 4: Location
              // Padding(
              //   padding: const EdgeInsets.only(left: 30, right: 30, bottom: 25),
              //   child: Column(
              //     crossAxisAlignment: CrossAxisAlignment.start,
              //     children: [
              //       Text(
              //         "Where is your home located?",
              //         style: kNunitoSansSemiBold16.copyWith(
              //           color: kOffBlack,
              //         ),
              //       ),
              //       const SizedBox(height: 12),
              //       TextFormField(
              //         controller: _locationController,
              //         cursorColor: kOffBlack,
              //         onChanged: (value) => controller.setLocation(value),
              //         decoration: inputDecorationConst.copyWith(
              //           labelText: "City / Country",
              //           hintText: "e.g., Los Angeles, USA",
              //           hintStyle: TextStyle(color: kNoghreiSilver),
              //         ),
              //       ),
              //     ],
              //   ),
              // ),
              
              // Question 5: Living Room Feeling
              _buildQuestion(
                "What atmosphere do you want your living space to evoke?",
                [
                  _buildGridOptions([
                    ("Cozy & Relaxed", "Cozy & relaxed"),
                    ("Elegant & Grand", "Elegant & grand"),
                    ("Bright & Lively", "Bright & lively"),
                    ("Calm & Balanced", "Calm & balanced"),
                  ], controller.onboardingData.livingRoomFeeling, (value) {
                    setState(() => controller.setLivingRoomFeeling(value));
                  }),
                ],
              ),
              
              // Question 6: Relaxation Activity
              _buildQuestion(
                "How do you unwind in your living space?",
                [
                  _buildGridOptions([
                    ("Reading", "Reading"),
                    ("Watching movies", "Movies"),
                    ("Lounging", "Lounging"),
                    ("Conversations", "Conversations"),
                    ("Entertaining guests", "Entertaining"),
                  ], controller.onboardingData.relaxationActivity, (value) {
                    setState(() => controller.setRelaxationActivity(value));
                  }),
                ],
              ),
              
              // Question 7: Comfort Words (multi-select)
              Padding(
                padding: const EdgeInsets.only(left: 30, right: 30, bottom: 25),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Which words capture your idea of perfect comfort? (Choose up to 3))",
                      style: kNunitoSansSemiBold16.copyWith(
                        color: kOffBlack,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        "Cozy",
                        "Elegant",
                        "Supportive",
                        "Firm",
                        "Inviting",
                        "Grand"
                      ].map((word) => _MultiSelectChip(
                        text: word,
                        isSelected: _selectedComfortWords.contains(word),
                        onTap: () => _toggleComfortWord(word),
                      )).toList(),
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

class _PersonalityOptionButton extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool isSelected;
  
  const _PersonalityOptionButton({
    required this.title,
    required this.subtitle,
    required this.onTap,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? kOffBlack : Colors.transparent,
          border: Border.all(
            color: isSelected ? kOffBlack : kNoghreiSilver,
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: kNunitoSansSemiBold16.copyWith(
                color: isSelected ? Colors.white : kOffBlack,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: kNunitoSans14.copyWith(
                color: isSelected ? Colors.white.withOpacity(0.8) : kGraniteGrey,
                fontSize: 13,
              ),
            ),
          ],
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

class _MultiSelectChip extends StatelessWidget {
  final String text;
  final bool isSelected;
  final VoidCallback onTap;
  
  const _MultiSelectChip({
    required this.text,
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
