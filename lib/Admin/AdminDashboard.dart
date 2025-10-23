import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:timberr/screens/authentication/onboarding_welcome.dart';

import 'delivery_setup_admin.dart';
import 'package:timberr/screens/orders/admin_order_management.dart';
import 'concierge_management.dart';
import 'concierge_booking_management.dart';
import 'package:timberr/role/screens/user_management_screen.dart';

class ColorsScheme {
  static const Color primaryBackgroundColor = Color(0xff2A2438);
  static const Color secondaryBackgroundColor = Color(0xff352F44);
  static const Color primaryTextColor = Color(0xffFFFFFF);
  static const Color secondaryTextColor = Color(0xffB0A0D6);
  static const Color primaryIconColor = Color(0xff8476AA);
}

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({Key? key}) : super(key: key);

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorsScheme.primaryBackgroundColor,
      appBar: AppBar(
        backgroundColor: ColorsScheme.primaryBackgroundColor,
        title: Text(
          'Admin Dashboard',
          style: TextStyle(
            color: ColorsScheme.primaryTextColor,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              Icons.logout,
              color: ColorsScheme.primaryTextColor,
            ),
            onPressed: () => _showLogoutDialog(context),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.9,
          children: [
            _buildDashboardCard(
              context,
              'Concierge Management',
              Icons.support_agent,
              'Add and manage concierge agents',
              () => Get.to(() => const ConciergeManagement()),
            ),
            _buildDashboardCard(
              context,
              'Concierge Bookings',
              Icons.event_available,
              'Manage concierge visit bookings',
              () => Get.to(() => const ConciergeBookingManagement()),
            ),
            _buildDashboardCard(
              context,
              'Order Review',
              Icons.receipt_long,
              'Review and approve/reject orders',
              () => Get.to(() => const AdminOrderManagement()),
            ),
            _buildDashboardCard(
              context,
              'Delivery Setup',
              Icons.local_shipping,
              'Manage delivery zones and schedules',
              () => Get.to(() => const DeliverySetupAdmin()),
            ),
            _buildDashboardCard(
              context,
              'User Management',
              Icons.people,
              'Manage users and roles',
              () => Get.to(() => const UserManagementScreen()),
            ),
            // Add a new card for Role Management
            _buildDashboardCard(
              context,
              'Role Management',
              Icons.admin_panel_settings,
              'Assign and manage user roles',
              () => Get.to(() => const UserManagementScreen()),
            ),
            // _buildDashboardCard(
            //   context,
            //   'Analytics',
            //   Icons.analytics,
            //   'View business metrics',
            //   () => _showComingSoon(context),
            // ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: ColorsScheme.secondaryBackgroundColor,
        title: Text(
          'Logout',
          style: TextStyle(color: ColorsScheme.primaryTextColor),
        ),
        content: Text(
          'Are you sure you want to logout?',
          style: TextStyle(color: ColorsScheme.secondaryTextColor),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: TextStyle(color: ColorsScheme.secondaryTextColor),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await FirebaseAuth.instance.signOut();
              await Get.deleteAll(force: true);
              Get.offAll(() => const OnBoardingWelcomeScreen());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardCard(
    BuildContext context,
    String title,
    IconData icon,
    String description,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: ColorsScheme.secondaryBackgroundColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              flex: 2,
              child: Icon(
                icon,
                size: 36,
                color: ColorsScheme.primaryIconColor,
              ),
            ),
            const SizedBox(height: 12),
            Flexible(
              flex: 2,
              child: Text(
                title,
                style: const TextStyle(
                  color: ColorsScheme.primaryTextColor,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 8),
            Flexible(
              flex: 2,
              child: Text(
                description,
                style: const TextStyle(
                  color: ColorsScheme.secondaryTextColor,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }


}