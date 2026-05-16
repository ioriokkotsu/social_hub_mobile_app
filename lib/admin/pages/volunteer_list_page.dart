import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:social_hub/services/auth_service.dart';
import 'package:social_hub/services/future_builder.dart';
import 'package:social_hub/theme/theme.dart';

class VolunteerListPage extends StatefulWidget {
  final String eventID;

  const VolunteerListPage({super.key, required this.eventID});

  @override
  State<VolunteerListPage> createState() => _VolunteerListPageState();
}

class _VolunteerListPageState extends State<VolunteerListPage> {
  void _showVolunteerDetailSheet(
    BuildContext context,
    String name,
    String role,
    String email,
    String phone,
    String occupation,
    String hours,
    String imgUrl,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(32),
              topRight: Radius.circular(32),
            ),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundImage: NetworkImage(imgUrl),
                        radius: 32,
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textMain,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              role.toUpperCase(),
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: AppColors.gray100,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(Icons.close, size: 16),
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildDetailRow(Icons.email, email),
              const SizedBox(height: 12),
              _buildDetailRow(Icons.phone, phone),
              const SizedBox(height: 12),
              _buildDetailRow(Icons.work, occupation),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.access_time,
                      color: AppColors.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 16),
                    Text(
                      hours,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Row(
              //   children: [
              //     Expanded(
              //       child: OutlinedButton.icon(
              //         onPressed: () => Navigator.pop(context),
              //         icon: const Icon(Icons.email),
              //         label: const Text('Email'),
              //         style: OutlinedButton.styleFrom(
              //           foregroundColor: AppColors.textMain,
              //           padding: const EdgeInsets.symmetric(vertical: 16),
              //           shape: RoundedRectangleBorder(
              //             borderRadius: BorderRadius.circular(12),
              //           ),
              //           side: const BorderSide(color: AppColors.gray100),
              //         ),
              //       ),
              //     ),
              //     const SizedBox(width: 12),
              //     Expanded(
              //       child: ElevatedButton.icon(
              //         onPressed: () => Navigator.pop(context),
              //         icon: const Icon(Icons.chat_bubble_outline),
              //         label: const Text('Message'),
              //         style: ElevatedButton.styleFrom(
              //           backgroundColor: AppColors.textMain,
              //           foregroundColor: Colors.white,
              //           padding: const EdgeInsets.symmetric(vertical: 16),
              //           shape: RoundedRectangleBorder(
              //             borderRadius: BorderRadius.circular(12),
              //           ),
              //         ),
              //       ),
              //     ),
              //   ],
              // ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.appBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.gray100),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.textMuted, size: 20),
          const SizedBox(width: 16),
          Text(
            text,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textMain,
            ),
          ),
        ],
      ),
    );
  }

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
            const Text(
              'Volunteer Roster',
              style: TextStyle(
                fontFamily: 'Poppins',
                color: AppColors.textMain,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            FirestoreFutureBuilder(
              width: 135.6,
              height: 13,
              future: AuthService().getCollectionData(
                widget.eventID,
                'communityEvents',
              ),
              builder: (event) {
                return Text(
                  event?['eventTitle'] ?? 'Event',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                );
              },
            ),
          ],
        ),
      ),
      body: FirestoreFutureBuilder<QuerySnapshot<Map<String, dynamic>>>(
        future: FirebaseFirestore.instance.collection('users').get(),

        builder: (snapshot) {
          final users = snapshot.docs
              .map((doc) {
                final data = doc.data();

                final events = List<Map<String, dynamic>>.from(
                  data['listJoinedEvents'] ?? [],
                );

                Map<String, dynamic>? matchedEvent;

                for (var event in events) {
                  final ref = event['eventID'] as DocumentReference?;

                  if (ref?.id == widget.eventID) {
                    matchedEvent = event;
                    break;
                  }
                }

                if (matchedEvent == null) {
                  return null;
                }

                return {
                  'user': data,
                  'logHours': matchedEvent['totalLogHours'] ?? 0,
                };
              })
              .whereType<Map<String, dynamic>>()
              .toList();

          return users.isEmpty
              ? const Center(child: Text('No volunteers found.'))
              : ListView.separated(
                  padding: const EdgeInsets.all(24),
                  physics: const BouncingScrollPhysics(),
                  itemCount: users.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final user = users[index]['user'];

                    final logHours = users[index]['logHours'];

                    return _buildVolunteerCard(
                      user['displayName'] ?? 'No Name',
                      user['occupation'] ?? 'Volunteer',
                      '$logHours hrs',
                      user['profileURL'] ?? 'https://i.pravatar.cc/100?img=1',
                      user['email'] ?? 'No Email',
                      user['contactNumber'] ?? 'No Phone',
                      user['occupation'] ?? 'No Occupation',
                    );
                  },
                );
        },
      ),
    );
  }

  Widget _buildVolunteerCard(
    String name,
    String role,
    String hours,
    String imgUrl,
    String email,
    String phone,
    String occupation,
  ) {
    return GestureDetector(
      onTap: () => _showVolunteerDetailSheet(
        context,
        name,
        role,
        email,
        phone,
        occupation,
        hours,
        imgUrl,
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.gray100),
          boxShadow: softShadow,
        ),
        child: Row(
          children: [
            CircleAvatar(backgroundImage: NetworkImage(imgUrl), radius: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    '$role • $hours',
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
