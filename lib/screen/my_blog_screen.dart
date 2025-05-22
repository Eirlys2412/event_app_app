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

class MyBlogScreen extends ConsumerStatefulWidget {
  const MyBlogScreen({super.key});

  @override
  ConsumerState<MyBlogScreen> createState() => _MyBlogScreenState();
}

class _MyBlogScreenState extends ConsumerState<MyBlogScreen> {
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
    final myBlogsListAsync = ref.watch(myBlogsProvider(''));
    final themeState = ref.watch(themeProvider);
    final theme = Theme.of(context);

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
                onChanged: (_) => setState(() {}),
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
      body: myBlogsListAsync.when(
        data: (blogs) {
          final filteredBlogs = _filterBlogs(blogs, _searchController.text);
          if (filteredBlogs.isEmpty) {
            return const Center(
              child: Text('Bạn chưa có bài viết nào.'),
            );
          }
          return ListView.builder(
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
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                        color: themeState.primaryColor.withOpacity(0.1)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (blog.photo.isNotEmpty)
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
                                  color: themeState.backgroundColor,
                                  child: Icon(
                                    Icons.broken_image_outlined,
                                    color: themeState.secondaryTextColor,
                                  ),
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
                                          color: themeState.primaryTextColor,
                                          fontWeight: FontWeight.w500,
                                          fontSize: 14,
                                        ),
                                      ),
                                      Text(
                                        formatDateTime(blog.createdAt),
                                        style: TextStyle(
                                          color: themeState.secondaryTextColor,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                PopupMenuButton<String>(
                                  icon: Icon(Icons.more_vert,
                                      color: themeState.secondaryTextColor),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  position: PopupMenuPosition.under,
                                  elevation: 3,
                                  onSelected: (value) {
                                    switch (value) {
                                      case 'profile':
                                        // TODO: Navigate to user profile
                                        break;
                                      case 'edit':
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => EditPostScreen(
                                                id: blog.id.toString(),
                                                blog: blog),
                                          ),
                                        );
                                        break;
                                      case 'delete':
                                        showDialog(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                            ),
                                            title: Text(
                                              'Xác nhận xóa',
                                              style: TextStyle(
                                                  color: themeState
                                                      .primaryTextColor),
                                            ),
                                            content: Text(
                                              'Bạn có chắc chắn muốn xóa bài viết này?',
                                              style: TextStyle(
                                                  color:
                                                      themeState.bodyTextColor),
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () =>
                                                    Navigator.pop(context),
                                                child: Text(
                                                  'Hủy',
                                                  style: TextStyle(
                                                      color: themeState
                                                          .primaryColor),
                                                ),
                                              ),
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                  ref
                                                      .read(
                                                          blogRepositoryProvider)
                                                      .deletePost(blog.id);
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    SnackBar(
                                                      content: Text(
                                                        'Đã xóa bài viết.',
                                                        style: TextStyle(
                                                            color: themeState
                                                                .primaryTextColor),
                                                      ),
                                                      backgroundColor:
                                                          themeState
                                                              .backgroundColor,
                                                    ),
                                                  );
                                                },
                                                child: Text(
                                                  'Xóa',
                                                  style: TextStyle(
                                                      color: Colors.red),
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
                                      value: 'profile',
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8),
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.person_outline,
                                              color:
                                                  themeState.primaryTextColor,
                                              size: 20,
                                            ),
                                            const SizedBox(width: 12),
                                            Text(
                                              'Xem trang cá nhân',
                                              style: TextStyle(
                                                  color: themeState
                                                      .primaryTextColor),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    PopupMenuItem(
                                      value: 'edit',
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8),
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.edit_outlined,
                                              color:
                                                  themeState.primaryTextColor,
                                              size: 20,
                                            ),
                                            const SizedBox(width: 12),
                                            Text(
                                              'Chỉnh sửa bài viết',
                                              style: TextStyle(
                                                  color: themeState
                                                      .primaryTextColor),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    PopupMenuItem(
                                      value: 'delete',
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8),
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.delete_outline,
                                              color: Colors.red,
                                              size: 20,
                                            ),
                                            const SizedBox(width: 12),
                                            Text(
                                              'Xóa bài viết',
                                              style:
                                                  TextStyle(color: Colors.red),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
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
                                  icon: Icons.thumb_up_outlined,
                                  label: blog.countLike.toString(),
                                  themeState: themeState,
                                ),
                                const SizedBox(width: 16),
                                _buildInteractionButton(
                                  icon: Icons.comment_outlined,
                                  label: blog.countComment.toString(),
                                  themeState: themeState,
                                ),
                                const SizedBox(width: 16),
                                _buildInteractionButton(
                                  icon: Icons.share_outlined,
                                  label: 'Share',
                                  themeState: themeState,
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
          );
        },
        loading: () => Center(
          child: CircularProgressIndicator(
            color: themeState.primaryColor,
          ),
        ),
        error: (err, _) => Center(
          child: Text(
            'Lỗi: $err',
            style: TextStyle(color: themeState.errorColor),
          ),
        ),
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
}) {
  return Row(
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
  );
}
