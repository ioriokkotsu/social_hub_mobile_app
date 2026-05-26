import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:social_hub/pages/donation_history_page.dart';
import 'package:social_hub/pages/edit_profile_page.dart';
import 'package:social_hub/pages/volunteer_dashboard.dart';
import 'package:social_hub/services/auth_service.dart';
import 'package:social_hub/services/stream_builder.dart';
import 'package:social_hub/theme/theme.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    return FirestoreStreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: AuthService().getUserDataSnapshot(
        AuthService().currentUser?.uid ?? '',
      ),
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
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 4,
                                  ),
                                  boxShadow: softShadow,
                                  image: DecorationImage(
                                    image: NetworkImage(
                                      user['profileURL'] ??
                                          'https://i.pravatar.cc/150?img=32',
                                    ),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                            
                            
                            
                            
                            
                            
                            
                            
                            
                            
                            
                            
                            
                            
                            
                            
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          user['displayName'] ?? 'Display Name',
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${user['occupation'] ?? 'Occupation'} | +${user['contactNumber'] ?? 'Contact Number'}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textMuted,
                          ),
                        ),
                        Text(
                          '${user['email'] ?? 'Email'}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textMuted,
                          ),
                        ),
                        const SizedBox(height: 12),
                        
                        
                        
                        
                        
                        
                        
                        
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
                              createSlideRoute(VolunteerDashboardPage()),
                            );
                          },
                        ),
                        const SizedBox(
                          height: 16,
                        ),
                        _buildMenuBtn(
                          icon: Icons.favorite_outline,
                          iconColor: AppColors.accent,
                          title: 'Donation History',
                          onTap: () {
                            Navigator.push(
                              context,
                              createSlideRoute(DonationHistoryPage()),
                            );
                          },
                        ),
                        const SizedBox(
                          height: 16,
                        ),
                        _buildMenuBtn(
                          icon: Icons.person_outline,
                          iconColor: AppColors.secondary,
                          title: 'Edit My Profile',
                          onTap: () {
                            Navigator.push(
                              context,
                              createSlideRoute(EditProfilePage()),
                            );
                          },
                        ),
                        
                        
                        
                        
                        
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Divider(color: AppColors.gray100),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
      width: double.infinity,
      height: double.infinity,
    );
  }

  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  

  Widget _buildMenuBtn({
    required IconData icon,
    required Color iconColor,
    required String title,
    VoidCallback? onTap,
  }) {
    return Material(
      borderRadius: BorderRadius.circular(24),
      color: AppColors.surface,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        highlightColor: AppColors.primary.withValues(alpha: 0.5),
        
        
        child: Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(24),
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
