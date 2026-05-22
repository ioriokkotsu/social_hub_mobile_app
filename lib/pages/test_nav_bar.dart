import 'dart:ui';
import 'package:flutter/material.dart';


class TestNavBar extends StatefulWidget {
  const TestNavBar({super.key});

  @override
  State<TestNavBar> createState() => _TestNavBarState();
}

class _TestNavBarState extends State<TestNavBar> {
  int currentIndex = 2;

  final List<NavItem> items = [
    NavItem(
      icon: Icons.home_outlined,
      activeIcon: Icons.home,
      label: "Home",
    ),
    NavItem(
      icon: Icons.calendar_month_outlined,
      activeIcon: Icons.calendar_month,
      label: "Calendar",
    ),
    NavItem(
      icon: Icons.auto_awesome_outlined,
      activeIcon: Icons.auto_awesome,
      label: "Explore",
    ),
    NavItem(
      icon: Icons.groups_outlined,
      activeIcon: Icons.groups,
      label: "Friends",
    ),
    NavItem(
      icon: Icons.person_outline,
      activeIcon: Icons.person,
      label: "Profile",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      body: const Center(
        child: Text(
          "Page Content",
          style: TextStyle(fontSize: 24),
        ),
      ),

      
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(
          left: 18,
          right: 18,
          bottom: 24,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(40),
          child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: 20,
              sigmaY: 20,
            ),
            child: Container(
              height: 78,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(40),
                gradient: LinearGradient(
                  colors: [
                    Colors.grey.withValues(alpha: 0.1),
                    Colors.grey.withValues(alpha: 0.05),
                  ],
                ),
                border: Border.all(
                  color: Colors.grey.withValues(alpha: 0.5),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(
                  items.length,
                  (index) {
                    final item = items[index];
                    final isSelected = currentIndex == index;

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          currentIndex = index;
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        padding: EdgeInsets.symmetric(
                          horizontal: isSelected ? 18 : 0,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Colors.black.withValues(alpha: 0.05)
                              : const Color.fromARGB(0, 0, 0, 0),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              isSelected
                                  ? item.activeIcon
                                  : item.icon,
                              color: isSelected
                                  ? Colors.black
                                  : Colors.black,
                              size: 28,
                            ),

                            if (isSelected) ...[
                              const SizedBox(width: 8),

                              Text(
                                item.label,
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ]
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}