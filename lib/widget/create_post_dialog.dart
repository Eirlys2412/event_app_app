import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class CreatePostDialog extends StatefulWidget {
  final Function(String, XFile?) onPostSubmitted;

  const CreatePostDialog({Key? key, required this.onPostSubmitted})
      : super(key: key);

  @override
  _CreatePostDialogState createState() => _CreatePostDialogState();
}

class _CreatePostDialogState extends State<CreatePostDialog> {
  final TextEditingController postController = TextEditingController();
  XFile? selectedImage;

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    selectedImage = await picker.pickImage(source: ImageSource.gallery);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Đăng Bài Mới'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: postController,
            decoration:
                const InputDecoration(hintText: 'Nhập nội dung bài đăng'),
          ),
          const SizedBox(height: 10),
          selectedImage != null
              ? Image.file(File(selectedImage!.path))
              : const Text('Chưa chọn ảnh'),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Hủy'),
        ),
        ElevatedButton(
          onPressed: () {
            widget.onPostSubmitted(postController.text, selectedImage);
            Navigator.of(context).pop();
          },
          child: const Text('Đăng'),
        ),
        IconButton(
          icon: const Icon(Icons.image),
          onPressed: _pickImage,
        ),
      ],
    );
  }
}
