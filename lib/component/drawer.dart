import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:social_hub/auth/role_selection_page.dart';
import 'package:social_hub/pages/community_project_page.dart';
import 'package:social_hub/pages/donation_history_page.dart';
import 'package:social_hub/pages/news_page.dart';
import 'package:social_hub/pages/volunteer_dashboard.dart';
import 'package:social_hub/services/auth_service.dart';
import 'package:social_hub/services/future_builder.dart';
import 'package:social_hub/theme/theme.dart';

class DrawerSideBar extends StatelessWidget {
  const DrawerSideBar({super.key});

  Future<void> signOut(BuildContext context) async {
    await AuthService().signOut();
    Navigator.push(context, createSlideRoute(const RoleSelectionPage()));
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.surface,
      width: MediaQuery.sizeOf(context).width * 0.75,

      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(36),
          bottomRight: Radius.circular(36),
        ),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            color: AppColors.primary.withValues(alpha: 0.1),
            padding: const EdgeInsets.fromLTRB(24, 48, 24, 24),

            child: FirestoreFutureBuilder(
              future: FirebaseFirestore.instance
                  .collection('users')
                  .doc(AuthService().currentUser!.uid)
                  .get(),
              builder: (user) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      margin: const EdgeInsets.only(bottom: 12),

                      decoration: BoxDecoration(
                        shape: BoxShape.circle,

                        border: Border.all(color: AppColors.primary, width: 2),

                        image: DecorationImage(
                          image: NetworkImage(
                            user['profileURL'] ??
                                'https://ui-avatars.com/api/?name=F&background=0D8ABC&color=fff&size=128',
                          ),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),

                    Text(
                      user['displayName'] ?? 'User Name',
                      style: GoogleFonts.poppins(
                        color: AppColors.textMain,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      user['occupation'] ?? 'Occupation',
                      style: GoogleFonts.poppins(
                        color: AppColors.textMuted,
                        fontSize: 14,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              physics: const BouncingScrollPhysics(),

              children: [
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                const SizedBox(height: 8),
                drawerItem(
                  icon: Icons.event_outlined,
                  iconColor: Colors.green,
                  label: 'Community Events',
                  onTap: () => Navigator.push(
                    context,
                    createSlideRoute(CommunityProjectsPage()),
                  ),
                ),
                const SizedBox(height: 8),
                drawerItem(
                  icon: Icons.badge_outlined,
                  iconColor: Colors.green,
                  label: 'My Volunteer Dashboard',
                  onTap: () => Navigator.push(
                    context,
                    createSlideRoute(VolunteerDashboardPage()),
                  ),
                ),
                const SizedBox(height: 8),
                drawerItem(
                  icon: Icons.money_outlined,
                  iconColor: Colors.orangeAccent,
                  label: 'My Donation History',
                  onTap: () => Navigator.push(
                    context,
                    createSlideRoute(DonationHistoryPage()),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Divider(color: Colors.grey[300], thickness: 1),
                ),
                
                
                
                
                
                
                
                
                
                
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: drawerItem(
              onTap: () => signOut(context),
              icon: Icons.logout,
              iconColor: Color(0xFFEF4444),
              label: 'Logout',
              textColor: Color(0xFFEF4444),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

Widget drawerItem({
  required IconData icon,
  required Color iconColor,
  required String label,
  Color textColor = AppColors.textMain,
  FontWeight fontWeight = FontWeight.w500,
  VoidCallback? onTap,
}) {
  return Material(
    color: Colors.transparent,
    child: InkWell(
      onTap: onTap ?? () {},
      borderRadius: BorderRadius.circular(12.0),
      hoverColor: AppColors.appBg,
      highlightColor: AppColors.primary.withValues(alpha: 0.5),
      splashColor: AppColors.primary.withValues(alpha: 0.3),
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 20),
            const SizedBox(width: 12),
            Text(
              label,
              style: GoogleFonts.inter(
                color: textColor,
                fontSize: 16,
                fontWeight: fontWeight,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
