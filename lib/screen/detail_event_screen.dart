import 'package:event_app/screen/event_register_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:event_app/utils/date_utils.dart';
import 'package:event_app/models/event.dart';
import 'package:event_app/screen/event_list_user_screen.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '../providers/vote_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/comment_provider.dart';
import '../models/comment.dart';
import '../constants/apilist.dart';
import '../constants/pref_data.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:video_player/video_player.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../widgets/media_viewer.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../utils/url_utils.dart';

class EventDetailScreen extends StatefulWidget {
  final Map<String, dynamic> event;
  const EventDetailScreen({Key? key, required this.event}) : super(key: key);

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  VideoPlayerController? _videoController;
  YoutubePlayerController? _youtubeController;
  bool showGallery = false;

  @override
  void dispose() {
    _videoController?.dispose();
    _youtubeController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Consumer(
      builder: (context, ref, _) {
        final themeState = ref.watch(themeProvider);

        return Scaffold(
          appBar: AppBar(
            title: Text(widget.event['title'] ?? 'Chi tiết sự kiện'),
            backgroundColor: themeState.appBarColor,
            foregroundColor: themeState.appBarTextColor,
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              MediaViewer(
                resources: widget.event['resources_data'] as List?,
                height: 200,
                width: double.infinity,
                borderRadius: 12,
                fit: BoxFit.cover,
                aspectRatio: 16 / 9,
              ),
              const SizedBox(height: 24),
              _buildEventInfo(themeState, theme),
              const SizedBox(height: 24),
              _buildActions(context, ref, themeState),
              const Divider(height: 40),
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    showGallery = !showGallery;
                  });
                },
                icon: Icon(Icons.photo_library),
                label: Text(showGallery ? 'Ẩn ảnh sự kiện' : 'Xem ảnh sự kiện'),
              ),
              if (showGallery)
                EventGallery(
                  eventId: widget.event['id'] ?? 0,
                  resources: widget.event['resources_data'] as List?,
                ),
              const SizedBox(height: 24),
              EventCommentsSection(
                eventId: widget.event['id'] ?? 0,
                eventTitle: widget.event['title'] ?? 'Sự kiện',
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEventInfo(ThemeState themeState, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.event['title'] ?? 'Chưa có tiêu đề',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: themeState.primaryTextColor,
          ),
        ),
        const SizedBox(height: 8),
        if (widget.event['summary'] != null)
          Text(
            widget.event['summary']!,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontStyle: FontStyle.italic,
              color: themeState.secondaryTextColor,
            ),
          ),
        const SizedBox(height: 12),
        if (widget.event['description'] != null)
          Text(
            widget.event['description']!,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: themeState.bodyTextColor,
            ),
          ),
        const SizedBox(height: 16),
        Row(
          children: [
            Icon(Icons.access_time,
                size: 20, color: themeState.primaryTextColor),
            const SizedBox(width: 6),
            Text(
              "${formatDate(widget.event['timestart'] as String?)} → ${formatDate(widget.event['timeend'] as String?)}",
              style: theme.textTheme.bodyMedium?.copyWith(
                color: themeState.bodyTextColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(Icons.location_on_outlined,
                size: 20, color: themeState.primaryTextColor),
            const SizedBox(width: 6),
            Text(
              widget.event['diadiem'] ?? "Chưa cập nhật",
              style: theme.textTheme.bodyMedium?.copyWith(
                color: themeState.bodyTextColor,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActions(
      BuildContext context, WidgetRef ref, ThemeState themeState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => EventRegisterScreen(
                      eventId: widget.event['id'],
                      eventTitle: widget.event['title'],
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: themeState.primaryColor,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              icon: const Icon(Icons.event_available),
              label: const Text("Đăng ký tham gia"),
            ),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => EventUserListScreen(
                      eventId: widget.event['id'],
                      eventTitle: widget.event['title'],
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: themeState.accentColor,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              icon: const Icon(Icons.group),
              label: const Text("Xem thành viên"),
            ),
          ],
        ),
        const Divider(height: 30),
        const SizedBox(height: 10),
        Text(
          "Đánh giá sự kiện",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: themeState.primaryTextColor,
          ),
        ),
        const SizedBox(height: 10),
        Consumer(builder: (context, ref, _) {
          final vote = ref.watch(voteStateProvider(
              {'type': 'event', 'id': widget.event['id'] ?? 0}));

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RatingBar.builder(
                initialRating: vote.toDouble(),
                minRating: 1,
                direction: Axis.horizontal,
                allowHalfRating: false,
                itemCount: 5,
                itemSize: 30,
                itemPadding: const EdgeInsets.symmetric(horizontal: 2),
                itemBuilder: (context, _) =>
                    Icon(Icons.star, color: themeState.primaryColor),
                onRatingUpdate: (rating) async {
                  try {
                    await ref
                        .read(voteStateProvider({
                          'type': 'event',
                          'id': widget.event['id'] ?? 0
                        }).notifier)
                        .vote(rating.toInt());
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Cảm ơn bạn đã đánh giá!')),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Lỗi: $e')),
                      );
                    }
                  }
                },
              ),
              const SizedBox(height: 8),
              Text(
                'Điểm trung bình: ${vote.toStringAsFixed(1)} ⭐',
                style: TextStyle(
                  color: themeState.primaryTextColor,
                  fontSize: 14,
                ),
              ),
            ],
          );
        }),
      ],
    );
  }

  Widget _buildCommentSection(ThemeState themeState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Bình luận",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: themeState.primaryTextColor,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "Chưa có bình luận.",
          style: TextStyle(color: themeState.secondaryTextColor),
        ),
      ],
    );
  }
}

