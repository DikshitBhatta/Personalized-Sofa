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
      print('🚀 Initializing FCM v1 Service...');
      
      // Initialize local notifications
      await _initializeLocalNotifications();
      
      // Request permissions
      await _requestPermissions();
      
      // Get and store FCM token
      await _handleTokenRefresh();
      
      // Set up token refresh listener
      _messaging.onTokenRefresh.listen(_onTokenRefresh);
      
      // Handle foreground messages
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
      
      // Handle background message taps
      FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageTap);
      
      // Handle app launch from terminated state
      _messaging.getInitialMessage().then((message) {
        if (message != null) {
          _handleMessageTap(message);
        }
      });
      
      print('✅ FCM v1 Service initialized successfully');
      
    } catch (e) {
      print('❌ FCM v1 Service initialization failed: $e');
    }
  }

  /// Initialize local notifications
  Future<void> _initializeLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
    );
    
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    
    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onLocalNotificationTap,
    );

    // Create Android notification channel
    const androidChannel = AndroidNotificationChannel(
      'timberr_notifications',
      'Timberr Notifications',
      description: 'Notifications for Timberr app',
      importance: Importance.high,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChannel);
  }

  /// Request FCM permissions
  Future<void> _requestPermissions() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );
    
    print('📱 FCM Permission status: ${settings.authorizationStatus}');
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
      
      final scopes = ['https://www.googleapis.com/auth/cloud-platform'];
      
      print('🌐 Requesting OAuth2 token with scopes: $scopes');
      _credentials = await obtainAccessCredentialsViaServiceAccount(
        accountCredentials,
        scopes,
        Client(),
      );
      
      _tokenExpiry = DateTime.now().add(
        Duration(seconds: _credentials!.accessToken.expiry.millisecondsSinceEpoch)
      );
      
      print('✅ New credentials obtained (expires: $_tokenExpiry)');
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
      
      // Try to send FCM notification
      print('📱 Step 2: Sending push notification via FCM...');
      bool fcmSent = false;
      try {
        fcmSent = await _sendFCMMessage(fcmToken, title, body, type, data ?? {});
        if (fcmSent) {
          print('✅ Push notification sent successfully!');
        } else {
          print('❌ Push notification failed to send');
        }
      } catch (e) {
        print('⚠️  FCM sending error: $e');
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
      print('✅ Notification stored in Firestore');
      
      // For development: Send local notification if user is current user
      final currentUser = _auth.currentUser;
      if (currentUser != null && currentUser.uid == targetUserId) {
        print('🔔 Step 4: Showing local notification (user is current user)...');
        await _showLocalNotification(RemoteMessage(
          notification: RemoteNotification(title: title, body: body),
          data: {
            'type': type.name,
            'user_id': targetUserId,
            ...?data,
          },
        ));
        print('✅ Local notification shown');
      }
      
      print('📊 Summary: FCM Push: $fcmSent, Firestore: true, Local: ${currentUser?.uid == targetUserId}');
      print('✅ ========== NOTIFICATION COMPLETE ==========');
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
            'notification': {
              'channel_id': 'timberr_notifications',
              'priority': 'high',
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
      print('📡 FCM Endpoint: ${FirebaseConfig.fcmEndpoint}');

      print('🚀 Step C: Sending to FCM API...');
      // Send the notification using FCM v1 API
      final response = await Dio().post(
        FirebaseConfig.fcmEndpoint,
        data: jsonEncode(message),
        options: Options(
          headers: {
            'Authorization': 'Bearer ${credentials.accessToken.data}',
            'Content-Type': 'application/json; UTF-8',
          },
        ),
      );

      print('📥 Response Status: ${response.statusCode}');
      if (response.statusCode == 200) {
        print('✅ FCM notification sent successfully');
        print('📋 Response: ${response.data}');
        return true;
      } else {
        print('❌ FCM failed with status: ${response.statusCode}');
        print('📋 Response: ${response.data}');
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
      final token = await _messaging.getToken();
      if (token != null) {
        await _saveTokenToFirestore(token);
      }
    } catch (e) {
      print('❌ Error handling token refresh: $e');
    }
  }

  /// Save FCM token to Firestore
  Future<void> _saveTokenToFirestore(String token) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;
      
      final tokenModel = FCMTokenModel(
        userId: user.uid,
        token: token,
        updatedAt: DateTime.now(),
        platform: Platform.isIOS ? 'ios' : 'android',
      );
      
      await _firestore
          .collection('fcm_tokens')
          .doc(user.uid)
          .set(tokenModel.toJson());
          
      print('✅ FCM token saved to Firestore');
      
    } catch (e) {
      print('❌ Error saving FCM token: $e');
    }
  }

  /// Handle token refresh events
  void _onTokenRefresh(String token) {
    _saveTokenToFirestore(token);
  }

  /// Handle foreground messages
  void _handleForegroundMessage(RemoteMessage message) {
    print('📱 Received foreground message: ${message.messageId}');
    
    // Show local notification
    _showLocalNotification(message);
  }

  /// Handle message tap events
  void _handleMessageTap(RemoteMessage message) {
    print('👆 Message tapped: ${message.messageId}');
    
    // Navigate based on notification type
    _handleNotificationNavigation(message.data);
  }

  /// Show local notification
  Future<void> _showLocalNotification(RemoteMessage message) async {
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
    
    await _localNotifications.show(
      message.hashCode,
      message.notification?.title ?? 'Timberr',
      message.notification?.body ?? 'You have a new notification',
      details,
      payload: jsonEncode(message.data),
    );
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
    // Implement navigation logic based on notification type
    final type = data['type'] as String?;
    
    switch (type) {
      case 'conciergeBooking':
      case 'conciergeConfirmation':
      case 'conciergeRejection':
        // Navigate to concierge management or booking details
        Get.toNamed('/notifications');
        break;
      case 'orderUpdate':
        // Navigate to order details
        Get.toNamed('/orders');
        break;
      default:
        // Navigate to notification screen
        Get.toNamed('/notifications');
        break;
    }
  }
}