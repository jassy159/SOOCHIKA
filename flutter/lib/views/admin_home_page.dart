import 'package:fcm/controllers/auth_service.dart';
import 'package:fcm/controllers/notification_service.dart';
import 'package:flutter/material.dart';

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  @override
  void initState() {
    PushNotification.getDeviceToken();
    PushNotification.subscribeToTopic('alert');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
              onPressed: () {
                AuthService.logoutUser();
                Navigator.pushNamedAndRemoveUntil(
                    context, '/', (route) => false);
              },
              icon: Icon(Icons.logout))
        ],
        title: Text("Admin Home "),
      ),
      body: Column(
        children: [
          ElevatedButton(
              onPressed: () {
                Map<String, dynamic> data = {
                  'title': 'Hello',
                };
                // PushNotification.sendNotificationSelectedUser(
                //     'ftY7QpuHQ-ijwT_Nri9Yeg:APA91bE589o1P-aRWiN4kVvUtkp_Kx-pBDulFotNOBXcidROJ66F6jwaB27vm9apwELezJMMOg3vQCtAf1wZ_qqS0AKQi3JidrGx4mB1WkkAa4zLFmjnXDk',
                //     context,
                //     data);

                    PushNotification.sendNotificationToTopic('alert', context, data);
              },
              child: Text("Send Notification")),
              
              
        ],
      ),
    );
  }
}
