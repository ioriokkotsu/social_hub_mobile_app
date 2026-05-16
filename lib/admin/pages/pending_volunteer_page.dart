import 'package:flutter/material.dart';
import 'package:social_hub/theme/theme.dart';

class PendingVolunteersPage extends StatefulWidget {
  const PendingVolunteersPage({super.key});

  @override
  State<PendingVolunteersPage> createState() => _PendingVolunteersPageState();
}

class _PendingVolunteersPageState extends State<PendingVolunteersPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.appBg,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textMuted),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text('Pending Volunteers', style: TextStyle(fontFamily: 'Poppins', color: AppColors.textMain, fontSize: 18, fontWeight: FontWeight.bold)),
            Text('Rural Tech Education', style: TextStyle(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.w600)),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(70),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
            child: Row(
              children: [
                Expanded(child: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: AppColors.appBg, borderRadius: BorderRadius.circular(8)), child: Column(children: const [Text('Pending', style: TextStyle(fontSize: 10, color: AppColors.textMuted, fontWeight: FontWeight.w500)), Text('3', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.accent))]))),
                const SizedBox(width: 16),
                Expanded(child: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: AppColors.appBg, borderRadius: BorderRadius.circular(8)), child: Column(children: const [Text('Approved', style: TextStyle(fontSize: 10, color: AppColors.textMuted, fontWeight: FontWeight.w500)), Text('12', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primary))]))),
              ],
            ),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        physics: const BouncingScrollPhysics(),
        children: [
          _buildPendingCard(
            name: 'Sarah Jenkins', initials: 'SJ', color: Colors.blue, role: 'Logistics Coordinator',
            motivation: '"I have 3 years of experience organizing community events and managing transport logistics."',
          ),
          _buildPendingCard(
            name: 'David Chen', imgUrl: 'https://i.pravatar.cc/100?img=68', role: 'Coding Instructor',
          ),
        ],
      ),
    );
  }

  Widget _buildPendingCard({required String name, String? initials, Color? color, required String role, String? motivation, String? imgUrl}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.gray100), boxShadow: softShadow),
      child: Column(
        children: [
          Row(
            children: [
              if (imgUrl != null) CircleAvatar(backgroundImage: NetworkImage(imgUrl), radius: 20)
              else CircleAvatar(backgroundColor: color!.withOpacity(0.1), radius: 20, child: Text(initials!, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 14))),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)), Text('Role: $role', style: const TextStyle(fontSize: 10, color: AppColors.textMuted))])),
              Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), decoration: BoxDecoration(color: AppColors.accent.withOpacity(0.2), borderRadius: BorderRadius.circular(4)), child: const Text('New', style: TextStyle(color: AppColors.accent, fontSize: 10, fontWeight: FontWeight.bold))),
            ],
          ),
          if (motivation != null) Padding(padding: const EdgeInsets.only(top: 12), child: Container(width: double.infinity, padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: AppColors.appBg, borderRadius: BorderRadius.circular(8)), child: Text(motivation, style: const TextStyle(fontSize: 12, color: AppColors.textMuted, fontStyle: FontStyle.italic)))),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: ElevatedButton.icon(onPressed: () {}, icon: const Icon(Icons.check, size: 14), label: const Text('Approve', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)), style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary.withOpacity(0.1), foregroundColor: AppColors.primary, elevation: 0))),
              const SizedBox(width: 8),
              Expanded(child: ElevatedButton.icon(onPressed: () {}, icon: const Icon(Icons.close, size: 14), label: const Text('Reject', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)), style: ElevatedButton.styleFrom(backgroundColor: AppColors.red500.withOpacity(0.1), foregroundColor: AppColors.red500, elevation: 0))),
            ],
          )
        ],
      ),
    );
  }
}