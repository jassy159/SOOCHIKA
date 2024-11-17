import 'dart:convert';
import 'dart:io';

import 'package:fcm/controllers/auth_service.dart';
import 'package:fcm/controllers/crud_service.dart';
import 'package:fcm/main.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:googleapis_auth/auth_io.dart' as auth;
import 'package:googleapis/servicecontrol/v1.dart' as servicecontrol;

class PushNotification {
  static final _firebaseMessaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin
      _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  //request notification permisssion
  static Future init() async {
    await _firebaseMessaging.requestPermission(
        alert: true,
        announcement: true,
        badge: true,
        carPlay: false,
        criticalAlert: true,
        provisional: false,
        sound: true);
  }

  static Future getDeviceToken() async {
    //get device token
    final token = await _firebaseMessaging.getToken();
    print('device token $token');

    bool isUserLoggedIn = await AuthService.isLoggedIn();
    if (isUserLoggedIn) {
      await CRUDService.saveUserToken(token!);
      print("Saved to firestore");

      //also save if token changes
      _firebaseMessaging.onTokenRefresh.listen((newToken) async {
        if (isUserLoggedIn) {
          await CRUDService.saveUserToken(token);
          print('saved tp firestroe');
        }
      });
    }
  }

  //initialize local notification
  static Future localNotificationinit() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    final InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    //request notification permission from android 13 and above
    _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()!
        .requestNotificationsPermission();
    _flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onDidReceiveBackgroundNotificationResponse: onNotificationTap,
        onDidReceiveNotificationResponse: onNotificationTap);
  }

  //on tap local notification in foreground
  static void onNotificationTap(NotificationResponse notificationrespone) {
    navigatorKey.currentState!
        .pushNamed('/message', arguments: notificationrespone);
  }

  static Future showSimpleNotification(
      {required String title,
      required String body,
      required String payload}) async {
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      'channel_id',
      'channel_name',
      channelDescription: 'channel_description',
      importance: Importance.max,
      priority: Priority.high,
      sound: RawResourceAndroidNotificationSound(
          'alert33762'), // Specify your sound file name without extension
      ticker: 'ticker',
    );
    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
    );
    await _flutterLocalNotificationsPlugin
        .show(0, title, body, notificationDetails, payload: payload);
  }

  static Future<void> createNotificationChannel() async {
    if (Platform.isAndroid) {
      const AndroidNotificationChannel channel = AndroidNotificationChannel(
        'channel_id', // The id of the channel.
        'Default Channel', // The human-readable name of the channel.
        description:
            'This is the default notification channel', // The description of the channel.
        importance: Importance.high, // Importance level of the channel.
      );

      await _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);
    }
  }

  static Future<String> getAccessToken() async {
    final serviceAccountJson = {
    
    };

    List<String> scopes = [
      'https://www.googleapis.com/auth/firebase.messaging',
      'https://www.googleapis.com/auth/firebase.database',
      'https://www.googleapis.com/auth/userinfo.email',
    ];

    http.Client client = await auth.clientViaServiceAccount(
        auth.ServiceAccountCredentials.fromJson(serviceAccountJson), scopes);

    //get accessToken
    auth.AccessCredentials credentials =
        await auth.obtainAccessCredentialsViaServiceAccount(
            auth.ServiceAccountCredentials.fromJson(serviceAccountJson),
            scopes,
            client);
    client.close();

    return credentials.accessToken.data;
  }

  //send Notification
  static sendNotificationSelectedUser(
      String token, BuildContext context, Map data) async {
    final String serverAccessToken = await getAccessToken();
    print(serverAccessToken);
    String endpointFirebaseCloudMessaging =
        'https://fcm.googleapis.com/v1/projects/notification-a5bd3/messages:send';

    final Map<String, dynamic> message = {
      
    };

    try {
      final http.Response response = await http.post(
        Uri.parse(endpointFirebaseCloudMessaging),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $serverAccessToken',
        },
        body: jsonEncode(message),
      );

      if (response.statusCode == 200) {
        print('Notification sent successfully');
      } else {
        print('Failed to send notification: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      print('Error sending notification: $e');
    }
  }

  static sendNotificationToTopic(
      String topic, BuildContext context, Map data) async {
    final String serverAccessToken = await getAccessToken();
    print(serverAccessToken);
    String endpointFirebaseCloudMessaging =
        'https://fcm.googleapis.com/v1/projects/#########################/messages:send';

    final Map<String, dynamic> message = {
      'message': {
        'topic':
            topic, // Specify the topic to which the notification will be sent
        'notification': {
          'title': "This is sent through API",
          'body': "BLa bla bla bla",
        },
        'data': data,
        'android': {
          'priority': 'high', // Set priority for Android notifications
          'notification': {
            'sound':
                'alert33762', // Specify your custom sound file name (without extension)
          },
        },
      }
    };

    try {
      final http.Response response = await http.post(
        Uri.parse(endpointFirebaseCloudMessaging),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $serverAccessToken',
        },
        body: jsonEncode(message),
      );

      if (response.statusCode == 200) {
        print('Notification sent successfully');
      } else {
        print('Failed to send notification: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      print('Error sending notification: $e');
    }
  }

  static Future<void> subscribeToTopic(String topic) async {
    try {
      await _firebaseMessaging.subscribeToTopic(topic);
      print('Subscribed to topic: $topic');
    } catch (e) {
      print('Error subscribing to topic: $e');
    }
  }
}
