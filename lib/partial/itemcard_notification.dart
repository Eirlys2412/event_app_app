import 'package:flutter/material.dart';

class ItemCardNotification extends StatelessWidget {
  final Color? textColor; // Màu chữ có thể thay đổi
  const ItemCardNotification({
    super.key,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        elevation: 3,
        // color: Colors.white, // Sử dụng màu nền hoặc mặc định
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Notifications",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: textColor ??
                      Colors.pink, // Sử dụng màu chữ hoặc mặc định,
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: ListView.builder(
                  itemCount: 3, // Số lượng thông báo
                  itemBuilder: (context, i) => ListTile(
                    leading: Icon(Icons.notifications,
                        color: textColor ?? Colors.orange),
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
