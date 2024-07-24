import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final Color backgroundColor;
  final Color textColor;
  final double fontSize;
  final bool hasBorder;
  final Color borderColor;
  final double borderWidth;

  const CustomButton({
    Key? key,
    required this.label,
    required this.onPressed,
    required this.backgroundColor,
    required this.textColor,
    this.fontSize = 16.0,
    this.hasBorder = false,
    this.borderColor = Colors.transparent,
    this.borderWidth = 1.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(10.0),
          border: hasBorder ? Border.all(color: borderColor, width: borderWidth) : null,
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            color: textColor,
            fontSize: fontSize,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
