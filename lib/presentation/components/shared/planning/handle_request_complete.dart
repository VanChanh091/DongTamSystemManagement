import 'package:dongtam/presentation/components/shared/confirm_dialog.dart';
import 'package:dongtam/utils/handleError/api_exception.dart';
import 'package:dongtam/utils/handleError/show_snack_bar.dart';
import 'package:dongtam/utils/logger/app_logger.dart';
import 'package:flutter/widgets.dart';

Future<void> handlePlanningTask({
  required BuildContext context,
  required List selectedPlanningIds,
  required Future<bool> Function(List<int> ids) onExecute,
  required VoidCallback onLoadPlanning,
}) async {
  try {
    if (selectedPlanningIds.isEmpty) {
      showSnackBarError(context, 'Vui lòng chọn kế hoạch cần thao tác');
      return;
    }

    final confirm = await showConfirmDialog(
      context: context,
      title: "⚠️ Xác nhận",
      content: "Xác nhận yêu cầu hoàn thành kế hoạch này?",
      confirmText: "Ok",
      confirmColor: const Color(0xffEA4346),
    );

    if (confirm != true) return;

    if (!context.mounted) return;
    showLoadingDialog(context);

    // Xử lý IDs
    final ids =
        selectedPlanningIds.map((e) => int.tryParse(e.toString())).whereType<int>().toList();

    // Thực thi API
    final success = await onExecute(ids);

    if (success) {
      onLoadPlanning();
    }

    // Đóng loading và thông báo thành công
    if (context.mounted) {
      Navigator.of(context).pop(); // Tắt loading
      showSnackBarSuccess(context, "Yêu cầu thành công");
    }
  } on ApiException catch (e) {
    if (context.mounted) {
      if (Navigator.canPop(context)) Navigator.of(context).pop();
      final errorText = switch (e.errorCode) {
        'PLANNING_ALREADY_REQUESTED' => e.message!,
        'PLANNING_NO_PRODUCED_QUANTITY' => e.message!,
        _ => 'Có lỗi xảy ra, vui lòng thử lại',
      };
      showSnackBarError(context, errorText);
    }
  } catch (e, s) {
    if (context.mounted) {
      if (Navigator.canPop(context)) Navigator.of(context).pop();
      AppLogger.e("Error in planning task: $e", stackTrace: s);
      showSnackBarError(context, 'Có lỗi xảy ra, vui lòng thử lại');
    }
  }
}
