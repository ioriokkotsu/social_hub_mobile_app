import 'package:flutter/material.dart';
import 'package:social_hub/services/auth_service.dart';
import 'package:social_hub/services/future_builder.dart';
import 'package:social_hub/theme/theme.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final TextEditingController _displayNameController = TextEditingController();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _numberController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textMuted),
        titleSpacing: 0,
        title: const Text(
          'Edit Profile',
          style: TextStyle(
            fontFamily: 'Poppins',
            color: AppColors.textMain,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              await AuthService().updateCollection(
                AuthService().currentUser?.uid ?? '',
                {
                  'displayName': _displayNameController.text,
                  'fullName': _fullNameController.text,
                  'contactNumber': _numberController.text,
                },
              );
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(backgroundColor: AppColors.primary, content: Text('Profile updated successfully!')),
              );
              Navigator.pop(context);
            },
            child: const Text(
              'Save',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: FirestoreFutureBuilder(
        future: AuthService().getUserData(AuthService().currentUser?.uid ?? ''),
        builder: (user) {
          _displayNameController.text = user?['displayName'] ?? '';
          _fullNameController.text = user?['fullName'] ?? user?['displayName'] ?? '';
          _emailController.text = user?['email'] ?? '';
          _numberController.text = user?['contactNumber'] ?? '';
          return ListView(
            padding: const EdgeInsets.all(24),
            physics: const BouncingScrollPhysics(),
            children: [
              Center(
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    Container(
                      width: 96,
                      height: 96,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.appBg, width: 4),
                        image: const DecorationImage(
                          image: NetworkImage(
                            'https://i.pravatar.cc/150?img=32',
                          ),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              _buildFormSection(
                'Display Name',
                controller: _displayNameController,
              ),
              const SizedBox(height: 16),

              _buildFormSection(
                'Full Name',
                controller: _fullNameController,
              ),
              const SizedBox(height: 16),

              _buildFormSection(
                'Email',
                isReadOnly: true,
                controller: _emailController,
              ),
              const SizedBox(height: 16),

              _buildFormSection(
                'Phone Number',
                isPhone: true,
                controller: _numberController,
              ),
              const SizedBox(height: 16),

              _buildDropdownSection('Role', [
                'Student',
                'Professional',
                'Community Member',
                'Company Rep',
              ], user?['role'] ?? 'Student'),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFormSection(
    String label, {
    required TextEditingController controller,
    bool isReadOnly = false,
    bool isPhone = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.textMuted,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.appBg,
            border: Border.all(color: AppColors.gray100),
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextFormField(
            controller: controller,
            readOnly: isReadOnly,
            keyboardType: isPhone ? TextInputType.phone : TextInputType.text,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: isReadOnly ? AppColors.textMuted : AppColors.textMain,
            ),
            decoration: const InputDecoration(border: InputBorder.none),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownSection(
    String label,
    List<String> options,
    String currentValue,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.textMuted,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.appBg,
            border: Border.all(color: AppColors.gray100),
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              value: currentValue,
              icon: const Icon(
                Icons.keyboard_arrow_down,
                color: AppColors.textMuted,
              ),
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textMain,
              ),
              items: options.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (_) {},
            ),
          ),
        ),
      ],
    );
  }
}
