// Example usage of LottieService
// Import this in any widget where you need a loading indicator

import 'package:flutter/material.dart';
import '../services/lottie_service.dart';

/// Examples of how to use the LottieService throughout your app
class LottieServiceExamples {
  
  /// Example 1: Simple circular progress indicator
  static Widget basicExample() {
    return LottieService.circularProgressIndicator();
  }
  
  /// Example 2: Small loading indicator with custom color
  static Widget smallColoredExample() {
    return LottieService.smallCircularProgressIndicator(
      color: Colors.blue,
    );
  }
  
  /// Example 3: Full screen loading with text
  static Widget fullScreenLoadingExample() {
    return Scaffold(
      body: LottieService.centeredLoadingWidget(
        size: 100.0,
        loadingText: "Loading your furniture...",
        textStyle: const TextStyle(
          fontSize: 16.0,
          fontWeight: FontWeight.w500,
          color: Colors.grey,
        ),
      ),
    );
  }
  
  /// Example 4: Loading overlay on existing content
  static Widget overlayExample() {
    return Scaffold(
      body: Stack(
        children: [
          // Your main content here
          const Center(
            child: Text("Main Content"),
          ),
          // Loading overlay
          LottieService.loadingOverlay(
            loadingText: "Please wait...",
          ),
        ],
      ),
    );
  }
  
  /// Example 5: Loading button
  static Widget loadingButtonExample() {
    bool isLoading = false;
    
    return StatefulBuilder(
      builder: (context, setState) {
        return LottieService.loadingButton(
          onPressed: () async {
            setState(() => isLoading = true);
            // Simulate network call
            await Future.delayed(const Duration(seconds: 2));
            setState(() => isLoading = false);
          },
          text: "Add to Cart",
          isLoading: isLoading,
          backgroundColor: Colors.orange,
          textColor: Colors.white,
          loadingColor: Colors.white,
          width: 200.0,
        );
      },
    );
  }
  
  /// Example 6: Show/Hide loading dialog
  static void showLoadingDialogExample(BuildContext context) {
    LottieService.showLoadingDialog(
      context,
      message: "Processing your order...",
      animationColor: Colors.orange,
    );
    
    // Hide after 3 seconds (in real app, hide when operation completes)
    Future.delayed(const Duration(seconds: 3), () {
      LottieService.hideLoadingDialog(context);
    });
  }
}

/// Example widget showing different sizes
class LoadingSizesExample extends StatelessWidget {
  const LoadingSizesExample({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Loading Sizes")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    const Text("Small"),
                    const SizedBox(height: 8),
                    // Small loading indicator
                    LottieService.smallCircularProgressIndicator(),
                  ],
                ),
                Column(
                  children: [
                    const Text("Medium"),
                    const SizedBox(height: 8),
                    // Medium loading indicator
                    LottieService.mediumCircularProgressIndicator(),
                  ],
                ),
                Column(
                  children: [
                    const Text("Large"),
                    const SizedBox(height: 8),
                    // Large loading indicator
                    LottieService.largeCircularProgressIndicator(),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
