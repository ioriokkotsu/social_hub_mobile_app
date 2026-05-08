import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
  bool isExtendedSearch = false;
  List<String> filters = ['All', 'Technology', 'Education', 'Healthcare'];
  List<bool> isSelectedFilters = [true, false, false, false];
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
          // bottom: PreferredSize(
          //   preferredSize: const Size.fromHeight(80),
          //   child: AnimatedContainer(
          //     padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
          //     decoration: BoxDecoration(
          //       color: AppColors.surface,
          //       boxShadow: [
          //         BoxShadow(
          //           color: Colors.black.withOpacity(0.02),
          //           offset: const Offset(0, 4),
          //           blurRadius: 10,
          //         ),
          //       ],
          //     ),
          //     duration: const Duration(milliseconds: 1000),
          //     child: Column(
          //       children: [
          //         Row(
          //           children: [
          //             Expanded(
          //               child: Container(
          //                 decoration: BoxDecoration(
          //                   color: AppColors.appBg,
          //                   borderRadius: BorderRadius.circular(12),
          //                   boxShadow: [
          //                     BoxShadow(
          //                       color: Colors.black.withOpacity(0.05),
          //                       blurRadius: 2,
          //                       offset: const Offset(0, 1),
          //                     ),
          //                   ],
          //                 ),
          //                 padding: const EdgeInsets.symmetric(
          //                   horizontal: 16,
          //                   vertical: 2,
          //                 ),
          //                 child: TextField(
          //                   controller: searchController,
          //                   onChanged: (value) {
          //                     setState(() {
          //                       keyword = value;
          //                     });
          //                   },
          //                   decoration: InputDecoration(
          //                     hintText: 'Search all projects...',
          //                     hintStyle: TextStyle(
          //                       color: AppColors.textMuted,
          //                       fontSize: 14,
          //                     ),
          //                     border: InputBorder.none,
          //                   ),
          //                 ),
          //               ),
          //             ),
          //             const SizedBox(width: 8),
          //             Container(
          //               width: 48,
          //               height: 48,
          //               decoration: BoxDecoration(
          //                 color: AppColors.primary.withOpacity(0.1),
          //                 borderRadius: BorderRadius.circular(12),
          //               ),
          //               child: const Icon(Icons.tune, color: AppColors.primary),
          //             ),
          //           ],
          //         ),
          //         // SizedBox(height: 30),
          //       ],
          //     ),
          //   ),
          // ),
        ),
        body: Column(
          children: [
            AnimatedContainer(
              padding: EdgeInsets.fromLTRB(24, 0, 24, 16),
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
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeInOut,
              child: Column(
                children: [
                  Row(
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
                        child: IconButton(
                          icon: Icon(Icons.tune),
                          color: AppColors.primary,
                          onPressed: () {
                            setState(() {
                              isExtendedSearch = !isExtendedSearch;
                              for (int i = 1; i < isSelectedFilters.length; i++) {
                                isSelectedFilters[i] = false;
                              }
                              isSelectedFilters[0] = true;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  AnimatedSize(
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeInOut,

                    child: Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            if (isExtendedSearch) ...[
                              // Container(
                              //   padding: const EdgeInsets.symmetric(
                              //     horizontal: 12,
                              //     vertical: 6,
                              //   ),
                              //   decoration: BoxDecoration(
                              //     color: AppColors.primary,
                              //     borderRadius: BorderRadius.circular(12),
                              //   ),
                              //   child: Text(
                              //     'SDG 1: No Poverty',
                              //     style: GoogleFonts.poppins(
                              //       color: AppColors.surface,
                              //       fontSize: 14,
                              //       fontWeight: FontWeight.bold,
                              //     ),
                              //   ),
                              // ),

                              // const SizedBox(width: 8),
                              boxFilterOptions(isSelectedFilters, filters),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: FirestoreFutureBuilder(
                loading: const Center(child: CircularProgressIndicator()),
                future: searchEvents(keyword, 'title', context,filters[isSelectedFilters.indexWhere((value) => value == true)]),
                builder: (snapshot) {
                  return ListView.builder(
                    itemCount: snapshot.length,
                    itemBuilder: (context, index) {
                      var event =
                          snapshot[index].data() as Map<String, dynamic>;
                      return Column(
                        children: [
                          const SizedBox(height: 24),
                          card(
                            context,
                            event['eventTitle'] ?? 'No Title',
                            event['eventDescription'] ??
                                'No description available',
                            event['amountRaised']?.toDouble() ?? 0,
                            event['amountTarget']?.toDouble() ?? 0,
                            snapshot[index].id,
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
          ],
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

  Widget boxFilterOptions(List<bool> selected, List<String> filters) {
    return Row(
      children: List.generate(filters.length, (index) {
        bool isSelected = selected[index];

        return Padding(
          padding: const EdgeInsets.only(right: 8),

          child: GestureDetector(
            onTap: () {
              setState(() {
                for (int i = 0; i < selected.length; i++) {
                  selected[i] = false;
                }

                selected[index] = true;
              });
            },

            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),

              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),

              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary
                    : AppColors.primary.withOpacity(0.1),

                borderRadius: BorderRadius.circular(12),

                border: Border.all(
                  color: AppColors.primary,
                  width: isSelected ? 2 : 1,
                ),
              ),

              child: Text(
                filters[index],

                style: GoogleFonts.poppins(
                  color: isSelected ? Colors.white : AppColors.primary,

                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}
