import 'package:flutter/material.dart';
import '../providers/eventmanager_provider.dart';
import '../constants/pref_data.dart';


class EventManagerHomeScreen extends StatelessWidget {
  const EventManagerHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trang quản lý sự kiện'),
        backgroundColor: const Color(0xFF6D3CC9),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder<String?>(
          future: PrefData.getRole() , // Lấy vai trò người dùng từ PrefData
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                  child: CircularProgressIndicator()); // Đợi tải dữ liệu
            }

            final role = snapshot.data;

            // Nếu không có role hoặc không phải Event Manager, hiển thị thông báo lỗi
            if (role == null || role != 'eventmanager') {
              return Center(
                child: Text(
                  'Bạn không có quyền truy cập vào trang này.',
                  style: TextStyle(fontSize: 18, color: Colors.red),
                ),
              );
            }

            // Nếu là Event Manager, hiển thị UI quản lý sự kiện
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Chào mừng, Event Manager!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Quản lý sự kiện của bạn tại đây. Bạn có thể thêm, sửa, và xóa các sự kiện cũng như quản lý người tham gia.',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: () {
                    // Điều hướng tới trang tạo sự kiện mới
                    Navigator.pushNamed(context, '/create_event');
                  },
                  child: const Text('Tạo sự kiện mới'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6D3CC9),
                    padding: const EdgeInsets.symmetric(
                        vertical: 15, horizontal: 20),
                    textStyle: const TextStyle(fontSize: 18),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    // Điều hướng tới trang quản lý sự kiện hiện tại
                    Navigator.pushNamed(context, '/manage_events');
                  },
                  child: const Text('Quản lý sự kiện'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(
                        vertical: 15, horizontal: 20),
                    textStyle: const TextStyle(fontSize: 18),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
