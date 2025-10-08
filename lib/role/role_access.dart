import 'package:firebase_auth/firebase_auth.dart';
import 'package:timberr/role/role_service.dart';
import 'package:timberr/role/role_model.dart';

/// Utility class to help with role-based access control
class RoleBasedAccessControl {
  /// Check if the current user has admin privileges
  static Future<bool> isCurrentUserAdmin() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) return false;
      
      final userRole = await RoleService.getUserRole(currentUser.uid);
      return userRole == DefaultRoles.adminRole;
    } catch (e) {
      print('Error checking if current user is admin: $e');
      return false;
    }
  }

  /// Get the current user's role
  static Future<String> getCurrentUserRole() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) return DefaultRoles.userRole;
      
      return await RoleService.getUserRole(currentUser.uid);
    } catch (e) {
      print('Error getting current user role: $e');
      return DefaultRoles.userRole;
    }
  }

  /// Get user role by email
  static Future<String> getUserRole(String email) async {
    try {
      return await RoleService.getUserRoleByEmail(email);
    } catch (e) {
      print('Error getting user role by email: $e');
      return DefaultRoles.userRole;
    }
  }

  /// Check if a user has permission to perform admin actions
  static Future<bool> canPerformAdminActions([String? email]) async {
    try {
      if (email != null) {
        final role = await RoleService.getUserRoleByEmail(email);
        return role == DefaultRoles.adminRole;
      } else {
        return await isCurrentUserAdmin();
      }
    } catch (e) {
      print('Error checking admin permissions: $e');
      return false;
    }
  }

  /// Check if current user has specific permission
  static Future<bool> hasPermission(String permission) async {
    try {
      final currentUserRole = await getCurrentUserRole();
      final rolePermissions = _getRolePermissions(currentUserRole);
      return rolePermissions.contains(permission);
    } catch (e) {
      print('Error checking permission: $e');
      return false;
    }
  }

  /// Check if user has multiple permissions (all must be true)
  static Future<bool> hasAllPermissions(List<String> permissions) async {
    try {
      final currentUserRole = await getCurrentUserRole();
      final rolePermissions = _getRolePermissions(currentUserRole);
      
      for (String permission in permissions) {
        if (!rolePermissions.contains(permission)) {
          return false;
        }
      }
      return true;
    } catch (e) {
      print('Error checking multiple permissions: $e');
      return false;
    }
  }

  /// Check if user has any of the specified permissions (at least one must be true)
  static Future<bool> hasAnyPermission(List<String> permissions) async {
    try {
      final currentUserRole = await getCurrentUserRole();
      final rolePermissions = _getRolePermissions(currentUserRole);
      
      for (String permission in permissions) {
        if (rolePermissions.contains(permission)) {
          return true;
        }
      }
      return false;
    } catch (e) {
      print('Error checking any permissions: $e');
      return false;
    }
  }

  /// Validate role change permissions (only admins can change roles)
  static Future<bool> canChangeUserRole(String targetEmail) async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) return false;

      // Check if the current user has admin privileges
      final isAdmin = await isCurrentUserAdmin();
      if (!isAdmin) return false;

      // Prevent admin from demoting themselves
      if (currentUser.email == targetEmail) return false;

      return true;
    } catch (e) {
      print('Error validating role change permissions: $e');
      return false;
    }
  }

  /// Check if current user can access admin dashboard
  static Future<bool> canAccessAdminDashboard() async {
    return await hasPermission('view_admin_dashboard');
  }

  /// Check if current user can manage users
  static Future<bool> canManageUsers() async {
    return await hasPermission('manage_users');
  }

  /// Check if current user can manage orders
  static Future<bool> canManageOrders() async {
    return await hasPermission('manage_orders');
  }

  /// Check if current user can manage products
  static Future<bool> canManageProducts() async {
    return await hasPermission('manage_products');
  }

  /// Check if current user can view analytics
  static Future<bool> canViewAnalytics() async {
    return await hasPermission('view_analytics');
  }

  /// Check if current user can manage concierge services
  static Future<bool> canManageConcierge() async {
    return await hasPermission('manage_concierge');
  }

  /// Check if current user can manage deliveries
  static Future<bool> canManageDeliveries() async {
    return await hasPermission('manage_deliveries');
  }

  /// Get permissions for a specific role
  static List<String> _getRolePermissions(String roleName) {
    switch (roleName) {
      case 'admin':
        return DefaultRoles.admin.permissions;
      case 'user':
        return DefaultRoles.user.permissions;
      default:
        return DefaultRoles.user.permissions;
    }
  }

  /// Get current user's permissions
  static Future<List<String>> getCurrentUserPermissions() async {
    try {
      final currentUserRole = await getCurrentUserRole();
      return _getRolePermissions(currentUserRole);
    } catch (e) {
      print('Error getting current user permissions: $e');
      return DefaultRoles.user.permissions;
    }
  }

  /// Check if user is authenticated
  static bool isUserAuthenticated() {
    return FirebaseAuth.instance.currentUser != null;
  }

  /// Get current user ID
  static String? getCurrentUserId() {
    return FirebaseAuth.instance.currentUser?.uid;
  }

  /// Get current user email
  static String? getCurrentUserEmail() {
    return FirebaseAuth.instance.currentUser?.email;
  }

  /// Assign admin role to user (only callable by existing admin)
  static Future<bool> assignAdminRole(String targetUserId, String targetUserEmail) async {
    try {
      // Check permissions first
      final canChange = await canChangeUserRole(targetUserEmail);
      if (!canChange) {
        throw Exception('Insufficient permissions to assign admin role');
      }

      return await RoleService.assignAdminRole(targetUserId, targetUserEmail);
    } catch (e) {
      print('Error assigning admin role: $e');
      return false;
    }
  }

  /// Remove admin role from user (only callable by existing admin)
  static Future<bool> removeAdminRole(String targetUserId, String targetUserEmail) async {
    try {
      // Check permissions first
      final canChange = await canChangeUserRole(targetUserEmail);
      if (!canChange) {
        throw Exception('Insufficient permissions to remove admin role');
      }

      return await RoleService.removeAdminRole(targetUserId, targetUserEmail);
    } catch (e) {
      print('Error removing admin role: $e');
      return false;
    }
  }

  /// Initialize role system (call this once during app setup)
  static Future<void> initializeRoleSystem() async {
    try {
      print('🚀 Starting role system initialization...');
      await RoleService.initializeDefaultRoles();
      print('✅ Role system initialization completed');
    } catch (e) {
      print('❌ Role system initialization failed: $e');
      print('📝 App will continue with graceful degradation');
      // Don't throw exception - allow app to continue
    }
  }

  /// Assign default user role to new user (call this during user registration)
  static Future<void> assignDefaultUserRole(String userId, String userEmail) async {
    try {
      await RoleService.assignDefaultUserRole(userId, userEmail);
    } catch (e) {
      print('Error assigning default user role: $e');
      throw Exception('Failed to assign user role');
    }
  }
}