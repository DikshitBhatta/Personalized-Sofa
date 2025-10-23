import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:timberr/constants.dart';
import 'package:timberr/controllers/splash_controller.dart';

/// Splash Screen - Shows loading animation while app initializes
/// Uses SplashController for all logic and data loading
/// Controller is automatically created by SplashBinding
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Get the controller (created by SplashBinding)
    // Controller's onReady() will automatically trigger data loading
    final controller = Get.find<SplashController>();
    
    return Scaffold(
      backgroundColor: kBackgroundBeige,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Loading animation
            LottieBuilder.asset(
              "assets/lottie/splash_loading_animation.json",
              width: 250,
              height: 250,
            ),
            
            const SizedBox(height: 24),
            
            // Loading message (reactive)
            Obx(() => Text(
              controller.loadingMessage.value,
              style: const TextStyle(
                fontSize: 16,
                color: kOffBlack,
                fontWeight: FontWeight.w500,
              ),
            )),
          ],
        ),
      ),
    );
  }
}
