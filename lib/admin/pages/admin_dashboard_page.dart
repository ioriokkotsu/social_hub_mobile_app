import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:social_hub/admin/admin_ops.dart';
import 'package:social_hub/admin/pages/create_event_page.dart';
import 'package:social_hub/admin/pages/event_detail_page.dart';
import 'package:social_hub/admin/pages/pending_volunteer_page.dart';
import 'package:social_hub/admin/pages/volunteer_list_page.dart';
import 'package:social_hub/services/auth_service.dart';
import 'package:social_hub/services/future_builder.dart';
import 'package:social_hub/services/stream_builder.dart';
import 'package:social_hub/theme/theme.dart';
// import 'create_event_page.dart';
// import 'event_detail_page.dart';
// import 'volunteer_list_page.dart';
// import 'pending_volunteers_page.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  int _mainTabIndex = 0; // 0: Overview, 1: Manage, 2: Requests
  int _reqTabIndex = 0; // 0: Apps, 1: Hours

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.appBg,
      body: Column(
        children: [
          // Sticky Top Header
          Container(
            padding: const EdgeInsets.fromLTRB(24, 48, 24, 24),
            decoration: const BoxDecoration(
              color: AppColors.textMain,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(32),
                bottomRight: Radius.circular(32),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ADMIN HUB',
                          style: TextStyle(
                            color: Colors.white60,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                          ),
                        ),
                        SizedBox(height: 2),
                        FirestoreFutureBuilder(
                          width: 140.7,
                          height: 29,
                          future: AuthService().getCollectionData(
                            AuthService().currentUser?.uid,
                            'ngo',
                          ),
                          builder: (ngo) {
                            return Text(
                              ngo?['ngoName'] ?? 'Admin',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: () => AuthService().signOut(),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: const [
                            Icon(Icons.logout, color: Colors.white, size: 14),
                            SizedBox(width: 4),
                            Text(
                              'Exit',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Animated Main Tabs (Pill Design)
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      _buildMainTab(0, 'Overview'),
                      _buildMainTab(1, 'Manage'),
                      _buildMainTab(2, 'Requests'),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Content Area
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _buildTabContent(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainTab(int index, String title) {
    bool isActive = _mainTabIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _mainTabIndex = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isActive ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isActive ? softShadow : [],
          ),
          alignment: Alignment.center,
          child: Text(
            title,
            style: TextStyle(
              fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
              fontSize: 14,
              color: isActive
                  ? AppColors.textMain
                  : Colors.white.withOpacity(0.8),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    switch (_mainTabIndex) {
      case 0:
        return _buildOverviewTab();
      case 1:
        return _buildManageTab();
      case 2:
        return _buildRequestsTab();
      default:
        return const SizedBox();
    }
  }

  // ================= 1. OVERVIEW TAB =================
  Widget _buildOverviewTab() {
    return ListView(
      key: const ValueKey('overview'),
      padding: const EdgeInsets.all(24),
      physics: const BouncingScrollPhysics(),
      children: [
        Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: softShadow,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Raised',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textMuted,
                      ),
                    ),
                    SizedBox(height: 4),
                    FirestoreFutureBuilder<QuerySnapshot>(
                      width: 140,
                      height: 29,
                      future: FirebaseFirestore.instance
                          .collection('communityEvents')
                          .where(
                            'organizedBy',
                            isEqualTo: FirebaseFirestore.instance
                                .collection('ngo')
                                .doc(AuthService().currentUser?.uid),
                          )
                          .get(),
                      builder: (event) {
                        double totalRaised = 0;
                        for (var doc in event.docs) {
                          final data = doc.data() as Map<String, dynamic>;

                          final raised = data['amountRaised'] ?? 0;

                          totalRaised += (raised as num).toDouble();
                        }
                        return Text(
                          event.docs.isNotEmpty
                              ? 'RM${(totalRaised).toStringAsFixed(2)}'
                              : 'RM0.00',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        );
                      },
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
                  boxShadow: softShadow,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Active Vols',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textMuted,
                      ),
                    ),
                    SizedBox(height: 4),
                    FirestoreFutureBuilder<QuerySnapshot>(
                      height: 29,
                      future: FirebaseFirestore.instance
                          .collection('communityEvents')
                          .where(
                            'organizedBy',
                            isEqualTo: FirebaseFirestore.instance
                                .collection('ngo')
                                .doc(AuthService().currentUser?.uid),
                          )
                          .get(),
                      builder: (event) {
                        int totalVolunteers = 0;
                        for (var doc in event.docs) {
                          final data = doc.data() as Map<String, dynamic>;

                          final volunteers = data['listJoinedVolunteers'] ?? [];

                          totalVolunteers += (volunteers as List).length;
                        }
                        return Text(
                          totalVolunteers.toString(),
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textMain,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Chart Mockup
        // Container(
        //   padding: const EdgeInsets.all(20),
        //   decoration: BoxDecoration(
        //     color: AppColors.surface,
        //     borderRadius: BorderRadius.circular(24),
        //     boxShadow: softShadow,
        //   ),
        //   child: Column(
        //     crossAxisAlignment: CrossAxisAlignment.start,
        //     children: [
        //       Row(
        //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //         children: [
        //           const Text(
        //             'Donation Analytics',
        //             style: TextStyle(
        //               fontFamily: 'Poppins',
        //               fontSize: 14,
        //               fontWeight: FontWeight.bold,
        //             ),
        //           ),
        //           Container(
        //             padding: const EdgeInsets.symmetric(
        //               horizontal: 8,
        //               vertical: 4,
        //             ),
        //             decoration: BoxDecoration(
        //               color: AppColors.appBg,
        //               borderRadius: BorderRadius.circular(8),
        //             ),
        //             child: const Text(
        //               'Last 6 Months',
        //               style: TextStyle(
        //                 fontSize: 10,
        //                 fontWeight: FontWeight.bold,
        //                 color: AppColors.textMuted,
        //               ),
        //             ),
        //           ),
        //         ],
        //       ),
        //       const SizedBox(height: 24),
        //       SizedBox(
        //         height: 100,
        //         child: Row(
        //           crossAxisAlignment: CrossAxisAlignment.end,
        //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //           children: [
        //             _buildBar(0.3, AppColors.primary.withOpacity(0.3)),
        //             _buildBar(0.5, AppColors.primary.withOpacity(0.4)),
        //             _buildBar(0.7, AppColors.primary.withOpacity(0.6)),
        //             _buildBar(0.95, AppColors.primary, label: '\$14.8k'),
        //             _buildBar(0.6, AppColors.primary.withOpacity(0.4)),
        //             _buildBar(0.4, AppColors.primary.withOpacity(0.3)),
        //           ],
        //         ),
        //       ),
        //       const SizedBox(height: 8),
        //       Row(
        //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //         children: const [
        //           Text(
        //             'Nov',
        //             style: TextStyle(fontSize: 10, color: AppColors.textMuted),
        //           ),
        //           Text(
        //             'Dec',
        //             style: TextStyle(fontSize: 10, color: AppColors.textMuted),
        //           ),
        //           Text(
        //             'Jan',
        //             style: TextStyle(fontSize: 10, color: AppColors.textMuted),
        //           ),
        //           Text(
        //             'Feb',
        //             style: TextStyle(
        //               fontSize: 10,
        //               fontWeight: FontWeight.bold,
        //               color: AppColors.textMain,
        //             ),
        //           ),
        //           Text(
        //             'Mar',
        //             style: TextStyle(fontSize: 10, color: AppColors.textMuted),
        //           ),
        //           Text(
        //             'Apr',
        //             style: TextStyle(fontSize: 10, color: AppColors.textMuted),
        //           ),
        //         ],
        //       ),
        //     ],
        //   ),
        // ),

        const SizedBox(height: 16),
        const Text(
          'Event Impact Summary',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        FirestoreFutureBuilder<QuerySnapshot<Map<String, dynamic>>>(
          future: FirebaseFirestore.instance
              .collection('communityEvents')
              .where(
                'organizedBy',
                isEqualTo: FirebaseFirestore.instance
                    .collection('ngo')
                    .doc(AuthService().currentUser?.uid),
              )
              .get(),
          builder: (snapshot) {
            final docs = snapshot.docs;
            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: docs.length,
              itemBuilder: (context, index) {
                final event = docs[index].data();
                return _buildImpactSummaryCard(
                  event['eventTitle'] ?? '',
                  event['status'] ?? '',
                  event['amountRaised'] ?? 0,
                  event['amountTarget'] ?? 0,
                  (event['listJoinedVolunteers'] ?? []).length,
                  event['targetVolunteers'] ?? 0,
                  docs[index].id,
                );
              },
              separatorBuilder: (context, index) => const SizedBox(height: 12),
            );
          },
        ),
      ],
    );
  }

  Widget _buildBar(double heightFactor, Color color, {String? label}) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            if (label != null)
              Container(
                margin: const EdgeInsets.only(bottom: 4),
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            FractionallySizedBox(
              widthFactor: 1,
              child: Container(
                height: 100 * heightFactor,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImpactSummaryCard(
    String title,
    String status,
    double raised,
    double target,
    int vols,
    int targetVols,
    String eventID,
  ) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        createSlideRoute(EventDetailPage(eventID: eventID)),
      ),
      child: Container(
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: switch (status) {
                      'Active' => Colors.green.withOpacity(0.1),
                      'Closing Soon' => AppColors.accent.withOpacity(0.1),
                      _ => AppColors.textMuted.withOpacity(0.1),
                    },
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    status.toUpperCase(),
                    style: TextStyle(
                      color: switch (status) {
                        'Active' => Colors.green,
                        'Closing Soon' => AppColors.accent,
                        _ => AppColors.textMuted,
                      },
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Donations Raised',
                        style: TextStyle(
                          fontSize: 10,
                          color: AppColors.textMuted,
                        ),
                      ),
                      RichText(
                        text: TextSpan(
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            color: AppColors.primary,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                          children: [
                            TextSpan(text: 'RM${(raised).toStringAsFixed(2)}'),
                            TextSpan(
                              text: ' / RM${(target).toStringAsFixed(2)}',
                              style: const TextStyle(
                                color: AppColors.textMuted,
                                fontSize: 10,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 6),
                      LinearProgressIndicator(
                        value: raised / target,
                        backgroundColor: AppColors.gray100,
                        color: AppColors.primary,
                        minHeight: 4,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: AppColors.gray100,
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Volunteers Joined',
                        style: TextStyle(
                          fontSize: 10,
                          color: AppColors.textMuted,
                        ),
                      ),
                      const SizedBox(height: 10),
                      RichText(
                        text: TextSpan(
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            color: AppColors.textMain,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                          children: [
                            TextSpan(
                              text: '$vols ',
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 6),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ================= 2. MANAGE TAB =================
  Widget _buildManageTab() {
    return ListView(
      key: const ValueKey('manage'),
      padding: const EdgeInsets.all(24),
      physics: const BouncingScrollPhysics(),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Active Events',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            GestureDetector(
              onTap: () => Navigator.push(
                context,
                createSlideRoute(const CreateEventPage()),
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  '+ Create Event',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
        FirestoreFutureBuilder<QuerySnapshot<Map<String, dynamic>>>(
          future: FirebaseFirestore.instance
              .collection('communityEvents')
              .where(
                'organizedBy',
                isEqualTo: FirebaseFirestore.instance
                    .collection('ngo')
                    .doc(AuthService().currentUser?.uid),
              )
              .where('status', isEqualTo: 'Active')
              .get(),
          builder: (snapshot) {
            final docs = snapshot.docs;
            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: docs.length,
              itemBuilder: (context, index) {
                final event = docs[index].data();
                return _buildManageEventCard(
                  event['eventTitle'] ?? '',
                  event['status'] ?? '',
                  Icons.calendar_today,
                  eventID: docs[index].id,
                );
              },
              separatorBuilder: (context, index) => const SizedBox(height: 12),
            );
          },
        ),
        // _buildManageEventCard(
        //   'Rural Tech Ed',
        //   'Ongoing • 12 Tasks assigned',
        //   Icons.calendar_today,
        // ),
        const Text(
          'Past Events',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        FirestoreFutureBuilder<QuerySnapshot<Map<String, dynamic>>>(
          future: FirebaseFirestore.instance
              .collection('communityEvents')
              .where(
                'organizedBy',
                isEqualTo: FirebaseFirestore.instance
                    .collection('ngo')
                    .doc(AuthService().currentUser?.uid),
              )
              .where('status', isEqualTo: 'Past')
              .get(),
          builder: (snapshot) {
            final docs = snapshot.docs;
            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: docs.length,
              itemBuilder: (context, index) {
                final event = docs[index].data();
                return _buildManageEventCard(
                  event['eventTitle'] ?? '',
                  event['status'] ?? '',
                  Icons.event_available,
                  isPast: true,
                  eventID: docs[index].id,
                );
              },
              separatorBuilder: (context, index) => const SizedBox(height: 12),
            );
          },
        ),
        // Opacity(
        //   opacity: 0.7,
        //   child: _buildManageEventCard(
        //     'Digital Literacy Camp',
        //     'Completed Oct 2023 • Goal Met',
        //     Icons.event_available,
        //     isPast: true,
        //   ),
        // ),

        // const SizedBox(height: 24),
        const Text(
          'Volunteer Roster',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        FirestoreFutureBuilder<QuerySnapshot<Map<String, dynamic>>>(
          future: FirebaseFirestore.instance
              .collection('communityEvents')
              .where(
                'organizedBy',
                isEqualTo: FirebaseFirestore.instance
                    .collection('ngo')
                    .doc(AuthService().currentUser?.uid),
              )
              .get(),
          builder: (snapshot) {
            final docs = snapshot.docs;
            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: docs.length,
              itemBuilder: (context, index) {
                final event = docs[index].data();
                final volunteers = event['listJoinedVolunteers'] ?? [];
                return _buildVolunteerRosterGroup(
                  event['eventTitle'] ?? '',
                  volunteers.length,
                  eventID: docs[index].id,
                );
              },
              separatorBuilder: (context, index) => const SizedBox(height: 12),
            );
          },
        ),
      ],
    );
  }

  Widget _buildManageEventCard(
    String title,
    String sub,
    IconData icon, {
    bool isPast = false,
    required String eventID,
  }) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        createSlideRoute(EventDetailPage(eventID: eventID)),
      ),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isPast
                ? AppColors.gray100
                : AppColors.primary.withOpacity(0.3),
          ),
          boxShadow: softShadow,
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isPast
                    ? AppColors.gray100
                    : AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: isPast ? Colors.grey : AppColors.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    sub,
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }

  Widget _buildVolunteerRosterGroup(
    String project,
    int vols, {
    required String eventID,
  }) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        createSlideRoute(VolunteerListPage(eventID: eventID)),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.gray100),
          boxShadow: softShadow,
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.people, color: AppColors.primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    project,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    '$vols Active Volunteers',
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.textMuted,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }

  // ================= 3. REQUESTS TAB =================
  Widget _buildRequestsTab() {
    return Column(
      key: const ValueKey('requests'),
      children: [
        // Smooth Animated Sliding Sub-Tab Bar
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
                AnimatedAlign(
                  alignment: _reqTabIndex == 0
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
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _reqTabIndex = 0),
                        behavior: HitTestBehavior.opaque,
                        child: Center(
                          child: Text(
                            'Applications',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: _reqTabIndex == 0
                                  ? AppColors.textMain
                                  : AppColors.textMuted,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _reqTabIndex = 1),
                        behavior: HitTestBehavior.opaque,
                        child: Center(
                          child: Text(
                            'Pending Hours',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: _reqTabIndex == 1
                                  ? AppColors.textMain
                                  : AppColors.textMuted,
                            ),
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
            child: _reqTabIndex == 0
                ? _buildApplicationsSubTab()
                : _buildPendingHoursSubTab(),
          ),
        ),
      ],
    );
  }

  Widget _buildApplicationsSubTab() {
    return ListView(
      key: const ValueKey('apps'),
      padding: const EdgeInsets.all(24),
      physics: const BouncingScrollPhysics(),
      children: [
        const Text(
          'Pending Applications by Event',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        FirestoreFutureBuilder<QuerySnapshot<Map<String, dynamic>>>(
          future: FirebaseFirestore.instance
              .collection('communityEvents')
              .where(
                'organizedBy',
                isEqualTo: FirebaseFirestore.instance
                    .collection('ngo')
                    .doc(AuthService().currentUser?.uid),
              )
              .get(),
          builder: (snapshot) {
            final docs = snapshot.docs;
            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: docs.length,
              itemBuilder: (context, index) {
                final event = docs[index].data();
                return _buildRequestGroup(
                  event['eventTitle'] ?? '',
                  docs[index].id,
                );
              },
              separatorBuilder: (context, index) => const SizedBox(height: 12),
            );
          },
        ),
      ],
    );
  }

  Widget _buildRequestGroup(String title, String eventID) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        createSlideRoute(PendingVolunteersPage(eventID: eventID, title: title)),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border(left: BorderSide(color: AppColors.primary, width: 4)),
          boxShadow: softShadow,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: AppColors.textMain,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 6),
                  FirestoreStreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                    empty: Row(
                      children: [
                        Text(
                          '0 Pending',
                          style: TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          '0 Approved',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
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
                              .doc(eventID),
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
                          Text(
                            '$pending Pending',
                            style: TextStyle(
                              color: pending > 0
                                  ? AppColors.accent
                                  : AppColors.textMuted,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            '$approved Approved',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.textMain),
          ],
        ),
      ),
    );
  }

  Widget _buildPendingHoursSubTab() {
    return ListView(
      key: const ValueKey('hours'),
      padding: const EdgeInsets.all(24),
      physics: const BouncingScrollPhysics(),
      children: [
        const Text(
          'Logs Awaiting Approval',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        FirestoreStreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          empty: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 50),
                Icon(
                  Icons.access_time,
                  size: 48,
                  color: const Color.fromARGB(255, 0, 0, 0),
                ),
                const SizedBox(height: 12),
                Text(
                  'No pending logs',
                  style: TextStyle(
                    fontSize: 14,
                    color: const Color.fromARGB(255, 0, 0, 0),
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
          stream: FirebaseFirestore.instance
              .collection('volunteerLogs')
              .where(
                'ngoID',
                isEqualTo: FirebaseFirestore.instance
                    .collection('ngo')
                    .doc(AuthService().currentUser?.uid),
              )
              .where('status', isEqualTo: 'Pending')
              .snapshots(),
          builder: (logs) {
            final docs = logs.docs;
            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: docs.length,
              itemBuilder: (context, index) {
                final log = docs[index].data();
                return _buildLogsRequest(
                  log['eventID'],
                  docs[index].id,
                  log['userID'],
                  log['taskCompleted'],
                  log['hoursClaimed'],
                );
              },
              separatorBuilder: (context, index) => const SizedBox(height: 12),
            );
          },
        ),
      ],
    );
  }
}

Widget _buildLogsRequest(
  DocumentReference eventRef,
  String logID,
  DocumentReference userRef,
  String taskCompleted,
  int hoursClaimed,
) {
  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: AppColors.gray100),
      boxShadow: softShadow,
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                FirestoreFutureBuilder(
                  future: userRef.get(),
                  builder: (user) {
                    return CircleAvatar(
                      backgroundImage: NetworkImage(
                        user['profileURL'] ??
                            'https://i.pravatar.cc/150?img=32',
                      ),
                      radius: 20,
                    );
                  },
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FirestoreFutureBuilder(
                      future: userRef.get(),
                      builder: (user) {
                        return Text(
                          user['displayName'] ?? 'Alex Volunteer',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        );
                      },
                    ),
                    FirestoreFutureBuilder(
                      future: eventRef.get(),
                      builder: (event) {
                        return Text(
                          event['eventTitle'] ?? 'Event Title',
                          style: TextStyle(
                            fontSize: 10,
                            color: AppColors.textMuted,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.access_time, size: 14, color: AppColors.primary),
                  SizedBox(width: 4),
                  Text(
                    '$hoursClaimed Hrs',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.appBg,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'TASKS COMPLETED',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textMuted,
                ),
              ),
              SizedBox(height: 4),
              Text(
                '" $taskCompleted "',
                style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () async {
                  await updateStatusLogHours(logID, 'Approved');
                },
                icon: const Icon(Icons.check, size: 16),
                label: const Text(
                  'Approve',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () async {
                  await updateStatusLogHours(logID, 'Rejected');
                },
                icon: const Icon(Icons.close, size: 16),
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
