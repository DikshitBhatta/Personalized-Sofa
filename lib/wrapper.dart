import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:timberr/routes/app_routes.dart';
import 'package:timberr/role/role_controller.dart';
import 'package:timberr/role/admin_wrapper.dart';
import 'package:timberr/services/init_services.dart';

/// Wrapper - Entry point for authenticated routing
/// Determines whether to show onboarding or redirect based on user role
/// NO manual controller initialization - bindings handle that
class Wrapper extends StatelessWidget {
  const Wrapper({super.key});

  @override
  Widget build(BuildContext context) {
    // Check authentication state and redirect accordingly
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Show loading while checking auth state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        
        // User is logged in - redirect based on role
        if (snapshot.hasData && snapshot.data != null) {
          return const _RoleBasedRedirect();
        }
        
        // User is not logged in - use WidgetsBinding callback to navigate after build
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Get.offAllNamed(AppRoutes.onboarding);
        });
        
        return const SizedBox.shrink();
      },
    );
  }
}

/// Internal widget to handle role-based redirection
class _RoleBasedRedirect extends StatefulWidget {
  const _RoleBasedRedirect();

  @override
  State<_RoleBasedRedirect> createState() => _RoleBasedRedirectState();
}

class _RoleBasedRedirectState extends State<_RoleBasedRedirect> {
  @override
  void initState() {
    super.initState();
    _redirect();
  }

  Future<void> _redirect() async {
    try {
      print('🔀 ========== USER REDIRECT STARTING ==========');
      
      // Complete notification initialization now that user is logged in
      print('🔔 Completing notification initialization for logged-in user...');
      try {
        if (Get.isRegistered<NotificationServiceInitializer>()) {
          final notificationService = Get.find<NotificationServiceInitializer>();
          await notificationService.completeInitialization();
        } else {
          print('⚠️ NotificationServiceInitializer not available yet');
        }
      } catch (e) {
        print('⚠️  Could not complete notification initialization: $e');
        // Continue anyway - don't block user flow
      }
      
      // Get role controller (already initialized by InitialBinding)
      final roleController = Get.isRegistered<RoleController>()
          ? Get.find<RoleController>()
          : Get.put(RoleController(), permanent: true);
      
      // Refresh user role from Firebase
      print('🎭 Refreshing user role...');
      await roleController.refreshUserRole();
      
      if (!mounted) return;
      
      print('✅ User role: ${roleController.isAdmin ? "admin" : "user"}');
      
      // Navigate after widget is built
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (roleController.isAdmin) {
          // Admin user - go to admin wrapper (not using routes for admin to keep existing logic)
          print('🔀 Redirecting to admin wrapper...');
          Get.offAll(() => const AdminWrapper());
        } else {
          // Regular user - use named route with binding
          print('🔀 Redirecting to splash screen...');
          Get.offAllNamed(AppRoutes.splash);
        }
      });
      
      print('===============================================');
    } catch (e, stackTrace) {
      print('❌ ========== ERROR IN ROLE REDIRECT ==========');
      print('Error: $e');
      print('Stack trace: $stackTrace');
      print('================================================');
      
      // Fallback to splash screen on error
      if (mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Get.offAllNamed(AppRoutes.splash);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
