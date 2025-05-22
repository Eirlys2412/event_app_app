import 'package:flutter/material.dart';
import '../models/comment.dart';
import '../models/user.dart';

class CommentItem extends StatelessWidget {
  final Comment comment;
  final Function(Comment) onLike;
  final Function(Comment, String) onReply;
  final VoidCallback onViewReplies;
  final bool showReplies;
  final User? currentUser;

  const CommentItem({
    Key? key,
    required this.comment,
    required this.onLike,
    required this.onReply,
    required this.onViewReplies,
    this.showReplies = false,
    this.currentUser,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool hasLiked = currentUser != null &&
        comment.reactUsers.contains(currentUser!.id.toString());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(comment.user.photo),
              radius: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          comment.user.full_name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(comment.content),
                        if (comment.imageUrl != null &&
                            comment.imageUrl!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                comment.imageUrl!,
                                fit: BoxFit.cover,
                                height: 150,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Row(
                      children: [
                        TextButton(
                          onPressed: () => onLike(comment),
                          child: Text(
                            'Thích ${comment.is_liked ? "(${comment.likes_count})" : ""}',
                            style: TextStyle(
                              fontSize: 12,
                              color: hasLiked
                                  ? Colors.deepPurple
                                  : Colors.grey[700],
                              fontWeight: hasLiked
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () => _showReplyDialog(context),
                          child: Text(
                            'Phản hồi',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[700],
                            ),
                          ),
                        ),
                        Text(
                          '${_getTimeAgo(DateTime.parse(comment.createdAt))}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        // Hiển thị phản hồi nếu có
        if (comment.replies.isNotEmpty && showReplies)
          Padding(
            padding: const EdgeInsets.only(left: 48),
            child: Column(
              children: comment.replies.map((reply) {
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: CommentItem(
                    comment: reply,
                    onLike: onLike,
                    onReply: onReply,
                    onViewReplies: () {}, // Không cần xem thêm phản hồi
                    showReplies: false, // Không hiển thị phản hồi của phản hồi
                    currentUser: currentUser, // Truyền người dùng hiện tại
                  ),
                );
              }).toList(),
            ),
          ),
        if (comment.replies.isNotEmpty && !showReplies)
          Padding(
            padding: const EdgeInsets.only(left: 48, top: 4),
            child: TextButton(
              onPressed: onViewReplies,
              child: Text('Xem ${comment.replies.length} phản hồi'),
            ),
          ),
        const SizedBox(height: 8),
      ],
    );
  }

  void _showReplyDialog(BuildContext context) {
    final TextEditingController replyController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Phản hồi cho ${comment.user.full_name}'),
          content: TextField(
            controller: replyController,
            decoration: const InputDecoration(
              hintText: 'Nhập phản hồi của bạn...',
            ),
            maxLines: 3,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () {
                if (replyController.text.isNotEmpty) {
                  onReply(comment, replyController.text);
                  Navigator.pop(context);
                }
              },
              child: const Text('Gửi'),
            ),
          ],
        );
      },
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

extension on Comment {
  get reactUsers => null;

  get imageUrl => null;
}
