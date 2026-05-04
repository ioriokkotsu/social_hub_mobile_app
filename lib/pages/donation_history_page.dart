import 'package:flutter/material.dart';
import 'package:social_hub/theme/theme.dart';

class DonationHistoryPage extends StatefulWidget {
  const DonationHistoryPage({super.key});

  @override
  State<DonationHistoryPage> createState() => _DonationHistoryPageState();
}

class _DonationHistoryPageState extends State<DonationHistoryPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.appBg,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textMuted),
        title: const Text('My Impact', style: TextStyle(fontFamily: 'Poppins', color: AppColors.textMain, fontSize: 20, fontWeight: FontWeight.bold)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(100),
          child: Container(
            padding: const EdgeInsets.only(bottom: 24),
            decoration: BoxDecoration(color: AppColors.surface, borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(32), bottomRight: Radius.circular(32)), boxShadow: softShadow),
            child: Center(
              child: Column(
                children: const [
                  Text('Total Donated', style: TextStyle(fontSize: 14, color: AppColors.textMuted)),
                  SizedBox(height: 4),
                  Text('\$450.00', style: TextStyle(fontFamily: 'Poppins', fontSize: 36, fontWeight: FontWeight.bold, color: AppColors.primary)),
                ],
              ),
            ),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        physics: const BouncingScrollPhysics(),
        children: [
          const Text('Recent Transactions', style: TextStyle(fontFamily: 'Poppins', fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _buildTransaction(org: 'EduGlobal NGO', date: 'Oct 12, 2023 • Rural Tech', amount: '+\$25.00'),
          _buildTransaction(org: 'Water for All', date: 'Sep 28, 2023 • Clean Wells', amount: '+\$50.00'),
          _buildTransaction(org: 'Green Earth NGO', date: 'Aug 05, 2023 • General', amount: '+\$100.00'),
        ],
      ),
    );
  }

  Widget _buildTransaction({required String org, required String date, required String amount}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16), boxShadow: softShadow),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(org, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 4),
              Text(date, style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(amount, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 14)),
              const SizedBox(height: 4),
              const Text('View Report', style: TextStyle(fontSize: 10, color: AppColors.blue500, decoration: TextDecoration.underline)),
            ],
          )
        ],
      ),
    );
  }
}