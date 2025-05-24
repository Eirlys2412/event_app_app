import 'package:event_app/screen/blog_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/comment.dart';
import '../providers/comment_provider.dart';
import '../providers/like_provider.dart';

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

  String _formatDateTime(String dateTimeStr) {
    try {
      final dateTime = DateTime.parse(dateTimeStr);
      return '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateTimeStr;
    }
  }

  // Thêm provider key
  late final _providerKey = {'itemId': widget.blogId, 'itemCode': 'blog'};

  @override
  void initState() {
    super.initState();
    // Load comments khi component mount
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return; // Kiểm tra mounted trước khi sử dụng ref
      final notifier =
          ref.read(blogCommentListProvider(widget.blogId).notifier);
      notifier.loadComments();
      notifier.startAutoRefresh();
      notifier.loadComments();
      notifier.startAutoRefresh();
    });
  }

  @override
  void dispose() {
    // if (mounted) {
    //   ref.read(commentListProvider(_providerKey).notifier).cancelAutoRefresh();
    // }
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final commentState = ref.watch(blogCommentListProvider(widget.blogId));
    final notifier = ref.read(blogCommentListProvider(widget.blogId).notifier);

    return Scaffold(
      appBar: AppBar(
        title: Text('Bình luận: ${widget.blogTitle}'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Column(
        children: [
          Expanded(
            child: commentState.error != null
                ? Center(child: Text('Lỗi: ${commentState.error}'))
                : commentState.comments.isEmpty
                    ? const Center(child: Text('Chưa có bình luận nào'))
                    : ListView.builder(
                        padding: const EdgeInsets.all(8),
                        itemCount: commentState.comments.length,
                        itemBuilder: (context, index) {
                          return _buildCommentItem(
                              commentState.comments[index], notifier);
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
                          await notifier.updateComment(
                            id: _editingComment!.id,
                            content: _commentController.text.trim(),
                          );
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
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundImage: NetworkImage(
                   getAvatarUrl(avatar)',
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        comment.user.full_name,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        _formatDateTime(comment.createdAt),
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
            const SizedBox(height: 8),
            Text(comment.content),
            const SizedBox(height: 8),
            Row(
              children: [
                TextButton.icon(
                  onPressed: () {
                    ref
                        .read(likeStateProvider(
                            {'type': 'comment', 'id': comment.id}).notifier)
                        .toggle();
                  },
                  icon: Icon(
                    comment.is_liked ? Icons.thumb_up : Icons.thumb_up_outlined,
                    size: 16,
                    color: comment.is_liked
                        ? const Color.fromARGB(255, 93, 0, 255)
                        : Colors.grey[600],
                  ),
                  label: Text(
                    'Like (${comment.likes_count})',
                    style: TextStyle(
                      fontSize: 12,
                      color: comment.is_liked
                          ? Colors.deepPurple
                          : Colors.grey[600],
                    ),
                  ),
                ),
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      _replyingTo = comment;
                      _commentController.clear();
                    });
                  },
                  icon: const Icon(Icons.reply, size: 16),
                  label: const Text('Trả lời'),
                ),
                if (comment.replies.isNotEmpty)
                  TextButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.comment, size: 16),
                    label: Text('${comment.replies.length} trả lời'),
                  ),
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
}
