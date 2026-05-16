import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:social_hub/services/auth_service.dart';
import 'package:social_hub/services/future_builder.dart';
import 'package:social_hub/theme/theme.dart';

class DonationHistoryPage extends StatefulWidget {
  const DonationHistoryPage({super.key});

  @override
  State<DonationHistoryPage> createState() => _DonationHistoryPageState();
}

class _DonationHistoryPageState extends State<DonationHistoryPage> {
  final formatter = NumberFormat.currency(
    locale: 'en_MY',
    symbol: 'RM',
    decimalDigits: 2,
  );
  @override
  Widget build(BuildContext context) {
    return FirestoreFutureBuilder(
      future: AuthService().getUserData(AuthService().currentUser!.uid),
      builder: (user) {
        return Scaffold(
          backgroundColor: AppColors.appBg,
          appBar: AppBar(
            backgroundColor: AppColors.surface,
            elevation: 0,
            iconTheme: const IconThemeData(color: AppColors.textMuted),
            centerTitle: true,
            title: const Text(
              'My Donations',
              style: TextStyle(
                fontFamily: 'Poppins',
                color: AppColors.textMain,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(100),
              child: Container(
                padding: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(32),
                    bottomRight: Radius.circular(32),
                  ),
                  boxShadow: softShadow,
                ),
                child: Center(
                  child: Column(
                    children: [
                      const Text(
                        'Total Donated',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textMuted,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        formatter.format(user?['totalDonated'] ?? 0),
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          body: Column(
            children: [
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Container(
                    width: 100,
                    height: 1,
                    decoration: BoxDecoration(
                      color: AppColors.textMain,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const Text(
                    'Recent Transactions',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Container(
                    width: 100,
                    height: 1,
                    decoration: BoxDecoration(
                      color: AppColors.textMain,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ],
              ),
              Expanded(
                child: FirestoreFutureBuilder(
                  loading: const Center(child: CircularProgressIndicator(color: AppColors.primary)),
                  future: FirebaseFirestore.instance
                      .collection('donations')
                      .where(
                        'userID',
                        isEqualTo: FirebaseFirestore.instance
                            .collection('users')
                            .doc(AuthService().currentUser!.uid),
                      )
                      .orderBy('createdAt', descending: true)
                      .get(),
                  builder: (donation) {
                    return ListView.builder(
                      padding: const EdgeInsets.all(24),
                      physics: const BouncingScrollPhysics(),
                      itemCount: donation.size,
                      itemBuilder: (context, index) {
                        final transaction = donation.docs[index];
                        return _buildTransaction(
                          eventRef: transaction['eventID'] as DocumentReference,
                          ngoRef: transaction['ngoID'] as DocumentReference,
                          date: transaction['createdAt'] != null
                              ? DateFormat.yMMMd().add_jm().format(
                                  transaction['createdAt'].toDate(),
                                )
                              : 'Unknown Date',
                          amount: formatter.format(transaction['amount']),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTransaction({
    required DocumentReference ngoRef,
    required String date,
    required String amount,
    required DocumentReference eventRef,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: softShadow,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FirestoreFutureBuilder(
                width: 184.3,
                height: 20,
                future: eventRef.get(),
                builder: (event) {
                  return Text(
                    event.exists ? event['eventTitle'] : 'Align with Event Name',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  );
                },
              ),
              const SizedBox(height: 4),
              FirestoreFutureBuilder(
                width: 92.3,
                height: 19,
                future: ngoRef.get(),
                builder: (ngo) {
                  return Text(
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    ngo.exists ? ngo['ngoName'] : 'Align with NGO Name',
                    style: const TextStyle(
                      fontWeight: FontWeight.normal,
                      fontSize: 13,
                    ),
                  );
                },
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                amount,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                date,
                style: const TextStyle(
                  fontSize: 10,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
