import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:social_hub/services/auth_service.dart';
import 'package:social_hub/services/future_builder.dart';
import 'package:social_hub/theme/theme.dart';

class VolunteerApplicationPage extends StatefulWidget {
  final dynamic eventID;
  final DocumentReference ngoRef;

  const VolunteerApplicationPage({
    super.key,
    required this.eventID,
    required this.ngoRef,
  });

  @override
  State<VolunteerApplicationPage> createState() =>
      _VolunteerApplicationPageState();
}

class _VolunteerApplicationPageState extends State<VolunteerApplicationPage> {
  String _selectedRole = '';
  bool _agreedToTerms = false;
  final TextEditingController _motivationTextController = TextEditingController();

  late Future<dynamic> eventFuture;
  late Future<dynamic> ngoData;

  @override
  void initState() {
    super.initState();
    eventFuture = AuthService().getCollectionData(
      widget.eventID,
      "communityEvents",
    );
    ngoData = AuthService().getCollectionData(widget.ngoRef, "ngo");
  }

  @override
  Widget build(BuildContext context) {
    return FirestoreFutureBuilder(
      future: eventFuture,
      builder: (event) {
        return Scaffold(
          backgroundColor: AppColors.surface,
          appBar: AppBar(
            centerTitle: true,
            backgroundColor: AppColors.surface,
            elevation: 0,
            iconTheme: const IconThemeData(color: AppColors.textMuted),
            titleSpacing: 0,
            title: const Text(
              'Volunteer Application',
              style: TextStyle(
                fontFamily: 'Poppins',
                color: AppColors.textMain,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          body: Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(24),
                  physics: const BouncingScrollPhysics(),
                  children: [
                    // Project Context Box
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.appBg,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.primary.withOpacity(0.1),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            event?['eventTitle'] ?? 'Project Title',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              color: AppColors.textMain,
                            ),
                          ),
                          const SizedBox(height: 4),
                          FirestoreFutureBuilder(
                            future: ngoData,
                            builder: (ngo) {
                              return Text(
                                ngo?['ngoName'] ?? 'Organizing NGO',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textMuted,
                                ),
                              );
                            }
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Motivation Input
                    _buildLabel('Motivation'),
                    _buildTextField(
                      hint: 'Why do you want to join this project?',
                      maxLines: 3,
                      controller: _motivationTextController,
                    ),
                    const SizedBox(height: 20),

                    // Role Selection
                    _buildLabel('Available Roles'),
                    _buildDropdown(_getRequiredRoles(event)),
                    const SizedBox(height: 24),

                    // Terms and Conditions Checkbox
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 24,
                          height: 24,
                          child: Checkbox(
                            value: _agreedToTerms,
                            activeColor: AppColors.primary,
                            side: const BorderSide(color: AppColors.textMuted),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                            onChanged: (bool? value) {
                              setState(() {
                                _agreedToTerms = value ?? false;
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: RichText(
                            text: const TextSpan(
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 12,
                                color: AppColors.textMuted,
                                height: 1.5,
                              ),
                              children: [
                                TextSpan(text: 'I agree to the '),
                                TextSpan(
                                  text: 'Volunteer Terms and Conditions',
                                  style: TextStyle(
                                    color: AppColors.primary,
                                    decoration: TextDecoration.underline,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                TextSpan(
                                  text:
                                      ' and commit to participating if approved.',
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Submit Button Sticky Bottom
              Container(
                padding: const EdgeInsets.all(24),
                decoration: const BoxDecoration(
                  color: AppColors.surface,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      offset: Offset(0, -2),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: () {
                    if (!_agreedToTerms) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Please agree to the Terms and Conditions first.',
                          ),
                          backgroundColor: AppColors.red500,
                        ),
                      );
                      return;
                    }

                    try {
                      final availableRoles = _getRequiredRoles(event);
                      final roleApplied = _getSelectedRole(availableRoles);

                      var data = {
                        'ngoID': widget.ngoRef,
                        'eventID': FirebaseFirestore.instance
                            .collection('communityEvents')
                            .doc(widget.eventID),
                        'roleApplied': roleApplied,
                        'status': 'Pending',
                        'submittedAt': FieldValue.serverTimestamp(),
                        'userID': FirebaseFirestore.instance
                            .collection('users')
                            .doc(AuthService().currentUser?.uid),
                        'motivationText': _motivationTextController.text,
                      };
                      AuthService().addDocToCollection(
                        'volunteerApplication',
                        data,
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Successfully submitted application.'),
                          backgroundColor: const Color.fromARGB(
                            255,
                            154,
                            239,
                            68,
                          ),
                        ),
                      );
                      Navigator.of(context).pop();
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error submitting application: $e'),
                          backgroundColor: AppColors.red500,
                        ),
                      );
                      return;
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    minimumSize: const Size(double.infinity, 0),
                  ),
                  child: const Text(
                    'Submit Application',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text.toUpperCase(),
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.textMuted,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  List<String> _getRequiredRoles(dynamic event) {
    final requiredRoles = event?['requiredRoles'];

    if (requiredRoles is! List) {
      return [];
    }

    return requiredRoles
        .whereType<Object>()
        .map((role) => role.toString().trim())
        .where((role) => role.isNotEmpty)
        .toList();
  }

  String _getSelectedRole(List<String> availableRoles) {
    if (availableRoles.isEmpty) {
      return '';
    }

    if (_selectedRole.isNotEmpty && availableRoles.contains(_selectedRole)) {
      return _selectedRole;
    }

    return availableRoles.first;
  }

  Widget _buildDropdown(List<String> availableRoles) {
    final selectedRole = _getSelectedRole(availableRoles);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.appBg,
        border: Border.all(color: AppColors.gray100),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: availableRoles.isEmpty ? null : selectedRole,
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
          items: availableRoles.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: (String? newValue) {
            setState(() {
              _selectedRole = newValue ?? '';
            });
          },
        ),
      ),
    );
  }

  Widget _buildTextField({required String hint, int maxLines = 1, required TextEditingController controller}) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.appBg,
        border: Border.all(color: AppColors.gray100),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppColors.textMain,
        ),
        decoration: InputDecoration(
          hintText: hint,
          border: InputBorder.none,
          hintStyle: const TextStyle(
            color: AppColors.textMuted,
            fontWeight: FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
