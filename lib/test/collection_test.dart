import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> renameDocument({
  required String oldDocId,
  required String newDocId,
}) async {

  final firestore = FirebaseFirestore.instance;

  // 1. Read old document
  DocumentSnapshot oldDoc = await firestore
      .collection('ngo')
      .doc(oldDocId)
      .get();

  if (!oldDoc.exists) {
    print("Old document not found");
    return;
  }

  // 2. Copy data to new document
  await firestore
      .collection('ngo')
      .doc(newDocId)
      .set(oldDoc.data() as Map<String, dynamic>);

  // 3. Delete old document
  await firestore
      .collection('users')
      .doc(oldDocId)
      .delete();

  print("Document renamed successfully");
}