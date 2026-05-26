import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:social_hub/services/future_builder.dart';
import 'package:social_hub/services/stream_builder.dart';
import 'package:social_hub/theme/theme.dart';

class ViewDonation extends StatefulWidget {
  const ViewDonation({super.key, required this.eventID});

  final String eventID;

  @override
  State<ViewDonation> createState() => _ViewDonationState();
}

class _ViewDonationState extends State<ViewDonation> {
  final formatter = NumberFormat.currency(
    locale: 'en_MY',
    symbol: 'RM',
    decimalDigits: 2,
  );
  @override
  Widget build(BuildContext context) {
    return Scaffold(
          backgroundColor: AppColors.appBg,
          appBar: AppBar(
            backgroundColor: AppColors.surface,
            elevation: 0,
            iconTheme: const IconThemeData(color: AppColors.textMuted),
            centerTitle: true,
            title: FirestoreFutureBuilder(
              future: FirebaseFirestore.instance
                  .collection('communityEvents')
                  .doc(widget.eventID)
                  .get(),
              builder: (event) {
                return Column(
                  children: [
                    Text(
                      '${event.exists ? event['eventTitle'] ?? 'Unknown Event' : 'Unknown Event'}',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        color: AppColors.textMain,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                );
              }
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
                      const SizedBox(
                        height: 12,
                      ),
                      const Text(
                        'Total Donated',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textMuted,
                        ),
                      ),
                      const SizedBox(height: 4),
                      FirestoreStreamBuilder(
                        stream: FirebaseFirestore.instance
                            .collection('communityEvents')
                            .doc(widget.eventID)
                            .snapshots(),
                        builder: (event) {
                          return Text(
                            formatter.format(event.data()?['amountRaised'] ?? 0),
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          );
                        }
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
                    'Recent Received Donations',
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
                  empty: const Center(
                    child: Text(
                      'No donations made yet.',
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  loading: const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ),
                  future: FirebaseFirestore.instance
                      .collection('donations')
                      .where(
                        'eventID',
                        isEqualTo: FirebaseFirestore.instance
                            .collection('communityEvents')
                            .doc(widget.eventID),
                      )
                      .orderBy('createdAt', descending: true)
                      .get(),
                  builder: (donation) {
                    return donation.size == 0
                        ? Padding(
                            padding: const EdgeInsets.symmetric(vertical: 20.0),
                            child: Center(
                              child: const Text(
                                'This event has no donations yet.',
                                style: TextStyle(
                                  color: AppColors.textMuted,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(24),
                            physics: const BouncingScrollPhysics(),
                            itemCount: donation.size,
                            itemBuilder: (context, index) {
                              final transaction = donation.docs[index];
                              return _buildTransaction(
                                userRef:
                                    transaction['userID'] as DocumentReference,
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
  }

  Widget _buildTransaction({
    required String date,
    required String amount,
    required DocumentReference userRef,
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
                future: userRef.get(),
                builder: (user) {
                  return Row(
                    children: [
                      CircleAvatar(
                          backgroundImage: NetworkImage(user['profileURL'] ?? ''),
                          radius: 20,
                        ),
                      const SizedBox(
                        width: 12,
                      ),
                      Text(
                        user.exists
                            ? user['displayName'] ?? 'Unknown User'
                            : 'Align with Event Name',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 4),
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
