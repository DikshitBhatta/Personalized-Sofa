import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:timberr/Notification/models/notification_model.dart';
import 'package:timberr/core/config/firebase_config.dart';
import 'package:get/get.dart';

class FCMv1Service {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  AccessCredentials? _credentials;
  DateTime? _tokenExpiry;

  // Singleton pattern
  static final FCMv1Service _instance = FCMv1Service._internal();
  factory FCMv1Service() => _instance;
  FCMv1Service._internal();

  /// Initialize the FCM service
  Future<void> initialize() async {
    try {
      print('🚀 ========== INITIALIZING FCM v1 SERVICE ==========');
      print('📱 Platform: ${Platform.isIOS ? "iOS" : "Android"}');
      
      // Initialize local notifications
      print('🔔 Step 1: Initializing local notifications...');
      await _initializeLocalNotifications();
      print('✅ Local notifications initialized');
      
      // Request permissions
      print('🔑 Step 2: Requesting notification permissions...');
      await _requestPermissions();
      
      // Get and store FCM token
      print('🎫 Step 3: Getting FCM token...');
      await _handleTokenRefresh();
      
      // Set up token refresh listener
      print('🔄 Step 4: Setting up token refresh listener...');
      _messaging.onTokenRefresh.listen(_onTokenRefresh);
      print('✅ Token refresh listener set up');
      
      // Handle foreground messages
      print('📥 Step 5: Setting up foreground message handler...');
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
      print('✅ Foreground message handler set up');
      
      // Handle background message taps
      print('👆 Step 6: Setting up background message tap handler...');
      FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageTap);
      print('✅ Background message tap handler set up');
      
      // Handle app launch from terminated state
      print('🚀 Step 7: Checking for initial message...');
      _messaging.getInitialMessage().then((message) {
        if (message != null) {
          print('📬 App launched from notification: ${message.messageId}');
          _handleMessageTap(message);
        } else {
          print('ℹ️  App launched normally (not from notification)');
        }
      });
      
      print('✅ ========== FCM v1 SERVICE INITIALIZED SUCCESSFULLY ==========');
      
    } catch (e, stackTrace) {
      print('❌ ========== FCM v1 SERVICE INITIALIZATION FAILED ==========');
      print('Error: $e');
      print('Stack trace: $stackTrace');
      print('=============================================================');
    }
  }

  /// Initialize local notifications
  Future<void> _initializeLocalNotifications() async {
    try {
      print('   📱 Setting up Android notification settings...');
      const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
      
      print('   🍎 Setting up iOS notification settings...');
      const iosSettings = DarwinInitializationSettings(
        requestSoundPermission: true,
        requestBadgePermission: true,
        requestAlertPermission: true,
      );
      
      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );
      
      print('   🔧 Initializing flutter_local_notifications...');
      final initialized = await _localNotifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _onLocalNotificationTap,
      );
      
      if (initialized == true) {
        print('   ✅ flutter_local_notifications initialized successfully');
      } else {
        print('   ⚠️  flutter_local_notifications initialization returned: $initialized');
      }

      // Create Android notification channel
      print('   📢 Creating Android notification channel...');
      const androidChannel = AndroidNotificationChannel(
        'timberr_notifications',
        'Timberr Notifications',
        description: 'Notifications for Timberr app',
        importance: Importance.high,
        playSound: true,
        enableVibration: true,
        showBadge: true,
      );

      final androidPlugin = _localNotifications
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      
      if (androidPlugin != null) {
        await androidPlugin.createNotificationChannel(androidChannel);
        print('   ✅ Android notification channel created: timberr_notifications');
      } else {
        print('   ⚠️  Could not create Android notification channel (not Android platform?)');
      }
    } catch (e, stackTrace) {
      print('   ❌ Error initializing local notifications: $e');
      print('   Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Request FCM permissions
  Future<void> _requestPermissions() async {
    try {
      print('   🔐 Requesting notification permissions...');
      final settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
        announcement: false,
        carPlay: false,
        criticalAlert: false,
      );
      
      print('   � Permission status: ${settings.authorizationStatus.name}');
      
      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        print('   ✅ User granted notification permissions');
      } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
        print('   📝 User granted provisional notification permissions');
      } else if (settings.authorizationStatus == AuthorizationStatus.denied) {
        print('   ❌ User denied notification permissions');
        print('   💡 To enable: Go to Settings > Apps > me sofa > Notifications');
      } else {
        print('   ⚠️  Notification permission status: ${settings.authorizationStatus.name}');
      }
      
      print('   🔔 Alert: ${settings.alert.name}');
      print('   🔊 Sound: ${settings.sound.name}');
      print('   🔴 Badge: ${settings.badge.name}');
    } catch (e, stackTrace) {
      print('   ❌ Error requesting permissions: $e');
      print('   Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Get current notification settings (for permission status check)
  Future<NotificationSettings> getNotificationSettings() async {
    return await _messaging.getNotificationSettings();
  }

  /// Get OAuth2 credentials for FCM v1 API
  Future<AccessCredentials?> _getAccessCredentials() async {
    try {
      print('🔐 Checking OAuth2 credentials...');
      
      if (_credentials != null && 
          _tokenExpiry != null && 
          DateTime.now().isBefore(_tokenExpiry!.subtract(const Duration(minutes: 5)))) {
        print('✅ Using cached credentials (valid until: $_tokenExpiry)');
        return _credentials!;
      }

      print('🔄 Obtaining new OAuth2 credentials...');
      
      // Use service account credentials from config
      // IMPORTANT: Only for development/testing - use backend server for production
      print('📄 Loading service account from FirebaseConfig...');
      final accountCredentials = ServiceAccountCredentials.fromJson(
        FirebaseConfig.serviceAccountKey
      );
      
      print('📧 Service Account Email: ${accountCredentials.email}');
      
      // ✅ FIXED: Use correct FCM v1 API scope
      final scopes = ['https://www.googleapis.com/auth/firebase.messaging'];
      
      print('🌐 Requesting OAuth2 token with scopes: $scopes');
      _credentials = await obtainAccessCredentialsViaServiceAccount(
        accountCredentials,
        scopes,
        Client(),
      );
      
      // Calculate correct token expiry
      // OAuth2 tokens typically expire in 1 hour (3600 seconds)
      _tokenExpiry = _credentials!.accessToken.expiry;
      
      print('✅ New credentials obtained');
      print('   Access Token: ${_credentials!.accessToken.data.substring(0, 30)}...');
      print('   Expires: $_tokenExpiry');
      if (_tokenExpiry != null) {
        print('   Time until expiry: ${_tokenExpiry!.difference(DateTime.now()).inMinutes} minutes');
      }
      
      return _credentials!;
      
    } catch (e, stackTrace) {
      print('❌ Failed to get access credentials: $e');
      print('📋 Stack trace: $stackTrace');
      print('💡 Make sure sofa.json file is properly loaded in FirebaseConfig');
      return null;
    }
  }

  /// Send notification using FCM v1 API
  Future<bool> sendNotification({
    required String targetUserId,
    required String title,
    required String body,
    required NotificationType type,
    Map<String, dynamic>? data,
  }) async {
    try {
      print('📤 ========== SENDING NOTIFICATION ==========');
      print('🎯 Target User ID: $targetUserId');
      print('📋 Title: $title');
      print('📋 Body: $body');
      print('📋 Type: ${type.name}');
      print('📋 Additional Data: ${data ?? "none"}');
      
      // Check if sending to current user
      final currentUser = _auth.currentUser;
      final isCurrentUser = currentUser != null && currentUser.uid == targetUserId;
      print('👤 Current User: ${currentUser?.uid ?? "not logged in"}');
      print('🎯 Is Target Current User: $isCurrentUser');
      
      // Get user's FCM token
      print('🔍 Step 1: Fetching FCM token from fcm_tokens collection...');
      final tokenDoc = await _firestore
          .collection('fcm_tokens')
          .doc(targetUserId)
          .get();
          
      if (!tokenDoc.exists) {
        print('⚠️  No FCM token document found for user: $targetUserId');
        print('💡 User may not have logged in or granted notification permissions');
        
        // Still store the notification for when user comes online
        print('💾 Step 2: Storing notification in Firestore for later...');
        await _storeNotification(
          userId: targetUserId,
          title: title,
          body: body,
          type: type,
          data: data ?? {},
        );
        print('✅ Notification stored in Firestore (user will see it when they log in)');
        print('============================================');
        return false;
      }
      
      final fcmToken = tokenDoc.data()!['token'] as String;
      print('✅ FCM token found: ${fcmToken.substring(0, 20)}...');
      print('   Platform: ${tokenDoc.data()!['platform'] ?? "unknown"}');
      print('   Last Updated: ${tokenDoc.data()!['updated_at'] ?? "unknown"}');
      print('   Token Length: ${fcmToken.length} characters');
      
      // Validate token format
      if (fcmToken.isEmpty || fcmToken.length < 100) {
        print('⚠️  WARNING: FCM token seems invalid (too short: ${fcmToken.length} chars)');
        print('   Expected length: ~152+ characters');
        print('   This token may be expired or corrupted');
      }
      
      // Try to send FCM notification
      print('📱 Step 2: Sending push notification via FCM...');
      bool fcmSent = false;
      try {
        fcmSent = await _sendFCMMessage(fcmToken, title, body, type, data ?? {});
        if (fcmSent) {
          print('✅ ✅ ✅ Push notification sent successfully via FCM!');
        } else {
          print('❌ ❌ ❌ Push notification failed to send via FCM');
        }
      } catch (e) {
        print('⚠️  FCM sending error: $e');
        print('   This means the notification was NOT delivered to the device');
      }
      
      // Always store notification in Firestore for persistence
      print('💾 Step 3: Storing notification in Firestore...');
      await _storeNotification(
        userId: targetUserId,
        title: title,
        body: body,
        type: type,
        data: data ?? {},
      );
      print('✅ Notification stored in Firestore (will appear in notification list)');
      
      // For current user: Show local notification immediately
      if (isCurrentUser) {
        print('🔔 Step 4: Target is current user - showing local notification NOW...');
        try {
          await _showLocalNotification(RemoteMessage(
            notification: RemoteNotification(title: title, body: body),
            data: {
              'type': type.name,
              'user_id': targetUserId,
              ...?data,
            },
          ));
          print('✅ Local notification shown to current user');
        } catch (e, stackTrace) {
          print('❌ Failed to show local notification: $e');
          print('   Stack trace: $stackTrace');
        }
      } else {
        print('ℹ️  Step 4: Skipped - Target user is not current user');
        print('   Notification will be delivered via FCM push to their device');
      }
      
      print('📊 Summary: FCM Push: $fcmSent, Firestore: ✅, Local: ${isCurrentUser ? "✅" : "N/A"}');
      print('✅ ========== NOTIFICATION PROCESS COMPLETE ==========');
      return true;
      
    } catch (e, stackTrace) {
      print('❌ ========== ERROR SENDING NOTIFICATION ==========');
      print('Error: $e');
      print('Stack trace: $stackTrace');
      print('===================================================');
      return false;
    }
  }

  /// Send FCM message using v1 API
  Future<bool> _sendFCMMessage(
    String token,
    String title,
    String body,
    NotificationType type,
    Map<String, dynamic> data,
  ) async {
    try {
      print('🔐 Step A: Getting OAuth2 access credentials...');
      
      // Get OAuth2 credentials
      final credentials = await _getAccessCredentials();
      if (credentials == null) {
        print('❌ Could not get access credentials');
        print('💡 Check if sofa.json file exists and is valid');
        return false;
      }
      
      print('✅ OAuth2 credentials obtained');
      print('🔑 Access Token: ${credentials.accessToken.data.substring(0, 30)}...');

      print('📝 Step B: Preparing FCM v1 message...');
      // Prepare FCM v1 message
      final message = {
        'message': {
          'token': token,
          'notification': {
            'title': title,
            'body': body,
          },
          'data': {
            'type': type.name,
            'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
            ...data.map((key, value) => MapEntry(key, value.toString())),
          },
          'android': {
            'priority': 'high', // ✅ FIXED: Moved priority to android level (not notification level)
            'notification': {
              'channel_id': 'timberr_notifications',
              'sound': 'default',
            },
          },
          'apns': {
            'payload': {
              'aps': {
                'alert': {
                  'title': title,
                  'body': body,
                },
                'badge': 1,
                'sound': 'default',
              },
            },
          },
        },
      };
      
      print('✅ Message prepared');
      print('� Message Preview:');
      print('   Token: ${token.substring(0, 30)}...');
      print('   Title: $title');
      print('   Body: $body');
      print('   Data keys: ${data.keys.join(", ")}');
      print('�📡 FCM Endpoint: ${FirebaseConfig.fcmEndpoint}');

      print('🚀 Step C: Sending to FCM API...');
      // Send the notification using FCM v1 API
      try {
        final response = await Dio().post(
          FirebaseConfig.fcmEndpoint,
          data: jsonEncode(message),
          options: Options(
            headers: {
              'Authorization': 'Bearer ${credentials.accessToken.data}',
              'Content-Type': 'application/json; UTF-8',
            },
            validateStatus: (status) => true, // Don't throw on any status code
          ),
        );

        print('📥 Response Status: ${response.statusCode}');
        
        if (response.statusCode == 200) {
          print('✅ FCM notification sent successfully');
          print('📋 Response: ${response.data}');
          return true;
        } else {
          print('❌ FCM failed with status: ${response.statusCode}');
          print('📋 Error Response: ${response.data}');
          print('📋 Full Response Body: ${jsonEncode(response.data)}');
          
          // Parse error details if available
          if (response.data is Map && response.data['error'] != null) {
            final error = response.data['error'];
            print('🔴 FCM Error Details:');
            print('   Code: ${error['code']}');
            print('   Message: ${error['message']}');
            print('   Status: ${error['status']}');
            if (error['details'] != null) {
              print('   Details: ${error['details']}');
            }
          }
          
          return false;
        }
      } on DioException catch (e) {
        print('❌ DioException sending to FCM: ${e.type}');
        print('📋 Error Message: ${e.message}');
        if (e.response != null) {
          print('📋 Response Status: ${e.response!.statusCode}');
          print('📋 Response Data: ${e.response!.data}');
        }
        return false;
      }

    } catch (e, stackTrace) {
      print('❌ Error sending FCM message: $e');
      print('📋 Stack trace: $stackTrace');
      
      // Provide helpful error messages
      if (e.toString().contains('INVALID_ARGUMENT')) {
        print('💡 Invalid FCM token or message format');
      } else if (e.toString().contains('UNAUTHENTICATED')) {
        print('💡 OAuth2 credentials expired or invalid');
      } else if (e.toString().contains('NOT_FOUND')) {
        print('💡 FCM token may have been unregistered');
      }
      
      return false;
    }
  }

  /// Store notification in Firestore
  Future<void> _storeNotification({
    required String userId,
    required String title,
    required String body,
    required NotificationType type,
    required Map<String, dynamic> data,
  }) async {
    try {
      final notification = NotificationModel(
        id: '', // Will be set by Firestore
        userId: userId,
        title: title,
        body: body,
        type: type,
        createdAt: DateTime.now(),
        data: data,
      );
      
      await _firestore
          .collection('notifications')
          .add(notification.toJson());
          
      print('✅ Notification stored in Firestore');
      
    } catch (e) {
      print('❌ Error storing notification: $e');
    }
  }

  /// Handle FCM token refresh
  Future<void> _handleTokenRefresh() async {
    try {
      print('   🎫 Getting FCM token...');
      final token = await _messaging.getToken();
      
      if (token != null) {
        print('   ✅ FCM Token obtained: ${token.substring(0, 50)}...');
        print('   📏 Token length: ${token.length} characters');
        await _saveTokenToFirestore(token);
      } else {
        print('   ❌ Failed to get FCM token (returned null)');
        print('   💡 This might happen if:');
        print('      1. App doesn\'t have notification permissions');
        print('      2. Google Play Services is not available');
        print('      3. Device is not connected to internet');
      }
    } catch (e, stackTrace) {
      print('   ❌ Error handling token refresh: $e');
      print('   Stack trace: $stackTrace');
    }
  }

  /// Save FCM token to Firestore
  Future<void> _saveTokenToFirestore(String token) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        print('   ⚠️  Cannot save FCM token: No user logged in');
        return;
      }
      
      print('   💾 Saving FCM token to Firestore...');
      print('   👤 User ID: ${user.uid}');
      print('   📧 User Email: ${user.email}');
      
      final tokenModel = FCMTokenModel(
        userId: user.uid,
        token: token,
        updatedAt: DateTime.now(),
        platform: Platform.isIOS ? 'ios' : 'android',
      );
      
      await _firestore
          .collection('fcm_tokens')
          .doc(user.uid)
          .set(tokenModel.toJson(), SetOptions(merge: true));
      
      print('   ✅ FCM token saved to Firestore successfully');
      print('   📍 Location: fcm_tokens/${user.uid}');
      
      // Verify the token was saved
      final savedDoc = await _firestore.collection('fcm_tokens').doc(user.uid).get();
      if (savedDoc.exists) {
        print('   ✅ Verified: Token document exists in Firestore');
      } else {
        print('   ⚠️  Warning: Could not verify token was saved');
      }
      
    } catch (e, stackTrace) {
      print('   ❌ Error saving FCM token to Firestore: $e');
      print('   Stack trace: $stackTrace');
      print('   💡 Check Firestore security rules and permissions');
    }
  }

  /// Handle token refresh events
  void _onTokenRefresh(String token) {
    print('🔄 FCM Token refreshed');
    print('   New token: ${token.substring(0, 50)}...');
    _saveTokenToFirestore(token);
  }

  /// Handle foreground messages
  void _handleForegroundMessage(RemoteMessage message) async {
    print('📱 ========== FOREGROUND MESSAGE RECEIVED ==========');
    print('   Message ID: ${message.messageId}');
    print('   Sent time: ${message.sentTime}');
    
    if (message.notification != null) {
      print('   ✅ Has notification payload:');
      print('      Title: ${message.notification!.title}');
      print('      Body: ${message.notification!.body}');
    } else {
      print('   ⚠️  NO notification payload (data-only message)');
    }
    
    if (message.data.isNotEmpty) {
      print('   ✅ Has data payload: ${message.data}');
    } else {
      print('   ⚠️  NO data payload');
    }
    
    print('   📢 Attempting to show local notification...');
    try {
      await _showLocalNotification(message);
      print('   ✅ Local notification shown successfully');
    } catch (e, stackTrace) {
      print('   ❌ Failed to show local notification: $e');
      print('   Stack trace: $stackTrace');
    }
    print('===================================================');
  }

  /// Handle message tap events
  void _handleMessageTap(RemoteMessage message) {
    print('👆 ========== NOTIFICATION TAPPED ==========');
    print('   Message ID: ${message.messageId}');
    
    if (message.notification != null) {
      print('   Title: ${message.notification!.title}');
      print('   Body: ${message.notification!.body}');
    }
    
    if (message.data.isNotEmpty) {
      print('   Data: ${message.data}');
    }
    
    print('   🚀 Navigating based on notification type...');
    _handleNotificationNavigation(message.data);
    print('============================================');
  }

  /// Show local notification
  Future<void> _showLocalNotification(RemoteMessage message) async {
    try {
      print('      🔔 Preparing local notification...');
      
      const androidDetails = AndroidNotificationDetails(
        'timberr_notifications',
        'Timberr Notifications',
        channelDescription: 'Notifications for Timberr app',
        importance: Importance.high,
        priority: Priority.high,
        showWhen: true,
      );
      
      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );
      
      const details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );
      
      final title = message.notification?.title ?? 'Timberr';
      final body = message.notification?.body ?? 'You have a new notification';
      final id = message.hashCode;
      
      print('      📋 Notification details:');
      print('         ID: $id');
      print('         Title: $title');
      print('         Body: $body');
      print('         Channel: timberr_notifications');
      
      await _localNotifications.show(
        id,
        title,
        body,
        details,
        payload: jsonEncode(message.data),
      );
      
      print('      ✅ Local notification displayed successfully');
      
    } catch (e, stackTrace) {
      print('      ❌ Error showing local notification: $e');
      print('      Stack trace: $stackTrace');
      throw e; // Re-throw to be caught by caller
    }
  }

  /// Handle local notification tap
  void _onLocalNotificationTap(NotificationResponse response) {
    if (response.payload != null) {
      final data = jsonDecode(response.payload!);
      _handleNotificationNavigation(data);
    }
  }

  /// Handle navigation based on notification data
  void _handleNotificationNavigation(Map<String, dynamic> data) {
    print('🧭 Navigation Handler - Data: $data');
    
    // Implement navigation logic based on notification type
    final type = data['type'] as String?;
    print('🧭 Notification Type: $type');
    
    switch (type) {
      case 'conciergeMessage':
        // Handle concierge chat message navigation
        final chatId = data['chat_id'] as String?;
        print('💬 Concierge message notification - Chat ID: $chatId');
        
        if (chatId != null && chatId.isNotEmpty) {
          print('🚀 Navigating to concierge chat screen...');
          // Import the screen at the top if needed
          // Navigate to user concierge chat screen
          try {
            Get.toNamed('/concierge-chat', arguments: {'chatId': chatId});
            print('✅ Navigation to concierge chat successful');
          } catch (e) {
            print('⚠️  Navigation failed, trying direct import: $e');
            // Fallback to notification screen if route doesn't exist
            Get.toNamed('/notifications');
          }
        } else {
          print('⚠️  No chat ID provided, navigating to notifications');
          Get.toNamed('/notifications');
        }
        break;
        
      case 'conciergeBooking':
      case 'conciergeConfirmation':
      case 'conciergeRejection':
        // Navigate to concierge management or booking details
        print('🏠 Concierge booking notification, navigating to notifications');
        Get.toNamed('/notifications');
        break;
        
      case 'orderUpdate':
        // Navigate to order details
        print('📦 Order update notification, navigating to orders');
        Get.toNamed('/orders');
        break;
        
      default:
        // Navigate to notification screen
        print('📢 Default notification, navigating to notifications');
        Get.toNamed('/notifications');
        break;
    }
  }
}