import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

/// Service class for managing Lottie animations throughout the app
class LottieService {
  static const String _furnitureSwapPath = 'assets/lottie/Furniture_Swap.json';
  
  /// Creates a circular progress indicator using the Furniture_Swap Lottie animation
  /// 
  /// [size] - The size of the animation (default: 80.0)
  /// [color] - Optional color filter for the animation
  /// [repeat] - Whether the animation should repeat (default: true)
  /// [reverse] - Whether the animation should reverse (default: false)
  /// [animate] - Whether the animation should start automatically (default: true)
  static Widget circularProgressIndicator({
    double size = 80.0,
    Color? color,
    bool repeat = true,
    bool reverse = false,
    bool animate = true,
  }) {
    return SizedBox(
      width: size,
      height: size,
      child: Lottie.asset(
        _furnitureSwapPath,
        width: size,
        height: size,
        fit: BoxFit.contain,
        repeat: repeat,
        reverse: reverse,
        animate: animate,
        delegates: color != null
            ? LottieDelegates(
                values: [
                  ValueDelegate.colorFilter(
                    const ['**'],
                    value: ColorFilter.mode(color, BlendMode.srcATop),
                  ),
                ],
              )
            : null,
      ),
    );
  }
  
  /// Creates a small circular progress indicator (40x40)
  static Widget smallCircularProgressIndicator({
    Color? color,
    bool repeat = true,
  }) {
    return circularProgressIndicator(
      size: 40.0,
      color: color,
      repeat: repeat,
    );
  }
  
  /// Creates a medium circular progress indicator (60x60)
  static Widget mediumCircularProgressIndicator({
    Color? color,
    bool repeat = true,
  }) {
    return circularProgressIndicator(
      size: 60.0,
      color: color,
      repeat: repeat,
    );
  }
  
  /// Creates a large circular progress indicator (120x120)
  static Widget largeCircularProgressIndicator({
    Color? color,
    bool repeat = true,
  }) {
    return circularProgressIndicator(
      size: 120.0,
      color: color,
      repeat: repeat,
    );
  }
  
  /// Creates a centered loading widget with the furniture swap animation
  /// Useful for full-screen loading states
  static Widget centeredLoadingWidget({
    double size = 80.0,
    Color? color,
    String? loadingText,
    TextStyle? textStyle,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          circularProgressIndicator(
            size: size,
            color: color,
          ),
          if (loadingText != null) ...[
            const SizedBox(height: 16.0),
            Text(
              loadingText,
              style: textStyle ?? const TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ],
        ],
      ),
    );
  }
  
  /// Creates a loading overlay that can be placed on top of other widgets
  /// 
  /// [backgroundColor] - Background color of the overlay (default: semi-transparent black)
  /// [size] - Size of the loading animation
  /// [color] - Color filter for the animation
  static Widget loadingOverlay({
    Color backgroundColor = const Color(0x80000000),
    double size = 80.0,
    Color? color,
    String? loadingText,
  }) {
    return Container(
      color: backgroundColor,
      child: centeredLoadingWidget(
        size: size,
        color: color,
        loadingText: loadingText,
      ),
    );
  }
  
  /// Creates a loading button replacement
  /// Useful when you want to show loading state in place of a button
  static Widget loadingButton({
    required VoidCallback? onPressed,
    required String text,
    bool isLoading = false,
    double? width,
    double height = 48.0,
    Color? backgroundColor,
    Color? textColor,
    Color? loadingColor,
    BorderRadius? borderRadius,
  }) {
    return SizedBox(
      width: width,
      height: height,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: borderRadius ?? BorderRadius.circular(8.0),
          ),
        ),
        child: isLoading
            ? circularProgressIndicator(
                size: 24.0,
                color: loadingColor ?? Colors.white,
              )
            : Text(
                text,
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }
  
  /// Shows a loading dialog with the furniture swap animation
  static void showLoadingDialog(
    BuildContext context, {
    String? message,
    bool barrierDismissible = false,
    Color? animationColor,
  }) {
    showDialog(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                circularProgressIndicator(
                  size: 80.0,
                  color: animationColor,
                ),
                if (message != null) ...[
                  const SizedBox(height: 16.0),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
  
  /// Hides the loading dialog
  static void hideLoadingDialog(BuildContext context) {
    Navigator.of(context).pop();
  }
}
