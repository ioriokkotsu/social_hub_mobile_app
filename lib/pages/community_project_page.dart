import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:social_hub/pages/home_page.dart';
import 'package:social_hub/services/future_builder.dart';
import 'package:social_hub/services/search_events.dart';
import 'package:social_hub/theme/theme.dart';

class CommunityProjectsPage extends StatefulWidget {
  const CommunityProjectsPage({super.key});

  @override
  State<CommunityProjectsPage> createState() => _CommunityProjectsPageState();
}

class _CommunityProjectsPageState extends State<CommunityProjectsPage> {
  String keyword = '';
  bool isExtendedSearch = false;
  List<String> filters = ['All', 'Technology', 'Education', 'Healthcare', 'Environment','Community Welfare'];
  List<bool> isSelectedFilters = [true, false, false, false, false, false];
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
            'Community Events',
            style: TextStyle(
              fontFamily: 'Poppins',
              color: AppColors.textMain,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
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
                              hintText: 'Search all events...',
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
                empty: const Center(
                  child: Text(
                    'No projects found.',
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 16,
                    ),
                  ),
                ),
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
                            event['eventCategory'] ?? 'Uncategorized',
                            event['eventImageURL'] ??
                                'https://images.unsplash.com/photo-1506744038136-46273834b3fb?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8Mnx8cHJvamVjdHxlbnwwfHwwfHx8MA%3D%3D&auto=format&fit=crop&w=800&q=60',
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
