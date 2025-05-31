import 'package:event_app/providers/like_provider.dart';
import 'package:event_app/screen/CreatePostScreen.dart';
import 'package:event_app/screen/blog_comment_screen.dart';
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
import '../screen/editposstScreen.dart';
import '../screen/my_event_screen.dart';
import '../constants/pref_data.dart';
import 'dart:convert';

class MyBlogScreen extends ConsumerStatefulWidget {
  const MyBlogScreen({super.key});

  @override
  ConsumerState<MyBlogScreen> createState() => _MyBlogScreenState();
}

class _MyBlogScreenState extends ConsumerState<MyBlogScreen> {
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _loadCurrentUserId();
    // Load blogs when the screen initializes. blogListProvider will handle fetching.
    ref.read(blogListProvider.notifier).loadBlogs(); // Ensure blogs are loaded
  }

  Future<void> _loadCurrentUserId() async {
    final userId = await PrefData.getUserId();
    setState(() {
      _currentUserId = userId?.toString();
    });
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
    // Watch the global blog list provider
    final blogList = ref.watch(blogListProvider);
    final themeState = ref.watch(themeProvider);
    final theme = Theme.of(context);

    // Filter blogs by current user ID and then apply search filter
    final myBlogs = blogList
        .where((blog) =>
            blog.authorId == _currentUserId) // Use authorId from BlogApproved
        .toList();

    final filteredBlogs = _filterBlogs(myBlogs, _searchController.text);

    // Check loading state from blogListProvider (assuming it has one, if not, need to add or handle manually)
    // For simplicity now, we use _currentUserId loading state.
    final isLoadingBlogs = ref.watch(blogListProvider.notifier).state.isEmpty &&
        _currentUserId != null &&
        ref
            .watch(blogListProvider.notifier)
            .isLoading; // Use isLoading from notifier if available

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: themeState.appBarTextColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
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
                onChanged: (_) =>
                    setState(() {}), // Rebuild to apply search filter
              )
            : Text(
                'Bài viết của tôi',
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
      body: _currentUserId == null // Show loading while fetching user ID
          ? const Center(
              child: CircularProgressIndicator()) // Or a loading indicator
          : isLoadingBlogs // Show loading while blogs are being fetched and list is empty
              ? Center(
                  child:
                      CircularProgressIndicator(color: themeState.primaryColor),
                )
              : filteredBlogs
                      .isEmpty // Show empty state if no blogs after loading
                  ? const Center(
                      child: Text('Bạn chưa có bài viết nào.'),
                    )
                  : ListView.builder(
                      // Display blogs if not empty
                      padding: const EdgeInsets.all(
                          16), // Add padding similar to BlogFeed
                      itemCount: filteredBlogs.length,
                      itemBuilder: (context, index) {
                        final blog = filteredBlogs[index];
                        return InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => BlogDetailScreen(
                                  blog: blog,
                                ),
                              ),
                            );
                          },
                          child: Card(
                            margin:
                                const EdgeInsets.only(bottom: 16), // Add margin
                            elevation: 2, // Add elevation
                            color: themeState.cardColor, // Use theme color
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                  12), // Add border radius
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (blog.photo != null &&
                                    blog.photo!.isNotEmpty)
                                  ClipRRect(
                                    borderRadius: const BorderRadius.vertical(
                                        top: Radius.circular(12)),
                                    child: AspectRatio(
                                      aspectRatio: 16 / 9,
                                      child: Image.network(
                                        getFullPhotoUrl(blog.photo),
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                          return Container(
                                            color: themeState.backgroundColor,
                                            child: Icon(
                                              Icons.broken_image_outlined,
                                              color:
                                                  themeState.secondaryTextColor,
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          CircleAvatar(
                                            radius: 16,
                                            backgroundColor:
                                                themeState.surfaceColor,
                                            backgroundImage: NetworkImage(
                                              getFullPhotoUrl(blog.authorPhoto),
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
                                                    color: themeState
                                                        .primaryTextColor,
                                                    fontWeight: FontWeight.w500,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                                Text(
                                                  formatDateTime(
                                                      blog.createdAt),
                                                  style: TextStyle(
                                                    color: themeState
                                                        .secondaryTextColor,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          // Use _buildMoreButton adapted for MyBlogScreen
                                          _buildMyBlogMoreButton(blog,
                                              themeState, ref), // Pass ref here
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
                                        blog.content
                                            .replaceAll(RegExp(r'<[^>]*>'), ''),
                                        style: TextStyle(
                                          color: themeState.bodyTextColor,
                                          fontSize: 14,
                                          height: 1.4,
                                        ),
                                        trimLines: 2,
                                        colorClickableText:
                                            themeState.primaryColor,
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
                                          // Like button with updated logic
                                          _buildInteractionButton(
                                            icon: blog.is_liked
                                                ? Icons.favorite
                                                : Icons.favorite_border,
                                            label: blog.countLike.toString(),
                                            themeState: themeState,
                                            iconColor: blog.is_liked
                                                ? Colors.red
                                                : themeState.secondaryTextColor,
                                            onPressed: () async {
                                              final response = await ref
                                                  .read(blogRepositoryProvider)
                                                  .toggleLikeBlog(blog.id);
                                              if (response.statusCode >= 200 &&
                                                  response.statusCode < 300) {
                                                try {
                                                  final responseData = json
                                                      .decode(response.body);
                                                  ref
                                                      .read(blogListProvider
                                                          .notifier)
                                                      .updateLikeStatus(
                                                        blog.id,
                                                        responseData[
                                                                'is_liked'] ??
                                                            !blog.is_liked,
                                                        responseData[
                                                                'likes_count'] ??
                                                            (blog.is_liked
                                                                ? blog.countLike -
                                                                    1
                                                                : blog.countLike +
                                                                    1),
                                                      );
                                                  if (mounted) {
                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .showSnackBar(
                                                      SnackBar(
                                                        content: Text(responseData[
                                                                'is_liked']
                                                            ? 'Đã thích bài viết'
                                                            : 'Đã bỏ thích bài viết'),
                                                      ),
                                                    );
                                                  }
                                                } catch (e) {
                                                  print(
                                                      'Error decoding like response: $e');
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    SnackBar(
                                                      content: Text(
                                                          'Lỗi xử lý phản hồi thích.'),
                                                    ),
                                                  );
                                                }
                                              } else {
                                                print(
                                                    'Error toggling like: ${response.statusCode}');
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                        'Lỗi khi cập nhật trạng thái thích.'),
                                                  ),
                                                );
                                              }
                                            },
                                          ),
                                          const SizedBox(width: 16),
                                          _buildInteractionButton(
                                            icon: Icons.comment_outlined,
                                            label: blog.countComment.toString(),
                                            themeState: themeState,
                                            onPressed: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (_) =>
                                                      BlogCommentScreen(
                                                    blogId: blog.id,
                                                    blogTitle: blog.title,
                                                  ),
                                                ),
                                              );
                                            },
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
}

String formatDateTime(DateTime? date) {
  if (date == null) return 'Không có ngày';
  return DateFormat('dd/MM/yyyy HH:mm').format(date);
}

String getFullPhotoUrl(String? url) {
  // If url is null or empty, return default avatar URL
  if (url == null || url.isEmpty) {
    return 'http://127.0.0.1:8000/storage/uploads/resources/default.png';
  }
  // If url is already a full URL, return it
  if (url.startsWith('http')) {
    return url.replaceFirst('127.0.0.1', '10.0.2.2');
  }
  // If url is just a filename, prepend the base URL
  return 'http://127.0.0.1:8000/storage/uploads/resources/$url';
}

Widget _buildInteractionButton({
  required IconData icon,
  required String label,
  required ThemeState themeState,
  Color? iconColor,
  VoidCallback? onPressed,
}) {
  return Row(
    children: [
      Icon(icon, size: 18, color: iconColor ?? themeState.secondaryTextColor),
      const SizedBox(width: 4),
      Text(
        label,
        style: TextStyle(
          color: themeState.secondaryTextColor,
          fontSize: 14,
        ),
      ),
    ],
  );
}

Widget _buildMyBlogMoreButton(
    BlogApproved blog, ThemeState themeState, WidgetRef ref) {
  // Adapted more button
  return Consumer(
    builder: (context, ref, child) {
      // In MyBlogScreen, this button is only shown for the current user's blogs
      // The filtering logic is already done before building the list.
      // So we don't need the user ID check here.

      return PopupMenuButton<String>(
        icon: Icon(Icons.more_vert, color: themeState.secondaryTextColor),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        position: PopupMenuPosition.under,
        elevation: 3,
        color: themeState.dialogBackgroundColor,
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
                  backgroundColor: themeState.dialogBackgroundColor,
                  title: Text(
                    'Xác nhận xóa',
                    style: TextStyle(color: themeState.dialogTextColor),
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
                        // Use ref from outer scope or pass it
                        ref.read(blogRepositoryProvider).deletePost(blog.id);
                        // After deleting, refresh the blog list
                        ref.read(blogListProvider.notifier).loadBlogs();
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
