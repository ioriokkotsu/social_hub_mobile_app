import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:social_hub/services/auth_service.dart';
import 'package:social_hub/services/future_builder.dart';
import 'package:social_hub/services/upload_cloudinary.dart';
import 'package:social_hub/services/stream_builder.dart';
import 'package:social_hub/theme/theme.dart';

class FeedPage extends StatefulWidget {
  const FeedPage({super.key});

  @override
  State<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  var currentProfileURL = 'https://i.pravatar.cc/150?img=32';

  void _showCreatePostSheet() {
    final TextEditingController postController = TextEditingController();
    String? selectedImagePath;
    bool isPosting = false;
    bool isUploadingImage = false;

    Future<void> pickAndPreviewImage(StateSetter setStateSheet) async {
      final image = await pickImage();
      if (image == null) return;

      setStateSheet(() {
        selectedImagePath = image.path;
      });
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateSheet) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Container(
                decoration: const BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(32),
                    topRight: Radius.circular(32),
                  ),
                ),
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Create Feed Post',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.close,
                            color: AppColors.textMuted,
                          ),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FirestoreFutureBuilder(
                          width: 40,
                          height: 40,
                          future: _firestore
                              .collection('users')
                              .doc(AuthService().currentUser?.uid)
                              .get(),
                          builder: (user) {
                            currentProfileURL =
                                user['profileURL'] ??
                                'https://i.pravatar.cc/150?img=32';
                            return CircleAvatar(
                              backgroundImage: NetworkImage(currentProfileURL),
                              radius: 20,
                            );
                          },
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: postController,
                            maxLines: 4,
                            decoration: const InputDecoration(
                              hintText: 'What do you want to share?',
                              border: InputBorder.none,
                              hintStyle: TextStyle(
                                color: AppColors.textMuted,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (selectedImagePath != null)
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 12),
                        height: 150,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        clipBehavior: Clip.hardEdge,
                        child: Stack(
                          children: [
                            Image.file(
                              File(selectedImagePath!),
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                            ),
                            Align(
                              alignment: Alignment.topRight,
                              child: IconButton(
                                icon: const Icon(
                                  Icons.cancel,
                                  color: Colors.white,
                                ),
                                onPressed: () => setStateSheet(() {
                                  selectedImagePath = null;
                                }),
                              ),
                            ),
                          ],
                        ),
                      ),
                    const Divider(color: AppColors.gray100),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton.icon(
                          onPressed: () => pickAndPreviewImage(setStateSheet),
                          icon: const Icon(
                            Icons.image_outlined,
                            color: AppColors.primary,
                          ),
                          label: const Text(
                            'Add Image',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: isPosting
                              ? null
                              : () async {
                                  if (postController.text.isNotEmpty ||
                                      selectedImagePath != null) {
                                    try {
                                      final currentUser =
                                          AuthService().currentUser;
                                      if (currentUser == null) return;

                                      setStateSheet(() {
                                        isPosting = true;
                                      });

                                      final postRef = await _firestore
                                          .collection('feedPosts')
                                          .add({
                                            'contentMessage':
                                                postController.text,
                                            'imageURL': null,
                                            'createdAt':
                                                FieldValue.serverTimestamp(),
                                            'userID': _firestore
                                                .collection('users')
                                                .doc(currentUser.uid),
                                            'likesCount': 0,
                                            'likedBy': <DocumentReference>[],
                                          });

                                      if (selectedImagePath != null) {
                                        setStateSheet(() {
                                          isUploadingImage = true;
                                        });

                                        final uploadedImageUrl =
                                            await uploadToCloudinary(
                                              selectedImagePath!,
                                            );
                                        if (uploadedImageUrl != null) {
                                          await postRef.update({
                                            'imageURL': uploadedImageUrl,
                                          });
                                        }
                                      }

                                      if (!context.mounted) return;
                                      Navigator.pop(context);
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Post created successfully!',
                                          ),
                                          backgroundColor: AppColors.primary,
                                        ),
                                      );
                                    } catch (e) {
                                      if (!context.mounted) return;
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text('Error: $e'),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    }
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: isPosting
                              ? Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              Colors.white,
                                            ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      isUploadingImage
                                          ? 'Uploading...'
                                          : 'Posting...',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                )
                              : const Text(
                                  'Post',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
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
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Container(
                height: MediaQuery.of(context).size.height * 0.6,
                decoration: const BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(32),
                    topRight: Radius.circular(32),
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Comments',
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.close,
                            color: AppColors.textMuted,
                          ),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const Divider(color: AppColors.gray100),
                    Expanded(
                      child: FirestoreStreamBuilder<QuerySnapshot>(
                        stream: postDoc.reference
                            .collection('comments')
                            .orderBy('createdAt', descending: true)
                            .snapshots(),
                        builder: (querySnapshot) {
                          final comments = querySnapshot.docs;

                          if (comments.isEmpty) {
                            return const Center(
                              child: Text(
                                'No comments yet. Be the first!',
                                style: TextStyle(color: AppColors.textMuted),
                              ),
                            );
                          }

                          return ListView(
                            physics: const BouncingScrollPhysics(),
                            children: comments.map((commentDoc) {
                              final commentData =
                                  commentDoc.data() as Map<String, dynamic>;
                              final userRef =
                                  commentData['userID'] as DocumentReference?;

                              return FutureBuilder<DocumentSnapshot>(
                                future: userRef?.get(),
                                builder: (context, userSnapshot) {
                                  final userName =
                                      userSnapshot.data?['displayName'] ??
                                      'Unknown User';
                                  final userAvatar =
                                      userSnapshot.data?['profileURL'] ??
                                      'https://i.pravatar.cc/150?img=32';

                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 16),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        CircleAvatar(
                                          backgroundImage: NetworkImage(
                                            userAvatar,
                                          ),
                                          radius: 16,
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Container(
                                            padding: const EdgeInsets.all(12),
                                            decoration: BoxDecoration(
                                              color: AppColors.appBg,
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                            ),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  userName,
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 12,
                                                    color: AppColors.textMain,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  commentData['commentMessage'] ??
                                                      '',
                                                  style: const TextStyle(
                                                    fontSize: 12,
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
                                },
                              );
                            }).toList(),
                          );
                        },
                        empty: const Center(
                          child: Text(
                            'No comments yet',
                            style: TextStyle(color: AppColors.textMuted),
                          ),
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        const CircleAvatar(
                          backgroundImage: NetworkImage(
                            'https://i.pravatar.cc/150?img=32',
                          ),
                          radius: 18,
                        ),
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
                                hintStyle: TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textMuted,
                                ),
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(
                            Icons.send,
                            color: AppColors.primary,
                          ),
                          onPressed: () async {
                            if (commentController.text.isNotEmpty) {
                              try {
                                final currentUser = AuthService().currentUser;
                                if (currentUser == null) return;

                                await postDoc.reference
                                    .collection('comments')
                                    .add({
                                      'commentMessage': commentController.text,
                                      'createdAt': FieldValue.serverTimestamp(),
                                      'userID': _firestore
                                          .collection('users')
                                          .doc(currentUser.uid),
                                    });

                                commentController.clear();
                                setStateSheet(() {});
                              } catch (e) {
                                if (!context.mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Error: $e'),
                                    backgroundColor: Colors.red,
                                  ),
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
          },
        );
      },
    );
  }

  Future<void> _deletePost(DocumentReference postRef) async {
    final commentsSnapshot = await postRef.collection('comments').get();

    for (final commentDoc in commentsSnapshot.docs) {
      await commentDoc.reference.delete();
    }

    await postRef.delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.appBg,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'Community Feed',
          style: TextStyle(
            fontFamily: 'Poppins',
            color: AppColors.textMain,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(32),
            bottomRight: Radius.circular(32),
          ),
        ),
      ),
      body: FirestoreStreamBuilder<QuerySnapshot>(
        loading: const Center(child: CircularProgressIndicator()),
        stream: _firestore.collection('feedPosts').snapshots(),
        builder: (querySnapshot) {
          final posts = querySnapshot.docs.toList()
            ..sort((a, b) {
              final aData = a.data() as Map<String, dynamic>? ?? {};
              final bData = b.data() as Map<String, dynamic>? ?? {};

              final aTimestamp = aData['createdAt'] as Timestamp?;
              final bTimestamp = bData['createdAt'] as Timestamp?;

              final aDateTime =
                  aTimestamp?.toDate() ??
                  DateTime.fromMillisecondsSinceEpoch(0);
              final bDateTime =
                  bTimestamp?.toDate() ??
                  DateTime.fromMillisecondsSinceEpoch(0);

              return bDateTime.compareTo(aDateTime);
            });

          return ListView(
            padding: EdgeInsets.only(
              top: 16,
              bottom:
                  MediaQuery.of(context).padding.bottom +
                  kBottomNavigationBarHeight +
                  12,
              left: 16,
              right: 16,
            ),
            physics: const BouncingScrollPhysics(),
            children: [
              GestureDetector(
                onTap: _showCreatePostSheet,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: softShadow,
                    color: AppColors.surface,
                  ),
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Row(
                    children: [
                      FirestoreFutureBuilder(
                        width: 40,
                        height: 40,
                        future: _firestore
                            .collection('users')
                            .doc(AuthService().currentUser?.uid)
                            .get(),
                        builder: (user) {
                          currentProfileURL =
                              user['profileURL'] ??
                              'https://i.pravatar.cc/150?img=32';
                          return CircleAvatar(
                            backgroundImage: NetworkImage(user['profileURL']),
                            radius: 20,
                          );
                        },
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 16,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.appBg,
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: const Text(
                            'Share an update or milestone...',
                            style: TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Icon(
                        Icons.image_outlined,
                        color: AppColors.primary,
                      ),
                    ],
                  ),
                ),
              ),
              ...posts.map(
                (postDoc) => _buildPostCard(
                  postDoc as DocumentSnapshot<Map<String, dynamic>>,
                ),
              ),
            ],
          );
        },
        empty: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.feed, size: 64, color: AppColors.textMuted),
              const SizedBox(height: 16),
              const Text(
                'No posts yet',
                style: TextStyle(color: AppColors.textMuted, fontSize: 16),
              ),
              const SizedBox(height: 8),
              const Text(
                'Be the first to share!',
                style: TextStyle(color: AppColors.textMuted, fontSize: 12),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _showCreatePostSheet,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                ),
                child: const Text(
                  'Create Post',
                  style: TextStyle(color: Colors.white),
                ),
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
    final likedByRefs =
        (postData['likedBy'] as List<dynamic>?)
            ?.whereType<DocumentReference>()
            .toList() ??
        <DocumentReference>[];
    final likesCount = postData['likesCount'] as int? ?? 0;
    final createdAt = postData['createdAt'] as Timestamp?;
    final currentUser = AuthService().currentUser;
    final currentUserRef = currentUser != null
        ? _firestore.collection('users').doc(currentUser.uid)
        : null;
    final isLiked =
        currentUserRef != null &&
        likedByRefs.any((ref) => ref.path == currentUserRef.path);
    final isOwner =
        currentUserRef != null &&
        userRef != null &&
        userRef.path == currentUserRef.path;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: softShadow,
        color: AppColors.surface,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 12),
            child: FutureBuilder<DocumentSnapshot>(
              future: userRef?.get(),
              builder: (context, snapshot) {
                final userData =
                    snapshot.data?.data() as Map<String, dynamic>? ?? {};
                final displayName = userData['displayName'] ?? 'Unknown User';
                final occupation = userData['occupation'] ?? 'Volunteer';
                final profileURL =
                    userData['profileURL'] ??
                    'https://i.pravatar.cc/150?img=32';

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
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              '$occupation • ${createdAt != null ? _getTimeAgo(createdAt.toDate()) : 'Unknown time'}',
                              style: const TextStyle(
                                color: AppColors.textMuted,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    PopupMenuButton<String>(
                      icon: const Icon(
                        Icons.more_horiz,
                        color: AppColors.textMuted,
                      ),
                      onSelected: (value) async {
                        if (value == 'copy') {
                          final contentMessage =
                              postData['contentMessage'] ?? '';
                          final imageLink = postData['imageURL'] as String?;
                          final shareText =
                              imageLink == null || imageLink.isEmpty
                              ? contentMessage
                              : '$contentMessage\n\n$imageLink';

                          await Clipboard.setData(
                            ClipboardData(text: shareText),
                          );

                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Post copied to clipboard.'),
                              backgroundColor: AppColors.primary,
                            ),
                          );
                        }

                        if (value == 'delete') {
                          final confirmed = await showDialog<bool>(
                            context: context,
                            builder: (dialogContext) {
                              return AlertDialog(
                                title: const Text('Delete Post'),
                                content: const Text(
                                  'Are you sure you want to delete this post?',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(dialogContext, false),
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(dialogContext, true),
                                    child: const Text('Delete'),
                                  ),
                                ],
                              );
                            },
                          );

                          if (confirmed != true) return;

                          try {
                            await _deletePost(postDoc.reference);
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Post deleted successfully.'),
                                backgroundColor: AppColors.primary,
                              ),
                            );
                          } catch (e) {
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Error deleting post: $e'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem<String>(
                          value: 'copy',
                          child: Text('Copy text'),
                        ),
                        if (isOwner)
                          const PopupMenuItem<String>(
                            value: 'delete',
                            child: Text('Delete'),
                          ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              postData['contentMessage'] ?? '',
              style: const TextStyle(
                fontSize: 14,
                height: 1.5,
                color: AppColors.textMain,
              ),
            ),
          ),
          if (postData['imageURL'] != null &&
              (postData['imageURL'] as String).isNotEmpty)
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
                      final updatedLikedBy = List<DocumentReference>.from(
                        likedByRefs,
                      );

                      if (isLiked) {
                        updatedLikedBy.removeWhere(
                          (ref) => ref.path == currentUserRef.path,
                        );
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
                        SnackBar(
                          content: Text('Error: $e'),
                          backgroundColor: Colors.red,
                        ),
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
                    width: 18,
                    height: 18,
                    radius: 1,
                    stream: postDoc.reference
                        .collection('comments')
                        .snapshots(),
                    builder: (querySnapshot) {
                      return _buildInteractionBtn(
                        Icons.chat_bubble_outline,
                        '${querySnapshot.docs.length}',
                      );
                    },
                    empty: _buildInteractionBtn(Icons.chat_bubble_outline, '0'),
                  ),
                ),
                GestureDetector(
                  onTap: () async {
                    final contentMessage = postData['contentMessage'] ?? '';
                    final imageLink = postData['imageURL'] as String?;
                    final shareText = imageLink == null || imageLink.isEmpty
                        ? contentMessage
                        : '$contentMessage\n\n$imageLink';

                    await Clipboard.setData(ClipboardData(text: shareText));

                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Post copied to clipboard.'),
                        backgroundColor: AppColors.primary,
                      ),
                    );
                  },
                  child: _buildInteractionBtn(Icons.share_outlined, 'Share'),
                ),
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
