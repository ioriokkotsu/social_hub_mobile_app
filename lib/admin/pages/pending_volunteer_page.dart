import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:social_hub/admin/admin_ops.dart';
import 'package:social_hub/services/stream_builder.dart';
import 'package:social_hub/theme/theme.dart';

class PendingVolunteersPage extends StatefulWidget {
  const PendingVolunteersPage({
    super.key,
    required this.eventID,
    required this.title,
  });

  final String eventID;
  final String title;

  @override
  State<PendingVolunteersPage> createState() => _PendingVolunteersPageState();
}

class _PendingVolunteersPageState extends State<PendingVolunteersPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.appBg,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textMuted),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pending Volunteers',
              style: TextStyle(
                fontFamily: 'Poppins',
                color: AppColors.textMain,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              widget.title,
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(70),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
            child: FirestoreStreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              empty: Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.appBg,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          children: [
                            const Text(
                              'Pending',
                              style: TextStyle(
                                fontSize: 10,
                                color: AppColors.textMuted,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              '0',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: AppColors.accent,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.appBg,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          children:  [
                            Text(
                              'Approved',
                              style: TextStyle(
                                fontSize: 10,
                                color: AppColors.textMuted,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              '0',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              stream: FirebaseFirestore.instance
                  .collection('volunteerApplication')
                  .where(
                    'eventID',
                    isEqualTo: FirebaseFirestore.instance
                        .collection('communityEvents')
                        .doc(widget.eventID),
                  )
                  .snapshots(),
              builder: (snapshot) {
                final docs = snapshot.docs;
                int pending = 0;
                for (final doc in docs) {
                  if (doc['status'] == 'Pending') {
                    pending++;
                  }
                }
                int approved = 0;
                for (final doc in docs) {
                  if (doc['status'] == 'Approved') {
                    approved++;
                  }
                }
                return Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.appBg,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          children: [
                            const Text(
                              'Pending',
                              style: TextStyle(
                                fontSize: 10,
                                color: AppColors.textMuted,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              '$pending',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: AppColors.accent,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.appBg,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          children: [
                            Text(
                              'Approved',
                              style: TextStyle(
                                fontSize: 10,
                                color: AppColors.textMuted,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              '$approved',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
      body: FirestoreStreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        empty: const Center(
          child: Text(
            "No pending volunteers",
            style: TextStyle(fontSize: 14, color: AppColors.textMuted),
          ),
        ),
        stream: FirebaseFirestore.instance
            .collection('volunteerApplication')
            .where(
              'eventID',
              isEqualTo: FirebaseFirestore.instance
                  .collection('communityEvents')
                  .doc(widget.eventID),
            )
            .where('status', isEqualTo: 'Pending')
            .snapshots(),
        builder: (snapshot) {
          final docs = snapshot.docs;
          return ListView.separated(
            padding: const EdgeInsets.all(24),
            physics: const BouncingScrollPhysics(),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final application = docs[index].data();
              return _buildPendingCard(
                id: docs[index].id,
                ref: docs[index].reference,
                userRef:
                    application['userID']
                        as DocumentReference<Map<String, dynamic>>,
                role: application['roleApplied'] ?? '',
                motivation: application['motivationText'] ?? '',
              );
            },
            separatorBuilder: (context, index) => const SizedBox(height: 16),
          );
        },
      ),
    );
  }

  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  

  Widget _buildPendingCard({
    required String id,
    required DocumentReference<Map<String, dynamic>> userRef,
    required String role,
    String? motivation,
    required DocumentReference ref,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.gray100),
        boxShadow: softShadow,
      ),
      child: Column(
        children: [
          Row(
            children: [
              FirestoreStreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                stream: userRef.snapshots(),
                builder: (userSnapshot) {
                  final user = userSnapshot.data();
                  return CircleAvatar(
                    backgroundImage: NetworkImage(user!['profileURL']),
                    radius: 20,
                  );
                },
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FirestoreStreamBuilder<
                      DocumentSnapshot<Map<String, dynamic>>
                    >(
                      stream: userRef.snapshots(),
                      builder: (userSnapshot) {
                        final user = userSnapshot.data();
                        return Text(
                          user!['displayName'] ?? 'Unknown User',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        );
                      },
                    ),
                    Text(
                      'Role: $role',
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.accent.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'New',
                  style: TextStyle(
                    color: AppColors.accent,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          if (motivation != null)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.appBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  motivation,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textMuted,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () async {
                    await updateApplicationStatus(userRef, 'Approved', id);
                  },
                  icon: const Icon(Icons.check, size: 14),
                  label: const Text(
                    'Approve',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary.withOpacity(0.1),
                    foregroundColor: AppColors.primary,
                    elevation: 0,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () async {
                    await updateApplicationStatus(userRef, 'Rejected', id);
                  },
                  icon: const Icon(Icons.close, size: 14),
                  label: const Text(
                    'Reject',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.red500.withOpacity(0.1),
                    foregroundColor: AppColors.red500,
                    elevation: 0,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
