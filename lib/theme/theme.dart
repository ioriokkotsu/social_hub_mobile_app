import 'package:flutter/material.dart';

class AppColors {
  static const primary = Color(0xFF2E7D32);
  static const secondary = Color(0xFF66BB6A);
  static const accent = Color(0xFFFFC107);
  static const appBg = Color(0xFFF5F7F5);
  static const surface = Color(0xFFFFFFFF);
  static const textMain = Color(0xFF1B1B1B);
  static const textMuted = Color(0xFF6B6B6B);
  
  static const blue500 = Color(0xFF3B82F6);
  static const red500 = Color(0xFFEF4444);
  static const teal500 = Color(0xFF14B8A6);
  static const orange500 = Color(0xFFF97316);
  static const gray100 = Color(0xFFF3F4F6);
}

final List<BoxShadow> softShadow = [
  BoxShadow(
    color: Colors.black.withValues(alpha: 0.05),
    offset: const Offset(0, 4),
    blurRadius: 20,
    spreadRadius: -4,
  )
];

final List<BoxShadow> floatingShadow = [
  BoxShadow(
    color: const Color(0xFF2E7D32).withValues(alpha: 0.15),
    offset: const Offset(0, 10),
    blurRadius: 40,
    spreadRadius: -10,
  )
];

// Reusable Slide Animation for navigating to new pages
Route createSlideRoute(Widget page) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(1.0, 0.0); // Slide from right
      const end = Offset.zero;
      const curve = Curves.easeOutQuart;

      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
      return SlideTransition(
        position: animation.drive(tween),
        child: child,
      );
    },
  );
}