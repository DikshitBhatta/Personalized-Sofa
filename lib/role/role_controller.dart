import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:timberr/role/role_service.dart';
import 'package:timberr/role/role_model.dart';
import 'package:timberr/role/role_access.dart';

/// Controller to manage role-based operations and UI state
class RoleController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  // Observable role state
  final RxString _currentUserRole = DefaultRoles.userRole.obs;
  final RxBool _isAdmin = false.obs;
  final RxBool _isLoading = false.obs;
  final RxList<String> _currentUserPermissions = <String>[].obs;
  final RxList<Map<String, dynamic>> _allUsers = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> _roleChangeHistory = <Map<String, dynamic>>[].obs;

  // Getters
  String get currentUserRole => _currentUserRole.value;
  bool get isAdmin => _isAdmin.value;
  bool get isLoading => _isLoading.value;
  List<String> get currentUserPermissions => _currentUserPermissions;
  List<Map<String, dynamic>> get allUsers => _allUsers;
  List<Map<String, dynamic>> get roleChangeHistory => _roleChangeHistory;

  @override
  void onInit() {
    super.onInit();
    _initializeRole();
    
    // Listen to auth state changes
    _auth.authStateChanges().listen((User? user) {
      if (user != null) {
        _loadUserRole();
      } else {
        _resetRoleState();
      }
    });
  }

  /// Initialize role system
  Future<void> _initializeRole() async {
    try {
      _isLoading.value = true;
      // Role system is already initialized in main.dart
      // Just load user role if user is authenticated
      if (_auth.currentUser != null) {
        await _loadUserRole();
      }
    } catch (e) {
      print('Error loading user role: $e');
      // Don't show error snackbar, just log and continue with defaults
    } finally {
      _isLoading.value = false;
    }
  }

  /// Load current user's role and permissions
  Future<void> _loadUserRole() async {
    try {
      final role = await RoleBasedAccessControl.getCurrentUserRole();
      final permissions = await RoleBasedAccessControl.getCurrentUserPermissions();
      
      _currentUserRole.value = role;
      _isAdmin.value = role == DefaultRoles.adminRole;
      _currentUserPermissions.assignAll(permissions);
      
      update();
    } catch (e) {
      print('Error loading user role: $e');
    }
  }

  /// Reset role state when user logs out
  void _resetRoleState() {
    _currentUserRole.value = DefaultRoles.userRole;
    _isAdmin.value = false;
    _currentUserPermissions.clear();
    _allUsers.clear();
    _roleChangeHistory.clear();
    update();
  }

  /// Check if current user has a specific permission
  bool hasPermission(String permission) {
    return _currentUserPermissions.contains(permission);
  }

  /// Check if current user has all specified permissions
  bool hasAllPermissions(List<String> permissions) {
    return permissions.every((permission) => _currentUserPermissions.contains(permission));
  }

  /// Check if current user has any of the specified permissions
  bool hasAnyPermission(List<String> permissions) {
    return permissions.any((permission) => _currentUserPermissions.contains(permission));
  }

  /// Refresh user role and permissions
  Future<void> refreshUserRole() async {
    await _loadUserRole();
  }

  /// Load all users with their roles (admin only)
  Future<void> loadAllUsers() async {
    try {
      if (!_isAdmin.value) {
        throw Exception('Insufficient permissions');
      }

      _isLoading.value = true;
      final users = await RoleService.getAllUsersWithRoles();
      _allUsers.assignAll(users);
      update();
    } catch (e) {
      print('Error loading all users: $e');
      Get.snackbar(
        'Error',
        'Failed to load users: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  /// Assign admin role to a user
  Future<bool> assignAdminRole(String userId, String userEmail, String userName) async {
    try {
      _isLoading.value = true;
      
      final success = await RoleBasedAccessControl.assignAdminRole(userId, userEmail);
      
      if (success) {
        // Update local user list
        final userIndex = _allUsers.indexWhere((user) => user['user_id'] == userId);
        if (userIndex != -1) {
          _allUsers[userIndex]['role'] = DefaultRoles.adminRole;
          _allUsers[userIndex]['role_assigned_at'] = DateTime.now().toIso8601String();
          _allUsers[userIndex]['role_assigned_by'] = _auth.currentUser?.email;
        }
        
        Get.snackbar(
          'Success',
          'Admin role assigned to $userName successfully',
          snackPosition: SnackPosition.BOTTOM,
        );
        
        update();
        return true;
      } else {
        Get.snackbar(
          'Error',
          'Failed to assign admin role to $userName',
          snackPosition: SnackPosition.BOTTOM,
        );
        return false;
      }
    } catch (e) {
      print('Error assigning admin role: $e');
      Get.snackbar(
        'Error',
        'Failed to assign admin role: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  /// Remove admin role from a user
  Future<bool> removeAdminRole(String userId, String userEmail, String userName) async {
    try {
      _isLoading.value = true;
      
      final success = await RoleBasedAccessControl.removeAdminRole(userId, userEmail);
      
      if (success) {
        // Update local user list
        final userIndex = _allUsers.indexWhere((user) => user['user_id'] == userId);
        if (userIndex != -1) {
          _allUsers[userIndex]['role'] = DefaultRoles.userRole;
          _allUsers[userIndex]['role_assigned_at'] = DateTime.now().toIso8601String();
          _allUsers[userIndex]['role_assigned_by'] = _auth.currentUser?.email;
        }
        
        Get.snackbar(
          'Success',
          'Admin role removed from $userName successfully',
          snackPosition: SnackPosition.BOTTOM,
        );
        
        update();
        return true;
      } else {
        Get.snackbar(
          'Error',
          'Failed to remove admin role from $userName',
          snackPosition: SnackPosition.BOTTOM,
        );
        return false;
      }
    } catch (e) {
      print('Error removing admin role: $e');
      Get.snackbar(
        'Error',
        'Failed to remove admin role: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  /// Load role change history (admin only)
  Future<void> loadRoleChangeHistory({int limit = 50}) async {
    try {
      if (!_isAdmin.value) {
        throw Exception('Insufficient permissions');
      }

      _isLoading.value = true;
      final history = await RoleService.getRoleChangeHistory(limit: limit);
      _roleChangeHistory.assignAll(history);
      update();
    } catch (e) {
      print('Error loading role change history: $e');
      Get.snackbar(
        'Error',
        'Failed to load role change history: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  /// Get user count by role
  Map<String, int> getUserCountByRole() {
    if (_allUsers.isEmpty) return {};
    
    final Map<String, int> counts = {};
    for (final user in _allUsers) {
      final role = user['role'] ?? DefaultRoles.userRole;
      counts[role] = (counts[role] ?? 0) + 1;
    }
    return counts;
  }

  /// Get admin users
  List<Map<String, dynamic>> getAdminUsers() {
    return _allUsers.where((user) => user['role'] == DefaultRoles.adminRole).toList();
  }

  /// Get regular users
  List<Map<String, dynamic>> getRegularUsers() {
    return _allUsers.where((user) => user['role'] == DefaultRoles.userRole).toList();
  }

  /// Search users by name or email
  List<Map<String, dynamic>> searchUsers(String query) {
    if (query.isEmpty) return _allUsers;
    
    final lowercaseQuery = query.toLowerCase();
    return _allUsers.where((user) {
      final name = (user['name'] ?? '').toString().toLowerCase();
      final email = (user['email'] ?? '').toString().toLowerCase();
      return name.contains(lowercaseQuery) || email.contains(lowercaseQuery);
    }).toList();
  }

  /// Filter users by role
  List<Map<String, dynamic>> filterUsersByRole(String role) {
    return _allUsers.where((user) => user['role'] == role).toList();
  }
}