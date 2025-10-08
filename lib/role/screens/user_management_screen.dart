import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:timberr/constants.dart';
import 'package:timberr/role/role_controller.dart';
import 'package:timberr/role/role_guard_widgets.dart';
import 'package:timberr/role/role_model.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  final RoleController _roleController = Get.find<RoleController>();
  final TextEditingController _searchController = TextEditingController();
  String _selectedRoleFilter = 'all';
  List<Map<String, dynamic>> _filteredUsers = [];

  @override
  void initState() {
    super.initState();
    _loadUsers();
    _searchController.addListener(_filterUsers);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadUsers() async {
    await _roleController.loadAllUsers();
    _filterUsers();
  }

  void _filterUsers() {
    setState(() {
      String query = _searchController.text.toLowerCase();
      _filteredUsers = _roleController.allUsers.where((user) {
        // Filter by search query
        bool matchesSearch = query.isEmpty || 
            user['name'].toString().toLowerCase().contains(query) ||
            user['email'].toString().toLowerCase().contains(query);
        
        // Filter by role
        bool matchesRole = _selectedRoleFilter == 'all' || 
            user['role'] == _selectedRoleFilter;
        
        return matchesSearch && matchesRole;
      }).toList();
    });
  }

  Future<void> _showRoleChangeDialog(Map<String, dynamic> user) async {
    final currentRole = user['role'];
    final isCurrentlyAdmin = currentRole == DefaultRoles.adminRole;
    
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Change Role - ${user['name']}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Current Role: ${currentRole.toUpperCase()}'),
            const SizedBox(height: 16),
            Text(
              isCurrentlyAdmin 
                  ? 'Remove admin privileges and assign user role?'
                  : 'Grant admin privileges to this user?',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            Text(
              isCurrentlyAdmin
                  ? 'This user will lose access to admin features.'
                  : 'This user will gain access to admin dashboard and management features.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              if (isCurrentlyAdmin) {
                await _roleController.removeAdminRole(
                  user['user_id'],
                  user['email'],
                  user['name'],
                );
              } else {
                await _roleController.assignAdminRole(
                  user['user_id'],
                  user['email'],
                  user['name'],
                );
              }
              _filterUsers();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: isCurrentlyAdmin ? Colors.red : Colors.green,
            ),
            child: Text(
              isCurrentlyAdmin ? 'Remove Admin' : 'Grant Admin',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PermissionGuard(
      adminOnly: true,
      child: Scaffold(
        backgroundColor: kBackgroundBeige,
        appBar: AppBar(
          backgroundColor: kBackgroundBeige,
          title: const Text(
            "USER MANAGEMENT",
            style: kMerriweatherBold16,
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _loadUsers,
            ),
          ],
        ),
        body: Column(
          children: [
            // Search and Filter Section
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Search Bar
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search users by name or email...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Role Filter
                  Row(
                    children: [
                      const Text(
                        'Filter by role: ',
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: DropdownButton<String>(
                          value: _selectedRoleFilter,
                          isExpanded: true,
                          items: const [
                            DropdownMenuItem(value: 'all', child: Text('All Roles')),
                            DropdownMenuItem(value: 'user', child: Text('Users')),
                            DropdownMenuItem(value: 'admin', child: Text('Admins')),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _selectedRoleFilter = value!;
                            });
                            _filterUsers();
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Statistics Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: GetBuilder<RoleController>(
                builder: (controller) {
                  final counts = controller.getUserCountByRole();
                  return Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          'Total Users',
                          controller.allUsers.length.toString(),
                          Colors.blue,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildStatCard(
                          'Regular Users',
                          (counts['user'] ?? 0).toString(),
                          Colors.green,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildStatCard(
                          'Admins',
                          (counts['admin'] ?? 0).toString(),
                          Colors.red,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            // User List
            Expanded(
              child: GetBuilder<RoleController>(
                builder: (controller) {
                  if (controller.isLoading) {
                    return const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(kOffBlack),
                      ),
                    );
                  }

                  if (_filteredUsers.isEmpty) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.people_outline,
                            size: 64,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'No users found',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _filteredUsers.length,
                    itemBuilder: (context, index) {
                      final user = _filteredUsers[index];
                      return _buildUserCard(user);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      fallback: const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.security,
                size: 64,
                color: Colors.grey,
              ),
              SizedBox(height: 16),
              Text(
                'Access Denied',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'You need admin privileges to access this page.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
      showFallbackOnNoPermission: true,
    );
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserCard(Map<String, dynamic> user) {
    final isAdmin = user['role'] == DefaultRoles.adminRole;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 2,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isAdmin ? Colors.red[100] : Colors.blue[100],
          child: Text(
            user['name'].toString().isNotEmpty 
                ? user['name'][0].toUpperCase()
                : '?',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isAdmin ? Colors.red[800] : Colors.blue[800],
            ),
          ),
        ),
        title: Text(
          user['name'] ?? 'Unknown',
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(user['email'] ?? 'No email'),
            const SizedBox(height: 4),
            Row(
              children: [
                RoleBadge(role: user['role']),
                if (user['role_assigned_at'] != null) ...[
                  const SizedBox(width: 8),
                  Text(
                    'Since: ${_formatDate(user['role_assigned_at'])}',
                    style: const TextStyle(fontSize: 10, color: Colors.grey),
                  ),
                ],
              ],
            ),
          ],
        ),
        trailing: IconButton(
          icon: Icon(
            isAdmin ? Icons.remove_moderator : Icons.admin_panel_settings,
            color: isAdmin ? Colors.red : Colors.green,
          ),
          onPressed: () => _showRoleChangeDialog(user),
          tooltip: isAdmin ? 'Remove Admin Role' : 'Grant Admin Role',
        ),
        isThreeLine: true,
      ),
    );
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return 'Unknown';
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return 'Unknown';
    }
  }
}