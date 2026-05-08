import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

Future<List<DocumentSnapshot>> searchEvents(
  String keyword,
  // DocumentReference? currentUser,
  String searchBy,
  BuildContext context,
) async {
  if (keyword.trim().isEmpty) {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('communityEvents')
        .get();
    return snapshot.docs;
  }
  try {
    String searchKeyword = keyword.toLowerCase();

    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('communityEvents')
        .get();

    List<DocumentSnapshot> matchedEvents = [];

    for (var doc in querySnapshot.docs) {
      // if (currentUser != null && doc.reference.path == currentUser.path) {
      //   continue;
      // }

      Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;

      if (data == null) continue;

      String? fieldValue;

      switch (searchBy.toLowerCase()) {
        case 'title':
          fieldValue = data['eventTitle'] as String?;
          break;
        case 'username':
          fieldValue = data['username'] as String?;
          break;
        case 'email':
          fieldValue = data['email'] as String?;
          break;
        default:
          // Default to eventTitle if invalid searchBy value
          fieldValue = data['eventTitle'] as String?;
          break;
      }

      if (fieldValue != null) {
        if (fieldValue.toLowerCase().contains(searchKeyword)) {
          matchedEvents.add(doc);
        }
      }
    }

    matchedEvents.sort((a, b) {
      String aField = '';
      String bField = '';

      // Get the appropriate field for sorting
      switch (searchBy.toLowerCase()) {
        case 'title':
          aField = a.get('eventTitle')?.toString().toLowerCase() ?? '';
          bField = b.get('eventTitle')?.toString().toLowerCase() ?? '';
          break;
        case 'username':
          aField = a.get('username')?.toString().toLowerCase() ?? '';
          bField = b.get('username')?.toString().toLowerCase() ?? '';
          break;
        case 'email':
          aField = a.get('email')?.toString().toLowerCase() ?? '';
          bField = b.get('email')?.toString().toLowerCase() ?? '';
          break;
        default:
          aField = a.get('eventTitle')?.toString().toLowerCase() ?? '';
          bField = b.get('eventTitle')?.toString().toLowerCase() ?? '';
          break;
      }

      bool aStartsWith = aField.startsWith(searchKeyword);
      bool bStartsWith = bField.startsWith(searchKeyword);

      if (aStartsWith && !bStartsWith) return -1;
      if (!aStartsWith && bStartsWith) return 1;

      return aField.compareTo(bField);
    });

    print("Search completed successfully");
    return matchedEvents;
  } catch (e) {
    print('Error in search: $e');
    return [];
  }
}
