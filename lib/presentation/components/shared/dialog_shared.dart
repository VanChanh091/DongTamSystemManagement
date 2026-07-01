import 'package:dongtam/utils/handleError/api_exception.dart';
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
  String? confirmText = "Xoá",
}) async {
  final confirm = await showConfirmDialog(
    context: context,
    title: title,
    content: content,
    confirmText: confirmText ?? "Xoá",
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
  } on ApiException catch (e) {
    switch (e.errorCode) {
      case "CUSTOMER_HAS_ORDERS":
        showSnackBarError(context, e.message!);
        break;
      case "PRODUCT_HAS_ORDERS":
        showSnackBarError(context, e.message!);
        break;
      default:
        showSnackBarError(context, 'Có lỗi xảy ra, vui lòng thử lại');
    }

    Navigator.pop(context);
  } catch (e, s) {
    Navigator.pop(context);
    AppLogger.e(errorMessage, error: e, stackTrace: s);
    showSnackBarError(context, errorMessage);
  }
}

Future<bool?> showInputQtyDialog({
  required BuildContext context,
  required String title,
  required String labelText,
  required TextEditingController controller,
  required Future<bool> Function() onConfirm,
  int? maxLines = 1,
  String? prefixText,
  String? Function(String?)? validator,
  TextInputType keyboardType = TextInputType.text,

  // Cấu hình cho Field 2 (Optional)
  String? labelText2,
  TextEditingController? controller2,
}) async {
  final formKey = GlobalKey<FormState>();
  bool isLoading = false;

  return showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
            content: SizedBox(
              width: 350,
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: controller,
                      keyboardType: keyboardType,
                      maxLines: maxLines,
                      decoration: InputDecoration(
                        labelText: labelText,
                        labelStyle: TextStyle(fontSize: 15),
                        prefixText: prefixText,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) return "Không được để trống";

                        if (validator != null) {
                          return validator(value);
                        }
                        return null;
                      },
                    ),

                    if (controller2 != null) ...[
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: controller2,
                        maxLines: 3,
                        decoration: InputDecoration(
                          labelText: labelText2,
                          labelStyle: TextStyle(fontSize: 15),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: isLoading ? null : () => Navigator.pop(context),
                child: const Text(
                  "Hủy",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black54,
                  ),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xffEA4346),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed:
                    isLoading
                        ? null
                        : () async {
                          if (formKey.currentState!.validate()) {
                            setState(() {
                              isLoading = true;
                            });
                            final success = await onConfirm();
                            if (context.mounted) {
                              if (success) {
                                Navigator.pop(context, true);
                              } else {
                                setState(() {
                                  isLoading = false;
                                });
                              }
                            }
                          }
                        },
                child:
                    isLoading
                        ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                        : const Text(
                          'Xác nhận',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
              ),
            ],
          );
        },
      );
    },
  );
}
