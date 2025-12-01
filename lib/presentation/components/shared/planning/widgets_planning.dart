import 'package:dongtam/presentation/components/shared/animated_button.dart';
import 'package:dongtam/utils/handleError/show_snack_bar.dart';
import 'package:dongtam/utils/helper/confirm_dialog.dart';
import 'package:dongtam/utils/logger/app_logger.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

Widget timeAndDayPlanning({
  required BuildContext context,
  required TextEditingController dayStartController,
  required TextEditingController timeStartController,
  required TextEditingController totalTimeWorkingController,
}) {
  return Padding(
    padding: const EdgeInsets.only(left: 12),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Ngày bắt đầu
        _buildLabelAndUnderlineInput(
          label: "Ngày bắt đầu:",
          controller: dayStartController,
          width: 120,
          readOnly: true,
          onTap: () async {
            final selected = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime.now(),
              lastDate: DateTime(2100),
              builder: (BuildContext context, Widget? child) {
                return Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: ColorScheme.light(
                      primary: Colors.blue,
                      onPrimary: Colors.white,
                      onSurface: Colors.black,
                    ),
                    dialogTheme: DialogThemeData(backgroundColor: Colors.white12),
                  ),
                  child: child!,
                );
              },
            );
            if (selected != null) {
              dayStartController.text =
                  "${selected.day.toString().padLeft(2, '0')}/"
                  "${selected.month.toString().padLeft(2, '0')}/"
                  "${selected.year}";
            }
          },
        ),
        const SizedBox(width: 32),

        // Giờ bắt đầu
        _buildLabelAndUnderlineInput(
          label: "Giờ bắt đầu:",
          controller: timeStartController,
          width: 60,
        ),
        const SizedBox(width: 32),

        // Tổng giờ làm
        _buildLabelAndUnderlineInput(
          label: "Tổng giờ làm:",
          controller: totalTimeWorkingController,
          width: 40,
          inputType: TextInputType.number,
        ),
      ],
    ),
  );
}

Widget _buildLabelAndUnderlineInput({
  required String label,
  required TextEditingController controller,
  required double width,
  TextInputType? inputType,
  void Function()? onTap,
  bool readOnly = false,
}) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      Text(label, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 16)),
      const SizedBox(width: 8),
      SizedBox(
        width: width,
        child: TextFormField(
          controller: controller,
          keyboardType: inputType ?? TextInputType.text,
          readOnly: readOnly,
          decoration: InputDecoration(
            isDense: true,
            border: UnderlineInputBorder(),
            contentPadding: const EdgeInsets.symmetric(vertical: 5),
            hintText: '',
          ),
          onTap: onTap,
        ),
      ),
    ],
  );
}

//button up/down planning
Widget rowMoveButtons({
  required bool enabled,
  required VoidCallback onMoveUp,
  required VoidCallback onMoveDown,
}) {
  return Row(
    children: [
      IconButton(icon: const Icon(Icons.arrow_upward), onPressed: enabled ? onMoveUp : null),
      IconButton(icon: const Icon(Icons.arrow_downward), onPressed: enabled ? onMoveDown : null),
    ],
  );
}

Widget confirmCompleteButton({
  required BuildContext context,
  required List<String> selectedIds,
  required Future<bool> Function(List<int> ids) onConfirmComplete,
  required VoidCallback onReload,
  required Rx<Color> backgroundColor,
}) {
  return AnimatedButton(
    onPressed: () async {
      if (selectedIds.isEmpty) {
        showSnackBarError(context, 'Vui lòng chọn kế hoạch cần thao tác');
        return;
      }

      final confirm = await showConfirmDialog(
        context: context,
        title: "⚠️ Xác nhận",
        content: "Xác nhận hoàn thành kế hoạch này?",
        confirmText: "Ok",
        confirmColor: const Color(0xffEA4346),
      );

      if (!confirm) return;

      if (!context.mounted) return;
      showLoadingDialog(context);

      try {
        final ids = selectedIds.map((e) => int.tryParse(e.toString())).whereType<int>().toList();

        final success = await onConfirmComplete(ids);
        if (success) {
          onReload();
        }

        if (!context.mounted) return;
        Navigator.of(context).pop();
        showSnackBarSuccess(context, "Thao tác thành công");
      } catch (e, s) {
        if (context.mounted) Navigator.of(context).pop();
        AppLogger.e("Error in update status planning: $e", stackTrace: s);

        if (context.mounted) {
          showSnackBarError(context, 'Có lỗi xảy ra, vui lòng thử lại');
        }
      }
    },
    label: "Hoàn Thành",
    icon: Symbols.check,
    backgroundColor: backgroundColor,
  );
}
