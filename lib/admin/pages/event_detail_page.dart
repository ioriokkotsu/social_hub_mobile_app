import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:social_hub/admin/pages/volunteer_list_page.dart';
import 'package:social_hub/services/auth_service.dart';
import 'package:social_hub/services/future_builder.dart';
import 'package:social_hub/theme/theme.dart';

class EventDetailPage extends StatefulWidget {
  const EventDetailPage({super.key, required this.eventID});

  final String eventID;

  @override
  State<EventDetailPage> createState() => _EventDetailPageState();
}

class _EventDetailPageState extends State<EventDetailPage> {
  @override
  Widget build(BuildContext context) {
    return FirestoreFutureBuilder(
      future: AuthService().getCollectionData(
        widget.eventID,
        'communityEvents',
      ),
      builder: (event) {
        final roles =
            (event?['requiredRoles'] as List<dynamic>?)
                ?.map((role) => role.toString())
                .toList() ??
            [];
        return Scaffold(
          backgroundColor: AppColors.surface,
          body: Stack(
            children: [
              CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverAppBar(
                    expandedHeight: 220,
                    pinned: true,
                    backgroundColor: AppColors.surface,
                    iconTheme: const IconThemeData(color: Colors.white),
                    actions: [
                      IconButton(
                        icon: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(color: Colors.black12, blurRadius: 4),
                            ],
                          ),
                          child: const Icon(
                            Icons.edit,
                            color: AppColors.primary,
                            size: 16,
                          ),
                        ),
                        onPressed: () {},
                        // onPressed: () => Navigator.push(context, createSlideRoute(const EditEventPage())),
                      ),
                      const SizedBox(width: 16),
                    ],
                    flexibleSpace: FlexibleSpaceBar(
                      background: Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.network(
                            'https://images.unsplash.com/photo-1497645851419-f06bcaeb1525?w=800&q=80',
                            fit: BoxFit.cover,
                          ),
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                colors: [
                                  Colors.black.withOpacity(0.8),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 16,
                            left: 16,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: switch (event?['status'] ?? 'Unknown') {
                                  'Active' => AppColors.primary,
                                  'Closing Soon' => AppColors.accent,
                                  _ => AppColors.textMuted,
                                },
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                event?['status'].toString().toUpperCase() ??
                                    'Unknown',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 24, 24, 100),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.menu_book,
                                color: AppColors.primary,
                                size: 12,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                event?['eventCategory'].toUpperCase() ?? 'No Category',
                                style: const TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            event?['eventTitle'] ?? 'No Event Title',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(
                                Icons.location_on,
                                color: AppColors.primary,
                                size: 12,
                              ),
                              SizedBox(width: 4),
                              Text(
                                '${event?['eventVenue'] ?? 'No Location'}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(
                                Icons.date_range,
                                color: AppColors.primary,
                                size: 12,
                              ),
                              SizedBox(width: 4),
                              Text(
                                '${DateFormat.yMMMd().add_jm().format((event?['startDate'] as Timestamp).toDate())} -- ${DateFormat.yMMMd().add_jm().format((event?['endDate'] as Timestamp).toDate())}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 24),

                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: AppColors.appBg,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: AppColors.gray100,
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'DONATION TARGET',
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: AppColors.textMuted,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'RM ${event?['amountTarget'].toStringAsFixed(2) ?? '0.00'}',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      LinearProgressIndicator(
                                        value:
                                            event!['amountRaised'] /
                                            event['amountTarget'],
                                        backgroundColor: Colors.grey[200],
                                        color: AppColors.primary,
                                        minHeight: 6,
                                        borderRadius: BorderRadius.circular(3),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'RM ${event?['amountRaised'].toStringAsFixed(2) ?? '0.00'} Raised',
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: AppColors.appBg,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: AppColors.gray100,
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'VOLUNTEERS',
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: AppColors.textMuted,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      RichText(
                                        text: TextSpan(
                                          style: const TextStyle(
                                            fontFamily: 'Inter',
                                            color: AppColors.textMain,
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          children: [
                                            TextSpan(
                                              text:
                                                  event?['targetVolunteers']
                                                      .toString() ??
                                                  '0',
                                            ),
                                            const TextSpan(
                                              text: '  Needed',
                                              style: TextStyle(
                                                color: AppColors.textMuted,
                                                fontSize: 10,
                                                fontWeight: FontWeight.normal,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      LinearProgressIndicator(
                                        value:
                                            (event['listJoinedVolunteers'] ??
                                                    [])
                                                .length /
                                            (event['targetVolunteers'] ?? 1),
                                        backgroundColor: Colors.grey[200],
                                        color: AppColors.secondary,
                                        minHeight: 6,
                                        borderRadius: BorderRadius.circular(3),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${(event['listJoinedVolunteers'] ?? const []).length} Approved',
                                        style: const TextStyle(
                                          fontSize: 10,
                                          color: AppColors.secondary,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          const Text(
                            'Event Description',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            event?['eventDescription'] ??
                                'No description available.',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textMuted,
                              height: 1.5,
                            ),
                          ),

                          const SizedBox(height: 24),
                          const Text(
                            'Required Roles',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              for (final role in roles) _buildRoleTag(role),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    border: const Border(
                      top: BorderSide(color: AppColors.gray100),
                    ),
                    boxShadow: floatingShadow,
                  ),
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.push(context, createSlideRoute(VolunteerListPage(eventID: widget.eventID))),
                    icon: const Icon(Icons.people, size: 20),
                    label: const Text(
                      'Manage Volunteers',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      minimumSize: const Size(double.infinity, 0),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRoleTag(String title) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        title,
        style: const TextStyle(
          color: AppColors.primary,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
