import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timberr/controllers/home_controller.dart';
import 'package:timberr/controllers/favorites_controller.dart';
import 'package:timberr/controllers/cart_controller.dart';
import 'package:timberr/controllers/user_controller.dart';
import 'package:timberr/controllers/address_controller.dart';
import 'package:timberr/controllers/card_details_controller.dart';
import 'package:timberr/role/role_controller.dart';
import 'package:timberr/services/init_services.dart';
import 'package:timberr/routes/app_routes.dart';

/// Controller for Splash Screen with Smart Caching
/// Implements stale-while-revalidate pattern for optimal startup performance
class SplashController extends GetxController {
  // Observable for loading state
  final RxBool isLoading = true.obs;
  final RxString loadingMessage = 'Initializing...'.obs;
  final RxDouble loadingProgress = 0.0.obs;

  // Track if this is a returning user with cached data
  bool _isReturningUser = false;
  bool _usedFastPath = false;

  @override
  void onInit() {
    super.onInit();
    print('🎬 SplashController: onInit called');
  }

  @override
  void onReady() {
    super.onReady();
    print('🚀 SplashController: onReady called');
    _initializeApp();
  }

  /// Initialize app with smart caching strategy
  /// Fast path: <1.5s for returning users with cache
  /// Slow path: ~3-5s for fresh load
  Future<void> _initializeApp() async {
    final startTime = DateTime.now();
    
    try {
      print('� SplashController: Starting smart initialization...');
      
      // Check if user has cached data
      final prefs = await SharedPreferences.getInstance();
      final hasCachedUser = prefs.getString('cached_user_uid') != null;
      final hasCachedRole = prefs.getString('cached_user_role') != null;
      _isReturningUser = hasCachedUser && hasCachedRole;
      
      print('📊 Cache status: returning user = $_isReturningUser');
      
      if (_isReturningUser) {
        // FAST PATH: Use cached data, refresh in background
        await _fastPathInitialization();
      } else {
        // SLOW PATH: Fresh load everything
        await _slowPathInitialization();
      }
      
      final duration = DateTime.now().difference(startTime);
      print('✅ Initialization complete in ${duration.inMilliseconds}ms (fast path: $_usedFastPath)');
      
      // Navigate to home
      loadingMessage.value = 'Ready!';
      loadingProgress.value = 1.0;
      Get.offAllNamed(AppRoutes.home);
      
    } catch (e, stackTrace) {
      print('❌ Critical error during initialization: $e');
      print('Stack trace: $stackTrace');
      
      // Fallback: Navigate anyway with degraded functionality
      Get.offAllNamed(AppRoutes.home);
    } finally {
      isLoading.value = false;
    }
  }

  /// Fast path for returning users - use cached data immediately
  /// Target: <1.5s to home screen
  Future<void> _fastPathInitialization() async {
    print('🚀 FAST PATH: Using cached data');
    _usedFastPath = true;
    
    loadingMessage.value = 'Welcome back!';
    loadingProgress.value = 0.2;
    
    try {
      // Get Phase 0 services (already initialized)
      final roleService = Get.find<RoleServiceInitializer>();
      
      // Step 1: Use cached role immediately
      if (roleService.cachedRole != null) {
        final roleController = Get.find<RoleController>();
        await roleController.setRoleFromCache(roleService.cachedRole!);
        print('✅ Role loaded from cache: ${roleService.cachedRole}');
      }
      
      loadingProgress.value = 0.4;
      
      // Step 2: Initialize controllers (lazy binding will handle this)
      loadingMessage.value = 'Loading your data...';
      
      // Get controller instances
      final homeController = Get.find<HomeController>();
      final userController = Get.find<UserController>();
      final favoritesController = Get.find<FavoritesController>();
      final cartController = Get.find<CartController>();
      
      loadingProgress.value = 0.6;
      
      // Step 3: Load critical data with timeout (fast fail if network slow)
      await Future.wait([
        userController.fetchUserData(),
        homeController.getProducts(0),
        favoritesController.fetchFavorites(),
        cartController.fetchCartItems(),
      ]).timeout(
        const Duration(milliseconds: 1500),
        onTimeout: () {
          print('⚠️ Fast path timeout - continuing with partial data');
          return [];
        },
      );
      
      loadingProgress.value = 0.9;
      
      // Step 4: Complete background tasks asynchronously (don't await)
      _completeBackgroundTasks();
      
      print('✅ Fast path complete');
      
    } catch (e) {
      print('⚠️ Fast path error: $e - falling back to slow path');
      await _slowPathInitialization();
    }
  }

