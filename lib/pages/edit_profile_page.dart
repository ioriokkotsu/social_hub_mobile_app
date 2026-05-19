import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:social_hub/services/auth_service.dart';
import 'package:social_hub/services/future_builder.dart';
import 'package:social_hub/services/upload_cloudinary.dart';
import 'package:social_hub/theme/theme.dart';

class MalaysiaPhoneNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final formatted = _formatMalaysiaPhone(newValue.text);

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  static String _formatMalaysiaPhone(String input) {
    var digits = input.replaceAll(RegExp(r'[^0-9]'), '');

    if (digits.startsWith('60')) {
      digits = digits.substring(2);
    }

    if (digits.length > 10) {
      digits = digits.substring(0, 10);
    }

    var formatted = '+60';

    if (digits.isNotEmpty) {
      if (digits.length <= 2) {
        formatted += digits;
      } else if (digits.length <= 5) {
        formatted += '${digits.substring(0, 2)}-${digits.substring(2)}';
      } else {
        formatted +=
            '${digits.substring(0, 2)}-${digits.substring(2, 5)} ${digits.substring(5)}';
      }
    }

    return formatted;
  }
}

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

  String _occupation = 'Student';

  bool _isInitialized = false;

  @override
  void dispose() {
    _displayNameController.dispose();
    _fullNameController.dispose();
    _emailController.dispose();
    _numberController.dispose();
    super.dispose();
  }

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
      ),

      body: FirestoreFutureBuilder(
        future: AuthService().getUserData(AuthService().currentUser?.uid ?? ''),

        builder: (user) {
          if (!_isInitialized) {
            _displayNameController.text = user?['displayName'] ?? '';

            _fullNameController.text =
                user?['fullName'] ?? user?['displayName'] ?? '';

            _emailController.text = user?['email'] ?? '';

            _numberController.text =
                MalaysiaPhoneNumberFormatter._formatMalaysiaPhone(
                  user?['contactNumber'] ?? '',
                );

            _occupation = user?['occupation'] ?? 'Student';

            _isInitialized = true;
          }

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

                        image: DecorationImage(
                          image: NetworkImage(
                            user?['profileURL'] ??
                                'https://i.pravatar.cc/150?img=32',
                          ),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),

                    GestureDetector(
                      onTap: () async {
                        print("Opening image picker...");

                        await updateProfilePicture(
                          AuthService().currentUser?.uid ?? '',
                        );

                        print("Profile picture updated");
                      },

                      child: Container(
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

              _buildFormSection('Full Name', controller: _fullNameController),

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

              _buildDropdownSection('Occupation', [
                'Student',
                'Professional',
                'Community Member',
                'Working',
              
              ], _occupation),

              const SizedBox(height: 50),

              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  onPressed: () async {
                    await AuthService().updateCollection(
                      AuthService().currentUser?.uid ?? '',
                      {
                        'displayName': _displayNameController.text.trim(),
                        'fullName': _fullNameController.text.trim(),
                        'contactNumber': _numberController.text.trim(),
                        'occupation': _occupation,
                      },
                    );

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        backgroundColor: AppColors.primary,
                        content: Text('Profile updated successfully!'),
                      ),
                    );

                    Navigator.pop(context);
                  },
                  child: Text(
                    'Save Changes',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
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

            keyboardType: isPhone ? TextInputType.number : TextInputType.text,
            inputFormatters: isPhone
                ? <TextInputFormatter>[MalaysiaPhoneNumberFormatter()]
                : null,

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

              onChanged: (String? newValue) {
                setState(() {
                  _occupation = newValue ?? 'Student';
                });
              },
            ),
          ),
        ),
      ],
    );
  }
}
