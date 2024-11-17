import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fcm/controllers/auth_service.dart';
import 'package:fcm/controllers/notification_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextEditingController _notificationcontroller = TextEditingController();
  final String _user = FirebaseAuth.instance.currentUser!.email!;
  List<Map<String, dynamic>> documents = []; // Declare documents list here

  // Function to get data from Firestore
  Future<void> getData() async {
    try {
      final FirebaseFirestore firestore = FirebaseFirestore.instance;
      QuerySnapshot querySnapshot = await firestore
          .collection('users') // Replace with your collection name
          .where('location',
              isNotEqualTo: '') // Replace with your field and desired value
          .get();

      // Clear the list before adding new data
      documents.clear();

      for (var doc in querySnapshot.docs) {
        documents.add(doc.data() as Map<String, dynamic>);
      }
      print(documents);

      setState(() {}); // Update the UI
    } catch (e) {
      print("Error getting documents: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    getData(); // Fetch data when the widget is initialized
    PushNotification.getDeviceToken();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () {
              AuthService.logoutUser();
              Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
            },
            icon: Icon(Icons.logout),
          )
        ],
        title: Text("Home ${_user}"),
      ),
      body: Column(
        children: [
          TextFormField(
            controller: _notificationcontroller,
            decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Type Error Notification"),
          ),
          ElevatedButton(
            onPressed: () {
              Map<String, dynamic> data = {
                'ALERT': _notificationcontroller.text,
              };
              PushNotification.sendNotificationSelectedUser(
                'ftY7QpuHQ-ijwT_Nri9Yeg:APA91bE589o1P-aRWiN4kVvUtkp_Kx-pBDulFotNOBXcidROJ66F6jwaB27vm9apwELezJMMOg3vQCtAf1wZ_qqS0AKQi3JidrGx4mB1WkkAa4zLFmjnXDk',
                context,
                data,
              );
            },
            child: Text("Send Notification"),
          ),
          Expanded(
            // Use Expanded to fill available space
            child: Container(
              padding: EdgeInsets.all(16.0),
              child: documents.isEmpty
                  ? Center(
                      child: CircularProgressIndicator()) // Loading indicator
                  : ListView.builder(
                      itemCount: documents.length,
                      itemBuilder: (context, index) {
                        return Container(
                          margin: EdgeInsets.symmetric(vertical: 8.0),
                          padding: EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                            color: Colors.blueAccent,
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Document ID: ${documents[index]['id']}', // Display document ID
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                              ),
                              SizedBox(height: 8.0),
                              Text(
                                'Field Value: ${documents[index]['field_name']}', // Display field value
                                style: TextStyle(
                                    fontSize: 14, color: Colors.white),
                              ),
                              // Add more fields as needed
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
