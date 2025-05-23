import 'package:event_app/providers/like_provider.dart';
import 'package:event_app/screen/CreatePostScreen.dart';
import 'package:event_app/screen/editposstScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/blog_approved.dart';
import '../providers/blog_provider.dart';
import 'package:intl/intl.dart';
import '../widget/drawer_custom.dart';
import 'package:readmore/readmore.dart';
import 'package:event_app/screen/blog_detail_screen.dart';
import '../widgets/theme_button.dart';
import '../widgets/theme_selector.dart';
import '../providers/theme_provider.dart';
import '../widgets/user_profile.dart';
import '../screen/blog_comment_screen.dart';
import '../constants/apilist.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import '../providers/user_provider.dart';

class BlogFeedScreen extends ConsumerStatefulWidget {
  const BlogFeedScreen({super.key});

  @override
  ConsumerState<BlogFeedScreen> createState() => _BlogFeedScreenState();
}

String getAvatarUrl(String? avatar) {
  if (avatar != null && avatar.isNotEmpty && avatar != 'null') {
    // Use getFullPhotoUrl to handle both full URLs and relative storage paths
    return getFullPhotoUrl(avatar);
  }
  // Return a default avatar URL if the provided avatar is null, empty, or 'null'
  return 'http://10.0.2.2:8000/storage/uploads/resources/default.png'; // Default avatar path
}

class _BlogFeedScreenState extends ConsumerState<BlogFeedScreen> {
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = false;
  String _error = '';
  List<BlogApproved> _blogs = [];
  Timer? _timer;

  Future<void> _loadBlogs() async {
    try {
      setState(() {
        _isLoading = true;
        _error = '';
      });

      final response = await http.get(Uri.parse(api_getblog));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['blogs'] != null) {
          final blogsData = data['blogs']['data'] as List;
          setState(() {
            _blogs =
                blogsData.map((json) => BlogApproved.fromJson(json)).toList();
            _isLoading = false;
          });
        } else {
          setState(() {
            _error = 'Không có dữ liệu bài viết';
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _error = 'Lỗi kết nối server';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Có lỗi xảy ra: $e';
        _isLoading = false;
      });
    }
  }

