import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:timberr/constants.dart';
import 'package:timberr/Notification/controllers/notification_controller.dart';
import 'package:timberr/Notification/services/notification_service.dart';
import 'package:timberr/Notification/models/notification_model.dart';
import 'package:timberr/role/role_service.dart';

/// Debug screen to test notification functionality
/// Access this screen to test and debug notifications
class NotificationTestScreen extends StatefulWidget {
  const NotificationTestScreen({super.key});

  @override
  State<NotificationTestScreen> createState() => _NotificationTestScreenState();
}

class _NotificationTestScreenState extends State<NotificationTestScreen> {
  final NotificationController _controller = Get.put(NotificationController());
  final NotificationService _service = NotificationService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  bool _isLoading = false;
  final List<String> _logs = [];

  void _addLog(String log) {
    setState(() {
      _logs.insert(0, '[${DateTime.now().toString().substring(11, 19)}] $log');
      if (_logs.length > 50) _logs.removeLast();
    });
  }

  Future<void> _testSelfNotification() async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      _addLog('❌ No user logged in');
      return;
    }

    setState(() => _isLoading = true);
    _addLog('📤 Sending test notification to self...');

    try {
      final success = await _service.sendNotification(
        targetUserId: currentUser.uid,
        title: '🧪 Test Notification',
        body: 'This is a test notification sent at ${DateTime.now()}',
        type: NotificationType.general,
        data: {'test': 'true', 'timestamp': DateTime.now().toString()},
      );

      if (success) {
        _addLog('✅ Notification sent successfully');
      } else {
        _addLog('❌ Notification failed to send');
      }
    } catch (e) {
      _addLog('❌ Error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _testAdminNotification() async {
    setState(() => _isLoading = true);
    _addLog('📤 Sending notification to all admins...');

    try {
      await _service.sendToAdmins(
        title: '🧪 Admin Test Notification',
        body: 'This is a test notification for admins sent at ${DateTime.now()}',
        type: NotificationType.general,
        data: {'test': 'true', 'admin_test': 'true'},
      );
      _addLog('✅ Admin notification process completed');
    } catch (e) {
      _addLog('❌ Error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _debugSetup() async {
    setState(() => _isLoading = true);
    _addLog('🔍 Running debug diagnostics...');

    try {
      await _controller.debugAdminUsers();
      _addLog('✅ Check console for detailed debug info');
    } catch (e) {
      _addLog('❌ Error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _checkFCMToken() async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      _addLog('❌ No user logged in');
      return;
    }

    setState(() => _isLoading = true);
    _addLog('🔍 Checking FCM token...');

    try {
      final tokenDoc = await _firestore.collection('fcm_tokens').doc(currentUser.uid).get();
      
      if (tokenDoc.exists) {
        final token = tokenDoc.data()!['token'] as String?;
        final platform = tokenDoc.data()!['platform'] as String?;
        final updatedAt = (tokenDoc.data()!['updated_at'] as Timestamp?)?.toDate();
        
        _addLog('✅ FCM Token exists');
        _addLog('📱 Platform: $platform');
        _addLog('🕐 Updated: $updatedAt');
        _addLog('🔑 Token: ${token?.substring(0, 30)}...');
      } else {
        _addLog('❌ No FCM token found for current user');
        _addLog('💡 Try restarting the app or checking permissions');
      }
    } catch (e) {
      _addLog('❌ Error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _checkAdminUsers() async {
    setState(() => _isLoading = true);
    _addLog('🔍 Checking admin users...');

    try {
      final adminUsers = await RoleService.getAllAdminUsers();
      
      if (adminUsers.isEmpty) {
        _addLog('❌ No admin users found');
        _addLog('💡 Add admin user in Firestore: users/{userId}/role = "admin"');
      } else {
        _addLog('✅ Found ${adminUsers.length} admin user(s)');
        for (final adminId in adminUsers) {
          _addLog('   👤 $adminId');
        }
      }
    } catch (e) {
      _addLog('❌ Error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _checkCurrentUser() async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      _addLog('❌ No user logged in');
      return;
    }

    setState(() => _isLoading = true);
    _addLog('🔍 Checking current user...');

    try {
      _addLog('👤 User ID: ${currentUser.uid}');
      _addLog('📧 Email: ${currentUser.email}');
      
      final role = await RoleService.getUserRole(currentUser.uid);
      _addLog('🎭 Role: $role');
      
      final userDoc = await _firestore.collection('users').doc(currentUser.uid).get();
      if (userDoc.exists) {
        _addLog('✅ User document exists in Firestore');
      } else {
        _addLog('⚠️  User document not found in Firestore');
      }
    } catch (e) {
      _addLog('❌ Error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundBeige,
      appBar: AppBar(
        backgroundColor: kBackgroundBeige,
        title: const Text('🧪 Notification Test', style: kMerriweatherBold16),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Action Buttons
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : _testSelfNotification,
                  icon: const Icon(Icons.send),
                  label: const Text('Send Test Notification to Self'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kSeaGreen,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.all(12),
                  ),
                ),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : _testAdminNotification,
                  icon: const Icon(Icons.admin_panel_settings),
                  label: const Text('Send Test Notification to Admins'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kFireOpal,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.all(12),
                  ),
                ),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 8),
                Text('Debug Tools', style: kNunitoSansSemiBold16),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _isLoading ? null : _debugSetup,
                      icon: const Icon(Icons.bug_report, size: 16),
                      label: const Text('Full Debug'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: _isLoading ? null : _checkFCMToken,
                      icon: const Icon(Icons.key, size: 16),
                      label: const Text('Check FCM Token'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: _isLoading ? null : _checkAdminUsers,
                      icon: const Icon(Icons.people, size: 16),
                      label: const Text('Check Admins'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: _isLoading ? null : _checkCurrentUser,
                      icon: const Icon(Icons.person, size: 16),
                      label: const Text('Check User'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          const Divider(thickness: 2),
          
          // Logs Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Logs', style: kNunitoSansSemiBold16),
                TextButton(
                  onPressed: () => setState(() => _logs.clear()),
                  child: const Text('Clear'),
                ),
              ],
            ),
          ),
          
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(8),
              ),
              child: _logs.isEmpty
                  ? const Center(
                      child: Text(
                        'No logs yet. Click a button to start testing.',
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _logs.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Text(
                            _logs[index],
                            style: const TextStyle(
                              color: Colors.white,
                              fontFamily: 'Courier',
                              fontSize: 11,
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ),
          
          if (_isLoading)
            const LinearProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(kSeaGreen),
            ),
        ],
      ),
    );
  }
}
