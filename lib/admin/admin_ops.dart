import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:social_hub/services/auth_service.dart';

Future<void> updateApplicationStatus(
  DocumentReference userRef,
  String newStatus,
  String applicationID,
) async {
  try {
    await FirebaseFirestore.instance
        .collection('volunteerApplication')
        .doc(applicationID)
        .update({'status': newStatus});

    if (newStatus == 'Approved') {
      DocumentSnapshot applicationDoc = await FirebaseFirestore.instance
          .collection('volunteerApplication')
          .doc(applicationID)
          .get();
      if (applicationDoc.exists) {
        DocumentReference userRef = applicationDoc['userID'];
        DocumentReference eventRef = applicationDoc['eventID'];

        await userRef.update({
          'listJoinedEvents': FieldValue.arrayUnion([
            {'eventID': eventRef, 'totalLogHours': 0},
          ]),
        });

        await eventRef.update({
          'listJoinedVolunteers': FieldValue.arrayUnion([
            {'userID': userRef, 'totalLogHours': 0},
          ]),
        });
      }
    }
  } catch (e) {
    print('Error updating application status: ${e.toString()}');
    throw Exception('Failed to update application status: ${e.toString()}');
  }
}

Future<void> submitLogHours(
  DocumentReference userRef,
  DocumentReference eventRef,
  int hours,
  String taskCompleted,
  DateTime? logsDate,
) async {
  try {
    await AuthService().addDocToCollection('volunteerLogs', {
      'userID': userRef,
      'eventID': eventRef,
      'ngoID': (await eventRef.get())['organizedBy'],
      'hoursClaimed': hours,
      'submittedAt': FieldValue.serverTimestamp(),
      'logsDate': logsDate ?? FieldValue.serverTimestamp(),
      'status': 'Pending',
      'taskCompleted': taskCompleted,
    });
  } catch (e) {
    throw Exception('Failed to submit log hours: ${e.toString()}');
  }
}

Future<void> updateStatusLogHours(String logID, String newStatus) async {
  try {
    DocumentReference logRef = FirebaseFirestore.instance
        .collection('volunteerLogs')
        .doc(logID);

    DocumentSnapshot logDoc = await logRef.get();

    await logRef.update({'status': newStatus});

    if (newStatus == 'Approved') {

      //User
      DocumentSnapshot userDoc = await logDoc['userID'].get();
      List listJoinedEvents = List.from(userDoc['listJoinedEvents'] ?? []);

      for (int i = 0; i < listJoinedEvents.length; i++) {
        if (listJoinedEvents[i]['eventID'] == logDoc['eventID']) {
          listJoinedEvents[i]['totalLogHours'] += logDoc['hoursClaimed'];
          break;
        }
      }

      int currentHoursLogged = userDoc['hoursLogged'] ?? 0;
      await userDoc.reference.update({'hoursLogged': currentHoursLogged + logDoc['hoursClaimed']});

      await logDoc['userID'].update({'listJoinedEvents': listJoinedEvents});

      //Event
      DocumentSnapshot eventDoc = await logDoc['eventID'].get();
      List listJoinedVolunteers = List.from(
        eventDoc['listJoinedVolunteers'] ?? [],
      );

      for (int i = 0; i < listJoinedVolunteers.length; i++) {
        if (listJoinedVolunteers[i]['userID'] == logDoc['userID']) {
          listJoinedVolunteers[i]['totalLogHours'] += logDoc['hoursClaimed'];
          break;
        }
      }

      await logDoc['eventID'].update({'listJoinedVolunteers': listJoinedVolunteers});
    }
  } catch (e) {
    throw Exception('Failed to approve log hours: ${e.toString()}');
  }
}
