import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:social_hub/admin/admin_ops.dart';
import 'package:social_hub/pages/log_hours_page.dart';
import 'package:social_hub/services/auth_service.dart';
import 'package:social_hub/services/future_builder.dart';
import 'package:social_hub/services/stream_builder.dart';
import 'package:social_hub/theme/theme.dart';

class ViewJoinedProjectPage extends StatefulWidget {
  const ViewJoinedProjectPage({
    super.key,
    required this.eventTitle,
    required this.totalLogHours,
    required this.eventID,
  });

  final String eventTitle;
  final String totalLogHours;
  final String eventID;

  @override
  State<ViewJoinedProjectPage> createState() => _ViewJoinedProjectPageState();
}

class _ViewJoinedProjectPageState extends State<ViewJoinedProjectPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.appBg,
      body: Column(
        children: [
          // Header Image Area
          SizedBox(
            height: 200,
            child: Stack(
              children: [
                Image.network(
                  'https://images.unsplash.com/photo-1542601906990-b4d3fb778b09?w=600&q=80',
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.cover,
                ),
                Container(color: Colors.black.withOpacity(0.4)),
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.3),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.arrow_back,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.2),
                            border: Border.all(
                              color: Colors.green.withOpacity(0.5),
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: Colors.greenAccent[400],
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Text(
                                'Active Volunteer',
                                style: TextStyle(
                                  color: Colors.greenAccent,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Content Body pulled up slightly to overlap image
          Expanded(
            child: Container(
              transform: Matrix4.translationValues(0.0, -24.0, 0.0),
              decoration: const BoxDecoration(
                color: AppColors.appBg,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                physics: const BouncingScrollPhysics(),
                children: [
                  Text(
                    widget.eventTitle,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Personal Impact Stats
                  const Text(
                    'Your Impact Here',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.gray100),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                Icons.schedule,
                                color: AppColors.primary,
                                size: 24,
                              ),
                              SizedBox(height: 8),
                              FirestoreStreamBuilder(
                                stream: FirebaseFirestore.instance
                                    .collection('users')
                                    .doc(AuthService().currentUser!.uid)
                                    .snapshots()
                                    .map((snapshot) {
                                      List joinedEvents =
                                          snapshot['listJoinedEvents'] ?? [];

                                      return joinedEvents.firstWhere(
                                        (e) =>
                                            e['eventID'].id == widget.eventID,
                                        orElse: () => {'totalLogHours': 0},
                                      )['totalLogHours'];
                                    }),
                                builder: (logHours) {
                                  return Text.rich(
                                    TextSpan(
                                      children: [
                                        TextSpan(
                                          text: logHours.toString(),
                                          style: TextStyle(
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.textMain,
                                          ),
                                        ),
                                        TextSpan(
                                          text: ' hrs',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: AppColors.textMuted,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                              SizedBox(height: 4),
                              Text(
                                'LOGGED TIME',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: AppColors.textMuted,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.gray100),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                Icons.check_box_outlined,
                                color: AppColors.accent,
                                size: 24,
                              ),
                              SizedBox(height: 8),
                              FirestoreFutureBuilder(
                                width: 14,
                                height: 34,
                                future: FirebaseFirestore.instance
                                    .collection('volunteerLogs')
                                    .where(
                                      'eventID',
                                      isEqualTo: FirebaseFirestore.instance
                                          .collection('communityEvents')
                                          .doc(widget.eventID),
                                    )
                                    .where(
                                      'userID',
                                      isEqualTo: FirebaseFirestore.instance
                                          .collection('users')
                                          .doc(AuthService().currentUser!.uid),
                                    )
                                    .where('status', isEqualTo: 'Approved')
                                    .get()
                                    .then((snapshot) => snapshot.docs.length),
                                builder: (count) {
                                  return Text(
                                    count.toString(),
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textMain,
                                    ),
                                  );
                                },
                              ),
                              SizedBox(height: 4),
                              Text(
                                'TASKS DONE',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: AppColors.textMuted,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Quick Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              createSlideRoute(
                                LogHoursPage(
                                  eventID: widget.eventID,
                                  eventTitle: widget.eventTitle,
                                  isFromEventDetails: true,
                                ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.add_circle_outline, size: 18),
                          label: const Text(
                            'Log New Hours',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Expanded(
                      //   child: OutlinedButton.icon(
                      //     onPressed: () {
                      //       //Test Function Approved Log
                      //       updateStatusLogHours(
                      //         'AF9yiO68sL9vfKQRDLHF',
                      //         'Approved',
                      //       );
                      //     },
                      //     icon: const Icon(Icons.message, size: 18),
                      //     label: const Text(
                      //       'Volunteer Chat',
                      //       style: TextStyle(
                      //         fontSize: 12,
                      //         fontWeight: FontWeight.bold,
                      //       ),
                      //     ),
                      //     style: OutlinedButton.styleFrom(
                      //       foregroundColor: AppColors.primary,
                      //       side: BorderSide(
                      //         color: AppColors.primary.withOpacity(0.2),
                      //       ),
                      //       padding: const EdgeInsets.symmetric(vertical: 14),
                      //       shape: RoundedRectangleBorder(
                      //         borderRadius: BorderRadius.circular(12),
                      //       ),
                      //       backgroundColor: AppColors.surface,
                      //     ),
                      //   ),
                      // ),
                    ],
                  ),

                  // const SizedBox(height: 32),
                  // const Text(
                  //   'Coordinator Announcements',
                  //   style: TextStyle(
                  //     fontFamily: 'Poppins',
                  //     fontSize: 14,
                  //     fontWeight: FontWeight.bold,
                  //   ),
                  // ),
                  // const SizedBox(height: 12),

                  // _buildAnnouncementCard(
                  //   timeAgo: '2 days ago',
                  //   borderColor: AppColors.blue500,
                  //   content:
                  //       'Thank you to everyone who showed up for the South Beach sector cleanup! We collected over 500lbs of plastic. Please ensure you log your hours by Friday evening so we can process approvals before the weekend.',
                  // ),
                  // _buildAnnouncementCard(
                  //   timeAgo: '1 week ago',
                  //   borderColor: AppColors.secondary,
                  //   content:
                  //       'Welcome to all new volunteers! Please introduce yourselves in the Volunteer Chat. The equipment distribution list has been updated in the pinned messages.',
                  // ),
                  // _buildAnnouncementCard(
                  //   timeAgo: '2 days ago',
                  //   borderColor: AppColors.blue500,
                  //   content:
                  //       'Thank you to everyone who showed up for the South Beach sector cleanup! We collected over 500lbs of plastic. Please ensure you log your hours by Friday evening so we can process approvals before the weekend.',
                  // ),
                  // _buildAnnouncementCard(
                  //   timeAgo: '1 week ago',
                  //   borderColor: AppColors.primary,
                  //   content:
                  //       'Welcome to all new volunteers! Please introduce yourselves in the Volunteer Chat. The equipment distribution list has been updated in the pinned messages.',
                  // ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnnouncementCard({
    required String timeAgo,
    required Color borderColor,
    required String content,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: softShadow,
        border: Border(left: BorderSide(color: borderColor, width: 4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: AppColors.blue500.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Text(
                    'EG',
                    style: TextStyle(
                      color: AppColors.blue500,
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'EduGlobal NGO',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              ),
              const Spacer(),
              Text(
                timeAgo,
                style: const TextStyle(
                  fontSize: 10,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textMain,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
