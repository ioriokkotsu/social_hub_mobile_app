import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import 'package:social_hub/component/drawer.dart';
import 'package:social_hub/pages/community_project_page.dart';
import 'package:social_hub/pages/project_detail_page.dart';
import 'package:social_hub/services/auth_service.dart';
import 'package:social_hub/services/future_builder.dart';
import 'package:social_hub/services/stream_builder.dart';
import 'package:social_hub/theme/theme.dart';
import 'package:social_hub/component/header.dart';

class HomePage extends StatefulWidget {
  final Function(bool) onDrawerChanged;

  const HomePage({super.key, required this.onDrawerChanged});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isDrawerOpen = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthService().currentUser;
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: AppColors.appBg,
        drawer: DrawerSideBar(),
        onDrawerChanged: (isOpen) {
          widget.onDrawerChanged(isOpen);
          setState(() {
            isDrawerOpen = isOpen;
            FocusScope.of(context).unfocus();
          });
        },
        body: Column(
          children: [
            header(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(24),
                physics: const BouncingScrollPhysics(),
                children: [
                  //Section Title
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Community Projects',
                        style: GoogleFonts.poppins(
                          color: AppColors.textMain,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            createSlideRoute(CommunityProjectsPage()),
                          );
                        },
                        child: Text(
                          'See All >',
                          style: GoogleFonts.poppins(
                            color: AppColors.textMuted,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  FirestoreStreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                    stream: AuthService().getCollectionStream(
                      'communityEvents',
                    ),
                    builder: (snapshot) {
                      final docs = snapshot.docs;
                      return ListView.builder(
                        shrinkWrap: true,
                        itemCount: docs.length,
                        itemBuilder: (context, index) {
                          final doc = docs[index].data();
                          return card(
                            context,
                            doc['eventTitle'] ?? 'No Title',
                            doc['eventDescription'] ?? 'No description available',
                            doc['amountRaised'] ?? 0,
                            doc['amountTarget'] ?? 0,
                            docs[index].id,
                          );
                        },
                      );
                    },
                  ),
                  // const SizedBox(height: 16),
                  // card(context),
                  // const SizedBox(height: 24),
                  // card(context),
                  // const SizedBox(height: 24),
                  // card(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget card(BuildContext context, String eventTitle,String eventDescription,double amountRaised,double amountTarget,String uid) {
  return GestureDetector(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ProjectDetailPage(uid: uid)),
      );
    },
    child: Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: softShadow,
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 160,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: Colors.grey[300],
            ),
            clipBehavior: Clip.hardEdge,
            child: Stack(
              children: [
                Image.network(
                  'https://images.unsplash.com/photo-1506744038136-46273834b3fb?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8Mnx8cHJvamVjdHxlbnwwfHwwfHx8MA%3D%3D&auto=format&fit=crop&w=800&q=60',
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                ),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomLeft,
                      end: Alignment.topRight,
                      colors: [
                        const Color(0xFF1B5E20).withValues(alpha: 0.1),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
                Positioned(
                  bottom: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'SDG 1: No Poverty',
                      style: GoogleFonts.poppins(
                        color: AppColors.surface,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            eventTitle,
            style: GoogleFonts.poppins(
              color: AppColors.textMain,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            eventDescription,
            style: GoogleFonts.poppins(
              color: AppColors.textMuted,
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 6,
                  child: LinearProgressIndicator(
                    value: amountTarget > 0 ? (amountRaised / amountTarget).clamp(0, 1) : 0,
                    borderRadius: BorderRadius.circular(4),
                    backgroundColor: Colors.grey[200],
                    valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '${(amountTarget > 0 ? (amountRaised / amountTarget) * 100 : 0).round()}% Funded',
                style: GoogleFonts.poppins(
                  color: AppColors.primary,
                  fontSize: 13.4,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
