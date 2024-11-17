import 'dart:convert';

import 'package:fcm/controllers/auth_service.dart';
import 'package:fcm/controllers/crud_service.dart';
import 'package:fcm/controllers/notification_service.dart';
import 'package:fcm/firebase_options.dart';
import 'package:fcm/views/admin_home_page.dart';
import 'package:fcm/views/checkuserrole.dart';
import 'package:fcm/views/home_page.dart';
import 'package:fcm/views/login_page.dart';
import 'package:fcm/views/message.dart';
import 'package:fcm/views/signup_page.dart';
import 'package:fcm/views/user_home_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

final navigatorKey = GlobalKey<NavigatorState>();

//function to listen to backgorund changes
Future _firebaseBackgroundMessage(RemoteMessage message) async {
  if (message.notification != null) {
    print("Some Notification is background/////");
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  //initialize fcm
  await PushNotification.init();

  //initialize localnotification
  await PushNotification.localNotificationinit();

  //Listen to Backgroynd notifiction
  FirebaseMessaging.onBackgroundMessage(_firebaseBackgroundMessage);

  //on background message tapped
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    if (message.notification != null) {
      print("background notificaotn Tapped");
      navigatorKey.currentState!.pushNamed('/message', arguments: message);
    }
  });

  //to handle foreground notification
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    String payloadData = jsonEncode(message.data);
    print("Got a message in foreground");
    print("${CRUDService.getCurrentLocation().toString()} HIII");
    
    if (message.notification != null) {
      print(payloadData);
      PushNotification.showSimpleNotification(
          title: message.notification!.title!,
          body: message.notification!.body!,
          payload: payloadData);
    }
  });

  //for handling in terminatedstate
  final RemoteMessage? message =
      await FirebaseMessaging.instance.getInitialMessage();
  if (message != null) {
    print("Launched from terminated state");
    Future.delayed(Duration(seconds: 1), () {
      navigatorKey.currentState!.pushNamed('/message', arguments: message);
    });
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      navigatorKey: navigatorKey,
      routes: {
        "/": (context) => const CheckUser(),
        "/signup": (context) => const SignUpPage(),
        "/login": (context) => const LoginPage(),
        "/adminhome": (context) => const AdminHomePage(),
        "/userhome": (context) => const UserHomePage(),
        "/message": (context) => const Message(),
        '/checkuserrole': (context) => const CheckUserRole()
      },
    );
  }
}

class CheckUser extends StatefulWidget {
  const CheckUser({super.key});

  @override
  State<CheckUser> createState() => _CheckUserState();
}

class _CheckUserState extends State<CheckUser> {
  @override
  void initState() {
    AuthService.isLoggedIn().then((value) {
      if (!mounted) return;
      if (value) {
        Navigator.pushReplacementNamed(context, "/checkuserrole");
      } else {
        Navigator.pushReplacementNamed(context, "/login");
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
