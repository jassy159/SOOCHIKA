
import 'package:fcm/controllers/auth_service.dart';
import 'package:fcm/controllers/notification_service.dart';
import 'package:flutter/material.dart';


class UserHomePage extends StatefulWidget {
  const UserHomePage({super.key});

  @override
  State<UserHomePage> createState() => _UserHomePageState();
}

class _UserHomePageState extends State<UserHomePage> {
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
        title: Text("User Home"),
        actions: [
          IconButton(
              onPressed: () async {
                await AuthService.logoutUser();
                Navigator.pushReplacementNamed(context, '/login');
              },
              icon: Icon(Icons.logout))
        ],
      ),
    );
  }
}
