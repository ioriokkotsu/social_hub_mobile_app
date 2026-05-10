import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:social_hub/services/auth_service.dart';
import 'package:social_hub/services/stream_builder.dart';
import 'package:social_hub/theme/theme.dart';

class FeedPage extends StatefulWidget {
  const FeedPage({super.key});

  @override
  State<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void _showCreatePostSheet() {
    final TextEditingController postController = TextEditingController();
    bool hasImage = false;
    String? imageUrl;

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
                    if (hasImage && imageUrl != null)
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 12),
                        height: 150,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          image: DecorationImage(
                            image: NetworkImage(imageUrl!),
                            fit: BoxFit.cover,
                          ),
                        ),
                        child: Align(
                          alignment: Alignment.topRight,
                          child: IconButton(
                            icon: const Icon(Icons.cancel, color: Colors.white),
                            onPressed: () => setStateSheet(() {
                              hasImage = false;
                              imageUrl = null;
                            }),
                          ),
                        ),
                      ),
                    const Divider(color: AppColors.gray100),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton.icon(
                          onPressed: () => setStateSheet(() {
                            hasImage = true;
                            imageUrl = 'https://images.unsplash.com/photo-1532996122724-e3c354a0b15b?w=600&q=80';
                          }),
                          icon: const Icon(Icons.image_outlined, color: AppColors.primary),
                          label: const Text('Add Image', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            if (postController.text.isNotEmpty || hasImage) {
                              try {
                                final currentUser = AuthService().currentUser;
                                if (currentUser == null) return;

                                await _firestore.collection('feedPosts').add({
                                  'contentMessage': postController.text,
                                  'imageURL': imageUrl,
                                  'createdAt': FieldValue.serverTimestamp(),
                                  'userID': _firestore.collection('users').doc(currentUser.uid),
                                  'likesCount': 0,
                                  'likedBy': <DocumentReference>[],
                                });

                                if (!context.mounted) return;
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Post created successfully!'), backgroundColor: AppColors.primary),
                                );
                              } catch (e) {
                                if (!context.mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
                                );
                              }
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

  void _showCommentsSheet(DocumentSnapshot postDoc) {
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
                        Text('Comments', style: const TextStyle(fontFamily: 'Poppins', fontSize: 18, fontWeight: FontWeight.bold)),
                        IconButton(icon: const Icon(Icons.close, color: AppColors.textMuted), onPressed: () => Navigator.pop(context)),
                      ],
                    ),
                    const Divider(color: AppColors.gray100),
                    Expanded(
                      child: FirestoreStreamBuilder<QuerySnapshot>(
                        stream: postDoc.reference.collection('comments').orderBy('createdAt', descending: true).snapshots(),
                        builder: (querySnapshot) {
                          final comments = querySnapshot.docs;
                          
                          if (comments.isEmpty) {
                            return const Center(
                              child: Text('No comments yet. Be the first!', style: TextStyle(color: AppColors.textMuted)),
                            );
                          }
                          
                          return ListView(
                            physics: const BouncingScrollPhysics(),
                            children: comments.map((commentDoc) {
                              final commentData = commentDoc.data() as Map<String, dynamic>;
                              final userRef = commentData['userID'] as DocumentReference?;

                              return FutureBuilder<DocumentSnapshot>(
                                future: userRef?.get(),
                                builder: (context, userSnapshot) {
                                  final userName = userSnapshot.data?['displayName'] ?? 'Unknown User';
                                  final userAvatar = userSnapshot.data?['profileURL'] ?? 'https://i.pravatar.cc/150?img=32';

                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 16),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        CircleAvatar(
                                          backgroundImage: NetworkImage(userAvatar),
                                          radius: 16,
                                        ),
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
                                              children: [
                                                Text(userName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.textMain)),
                                                const SizedBox(height: 4),
                                                Text(commentData['commentMessage'] ?? '', style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }
                              );
                            }).toList(),
                          );
                        },
                        empty: const Center(child: Text('No comments yet', style: TextStyle(color: AppColors.textMuted))),
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
                          onPressed: () async {
                            if (commentController.text.isNotEmpty) {
                              try {
                                final currentUser = AuthService().currentUser;
                                if (currentUser == null) return;

                                await postDoc.reference.collection('comments').add({
                                  'commentMessage': commentController.text,
                                  'createdAt': FieldValue.serverTimestamp(),
                                  'userID': _firestore.collection('users').doc(currentUser.uid),
                                });

                                commentController.clear();
                                setStateSheet(() {});
                              } catch (e) {
                                if (!context.mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
                                );
                              }
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
      body: FirestoreStreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('feedPosts')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (querySnapshot) {
          final posts = querySnapshot.docs;

          return ListView(
            padding: const EdgeInsets.only(top: 16, bottom: 24),
            physics: const BouncingScrollPhysics(),
            children: [
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
              ...posts.map((postDoc) => _buildPostCard(postDoc as DocumentSnapshot<Map<String, dynamic>>)).toList(),
            ],
          );
        },
        empty: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.feed, size: 64, color: AppColors.textMuted),
              const SizedBox(height: 16),
              const Text('No posts yet', style: TextStyle(color: AppColors.textMuted, fontSize: 16)),
              const SizedBox(height: 8),
              const Text('Be the first to share!', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _showCreatePostSheet,
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                child: const Text('Create Post', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inSeconds < 60) {
      return 'just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${dateTime.month}/${dateTime.day}/${dateTime.year}';
    }
  }

  Widget _buildPostCard(DocumentSnapshot<Map<String, dynamic>> postDoc) {
    final postData = postDoc.data() ?? {};
    final userRef = postData['userID'] as DocumentReference?;
    final likedByRefs = (postData['likedBy'] as List<dynamic>?)
            ?.whereType<DocumentReference>()
            .toList() ??
        <DocumentReference>[];
    final likesCount = postData['likesCount'] as int? ?? 0;
    final createdAt = postData['createdAt'] as Timestamp?;
    final currentUser = AuthService().currentUser;
    final currentUserRef = currentUser != null
        ? _firestore.collection('users').doc(currentUser.uid)
        : null;
    final isLiked = currentUserRef != null &&
        likedByRefs.any((ref) => ref.path == currentUserRef.path);

    return Container(
      color: AppColors.surface,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 12),
            child: FutureBuilder<DocumentSnapshot>(
              future: userRef?.get(),
              builder: (context, snapshot) {
                final userData = snapshot.data?.data() as Map<String, dynamic>? ?? {};
                final displayName = userData['displayName'] ?? 'Unknown User';
                final occupation = userData['occupation'] ?? 'Volunteer';
                final profileURL = userData['profileURL'] ?? 'https://i.pravatar.cc/150?img=32';

                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundImage: NetworkImage(profileURL),
                          radius: 20,
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              displayName,
                              style: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                            Text(
                              '$occupation • ${createdAt != null ? _getTimeAgo(createdAt.toDate()) : 'Unknown time'}',
                              style: const TextStyle(color: AppColors.textMuted, fontSize: 10),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const Icon(Icons.more_horiz, color: AppColors.textMuted),
                  ],
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              postData['contentMessage'] ?? '',
              style: const TextStyle(fontSize: 14, height: 1.5, color: AppColors.textMain),
            ),
          ),
          if (postData['imageURL'] != null && (postData['imageURL'] as String).isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Image.network(
                postData['imageURL'],
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          const SizedBox(height: 12),
          const Divider(color: AppColors.gray100, height: 1),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () async {
                    if (currentUserRef == null) return;
                    
                    try {
                      final updatedLikedBy = List<DocumentReference>.from(likedByRefs);
                      
                      if (isLiked) {
                        updatedLikedBy.removeWhere((ref) => ref.path == currentUserRef.path);
                      } else {
                        updatedLikedBy.add(currentUserRef);
                      }

                      await postDoc.reference.update({
                        'likedBy': updatedLikedBy,
                        'likesCount': isLiked ? likesCount - 1 : likesCount + 1,
                      });
                    } catch (e) {
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
                      );
                    }
                  },
                  child: _buildInteractionBtn(
                    isLiked ? Icons.thumb_up_alt : Icons.thumb_up_alt_outlined,
                    '$likesCount',
                    color: isLiked ? AppColors.primary : AppColors.textMuted,
                  ),
                ),
                GestureDetector(
                  onTap: () => _showCommentsSheet(postDoc),
                  child: FirestoreStreamBuilder<QuerySnapshot>(
                    stream: postDoc.reference.collection('comments').snapshots(),
                    builder: (querySnapshot) {
                      return _buildInteractionBtn(
                        Icons.chat_bubble_outline,
                        '${querySnapshot.docs.length}',
                      );
                    },
                    empty: _buildInteractionBtn(Icons.chat_bubble_outline, '0'),
                  ),
                ),
                _buildInteractionBtn(Icons.share_outlined, 'Share'),
              ],
            ),
          ),
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