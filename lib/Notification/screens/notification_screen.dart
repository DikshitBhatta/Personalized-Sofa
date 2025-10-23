import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:timberr/constants.dart';
import 'package:timberr/widgets/tabbed/curved_bottom_navbar.dart';
import 'package:timberr/Notification/widgets/notification_tile.dart';
import 'package:timberr/Notification/controllers/notification_controller.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(NotificationController());
    
    return PopScope(
      canPop: false,
      onPopInvoked: (_) => kOnExitConfirmation(),
      child: Scaffold(
        backgroundColor: kBackgroundBeige,
        appBar: AppBar(
          backgroundColor: kBackgroundBeige,
          title: const Text(
            "NOTIFICATIONS",
            style: kMerriweatherBold16,
          ),
          centerTitle: true,
          actions: [
            GetBuilder<NotificationController>(
              builder: (controller) {
                if (controller.unreadCount > 0) {
                  return IconButton(
                    icon: Stack(
                      children: [
                        const Icon(Icons.mark_email_read),
                        Positioned(
                          right: 0,
                          top: 0,
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: const BoxDecoration(
                              color: kFireOpal,
                              shape: BoxShape.circle,
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 16,
                              minHeight: 16,
                            ),
                            child: Text(
                              '${controller.unreadCount}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ],
                    ),
                    onPressed: () => controller.markAllAsRead(),
                    tooltip: 'Mark all as read',
                  );
                }
                return const SizedBox.shrink();
              }
            ),
          ],
        ),
        bottomNavigationBar: const CurvedBottomNavBar(selectedPos: 2),
        body: GetBuilder<NotificationController>(
          builder: (controller) {
            if (controller.isLoading) {
              return const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(kSeaGreen),
                ),
              );
            }

            if (controller.notifications.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.notifications_none,
                      size: 64,
                      color: kGrey,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "No notifications yet",
                      style: kNunitoSansSemiBold16.copyWith(color: kGrey),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "We'll notify you when something happens",
                      style: kNunitoSans12Grey,
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: controller.loadNotifications,
              color: kSeaGreen,
              child: ListView.separated(
                itemCount: controller.notifications.length,
                physics: const AlwaysScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  final notification = controller.notifications[index];
                  return Dismissible(
                    key: Key(notification.id),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      color: kFireOpal,
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20),
                      child: const Icon(
                        Icons.delete,
                        color: Colors.white,
                      ),
                    ),
                    onDismissed: (direction) {
                      controller.deleteNotification(notification.id);
                      Get.snackbar(
                        'Deleted',
                        'Notification deleted successfully',
                        backgroundColor: kSeaGreen,
                        colorText: Colors.white,
                        snackPosition: SnackPosition.BOTTOM,
                        margin: const EdgeInsets.all(16),
                      );
                    },
                    child: NotificationTile(
                      notification: notification,
                      onTap: () => controller.markAsRead(notification.id),
                    ),
                  );
                },
                separatorBuilder: (context, index) {
                  return const Divider(
                    height: 0,
                    thickness: 1,
                    color: kSnowFlakeWhite,
                    indent: 20,
                    endIndent: 20,
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}