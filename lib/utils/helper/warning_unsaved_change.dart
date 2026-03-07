import 'package:dongtam/data/controller/unsaved_change_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

Future<bool> UnsavedChangeDialog(UnsavedChangeController ctrl) async {
  if (!ctrl.isUnsavedChanges.value) return true;

  final result = await Get.dialog<bool>(
    AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text("Cảnh báo", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
      content: const Text(
        "Bạn có thay đổi chưa lưu. Rời trang sẽ mất dữ liệu.",
        style: TextStyle(fontWeight: FontWeight.w400, fontSize: 16),
      ),
      actions: [
        TextButton(
          onPressed: () => Get.back(result: false),
          child: const Text(
            "Ở lại",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black54),
          ),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xffEA4346),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          onPressed: () {
            ctrl.resetUnsavedChanges();
            Get.back(result: true);
          },
          child: const Text("Rời đi", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ),
      ],
    ),
    barrierDismissible: false,
  );
  return result ?? false;
}
