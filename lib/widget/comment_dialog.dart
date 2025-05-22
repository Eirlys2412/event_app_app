import 'package:flutter/material.dart';

class CommentSection extends StatelessWidget {
  final List<dynamic> comments;

  const CommentSection({super.key, required this.comments});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Bình luận",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        ...comments.map((c) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Text("- ${c.toString()}"),
            )),
        const SizedBox(height: 10),
        TextField(
          decoration: InputDecoration(
            hintText: "Nhập bình luận...",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            suffixIcon: IconButton(
              icon: const Icon(Icons.send),
              onPressed: () {
                // TODO: Gửi comment
              },
            ),
          ),
        ),
      ],
    );
  }
}