  List<BlogApproved> _filterBlogs(List<BlogApproved> blogs, String keyword) {
    if (keyword.isEmpty) return blogs;
    return blogs
        .where(
            (blog) => blog.title.toLowerCase().contains(keyword.toLowerCase()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final blogs = ref.watch(blogListProvider);
    final themeState = ref.watch(themeProvider);
    final theme = Theme.of(context);

    return Scaffold(
      drawer: const DrawerCustom(),
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Tìm kiếm bài viết...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: themeState.secondaryTextColor),
                ),
                style: TextStyle(color: themeState.primaryTextColor),
                onChanged: (_) => setState(() {}),
              )
            : Text(
                'Bài viết',
                style: TextStyle(color: themeState.appBarTextColor),
              ),
        backgroundColor: themeState.appBarColor,
        actions: [
          IconButton(
            icon: Icon(
              _isSearching ? Icons.close : Icons.search,
              color: themeState.appBarTextColor,
            ),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) _searchController.clear();
              });
            },
          ),
          const ThemeButton(),
          const ThemeSelector(),
        ],
      ),
      body: blogs.isEmpty
          ? Center(child: Text('Chưa có bài viết nào'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: blogs.length,
              itemBuilder: (context, index) {
                if (index >= blogs.length) return null;
                final blog = blogs[index];
                if (blog == null) return null;

                return InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BlogDetailScreen(blog: blog),
                      ),
                    );
                  },
                  child: Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (blog.photo != null &&
                            blog.photo?.isNotEmpty == true)
                          ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(12)),
                            child: AspectRatio(
                              aspectRatio: 16 / 9,
                              child: Image.network(
                                getFullPhotoUrl(blog.photo),
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: Colors.grey[200],
                                    child: Icon(Icons.broken_image,
                                        color: Colors.grey),
                                  );
                                },
                              ),
                            ),
                          ),
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 16,
                                    backgroundColor: themeState.surfaceColor,
                                    backgroundImage: NetworkImage(
                                      getAvatarUrl(blog.authorPhoto),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          blog.authorName,
                                          style: TextStyle(
                                            color: themeState.primaryTextColor,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          formatDateTime(blog.createdAt),
                                          style: TextStyle(
                                            color:
                                                themeState.secondaryTextColor,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  _buildMoreButton(blog, themeState),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                blog.title,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: themeState.primaryTextColor,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 8),
                              ReadMoreText(
                                blog.content.replaceAll(RegExp(r'<[^>]*>'), ''),
                                style: TextStyle(
                                  color: themeState.bodyTextColor,
                                  fontSize: 14,
                                  height: 1.4,
                                ),
                                trimLines: 2,
                                colorClickableText: themeState.primaryColor,
                                trimMode: TrimMode.Line,
                                trimCollapsedText: 'Đọc tiếp',
                                trimExpandedText: 'Thu gọn',
                                moreStyle: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: themeState.primaryColor,
                                ),
                                lessStyle: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: themeState.primaryColor,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  _buildInteractionButton(
                                    icon: Icons.favorite_border,
                                    label: blog.countLike.toString(),
                                    themeState: themeState,
                                  ),
                                  const SizedBox(width: 16),
                                  IconButton(
                                    onPressed: () {
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
                                    icon: Icon(Icons.comment_outlined),
                                  ),
                                
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => CreatePostScreen()),
          );
        },
        backgroundColor: themeState.primaryColor,
        child: Icon(Icons.add, color: themeState.buttonTextColor),
        tooltip: 'Tạo bài viết mới',
      ),
    );
  }

  void startAutoReload() {
    _timer = Timer.periodic(Duration(seconds: 30), (_) => _loadBlogs());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

String formatDateTime(DateTime? date) {
  if (date == null) return 'Không có ngày';
  return DateFormat('dd/MM/yyyy HH:mm').format(date);
}

String getFullPhotoUrl(String? url) {
  // If url is null or empty, return default avatar URL
  if (url == null || url.isEmpty || url == 'null') {
    return 'http://10.0.2.2:8000/storage/uploads/resources/default.png'; // Default avatar path
  }

  String processedUrl = url;

  // If url is already a full URL
  if (processedUrl.startsWith('http')) {
    // Fix repeated storage segment if present (e.g., http://.../storage/storage/...)
    processedUrl = processedUrl.replaceFirst('/storage/storage/', '/storage/');

    // Handle emulator address
    processedUrl = processedUrl.replaceFirst('127.0.0.1', '10.0.2.2');

    return processedUrl;
  }

  // Handle relative paths
  // Assume paths starting with 'storage/' are relative to the base URL's storage directory
  if (processedUrl.startsWith('storage/')) {
    // Correctly prepend base URL for storage paths
    // Use 10.0.2.2 for emulator
    return 'http://10.0.2.2:8000/' + processedUrl; // Correctly prepend base URL
  }

  // For other relative paths or just filenames, assume they are resources
  return 'http://10.0.2.2:8000/storage/uploads/resources/' +
      processedUrl; // Old logic for resource paths
}

Widget _buildInteractionButton({
  required IconData icon,
  required String label,
  required ThemeState themeState,
  VoidCallback? onPressed,
}) {
  return InkWell(
    onTap: onPressed,
    borderRadius: BorderRadius.circular(8),
    child: Row(
      children: [
        Icon(icon, size: 18, color: themeState.secondaryTextColor),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            color: themeState.secondaryTextColor,
            fontSize: 14,
          ),
        ),
      ],
    ),
  );
}

Widget _buildMoreButton(BlogApproved blog, ThemeState themeState) {
  return Consumer(
    builder: (context, ref, child) {
      // Lấy userId hiện tại từ userProvider
      final currentUserId = ref.watch(userProvider)?.id.toString() ?? '';

      // Chỉ hiện nút 3 chấm nếu là bài viết của user hiện tại
      if (currentUserId != blog.userId) {
        return const SizedBox.shrink();
      }

      return PopupMenuButton<String>(
        icon: Icon(Icons.more_vert, color: themeState.secondaryTextColor),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        position: PopupMenuPosition.under,
        elevation: 3,
        onSelected: (value) {
          switch (value) {
            case 'edit':
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => EditPostScreen(
                    id: blog.id.toString(),
                    blog: blog,
                  ),
                ),
              );
              break;
            case 'delete':
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  title: Text(
                    'Xác nhận xóa',
                    style: TextStyle(color: themeState.primaryTextColor),
                  ),
                  content: Text(
                    'Bạn có chắc chắn muốn xóa bài viết này?',
                    style: TextStyle(color: themeState.bodyTextColor),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'Hủy',
                        style: TextStyle(color: themeState.primaryColor),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        ref.read(blogRepositoryProvider).deletePost(blog.id);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Đã xóa bài viết.',
                              style:
                                  TextStyle(color: themeState.primaryTextColor),
                            ),
                            backgroundColor: themeState.backgroundColor,
                          ),
                        );
                      },
                      child: Text(
                        'Xóa',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              );
              break;
          }
        },
        itemBuilder: (context) => [
          PopupMenuItem(
            value: 'edit',
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                children: [
                  Icon(
                    Icons.edit_outlined,
                    color: themeState.primaryTextColor,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Chỉnh sửa bài viết',
                    style: TextStyle(color: themeState.primaryTextColor),
                  ),
                ],
              ),
            ),
          ),
          PopupMenuItem(
            value: 'delete',
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                children: [
                  const Icon(
                    Icons.delete_outline,
                    color: Colors.red,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Xóa bài viết',
                    style: TextStyle(color: Colors.red),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    },
  );
}
