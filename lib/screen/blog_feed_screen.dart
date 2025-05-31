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
import 'dart:convert';
import '../providers/user_provider.dart';
import '../utils/url_utils.dart' as url_utils;

class BlogFeedScreen extends ConsumerStatefulWidget {
  const BlogFeedScreen({super.key});

  @override
  ConsumerState<BlogFeedScreen> createState() => _BlogFeedScreenState();
}

class _BlogFeedScreenState extends ConsumerState<BlogFeedScreen> {
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

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

    final filteredBlogs = _filterBlogs(blogs, _searchController.text);

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
      body: filteredBlogs.isEmpty
          ? Center(
              child: _isSearching
                  ? const Text('Không tìm thấy bài viết nào')
                  : const Text('Chưa có bài viết nào'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: filteredBlogs.length,
              itemBuilder: (context, index) {
                if (index >= filteredBlogs.length) return null;
                final blog = filteredBlogs[index];
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
                                url_utils.getFullPhotoUrl(blog.photo),
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
                                      url_utils.getAvatarUrl(blog.authorPhoto),
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
                                    icon: blog.is_liked
                                        ? Icons.favorite
                                        : Icons.favorite_border,
                                    label: 'Thích (${blog.countLike})',
                                    themeState: themeState,
                                    iconColor: blog.is_liked
                                        ? Colors.red
                                        : themeState.secondaryTextColor,
                                    onPressed: () async {
                                      try {
                                        final response = await ref
                                            .read(blogRepositoryProvider)
                                            .toggleLikeBlog(blog.id);
                                        if (response.statusCode >= 200 &&
                                            response.statusCode < 300) {
                                          final responseData =
                                              json.decode(response.body);
                                          ref
                                              .read(blogListProvider.notifier)
                                              .updateLikeStatus(
                                                blog.id,
                                                responseData['is_liked'] ??
                                                    false,
                                                responseData['likes_count'] ??
                                                    0,
                                              );
                                          if (mounted) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                content: Text(responseData[
                                                        'is_liked']
                                                    ? 'Đã thích bài viết'
                                                    : 'Đã bỏ thích bài viết'),
                                              ),
                                            );
                                          }
                                        } else {
                                          throw Exception(
                                              'API error: ${response.statusCode}');
                                        }
                                      } catch (e) {
                                        if (mounted) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                                content: Text(
                                                    'Lỗi: ${e.toString()}')),
                                          );
                                        }
                                      }
                                    },
                                  ),
                                  const SizedBox(width: 16),
                                  _buildInteractionButton(
                                    icon: Icons.comment_outlined,
                                    label: 'Bình luận',
                                    themeState: themeState,
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

Widget _buildInteractionButton({
  required IconData icon,
  required String label,
  required ThemeState themeState,
  VoidCallback? onPressed,
  Color? iconColor,
}) {
  return InkWell(
    onTap: onPressed,
    borderRadius: BorderRadius.circular(8),
    child: Row(
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
    ),
  );
}

Widget _buildMoreButton(BlogApproved blog, ThemeState themeState) {
  return Consumer(
    builder: (context, ref, child) {
      final currentUserId = ref.watch(userProvider)?.id.toString() ?? '';

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
