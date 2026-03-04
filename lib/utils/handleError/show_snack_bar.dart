import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void showSnackBarSuccess(BuildContext context, String message) {
  _showOverlay(context, message, Colors.blue.shade500, Icons.check_circle_outline);
}

void showSnackBarError(BuildContext context, String message) {
  _showOverlay(context, message, Colors.red.shade600, Icons.error_outline);
}

//helper
void showError(BuildContext context, String message) {
  _showOverlay(context, message, Colors.red.shade600, Icons.error_outline);
}

// Hàm core xử lý Overlay
void _showOverlay(BuildContext context, String message, Color backgroundColor, IconData icon) {
  final overlay = Overlay.of(context);
  late OverlayEntry overlayEntry;

  overlayEntry = OverlayEntry(
    builder:
        (context) => Positioned(
          bottom: MediaQuery.of(context).padding.bottom + 20,
          left: 20,
          right: 20,
          child: Material(
            color: Colors.transparent,
            child: TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 350),
              tween: Tween(begin: 0.0, end: 1.0),
              builder: (context, value, child) {
                return Opacity(
                  opacity: value,
                  child: Transform.translate(
                    offset: Offset(0, (1 - value) * 20), // Trượt từ dưới lên
                    child: child,
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [
                    BoxShadow(color: Colors.black26, blurRadius: 12, offset: Offset(0, 4)),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(icon, color: Colors.white, size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        message,
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
  );

  overlay.insert(overlayEntry);

  // Tự động đóng sau 2 giây
  Timer(const Duration(milliseconds: 2000), () {
    if (overlayEntry.mounted) {
      overlayEntry.remove();
    }
  });
}
