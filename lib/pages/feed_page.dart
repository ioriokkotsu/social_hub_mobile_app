import 'package:flutter/material.dart';
import 'package:social_hub/theme/theme.dart';

// --- Data Model for Posts ---
class _PostData {
  final String name;
  final String role;
  final String? avatarUrl;
  final bool isPartner;
  final String content;
  final String? imageUrl;
  int likes;
  int comments;
  bool isLiked;

  _PostData({
    required this.name,
    required this.role,
    this.avatarUrl,
    this.isPartner = false,
    required this.content,
    this.imageUrl,
    required this.likes,
    required this.comments,
    this.isLiked = false,
  });
}

class FeedPage extends StatefulWidget {
  const FeedPage({super.key});

  @override
  State<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  // Initial dummy data
  final List<_PostData> _posts = [
    _PostData(
      name: 'Sarah Jenkins',
      role: 'Volunteer • 2 hrs ago',
      avatarUrl: 'https://i.pravatar.cc/150?img=12',
      content: 'Just wrapped up an amazing weekend at the City Park Tree Planting event! We managed to plant over 200 saplings. 🌳💚 #SDG13 #ClimateAction',
      imageUrl: 'https://images.unsplash.com/photo-1542601906990-b4d3fb778b09?w=600&q=80',
      likes: 24,
      comments: 5,
    ),
    _PostData(
      name: 'EduGlobal NGO',
      role: 'Partner • 5 hrs ago',
      isPartner: true,
      content: 'A huge thank you to all the donors! We just hit 60% of our funding goal for the Rural Tech Education Initiative. We are so close to bringing these labs to life. 💻🚀',
      likes: 112,
      comments: 18,
    ),
  ];

