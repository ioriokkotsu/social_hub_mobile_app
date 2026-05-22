import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:social_hub/admin/admin_ops.dart';
import 'package:social_hub/services/auth_service.dart';
import 'package:social_hub/theme/theme.dart';

class LogHoursPage extends StatefulWidget {
  final String eventID;
  final String eventTitle;
  final bool? isFromEventDetails;

  const LogHoursPage({
    super.key,
    required this.eventID,
    required this.eventTitle,
    this.isFromEventDetails = false,
  });

  @override
  State<LogHoursPage> createState() => _LogHoursPageState();
}

class _LogHoursPageState extends State<LogHoursPage> {
  String? selectedEvent;
  TextEditingController hoursController = TextEditingController();
  TextEditingController taskController = TextEditingController();

  DateTime? dateTime = DateTime.now();

  void _showDialog(Widget child) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => Container(
        height: 216,
        padding: const EdgeInsets.only(top: 6.0),
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        color: CupertinoColors.systemBackground.resolveFrom(context),
        child: SafeArea(top: false, child: child),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    selectedEvent = widget.eventTitle;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textMuted),
        title: const Text(
          'Log Volunteer Hours',
          style: TextStyle(
            fontFamily: 'Poppins',
            color: AppColors.textMain,
            fontSize: 20,
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
                _buildLabel('Select Project'),
                _buildDropdown(),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel('Date and Time'),
                          InkWell(
                            onTap: () {
                              _showDialog(
                                CupertinoDatePicker(
                                  
                                  use24hFormat: true,
                                  mode: CupertinoDatePickerMode.dateAndTime,
                                  initialDateTime: dateTime,
                                  onDateTimeChanged: (DateTime newDateTime) {
                                    setState(() {
                                      dateTime = newDateTime;
                                    });
                                  },
                                ),
                              );
                            },
                            child: Container(
                              width: 174,
                              height: 50,
                              decoration: BoxDecoration(
                                color: AppColors.appBg,
                                border: Border.all(color: AppColors.gray100),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '${dateTime!.day}-${dateTime!.month}-${dateTime!.year} , ${dateTime!.hour}:${dateTime!.minute.toString().padLeft(2, '0')}',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const Icon(
                                    Icons.calendar_today_outlined,
                                    color: AppColors.textMuted,
                                    size: 16,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel('Hours Spent'),
                          Container(
                            decoration: BoxDecoration(
                              color: AppColors.appBg,
                              border: Border.all(color: AppColors.gray100),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: TextField(
                              controller: hoursController,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              keyboardType: TextInputType.number,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                              decoration: const InputDecoration(
                                hintText: 'e.g. 4',
                                border: InputBorder.none,
                                hintStyle: TextStyle(
                                  color: AppColors.textMuted,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                _buildLabel('Tasks Completed'),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.appBg,
                    border: Border.all(color: AppColors.gray100),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextField(
                    controller: taskController,
                    maxLines: 4,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: const InputDecoration(
                      hintText: 'Briefly describe what you worked on...',
                      border: InputBorder.none,
                      hintStyle: TextStyle(
                        color: AppColors.textMuted,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: AppColors.gray100)),
            ),
            child: ElevatedButton(
              onPressed: () {
                if (hoursController.text.isEmpty ||
                    taskController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      duration: Duration(seconds: 2),
                      content: Text('Please fill in all required fields.'),
                    ),
                  );
                  return;
                }
                submitLogHours(
                  FirebaseFirestore.instance
                      .collection('users')
                      .doc(AuthService().currentUser!.uid),
                  FirebaseFirestore.instance
                      .collection('communityEvents')
                      .doc(widget.eventID),
                  int.tryParse(hoursController.text) ?? 0,
                  taskController.text,
                  dateTime,
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    duration: Duration(seconds: 2),
                    content: Text(
                      'Log hours submitted successfully! Awaiting approval.',
                    ),
                  ),
                );
                Navigator.pop(context);
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
                'Submit for Approval',
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
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.appBg,
        border: Border.all(color: AppColors.gray100),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: selectedEvent,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textMain,
          ),
          items: <String>['Test Event 1', 'Test Event 2', widget.eventTitle]
              .map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              })
              .toList(),
          onChanged: widget.isFromEventDetails == false
              ? (value) {
                  setState(() {
                    selectedEvent = value;
                  });
                }
              : null,
        ),
      ),
    );
  }
}
