import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:social_hub/services/auth_service.dart';
import 'package:social_hub/services/upload_cloudinary.dart';
import 'package:social_hub/theme/theme.dart';

class CreateEventPage extends StatefulWidget {
  const CreateEventPage({super.key});

  @override
  State<CreateEventPage> createState() => _CreateEventPageState();
}

class _CreateEventPageState extends State<CreateEventPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _venueController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _roleController = TextEditingController();

  final List<String> _categoryOptions = const [
    'Technology',
    'Education',
    'Healthcare',
    'Environment',
    'Community Welfare',
  ];

  bool _isSaving = false;
  bool _isUploadingImage = false;

  String? _selectedCategory;
  String? _profileURL;
  DateTime? _startDate;
  DateTime? _endDate;
  List<String> _requiredRoles = [];

  @override
  void dispose() {
    _titleController.dispose();
    _venueController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    _roleController.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime({required bool isStartDate}) async {
    DateTime fallback = isStartDate
        ? (_startDate ?? DateTime.now())
        : (_endDate ?? _startDate ?? DateTime.now());
    DateTime tempDate = fallback;

    final selected = await showModalBottomSheet<DateTime>(
      context: context,
      builder: (context) {
        return Container(
          height: 300,
          color: Colors.white,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CupertinoButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    Text(
                      isStartDate ? 'Select Start Date' : 'Select End Date',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textMain,
                      ),
                    ),
                    CupertinoButton(
                      onPressed: () => Navigator.pop(context, tempDate),
                      child: const Text('Done'),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.dateAndTime,
                  initialDateTime: fallback,
                  minimumDate: isStartDate
                      ? null
                      : (_startDate ?? DateTime.now()),
                  use24hFormat: false,
                  onDateTimeChanged: (value) => tempDate = value,
                ),
              ),
            ],
          ),
        );
      },
    );

    if (!mounted || selected == null) return;

    setState(() {
      if (isStartDate) {
        _startDate = selected;
        if (_endDate != null && _endDate!.isBefore(selected)) {
          _endDate = selected;
        }
      } else {
        _endDate = selected;
      }
    });
  }

  Future<void> _changeCoverImage() async {
    if (_isUploadingImage) return;

    final image = await pickImage();
    if (image == null) return;

    setState(() => _isUploadingImage = true);
    try {
      final uploadedUrl = await uploadToCloudinary(image.path);
      if (!mounted) return;
      if (uploadedUrl == null || uploadedUrl.isEmpty) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Image upload failed.')));
        return;
      }
      setState(() => _profileURL = uploadedUrl);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Cover image uploaded.')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Upload error: $e')));
    } finally {
      if (mounted) setState(() => _isUploadingImage = false);
    }
  }

  void _addRole() {
    final role = _roleController.text.trim();
    if (role.isEmpty) return;
    if (_requiredRoles.contains(role)) {
      _roleController.clear();
      return;
    }
    setState(() {
      _requiredRoles = [..._requiredRoles, role];
      _roleController.clear();
    });
  }

  void _removeRole(String role) {
    setState(() => _requiredRoles.remove(role));
  }

  Future<void> _saveEvent() async {
    if (_isSaving) return;

    final title = _titleController.text.trim();
    final category = (_selectedCategory ?? '').trim();
    final venue = _venueController.text.trim();
    final amount = double.tryParse(_amountController.text.trim());
    final description = _descriptionController.text.trim();
    final startDate = _startDate;
    final endDate = _endDate;

    if (title.isEmpty ||
        category.isEmpty ||
        venue.isEmpty ||
        amount == null ||
        description.isEmpty ||
        startDate == null ||
        endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all required fields.')),
      );
      return;
    }

    if (amount < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Target amount must be zero or greater.')),
      );
      return;
    }

    if (endDate.isBefore(startDate)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('End date cannot be earlier than start date.'),
        ),
      );
      return;
    }

    final cleanRoles = _requiredRoles
        .map((r) => r.trim())
        .where((r) => r.isNotEmpty)
        .toSet()
        .toList();

    final payload = <String, dynamic>{
      'eventTitle': title,
      'eventCategory': category,
      'eventVenue': venue,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'amountTarget': amount,
      'amountRaised': 0.0,
      'eventDescription': description,
      'requiredRoles': cleanRoles,
      'profileURL': _profileURL ?? '',
      'organizedBy': FirebaseFirestore.instance
          .collection('ngo')
          .doc(AuthService().currentUser?.uid) as DocumentReference,
      'listJoinedVolunteer': <String>[],
      'status': 'Active',
      'createdAt': FieldValue.serverTimestamp(),
    };

    setState(() => _isSaving = true);
    try {
      await FirebaseFirestore.instance
          .collection('communityEvents')
          .add(payload);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Event created successfully.')),
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to create event: $e')));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
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
          'Create New Event',
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
                GestureDetector(
                  onTap: _changeCoverImage,
                  child: Container(
                    height: 140,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      image: DecorationImage(
                        image: NetworkImage(
                          _profileURL ??
                              'https://images.unsplash.com/photo-1497645851419-f06bcaeb1525?w=500&q=80',
                        ),
                        fit: BoxFit.cover,
                        colorFilter: const ColorFilter.mode(
                          Colors.black38,
                          BlendMode.darken,
                        ),
                      ),
                    ),
                    child: Center(
                      child: _isUploadingImage
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(
                                  Icons.camera_alt,
                                  color: Colors.white,
                                  size: 24,
                                ),
                                SizedBox(height: 6),
                                Text(
                                  'Change Cover Image',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                _buildLabel('Event Title'),
                _buildTextField(
                  controller: _titleController,
                  hint: 'e.g. Clean Rivers Initiative',
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [_buildLabel('Category'), _buildDropdown()],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel('Venue'),
                          _buildTextField(
                            controller: _venueController,
                            hint: 'Location Name',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel('Start Date'),
                          _buildDateContainer(
                            value: _startDate,
                            onTap: () => _pickDateTime(isStartDate: true),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel('End Date'),
                          _buildDateContainer(
                            value: _endDate,
                            onTap: () => _pickDateTime(isStartDate: false),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                _buildLabel('Target Amount (RM)'),
                _buildTextField(
                  controller: _amountController,
                  hint: 'e.g. 5000',
                  isNumber: true,
                ),
                const SizedBox(height: 16),

                _buildLabel('Required Roles'),
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        controller: _roleController,
                        hint: 'Type role and press enter',
                        onSubmitted: (_) => _addRole(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _addRole,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Add'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _requiredRoles
                      .map((r) => _buildTag(r, AppColors.primary))
                      .toList(),
                ),
                const SizedBox(height: 16),

                _buildLabel('Event Description'),
                _buildTextField(
                  controller: _descriptionController,
                  hint: 'Describe the event goals and impact...',
                  maxLines: 4,
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: AppColors.gray100)),
            ),
            child: ElevatedButton.icon(
              onPressed: _isSaving ? null : _saveEvent,
              icon: _isSaving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.save, size: 18, color: Colors.white),
              label: Text(
                _isSaving ? 'Publishing...' : 'Publish Event',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                minimumSize: const Size(double.infinity, 0),
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
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: AppColors.textMuted,
          letterSpacing: 1,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    String? hint,
    int maxLines = 1,
    bool isNumber = false,
    ValueChanged<String>? onSubmitted,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.appBg,
        border: Border.all(color: AppColors.gray100),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TextFormField(
        controller: controller,
        onFieldSubmitted: onSubmitted,
        maxLines: maxLines,
        keyboardType: isNumber
            ? const TextInputType.numberWithOptions(decimal: true)
            : TextInputType.text,
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

  Widget _buildDateContainer({
    required DateTime? value,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.appBg,
          border: Border.all(color: AppColors.gray100),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                value == null
                    ? 'Select date & time'
                    : DateFormat.yMMMd().add_jm().format(value),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: value == null
                      ? AppColors.textMuted
                      : AppColors.textMain,
                ),
              ),
            ),
            const Icon(
              Icons.calendar_today,
              color: AppColors.textMuted,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown() {
    final options = <String>{..._categoryOptions};
    if (_selectedCategory != null && _selectedCategory!.isNotEmpty) {
      options.add(_selectedCategory!);
    }
    final list = options.toList();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.appBg,
        border: Border.all(color: AppColors.gray100),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: _selectedCategory ?? list.first,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textMain,
          ),
          items: list
              .map(
                (String value) =>
                    DropdownMenuItem<String>(value: value, child: Text(value)),
              )
              .toList(),
          onChanged: (value) {
            if (value == null) return;
            setState(() => _selectedCategory = value);
          },
        ),
      ),
    );
  }

  Widget _buildTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: () => _removeRole(text),
            child: Icon(Icons.close, color: color, size: 14),
          ),
        ],
      ),
    );
  }
}
