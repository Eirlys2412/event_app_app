import 'package:event_app/providers/like_provider.dart';
import 'package:event_app/screen/CreatePostScreen.dart';
import 'package:event_app/screen/blog_comment_screen.dart';
import 'package:event_app/screen/editposstScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/blog_approved.dart';
import '../providers/blog_provider.dart';
import 'package:intl/intl.dart';
import '../widgets/theme_button.dart';
import '../widgets/theme_selector.dart';
import '../providers/theme_provider.dart';
import '../screen/editposstScreen.dart';
import '../widgets/user_profile.dart';
import '../providers/comment_provider.dart';
import '../models/comment.dart';
import '../providers/blog_detail_provider.dart' hide blogRepositoryProvider;
import 'dart:convert';

String getFullPhotoUrl(String? url) {
  if (url == null || url.isEmpty || url == 'null') {
    // Return a default placeholder or handle as needed
    return 'http://10.0.2.2:8000/storage/uploads/resources/default.png'; // Example default URL
  }

  String processedUrl = url;

  // If url is already a full URL
  if (processedUrl.startsWith('http')) {
    // Fix repeated storage segment if present
    processedUrl = processedUrl.replaceFirst('/storage/storage/', '/storage/');

    // Handle emulator address
    processedUrl = processedUrl.replaceFirst('127.0.0.1', '10.0.2.2');

    return processedUrl;
  }

  // Handle relative paths starting with 'storage/'
  if (processedUrl.startsWith('storage/')) {
    // Use 10.0.2.2 for emulator
    return 'http://10.0.2.2:8000/' + processedUrl; // Correctly prepend base URL
  }

  // For other relative paths or just filenames, assume they are resources
  return 'http://10.0.2.2:8000/storage/uploads/resources/' +
      processedUrl; // Assuming resource paths
}

String getAvatarUrl(String? avatar) {
  if (avatar != null && avatar.isNotEmpty && avatar != 'null') {
    // Use getFullPhotoUrl to handle both full URLs and relative storage paths
    return getFullPhotoUrl(avatar);
  }
  // Return a default avatar URL if the provided avatar is null, empty, or 'null'
  return 'http://10.0.2.2:8000/storage/uploads/resources/default.png'; // Default avatar path
}

class BlogDetailScreen extends ConsumerWidget {
  final BlogApproved blog;

  const BlogDetailScreen({
    Key? key,
    required this.blog,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = Theme.of(context);
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 244, 244, 244),
      appBar: AppBar(
        title: const Text(
          'Chi tiết bài viết',
          style: TextStyle(
            color: Color.fromARGB(221, 1, 0, 0),
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 154, 144, 243),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Header with user info
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: Colors.grey[200],
                backgroundImage: NetworkImage(getAvatarUrl(blog.authorPhoto)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      blog.authorName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      DateFormat('dd/MM/yyyy HH:mm').format(blog.createdAt),
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Main content card
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (blog.photo != null &&
                    blog.photo?.isNotEmpty == true &&
                    blog.photo != 'null')
                  GestureDetector(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) => Dialog(
                          backgroundColor: Colors.black,
                          child: InteractiveViewer(
                            child: Image.network(
                              getFullPhotoUrl(blog.photo),
                              fit: BoxFit.contain,
                              errorBuilder: (_, __, ___) => Container(
                                color: Colors.grey[100],
                                child: const Icon(
                                  Icons.broken_image_outlined,
                                  color: Colors.grey,
                                  size: 40,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(16),
                      ),
                      child: Image.network(
                        getFullPhotoUrl(blog.photo),
                        height: 220,
                        width: double.infinity,
                        fit: BoxFit.contain,
                        alignment: Alignment.center,
                        errorBuilder: (_, __, ___) => Container(
                          height: 220,
                          color: Colors.grey[100],
                          child: const Icon(
                            Icons.broken_image_outlined,
                            color: Colors.grey,
                            size: 40,
                          ),
                        ),
                      ),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        blog.title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        blog.content.replaceAll(RegExp(r'<[^>]*>'), ''),
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[800],
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Interaction buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Consumer(builder: (context, ref, child) {
                final blogRepository = ref.read(blogRepositoryProvider);

                return _buildInteractionButton(
                  icon: blog.is_liked ? Icons.favorite : Icons.favorite_border,
                  label: 'Thích (${blog.countLike})',
                  iconColor: blog.is_liked ? Colors.red : Colors.grey[700],
                  onTap: () async {
                    try {
                      final response =
                          await blogRepository.toggleLikeBlog(blog.id);
                      if (response.statusCode >= 200 &&
                          response.statusCode < 300) {
                        final responseData = json.decode(response.body);
                        // Cập nhật trạng thái like trong provider
                        final bool isNowLiked =
                            responseData['is_liked'] ?? false;
                        final int currentLikesCount =
                            responseData['likes_count'] ?? 0;
                        print(
                            'API response for like/unlike: is_liked=$isNowLiked, likes_count=$currentLikesCount'); // Debug print
                        ref.read(blogDetailProvider.notifier).updateLikeStatus(
                              blog.id,
                              isNowLiked,
                              currentLikesCount,
                            );

                        if (context.mounted) {
                          // Hiển thị thông báo cụ thể hơn
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text(isNowLiked
                                    ? 'Đã thích bài viết!'
                                    : 'Đã bỏ thích bài viết!')),
                          );
                        }
                      } else {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text(
                                    'Lỗi khi thích bài viết: ${response.statusCode}')),
                          );
                        }
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Lỗi: ${e.toString()}')),
                        );
                      }
                    }
                  },
                );
              }),
              _buildInteractionButton(
                icon: Icons.comment_outlined,
                label: 'Bình luận (${blog.countComment})',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BlogCommentScreen(
                        blogId: blog.id,
                        blogTitle: blog.title,
                      ),
                    ),
                  );
                },
                iconColor: Colors.grey[700],
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Tags
          if (blog.tags?.isNotEmpty ?? false)
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: (blog.tags as List)
                  .map((tag) => Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '#$tag',
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 14,
                          ),
                        ),
                      ))
                  .toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildInteractionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? iconColor,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            Icon(icon, size: 20, color: iconColor ?? Colors.grey[700]),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
