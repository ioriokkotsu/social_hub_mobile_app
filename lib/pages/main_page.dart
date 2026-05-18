import 'package:flutter/material.dart';
import 'package:social_hub/component/bottom_nav_bar.dart';
import 'package:social_hub/pages/chat_page.dart';
import 'package:social_hub/pages/feed_page.dart';
import 'package:social_hub/pages/home_page.dart';
import 'package:social_hub/pages/news_page.dart';
import 'package:social_hub/pages/profile_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int currentIndex = 0;
  bool isDrawerOpen = false;

  late final pages = [
    HomePage(
      onDrawerChanged: (isOpen) {
        setState(() {
          isDrawerOpen = isOpen;
        });
      },
    ),
    const FeedPage(),
    const NewsPage(),
    const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        body: Stack(
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: pages[currentIndex],
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: isDrawerOpen ? 0 : null,
                width: isDrawerOpen ? 0 : null,
                child: BottomNavBar(
                  currentIndex: currentIndex,
                  onTap: (index) {
                    setState(() {
                      currentIndex = index;
                    });
                  },
                  isDrawerOpen: isDrawerOpen,
                ),
              ),
            ),
          ],
        ),

        // bottomNavigationBar:
        // AnimatedContainer(
        //   duration: const Duration(milliseconds: 200),
        //   height: isDrawerOpen ? 0 : null,
        //   width: isDrawerOpen ? 0 : null,
        //   child: BottomNavBar(
        //     currentIndex: currentIndex,
        //     onTap: (index) {
        //       setState(() {
        //         currentIndex = index;
        //       });
        //     },
        //     isDrawerOpen: isDrawerOpen,
        //   ),
        // ),
      ),
    );
  }
}
