import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:social_hub/admin/admin_ops.dart';
import 'package:social_hub/pages/ngo_profile_page.dart';
import 'package:social_hub/pages/volunteer_application_page.dart';
import 'package:social_hub/services/auth_service.dart';
import 'package:social_hub/services/future_builder.dart';
import 'package:social_hub/services/stream_builder.dart';
import 'package:social_hub/theme/theme.dart';
import 'package:intl/intl.dart';

class ProjectDetailPage extends StatefulWidget {
  const ProjectDetailPage({super.key, required this.uid});

  final String uid;

  @override
  State<ProjectDetailPage> createState() => _ProjectDetailPageState();
}

class _ProjectDetailPageState extends State<ProjectDetailPage> {
  String selectedAmt = '';
  final formatter = NumberFormat.currency(
    locale: 'en_MY',
    symbol: 'RM',
    decimalDigits: 2,
  );
  late DocumentReference eventRef = FirebaseFirestore.instance
      .collection('communityEvents')
      .doc(widget.uid);
  @override
  Widget build(BuildContext context) {
    return FirestoreFutureBuilder(
      future: AuthService().getCollectionData(widget.uid, 'communityEvents'),
      builder: (event) {
        return Scaffold(
          backgroundColor: AppColors.surface,
          body: Stack(
            children: [
              CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverAppBar(
                    expandedHeight: 250,
                    pinned: true,
                    backgroundColor: AppColors.primary.withAlpha(100),
                    iconTheme: const IconThemeData(color: Colors.black),
                    flexibleSpace: FlexibleSpaceBar(
                      background: Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.network(
                            'https://images.unsplash.com/photo-1506744038136-46273834b3fb?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8Mnx8cHJvamVjdHxlbnwwfHwwfHx8MA%3D%3D&auto=format&fit=crop&w=800&q=60',
                            fit: BoxFit.cover,
                          ),
                          Container(color: Colors.black.withValues(alpha: 0.1)),
                        ],
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Container(
                      transform: Matrix4.translationValues(0.0, -24.0, 0.0),
                      decoration: const BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(24),
                          topRight: Radius.circular(24),
                        ),
                      ),
                      padding: const EdgeInsets.fromLTRB(24, 24, 24, 100),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              const Icon(
                                Icons.menu_book,
                                color: AppColors.primary,
                                size: 14,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                (event?['eventCategory'] ?? 'Uncategorized').toUpperCase(),
                                style: const TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${event?['eventTitle'] ?? 'Project Title'}',
                            style: GoogleFonts.poppins(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            //start date - end date
                            '${DateFormat.yMMMd().add_jm().format((event?['startDate'] as Timestamp).toDate())} - ${DateFormat.yMMMd().add_jm().format((event?['endDate'] as Timestamp).toDate())}',
                            style: GoogleFonts.poppins(
                              fontSize: 15.5,
                              color: AppColors.textMain,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 24),
                          RichText(
                            text: TextSpan(
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                color: Colors.black,
                              ),
                              children: [
                                TextSpan(
                                  text: 'Location: ',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                TextSpan(
                                  text: event?['eventVenue'] ?? 'N/A',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textMuted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'Organized by: ',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: AppColors.textMain,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),

                          FirestoreFutureBuilder(
                            future: AuthService().getCollectionData(
                              event?['organizedBy'],
                              'ngo',
                            ),
                            builder: (ngo) {
                              bool isVerified = ngo?['isVerified'] == true;
                              return InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    createSlideRoute(
                                      NGOProfilePage(ngoId: ngo?['uid']),
                                    ),
                                  );
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: isVerified
                                        ? AppColors.primary.withValues(
                                            alpha: 0.15,
                                          )
                                        : AppColors.appBg,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: isVerified
                                          ? AppColors.primary.withValues(
                                              alpha: 0.25,
                                            )
                                          : AppColors.textMain.withValues(
                                              alpha: 0.25,
                                            ),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 40,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          color: AppColors.primary.withValues(
                                            alpha: 0.2,
                                          ),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Center(
                                          child: Text(
                                            'EG',
                                            style: TextStyle(
                                              color: AppColors.primary,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      isVerified
                                          ? Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  ngo?['ngoName'] ?? 'NGO Name',
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                                Text(
                                                  'Verified via ${ngo?['verifiedBy'] ?? 'email'}',
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    color: AppColors.textMuted,
                                                  ),
                                                ),
                                              ],
                                            )
                                          : Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  ngo?['ngoName'] ?? 'NGO Name',
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                                Text(
                                                  'Not Verified',
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    color: AppColors.textMuted,
                                                  ),
                                                ),
                                              ],
                                            ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 24),
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: AppColors.appBg,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Column(
                                    children: [
                                      const Text(
                                        'Raised',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: AppColors.textMuted,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        formatter.format(
                                          event?['amountRaised'] ?? 0,
                                        ),
                                        style: const TextStyle(
                                          fontSize: 16.5,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: AppColors.appBg,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Column(
                                    children: [
                                      const Text(
                                        'Target',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: AppColors.textMuted,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        formatter.format(
                                          event?['amountTarget'] ?? 0,
                                        ),
                                        style: const TextStyle(
                                          fontSize: 16.5,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          const Text(
                            'Description',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            event?['eventDescription'] ??
                                'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.',
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.textMuted,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    border: const Border(
                      top: BorderSide(color: AppColors.gray100),
                    ),
                    boxShadow: floatingShadow,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Expanded(
                          child: StreamBuilder<QuerySnapshot>(
                            stream: FirebaseFirestore.instance
                                .collection('volunteerApplication')
                                .where(
                                  'eventID',
                                  isEqualTo: FirebaseFirestore.instance
                                      .collection('communityEvents')
                                      .doc(widget.uid),
                                )
                                .where(
                                  'userID',
                                  isEqualTo: FirebaseFirestore.instance
                                      .collection('users')
                                      .doc(AuthService().currentUser!.uid),
                                )
                                .where('status', isNotEqualTo: 'Rejected')
                                .snapshots(),

                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              }

                              if (snapshot.hasError) {
                                return const Text('Something went wrong');
                              }

                              final docs = snapshot.data?.docs ?? [];

                              DocumentSnapshot? document = docs.isNotEmpty
                                  ? docs.first
                                  : null;

                              String status = '';

                              if (document != null) {
                                status = document['status'] ?? '';
                              }

                              bool canApply =
                                  status != 'Approved' && status != 'Pending';

                              return ElevatedButton(
                                onPressed: canApply
                                    ? () {
                                        Navigator.push(
                                          context,
                                          createSlideRoute(
                                            VolunteerApplicationPage(
                                              eventID: widget.uid,
                                              ngoRef: event?['organizedBy'],
                                            ),
                                          ),
                                        );
                                      }
                                    : null,

                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.secondary
                                      .withValues(alpha: 0.1),
                                  foregroundColor: AppColors.primary,
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),

                                child: Text(
                                  status == 'Approved'
                                      ? 'Joined'
                                      : status == 'Pending'
                                      ? 'Pending'
                                      : 'Join',

                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _showDonationSheet(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Text(
                            'Donate',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showDonationSheet(BuildContext context) {
    String selectedAmtLocal = selectedAmt;
    FocusNode textFocus = FocusNode();
    TextEditingController textController = TextEditingController();

    void paymentAction(double amount) async {
      try {
        DocumentReference ngoRef = await eventRef.get().then((doc) {
          if (doc.exists) {
            return doc['organizedBy'] as DocumentReference;
          } else {
            throw Exception('Event not found');
          }
        });
        AuthService().addDocToCollection('donations', {
          'amount': amount,
          'eventID': eventRef,
          'userID': FirebaseFirestore.instance
              .collection('users')
              .doc(AuthService().currentUser!.uid),
          'createdAt': FieldValue.serverTimestamp(),
          'currency': 'myr',
          'status': 'Successful',
          'ngoID': ngoRef,
        });
        await eventRef.update({'amountRaised': FieldValue.increment(amount)});
        AuthService().updateCollection(AuthService().currentUser!.uid, {
          'totalDonated': FieldValue.increment(amount),
        });
        await ngoRef.update({
          'overallStats.totalRaised': FieldValue.increment(amount),
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Payment successful! Thank you for your donation.'),
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Payment failed: ${e.toString()}')),
        );
      }
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return GestureDetector(
          onTap: () => textFocus.unfocus(),
          child: StatefulBuilder(
            builder: (context, setModalState) {
              return Container(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                decoration: const BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(32),
                    topRight: Radius.circular(32),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Select Amount',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.close,
                              color: AppColors.textMuted,
                            ),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildAmtBtn('RM10', selectedAmtLocal, (
                              val,
                            ) {
                              setModalState(() {
                                selectedAmtLocal = val;
                                textController.text = val.replaceAll('RM', '');
                              });
                            }),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildAmtBtn('RM25', selectedAmtLocal, (
                              val,
                            ) {
                              setModalState(() {
                                selectedAmtLocal = val;
                                textController.text = val.replaceAll('RM', '');
                              });
                            }),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildAmtBtn('RM50', selectedAmtLocal, (
                              val,
                            ) {
                              setModalState(() {
                                selectedAmtLocal = val;
                                textController.text = val.replaceAll('RM', '');
                              });
                            }),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.appBg,
                          border: Border.all(color: AppColors.gray100),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: TextField(
                          onChanged: (value) {
                            setModalState(() {
                              selectedAmtLocal = '';
                            });
                          },
                          controller: textController,
                          focusNode: textFocus,
                          decoration: InputDecoration(
                            prefixText: 'RM',
                            hintText: ' Custom Amount (RM)',
                            border: InputBorder.none,
                            hintStyle: const TextStyle(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          keyboardType: TextInputType.number,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => paymentAction(
                            textController.text.isNotEmpty
                                ? double.parse(textController.text)
                                : 0,
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.textMain,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Pay securely',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildAmtBtn(
    String amt,
    String selectedAmt,
    Function(String) onSelected,
  ) {
    bool isSelected = selectedAmt == amt;

    return GestureDetector(
      onTap: () {
        onSelected(amt);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.05)
              : Colors.transparent,
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.gray100,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.center,
        child: Text(
          amt,
          style: TextStyle(
            color: isSelected ? AppColors.primary : AppColors.textMain,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
