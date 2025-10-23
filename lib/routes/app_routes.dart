import 'package:get/get.dart';
import 'package:timberr/bindings/initial_binding.dart';
import 'package:timberr/bindings/auth_binding.dart';
import 'package:timberr/bindings/splash_binding.dart';
import 'package:timberr/bindings/home_binding.dart';
import 'package:timberr/screens/authentication/onboarding_welcome.dart';
import 'package:timberr/screens/authentication/splash_screen.dart';
import 'package:timberr/screens/home.dart';
import 'package:timberr/wrapper.dart';

/// App Routes Configuration
/// Each route has its own binding for proper dependency injection
class AppRoutes {
  static const String wrapper = '/';
  static const String onboarding = '/onboarding';
  static const String splash = '/splash';
  static const String home = '/home';
  
  static List<GetPage> routes = [
    GetPage(
      name: wrapper,
      page: () => const Wrapper(),
      binding: InitialBinding(),
    ),
    GetPage(
      name: onboarding,
      page: () => const OnBoardingWelcomeScreen(),
      binding: AuthBinding(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: splash,
      page: () => const SplashScreen(),
      binding: SplashBinding(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: home,
      page: () => Home(),
      binding: HomeBinding(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
    ),
  ];
}
