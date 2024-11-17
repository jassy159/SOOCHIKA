import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  static Future<String> createAccountWithEmail(
      String email, String password) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.email)
          .set({'email': user.email, 'isUserAdmin': 'user'});
      print("Document is added");
      return "Account Created";
    } on FirebaseAuthException catch (e) {
      return e.message.toString();
    } catch (e) {
      return e.toString();
    }
  }

  //login user
  static Future<String> loginWithEmail(String email, String password) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);
      return 'Login Successful';
    } on FirebaseAuthException catch (e) {
      return e.message.toString();
    } catch (e) {
      return e.toString();
    }
  }

  //logout User
  static Future<void> logoutUser() async {
    await FirebaseAuth.instance.signOut();
  }

  //check wheather user signed in
  static Future<bool> isLoggedIn() async {
    var user = FirebaseAuth.instance.currentUser;
    return user != null;
  }

  // static Future<bool> isUserAdmin() async{
  //   var user = Firebase.
  // }

  static bool isUserAdmin() {
    final FirebaseFirestore db = FirebaseFirestore.instance;
    final userDoc = db.collection('user');
    User? signedInUser = FirebaseAuth.instance.currentUser;
    userDoc.doc(signedInUser?.email).get().then((DocumentSnapshot doc) {
      final data = doc.data() as Map<String, dynamic>;

      if (data['role'] == 'admin') {
        return true;
      }
    });
    return false;
  }
}
