import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:social_hub/pages/donation_history_page.dart';
import 'package:social_hub/pages/edit_profile_page.dart';
import 'package:social_hub/pages/my_badges_page.dart';
import 'package:social_hub/pages/volunteer_dashboard.dart';
import 'package:social_hub/services/auth_service.dart';
import 'package:social_hub/services/future_builder.dart';
import 'package:social_hub/services/stream_builder.dart';
import 'package:social_hub/theme/theme.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {

  late Future<Map<String, dynamic>?> _userData;

  @override
  void initState() {
    super.initState();
    _userData = AuthService().getUserData(AuthService().currentUser?.uid ?? '');
  }

  @override
  Widget build(BuildContext context) {
    return FirestoreStreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: AuthService().getUserDataSnapshot(AuthService().currentUser?.uid ?? ''),
      builder: (user) {
        return Scaffold(
          backgroundColor: AppColors.appBg,
          body: Stack(
            children: [
              Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(32),
                        bottomRight: Radius.circular(32),
                      ),
                      boxShadow: softShadow,
                    ),
                    padding: const EdgeInsets.fromLTRB(24, 64, 24, 24),
                    child: Column(
                      children: [
                        Stack(
                          alignment: Alignment.topRight,
                          children: [
                            Align(
                              alignment: Alignment.center,
                              child: Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 4),
                                  boxShadow: softShadow,
                                  image: DecorationImage(
                                    image: NetworkImage(
                                      user['profileURL'] ?? 'https://i.pravatar.cc/150?img=32',
                                    ),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.edit_outlined,
                                color: AppColors.primary,
                                size: 20,
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  createSlideRoute(
                                    const EditProfilePage(),
                                  ),
                                );
                              },
                              style: IconButton.styleFrom(
                                backgroundColor: AppColors.appBg,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          user?['displayName'] ?? 'Display Name',
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${user?['occupation'] ?? 'Occupation'} | +${user?['contactNumber'] ?? 'Contact Number'}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textMuted,
                          ),
                        ),
                        Text(
                          '${user?['email'] ?? 'Email'}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textMuted,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildTag('SDG 4', AppColors.primary),
                            const SizedBox(width: 8),
                            _buildTag('SDG 13', AppColors.accent),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.all(24),
                      physics: const BouncingScrollPhysics(),
                      children: [
                        _buildMenuBtn(
                          icon: Icons.assignment_turned_in_outlined,
                          iconColor: AppColors.primary,
                          title: 'Volunteer Dashboard',
                          onTap: () {
                            Navigator.push(
                              context,
                              createSlideRoute(VolunteerDashboardPage()
                              ),
                            );
                          },
                        ),
                        _buildMenuBtn(
                          icon: Icons.favorite_outline,
                          iconColor: AppColors.accent,
                          title: 'Donation History',
                          onTap: () {
                            Navigator.push(
                              context,
                              createSlideRoute(DonationHistoryPage()
                              ),
                            );
                          },
                        ),
                        _buildMenuBtn(
                          icon: Icons.workspace_premium_outlined,
                          iconColor: AppColors.secondary,
                          title: 'My Badges',
                          onTap: () {
                            Navigator.push(
                              context,
                              createSlideRoute(MyBadgesPage()
                              ),
                            );
                          },
                        ),
                        _buildMenuBtn(
                          icon: Icons.language_outlined,
                          iconColor: AppColors.blue500,
                          title: 'Language & Settings',
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Divider(color: AppColors.gray100),
                        ),
                        ElevatedButton.icon(
                          onPressed: () {},
                          icon: const Icon(
                            Icons.business_center_outlined,
                            color: Colors.white,
                            size: 20,
                          ),
                          label: const Text(
                            'Switch to NGO Admin View',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.textMain,
                            padding: const EdgeInsets.all(16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      }, width: double.infinity, height: double.infinity,
    );
  }

  Widget _buildTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildMenuBtn({
    required IconData icon,
    required Color iconColor,
    required String title,
    VoidCallback? onTap,
  }) {
    return Material(
      color: AppColors.surface,
      child: InkWell(
        onTap: onTap,
        // highlightColor: AppColors.primary.withValues(alpha: 0.5),
        // splashColor: AppColors.primary.withValues(alpha: 0.3),
        // hoverColor: AppColors.surface,
        child: Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ListTile(
            leading: Icon(icon, color: iconColor),
            title: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
            trailing: const Icon(
              Icons.chevron_right,
              color: AppColors.textMuted,
            ),
            onTap: onTap,
          ),
        ),
      ),
    );
  }
}
