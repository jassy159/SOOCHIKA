import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fcm/controllers/notification_service.dart';
import 'package:fcm/views/admin_home_page.dart';
import 'package:fcm/views/user_home_page.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';



class CheckUserRole extends StatefulWidget {
  const CheckUserRole({super.key});

  @override
  State<CheckUserRole> createState() => _CheckUserRoleState();
}

class _CheckUserRoleState extends State<CheckUserRole> {
  @override
  void initState() {
    PushNotification.getDeviceToken();
    super.initState();
  }

  Future<bool> isUserAdmin() async {
    final inst = await FirebaseFirestore.instance
        .collection('user_data')
        .doc(FirebaseAuth.instance.currentUser?.email)
        .get();
    final data = inst.data() as Map<String, dynamic>;
    print('${data['isUserAdmin']} hi');
    return data['isUserAdmin'] == 'admin';
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: isUserAdmin(),
        builder: (context, snapshot) {
         
            if (FirebaseAuth.instance.currentUser!.email == 'jassymon114@gmail.com') {
              return const AdminHomePage();
            } else {
              return const UserHomePage();
            }
          
        });
  }
}
