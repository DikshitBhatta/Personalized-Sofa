import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timberr/role/role_access.dart';
import 'package:timberr/Notification/services/notification_service.dart';

/// Phase 0 Services - Critical, fast initialization before app starts
/// These services are optimized for startup performance with caching

/// Auth Service - handles Firebase Auth state with caching
class AuthServiceInitializer extends GetxService {
  User? _cachedUser;
  bool _isInitialized = false;

  Future<AuthServiceInitializer> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedUid = prefs.getString('cached_user_uid');
      
      // Listen to auth state changes
      FirebaseAuth.instance.authStateChanges().listen((User? user) {
        _cachedUser = user;
        if (user != null) {
          prefs.setString('cached_user_uid', user.uid);
        } else {
          prefs.remove('cached_user_uid');
        }
      });

      // Get current user immediately (fast, usually cached by Firebase)
      _cachedUser = FirebaseAuth.instance.currentUser;
      _isInitialized = true;
      
      print('✅ Auth Service initialized (cached: ${cachedUid != null})');
    } catch (e) {
      print('⚠️ Auth Service initialization failed: $e');
      _isInitialized = true;
    }
    return this;
  }

  User? get currentUser => _cachedUser;
  bool get isInitialized => _isInitialized;
}

/// Role Service - handles role-based access control with caching
class RoleServiceInitializer extends GetxService {
  String? _cachedRole;
  bool _isInitialized = false;

  Future<RoleServiceInitializer> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _cachedRole = prefs.getString('cached_user_role');
      
      // Initialize role system (sets up controllers)
      await RoleBasedAccessControl.initializeRoleSystem();
      
      _isInitialized = true;
      print('✅ Role Service initialized (cached role: ${_cachedRole ?? "none"})');
    } catch (e) {
      print('⚠️ Role Service initialization failed: $e');
      _isInitialized = true;
    }
    return this;
  }

  String? get cachedRole => _cachedRole;
  bool get isInitialized => _isInitialized;
}

/// Notification Service - handles push notifications with fast permission check
class NotificationServiceInitializer extends GetxService {
  late final NotificationService _notificationService;
  bool _isInitialized = false;
  bool _isFullyInitialized = false;

  Future<NotificationServiceInitializer> init() async {
    try {
      print('📱 ========== NOTIFICATION SERVICE INITIALIZER ==========');
      _notificationService = NotificationService();
      
      // Phase 0: Only check permission status (fast, non-blocking)
      print('   ⚡ Phase 0: Quick permission check...');
      final hasPermission = await _notificationService.checkPermissionStatus();
      
      _isInitialized = true;
      print('   ✅ Phase 0 complete (permission: $hasPermission)');
      
      // If user is already logged in, complete initialization immediately
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        print('   👤 User already logged in: ${currentUser.email}');
        print('   🚀 Starting full initialization in background...');
        completeInitialization();
      } else {
        print('   ℹ️  No user logged in yet, will complete initialization after login');
      }
      
      print('========================================================');
    } catch (e, stackTrace) {
      print('⚠️ Notification Service initialization failed: $e');
      print('Stack trace: $stackTrace');
      _isInitialized = true;
    }
    return this;
  }

  NotificationService get service => _notificationService;
  bool get isInitialized => _isInitialized;
  bool get isFullyInitialized => _isFullyInitialized;
  
  /// Complete full initialization in background (token fetch, etc.)
  Future<void> completeInitialization() async {
    if (_isFullyInitialized) {
      print('   ℹ️  Notification service already fully initialized');
      return;
    }
    
    try {
      print('🔔 ========== COMPLETING NOTIFICATION INITIALIZATION ==========');
      await _notificationService.initialize();
      _isFullyInitialized = true;
      print('✅ Notification Service fully initialized');
      print('===============================================================');
    } catch (e, stackTrace) {
      print('⚠️ Notification Service full initialization failed: $e');
      print('Stack trace: $stackTrace');
    }
  }
}

/// Initialize Phase 0 services before app starts
/// These are critical services that must be ready for the first frame
/// Optimized for speed - only essential blocking operations
Future<void> initServices() async {
  print('🚀 Phase 0: Initializing critical services...');
  
  final startTime = DateTime.now();
  
  try {
    // Initialize services with timeout protection
    await Future.wait([
      Get.putAsync(() => AuthServiceInitializer().init()),
      Get.putAsync(() => RoleServiceInitializer().init()),
      Get.putAsync(() => NotificationServiceInitializer().init()),
    ]).timeout(
      const Duration(seconds: 3),
      onTimeout: () {
        print('⚠️ Service initialization timeout - continuing with partial services');
        return [];
      },
    );
    
    final duration = DateTime.now().difference(startTime);
    print('✅ Phase 0 complete in ${duration.inMilliseconds}ms');
  } catch (e) {
    print('⚠️ Service initialization error: $e');
    print('📋 App will continue with degraded functionality');
  }
}
