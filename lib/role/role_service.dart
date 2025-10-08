import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:timberr/role/role_model.dart';

/// Service class to handle role-based operations in Firestore
class RoleService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Initialize default roles in Firestore (call this once during app setup)
  static Future<void> initializeDefaultRoles() async {
    try {
      print('🔧 Initializing default roles in Firestore...');
      final rolesCollection = _firestore.collection('roles');
      
      for (UserRole role in DefaultRoles.allRoles) {
        print('📝 Creating role: ${role.name}');
        await rolesCollection.doc(role.id).set(role.toJson(), SetOptions(merge: true));
      }
      print('✅ Default roles initialized successfully');
    } catch (e) {
      print('❌ Error initializing default roles: $e');
      // Don't throw exception - allow app to continue with graceful degradation
      print('⚠️ App will continue with client-side role handling');
    }
  }

  /// Assign default user role to a new user
  static Future<void> assignDefaultUserRole(String userId, String userEmail) async {
    try {
      print('👤 Assigning default user role to: $userEmail');
      
      final userRoleAssignment = UserRoleAssignment(
        userId: userId,
        userEmail: userEmail,
        roleName: DefaultRoles.userRole,
        assignedBy: 'system',
        assignedAt: DateTime.now(),
      );

      // Try to create user_roles document
      await _firestore
          .collection('user_roles')
          .doc(userId)
          .set(userRoleAssignment.toJson());

      // Also update the user document with role information
      await _firestore.collection('users').doc(userId).update({
        'role': DefaultRoles.userRole,
        'role_assigned_at': DateTime.now().toIso8601String(),
      });
      
      print('✅ Successfully assigned user role to: $userEmail');
    } catch (e) {
      print('❌ Error assigning default user role to $userEmail: $e');
      
      // Try fallback: just update the user document
      try {
        await _firestore.collection('users').doc(userId).update({
          'role': DefaultRoles.userRole,
          'role_assigned_at': DateTime.now().toIso8601String(),
        });
        print('✅ Fallback: Updated role in users collection for: $userEmail');
      } catch (fallbackError) {
        print('❌ Fallback also failed for $userEmail: $fallbackError');
        print('⚠️ User will default to user role on login');
      }
    }
  }

  /// Get user's current role
  static Future<String> getUserRole(String userId) async {
    try {
      // First try to get from user_roles collection
      final userRoleDoc = await _firestore.collection('user_roles').doc(userId).get();
      
      if (userRoleDoc.exists) {
        final roleAssignment = UserRoleAssignment.fromJson(userRoleDoc.data()!);
        return roleAssignment.isActive ? roleAssignment.roleName : DefaultRoles.userRole;
      }
      
      // Fallback: check user document
      final userDoc = await _firestore.collection('users').doc(userId).get();
      if (userDoc.exists && userDoc.data()!['role'] != null) {
        final role = userDoc.data()!['role'];
        print('📋 Found role in users collection: $role for user $userId');
        return role;
      }
      
      print('⚠️ No role found for user $userId, defaulting to user role');
      return DefaultRoles.userRole;
    } catch (e) {
      print('❌ Error getting user role for $userId: $e');
      print('📝 Defaulting to user role due to error');
      return DefaultRoles.userRole;
    }
  }

  /// Get user's role by email
  static Future<String> getUserRoleByEmail(String email) async {
    try {
      final userQuery = await _firestore
          .collection('user_roles')
          .where('user_email', isEqualTo: email)
          .where('is_active', isEqualTo: true)
          .limit(1)
          .get();

      if (userQuery.docs.isNotEmpty) {
        final roleAssignment = UserRoleAssignment.fromJson(userQuery.docs.first.data());
        return roleAssignment.roleName;
      }

      return DefaultRoles.userRole;
    } catch (e) {
      print('Error getting user role by email: $e');
      return DefaultRoles.userRole;
    }
  }

  /// Assign admin role to a user (only callable by existing admin)
  static Future<bool> assignAdminRole(String targetUserId, String targetUserEmail) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      // Check if current user is admin
      final currentUserRole = await getUserRole(currentUser.uid);
      if (currentUserRole != DefaultRoles.adminRole) {
        throw Exception('Insufficient permissions: Only admins can assign roles');
      }

      // Get current user email for logging
      final currentUserDoc = await _firestore.collection('users').doc(currentUser.uid).get();
      final currentUserEmail = currentUserDoc.data()?['email'] ?? currentUser.email ?? 'unknown';

      final adminRoleAssignment = UserRoleAssignment(
        userId: targetUserId,
        userEmail: targetUserEmail,
        roleName: DefaultRoles.adminRole,
        assignedBy: currentUserEmail,
        assignedAt: DateTime.now(),
      );

      await _firestore
          .collection('user_roles')
          .doc(targetUserId)
          .set(adminRoleAssignment.toJson());

      // Update user document
      await _firestore.collection('users').doc(targetUserId).update({
        'role': DefaultRoles.adminRole,
        'role_assigned_at': DateTime.now().toIso8601String(),
        'role_assigned_by': currentUserEmail,
      });

      // Log the role change
      await _logRoleChange(targetUserId, targetUserEmail, DefaultRoles.userRole, DefaultRoles.adminRole, currentUserEmail);

      return true;
    } catch (e) {
      print('Error assigning admin role: $e');
      return false;
    }
  }

  /// Remove admin role and assign user role
  static Future<bool> removeAdminRole(String targetUserId, String targetUserEmail) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      // Check if current user is admin
      final currentUserRole = await getUserRole(currentUser.uid);
      if (currentUserRole != DefaultRoles.adminRole) {
        throw Exception('Insufficient permissions: Only admins can modify roles');
      }

      // Prevent admin from demoting themselves
      if (currentUser.uid == targetUserId) {
        throw Exception('Cannot demote yourself');
      }

      // Get current user email for logging
      final currentUserDoc = await _firestore.collection('users').doc(currentUser.uid).get();
      final currentUserEmail = currentUserDoc.data()?['email'] ?? currentUser.email ?? 'unknown';

      final userRoleAssignment = UserRoleAssignment(
        userId: targetUserId,
        userEmail: targetUserEmail,
        roleName: DefaultRoles.userRole,
        assignedBy: currentUserEmail,
        assignedAt: DateTime.now(),
      );

      await _firestore
          .collection('user_roles')
          .doc(targetUserId)
          .set(userRoleAssignment.toJson());

      // Update user document
      await _firestore.collection('users').doc(targetUserId).update({
        'role': DefaultRoles.userRole,
        'role_assigned_at': DateTime.now().toIso8601String(),
        'role_assigned_by': currentUserEmail,
      });

      // Log the role change
      await _logRoleChange(targetUserId, targetUserEmail, DefaultRoles.adminRole, DefaultRoles.userRole, currentUserEmail);

      return true;
    } catch (e) {
      print('Error removing admin role: $e');
      return false;
    }
  }

  /// Get all users with their roles (admin only)
  static Future<List<Map<String, dynamic>>> getAllUsersWithRoles() async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      // Check if current user is admin
      final currentUserRole = await getUserRole(currentUser.uid);
      if (currentUserRole != DefaultRoles.adminRole) {
        throw Exception('Insufficient permissions: Admin access required');
      }

      final usersSnapshot = await _firestore.collection('users').get();
      List<Map<String, dynamic>> usersWithRoles = [];

      for (QueryDocumentSnapshot userDoc in usersSnapshot.docs) {
        final userData = userDoc.data() as Map<String, dynamic>;
        final userRole = await getUserRole(userDoc.id);
        
        usersWithRoles.add({
          'user_id': userDoc.id,
          'name': userData['name'] ?? 'Unknown',
          'email': userData['email'] ?? 'Unknown',
          'role': userRole,
          'profile_picture_url': userData['profile_picture_url'],
          'created_at': userData['created_at'],
          'role_assigned_at': userData['role_assigned_at'],
          'role_assigned_by': userData['role_assigned_by'],
        });
      }

      return usersWithRoles;
    } catch (e) {
      print('Error getting all users with roles: $e');
      throw Exception('Failed to fetch users');
    }
  }

  /// Log role changes for audit purposes
  static Future<void> _logRoleChange(
    String userId,
    String userEmail,
    String oldRole,
    String newRole,
    String changedBy,
  ) async {
    try {
      await _firestore.collection('role_change_logs').add({
        'user_id': userId,
        'user_email': userEmail,
        'old_role': oldRole,
        'new_role': newRole,
        'changed_by': changedBy,
        'changed_at': DateTime.now().toIso8601String(),
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error logging role change: $e');
    }
  }

  /// Get role change history (admin only)
  static Future<List<Map<String, dynamic>>> getRoleChangeHistory({int limit = 50}) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      // Check if current user is admin
      final currentUserRole = await getUserRole(currentUser.uid);
      if (currentUserRole != DefaultRoles.adminRole) {
        throw Exception('Insufficient permissions: Admin access required');
      }

      final logsSnapshot = await _firestore
          .collection('role_change_logs')
          .orderBy('timestamp', descending: true)
          .limit(limit)
          .get();

      return logsSnapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      print('Error getting role change history: $e');
      throw Exception('Failed to fetch role change history');
    }
  }
}