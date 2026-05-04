import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:social_hub/auth/sign_up_page.dart';
import 'package:social_hub/pages/main_page.dart';
import 'package:social_hub/services/auth_service.dart';
import 'package:social_hub/theme/theme.dart';

void main() async {

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Social Hub',
      home: StreamBuilder<User?>(
        stream: AuthService().authStateChanges,
        builder: (context, snapshot) {
          // Show a loader while checking the auth state
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              backgroundColor: AppColors.appBg,
              body: Center(child: CircularProgressIndicator(color: AppColors.primary)),
            );
          }
          
          // If a user is currently logged in, skip Login and go to Main App Shell
          if (snapshot.hasData) {
            return const MainPage(); // This holds your Bottom Nav & Home Screen
          }
          
          // If NO user is logged in, show the Login Screen
          return const SignUpPage();
        },
      ),
    );
  }
}
