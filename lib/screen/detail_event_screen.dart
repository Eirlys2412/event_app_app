import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:event_app/utils/date_utils.dart';
import 'package:event_app/models/event.dart';
import 'package:event_app/screen/event_list_user_screen.dart';

class EventDetailScreen extends StatelessWidget {
  final Map<String, dynamic> event;

  const EventDetailScreen({Key? key, required this.event}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(event['title']),
        backgroundColor: const Color.fromARGB(255, 137, 82, 232),
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (event['resources'] != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                event['resources']!,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),

          const SizedBox(height: 20),

          // Thông tin sự kiện
          _buildEventInfo(),

          const SizedBox(height: 24),

          // Vote và Đăng ký
          _buildActions(context),

          const Divider(height: 40),

          // Danh sách bình luận
          _buildCommentSection(),

          const SizedBox(height: 20),

          // Form gửi bình luận
          _buildCommentForm(context),
        ],
      ),
    );
  }

  Widget _buildEventInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          event['title'],
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        if (event['summary'] != null)
          Text(
            event['summary']!,
            style: const TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
          ),
        const SizedBox(height: 12),
        if (event['description'] != null)
          Text(
            event['description']!,
            style: const TextStyle(fontSize: 15),
          ),
        const SizedBox(height: 16),
        Row(
          children: [
            const Icon(Icons.access_time, size: 20),
            const SizedBox(width: 6),
            Text(
              "${formatDate(event['timestart'] as String?)} → ${formatDate(event['timeend'] as String?)}",
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Icon(Icons.location_on_outlined, size: 20),
            const SizedBox(width: 6),
            Text(event['diadiem'] ?? "Chưa cập nhật"),
          ],
        ),
      ],
    );
  }

  Widget _buildActions(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton.icon(
          onPressed: () {
            // TODO: Call vote API
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Bạn đã vote cho sự kiện!")),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.deepPurple,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
          icon: const Icon(Icons.thumb_up),
          label: const Text("Vote"),
        ),
        ElevatedButton.icon(
          onPressed: () {
            // TODO: Call đăng ký API
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Đăng ký thành công!")),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
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
                  eventId: event['id'],
                  eventTitle: event['title'],
                ),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blueGrey,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
          icon: const Icon(Icons.group),
          label: const Text("Xem thành viên"),
        ),
      ],
    );
  }

  Widget _buildCommentSection() {
    // TODO: Replace bằng real data từ API
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text(
          "Bình luận",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        Text("Chưa có bình luận."),
      ],
    );
  }

  Widget _buildCommentForm(BuildContext context) {
    final controller = TextEditingController();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Gửi bình luận mới",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: "Nhập bình luận...",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
        const SizedBox(height: 10),
        Align(
          alignment: Alignment.centerRight,
          child: ElevatedButton(
            onPressed: () {
              // TODO: Gửi bình luận API
              if (controller.text.trim().isNotEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Bình luận đã được gửi!")),
                );
                controller.clear();
              }
            },
            child: const Text("Gửi"),
          ),
        )
      ],
    );
  }
}
