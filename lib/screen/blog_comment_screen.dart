import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/comment.dart';
import '../providers/comment_provider.dart';
import '../providers/like_provider.dart';
import '../providers/profile_provider.dart';

class BlogCommentScreen extends ConsumerStatefulWidget {
  final int blogId;
  final String blogTitle;

  const BlogCommentScreen(
      {Key? key, required this.blogId, required this.blogTitle})
      : super(key: key);

  @override
  ConsumerState<BlogCommentScreen> createState() => _BlogCommentScreenState();
}

String getFullPhotoUrl(String? url) {
  // 1. Xử lý trường hợp URL rỗng hoặc null
  if (url == null || url.isEmpty || url == 'null') {
    return 'http://10.0.2.2:8000/storage/uploads/resources/default.png'; // URL mặc định
  }

  String processedUrl = url.trim(); // Loại bỏ khoảng trắng

  // 2. Xử lý trường hợp URL đã đầy đủ (bắt đầu bằng http)
  if (processedUrl.startsWith('http')) {
    // Chuẩn hóa: thay thế các dấu gạch chéo kép (không nằm sau http:) bằng một dấu gạch chéo đơn
    processedUrl = processedUrl.replaceAll(RegExp(r'(?<!:)/{2,}'), '/');

    // Fix repeated storage segment if present (e.g., http://.../storage/storage/...)
    processedUrl = processedUrl.replaceFirst('/storage/storage/', '/storage/');

    // Handle emulator address
    processedUrl = processedUrl.replaceFirst('127.0.0.1', '10.0.2.2');

    return processedUrl; // Trả về URL đã xử lý
  } else {
    // 3. Xử lý đường dẫn tương đối (nếu không bắt đầu bằng http)
    // Loại bỏ dấu gạch chéo ở đầu nếu có
    if (processedUrl.startsWith('/')) {
      processedUrl = processedUrl.substring(1);
    }

    // Chuẩn hóa: thay thế các dấu gạch chéo kép bằng một dấu gạch chéo đơn trong đường dẫn tương đối
    processedUrl = processedUrl.replaceAll(RegExp(r'/{2,}'), '/');

    // 4. Thêm tiền tố URL cơ sở dựa trên loại đường dẫn tương đối
    // Giả định các đường dẫn bắt đầu bằng 'storage/' là tương đối với thư mục storage gốc
    if (processedUrl.startsWith('storage/')) {
      // Sử dụng 10.0.2.2 cho emulator
      return 'http://10.0.2.2:8000/' + processedUrl; // Thêm tiền tố chính xác
    } else {
      // 5. Fallback cho các đường dẫn tương đối khác (ví dụ: resource paths khác)
      // Giả định chúng là resource paths và thêm tiền tố tương ứng.
      return 'http://10.0.2.2:8000/storage/uploads/resources/' + processedUrl;
    }
  }
  // Mặc dù logic trên đã bao phủ, thêm return cuối cùng để làm hài lòng linter nếu cần (thường không cần khi có else cuối cùng)
  // return 'http://10.0.2.2:8000/storage/uploads/resources/default.png'; // Có thể uncomment nếu lỗi vẫn còn
}

class _BlogCommentScreenState extends ConsumerState<BlogCommentScreen> {
  final TextEditingController _commentController = TextEditingController();
  Comment? _replyingTo;
  Comment? _editingComment;

