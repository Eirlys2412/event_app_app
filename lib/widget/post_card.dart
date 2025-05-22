import 'package:flutter/material.dart';
import '../models/post.dart';
import '../models/user.dart';

class PostCard extends StatelessWidget {
  final Post post;
  final VoidCallback onLike;
  final VoidCallback onComment;
  final VoidCallback onShare;
  final VoidCallback onProfileTap;
  final User? currentUser;

  const PostCard({
    Key? key,
    required this.post,
    required this.onLike,
    required this.onComment,
    required this.onShare,
    required this.onProfileTap,
    this.currentUser,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool hasLiked = currentUser != null &&
        post.likedUsers.contains(currentUser!.id.toString());

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: onProfileTap,
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundImage: NetworkImage(post.user.photo),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.user.full_name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        _getTimeAgo(post.timestamp),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(post.content),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.thumb_up,
                  size: 16,
                  color: Colors.blue[400],
                ),
                const SizedBox(width: 4),
                Text(
                  '${post.likes}',
                  style: TextStyle(
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(width: 16),
                Icon(
                  Icons.chat_bubble_outline,
                  size: 16,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 4),
                Text(
                  '${post.comments}',
                  style: TextStyle(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                TextButton.icon(
                  onPressed: onLike,
                  icon: Icon(
                    hasLiked ? Icons.thumb_up : Icons.thumb_up_outlined,
                    color: hasLiked ? Colors.blue : Colors.grey[600],
                  ),
                  label: Text(
                    'Thích',
                    style: TextStyle(
                      color: hasLiked ? Colors.blue : Colors.grey[600],
                    ),
                  ),
                ),
                TextButton.icon(
                  onPressed: onComment,
                  icon: Icon(
                    Icons.chat_bubble_outline,
                    color: Colors.grey[600],
                  ),
                  label: Text(
                    'Bình luận',
                    style: TextStyle(
                      color: Colors.grey[600],
                    ),
                  ),
                ),
                TextButton.icon(
                  onPressed: onShare,
                  icon: Icon(
                    Icons.share,
                    color: Colors.grey[600],
                  ),
                  label: Text(
                    'Chia sẻ',
                    style: TextStyle(
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getTimeAgo(DateTime dateTime) {
    final difference = DateTime.now().difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays} ngày trước';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} giờ trước';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} phút trước';
    } else {
      return 'Vừa xong';
    }
  }
}
