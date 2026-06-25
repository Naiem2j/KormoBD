import 'package:flutter/material.dart';
import '../core/constants/colors.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  final bool isLoading;
  final double height;
  final Color? color;

  const CustomButton({
    super.key,
    required this.text,
    required this.onTap,
    this.isLoading = false,
    this.height = 50,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final btnColor = color ?? AppColors.primary;

    return SizedBox(
      width: double.infinity,
      height: height,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: btnColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        onPressed: isLoading ? null : onTap,
        child: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Text(text, style: const TextStyle(color: Colors.white)),
      ),
    );
  }
}
