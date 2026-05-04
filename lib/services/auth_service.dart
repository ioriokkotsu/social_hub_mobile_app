import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Stream to listen to authentication state changes (logged in or logged out)
  // This is what StreamBuilder in main.dart listens to!
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Get the current logged-in user
  User? get currentUser => _auth.currentUser;

  // --- Sign Up with Email & Password ---
  Future<UserCredential> signUpWithEmail(String email, String password, {String? name}) async {
    try {
      // 1. Create the user in Firebase Auth
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // 2. Auto-create the user document in the 'users' Firestore collection
      if (userCredential.user != null) {
        await _firestore.collection('users').doc(userCredential.user!.uid).set({
          'uid': userCredential.user!.uid,
          'email': email,
          'displayName': name ?? '', // Save the name if provided
          //'role': 'Volunteer', // Default role for new users
          'createdAt': FieldValue.serverTimestamp(),
          'hoursLogged': 0,
        });
      }

      return userCredential;
    } on FirebaseAuthException catch (e) {
      // Throw custom error messages based on Firebase error codes
      if (e.code == 'weak-password') {
        throw Exception('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        throw Exception('An account already exists for that email.');
      } else if (e.code == 'invalid-email') {
        throw Exception('The email address is not valid.');
      }
      throw Exception(e.message ?? 'An unknown error occurred.');
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // --- Log In with Email & Password ---
  Future<UserCredential> loginWithEmail(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        throw Exception('No user found for that email.');
      } else if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
        throw Exception('Wrong password provided for that user.');
      } else if (e.code == 'invalid-email') {
        throw Exception('The email address is not valid.');
      }
      throw Exception(e.message ?? 'An unknown error occurred.');
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // --- Log Out ---
  Future<void> signOut() async {
    await _auth.signOut();
  }
}