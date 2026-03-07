import 'dart:async';
import 'package:dongtam/utils/logger/app_logger.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

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
void _showOverlay(BuildContext? context, String message, Color backgroundColor, IconData icon) {
  // Ưu tiên dùng Overlay từ context, nếu không có thì dùng navigatorKey
  final overlay =
      (context != null ? Overlay.maybeOf(context) : null) ?? navigatorKey.currentState?.overlay;

  if (overlay == null) {
    AppLogger.w("Vẫn không tìm thấy Overlay! Kiểm tra lại việc gắn navigatorKey.");
    return;
  }

  late OverlayEntry overlayEntry;

  // Dùng context của navigator nếu context truyền vào bị null
  final effectiveContext = context ?? navigatorKey.currentContext!;

  overlayEntry = OverlayEntry(
    builder:
        (context) => Positioned(
          bottom: MediaQuery.of(effectiveContext).padding.bottom + 20,
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
