import 'package:flutter/material.dart';

class UnauthorizedScreen extends StatelessWidget {
  const UnauthorizedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          'Không có quyền truy cập',
          style: TextStyle(fontSize: 20, color: Colors.red),
        ),
      ),
    );
  }
}
