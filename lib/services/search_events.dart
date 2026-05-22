import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

Future<List<DocumentSnapshot>> searchEvents(
  String keyword,
  String searchBy,
  BuildContext context,
  String? eventCategory
) async {
  bool isAll = eventCategory == 'All';
  if (keyword.trim().isEmpty) {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('communityEvents')
        .where('eventCategory', isEqualTo: isAll ? null : eventCategory)
        .get();
    return snapshot.docs;
  }
  try {
    String searchKeyword = keyword.toLowerCase();

    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('communityEvents')
        .where('eventCategory', isEqualTo: isAll ? null : eventCategory)
        .get();

    List<DocumentSnapshot> matchedEvents = [];

    for (var doc in querySnapshot.docs) {

      Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;

      if (data == null) continue;

      String? fieldValue;

      switch (searchBy.toLowerCase()) {
        case 'title':
          fieldValue = data['eventTitle'] as String?;
          break;
        default:
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

      
      switch (searchBy.toLowerCase()) {
        case 'title':
          aField = a.get('eventTitle')?.toString().toLowerCase() ?? '';
          bField = b.get('eventTitle')?.toString().toLowerCase() ?? '';
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

    return matchedEvents;
  } catch (e) {
    return [];
  }
}
