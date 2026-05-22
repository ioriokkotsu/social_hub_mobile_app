import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> renameDocument({
  required String oldDocId,
  required String newDocId,
}) async {

  final firestore = FirebaseFirestore.instance;

  
  DocumentSnapshot oldDoc = await firestore
      .collection('ngo')
      .doc(oldDocId)
      .get();

  if (!oldDoc.exists) {
    print("Old document not found");
    return;
  }

  
  await firestore
      .collection('ngo')
      .doc(newDocId)
      .set(oldDoc.data() as Map<String, dynamic>);

  
  await firestore
      .collection('users')
      .doc(oldDocId)
      .delete();

  print("Document renamed successfully");
}