import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  
  
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  
  User? get currentUser => _auth.currentUser;

  
  Future<UserCredential> signUpWithEmail(
    String email,
    String password, {
    required String name,
    required String occupation,
    required String number,
  }) async {
    try {
      
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      
      if (userCredential.user != null) {
        await _firestore.collection('users').doc(userCredential.user!.uid).set({
          'uid': userCredential.user!.uid,
          'email': email,
          'displayName': name ,
          'occupation': occupation, 
          'createdAt': FieldValue.serverTimestamp(),
          'hoursLogged': 0,
          'profileURL': 'https://res.cloudinary.com/dd7kgf2io/image/upload/v1779262634/empty_profile_cl2y8s.jpg',
          'contactNumber': number,
          'listJoinedEvents': [],
        });
      }

      return userCredential;
    } on FirebaseAuthException catch (e) {
      
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

  
  Future<UserCredential> signUpNgoWithEmail(
    String email,
    String password, {
    String? name,
  }) async {
    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      if (userCredential.user != null) {
        await _firestore.collection('ngo').doc(userCredential.user!.uid).set({
          'uid': userCredential.user!.uid,
          'email': email,
          'organizationName': name ?? '',
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      return userCredential;
    } on FirebaseAuthException catch (e) {
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

  
  Future<void> signOut() async {
    await _auth.signOut();
  }

  
  Future<Map<String, dynamic>?> getUserData(String? uid) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection('users')
          .doc(uid)
          .get();
      if (doc.exists) {
        return doc.data() as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      throw Exception('Failed to fetch user data: ${e.toString()}');
    }
  }

  
  Stream<DocumentSnapshot<Map<String, dynamic>>> getUserDataSnapshot(
    String? uid,
  ) {
    return _firestore.collection('users').doc(uid).snapshots();
  }

  
  Future<Map<String, dynamic>?> getCollectionData(
    dynamic referenceOrUid,
    String collection,
  ) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> doc;

      if (referenceOrUid is DocumentReference<Map<String, dynamic>>) {
        doc = await referenceOrUid.get();
      } else {
        
        doc = await _firestore.collection(collection).doc(referenceOrUid).get();
      }

      if (doc.exists) {
        final data = doc.data()!;

        data['uid'] = doc.id;
        return data;
      }

      return null;
    } catch (e) {
      throw Exception('Failed to fetch collection data: ${e.toString()}');
    }
  }

  
  Stream<DocumentSnapshot<Map<String, dynamic>>> getCollectionDataSnapshot(
    dynamic referenceOrUid,
    String collection,
  ) {
    DocumentReference<Map<String, dynamic>> docRef;

    if (referenceOrUid is DocumentReference<Map<String, dynamic>>) {
      docRef = referenceOrUid;
    } else {
      docRef = _firestore.collection(collection).doc(referenceOrUid);
    }

    return docRef.snapshots();
  }

  
  Future<List<Map<String, dynamic>>> getUsers(String collection) async {
    try {
      QuerySnapshot<Map<String, dynamic>> snapshot = await _firestore
          .collection(collection)
          .get();

      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      throw Exception('Failed to fetch collection data: ${e.toString()}');
    }
  }

  
  Stream<QuerySnapshot<Map<String, dynamic>>> getCollectionStream(
    String collection,
  ) {
    return _firestore.collection(collection).snapshots();
  }

  
  Future<List<Map<String, dynamic>>> getQueryAdvanced({
    List<Map<String, dynamic>>? filters,
    required String collection,
  }) async {
    try {
      Query<Map<String, dynamic>> query = _firestore.collection(collection);

      if (filters != null) {
        for (var f in filters) {
          query = query.where(f['field'], isEqualTo: f['value']);
        }
      }

      final snapshot = await query.get();

      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      throw Exception('Failed to fetch collection data: ${e.toString()}');
    }
  }

  
  Future<void> updateCollection(String uid, Map<String, dynamic> data) async {
    try {
      await _firestore.collection('users').doc(uid).update(data);
    } catch (e) {
      throw Exception('Failed to update user data: ${e.toString()}');
    }
  }

  
  Future<String?> getFieldOfCollectionFromPath(String path,String fieldName) async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance.doc(path).get();

      if (doc.exists) {
        return doc[fieldName];
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  
  Future<void> addDocToCollection(String collection, Map<String, dynamic> data) async {
    try {
      await _firestore.collection(collection).add(data);
    } catch (e) {
      throw Exception('Failed to add data to collection: ${e.toString()}');
    }
  }
}
