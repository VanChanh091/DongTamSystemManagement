import 'dart:async';
import 'package:dongtam/utils/logger/app_logger.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
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

  overlayEntry = OverlayEntry(
    builder:
        (innerContext) => Positioned(
          bottom: (MediaQuery.maybeOf(innerContext)?.padding.bottom ?? 0) + 20,
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
  Timer(const Duration(milliseconds: 2500), () {
    if (overlayEntry.mounted) {
      overlayEntry.remove();
    }
  });
}

//show notification banner
void showNotificationBanner({required String title, required String message, VoidCallback? onTap}) {
  Get.snackbar(
    '',
    '',
    snackPosition: SnackPosition.TOP,
    duration: const Duration(seconds: 3),
    animationDuration: const Duration(milliseconds: 300),

    maxWidth: 500,
    borderRadius: 12,
    margin: const EdgeInsets.only(top: 10),
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),

    backgroundColor: const Color(0xFFEFF6FF), // Xanh dương pastel sáng nhẹ
    borderColor: const Color(0xFFBFDBFE), // Đường viền xanh tươi tinh tế
    borderWidth: 1,
    boxShadows: [
      BoxShadow(
        color: const Color(0xFF1E40AF).withValues(alpha: 0.12),
        blurRadius: 16,
        offset: const Offset(0, 4),
      ),
    ],

    icon: Padding(
      padding: const EdgeInsets.only(left: 10, right: 8),
      child: Container(
        width: 40,
        height: 40,
        alignment: Alignment.center,
        decoration: const BoxDecoration(color: Color(0xFF2563EB), shape: BoxShape.circle),
        child: const Icon(Icons.notifications_active_rounded, color: Colors.white, size: 18),
      ),
    ),

    titleText: Text(
      title,
      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF1E3A8A)),
    ),

    messageText: Text(
      message,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(fontSize: 13, color: Color(0xFF2563EB), height: 1.2),
    ),

    onTap: (_) {
      if (Get.isSnackbarOpen) Get.closeCurrentSnackbar();
      if (onTap != null) onTap();
    },
  );
}
