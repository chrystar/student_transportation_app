import 'package:flutter/material.dart';
import 'app_colors.dart';


class Button extends StatelessWidget {
  Button({
    super.key,
    this.width,
    required this.onPressed,
    required this.text,
    this.color = AppColor.primaryElement,
    this.textColor = Colors.white,
    this.borderColor = Colors.transparent,
  });

  double? width;
  VoidCallback onPressed;
  String text;
  Color color;
  Color textColor;
  Color borderColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: 50,
      decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 2,
              offset: const Offset(0, 1),
            )
          ],
          border: Border.all(color: borderColor)
      ),
      child: TextButton(
        onPressed: onPressed,
        child: Text(
          text,
          style: TextStyle(
            color: textColor,
            fontSize: 16,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    );
  }
}