class EventCommentsSection extends ConsumerStatefulWidget {
  final int eventId;
  final String eventTitle;

  const EventCommentsSection({
    Key? key,
    required this.eventId,
    required this.eventTitle,
  }) : super(key: key);

  @override
  ConsumerState<EventCommentsSection> createState() =>
      _EventCommentsSectionState();
}

class _EventCommentsSectionState extends ConsumerState<EventCommentsSection> {
  final TextEditingController _commentController = TextEditingController();
  Comment? _replyingTo;
  Comment? _editingComment;

  // Phương thức để xây dựng cấu trúc bình luận phân cấp
  List<Comment> _buildCommentTree(List<Comment> flatList) {
    final Map<int, Comment> commentMap = {};
    final List<Comment> rootComments = [];

    // Tạo map từ id đến comment
    for (var comment in flatList) {
      commentMap[comment.id] = comment;
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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    Future.microtask(() {
      ref
          .read(commentListProvider(
              {'itemId': widget.eventId, 'itemCode': 'event'}).notifier)
          .loadComments();
    });
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submitComment() async {
    if (_commentController.text.trim().isEmpty) return;

    try {
      if (_editingComment != null) {
        await ref
            .read(commentListProvider(
                {'itemId': widget.eventId, 'itemCode': 'event'}).notifier)
            .updateComment(
              id: _editingComment!.id,
              content: _commentController.text.trim(),
            );
      } else {
        await ref
            .read(commentListProvider(
                {'itemId': widget.eventId, 'itemCode': 'event'}).notifier)
            .addComment(
              content: _commentController.text.trim(),
              parentId: _replyingTo?.id,
            );
      }

      _commentController.clear();
      setState(() {
        _replyingTo = null;
        _editingComment = null;
      });

      await ref
          .read(commentListProvider(
              {'itemId': widget.eventId, 'itemCode': 'event'}).notifier)
          .loadComments();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Thao tác thành công')),
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

  Future<void> _deleteComment(Comment comment) async {
    try {
      await ref
          .read(commentListProvider(
              {'itemId': widget.eventId, 'itemCode': 'event'}).notifier)
          .deleteComment(comment.id);
      await ref
          .read(commentListProvider(
              {'itemId': widget.eventId, 'itemCode': 'event'}).notifier)
          .loadComments();
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

  Widget _buildCommentItem(Comment comment) {
    print('Building comment item for id: ${comment.id}'); // Debug line
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
                        comment
                            .createdAt, // Có thể format lại thời gian nếu cần
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                // Placeholder cho nút Like
                TextButton.icon(
                  onPressed: () {/* TODO: Implement Like functionality */},
                  icon: Icon(
                    comment.is_liked ? Icons.thumb_up : Icons.thumb_up_outlined,
                    size: 16,
                    color: comment.is_liked ? Colors.blue : Colors.grey[600],
                  ),
                  label: Text(
                    'Thích ${comment.likes_count > 0 ? '(${comment.likes_count})' : ''}',
                    style: TextStyle(
                      fontSize: 12,
                      color: comment.is_liked ? Colors.blue : Colors.grey[600],
                    ),
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    switch (value) {
                      case 'edit':
                        setState(() {
                          _editingComment = comment;
                          _commentController.text = comment.content;
                        });
                        break;
                      case 'delete':
                        _deleteComment(comment);
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
                      .map((c) => _buildCommentItem(c))
                      .toList(), // Gọi đệ quy
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final commentState = ref.watch(
        commentListProvider({'itemId': widget.eventId, 'itemCode': 'event'}));

    // Xây dựng cây bình luận từ danh sách phẳng
    // final List<Comment> commentTree = _buildCommentTree(commentState);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        const Text(
          'Bình luận sự kiện',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 300, // hoặc MediaQuery nếu muốn co dãn
          child: commentState.isEmpty
              ? const Center(child: Text('Chưa có bình luận nào'))
              : ListView.builder(
                  padding: const EdgeInsets.all(8),
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: commentState.length,
                  itemBuilder: (context, index) {
                    return _buildCommentItem(commentState[index]);
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
                    onPressed: _submitComment,
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
    );
  }
}

class EventGallery extends ConsumerStatefulWidget {
  final int eventId;
  final List<dynamic>? resources;

  const EventGallery({
    Key? key,
    required this.eventId,
    this.resources,
  }) : super(key: key);

  @override
  ConsumerState<EventGallery> createState() => _EventGalleryState();
}

class _EventGalleryState extends ConsumerState<EventGallery> {
  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false;
  List<Map<String, dynamic>> _eventImages = [];

  @override
  void initState() {
    super.initState();
    if (widget.resources != null) {
      _eventImages = List<Map<String, dynamic>>.from(
          widget.resources!.where((item) => item is Map));
    } else {
      _eventImages = [];
    }
  }

  Future<void> _pickAndUploadImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (image != null) {
        setState(() => _isUploading = true);

        var request = http.MultipartRequest(
          'POST',
          Uri.parse(api_upload_image(widget.eventId)),
        );

        final token = await PrefData.getToken();
        request.headers['Authorization'] = 'Bearer $token';

        request.files.add(
          await http.MultipartFile.fromPath(
            'images[]',
            image.path,
          ),
        );

        var response = await request.send();
        var responseData = await response.stream.bytesToString();

        // Log phản hồi đầy đủ để debug, bất kể thành công hay thất bại
        print('Upload Image Response Status: ${response.statusCode}');
        print('Upload Image Response Body: $responseData');

        if (response.statusCode >= 200 && response.statusCode < 300) {
          try {
            var jsonResponse = json.decode(responseData);
            if (jsonResponse != null &&
                jsonResponse['data'] != null &&
                jsonResponse['data']['resources'] is List) {
              setState(() {
                final newResources = List<Map<String, dynamic>>.from(
                    jsonResponse['data']['resources']
                        .where((item) => item is Map));
                _eventImages.addAll(newResources);
              });
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Đăng ảnh thành công')),
                );
              }
            } else {
              // Dữ liệu thành công nhưng cấu trúc sai
              throw Exception(
                  'Phản hồi thành công nhưng dữ liệu ảnh không đúng định dạng.');
            }
          } catch (e) {
            // Lỗi khi parse JSON thành công
            throw Exception(
                'Lỗi xử lý dữ liệu phản hồi từ server: ${e.toString()}');
          }
        } else {
          // Xử lý khi status code là lỗi
          String errorMessage =
              'Lỗi khi đăng ảnh (Status: ${response.statusCode})';
          try {
            // Thử parse response body để lấy message lỗi từ server
            var jsonResponse = json.decode(responseData);
            if (jsonResponse != null && jsonResponse['message'] != null) {
              errorMessage = jsonResponse['message'];
            } else {
              errorMessage =
                  'Lỗi server không có thông báo cụ thể. Phản hồi: $responseData';
            }
          } catch (e) {
            // Không parse được JSON lỗi (có thể là HTML)
            errorMessage =
                'Lỗi server hoặc hết phiên đăng nhập. Phản hồi: $responseData';
          }
          throw Exception(errorMessage);
        }
      }
    } catch (e) {
      // Bắt các lỗi khác (ví dụ: network error, image picking failed)
      print('Error during image upload process: $e'); // Log lỗi chi tiết
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeState = ref.watch(themeProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Hình ảnh sự kiện',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: themeState.primaryTextColor,
                ),
              ),
              ElevatedButton.icon(
                onPressed: _isUploading ? null : _pickAndUploadImage,
                icon: _isUploading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.add_photo_alternate),
                label: Text(_isUploading ? 'Đang tải lên...' : 'Thêm ảnh'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: themeState.primaryColor,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
        if (_eventImages.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Chưa có hình ảnh nào',
                style: TextStyle(
                  color: themeState.secondaryTextColor,
                ),
              ),
            ),
          )
        else
          SizedBox(
            height: 200,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _eventImages.length,
              itemBuilder: (context, index) {
                // Kiểm tra nếu phần tử hiện tại là null hoặc không phải Map
                if (_eventImages[index] == null ||
                    !(_eventImages[index] is Map)) {
                  return Container(
                    // Hoặc SizedBox.shrink() nếu không muốn hiển thị gì
                    width: 150,
                    height: 200,
                    color: Colors.grey[200],
                    child: const Icon(Icons.error_outline, color: Colors.grey),
                  );
                }

                final image = _eventImages[index]; // Bây giờ chắc chắn là Map

                if (image['url'] == null ||
                    !(image['url'] as String).startsWith('http')) {
                  // Handles null or invalid URL for a single item
                  return Container(
                    width: 150,
                    height: 200,
                    color: Colors.grey[200],
                    child: const Icon(Icons.broken_image),
                  );
                }

                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) => Dialog(
                          child: CachedNetworkImage(
                            imageUrl: image['url'],
                            fit: BoxFit.contain,
                            errorWidget: (context, url, error) =>
                                const Icon(Icons.error),
                          ),
                        ),
                      );
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: CachedNetworkImage(
                        imageUrl: image['url'],
                        width: 150,
                        height: 200,
                        fit: BoxFit.cover,
                        errorWidget: (context, url, error) => Container(
                          width: 150,
                          height: 200,
                          color: Colors.grey[200],
                          child: const Icon(Icons.error),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}
