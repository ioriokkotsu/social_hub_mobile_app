import 'package:flutter/material.dart';
import 'package:social_hub/theme/theme.dart';

class MyBadgesPage extends StatefulWidget {
  const MyBadgesPage({super.key});

  @override
  State<MyBadgesPage> createState() => _MyBadgesPageState();
}

class _MyBadgesPageState extends State<MyBadgesPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.appBg,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textMuted),
        title: const Text('My Badges', style: TextStyle(fontFamily: 'Poppins', color: AppColors.textMain, fontSize: 20, fontWeight: FontWeight.bold)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        physics: const BouncingScrollPhysics(),
        children: [
          const Text('Earned Achievements', style: TextStyle(fontFamily: 'Poppins', fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 1.1,
            children: [
              _buildBadgeCard(icon: Icons.workspace_premium, title: 'Top 10%', desc: 'Most active this month', color: AppColors.accent),
              _buildBadgeCard(icon: Icons.schedule, title: '50 Hours', desc: 'Total volunteer time', color: AppColors.primary),
              _buildBadgeCard(icon: Icons.favorite, title: 'First Donor', desc: 'Supported a project', color: AppColors.secondary),
            ],
          ),
          const SizedBox(height: 32),
          const Text('Locked Badges', style: TextStyle(fontFamily: 'Poppins', fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Opacity(
            opacity: 0.5,
            child: GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.1,
              children: [
                _buildBadgeCard(icon: Icons.schedule, title: '100 Hours', desc: 'Keep going!', color: Colors.grey, isLocked: true),
                _buildBadgeCard(icon: Icons.public, title: 'Global Citizen', desc: 'Join 5 Int. projects', color: Colors.grey, isLocked: true),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildBadgeCard({required IconData icon, required String title, required String desc, required Color color, bool isLocked = false}) {
    return Container(
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: isLocked ? AppColors.gray100 : color.withOpacity(0.2)), boxShadow: softShadow),
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(width: 48, height: 48, decoration: BoxDecoration(color: isLocked ? AppColors.gray100 : color.withOpacity(0.1), shape: BoxShape.circle), child: Icon(icon, color: color, size: 24)),
          const SizedBox(height: 12),
          Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: isLocked ? Colors.grey[700] : AppColors.textMain)),
          const SizedBox(height: 4),
          Text(desc, style: TextStyle(fontSize: 10, color: isLocked ? Colors.grey[500] : AppColors.textMuted), textAlign: TextAlign.center),
        ],
      ),
    );
  }
}