import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:timberr/role/role_access.dart';
import 'package:timberr/role/role_service.dart';

/// Debug utility for the role system
class RoleDebugger {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Test the role system with comprehensive checks
  static Future<void> runRoleSystemTest() async {
    print('\n🧪 === ROLE SYSTEM DEBUG TEST ===');
    
    try {
      // 1. Check Firebase connection
      print('\n1. 📱 Testing Firebase Connection...');
      final currentUser = _auth.currentUser;
      if (currentUser != null) {
        print('✅ User authenticated: ${currentUser.email}');
        print('📋 User ID: ${currentUser.uid}');
      } else {
        print('❌ No user authenticated');
        return;
      }

      // 2. Test Firestore access
      print('\n2. 🔥 Testing Firestore Access...');
      try {
        await _firestore.collection('test').doc('connection').get();
        print('✅ Firestore connection successful');
      } catch (e) {
        print('❌ Firestore connection failed: $e');
      }

      // 3. Test role retrieval
      print('\n3. 🎭 Testing Role Retrieval...');
      try {
        final role = await RoleBasedAccessControl.getCurrentUserRole();
        print('✅ Current user role: $role');
        
        final isAdmin = await RoleBasedAccessControl.isCurrentUserAdmin();
        print('👑 Is admin: $isAdmin');
        
        final permissions = await RoleBasedAccessControl.getCurrentUserPermissions();
        print('🎫 Permissions count: ${permissions.length}');
      } catch (e) {
        print('❌ Role retrieval failed: $e');
      }

      // 4. Test user document
      print('\n4. 👤 Testing User Document...');
      try {
        final userDoc = await _firestore.collection('users').doc(currentUser.uid).get();
        if (userDoc.exists) {
          final userData = userDoc.data()!;
          print('✅ User document exists');
          print('📋 Name: ${userData['name']}');
          print('📧 Email: ${userData['email']}');
          print('🏷️ Role: ${userData['role']}');
        } else {
          print('❌ User document does not exist');
        }
      } catch (e) {
        print('❌ User document check failed: $e');
      }

      // 5. Test user_roles document
      print('\n5. 🎯 Testing User Roles Document...');
      try {
        final roleDoc = await _firestore.collection('user_roles').doc(currentUser.uid).get();
        if (roleDoc.exists) {
          final roleData = roleDoc.data()!;
          print('✅ User roles document exists');
          print('🏷️ Role name: ${roleData['role_name']}');
          print('👤 Assigned by: ${roleData['assigned_by']}');
          print('📅 Assigned at: ${roleData['assigned_at']}');
          print('✅ Is active: ${roleData['is_active']}');
        } else {
          print('❌ User roles document does not exist');
        }
      } catch (e) {
        print('❌ User roles document check failed: $e');
      }

      // 6. Test roles collection
      print('\n6. 📚 Testing Roles Collection...');
      try {
        final rolesSnapshot = await _firestore.collection('roles').get();
        print('✅ Roles collection exists');
        print('📋 Number of roles: ${rolesSnapshot.docs.length}');
        for (final doc in rolesSnapshot.docs) {
          final roleData = doc.data();
          print('  🎭 Role: ${roleData['name']} (${roleData['permissions']?.length ?? 0} permissions)');
        }
      } catch (e) {
        print('❌ Roles collection check failed: $e');
      }

      print('\n✅ === ROLE SYSTEM TEST COMPLETED ===\n');
      
    } catch (e) {
      print('❌ Role system test failed: $e');
    }
  }

  /// Fix common role system issues
  static Future<void> fixRoleSystemIssues() async {
    print('\n🔧 === FIXING ROLE SYSTEM ISSUES ===');
    
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      print('❌ No user authenticated');
      return;
    }

