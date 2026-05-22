import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:social_hub/admin/pages/admin_dashboard_page.dart';
import 'package:social_hub/auth/role_selection_page.dart';
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
  final AuthService _authService = AuthService();

  Future<String> _resolveRole(String uid) async {
    final userDoc = await _authService.getCollectionData(uid, 'users');
    if (userDoc != null) return 'user';

    final ngoDoc = await _authService.getCollectionData(uid, 'ngo');
    if (ngoDoc != null) return 'ngo';

    return 'unknown';
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Social Hub',
      home: StreamBuilder<User?>(
        stream: AuthService().authStateChanges,
        builder: (context, snapshot) {
          
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              backgroundColor: AppColors.appBg,
              body: Center(child: CircularProgressIndicator(color: AppColors.primary)),
            );
          }
          
          
          if (snapshot.hasData) {
            return FutureBuilder<String>(
              future: _resolveRole(snapshot.data!.uid),
              builder: (context, roleSnapshot) {
                if (roleSnapshot.connectionState == ConnectionState.waiting) {
                  return const Scaffold(
                    backgroundColor: AppColors.appBg,
                    body: Center(
                      child: CircularProgressIndicator(color: AppColors.primary),
                    ),
                  );
                }

                if (roleSnapshot.data == 'ngo') {
                  return const AdminDashboardPage();
                }

                return const MainPage();
              },
            );
          }
          
          
          return const RoleSelectionPage();
        },
      ),
    );
  }
}
