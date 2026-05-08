import 'package:flutter/material.dart';
import 'package:social_hub/pages/home_page.dart';
import 'package:social_hub/services/future_builder.dart';
import 'package:social_hub/services/search_events.dart';
import 'package:social_hub/theme/theme.dart';
import 'package:social_hub/pages/project_detail_page.dart';

class CommunityProjectsPage extends StatefulWidget {
  const CommunityProjectsPage({super.key});

  @override
  State<CommunityProjectsPage> createState() => _CommunityProjectsPageState();
}

class _CommunityProjectsPageState extends State<CommunityProjectsPage> {
  String keyword = '';
  TextEditingController searchController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: AppColors.appBg,
        appBar: AppBar(
          backgroundColor: AppColors.surface,
          elevation: 0,
          iconTheme: const IconThemeData(color: AppColors.textMuted),
          titleSpacing: 0,
          title: const Text(
            'Community Projects',
            style: TextStyle(
              fontFamily: 'Poppins',
              color: AppColors.textMain,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(80),
            child: Container(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    offset: const Offset(0, 4),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.appBg,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 2,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 2,
                      ),
                      child: TextField(
                        controller: searchController,
                        onChanged: (value) {
                          setState(() {
                            keyword = value;
                          });
                        },
                        decoration: InputDecoration(
                          hintText: 'Search all projects...',
                          hintStyle: TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 14,
                          ),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.tune, color: AppColors.primary),
                  ),
                ],
              ),
            ),
          ),
        ),
        body: FirestoreFutureBuilder(
          future: searchEvents(keyword, 'title', context),
          builder: (snapshot) {
            return ListView.builder(
              itemCount: snapshot.length,
              itemBuilder: (context, index) {
                var event = snapshot[index].data() as Map<String, dynamic>;
                return card(
                  context,
                  event['eventTitle'] ?? 'No Title',
                  event['eventDescription'] ?? 'No description available',
                  event['amountRaised']?.toDouble() ?? 0,
                  event['amountTarget']?.toDouble() ?? 0,
                  snapshot[index].id,
                );
              },
            );
          },
          empty: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('assets/images/no_results.png', width: 150),
                const SizedBox(height: 16),
                Text(
                  'No projects found',
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),

        // body: ListView(
        //   padding: const EdgeInsets.all(24),
        //   physics: const BouncingScrollPhysics(),
        //   children: [
        //     // _buildProjectCard(
        //     //   context: context,
        //     //   title: 'Rural Tech Education',
        //     //   desc:
        //     //       'Providing laptops and coding classes to remote villages in SEA.',
        //     //   imageUrl:
        //     //       'https://images.unsplash.com/photo-1497645851419-f06bcaeb1525?w=500&q=80',
        //     //   badgeText: 'SDG 4 Education',
        //     //   badgeColor: AppColors.accent,
        //     //   badgeTextColor: AppColors.textMain,
        //     //   progress: 0.6,
        //     //   progressText: '60% Funded',
        //     // ),
        //     // const SizedBox(height: 24),
        //     // _buildProjectCard(
        //     //   context: context,
        //     //   title: 'Ocean Cleanup Drive',
        //     //   desc:
        //     //       'Mobilizing volunteers to remove plastic waste from coastal areas and protect marine ecosystems.',
        //     //   imageUrl:
        //     //       'https://images.unsplash.com/photo-1621451537084-482c73073e0f?w=500&q=80',
        //     //   badgeText: 'SDG 14 Life Below Water',
        //     //   badgeColor: AppColors.blue500.withOpacity(0.2),
        //     //   badgeTextColor: Colors.blue[800]!,
        //     //   progress: 0.81,
        //     //   progressText: '81% Funded',
        //     // ),
        //     // const SizedBox(height: 24),
        //     // _buildProjectCard(
        //     //   context: context,
        //     //   title: 'Clean Wells Initiative',
        //     //   desc:
        //     //       'Building sustainable water pumps to provide clean drinking water to drought-affected communities.',
        //     //   imageUrl:
        //     //       'https://images.unsplash.com/photo-1538300342682-ffa5ba1b9dca?w=500&q=80',
        //     //   badgeText: 'SDG 6 Clean Water',
        //     //   badgeColor: AppColors.teal500.withOpacity(0.2),
        //     //   badgeTextColor: Colors.teal[800]!,
        //     //   progress: 0.25,
        //     //   progressText: '25% Funded',
        //     // ),
        //     // const SizedBox(height: 24),
        //     // _buildProjectCard(
        //     //   context: context,
        //     //   title: 'Urban Community Gardens',
        //     //   desc:
        //     //       'Converting abandoned city lots into vibrant green spaces for local organic food production.',
        //     //   imageUrl:
        //     //       'https://images.unsplash.com/photo-1592424001801-9f9fdf098e98?w=500&q=80',
        //     //   badgeText: 'SDG 11 Sustainable Cities',
        //     //   badgeColor: AppColors.orange500.withOpacity(0.2),
        //     //   badgeTextColor: Colors.orange[800]!,
        //     //   progress: 0.45,
        //     //   progressText: '45% Funded',
        //     // ),
        //   ],
        // ),
      ),
    );
  }

  Widget _buildProjectCard({
    required BuildContext context,
    required String title,
    required String desc,
    required String imageUrl,
    required String badgeText,
    required Color badgeColor,
    required Color badgeTextColor,
    required double progress,
    required String progressText,
  }) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        createSlideRoute(const ProjectDetailPage(uid: 'QzMtSxmpzlPR0VP5qwIc')),
      ),
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
            // Image Area
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
                    imageUrl,
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomLeft,
                        end: Alignment.topRight,
                        colors: [
                          Colors.black.withOpacity(0.6),
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
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: badgeColor,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: badgeTextColor.withOpacity(0.2),
                        ),
                      ),
                      child: Text(
                        badgeText,
                        style: TextStyle(
                          color: badgeTextColor,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              desc,
              style: const TextStyle(color: AppColors.textMuted, fontSize: 14),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 16),
            // Progress Area
            Row(
              children: [
                Expanded(
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.grey[200],
                    color: AppColors.primary,
                    minHeight: 6,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  progressText,
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
