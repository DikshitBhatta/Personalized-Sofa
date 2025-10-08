import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:timberr/constants.dart';
import 'package:timberr/role/role_debugger.dart';
import 'package:timberr/role/role_controller.dart';

class RoleDebugScreen extends StatefulWidget {
  const RoleDebugScreen({super.key});

  @override
  State<RoleDebugScreen> createState() => _RoleDebugScreenState();
}

class _RoleDebugScreenState extends State<RoleDebugScreen> {
  final RoleController _roleController = Get.find<RoleController>();
  bool _isLoading = false;
  String _debugOutput = '';

  void _addToOutput(String message) {
    setState(() {
      _debugOutput += '$message\n';
    });
  }

  Future<void> _runTest() async {
    setState(() {
      _isLoading = true;
      _debugOutput = '';
    });

    try {
      await RoleDebugger.runRoleSystemTest();
      _addToOutput('✅ Role system test completed - check console for details');
    } catch (e) {
      _addToOutput('❌ Test failed: $e');
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _fixIssues() async {
    setState(() {
      _isLoading = true;
      _debugOutput = '';
    });

    try {
      await RoleDebugger.fixRoleSystemIssues();
      _addToOutput('✅ Role system issues fixed - check console for details');
      
      // Refresh role controller
      await _roleController.refreshUserRole();
      _addToOutput('🔄 Role controller refreshed');
    } catch (e) {
      _addToOutput('❌ Fix failed: $e');
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _makeAdmin() async {
    final confirmed = await _showConfirmationDialog(
      'Make Admin',
      'Are you sure you want to make the current user an admin? This is for development purposes only.',
    );

    if (!confirmed) return;

    setState(() {
      _isLoading = true;
      _debugOutput = '';
    });

    try {
      await RoleDebugger.makeCurrentUserAdmin();
      _addToOutput('✅ Current user is now admin - restart app to see changes');
    } catch (e) {
      _addToOutput('❌ Failed to make admin: $e');
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _makeRegular() async {
    final confirmed = await _showConfirmationDialog(
      'Make Regular User',
      'Are you sure you want to make the current user a regular user?',
    );

    if (!confirmed) return;

    setState(() {
      _isLoading = true;
      _debugOutput = '';
    });

    try {
      await RoleDebugger.makeCurrentUserRegular();
      _addToOutput('✅ Current user is now regular user - restart app to see changes');
    } catch (e) {
      _addToOutput('❌ Failed to make regular: $e');
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _printStatus() async {
    setState(() {
      _debugOutput = '';
    });

    await RoleDebugger.printCurrentStatus();
    _addToOutput('📊 Current status printed to console');
  }

  Future<bool> _showConfirmationDialog(String title, String content) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Confirm', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    ) ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundBeige,
      appBar: AppBar(
        backgroundColor: kBackgroundBeige,
        title: const Text(
          "ROLE DEBUG",
          style: kMerriweatherBold16,
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Current Status Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: GetBuilder<RoleController>(
                  builder: (controller) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Current Status',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Text('Role: '),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: controller.isAdmin
                                    ? Colors.red.shade100
                                    : Colors.blue.shade100,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                controller.currentUserRole.toUpperCase(),
                                style: TextStyle(
                                  color: controller.isAdmin
                                      ? Colors.red.shade800
                                      : Colors.blue.shade800,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text('Permissions: ${controller.currentUserPermissions.length}'),
                        const SizedBox(height: 8),
                        Text('Loading: ${controller.isLoading}'),
                      ],
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Action Buttons
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.2,
                children: [
                  _buildActionCard(
                    'Run Test',
                    'Test role system',
                    Icons.bug_report,
                    Colors.blue,
                    _runTest,
                  ),
                  _buildActionCard(
                    'Fix Issues',
                    'Fix common problems',
                    Icons.build,
                    Colors.green,
                    _fixIssues,
                  ),
                  _buildActionCard(
                    'Make Admin',
                    'Grant admin role',
                    Icons.admin_panel_settings,
                    Colors.red,
                    _makeAdmin,
                  ),
                  _buildActionCard(
                    'Make User',
                    'Remove admin role',
                    Icons.person,
                    Colors.orange,
                    _makeRegular,
                  ),
                  _buildActionCard(
                    'Print Status',
                    'Show current status',
                    Icons.info,
                    Colors.purple,
                    _printStatus,
                  ),
                  _buildActionCard(
                    'Refresh',
                    'Reload role data',
                    Icons.refresh,
                    Colors.teal,
                    () async {
                      await _roleController.refreshUserRole();
                      _addToOutput('🔄 Role data refreshed');
                    },
                  ),
                ],
              ),
            ),
            // Output Section
            if (_debugOutput.isNotEmpty) ...[
              const SizedBox(height: 16),
              Card(
                child: Container(
                  width: double.infinity,
                  height: 120,
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Debug Output:',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _debugOutput = '';
                              });
                            },
                            child: const Text('Clear'),
                          ),
                        ],
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Text(
                            _debugOutput,
                            style: const TextStyle(
                              fontSize: 12,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            // Loading Indicator
            if (_isLoading) ...[
              const SizedBox(height: 16),
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(kOffBlack),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: _isLoading ? null : onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 32,
                color: _isLoading ? Colors.grey : color,
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: _isLoading ? Colors.grey : color,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}