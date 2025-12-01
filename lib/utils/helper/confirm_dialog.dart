import 'package:dongtam/utils/handleError/show_snack_bar.dart';
import 'package:dongtam/utils/logger/app_logger.dart';
import 'package:flutter/material.dart';

Future<bool> showConfirmDialog({
  required BuildContext context,
  required String title,
  required String content,
  required String confirmText,
  String cancelText = "Hủy",
  Color confirmColor = const Color(0xffEA4346),
}) async {
  final result = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder:
        (_) => AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
          content: Text(content, style: const TextStyle(fontWeight: FontWeight.w400, fontSize: 16)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(
                cancelText,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black54,
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: confirmColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () => Navigator.pop(context, true),
              child: Text(
                confirmText,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
  );

  return result ?? false;
}

Future<void> showLoadingDialog(BuildContext context, {String message = "Đang xử lý..."}) async {
  await showGeneralDialog(
    context: context,
    barrierDismissible: false,
    barrierLabel: "Loading",
    transitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (context, _, _) {
      return Center(
        child: AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          content: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(strokeWidth: 2),
              const SizedBox(width: 12),
              Flexible(child: Text(message, style: const TextStyle(fontSize: 16))),
            ],
          ),
        ),
      );
    },

    // 💫 Animation: fade + scale
    transitionBuilder: (_, animation, _, child) {
      return Transform.scale(
        scale: Curves.easeOutBack.transform(animation.value),
        child: Opacity(opacity: animation.value, child: child),
      );
    },
  );
}

Future<void> showDeleteConfirmHelper({
  required BuildContext context,
  required String title,
  required String content,
  required Future<void> Function() onDelete,
  required VoidCallback onSuccess,
  String loadingMessage = "Đang xoá...",
  String successMessage = "Xoá thành công",
  String errorMessage = "Lỗi khi xoá",
}) async {
  final confirm = await showConfirmDialog(
    context: context,
    title: title,
    content: content,
    confirmText: "Xoá",
    confirmColor: const Color(0xffEA4346),
  );

  if (!confirm) return;

  //show deleteing dialog
  if (!context.mounted) return;
  showLoadingDialog(context, message: loadingMessage);

  try {
    await onDelete();
    await Future.delayed(const Duration(milliseconds: 600));

    if (!context.mounted) return;
    Navigator.pop(context);

    showSnackBarSuccess(context, successMessage);

    onSuccess();
  } catch (e, s) {
    Navigator.pop(context);
    AppLogger.e(errorMessage, error: e, stackTrace: s);
    showSnackBarError(context, errorMessage);
  }
}
