import 'package:flutter/material.dart';
import 'package:event_app/partial/girl.dart';

class Topgroundright extends StatelessWidget {
  const Topgroundright({
    super.key,
    required this.size,
  });

  final Size size;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      right: 0,
      child: CustomPaint(
        size: Size(
          size.width * 0.2,
          (size.width * 0.2).toDouble(),
        ),
        painter: RPSCustomPainter(),
      ),
    );
  }
}
