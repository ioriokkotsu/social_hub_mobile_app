import 'package:flutter/material.dart';
import 'package:social_hub/theme/theme.dart';

class VolunteerDashboardPage extends StatefulWidget {
  const VolunteerDashboardPage({super.key});

  @override
  State<VolunteerDashboardPage> createState() => _VolunteerDashboardPageState();
}

class _VolunteerDashboardPageState extends State<VolunteerDashboardPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.appBg,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textMuted),
        title: const Text('My Volunteer Dash', style: TextStyle(fontFamily: 'Poppins', color: AppColors.textMain, fontSize: 20, fontWeight: FontWeight.bold)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: Container(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
            alignment: Alignment.centerLeft,
            child: Row(
              children: [
                _buildBadgePreview(Icons.workspace_premium, 'Top 10%', AppColors.accent),
                const SizedBox(width: 12),
                _buildBadgePreview(Icons.schedule, '50 Hrs', AppColors.primary),
              ],
            ),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        physics: const BouncingScrollPhysics(),
        children: [
          const Text('Upcoming Tasks', style: TextStyle(fontFamily: 'Poppins', fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16), boxShadow: softShadow, border: const Border(left: BorderSide(color: AppColors.primary, width: 4))),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text('Teach HTML Basics', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        const SizedBox(width: 8),
                        Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), decoration: BoxDecoration(color: AppColors.secondary.withOpacity(0.2), borderRadius: BorderRadius.circular(4)), child: const Text('Tomorrow', style: TextStyle(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.bold))),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(children: const [Icon(Icons.location_on, size: 12, color: AppColors.textMuted), SizedBox(width: 4), Text('Rural Tech Edu Hub', style: TextStyle(fontSize: 12, color: AppColors.textMuted))])
                  ],
                ),
                Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(8)), child: const Text('View', style: TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.bold))),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          const Text('Recent Activity', style: TextStyle(fontFamily: 'Poppins', fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16), boxShadow: softShadow, border: const Border(left: BorderSide(color: AppColors.accent, width: 4))),
            child: Row(
              children: [
                Container(width: 40, height: 40, decoration: BoxDecoration(color: AppColors.accent.withOpacity(0.1), shape: BoxShape.circle), child: const Icon(Icons.schedule, color: AppColors.accent, size: 20)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Ocean Cleanup Drive', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      Row(children: const [Text('4 Hours • ', style: TextStyle(fontSize: 10, color: AppColors.textMuted)), Text('Pending Approval', style: TextStyle(fontSize: 10, color: AppColors.accent, fontWeight: FontWeight.bold))]),
                    ],
                  ),
                )
              ],
            ),
          ),

          const SizedBox(height: 24),
          const Text('Joined Projects', style: TextStyle(fontFamily: 'Poppins', fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16), boxShadow: softShadow),
            child: Row(
              children: [
                Container(width: 48, height: 48, decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), image: const DecorationImage(image: NetworkImage('https://images.unsplash.com/photo-1542601906990-b4d3fb778b09?w=100&q=80'), fit: BoxFit.cover))),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text('Ocean Cleanup', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      Text('Active • 12 hrs logged', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: AppColors.primary),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildBadgePreview(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: color.withOpacity(0.1), border: Border.all(color: color.withOpacity(0.2)), borderRadius: BorderRadius.circular(8)),
      child: Row(
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}