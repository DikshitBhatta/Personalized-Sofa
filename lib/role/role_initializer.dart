import 'package:timberr/role/role_access.dart';

/// Initialize the role-based access control system
/// Call this method once during app startup (preferably in main.dart)
class RoleSystemInitializer {
  
  /// Initialize the role system
  /// This should be called once during app startup
  static Future<void> initialize() async {
    try {
      print('🔧 Initializing Role-Based Access Control System...');
      
      // Initialize default roles in Firestore
      await RoleBasedAccessControl.initializeRoleSystem();
      
      print('✅ Role system initialized successfully');
      print('📋 Available roles: user, admin');
      print('🔑 Default permissions configured');
      print('📊 Audit logging enabled');
      
    } catch (e) {
      print('❌ Failed to initialize role system: $e');
      throw Exception('Role system initialization failed: $e');
    }
  }

  /// Verify role system is working correctly
  static Future<bool> verifySystem() async {
    try {
      print('🔍 Verifying role system...');
      
      // Check if current user has a role assigned
      final currentUserRole = await RoleBasedAccessControl.getCurrentUserRole();
      print('👤 Current user role: $currentUserRole');
      
      // Check if current user is authenticated
      final isAuthenticated = RoleBasedAccessControl.isUserAuthenticated();
      print('🔐 User authenticated: $isAuthenticated');
      
      if (isAuthenticated) {
        // Check current user permissions
        final permissions = await RoleBasedAccessControl.getCurrentUserPermissions();
        print('🎫 User permissions: ${permissions.length} permissions');
        
        // Check if user can perform basic actions
        final canViewProducts = await RoleBasedAccessControl.hasPermission('view_products');
        print('🛍️ Can view products: $canViewProducts');
        
        // Check admin status
        final isAdmin = await RoleBasedAccessControl.isCurrentUserAdmin();
        print('👑 Is admin: $isAdmin');
        
        if (isAdmin) {
          final canManageUsers = await RoleBasedAccessControl.hasPermission('manage_users');
          print('👥 Can manage users: $canManageUsers');
        }
      }
      
      print('✅ Role system verification completed');
      return true;
      
    } catch (e) {
      print('❌ Role system verification failed: $e');
      return false;
    }
  }

  /// Print system status and statistics
  static Future<void> printSystemStatus() async {
    try {
      print('\n📊 === ROLE SYSTEM STATUS ===');
      
      final isAuthenticated = RoleBasedAccessControl.isUserAuthenticated();
      if (!isAuthenticated) {
        print('❌ No user authenticated');
        return;
      }
      
      final userId = RoleBasedAccessControl.getCurrentUserId();
      final userEmail = RoleBasedAccessControl.getCurrentUserEmail();
      final userRole = await RoleBasedAccessControl.getCurrentUserRole();
      final isAdmin = await RoleBasedAccessControl.isCurrentUserAdmin();
      final permissions = await RoleBasedAccessControl.getCurrentUserPermissions();
      
      print('👤 User ID: $userId');
      print('📧 Email: $userEmail');
      print('🏷️ Role: $userRole');
      print('👑 Admin: $isAdmin');
      print('🎫 Permissions: ${permissions.length}');
      
      print('\n🔑 User Permissions:');
      for (final permission in permissions) {
        print('  ✓ $permission');
      }
      
      if (isAdmin) {
        print('\n👑 Admin Capabilities:');
        print('  ✓ Manage users');
        print('  ✓ View all orders');
        print('  ✓ Access admin dashboard');
        print('  ✓ Manage products');
        print('  ✓ View analytics');
        print('  ✓ Manage concierge');
        print('  ✓ Manage deliveries');
      }
      
      print('================================\n');
      
    } catch (e) {
      print('❌ Failed to print system status: $e');
    }
  }

  /// Quick setup guide for developers
  static void printSetupGuide() {
    print('\n📖 === ROLE SYSTEM SETUP GUIDE ===');
    print('');
    print('1. 🚀 Initialize the system in main.dart:');
    print('   await RoleSystemInitializer.initialize();');
    print('');
    print('2. 🎯 Initialize RoleController in your app wrapper:');
    print('   Get.lazyPut(() => RoleController(), fenix: true);');
    print('');
    print('3. 🔐 Check permissions in your widgets:');
    print('   PermissionGuard(adminOnly: true, child: AdminButton())');
    print('');
    print('4. 🎫 Check permissions programmatically:');
    print('   if (await RoleBasedAccessControl.hasPermission("manage_users")) {');
    print('     // Show admin features');
    print('   }');
    print('');
    print('5. 👑 Assign admin role (from Firestore console):');
    print('   Update user document: {"role": "admin"}');
    print('   Or use UserManagementScreen in admin dashboard');
    print('');
    print('6. 📊 Monitor role changes:');
    print('   Check "role_change_logs" collection in Firestore');
    print('');
    print('🔗 For more details, see: lib/role/ROLE_SYSTEM_SUMMARY.md');
    print('==================================\n');
  }
}