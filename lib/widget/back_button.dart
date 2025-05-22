import 'package:flutter/material.dart';

class CustomBackButton extends StatelessWidget {
  final Color? iconColor;
  final VoidCallback? onPressed;
  final String? label;

  const CustomBackButton({
    super.key,
    this.iconColor,
    this.onPressed,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios, size: 20),
            color: iconColor ?? Colors.black,
            onPressed: onPressed ?? () => Navigator.of(context).pop(),
          ),
          if (label != null)
            Text(
              label!,
              style: TextStyle(
                color: iconColor ?? Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
        ],
      ),
    );
  }
}
