import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:timberr/role/role_controller.dart';
import 'package:timberr/role/admin_wrapper.dart';
import 'package:timberr/wrapper.dart';
import 'package:timberr/screens/authentication/onboarding_welcome.dart';

/// Utility class for role-based navigation and interface switching
class RoleNavigationService {
  static final RoleController _roleController = Get.find<RoleController>();

  /// Navigate to appropriate interface based on user role
  static Future<void> navigateBasedOnRole() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        Get.offAll(() => const OnBoardingWelcomeScreen());
        return;
      }

      await _roleController.refreshUserRole();

      if (_roleController.isAdmin) {
        Get.offAll(() => const AdminWrapper());
      } else {
        Get.offAll(() => const Wrapper());
      }
    } catch (e) {
      print('Error in role-based navigation: $e');
      Get.offAll(() => const Wrapper());
    }
  }

  /// Switch from admin interface to user interface (admin testing user experience)
  static void switchToUserInterface() {
    if (!_roleController.isAdmin) {
      Get.snackbar(
        'Access Denied',
        'Only admins can switch interfaces',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
      );
      return;
    }

    Get.dialog(
      AlertDialog(
        title: const Text('Switch to User Interface'),
        content: const Text(
          'You will be redirected to the regular user interface to test the user experience. '
          'You can return to the admin interface anytime from the profile menu.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(Get.context!).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(Get.context!).pop();
              Get.offAll(() => const Wrapper());
            },
            child: const Text('Switch to User Interface'),
          ),
        ],
      ),
    );
  }

  /// Switch from user interface to admin interface (for admins)
  static void switchToAdminInterface() {
    if (!_roleController.isAdmin) {
      Get.snackbar(
        'Access Denied',
        'You need admin privileges to access the admin interface',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
      );
      return;
    }

    Get.dialog(
      AlertDialog(
        title: const Text('Switch to Admin Interface'),
        content: const Text(
          'You will be redirected to the admin dashboard where you can manage users, orders, and other administrative tasks.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(Get.context!).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(Get.context!).pop();
              Get.offAll(() => const AdminWrapper());
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Switch to Admin Interface', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  /// Check if current user can access admin features
  static bool canAccessAdmin() {
    return _roleController.isAdmin;
  }

  /// Show interface switch options for admins
  static void showInterfaceSwitchDialog() {
    if (!_roleController.isAdmin) return;

    Get.dialog(
      AlertDialog(
        title: const Text('Switch Interface'),
        content: const Text('Choose which interface you want to use:'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(Get.context!).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(Get.context!).pop();
              Get.offAll(() => const Wrapper());
            },
            child: const Text('User Interface'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(Get.context!).pop();
              Get.offAll(() => const AdminWrapper());
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Admin Interface', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  /// Get interface type description
  static String getCurrentInterfaceType() {
    // This is a simple way to determine interface type
    // You might want to implement a more robust solution
    return _roleController.isAdmin ? 'Admin Interface Available' : 'User Interface';
  }

  /// Refresh user role and redirect if needed
  static Future<void> refreshAndRedirect() async {
    await _roleController.refreshUserRole();
    
    Get.dialog(
      AlertDialog(
        title: const Text('Role Refreshed'),
        content: Text(
          'Your role has been refreshed. Current role: ${_roleController.currentUserRole}.\n\n'
          'Would you like to navigate to the appropriate interface?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(Get.context!).pop(),
            child: const Text('Stay Here'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(Get.context!).pop();
              navigateBasedOnRole();
            },
            child: const Text('Navigate'),
          ),
        ],
      ),
    );
  }
}

/// Widget for interface switching button (for admin users)
class InterfaceSwitchButton extends StatelessWidget {
  final bool isAdminInterface;
  final VoidCallback? onPressed;

  const InterfaceSwitchButton({
    super.key,
    required this.isAdminInterface,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<RoleController>(
      builder: (roleController) {
        if (!roleController.isAdmin) {
          return const SizedBox.shrink();
        }

        return IconButton(
          onPressed: onPressed ?? () {
            if (isAdminInterface) {
              RoleNavigationService.switchToUserInterface();
            } else {
              RoleNavigationService.switchToAdminInterface();
            }
          },
          icon: Icon(
            isAdminInterface ? Icons.person : Icons.admin_panel_settings,
            color: isAdminInterface ? Colors.blue : Colors.red,
          ),
          tooltip: isAdminInterface ? 'Switch to User Interface' : 'Switch to Admin Interface',
        );
      },
    );
  }
}

/// AppBar action for interface switching
class InterfaceSwitchAction extends StatelessWidget {
  final bool isAdminInterface;

  const InterfaceSwitchAction({
    super.key,
    required this.isAdminInterface,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<RoleController>(
      builder: (roleController) {
        if (!roleController.isAdmin) {
          return const SizedBox.shrink();
        }

        return PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'switch_user':
                RoleNavigationService.switchToUserInterface();
                break;
              case 'switch_admin':
                RoleNavigationService.switchToAdminInterface();
                break;
              case 'refresh_role':
                RoleNavigationService.refreshAndRedirect();
                break;
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem<String>(
              value: isAdminInterface ? 'switch_user' : 'switch_admin',
              child: Row(
                children: [
                  Icon(
                    isAdminInterface ? Icons.person : Icons.admin_panel_settings,
                    color: isAdminInterface ? Colors.blue : Colors.red,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(isAdminInterface ? 'User Interface' : 'Admin Interface'),
                ],
              ),
            ),
            const PopupMenuItem<String>(
              value: 'refresh_role',
              child: Row(
                children: [
                  Icon(Icons.refresh, color: Colors.green, size: 20),
                  SizedBox(width: 8),
                  Text('Refresh Role'),
                ],
              ),
            ),
          ],
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isAdminInterface ? Colors.red.shade100 : Colors.blue.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isAdminInterface ? Icons.admin_panel_settings : Icons.person,
                  color: isAdminInterface ? Colors.red.shade800 : Colors.blue.shade800,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  isAdminInterface ? 'Admin' : 'User',
                  style: TextStyle(
                    color: isAdminInterface ? Colors.red.shade800 : Colors.blue.shade800,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}