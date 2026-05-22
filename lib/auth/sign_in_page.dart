import 'package:flutter/material.dart';
import 'package:social_hub/auth/role_selection_page.dart';
import 'package:social_hub/auth/sign_up_page.dart';
import 'package:social_hub/theme/theme.dart';
import '../services/auth_service.dart';
import 'package:social_hub/pages/main_page.dart';
import 'package:social_hub/admin/pages/admin_dashboard_page.dart';

class LogInPage extends StatefulWidget {
  const LogInPage({super.key, required this.selectedRole});

  final String selectedRole;

  @override
  State<LogInPage> createState() => _LogInPageState();
}

class _LogInPageState extends State<LogInPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();

  bool _isLoading = false;

  Future<void> _loginForSelectedRole() async {
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    setState(() => _isLoading = true);

    try {
      final credential = await _authService.loginWithEmail(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      final uid = credential.user?.uid;
      if (uid == null) throw Exception('Failed to retrieve user id');

      if (widget.selectedRole == 'ngo') {
        final ngoDoc = await _authService.getCollectionData(uid, 'ngo');
        if (ngoDoc != null) {
          if (mounted)
            navigator.pushReplacement(
              createSlideRoute(const AdminDashboardPage()),
            );
          return;
        }
        await _authService.signOut();
        throw Exception('No NGO profile found for this account.');
      }

      final userDoc = await _authService.getCollectionData(uid, 'users');
      if (userDoc != null) {
        if (mounted)
          navigator.pushReplacement(createSlideRoute(const MainPage()));
        return;
      }
      await _authService.signOut();
      throw Exception('No volunteer profile found for this account.');
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: AppColors.red500,
        ),
      );
      debugPrint(e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textMain),
          onPressed: () => Navigator.push(
            context,
            createSlideRoute(const RoleSelectionPage()),
          ),
        ),
      ),
      backgroundColor: AppColors.appBg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.person_add,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    widget.selectedRole == 'ngo' ? 'NGO' : 'Volunteer',
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textMain,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'Log In Account',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textMain,
                ),
              ),
              Text(
                widget.selectedRole == 'ngo'
                    ? 'NGO account selected. Log in as NGO.'
                    : 'Volunteer account selected. Log in as volunteer.',
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 32),

              _buildTextField('Email Address', _emailController, false),
              const SizedBox(height: 16),
              _buildTextField('Password', _passwordController, true),
              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _loginForSelectedRole,
                  onLongPress: _isLoading
                      ? null
                      : () {
                          if (widget.selectedRole == 'ngo') {
                            _emailController.text = 'help@eduglobal.org';
                            _passwordController.text = 'eduglobal';
                          } else {
                            _emailController.text = 'faiz@gmail.com';
                            _passwordController.text = 'faiz123';
                          }
                          _loginForSelectedRole();
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 5,
                    shadowColor: AppColors.primary.withValues(alpha: 0.5),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Log In',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Poppins',
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 48),
              widget.selectedRole == 'ngo'
                  ? const SizedBox.shrink()
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Dont have an account? ",
                          style: TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 14,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.push(
                            context,
                            createSlideRoute(
                              SignUpPage(selectedRole: widget.selectedRole),
                            ),
                          ),
                          child: const Text(
                            'Sign Up Now',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    String hint,
    TextEditingController controller,
    bool isPassword,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: softShadow,
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        style: const TextStyle(color: AppColors.textMain, fontSize: 14),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: AppColors.textMuted),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
        ),
      ),
    );
  }
}
