import 'package:flutter/material.dart';
import '../../models/notification.dart'; // Import the Notification model

class NotificationsScreen extends StatelessWidget {
  final List<NotificationModel> notifications;
  final Function(String) onDelete;

  NotificationsScreen({Key? key, required this.notifications, required this.onDelete}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Notifications')),
      body: notifications.isEmpty
          ? Center(child: Text('No notifications available.'))
          : ListView.builder(
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notification = notifications[index];
                return ListTile(
                  title: Text(notification.message),
                  subtitle: Text(notification.movieTitle),
                  trailing: IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      onDelete(notification.id);
                    },
                  ),
                );
              },
            ),
    );
  }
}
