import 'package:asnan_hub/models/user.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';



class AuthService {
final FirebaseAuth _auth = FirebaseAuth.instance;


Future<UserModel?> getUserProfile() async {
  // 1. Get the current user's UID
  String? uid = FirebaseAuth.instance.currentUser?.uid;

  if (uid == null) {
    print("No user logged in");
    return null; // User not logged in
  }

  try {
    // 2. Fetch the document from the 'users' collection
    DocumentSnapshot userDoc = 
        await FirebaseFirestore.instance.collection('users').doc(uid).get();

    // 3. Check if it exists and read data
    if (userDoc.exists && userDoc.data() != null) {
      // Access fields using data() method which returns Map<String, dynamic>?
      final data = userDoc.data() as Map<String, dynamic>;
      print("user doc exists , ${data}");
      var user = UserModel.fromMap(data);
      print(user.email);
      return UserModel.fromMap(data);
    } else {
      print("User document does not exist in Firestore for uid: $uid");
      return null;
    }
  } catch (e) {
    print("Error fetching user data: $e");
    return null;
  }
}

Future<UserCredential> signUp(String email, String password) async {
  try {
    var user = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    return user;
  } on FirebaseAuthException catch (e) {
    throw e.message ?? "Sign up failed: ${e.code}";
  } catch (e) {
    throw "An unexpected error occurred: ${e.toString()}";
  }
}


Future<UserCredential> signIn(String email, String password) async {
  try {
    var user = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return user;
  } on FirebaseAuthException catch (e) {
    throw e.message ?? "Login failed: ${e.code}";
  } catch (e) {
    throw "An unexpected error occurred: ${e.toString()}";
  }
}
}


