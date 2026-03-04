import 'dart:async';
import 'package:flutter/foundation.dart';

class PlanningListHelper {
  static Timer? _repeatTimer;
  static Timer? _delayTimer;

  static void moveRows<T>({
    required List<T> list,
    required List<String> idsToMove,
    required String Function(T) getId,
    required bool moveUp,
    required VoidCallback onUpdate, // Callback gọi buildDataGridRows()
    dynamic unsavedChangeController,
  }) {
    if (idsToMove.isEmpty) return;

    // Thông báo có thay đổi chưa lưu
    unsavedChangeController?.setUnsavedChanges(value: true);

    // Lấy danh sách các item được chọn và sắp xếp theo thứ tự hiện tại trong list
    List<T> selectedItems = list.where((p) => idsToMove.contains(getId(p))).toList();
    selectedItems.sort((a, b) => list.indexOf(a).compareTo(list.indexOf(b)));

    if (moveUp) {
      int minIndex = list.indexOf(selectedItems.first);
      if (minIndex <= 0) return;

      // Xóa và chèn lại
      for (var item in selectedItems) {
        list.remove(item);
      }

      list.insertAll(minIndex - 1, selectedItems);
    } else {
      int maxIndex = list.indexOf(selectedItems.last);
      if (maxIndex == -1 || maxIndex >= list.length - 1) return;

      // Lấy phần tử ngay sau khối được chọn để làm mốc
      T elementAfterBlock = list[maxIndex + 1];

      // Xóa các phần tử được chọn
      for (var item in selectedItems) {
        list.remove(item);
      }

      // Tìm vị trí mới của phần tử mốc và chèn vào sau nó
      int anchorIndex = list.indexOf(elementAfterBlock);
      list.insertAll(anchorIndex + 1, selectedItems);
    }

    // Cập nhật UI
    onUpdate();
  }

  static void startContinuousAction(VoidCallback action) {
    // Dừng các timer cũ nếu có
    stopContinuousAction();

    action();

    // 2. Sau 500ms nếu vẫn giữ, thì bắt đầu lặp lại mỗi 100ms
    _delayTimer = Timer(const Duration(milliseconds: 500), () {
      _repeatTimer = Timer.periodic(const Duration(milliseconds: 150), (timer) {
        action();
      });
    });
  }

  static void stopContinuousAction() {
    _delayTimer?.cancel();
    _repeatTimer?.cancel();
    _delayTimer = null;
    _repeatTimer = null;
  }
}
