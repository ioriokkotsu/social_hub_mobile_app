import 'package:flutter/material.dart';
import 'package:social_hub/services/auth_service.dart';
import 'package:social_hub/services/stream_builder.dart';
import 'package:social_hub/theme/theme.dart';

Widget header() => const Header();

class Header extends StatefulWidget {
  const Header({super.key});

  @override
  _HeaderState createState() => _HeaderState();
}

class _HeaderState extends State<Header> {
  Future<void> signOut() async {
    await AuthService().signOut();
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthService().currentUser;
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
          boxShadow: softShadow,
        ),
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
            child: Column(
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.menu, color: AppColors.textMain),
                      onPressed: () {
                        Scaffold.of(context).openDrawer();
                        FocusScope.of(context).unfocus();
                      },
                      padding: EdgeInsets.zero,
                      constraints: BoxConstraints(),
                    ),
                    const SizedBox(width: 12),
                    SizedBox(
                      width: 262,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hello',
                            style: TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          FirestoreStreamBuilder(
                            stream: AuthService().getUserDataSnapshot(
                              user!.uid,
                            ),
                            builder: (user) {
                              return Text(
                                user['displayName'] ?? 'Guest',
                                style: TextStyle(
                                  color: AppColors.textMain,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'Poppins',
                                ),
                              );
                            },
                            width: 80,
                            height: 26,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.appBg,
                        //boxShadow: softShadow,
                      ),
                      child: IconButton(
                        icon: const Icon(
                          Icons.notifications_none,
                          color: AppColors.textMain,
                          size: 20,
                        ),
                        onPressed: () {
                          signOut();
                          // Navigator.push(
                          //   context,
                          //   MaterialPageRoute(
                          //     builder: (context) => NotificationsPage(),
                          //   ),
                          // );
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
