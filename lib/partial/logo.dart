import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_svg/flutter_svg.dart';

class LogoWidget extends StatelessWidget {
  final Color primaryColor;
  final Color textHead1Color;
  final double width;
  final double font_size;
  final String primaryTitle;
  final String subTitle;
  const LogoWidget(
      {super.key,
      required this.primaryColor,
      required this.textHead1Color,
      required this.width,
      required this.font_size,
      required this.primaryTitle,
      required this.subTitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(0),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SvgPicture.asset(
          'assets/svg/logo.svg', // Path to your SVG file
          width: width, // Desired width
          height: width, // Desired height
          color: primaryColor,
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            if (subTitle == '') const SizedBox(height: 18), //
            Text(primaryTitle,
                style: TextStyle(
                  fontSize: font_size,
                  fontWeight: FontWeight.bold,
                  color: textHead1Color,
                )),
            if (subTitle != '')
              const SizedBox(
                  height:
                      8), // Add spacing between the title and the sub slogan
            if (subTitle != '')
              Text(
                subTitle,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight:
                      FontWeight.w500, // Medium weight for a balanced look
                  color: Colors.grey, // Soft color for a secondary emphasis
                  fontStyle: FontStyle.italic, // Add italic for a graceful look
                ),
              ),
          ],
        ),
      ]),
    );
  }
}
