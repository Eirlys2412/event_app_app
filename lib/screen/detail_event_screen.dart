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
import '../providers/like_provider.dart';
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
import '../providers/detail_event_provider.dart';

class EventDetailScreen extends ConsumerStatefulWidget {
  final int eventId;

  const EventDetailScreen({Key? key, required this.eventId}) : super(key: key);

  @override
  ConsumerState<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends ConsumerState<EventDetailScreen> {
  VideoPlayerController? _videoController;
  YoutubePlayerController? _youtubeController;
  bool showGallery = false;

  String _formatDateTime(String dateTimeStr) {
    try {
      final dateTime = DateTime.parse(dateTimeStr);
      return '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateTimeStr;
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    _youtubeController?.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    Future.microtask(() {
      print('Fetching detail for eventId: ${widget.eventId}');
      ref.read(detailEventProvider(widget.eventId));
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeState = ref.watch(themeProvider);
    final eventDataAsyncValue = ref.watch(detailEventProvider(widget.eventId));

    return Scaffold(
      appBar: AppBar(
        title: Text(
          eventDataAsyncValue.when(
            data: (event) => event.title ?? 'Chi tiết sự kiện',
            loading: () => 'Đang tải...',
            error: (err, stack) => 'Lỗi tải sự kiện',
          ),
        ),
        backgroundColor: themeState.appBarColor,
        foregroundColor: themeState.appBarTextColor,
      ),
      body: eventDataAsyncValue.when(
        data: (eventData) {
          print('Building EventDetailScreen with eventData: $eventData');
          if (eventData == null) {
            return const Center(child: Text('Không tìm thấy sự kiện'));
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (eventData.resourcesData != null &&
                  eventData.resourcesData!.isNotEmpty)
                MediaViewer(
                  resources: eventData.resourcesData!,
                  height: 200,
                  width: double.infinity,
                  borderRadius: 12,
                  fit: BoxFit.cover,
                ),
              const SizedBox(height: 16),
              _buildEventInfo(themeState, Theme.of(context), eventData),
              const SizedBox(height: 16),
              _buildActions(context, ref, themeState, eventData),
              const SizedBox(height: 24),
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
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: EventGallery(
                    eventId: eventData.id,
                    resources: eventData.resourcesData,
                  ),
                ),
              const SizedBox(height: 24),
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
                final double initialRating = eventData.averageRating ?? 0.0;
                final int initialVotes = eventData.totalVotes ?? 0;
                final int eventId = eventData.id;

                final voteStats = ref.watch(voteStateProvider({
                  'type': 'event',
                  'id': eventId,
                  'initialRating': initialRating,
                  'initialVotes': initialVotes,
                }));

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RatingBar.builder(
                      initialRating: voteStats.averageRating,
                      minRating: 1,
                      direction: Axis.horizontal,
                      allowHalfRating: false,
                      itemCount: 5,
                      itemSize: 30,
                      itemPadding: const EdgeInsets.symmetric(horizontal: 2),
                      itemBuilder: (context, _) =>
                          Icon(Icons.star, color: Colors.amber),
                      onRatingUpdate: (rating) async {
                        try {
                          await ref
                              .read(voteStateProvider(
                                  {'type': 'event', 'id': eventId}).notifier)
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
                              SnackBar(content: Text('Lỗi: ${e.toString()}')),
                            );
                          }
                        }
                      },
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Điểm trung bình: ${voteStats.averageRating.toStringAsFixed(1)} ⭐ (${voteStats.totalVotes} lượt đánh giá)',
                      style: TextStyle(
                        color: themeState.primaryTextColor,
                        fontSize: 14,
                      ),
                    ),
                  ],
                );
              }),
              const SizedBox(height: 24),
              EventCommentsSection(
                eventId: eventData.id,
                eventTitle: eventData.title ?? 'Sự kiện',
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Text('Không thể tải chi tiết sự kiện: ${err.toString()}'),
        ),
      ),
    );
  }

  Widget _buildEventInfo(
      ThemeState themeState, ThemeData theme, Detailevent eventData) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          eventData.title ?? 'Chưa có tiêu đề',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: themeState.primaryTextColor,
          ),
        ),
        const SizedBox(height: 12),
        if (eventData.description != null)
          Text(
            eventData.description ?? 'Không có mô tả',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: themeState.bodyTextColor,
            ),
          ),
        if (eventData.summary != null)
          Text(
            eventData.summary ?? 'Không có tóm tắt',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontStyle: FontStyle.italic,
              color: themeState.secondaryTextColor,
            ),
          ),
        const SizedBox(height: 16),
        Row(
          children: [
            Icon(Icons.access_time, color: themeState.primaryTextColor),
            const SizedBox(width: 6),
            Text(
              "${_formatDateTime(eventData.timestart)} → ${_formatDateTime(eventData.timeend)}",
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
                color: themeState.primaryTextColor),
            const SizedBox(width: 6),
            Text(
              eventData.diadiem ?? "Chưa cập nhật",
              style: theme.textTheme.bodyMedium?.copyWith(
                color: themeState.bodyTextColor,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActions(BuildContext context, WidgetRef ref,
      ThemeState themeState, Detailevent eventData) {
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
                      eventId: eventData.id ?? 0,
                      eventTitle: eventData.title ?? '',
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
                      eventId: eventData.id ?? 0,
                      eventTitle: eventData.title ?? '',
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
      ],
    );
  }

  void _showRatingDialog(
      BuildContext context, WidgetRef ref, int eventId, ThemeState themeState) {
    final currentVoteStats = ref.read(voteStateProvider({
      'type': 'event',
      'id': eventId,
      'initialRating': ref
          .read(voteStateProvider({
            'type': 'event',
            'id': eventId,
            'initialRating': 0.0,
            'initialVotes': 0
          }))
          .averageRating,
      'initialVotes': ref
          .read(voteStateProvider({
            'type': 'event',
            'id': eventId,
            'initialRating': 0.0,
            'initialVotes': 0
          }))
          .totalVotes,
    }));

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Đánh giá sự kiện của bạn'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RatingBar.builder(
                initialRating: currentVoteStats.averageRating,
                minRating: 1,
                direction: Axis.horizontal,
                allowHalfRating: false,
                itemCount: 5,
                itemSize: 30,
                itemPadding: const EdgeInsets.symmetric(horizontal: 2),
                itemBuilder: (context, _) => Icon(
                  Icons.star,
                  color: Colors.amber,
                ),
                onRatingUpdate: (rating) async {
                  Navigator.pop(context);
                  try {
                    await ref
                        .read(
                            voteStateProvider({'type': 'event', 'id': eventId})
                                .notifier)
                        .vote(rating.toInt());
                    if (context.mounted) {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text('Thành công!'),
                            content:
                                const Text('Cảm ơn bạn đã đánh giá sự kiện.'),
                            actions: <Widget>[
                              TextButton(
                                child: const Text('Đóng'),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                            ],
                          );
                        },
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Lỗi: ${e.toString()}')),
                      );
                    }
                  }
                },
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Hủy'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
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

  String _formatDateTime(String dateTimeStr) {
    try {
      final dateTime = DateTime.parse(dateTimeStr);
      return '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateTimeStr;
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final notifier =
          ref.read(eventCommentListProvider(widget.eventId).notifier);
      notifier.loadComments();
      notifier.startAutoRefresh();
    });
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

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

  Future<void> _submitComment() async {
    if (_commentController.text.trim().isEmpty) return;

    try {
      if (_editingComment != null) {
        await ref
            .read(eventCommentListProvider(widget.eventId).notifier)
            .updateComment(
              id: _editingComment!.id,
              content: _commentController.text.trim(),
            );
      } else {
        await ref
            .read(eventCommentListProvider(widget.eventId).notifier)
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
          .read(eventCommentListProvider(widget.eventId).notifier)
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
          .read(eventCommentListProvider(widget.eventId).notifier)
          .deleteComment(comment.id);
      await ref
          .read(eventCommentListProvider(widget.eventId).notifier)
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
                        _formatDateTime(
                            comment.createdAt), // Áp dụng hàm format thời gian
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
                  onPressed: () {
                    if (comment.id != null) {
                      ref
                          .read(likeStateProvider(
                              {'type': 'comment', 'id': comment.id}).notifier)
                          .toggle();
                    }
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
    // Use the same provider key
    final commentState = ref.watch(eventCommentListProvider(widget.eventId));
    final List<Comment> commentTree = _buildCommentTree(commentState.comments);
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
          height: 300,
          child:
              // commentState.isLoading
              //     ? const Center(child: CircularProgressIndicator())
              //     :
              commentState.error != null
                  ? Center(child: Text('Lỗi: ${commentState.error}'))
                  : commentState.comments.isEmpty
                      ? const Center(child: Text('Chưa có bình luận nào'))
                      : ListView.builder(
                          padding: const EdgeInsets.all(8),
                          itemCount: commentTree.length,
                          itemBuilder: (context, index) {
                            return _buildCommentItem(commentTree[index]);
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
    _updateEventImages(widget.resources);
  }

  @override
  void didUpdateWidget(covariant EventGallery oldWidget) {
    super.didUpdateWidget(oldWidget);
    _updateEventImages(widget.resources);
  }

  void _updateEventImages(List<dynamic>? resources) {
    if (resources != null) {
      _eventImages = List<Map<String, dynamic>>.from(
          resources.where((item) => item is Map<String, dynamic>));
    } else {
      _eventImages = [];
    }
  }

  String _formatDateTime(String dateTimeStr) {
    try {
      final dateTime = DateTime.parse(dateTimeStr);
      return '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateTimeStr;
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
              throw Exception(
                  'Phản hồi thành công nhưng dữ liệu ảnh không đúng định dạng.');
            }
          } catch (e) {
            throw Exception(
                'Lỗi xử lý dữ liệu phản hồi từ server: ${e.toString()}');
          }
        } else {
          String errorMessage =
              'Lỗi khi đăng ảnh (Status: ${response.statusCode})';
          try {
            var jsonResponse = json.decode(responseData);
            if (jsonResponse != null && jsonResponse['message'] != null) {
              errorMessage = jsonResponse['message'];
            } else {
              errorMessage =
                  'Lỗi server không có thông báo cụ thể. Phản hồi: $responseData';
            }
          } catch (e) {
            errorMessage =
                'Lỗi server hoặc hết phiên đăng nhập. Phản hồi: $responseData';
          }
          throw Exception(errorMessage);
        }
      }
    } catch (e) {
      print('Error during image upload process: $e');
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
                if (_eventImages[index] == null ||
                    !(_eventImages[index] is Map)) {
                  return Container(
                    width: 150,
                    height: 200,
                    color: Colors.grey[200],
                    child: const Icon(Icons.error_outline, color: Colors.grey),
                  );
                }

                final image = _eventImages[index];

                if (image['url'] == null ||
                    !(image['url'] as String).startsWith('http')) {
                  return Container(
                    width: 150,
                    height: 200,
                    color: Colors.grey[200],
                    child: const Icon(Icons.broken_image),
                  );
                }

                final String imageUrl = getFullPhotoUrl(image['url']);

                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Stack(
                    children: [
                      GestureDetector(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) => Dialog(
                              child: CachedNetworkImage(
                                imageUrl: imageUrl,
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
                            imageUrl: imageUrl,
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
                      Positioned(
                        bottom: 4,
                        left: 4,
                        child: GestureDetector(
                          onTap: () async {
                            final resourceId = image['id'];
                            if (resourceId == null) return;

                            try {
                              final token = await PrefData.getToken();
                              final response = await http.post(
                                Uri.parse(api_like_image(resourceId)),
                                headers: {
                                  'Authorization': 'Bearer $token',
                                  'Content-Type': 'application/json',
                                },
                              );

                              if (response.statusCode >= 200 &&
                                  response.statusCode < 300) {
                                final responseData = json.decode(response.body);
                                print('Like Image API Success: $responseData');
                                setState(() {
                                  final index = _eventImages.indexWhere(
                                      (img) => img['id'] == resourceId);
                                  if (index != -1) {
                                    _eventImages[index]['is_liked'] =
                                        responseData['data']['is_liked'] ??
                                            false;
                                    _eventImages[index]['total_likes'] =
                                        responseData['data']['total_likes'] ??
                                            0;
                                  }
                                });
                              } else {
                                print(
                                    'Like Image API Error: ${response.statusCode}');
                                print(
                                    'Like Image API Error Body: ${response.body}');
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text(
                                            'Lỗi khi thích ảnh: ${response.statusCode}')),
                                  );
                                }
                              }
                            } catch (e) {
                              print('Error toggling like: $e');
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text('Lỗi: ${e.toString()}')),
                                );
                              }
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  (image['is_liked'] ?? false)
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  color: (image['is_liked'] ?? false)
                                      ? Colors.red
                                      : Colors.white,
                                  size: 20,
                                ),
                                if ((image['total_likes'] ?? 0) > 0)
                                  Padding(
                                    padding: const EdgeInsets.only(left: 4.0),
                                    child: Text(
                                      '${image['total_likes']}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: PopupMenuButton<String>(
                          onSelected: (value) async {
                            if (value == 'delete') {
                              await _deleteImage(image['id']);
                            }
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'delete',
                              child: Text('Xóa ảnh'),
                            ),
                          ],
                          icon: const Icon(Icons.more_vert,
                              color: Colors.white, size: 20),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  Future<void> _deleteImage(int imageId) async {
    try {
      final token = await PrefData.getToken();
      final response = await http.delete(
        Uri.parse(api_delete_image(widget.eventId, imageId)),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        setState(() {
          _eventImages.removeWhere((img) => img['id'] == imageId);
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Xóa ảnh thành công')),
          );
        }
      } else {
        throw Exception('Lỗi khi xóa ảnh');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: ${e.toString()}')),
        );
      }
    }
  }
}
