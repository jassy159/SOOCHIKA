import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';

class CRUDService {
  static Future saveUserToken(String token) async {
    User? user = FirebaseAuth.instance.currentUser;

    //save fcm token to firestore

    Map<String, dynamic> data = {
      "token": token,
    };
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.email)
          .update(data);
      print("Document is added");
    } catch (e) {
      print("Error in saving in FireStore ${e.toString()}");
    }
  }

  static Future<Position?> getCurrentLocation() async {
    // Check if location services are enabled
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled, return null
      print('Location services are disabled.');
      return null;
    }

    // Check for location permission
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      // Request permission
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, return null
        print('Location permissions are denied.');
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, return null
      print(
          'Location permissions are permanently denied, we cannot request permissions.');
      return null;
    }

    // If we have permission, get the current position
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      print('Current position: ${position.latitude}, ${position.longitude}');
      String docId = FirebaseAuth.instance.currentUser!.email!;
      Map<String, dynamic> newData = {
        'location': '${position.latitude}, ${position.longitude}',
      };

      updateData(docId, newData);
      return position;
    } catch (e) {
      print('Error getting location: $e');
      return null;
    }
  }

  // Function to update data
  static Future<void> updateData(
      String docId, Map<String, dynamic> data) async {
    try {
      final FirebaseFirestore firestore = FirebaseFirestore.instance;
      await firestore
          .collection('users')
          .doc(docId)
          .update(data);
      print("Document updated successfully");
    } catch (e) {
      print("Error updating document: $e");
    }
  }

   Future<void> getData() async {
    try {
       final FirebaseFirestore firestore = FirebaseFirestore.instance;
      // Querying the collection where 'field_name' has specific values
      QuerySnapshot querySnapshot = await firestore
          .collection('your_collection_name')
          .where('field_name', isEqualTo: 'desired_value') // Change as needed
          .get();

      // Process the documents
      for (var doc in querySnapshot.docs) {
        print("Document ID: ${doc.id}, Data: ${doc.data()}");
      }
    } catch (e) {
      print("Error getting documents: $e");
    }
  }
}
