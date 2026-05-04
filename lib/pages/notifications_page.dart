import 'package:flutter/material.dart';
import 'package:social_hub/theme/theme.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textMuted),
        title: const Text('Notifications', style: TextStyle(fontFamily: 'Poppins', color: AppColors.textMain, fontSize: 20, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(icon: const Icon(Icons.done_all, color: AppColors.primary), onPressed: () {}),
          const SizedBox(width: 8),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: AppColors.gray100, height: 1),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        physics: const BouncingScrollPhysics(),
        children: [
          _buildNotifCard(
            icon: Icons.workspace_premium,
            iconColor: AppColors.accent,
            title: 'New Badge Earned!',
            desc: 'You logged 50 volunteer hours.',
            time: '2 hours ago',
            bgColor: AppColors.appBg,
          ),
          _buildNotifCard(
            icon: Icons.description_outlined,
            iconColor: AppColors.primary,
            title: 'Transparency Report',
            desc: 'for Rural Tech project is available.',
            time: 'Yesterday',
            bgColor: Colors.transparent,
          ),
        ],
      ),
    );
  }

  Widget _buildNotifCard({required IconData icon, required Color iconColor, required String title, required String desc, required String time, required Color bgColor}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(16)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(color: iconColor.withOpacity(0.2), shape: BoxShape.circle),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    style: const TextStyle(fontFamily: 'Inter', fontSize: 14, color: AppColors.textMain),
                    children: [
                      TextSpan(text: '$title ', style: const TextStyle(fontWeight: FontWeight.bold)),
                      TextSpan(text: desc),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Text(time, style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
              ],
            ),
          )
        ],
      ),
    );
  }
}