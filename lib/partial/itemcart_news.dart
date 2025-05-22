import 'package:flutter/material.dart';

class ItemCardNews extends StatelessWidget {
  final Color? backgroundColor; // Màu nền có thể thay đổi
  final Color? textColor; // Màu chữ có thể thay đổi

  const ItemCardNews({
    super.key,
    this.backgroundColor, // Nhận màu nền từ bên ngoài
    this.textColor, // Nhận màu chữ từ bên ngoài
  });

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: Card(
        elevation: 3,
        // color: Colors.white, // Sử dụng màu nền hoặc mặc định
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "News",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color:
                      textColor ?? Colors.pink, // Sử dụng màu chữ hoặc mặc định
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: ListView.builder(
                  physics:
                      const NeverScrollableScrollPhysics(), // Ngăn cuộn bên trong
                  itemCount: 3, // Số lượng tin mới
                  itemBuilder: (context, i) => ListTile(
                    leading: Icon(
                      Icons.newspaper,
                      color: textColor ?? Colors.pink, // Màu icon theo theme
                    ),
                    title: Text(
                      "News ${i + 1}",
                      // style: TextStyle(color: Colors.black),
                    ),
                    subtitle: Text(
                      "Latest updates...",
                      // style: TextStyle(color: Colors.black54),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
