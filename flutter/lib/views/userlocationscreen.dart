import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserLocationScreen extends StatefulWidget {
  const UserLocationScreen({super.key});
  @override
  _UserLocationScreenState createState() => _UserLocationScreenState();
}

class _UserLocationScreenState extends State<UserLocationScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('users').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text('No users found.'));
        }

        // Extract user documents
        final users = snapshot.data!.docs;

        return ListView.builder(
          itemCount: users.length,
          itemBuilder: (context, index) {
            final user = users[index];
            final location = user['location'];

            // Only display users with a non-null location
            if (location != null) {
              return ListTile(
                title: Text(user.id), // Display user ID or name
                subtitle: Text('Location: $location'),
              );
            } else {
              return SizedBox
                  .shrink(); // Return an empty widget if location is null
            }
          },
        );
      },
    );
  }
}
