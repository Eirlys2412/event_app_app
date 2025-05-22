// // Custom Painter for vertical curves
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// class VerticalCurvyPainter extends CustomPainter {
//   final Color gradientStart;
//   final Color gradientEnd;

//   VerticalCurvyPainter(
//       {super.repaint, required this.gradientStart, required this.gradientEnd});
//   @override
//   void paint(Canvas canvas, Size size) {
//     Paint paint = Paint()
//       ..shader = LinearGradient(
//         colors: [gradientStart, gradientEnd],
//         begin: Alignment.topLeft,
//         end: Alignment.bottomRight,
//       ).createShader(Rect.fromLTRB(0, 0, size.width, size.height));
//     Path path = Path();
//     path.moveTo(0, 0); // Bắt đầu từ góc trên bên trái

//     // Tạo đoạn cong đầu tiên
//     path.quadraticBezierTo(
//       size.width * 0.2, size.height * 0.1, // Điểm điều khiển
//       size.width * 0.4, size.height * 0.2, // Điểm kết thúc
//     );

//     // Tạo đoạn cong thứ hai
//     path.quadraticBezierTo(
//       size.width * 0.6, size.height * 0.3, // Điểm điều khiển
//       size.width * 0.4, size.height * 0.4, // Điểm kết thúc
//     );

//     // Tạo đoạn cong thứ ba
//     path.quadraticBezierTo(
//       size.width * 0.2, size.height * 0.5, // Điểm điều khiển
//       size.width * 0.5, size.height * 0.7, // Điểm kết thúc
//     );

//     // Tạo đoạn cong cuối
//     path.quadraticBezierTo(
//       size.width * 0.8, size.height * 0.9, // Điểm điều khiển
//       size.width, size.height, // Điểm kết thúc (góc phải đáy màn hình)
//     );

//     path.lineTo(0, size.height); // Kéo xuống đáy màn hình
//     path.close(); // Đóng đường dẫn

//     canvas.drawPath(path, paint);
//   }

//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) {
//     return false;
//   }
// }

class VerticalCurvyPainter extends CustomPainter {
  final Color gradientStart;
  final Color gradientEnd;
  final double progress; // Giá trị động để tạo animation

  VerticalCurvyPainter({
    required this.gradientStart,
    required this.gradientEnd,
    required this.progress, // Thêm progress vào constructor
  });

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..shader = LinearGradient(
        colors: [gradientStart, gradientEnd],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromLTRB(0, 0, size.width, size.height));

    Path path = Path();
    path.moveTo(0, 0); // Bắt đầu từ góc trên bên trái

    // Tạo đoạn cong đầu tiên (thay đổi điểm điều khiển theo progress)
    path.quadraticBezierTo(
      size.width * 0.2,
      size.height *
          (0.1 + 0.05 * progress), // Điều chỉnh chiều cao theo progress
      size.width * 0.4,
      size.height * 0.2,
    );

    // Tạo đoạn cong thứ hai
    path.quadraticBezierTo(
      size.width * 0.6,
      size.height *
          (0.3 - 0.05 * progress), // Điều chỉnh chiều cao theo progress
      size.width * 0.4,
      size.height * 0.4,
    );

    // Tạo đoạn cong thứ ba
    path.quadraticBezierTo(
      size.width * 0.2,
      size.height *
          (0.5 + 0.1 * progress), // Điều chỉnh chiều cao theo progress
      size.width * 0.5,
      size.height * 0.7,
    );

    // Tạo đoạn cong cuối
    path.quadraticBezierTo(
      size.width * 0.8,
      size.height *
          (0.9 - 0.05 * progress), // Điều chỉnh chiều cao theo progress
      size.width,
      size.height,
    );

    path.lineTo(0, size.height); // Kéo xuống đáy màn hình
    path.close(); // Đóng đường dẫn

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant VerticalCurvyPainter oldDelegate) {
    return oldDelegate.progress != progress; // Vẽ lại khi progress thay đổi
  }
}

class AnimatedVerticalCurvyPainter extends StatefulWidget {
  @override
  _AnimatedVerticalCurvyPainterState createState() =>
      _AnimatedVerticalCurvyPainterState();
}

class _AnimatedVerticalCurvyPainterState
    extends State<AnimatedVerticalCurvyPainter>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
      animationBehavior: AnimationBehavior.preserve, // Giảm tải khi không cần
    );
  }

  void _startAnimation() {
    if (!_controller.isAnimating) {
      _controller.repeat(reverse: true);
    }
  }

  void _stopAnimation() {
    if (_controller.isAnimating) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          size: MediaQuery.of(context).size,
          painter: VerticalCurvyPainter(
            gradientStart: Colors.pinkAccent,
            gradientEnd: Colors.pink.shade100,
            progress: _controller.value, // Giá trị động từ animation controller
          ),
        );
      },
    );
  }
}