  // Thêm provider key (không cần thiết nếu dùng family provider với id)
  // late final _providerKey = {'itemId': widget.blogId, 'itemCode': 'blog'};

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
      // Xóa bỏ các dòng loadComments() và startAutoRefresh() trùng lặp
    });
  }

  @override
  void dispose() {
    // Dừng auto refresh khi dispose
    ref.read(blogCommentListProvider(widget.blogId).notifier).stopAutoRefresh();
    _commentController.dispose();
    super.dispose();
  }

  // Phương thức để xây dựng cấu trúc bình luận phân cấp từ danh sách phẳng
  List<Comment> _buildCommentTree(List<Comment> flatList) {
    final Map<int, Comment> commentMap = {};
    final List<Comment> rootComments = [];

    // Tạo map từ id đến comment và khởi tạo danh sách replies rỗng cho mỗi comment
    for (var comment in flatList) {
      commentMap[comment.id] =
          comment; // Lưu trữ comment gốc (có thể có replies sau)
      // Đảm bảo replies list được khởi tạo để thêm replies vào sau
      comment.replies
          .clear(); // Xóa replies cũ nếu có (để tránh trùng lặp khi refresh)
    }

    // Xây dựng cây
    for (var comment in flatList) {
      if (comment.parentId == null) {
        // Là bình luận gốc
        rootComments.add(comment);
      } else {
        // Là bình luận trả lời, tìm bình luận cha và thêm vào danh sách replies của cha
        final parent = commentMap[comment.parentId];
        if (parent != null) {
          parent.replies.add(
              comment); // Thêm vào danh sách replies đã có sẵn trong model Comment
        }
        // Nếu parent không tồn tại (lỗi dữ liệu), bỏ qua bình luận này
      }
    }

    // Sắp xếp bình luận gốc theo thời gian tạo (mới nhất lên đầu)
    rootComments.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    // Sắp xếp các replies trong từng bình luận (thường là cũ nhất lên đầu để đọc theo luồng)
    for (var root in rootComments) {
      _sortReplies(root.replies);
    }

    return rootComments;
  }

  // Phương thức đệ quy để sắp xếp replies
  void _sortReplies(List<Comment> replies) {
    replies.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    for (var reply in replies) {
      if (reply.replies.isNotEmpty) {
        _sortReplies(reply.replies);
      }
    }
  }

  Future<void> _deleteComment(Comment comment) async {
    // Lấy ID người dùng hiện tại
    final currentUserProfileState = ref.read(profileProvider);
    final currentUserId = currentUserProfileState.profile?.id;

    // Kiểm tra nếu bình luận không thuộc về người dùng hiện tại
    if (currentUserId == null || comment.user.id != currentUserId) {
      // Hiển thị popup thông báo
      if (mounted) {
        showDialog(
          // Sử dụng showDialog để hiển thị popup
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Không thể xóa'),
              content:
                  const Text('Bạn không thể xóa bình luận của người khác.'),
              actions: <Widget>[
                TextButton(
                  child: const Text('Đóng'),
                  onPressed: () {
                    Navigator.of(context).pop(); // Đóng popup
                  },
                ),
              ],
            );
          },
        );
      }
      return; // Ngừng thực hiện hàm xóa
    }

    // Tiếp tục xóa nếu bình luận là của người dùng hiện tại
    try {
      // Lấy notifier một lần nữa trong hàm async
      final notifier =
          ref.read(blogCommentListProvider(widget.blogId).notifier);
      await notifier.deleteComment(comment.id);
      // Không cần gọi loadComments() ở đây vì deleteComment đã gọi invalidate
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã xóa bình luận')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final commentState = ref.watch(blogCommentListProvider(widget.blogId));
    final notifier = ref.read(blogCommentListProvider(widget.blogId).notifier);

    // Xây dựng cấu trúc cây từ danh sách bình luận phẳng nhận được từ provider
    final List<Comment> commentTree = _buildCommentTree(commentState.comments);

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
                        itemCount: commentTree
                            .length, // Sử dụng kích thước của cây bình luận gốc
                        itemBuilder: (context, index) {
                          return _buildCommentItem(commentTree[index],
                              notifier); // Truyền bình luận gốc từ cây
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
    // Parse the date string
    final DateTime createdAt = DateTime.parse(comment.createdAt);
    // Format the date
    final String formattedDate =
        DateFormat('dd/MM/yyyy HH:mm').format(createdAt);

    // Lấy ID người dùng hiện tại và kiểm tra quyền
    final currentUserProfileState = ref.watch(profileProvider);
    final currentUserId = currentUserProfileState.profile?.id;
    final isMyComment = comment.user.id == currentUserId;

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
                    (comment.user.photo != null &&
                            comment.user.photo!.isNotEmpty &&
                            comment.user.photo !=
                                'null') // Kiểm tra thêm 'null'
                        ? getFullPhotoUrl(comment
                            .user.photo!) // Sử dụng hàm getFullPhotoUrl đã sửa
                        : 'https://ui-avatars.com/api/?name=${comment.user.full_name}', // Avatar mặc định
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
                        formattedDate,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                // PopupMenuButton chỉ hiển thị nếu bình luận là của người dùng hiện tại
                if (isMyComment)
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
                          await _deleteComment(
                              comment); // Gọi hàm xóa đã sửa đổi
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
                        .read(commentLikeStateProvider(comment.id).notifier)
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
                      .map((c) => Container(
                            margin: const EdgeInsets.only(top: 8),
                            decoration: BoxDecoration(
                              border: Border(
                                left: BorderSide(
                                  color: Colors.grey[300]!,
                                  width: 2,
                                ),
                              ),
                            ),
                            child: _buildCommentItem(c, notifier),
                          ))
                      .toList(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// Xóa bỏ định nghĩa trùng lặp của blogCommentListProvider và eventCommentListProvider
// Chúng nên được định nghĩa trong lib/providers/comment_provider.dart

// Provider riêng cho Blog Comments
// final blogCommentListProvider = StateNotifierProvider.family<CommentListNotifier, CommentListState, int>(
//     (ref, blogId) {
//   final repository = ref.watch(commentRepositoryProvider);
//   // Truyền blogId thay vì itemId và itemCode cố định nếu notifier này chỉ dùng cho blog
//   return CommentListNotifier(repository, ref, blogId);
// });

// Provider riêng cho Event Comments (ví dụ, nếu có)
// final eventCommentListProvider = StateNotifierProvider.family<CommentListNotifier, CommentListState, int>(
//     (ref, eventId) {
//   final repository = ref.watch(commentRepositoryProvider);
//   // Truyền repository, ref, và eventId
//   return CommentListNotifier(repository, ref, eventId);
// });
