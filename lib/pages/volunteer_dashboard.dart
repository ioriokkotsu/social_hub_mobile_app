import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:social_hub/pages/view_joined_project.dart';
import 'package:social_hub/services/auth_service.dart';
import 'package:social_hub/services/future_builder.dart';
import 'package:social_hub/services/stream_builder.dart';
import 'package:social_hub/theme/theme.dart';

class VolunteerDashboardPage extends StatefulWidget {
  const VolunteerDashboardPage({super.key});

  @override
  State<VolunteerDashboardPage> createState() => _VolunteerDashboardPageState();
}

class _VolunteerDashboardPageState extends State<VolunteerDashboardPage> {
  bool _isTasksTab = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.appBg,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textMuted),
        title: const Text(
          'My Volunteer Dash',
          style: TextStyle(
            fontFamily: 'Poppins',
            color: AppColors.textMain,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Container(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
            alignment: Alignment.centerLeft,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: [
                  // _buildBadgePreview(
                  //   Icons.workspace_premium,
                  //   'Top 10%',
                  //   AppColors.accent,
                  // ),
                  // const SizedBox(width: 12),
                  FirestoreFutureBuilder(
                    future: FirebaseFirestore.instance
                        .collection('users')
                        .doc(AuthService().currentUser!.uid)
                        .get(),
                    builder: (user) {
                      return _buildBadgePreview(
                        Icons.schedule,
                        '${user['hoursLogged'] ?? 0} Hours',
                        AppColors.primary,
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // Smooth Animated Tab Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
            child: Container(
              height: 44,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.grey[200]?.withOpacity(0.7),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Stack(
                children: [
                  // Sliding Indicator
                  AnimatedAlign(
                    alignment: _isTasksTab
                        ? Alignment.centerLeft
                        : Alignment.centerRight,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOutQuart,
                    child: FractionallySizedBox(
                      widthFactor: 0.5,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Tab Buttons
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _isTasksTab = true),
                          behavior: HitTestBehavior.opaque,
                          child: Center(
                            child: AnimatedDefaultTextStyle(
                              duration: const Duration(milliseconds: 200),
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: _isTasksTab
                                    ? AppColors.textMain
                                    : AppColors.textMuted,
                              ),
                              child: const Text('Tasks'),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _isTasksTab = false),
                          behavior: HitTestBehavior.opaque,
                          child: Center(
                            child: AnimatedDefaultTextStyle(
                              duration: const Duration(milliseconds: 200),
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: !_isTasksTab
                                    ? AppColors.textMain
                                    : AppColors.textMuted,
                              ),
                              child: const Text('Projects'),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _isTasksTab
                  ? _buildTasksSection()
                  : _buildProjectsSection(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadgePreview(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        border: Border.all(color: color.withOpacity(0.2)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // --- SECTION 1: Tasks ---
  Widget _buildTasksSection() {
    return ListView(
      key: const ValueKey('tasks'),
      padding: const EdgeInsets.all(24),
      physics: const BouncingScrollPhysics(),
      children: [
        // const Text(
        //   'Upcoming Tasks',
        //   style: TextStyle(
        //     fontFamily: 'Poppins',
        //     fontSize: 16,
        //     fontWeight: FontWeight.bold,
        //   ),
        // ),
        // const SizedBox(height: 12),
        // Container(
        //   padding: const EdgeInsets.all(16),
        //   decoration: BoxDecoration(
        //     color: AppColors.surface,
        //     borderRadius: BorderRadius.circular(16),
        //     boxShadow: softShadow,
        //     border: const Border(
        //       left: BorderSide(color: AppColors.primary, width: 4),
        //     ),
        //   ),
        //   child: Row(
        //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //     children: [
        //       // Column(
        //       //   crossAxisAlignment: CrossAxisAlignment.start,
        //       //   children: [
        //       //     Row(
        //       //       children: [
        //       //         const Text(
        //       //           'Teach HTML Basics',
        //       //           style: TextStyle(
        //       //             fontWeight: FontWeight.bold,
        //       //             fontSize: 14,
        //       //           ),
        //       //         ),
        //       //         const SizedBox(width: 8),
        //       //         Container(
        //       //           padding: const EdgeInsets.symmetric(
        //       //             horizontal: 8,
        //       //             vertical: 2,
        //       //           ),
        //       //           decoration: BoxDecoration(
        //       //             color: AppColors.secondary.withOpacity(0.2),
        //       //             borderRadius: BorderRadius.circular(4),
        //       //           ),
        //       //           child: const Text(
        //       //             'Tomorrow',
        //       //             style: TextStyle(
        //       //               color: AppColors.primary,
        //       //               fontSize: 10,
        //       //               fontWeight: FontWeight.bold,
        //       //             ),
        //       //           ),
        //       //         ),
        //       //       ],
        //       //     ),
        //       //     const SizedBox(height: 4),
        //       //     Row(
        //       //       children: const [
        //       //         Icon(
        //       //           Icons.location_on,
        //       //           size: 12,
        //       //           color: AppColors.textMuted,
        //       //         ),
        //       //         SizedBox(width: 4),
        //       //         Text(
        //       //           'Rural Tech Edu Hub',
        //       //           style: TextStyle(
        //       //             fontSize: 12,
        //       //             color: AppColors.textMuted,
        //       //           ),
        //       //         ),
        //       //       ],
        //       //     ),
        //       //   ],
        //       // ),
        //       // GestureDetector(
        //       //   onTap: () {},
        //       //   child: Container(
        //       //     padding: const EdgeInsets.symmetric(
        //       //       horizontal: 12,
        //       //       vertical: 6,
        //       //     ),
        //       //     decoration: BoxDecoration(
        //       //       color: AppColors.primary.withOpacity(0.1),
        //       //       borderRadius: BorderRadius.circular(8),
        //       //     ),
        //       //     child: const Text(
        //       //       'View',
        //       //       style: TextStyle(
        //       //         color: AppColors.primary,
        //       //         fontSize: 12,
        //       //         fontWeight: FontWeight.bold,
        //       //       ),
        //       //     ),
        //       //   ),
        //       // ),
        //     ],
        //   ),
        // ),

        // const SizedBox(height: 24),
        const Text(
          'Recent Activity',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        FirestoreStreamBuilder<QuerySnapshot>(
          empty: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20.0),
            child: Center(
              child: const Text(
                'You have not created any logs yet.',
                style: TextStyle(color: AppColors.textMuted, fontSize: 14),
              ),
            ),
          ),
          width: 363.4,
          height: 72,
          radius: 12,
          stream: FirebaseFirestore.instance
              .collection('volunteerLogs')
              .where(
                'userID',
                isEqualTo: FirebaseFirestore.instance
                    .collection('users')
                    .doc(AuthService().currentUser!.uid),
              )
              .orderBy('submittedAt', descending: true)
              .snapshots(),
          builder: (logs) {
            return ListView.builder(
              itemCount: logs.docs.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                Map<String, dynamic> log =
                    logs.docs[index].data() as Map<String, dynamic>;
                return Column(
                  children: [
                    _buildActivityItem(
                      eventRef: log['eventID'],
                      status: log['status'],
                      hours: log['hoursClaimed'],
                    ),
                    const SizedBox(height: 16),
                  ],
                );
              },
            );
          },
        ),
        // Pending Log
        // _buildActivityItem(
        //   eventRef: FirebaseFirestore.instance.collection('communityEvents').doc('QzMtSxmpzlPR0VP5qwIc'),
        //   status: 'Pending',
        //   hours: 4,
        // ),

        // // Approved Log
        // _buildActivityItem(
        //   eventRef: FirebaseFirestore.instance.collection('communityEvents').doc('QzMtSxmpzlPR0VP5qwIc'),
        //   status: 'Approved',
        //   hours: 3,
        // ),
      ],
    );
  }

  Widget _buildActivityItem({
    required DocumentReference eventRef,
    required String status,
    required int hours,
  }) {
    Color statusColor = status == 'Approved'
        ? AppColors.primary
        : status == 'Pending'
        ? AppColors.accent
        : Colors.red;
    Color iconColor = status == 'Approved'
        ? AppColors.primary
        : status == 'Pending'
        ? AppColors.accent
        : Colors.red;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: softShadow,
        border: Border(left: BorderSide(color: iconColor, width: 4)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Builder(
              builder: (context) {
                switch (status) {
                  case 'Approved':
                    return Icon(Icons.check_circle, color: iconColor, size: 20);

                  case 'Pending':
                    return Icon(Icons.schedule, color: iconColor, size: 20);

                  case 'Rejected':
                    return Icon(Icons.cancel, color: iconColor, size: 20);

                  default:
                    return Icon(
                      Icons.help,
                      color: AppColors.textMuted,
                      size: 20,
                    );
                }
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FirestoreFutureBuilder(
                  future: eventRef.get(),
                  builder: (event) {
                    return Text(
                      event['eventTitle'] ?? 'Unknown Event',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    );
                  },
                ),
                RichText(
                  text: TextSpan(
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 10,
                      color: AppColors.textMuted,
                    ),
                    children: [
                      TextSpan(text: '$hours Hours  •  '),
                      TextSpan(
                        text: status,
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Stream<List<Map<String, dynamic>>> fetchJoinedProjects() async* {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(AuthService().currentUser!.uid)
          .get();

      List listJoinedEvents = userDoc['listJoinedEvents'] ?? [];
      List<Map<String, dynamic>> projects = [];
      if (listJoinedEvents.isEmpty) {
        yield [];
        return;
      }
      for (var event in listJoinedEvents) {
        DocumentSnapshot eventDoc =
            await (event['eventID'] as DocumentReference).get();

        projects.add({
          'uid': eventDoc.id,
          'eventTitle': eventDoc['eventTitle'],
          'totalLogHours': event['totalLogHours'],
          'eventImageURL':
              eventDoc['eventImageURL'] ??
              'https://images.unsplash.com/photo-1542601906990-b4d3fb778b09?w=100&q=80',
          'status': eventDoc['status'],
        });
      }

      yield projects;
    } catch (e) {
      print('Error fetching joined projects: ${e.toString()}');
      throw Exception('Failed to fetch joined projects: ${e.toString()}');
    }
  }

  // --- SECTION 2: Projects ---
  Widget _buildProjectsSection() {
    return ListView(
      key: const ValueKey('projects'),
      padding: const EdgeInsets.all(24),
      physics: const BouncingScrollPhysics(),
      children: [
        const Text(
          'Joined Projects',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        FirestoreStreamBuilder(
          empty: const Center(
            child: Text(
              'You have not joined any projects yet.',
              style: TextStyle(color: AppColors.textMuted, fontSize: 14),
            ),
          ),
          stream: fetchJoinedProjects(),
          builder: (projects) {
            return projects.isEmpty
                ? Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20.0),
                    child: Center(
                      child: const Text(
                        'You have not joined any projects yet.',
                        style: TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  )
                : Column(
                    spacing: 16,
                    children: projects
                        .map(
                          (project) => _buildJoinedProjectCard(
                            eventTitle: project['eventTitle'],
                            totalLogHours: '${project['totalLogHours']}',
                            eventImageURL: project['eventImageURL'],
                            status: project['status'],
                            eventID: project['uid'],
                          ),
                        )
                        .toList(),
                  );
            Column(
              spacing: 16,
              children: projects
                  .map(
                    (project) => _buildJoinedProjectCard(
                      eventTitle: project['eventTitle'],
                      totalLogHours: '${project['totalLogHours']}',
                      eventImageURL: project['eventImageURL'],
                      status: project['status'],
                      eventID: project['uid'],
                    ),
                  )
                  .toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildJoinedProjectCard({
    required String eventTitle,
    required String totalLogHours,
    required String? eventImageURL,
    required String status,
    required String eventID,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          createSlideRoute(
            ViewJoinedProjectPage(
              eventTitle: eventTitle,
              totalLogHours: totalLogHours,
              eventID: eventID,
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: softShadow,
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                image: DecorationImage(
                  image: NetworkImage(
                    eventImageURL ??
                        'https://images.unsplash.com/photo-1542601906990-b4d3fb778b09?w=100&q=80',
                  ),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    eventTitle,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: status == 'Active'
                              ? Colors.green
                              : Colors.grey,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '$status • $totalLogHours hrs logged',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.primary),
          ],
        ),
      ),
    );
  }
}
