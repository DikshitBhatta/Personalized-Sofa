import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:timberr/role/role_controller.dart';
import 'package:timberr/role/role_guard_widgets.dart';
import 'package:timberr/Admin/AdminDashboard.dart';
import 'package:timberr/screens/authentication/onboarding_welcome.dart';

class AdminWrapper extends StatefulWidget {
  const AdminWrapper({super.key});

  @override
  State<AdminWrapper> createState() => _AdminWrapperState();
}

class _AdminWrapperState extends State<AdminWrapper> {
  final RoleController _roleController = Get.find<RoleController>();

  @override
  void initState() {
    super.initState();
    _verifyAdminAccess();
  }

  /// Verify that the current user still has admin access
  Future<void> _verifyAdminAccess() async {
    await _roleController.refreshUserRole();
    if (!_roleController.isAdmin) {
      // User is no longer admin, redirect to user interface
      _redirectToUserInterface();
    }
  }

  /// Redirect to user interface
  void _redirectToUserInterface() {
    Get.offAll(() => const OnBoardingWelcomeScreen());
  }

  @override
  Widget build(BuildContext context) {
    return PermissionGuard(
      adminOnly: true,
      child: const AdminDashboard(),
      fallback: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.security,
                size: 64,
                color: Colors.grey,
              ),
              const SizedBox(height: 16),
              const Text(
                'Access Denied',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Admin privileges required to access this interface.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _redirectToUserInterface,
                child: const Text('Go to User Interface'),
              ),
            ],
          ),
        ),
      ),
      showFallbackOnNoPermission: true,
    );
  }
}