  /// Slow path for new users - fresh load everything
  /// Target: ~3-5s to home screen with full data
  Future<void> _slowPathInitialization() async {
    print('🐌 SLOW PATH: Fresh load');
    _usedFastPath = false;
    
    loadingMessage.value = 'Setting up your account...';
    loadingProgress.value = 0.2;
    
    // Get controller instances
    final homeController = Get.find<HomeController>();
    final userController = Get.find<UserController>();
    final favoritesController = Get.find<FavoritesController>();
    final cartController = Get.find<CartController>();
    final addressController = Get.find<AddressController>();
    final cardDetailsController = Get.find<CardDetailsController>();
    
    // Step 1: Load user data first (critical)
    loadingMessage.value = 'Loading your profile...';
    await userController.fetchUserData();
    loadingProgress.value = 0.4;
    
    // Step 2: Load all other data in parallel
    loadingMessage.value = 'Loading your data...';
    await Future.wait([
      homeController.getProducts(0).catchError((e) {
        print('⚠️ Error loading products: $e');
        return;
      }),
      favoritesController.fetchFavorites().catchError((e) {
        print('⚠️ Error loading favorites: $e');
        return;
      }),
      cartController.fetchCartItems().catchError((e) {
        print('⚠️ Error loading cart: $e');
        return;
      }),
      cardDetailsController.getDefaultCardDetail().catchError((e) {
        print('⚠️ Error loading card details: $e');
        return;
      }),
      addressController.getDefaultShippingAddress().catchError((e) {
        print('⚠️ Error loading address: $e');
        return;
      }),
    ]);
    
    loadingProgress.value = 0.9;
    print('✅ Slow path complete');
  }

  /// Complete non-critical tasks in background (don't block navigation)
  void _completeBackgroundTasks() {
    print('🔄 Starting background tasks...');
    
    // Run these asynchronously without blocking navigation
    Future.microtask(() async {
      try {
        final addressController = Get.find<AddressController>();
        final cardDetailsController = Get.find<CardDetailsController>();
        final roleController = Get.isRegistered<RoleController>()
            ? Get.find<RoleController>()
            : Get.put(RoleController(), permanent: true);
        
        // Load secondary data - with optional notification service
        final tasks = [
          addressController.getDefaultShippingAddress().catchError((e) {
            print('⚠️ Background: Error loading address: $e');
            return;
          }),
          cardDetailsController.getDefaultCardDetail().catchError((e) {
            print('⚠️ Background: Error loading card details: $e');
            return;
          }),
          roleController.fetchUserRole().catchError((e) {
            print('⚠️ Background: Error refreshing role: $e');
            return;
          }),
        ];
        
        // Add notification task only if service is available
        if (Get.isRegistered<NotificationServiceInitializer>()) {
          final notificationService = Get.find<NotificationServiceInitializer>();
          tasks.add(
            notificationService.completeInitialization().catchError((e) {
              print('⚠️ Background: Error completing notification setup: $e');
              return;
            }),
          );
        }
        
        await Future.wait(tasks);
        
        print('✅ Background tasks complete');
      } catch (e) {
        print('⚠️ Background tasks error: $e');
      }
    });
  }

  @override
  void onClose() {
    print('👋 SplashController: onClose called');
    super.onClose();
  }
}
