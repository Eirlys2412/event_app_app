import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:event_app/providers/event_profile.dart'; // Comment out hoặc xóa dòng này
import 'package:event_app/providers/user_profile.dart'; // Import đúng file provider
import 'package:event_app/providers/blog_provider.dart';
import '../constants/apilist.dart';
import 'blog_detail_screen.dart'; // Import màn hình chi tiết blog

String getFullPhotoUrl(String? photoPath) {
  if (photoPath == null || photoPath.isEmpty || photoPath == 'null') {
    return '${url_image}storage/uploads/resources/default.png';
  }
  if (photoPath.startsWith('http')) {
    return photoPath
        .replaceFirst('127.0.0.1', '10.0.2.2')
        .replaceFirst('localhost', '10.0.2.2');
  }
  if (photoPath.startsWith('storage/')) {
    return url_image + photoPath;
  }
  return '${url_image}storage/uploads/resources/$photoPath';
}

class EventUserProfileScreen extends ConsumerWidget {
  final int userId;

  const EventUserProfileScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userProfileAsync = ref.watch(userProfileProvider(userId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hồ sơ thành viên'),
      ),
      body: userProfileAsync.when(
        data: (user) {
          print('User data: $user');
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 48,
                  backgroundImage: user.photo != null && user.photo!.isNotEmpty
                      ? NetworkImage(getFullPhotoUrl(user.photo!))
                          as ImageProvider
                      : const AssetImage('assets/default_avatar.png')
                          as ImageProvider,
                  onBackgroundImageError: (exception, stackTrace) {
                    print('Error loading user avatar: $exception');
                    // Fallback to default avatar on error
                  },
                ),
                const SizedBox(height: 16),

                Text(
                  user.full_Name ?? 'Không rõ tên',
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  user.email ?? 'Không rõ email',
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 24),

                const Divider(height: 30, thickness: 1.2),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {
                          // TODO: Follow logic
                        },
                        icon: const Icon(Icons.person_add_alt_1),
                        label: const Text('Theo dõi'),
                      ),
                      ElevatedButton.icon(
                        onPressed: () {
                          // TODO: Gửi tin nhắn logic
                        },
                        icon: const Icon(Icons.message),
                        label: const Text('Nhắn tin'),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 30, thickness: 1.2),

                /// Bài viết gần đây
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Bài viết gần đây',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      // color: Colors.black87, // Có thể tùy chỉnh màu sắc
                    ),
                  ),
                ),
                const SizedBox(
                    height: 16), // Khoảng cách giữa tiêu đề và danh sách

                user.blogs.isEmpty // Sử dụng danh sách blog từ user object
                    ? const Text('Chưa có bài viết nào.')
                    : Container(
                        height:
                            250, // Chiều cao cố định cho ListView cuộn ngang
                        padding: const EdgeInsets.symmetric(
                            vertical: 8.0), // Thêm padding
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: user.blogs.length,
                          itemBuilder: (context, index) {
                            final blog = user.blogs[index];
                            return InkWell(
                              onTap: () {
                                // Điều hướng đến màn hình chi tiết bài viết
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => BlogDetailScreen(
                                        blog:
                                            blog), // Truyền đối tượng blog đầy đủ
                                  ),
                                );
                              },
                              child: Card(
                                elevation: 4.0, // Tăng độ đổ bóng
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                      12.0), // Bo tròn góc nhiều hơn
                                ),
                                margin: const EdgeInsets.symmetric(
                                    horizontal: 8), // Giữ margin cho Card
                                child: Container(
                                  width: 200,
                                  padding: const EdgeInsets.all(10),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Thêm ảnh blog (nếu có)
                                      if (blog.photo != null &&
                                          blog.photo!.isNotEmpty)
                                        ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                          child: Image.network(
                                            getFullPhotoUrl(blog.photo!),
                                            height: 100,
                                            width: double.infinity,
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error,
                                                    stackTrace) =>
                                                Icon(Icons
                                                    .broken_image), // Fallback icon
                                          ),
                                        ),
                                      const SizedBox(height: 8),
                                      Text(blog.title,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold)),
                                      const SizedBox(height: 4),
                                      Text(blog.summary ?? '',
                                          maxLines: 3,
                                          overflow: TextOverflow.ellipsis),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                const Divider(height: 30, thickness: 1.2),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) {
          print('Lỗi chi tiết: $err');
          return Center(child: Text('Lỗi khi tải hồ sơ: $err'));
        },
      ),
    );
  }
}
