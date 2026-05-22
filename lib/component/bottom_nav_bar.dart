import 'package:flutter/material.dart';

import 'package:social_hub/theme/theme.dart';

class BottomNavBar extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTap;

  final bool isDrawerOpen;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.isDrawerOpen,
  });

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  bool _isActive(int index) => index == widget.currentIndex;

  void _onTabTapped(int index) {
    widget.onTap(index);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 15),

      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.bottomCenter,

        children: [
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface.withValues(alpha: 0.9),
              
              border: Border.all(color: Color.fromARGB(255, 148, 149, 149)),
              borderRadius: BorderRadius.circular(24),
              boxShadow: floatingShadow,
            ),

            child: SafeArea(
              bottom: false,
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),

                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    navItem(
                      0,
                      Icons.home_outlined,
                      'Home',
                      ontap: () => _onTabTapped(0),
                      active: _isActive(0),
                    ),

                    navItem(
                      1,
                      Icons.dynamic_feed,
                      "Feed",
                      ontap: () => _onTabTapped(1),
                      active: _isActive(1),
                    ),

                    
                    navItem(
                      3,
                      Icons.newspaper_outlined,
                      "News",
                      ontap: () => _onTabTapped(2),
                      active: _isActive(2),
                    ),

                    navItem(
                      4,
                      Icons.person_outline,
                      "Profile",
                      ontap: () => _onTabTapped(3),
                      active: _isActive(3),
                    ),
                  ],
                ),
              ),
            ),
          ),

          
          
          

          
          

          
          
          

          
          
          
          
          

          
          
          
          
          
          
          
          
          
          
          
          
          
          
          
          
          
          
          
          
          
          
          
          
          
          
          
          
          
          
          
          
          
          
          
          
        ],
      ),
    );
  }
}

Widget navItem(
  int index,
  IconData icon,
  String label, {
  Function()? ontap,
  required bool active,
}) {
  final color = active ? AppColors.primary : AppColors.textMuted;

  return Material(
    color: Colors.transparent,

    child: InkWell(
      focusColor: Colors.transparent,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      hoverColor: Colors.transparent,

      borderRadius: BorderRadius.circular(24),

      onTap: ontap,

      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.elasticOut,

        decoration: BoxDecoration(
          color: active
              ? AppColors.primary.withValues(alpha: 0.12)
              : Colors.transparent,

          borderRadius: BorderRadius.circular(16),
        ),

        width: 70,

        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),

          child: Column(
            mainAxisSize: MainAxisSize.min,

            children: [
              Icon(icon, color: color, size: 30),

              
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight: active ? FontWeight.bold : FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
