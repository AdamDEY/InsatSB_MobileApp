import 'package:flutter/material.dart';

class LinkedInButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String? text;

  const LinkedInButton({
    super.key,
    this.onPressed,
    this.text,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF0077B5), // LinkedIn blue
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // LinkedIn icon
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Icon(
                Icons.business,
                color: Color(0xFF0077B5),
                size: 16,
              ),
            ),
            const SizedBox(width: 12),
            // Text
            Text(
              text ?? 'LinkedIn',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 8),
            // Arrow icon
            const Icon(
              Icons.arrow_forward,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}
