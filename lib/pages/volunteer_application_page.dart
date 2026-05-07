import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:social_hub/services/auth_service.dart';
import 'package:social_hub/services/future_builder.dart';
import 'package:social_hub/theme/theme.dart';

class VolunteerApplicationPage extends StatefulWidget {
  final String uid;
  final String ngoName;
  final String ngoID;

  const VolunteerApplicationPage({
    super.key,
    required this.uid,
    required this.ngoName,
    required this.ngoID,
  });

  @override
  State<VolunteerApplicationPage> createState() =>
      _VolunteerApplicationPageState();
}

class _VolunteerApplicationPageState extends State<VolunteerApplicationPage> {
  String _selectedRole = 'General Volunteer';
  bool _agreedToTerms = false;

  late Future<dynamic> eventFuture;

  @override
  void initState() {
    super.initState();
    eventFuture = AuthService().getCollectionData(
      widget.uid,
      "communityEvents",
    );
  }

  @override
  Widget build(BuildContext context) {
    return FirestoreFutureBuilder(
      future: eventFuture,
      builder: (event) {
        return Scaffold(
          backgroundColor: AppColors.surface,
          appBar: AppBar(
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
                          Text(
                            widget.ngoName,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textMuted,
                            ),
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
                    ),
                    const SizedBox(height: 20),

                    // Role Selection
                    _buildLabel('Available Roles'),
                    _buildDropdown(),
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
                      var data = {
                        'ngoID': FirebaseFirestore.instance.collection('ngo').doc(widget.ngoID),
                        'eventID': FirebaseFirestore.instance.collection('communityEvents').doc(widget.uid),
                        'roleApplied': _selectedRole,
                        'status': 'Pending',
                        'submittedAt': FieldValue.serverTimestamp(),
                        'userID': FirebaseFirestore.instance.collection('users').doc(AuthService().currentUser?.uid),
                      };
                      AuthService().addDataToCollection(
                        'volunteerApplication',
                        data,
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Successfully submitted application.'),
                          backgroundColor: const Color.fromARGB(255, 154, 239, 68),
                        ),
                      );
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

  Widget _buildDropdown() {
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
          value: _selectedRole,
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
          items:
              <String>[
                'Coding Instructor',
                'Logistics Coordinator',
                'General Volunteer',
              ].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
          onChanged: (String? newValue) {
            setState(() {
              _selectedRole = newValue!;
            });
          },
        ),
      ),
    );
  }

  Widget _buildTextField({required String hint, int maxLines = 1}) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.appBg,
        border: Border.all(color: AppColors.gray100),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TextField(
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