    try {
      // 1. Ensure user document has role
      print('\n1. 🔧 Ensuring user document has role...');
      final userDoc = await _firestore.collection('users').doc(currentUser.uid).get();
      if (userDoc.exists) {
        final userData = userDoc.data()!;
        if (userData['role'] == null) {
          await _firestore.collection('users').doc(currentUser.uid).update({
            'role': 'user',
            'role_assigned_at': DateTime.now().toIso8601String(),
            'role_assigned_by': 'system_fix',
          });
          print('✅ Added role to user document');
        } else {
          print('✅ User document already has role: ${userData['role']}');
        }
      }

      // 2. Ensure user_roles document exists
      print('\n2. 🔧 Ensuring user_roles document exists...');
      final roleDoc = await _firestore.collection('user_roles').doc(currentUser.uid).get();
      if (!roleDoc.exists) {
        await RoleService.assignDefaultUserRole(currentUser.uid, currentUser.email ?? 'unknown');
        print('✅ Created user_roles document');
      } else {
        print('✅ User_roles document already exists');
      }

      // 3. Initialize default roles
      print('\n3. 🔧 Ensuring default roles exist...');
      await RoleService.initializeDefaultRoles();
      print('✅ Default roles initialized');

      print('\n✅ === ROLE SYSTEM FIXES COMPLETED ===\n');
      
    } catch (e) {
      print('❌ Role system fix failed: $e');
    }
  }

  /// Create a test admin user (for development only)
  static Future<void> makeCurrentUserAdmin() async {
    print('\n👑 === MAKING CURRENT USER ADMIN ===');
    
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      print('❌ No user authenticated');
      return;
    }

    try {
      // Update user document
      await _firestore.collection('users').doc(currentUser.uid).update({
        'role': 'admin',
        'role_assigned_at': DateTime.now().toIso8601String(),
        'role_assigned_by': 'debug_utility',
      });

      // Update user_roles document
      await _firestore.collection('user_roles').doc(currentUser.uid).set({
        'user_id': currentUser.uid,
        'user_email': currentUser.email,
        'role_name': 'admin',
        'assigned_by': 'debug_utility',
        'assigned_at': DateTime.now().toIso8601String(),
        'is_active': true,
      });

      // Log the change
      await _firestore.collection('role_change_logs').add({
        'user_id': currentUser.uid,
        'user_email': currentUser.email,
        'old_role': 'user',
        'new_role': 'admin',
        'changed_by': 'debug_utility',
        'changed_at': DateTime.now().toIso8601String(),
        'timestamp': FieldValue.serverTimestamp(),
      });

      print('✅ User ${currentUser.email} is now an admin');
      print('🔄 Please restart the app or refresh to see changes');
      
    } catch (e) {
      print('❌ Failed to make user admin: $e');
    }
  }

  /// Remove admin role from current user
  static Future<void> makeCurrentUserRegular() async {
    print('\n👤 === MAKING CURRENT USER REGULAR ===');
    
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      print('❌ No user authenticated');
      return;
    }

    try {
      // Update user document
      await _firestore.collection('users').doc(currentUser.uid).update({
        'role': 'user',
        'role_assigned_at': DateTime.now().toIso8601String(),
        'role_assigned_by': 'debug_utility',
      });

      // Update user_roles document
      await _firestore.collection('user_roles').doc(currentUser.uid).set({
        'user_id': currentUser.uid,
        'user_email': currentUser.email,
        'role_name': 'user',
        'assigned_by': 'debug_utility',
        'assigned_at': DateTime.now().toIso8601String(),
        'is_active': true,
      });

      print('✅ User ${currentUser.email} is now a regular user');
      print('🔄 Please restart the app or refresh to see changes');
      
    } catch (e) {
      print('❌ Failed to make user regular: $e');
    }
  }

  /// Print current role status
  static Future<void> printCurrentStatus() async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      print('❌ No user authenticated');
      return;
    }

    print('\n📊 === CURRENT ROLE STATUS ===');
    print('👤 User: ${currentUser.email}');
    print('🆔 UID: ${currentUser.uid}');
    
    try {
      final role = await RoleBasedAccessControl.getCurrentUserRole();
      final isAdmin = await RoleBasedAccessControl.isCurrentUserAdmin();
      final permissions = await RoleBasedAccessControl.getCurrentUserPermissions();
      
      print('🏷️ Role: $role');
      print('👑 Is Admin: $isAdmin');
      print('🎫 Permissions: ${permissions.length}');
      
      if (permissions.isNotEmpty) {
        print('\n📋 Permission List:');
        for (final permission in permissions) {
          print('  ✓ $permission');
        }
      }
      
    } catch (e) {
      print('❌ Error getting role status: $e');
    }
    
    print('================================\n');
  }
}