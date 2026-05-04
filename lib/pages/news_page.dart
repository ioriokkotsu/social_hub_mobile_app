import 'package:flutter/material.dart';
import 'package:social_hub/theme/theme.dart';

class NewsPage extends StatefulWidget {
  const NewsPage({super.key});

  @override
  State<NewsPage> createState() => _NewsPageState();
}

class _NewsPageState extends State<NewsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.appBg,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textMuted),
        title: const Text(
          'Global News',
          style: TextStyle(
            fontFamily: 'Poppins',
            color: AppColors.textMain,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        physics: const BouncingScrollPhysics(),
        children: [
          _buildNewsCard(
            tag: 'Environment',
            tagColor: AppColors.primary,
            title: 'UN Announces New Global Plastic Treaty Negotiations',
            source: 'Reuters • 2 hours ago',
            imageUrl:
                'https://images.unsplash.com/photo-1532996122724-e3c354a0b15b?w=200&q=80',
          ),
          _buildNewsCard(
            tag: 'Education',
            tagColor: AppColors.accent,
            title: 'How Tech is Closing the Gap in Rural Communities',
            source: 'Global Times • 5 hours ago',
            imageUrl:
                'https://images.unsplash.com/photo-1522202176988-66273c2fd55f?w=200&q=80',
          ),
          _buildNewsCard(
            tag: 'Innovation',
            tagColor: AppColors.blue500,
            title:
                'Startups Focus on SDG 9: Industry, Innovation, and Infrastructure',
            source: 'Tech Insider • 1 day ago',
            iconFallback: Icons.image_outlined,
          ),
        ],
      ),
    );
  }

  Widget _buildNewsCard({
    required String tag,
    required Color tagColor,
    required String title,
    required String source,
    String? imageUrl,
    IconData? iconFallback,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: softShadow,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image or Icon Fallback
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              color: AppColors.gray100,
              borderRadius: BorderRadius.circular(16),
              image: imageUrl != null
                  ? DecorationImage(
                      image: NetworkImage(imageUrl),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: imageUrl == null && iconFallback != null
                ? Icon(iconFallback, color: Colors.grey[400], size: 32)
                : null,
          ),
          const SizedBox(width: 12),
          // Content
          Expanded(
            child: SizedBox(
              height: 96,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tag.toUpperCase(),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: tagColor,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          height: 1.2,
                          color: AppColors.textMain,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                  Text(
                    source,
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
