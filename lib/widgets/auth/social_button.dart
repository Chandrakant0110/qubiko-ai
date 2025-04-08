import 'package:flutter/material.dart';

class SocialButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String iconPath;
  final String? label;
  final double width;
  final double height;
  final double iconSize;

  const SocialButton({
    super.key,
    required this.onPressed,
    required this.iconPath,
    this.label,
    this.width = 110,
    this.height = 60,
    this.iconSize = 24,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: label != null ? double.infinity : width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onPressed,
          child: Center(
            child: label != null
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        iconPath,
                        width: iconSize,
                        height: iconSize,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        label!,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF424242),
                        ),
                      ),
                    ],
                  )
                : Image.asset(
                    iconPath,
                    width: iconSize,
                    height: iconSize,
                  ),
          ),
        ),
      ),
    );
  }
}
