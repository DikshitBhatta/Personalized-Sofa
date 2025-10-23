import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:timberr/constants.dart';
import 'package:timberr/controllers/onboarding_controller.dart';
import 'package:timberr/screens/authentication/onboarding_step_1.dart';
import 'package:timberr/screens/authentication/onboarding_step_2.dart';
import 'package:timberr/screens/authentication/onboarding_step_3.dart';
import 'package:timberr/screens/authentication/onboarding_step_4.dart';

class UserOnboardingScreen extends StatefulWidget {
  const UserOnboardingScreen({super.key});

  @override
  State<UserOnboardingScreen> createState() => _UserOnboardingScreenState();
}

class _UserOnboardingScreenState extends State<UserOnboardingScreen> {
  final OnboardingController _onboardingController = Get.put(OnboardingController());
  final PageController _pageController = PageController();

  final List<Widget> _pages = [
    const OnboardingStep1(),
    const OnboardingStep2(),
    const OnboardingStep3(),
    const OnboardingStep4(),
  ];

  @override
  void initState() {
    super.initState();
    // Listen to page changes from controller
    ever(_onboardingController.currentPageIndex, (index) {
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundBeige,
      body: SafeArea(
        child: Column(
          children: [
            // Progress indicator
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
              child: Obx(() => Row(
                children: List.generate(OnboardingController.totalPages, (index) {
                  final isActive = index == _onboardingController.currentPageIndex.value;
                  final isCompleted = index < _onboardingController.currentPageIndex.value;
                  
                  return Expanded(
                    child: Container(
                      height: 4,
                      margin: EdgeInsets.only(
                        right: index < OnboardingController.totalPages - 1 ? 8 : 0,
                      ),
                      decoration: BoxDecoration(
                        color: isActive || isCompleted ? kOffBlack : kNoghreiSilver,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  );
                }),
              )),
            ),
            
            // Pages
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: _pages,
              ),
            ),
            
            // Navigation Buttons
            Obx(() => Padding(
              padding: const EdgeInsets.all(30),
              child: Row(
                children: [
                  if (_onboardingController.currentPageIndex.value > 0)
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _onboardingController.previousPage(),
                        child: Container(
                          height: 50,
                          margin: const EdgeInsets.only(right: 10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: kOffBlack, width: 1.5),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              "BACK",
                              style: kNunitoSansSemiBold18.copyWith(
                                color: kOffBlack,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  Expanded(
                    flex: _onboardingController.currentPageIndex.value > 0 ? 1 : 1,
                    child: GestureDetector(
                      onTap: () {
                        if (_onboardingController.currentPageIndex.value < OnboardingController.totalPages - 1) {
                          _onboardingController.nextPage();
                        } else {
                          _onboardingController.completeOnboarding();
                        }
                      },
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          color: kOffBlack,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x50303030),
                              offset: Offset(0, 10),
                              blurRadius: 20,
                            )
                          ],
                        ),
                        child: Center(
                          child: Text(
                            _onboardingController.currentPageIndex.value < OnboardingController.totalPages - 1
                                ? "NEXT"
                                : "GET STARTED",
                            style: kNunitoSansSemiBold18.copyWith(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}