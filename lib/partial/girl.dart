import 'dart:ui' as ui;
import 'package:flutter/material.dart';

//Add this CustomPaint widget to the Widget Tree

//Copy this CustomPainter code to the Bottom of the File
class RPSCustomPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Path path_0 = Path();
    path_0.moveTo(size.width * 0.5567568, size.height * 0.7297297);
    path_0.lineTo(size.width * 0.5000000, size.height * 0.7297297);
    path_0.lineTo(size.width * 0.4432432, size.height * 0.7297297);
    path_0.cubicTo(
        size.width * 0.3402514,
        size.height * 0.7297297,
        size.width * 0.2567568,
        size.height * 0.8132243,
        size.width * 0.2567568,
        size.height * 0.9162162);
    path_0.lineTo(size.width * 0.2567568, size.height);
    path_0.lineTo(size.width * 0.5000000, size.height);
    path_0.lineTo(size.width * 0.7432432, size.height);
    path_0.lineTo(size.width * 0.7432432, size.height * 0.9162162);
    path_0.cubicTo(
        size.width * 0.7432432,
        size.height * 0.8132243,
        size.width * 0.6597486,
        size.height * 0.7297297,
        size.width * 0.5567568,
        size.height * 0.7297297);
    path_0.close();

    Paint paint_0_fill = Paint()..style = PaintingStyle.fill;
    paint_0_fill.color = Color(0xffFFB9A7).withOpacity(1.0);
    canvas.drawPath(path_0, paint_0_fill);

    Path path_1 = Path();
    path_1.moveTo(size.width * 0.5000000, size.height * 0.7297297);
    path_1.lineTo(size.width * 0.4432432, size.height * 0.7297297);
    path_1.cubicTo(
        size.width * 0.3402514,
        size.height * 0.7297297,
        size.width * 0.2567568,
        size.height * 0.8132243,
        size.width * 0.2567568,
        size.height * 0.9162162);
    path_1.lineTo(size.width * 0.2567568, size.height);
    path_1.lineTo(size.width * 0.5000000, size.height);
    path_1.lineTo(size.width * 0.5000000, size.height * 0.7297297);
    path_1.close();

    Paint paint_1_fill = Paint()..style = PaintingStyle.fill;
    paint_1_fill.color = Color(0xffF285B9).withOpacity(1.0);
    canvas.drawPath(path_1, paint_1_fill);

    Path path_2 = Path();
    path_2.moveTo(size.width * 0.5000000, size.height * 0.8918919);
    path_2.lineTo(size.width * 0.3918919, size.height);
    path_2.lineTo(size.width * 0.5000000, size.height);
    path_2.lineTo(size.width * 0.6081081, size.height);
    path_2.close();

    Paint paint_2_fill = Paint()..style = PaintingStyle.fill;
    paint_2_fill.color = Color(0xffFFE3DC).withOpacity(1.0);
    canvas.drawPath(path_2, paint_2_fill);

    Path path_3 = Path();
    path_3.moveTo(size.width * 0.3918919, size.height);
    path_3.lineTo(size.width * 0.5000000, size.height * 0.8918919);
    path_3.lineTo(size.width * 0.5000000, size.height);
    path_3.close();

    Paint paint_3_fill = Paint()..style = PaintingStyle.fill;
    paint_3_fill.color = Color(0xffFFB9A7).withOpacity(1.0);
    canvas.drawPath(path_3, paint_3_fill);

    Path path_4 = Path();
    path_4.moveTo(size.width * 0.2567568, size.height * 0.4864865);
    path_4.lineTo(size.width * 0.2567568, size.height * 0.6756757);
    path_4.cubicTo(
        size.width * 0.2567568,
        size.height * 0.6756757,
        size.width * 0.2027027,
        size.height * 0.6216216,
        size.width * 0.2027027,
        size.height * 0.4864865);
    path_4.lineTo(size.width * 0.2567568, size.height * 0.4864865);
    path_4.close();

    Paint paint_4_fill = Paint()..style = PaintingStyle.fill;
    paint_4_fill.color = Color(0xffBF720D).withOpacity(1.0);
    canvas.drawPath(path_4, paint_4_fill);

    Path path_5 = Path();
    path_5.moveTo(size.width * 0.7432432, size.height * 0.4864865);
    path_5.lineTo(size.width * 0.7432432, size.height * 0.6756757);
    path_5.cubicTo(
        size.width * 0.7432432,
        size.height * 0.6756757,
        size.width * 0.7972973,
        size.height * 0.6216216,
        size.width * 0.7972973,
        size.height * 0.4864865);
    path_5.lineTo(size.width * 0.7432432, size.height * 0.4864865);
    path_5.close();

    Paint paint_5_fill = Paint()..style = PaintingStyle.fill;
    paint_5_fill.color = Color(0xffFF9811).withOpacity(1.0);
    canvas.drawPath(path_5, paint_5_fill);

    Paint paint_6_fill = Paint()..style = PaintingStyle.fill;
    paint_6_fill.color = Color(0xff804C09).withOpacity(1.0);
    canvas.drawCircle(Offset(size.width * 0.4999973, size.height * 0.1351351),
        size.width * 0.1351351, paint_6_fill);

    Path path_7 = Path();
    path_7.moveTo(size.width * 0.5810811, size.height * 0.7297297);
    path_7.cubicTo(
        size.width * 0.5810811,
        size.height * 0.7745081,
        size.width * 0.5447784,
        size.height * 0.8108108,
        size.width * 0.5000000,
        size.height * 0.8108108);
    path_7.lineTo(size.width * 0.5000000, size.height * 0.8108108);
    path_7.cubicTo(
        size.width * 0.4552216,
        size.height * 0.8108108,
        size.width * 0.4189189,
        size.height * 0.7745081,
        size.width * 0.4189189,
        size.height * 0.7297297);
    path_7.lineTo(size.width * 0.4189189, size.height * 0.6486486);
    path_7.cubicTo(
        size.width * 0.4189189,
        size.height * 0.6038703,
        size.width * 0.4552216,
        size.height * 0.5675676,
        size.width * 0.5000000,
        size.height * 0.5675676);
    path_7.lineTo(size.width * 0.5000000, size.height * 0.5675676);
    path_7.cubicTo(
        size.width * 0.5447784,
        size.height * 0.5675676,
        size.width * 0.5810811,
        size.height * 0.6038703,
        size.width * 0.5810811,
        size.height * 0.6486486);
    path_7.lineTo(size.width * 0.5810811, size.height * 0.7297297);
    path_7.close();

    Paint paint_7_fill = Paint()..style = PaintingStyle.fill;
    paint_7_fill.color = Color(0xffFFEACF).withOpacity(1.0);
    canvas.drawPath(path_7, paint_7_fill);

    Paint paint_8_fill = Paint()..style = PaintingStyle.fill;
    paint_8_fill.color = Color(0xffFFEACF).withOpacity(1.0);
    canvas.drawOval(
        Rect.fromCenter(
            center: Offset(size.width * 0.5000000, size.height * 0.4459459),
            width: size.width * 0.5405405,
            height: size.height * 0.5675676),
        paint_8_fill);

    Path path_9 = Path();
    path_9.moveTo(size.width * 0.5000000, size.height * 0.6374541);
    path_9.cubicTo(
        size.width * 0.4529189,
        size.height * 0.6374541,
        size.width * 0.4092405,
        size.height * 0.6119514,
        size.width * 0.3860108,
        size.height * 0.5708946);
    path_9.cubicTo(
        size.width * 0.3841730,
        size.height * 0.5676459,
        size.width * 0.3853162,
        size.height * 0.5635243,
        size.width * 0.3885649,
        size.height * 0.5616865);
    path_9.cubicTo(
        size.width * 0.3918108,
        size.height * 0.5598432,
        size.width * 0.3959351,
        size.height * 0.5609919,
        size.width * 0.3977730,
        size.height * 0.5642405);
    path_9.cubicTo(
        size.width * 0.4186108,
        size.height * 0.6010649,
        size.width * 0.4577811,
        size.height * 0.6239405,
        size.width * 0.5000000,
        size.height * 0.6239405);
    path_9.cubicTo(
        size.width * 0.5422216,
        size.height * 0.6239405,
        size.width * 0.5813919,
        size.height * 0.6010649,
        size.width * 0.6022270,
        size.height * 0.5642405);
    path_9.cubicTo(
        size.width * 0.6040649,
        size.height * 0.5609919,
        size.width * 0.6081892,
        size.height * 0.5598486,
        size.width * 0.6114351,
        size.height * 0.5616865);
    path_9.cubicTo(
        size.width * 0.6146838,
        size.height * 0.5635243,
        size.width * 0.6158270,
        size.height * 0.5676459,
        size.width * 0.6139892,
        size.height * 0.5708946);
    path_9.cubicTo(
        size.width * 0.5907595,
        size.height * 0.6119514,
        size.width * 0.5470811,
        size.height * 0.6374541,
        size.width * 0.5000000,
        size.height * 0.6374541);
    path_9.close();

    Paint paint_9_fill = Paint()..style = PaintingStyle.fill;
    paint_9_fill.color = Color(0xffE8667D).withOpacity(1.0);
    canvas.drawPath(path_9, paint_9_fill);

    Paint paint_10_fill = Paint()..style = PaintingStyle.fill;
    paint_10_fill.color = Color(0xffFFB9A7).withOpacity(1.0);
    canvas.drawOval(
        Rect.fromCenter(
            center: Offset(size.width * 0.4054054, size.height * 0.5135135),
            width: size.width * 0.08108108,
            height: size.height * 0.05405405),
        paint_10_fill);

    Paint paint_11_fill = Paint()..style = PaintingStyle.fill;
    paint_11_fill.color = Color(0xff50412E).withOpacity(1.0);
    canvas.drawCircle(Offset(size.width * 0.4054054, size.height * 0.4527027),
        size.width * 0.02027027, paint_11_fill);

    Paint paint_12_fill = Paint()..style = PaintingStyle.fill;
    paint_12_fill.color = Color(0xffFFB9A7).withOpacity(1.0);
    canvas.drawOval(
        Rect.fromCenter(
            center: Offset(size.width * 0.5945946, size.height * 0.5135135),
            width: size.width * 0.08108108,
            height: size.height * 0.05405405),
        paint_12_fill);

    Paint paint_13_fill = Paint()..style = PaintingStyle.fill;
    paint_13_fill.color = Color(0xff50412E).withOpacity(1.0);
    canvas.drawCircle(Offset(size.width * 0.5945946, size.height * 0.4527027),
        size.width * 0.02027027, paint_13_fill);

    Path path_14 = Path();
    path_14.moveTo(size.width * 0.5000000, size.height * 0.6972973);
    path_14.cubicTo(
        size.width * 0.4391135,
        size.height * 0.6972973,
        size.width * 0.3808541,
        size.height * 0.6855189,
        size.width * 0.3271351,
        size.height * 0.6640703);
    path_14.cubicTo(
        size.width * 0.3739892,
        size.height * 0.7050595,
        size.width * 0.4342432,
        size.height * 0.7297297,
        size.width * 0.5000000,
        size.height * 0.7297297);
    path_14.cubicTo(
        size.width * 0.5657568,
        size.height * 0.7297297,
        size.width * 0.6260108,
        size.height * 0.7050595,
        size.width * 0.6728622,
        size.height * 0.6640703);
    path_14.cubicTo(
        size.width * 0.6191432,
        size.height * 0.6855189,
        size.width * 0.5608865,
        size.height * 0.6972973,
        size.width * 0.5000000,
        size.height * 0.6972973);
    path_14.close();

    Paint paint_14_fill = Paint()..style = PaintingStyle.fill;
    paint_14_fill.color = Color(0xffFFD6A0).withOpacity(1.0);
    canvas.drawPath(path_14, paint_14_fill);

    Path path_15 = Path();
    path_15.moveTo(size.width * 0.5000000, size.height * 0.08108108);
    path_15.cubicTo(
        size.width * 0.3648649,
        size.height * 0.08108108,
        size.width * 0.1486486,
        size.height * 0.1891892,
        size.width * 0.2027027,
        size.height * 0.4864865);
    path_15.lineTo(size.width * 0.2297297, size.height * 0.4324324);
    path_15.cubicTo(
        size.width * 0.2837838,
        size.height * 0.4324324,
        size.width * 0.4459459,
        size.height * 0.3783784,
        size.width * 0.5000000,
        size.height * 0.2432432);
    path_15.cubicTo(
        size.width * 0.5540541,
        size.height * 0.3783784,
        size.width * 0.7162162,
        size.height * 0.4324324,
        size.width * 0.7702703,
        size.height * 0.4324324);
    path_15.lineTo(size.width * 0.7972973, size.height * 0.4864865);
    path_15.cubicTo(
        size.width * 0.8513514,
        size.height * 0.1891892,
        size.width * 0.6351351,
        size.height * 0.08108108,
        size.width * 0.5000000,
        size.height * 0.08108108);
    path_15.close();

    Paint paint_15_fill = Paint()..style = PaintingStyle.fill;
    paint_15_fill.color = Color(0xffFF9811).withOpacity(1.0);
    canvas.drawPath(path_15, paint_15_fill);

    Path path_16 = Path();
    path_16.moveTo(size.width * 0.5000000, size.height * 0.08108108);
    path_16.cubicTo(
        size.width * 0.3648649,
        size.height * 0.08108108,
        size.width * 0.1486486,
        size.height * 0.1891892,
        size.width * 0.2027027,
        size.height * 0.4864865);
    path_16.lineTo(size.width * 0.2297297, size.height * 0.4324324);
    path_16.cubicTo(
        size.width * 0.2837838,
        size.height * 0.4324324,
        size.width * 0.4459459,
        size.height * 0.3783784,
        size.width * 0.5000000,
        size.height * 0.2432432);
    path_16.cubicTo(
        size.width * 0.5000000,
        size.height * 0.1621622,
        size.width * 0.5000000,
        size.height * 0.1351351,
        size.width * 0.5000000,
        size.height * 0.08108108);
    path_16.close();

    Paint paint_16_fill = Paint()..style = PaintingStyle.fill;
    paint_16_fill.color = Color(0xffBF720D).withOpacity(1.0);
    canvas.drawPath(path_16, paint_16_fill);

    Paint paint_17_fill = Paint()..style = PaintingStyle.fill;
    paint_17_fill.color = Color(0xffFFEACF).withOpacity(1.0);
    canvas.drawCircle(Offset(size.width * 0.2297297, size.height * 0.4864865),
        size.width * 0.05405405, paint_17_fill);

    Paint paint_18_fill = Paint()..style = PaintingStyle.fill;
    paint_18_fill.color = Color(0xffFFEACF).withOpacity(1.0);
    canvas.drawCircle(Offset(size.width * 0.7702703, size.height * 0.4864865),
        size.width * 0.05405405, paint_18_fill);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
