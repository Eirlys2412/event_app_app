import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/comment.dart';
import '../providers/comment_provider.dart';

class BlogCommentScreen extends ConsumerStatefulWidget {
  final int blogId;
  final String blogTitle;

  const BlogCommentScreen(
      {Key? key, required this.blogId, required this.blogTitle})
      : super(key: key);

  @override
  ConsumerState<BlogCommentScreen> createState() => _BlogCommentScreenState();
}

class _BlogCommentScreenState extends ConsumerState<BlogCommentScreen> {
  final TextEditingController _commentController = TextEditingController();
  Comment? _replyingTo;
  Comment? _editingComment;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    Future.microtask(() {
      ref
          .read(
              commentListProvider({'itemId': widget.blogId, 'itemCode': 'blog'})
                  .notifier)
          .loadComments();
    });
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  String getFullPhotoUrl(String? url) {
    if (url == null || url.isEmpty || url == 'null') {
      return 'http://10.0.2.2:8000/storage/uploads/resources/default.png';
    }

    String processedUrl = url;

    if (processedUrl.startsWith('http')) {
      processedUrl =
          processedUrl.replaceFirst('/storage/storage/', '/storage/');
      processedUrl = processedUrl.replaceFirst('127.0.0.1', '10.0.2.2');
      return processedUrl;
    }

    if (processedUrl.startsWith('storage/')) {
      return 'http://10.0.2.2:8000/' + processedUrl;
    }

    return 'http://10.0.2.2:8000/storage/uploads/resources/' + processedUrl;
  }

  @override
  Widget build(BuildContext context) {
    final comments = ref.watch(
        commentListProvider({'itemId': widget.blogId, 'itemCode': 'blog'}));
    final notifier = ref.read(
        commentListProvider({'itemId': widget.blogId, 'itemCode': 'blog'})
            .notifier);

    return Scaffold(
      appBar: AppBar(
        title: Text('Bình luận: ${widget.blogTitle}'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Column(
        children: [
          Expanded(
            child: comments.isEmpty
                ? const Center(child: Text('Chưa có bình luận nào'))
                : ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: comments.length,
                    itemBuilder: (context, index) {
                      return _buildCommentItem(comments[index], notifier);
                    },
                  ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: const Offset(0, -1),
                ),
              ],
            ),
            child: Column(
              children: [
                if (_replyingTo != null)
                  Container(
                    padding: const EdgeInsets.all(8),
                    color: Colors.grey[100],
                    child: Row(
                      children: [
                        Text('Đang trả lời ${_replyingTo!.user.full_name}'),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () {
                            setState(() {
                              _replyingTo = null;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                if (_editingComment != null)
                  Container(
                    padding: const EdgeInsets.all(8),
                    color: Colors.blue[50],
                    child: Row(
                      children: [
                        const Text('Đang chỉnh sửa bình luận'),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () {
                            setState(() {
                              _editingComment = null;
                              _commentController.clear();
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _commentController,
                        decoration: InputDecoration(
                          hintText: _editingComment != null
                              ? 'Chỉnh sửa bình luận...'
                              : 'Viết bình luận...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        maxLines: null,
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () async {
                        if (_commentController.text.trim().isEmpty) return;
                        if (_editingComment != null) {
                          // Nếu muốn hỗ trợ update comment, thêm hàm update vào provider
                        } else {
                          await notifier.addComment(
                            content: _commentController.text.trim(),
                            parentId: _replyingTo?.id,
                          );
                        }
                        setState(() {
                          _commentController.clear();
                          _replyingTo = null;
                          _editingComment = null;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        shape: const CircleBorder(),
                        padding: const EdgeInsets.all(12),
                      ),
                      child: const Icon(Icons.send, color: Colors.white),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentItem(Comment comment, CommentListNotifier notifier) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundImage: NetworkImage(
                    getFullPhotoUrl(comment.user.photo!),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        comment.user.full_name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        _getTimeAgo(DateTime.parse(comment.createdAt)),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) async {
                    switch (value) {
                      case 'edit':
                        setState(() {
                          _editingComment = comment;
                          _commentController.text = comment.content;
                        });
                        break;
                      case 'delete':
                        await notifier.deleteComment(comment.id);
                        break;
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Text('Chỉnh sửa'),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Text('Xóa'),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                comment.content,
                style: const TextStyle(fontSize: 15),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      _replyingTo = comment;
                      _commentController.clear();
                    });
                  },
                  icon: const Icon(Icons.reply, size: 16),
                  label: const Text('Trả lời'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.deepPurple,
                  ),
                ),
                if (comment.replies.isNotEmpty) ...[
                  const SizedBox(width: 16),
                  TextButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.comment, size: 16),
                    label: Text('${comment.replies.length} trả lời'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.deepPurple,
                    ),
                  ),
                ],
              ],
            ),
            if (comment.replies.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: Column(
                  children: comment.replies
                      .map((c) => _buildCommentItem(c, notifier))
                      .toList(),
                ),
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