  // --- Show Bottom Sheet to Create Post ---
  void _showCreatePostSheet() {
    final TextEditingController postController = TextEditingController();
    bool hasImage = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateSheet) {
            return Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
              child: Container(
                decoration: const BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(32), topRight: Radius.circular(32)),
                ),
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Create Post', style: TextStyle(fontFamily: 'Poppins', fontSize: 20, fontWeight: FontWeight.bold)),
                        IconButton(icon: const Icon(Icons.close, color: AppColors.textMuted), onPressed: () => Navigator.pop(context)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const CircleAvatar(backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=32'), radius: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: postController,
                            maxLines: 4,
                            decoration: const InputDecoration(
                              hintText: 'What do you want to share?',
                              border: InputBorder.none,
                              hintStyle: TextStyle(color: AppColors.textMuted, fontSize: 14),
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (hasImage)
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 12),
                        height: 150,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          image: const DecorationImage(
                            image: NetworkImage('https://images.unsplash.com/photo-1532996122724-e3c354a0b15b?w=600&q=80'),
                            fit: BoxFit.cover,
                          ),
                        ),
                        child: Align(
                          alignment: Alignment.topRight,
                          child: IconButton(
                            icon: const Icon(Icons.cancel, color: Colors.white),
                            onPressed: () => setStateSheet(() => hasImage = false),
                          ),
                        ),
                      ),
                    const Divider(color: AppColors.gray100),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton.icon(
                          onPressed: () => setStateSheet(() => hasImage = true),
                          icon: const Icon(Icons.image_outlined, color: AppColors.primary),
                          label: const Text('Add Image', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            if (postController.text.isNotEmpty || hasImage) {
                              setState(() {
                                _posts.insert(0, _PostData(
                                  name: 'Alex Volunteer',
                                  role: 'Volunteer • Just now',
                                  avatarUrl: 'https://i.pravatar.cc/150?img=32',
                                  content: postController.text,
                                  imageUrl: hasImage ? 'https://images.unsplash.com/photo-1532996122724-e3c354a0b15b?w=600&q=80' : null,
                                  likes: 0,
                                  comments: 0,
                                ));
                              });
                              Navigator.pop(context);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text('Post', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }
        );
      },
    );
  }

  // --- Show Bottom Sheet for Comments ---
  void _showCommentsSheet(int index) {
    final TextEditingController commentController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateSheet) {
            return Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
              child: Container(
                height: MediaQuery.of(context).size.height * 0.6,
                decoration: const BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(32), topRight: Radius.circular(32)),
                ),
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Comments (${_posts[index].comments})', style: const TextStyle(fontFamily: 'Poppins', fontSize: 18, fontWeight: FontWeight.bold)),
                        IconButton(icon: const Icon(Icons.close, color: AppColors.textMuted), onPressed: () => Navigator.pop(context)),
                      ],
                    ),
                    const Divider(color: AppColors.gray100),
                    Expanded(
                      child: ListView(
                        physics: const BouncingScrollPhysics(),
                        children: [
                          if (_posts[index].comments > 0)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const CircleAvatar(backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=44'), radius: 16),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: AppColors.appBg,
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: const [
                                          Text('Jane Doe', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.textMain)),
                                          SizedBox(height: 4),
                                          Text('This is amazing! Great work everyone 👏', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Simulated dynamic comments could be added here
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        const CircleAvatar(backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=32'), radius: 18),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              color: AppColors.appBg,
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: TextField(
                              controller: commentController,
                              decoration: const InputDecoration(
                                hintText: 'Add a comment...',
                                hintStyle: TextStyle(fontSize: 14, color: AppColors.textMuted),
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.send, color: AppColors.primary),
                          onPressed: () {
                            if (commentController.text.isNotEmpty) {
                              setState(() {
                                _posts[index].comments++;
                              });
                              setStateSheet(() {
                                commentController.clear();
                              });
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.appBg,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text('Community Feed', style: TextStyle(fontFamily: 'Poppins', color: AppColors.textMain, fontSize: 20, fontWeight: FontWeight.bold)),
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.only(bottomLeft: Radius.circular(32), bottomRight: Radius.circular(32))),
      ),
      body: ListView(
        padding: const EdgeInsets.only(top: 16, bottom: 24),
        physics: const BouncingScrollPhysics(),
        children: [
          // Create Post Input area
          GestureDetector(
            onTap: _showCreatePostSheet,
            child: Container(
              color: AppColors.surface,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              margin: const EdgeInsets.only(bottom: 16),
              child: Row(
                children: [
                  const CircleAvatar(backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=32'), radius: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      decoration: BoxDecoration(color: AppColors.appBg, borderRadius: BorderRadius.circular(24)),
                      child: const Text('Share an update or milestone...', style: TextStyle(color: AppColors.textMuted, fontSize: 14)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Icon(Icons.image_outlined, color: AppColors.primary),
                ],
              ),
            ),
          ),
          
          // Dynamically rendering posts
          ...List.generate(_posts.length, (index) => _buildPostCard(index)),
        ],
      ),
    );
  }

  Widget _buildPostCard(int index) {
    final post = _posts[index];
    
    return Container(
      color: AppColors.surface,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    if (post.avatarUrl != null) 
                      CircleAvatar(backgroundImage: NetworkImage(post.avatarUrl!), radius: 20)
                    else 
                      Container(width: 40, height: 40, decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.2), shape: BoxShape.circle), child: const Center(child: Text('EG', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)))),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(post.name, style: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 14)), 
                            if (post.isPartner) 
                              const Padding(padding: EdgeInsets.only(left: 4), child: Icon(Icons.check_circle, color: AppColors.secondary, size: 14))
                          ],
                        ),
                        Text(post.role, style: const TextStyle(color: AppColors.textMuted, fontSize: 10)),
                      ],
                    ),
                  ],
                ),
                const Icon(Icons.more_horiz, color: AppColors.textMuted),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24), 
            child: Text(post.content, style: const TextStyle(fontSize: 14, height: 1.5, color: AppColors.textMain))
          ),
          if (post.imageUrl != null) 
            Padding(
              padding: const EdgeInsets.only(top: 12), 
              child: Image.network(post.imageUrl!, height: 200, width: double.infinity, fit: BoxFit.cover)
            ),
          const SizedBox(height: 12),
          const Divider(color: AppColors.gray100, height: 1),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Interactive Like Button
                GestureDetector(
                  onTap: () {
                    setState(() {
                      post.isLiked = !post.isLiked;
                      post.likes += post.isLiked ? 1 : -1;
                    });
                  },
                  child: _buildInteractionBtn(
                    post.isLiked ? Icons.thumb_up_alt : Icons.thumb_up_alt_outlined, 
                    '${post.likes}',
                    color: post.isLiked ? AppColors.primary : AppColors.textMuted,
                  ),
                ),
                
                // Interactive Comment Button
                GestureDetector(
                  onTap: () => _showCommentsSheet(index),
                  child: _buildInteractionBtn(Icons.chat_bubble_outline, '${post.comments}'),
                ),
                
                // Share Button
                _buildInteractionBtn(Icons.share_outlined, 'Share'),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildInteractionBtn(IconData icon, String text, {Color? color}) {
    final effectiveColor = color ?? AppColors.textMuted;
    return Row(
      children: [
        Icon(icon, color: effectiveColor, size: 18),
        const SizedBox(width: 6),
        Text(text, style: TextStyle(color: effectiveColor, fontSize: 14)),
      ],
    );
  }
}