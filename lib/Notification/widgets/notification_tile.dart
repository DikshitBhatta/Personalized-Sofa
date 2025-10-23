import 'package:flutter/material.dart';
import 'package:timberr/constants.dart';
import 'package:timberr/Notification/models/notification_model.dart';
import 'package:timeago/timeago.dart' as timeago;

class NotificationTile extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback? onTap;

  const NotificationTile({
    super.key,
    required this.notification,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Stack(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
            color: notification.isRead ? Colors.white : kSnowFlakeWhite,
            child: Row(
              children: [
                Container(
                  height: 50,
                  width: 50,
                  decoration: BoxDecoration(
                    color: _getTypeColor(notification.type),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Icon(
                    _getTypeIcon(notification.type),
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              notification.title,
                              style: kNunitoSans14.copyWith(
                                color: kOffBlack,
                                fontWeight: notification.isRead 
                                    ? FontWeight.w600 
                                    : FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            timeago.format(notification.createdAt),
                            style: kNunitoSans10Grey,
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        notification.body,
                        style: kNunitoSans12Grey.copyWith(
                          color: notification.isRead ? kGrey : kOffBlack,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (notification.data.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          _getDataText(notification.data),
                          style: kNunitoSans10Grey.copyWith(
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (!notification.isRead)
            Positioned(
              top: 15,
              right: 20,
              child: Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: kSeaGreen,
                  shape: BoxShape.circle,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Color _getTypeColor(NotificationType type) {
    switch (type) {
      case NotificationType.conciergeBooking:
        return kSeaGreen;
      case NotificationType.conciergeConfirmation:
        return kCrayolaGreen;
      case NotificationType.conciergeRejection:
        return kFireOpal;
      case NotificationType.orderUpdate:
        return kOffBlack;
      case NotificationType.general:
        return kGrey;
    }
  }

  IconData _getTypeIcon(NotificationType type) {
    switch (type) {
      case NotificationType.conciergeBooking:
        return Icons.event_available;
      case NotificationType.conciergeConfirmation:
        return Icons.check_circle;
      case NotificationType.conciergeRejection:
        return Icons.cancel;
      case NotificationType.orderUpdate:
        return Icons.shopping_bag;
      case NotificationType.general:
        return Icons.info;
    }
  }

  String _getDataText(Map<String, dynamic> data) {
    if (data['concierge_name'] != null) {
      return 'Concierge: ${data['concierge_name']}';
    }
    if (data['order_id'] != null) {
      return 'Order: #${data['order_id']}';
    }
    return '';
  }
}