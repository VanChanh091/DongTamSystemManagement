import 'package:dongtam/data/controller/unsaved_change_controller.dart';
import 'package:dongtam/utils/helper/warning_unsaved_change.dart';
import 'package:flutter/material.dart';

extension UnsavedChangeExtension on UnsavedChangeController {
  Future<void> runSafe(VoidCallback action) async {
    if (isUnsavedChanges.value) {
      final canLeave = await UnsavedChangeDialog(this);

      if (canLeave) {
        resetUnsavedChanges();
        action();
      }
    } else {
      action();
    }
  }
}

extension StringCleaningExtension on TextEditingController {
  /// Lấy text đã được trim, nếu rỗng thì trả về chuỗi rỗng
  String get trimmed => text.trim();

  /// Lấy text đã được trim và xóa khoảng trắng thừa ở giữa
  String get superClean => text.trim().replaceAll(RegExp(r'\s+'), ' ');
}
