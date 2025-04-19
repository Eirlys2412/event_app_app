import 'package:flutter/material.dart';
import '../widget/drawer_custom.dart';

class BlogFeedScreen extends StatelessWidget {
  const BlogFeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Dữ liệu mẫu
    final List<Map<String, dynamic>> posts = [
      {
        'avatar': 'https://randomuser.me/api/portraits/men/1.jpg',
        'username': 'Nguyễn Văn A',
        'time': '2 giờ trước',
        'content': 'Hôm nay tham gia sự kiện rất vui!',
        'image': 'https://source.unsplash.com/random/300x200/?event',
      },
      {
        'avatar': 'https://randomuser.me/api/portraits/women/2.jpg',
        'username': 'Trần Thị B',
        'time': '3 giờ trước',
        'content': 'Đây là hình ảnh buổi workshop ngày hôm qua.',
        'image': 'https://source.unsplash.com/random/300x200/?workshop',
      },
    ];

    return Scaffold(
      drawer: const DrawerCustom(userName: '', userEmail: '', avatarUrl: ''),
      appBar: AppBar(
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu), // Nút 3 gạch
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
        title: const Text('Bảng tin sự kiện'),
        backgroundColor: const Color.fromARGB(255, 154, 144, 243),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: posts.length,
        itemBuilder: (context, index) {
          final post = posts[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 10),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundImage: NetworkImage(post['avatar']),
                        radius: 22,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(post['username'],
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                            Text(post['time'],
                                style: const TextStyle(
                                    fontSize: 12, color: Colors.grey)),
                          ],
                        ),
                      ),
                      const Icon(Icons.more_horiz)
                    ],
                  ),
                  const SizedBox(height: 10),
                  // Nội dung
                  Text(post['content']),
                  const SizedBox(height: 10),
                  // Hình ảnh
                  if (post['image'] != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        post['image'],
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: 200,
                      ),
                    ),
                  const SizedBox(height: 10),
                  // Các nút tương tác
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      IconButton(
                          icon: const Icon(Icons.thumb_up_alt_outlined),
                          onPressed: () {}),
                      IconButton(
                          icon: const Icon(Icons.comment_outlined),
                          onPressed: () {}),
                      IconButton(
                          icon: const Icon(Icons.share_outlined),
                          onPressed: () {}),
                    ],
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
