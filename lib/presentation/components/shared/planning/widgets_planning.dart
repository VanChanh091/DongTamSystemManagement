import 'package:dongtam/presentation/components/shared/animated_button.dart';
import 'package:dongtam/utils/handleError/api_exception.dart';
import 'package:dongtam/utils/handleError/show_snack_bar.dart';
import 'package:dongtam/presentation/components/shared/confirm_dialog.dart';
import 'package:dongtam/utils/helper/planning_helper.dart';
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
        buildLabelAndUnderlineInput(
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
        buildLabelAndUnderlineInput(
          label: "Giờ bắt đầu:",
          controller: timeStartController,
          width: 60,
        ),
        const SizedBox(width: 32),

        // Tổng giờ làm
        buildLabelAndUnderlineInput(
          label: "Tổng giờ làm:",
          controller: totalTimeWorkingController,
          width: 40,
          inputType: TextInputType.number,
        ),
      ],
    ),
  );
}

Widget buildLabelAndUnderlineInput({
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
      _buildRepeatableButton(icon: Icons.arrow_upward, enabled: enabled, onAction: onMoveUp),
      const SizedBox(width: 8),
      _buildRepeatableButton(icon: Icons.arrow_downward, enabled: enabled, onAction: onMoveDown),
    ],
  );
}

Widget _buildRepeatableButton({
  required IconData icon,
  required bool enabled,
  required VoidCallback onAction,
}) {
  final isHovered = ValueNotifier<bool>(false);
  final isPressed = ValueNotifier<bool>(false);

  return MouseRegion(
    onEnter: (_) => enabled ? isHovered.value = true : null,
    onExit: (_) => enabled ? isHovered.value = false : null,
    cursor: enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
    child: GestureDetector(
      onTapDown:
          enabled
              ? (_) {
                isPressed.value = true;
                PlanningListHelper.startContinuousAction(onAction);
              }
              : null,
      onTapUp: (_) {
        isPressed.value = false;
        PlanningListHelper.stopContinuousAction();
      },
      onTapCancel: () {
        isPressed.value = false;
        PlanningListHelper.stopContinuousAction();
      },
      child: ValueListenableBuilder(
        valueListenable: isHovered,
        builder: (context, hovered, _) {
          return ValueListenableBuilder(
            valueListenable: isPressed,
            builder: (context, pressed, _) {
              double scale = !enabled ? 1.0 : (pressed ? 0.9 : (hovered ? 1.05 : 1.0));

              return AnimatedScale(
                scale: scale,
                duration: const Duration(milliseconds: 100),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color:
                        enabled
                            ? (hovered
                                ? Colors.blue.withValues(alpha: 0.2)
                                : Colors.blue.withValues(alpha: 0.1))
                            : Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color:
                          hovered && enabled
                              ? Colors.blue.withValues(alpha: 0.3)
                              : Colors.transparent,
                    ),
                  ),
                  child: Icon(icon, color: enabled ? Colors.blue : Colors.grey, size: 20),
                ),
              );
            },
          );
        },
      ),
    ),
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

      final ids = selectedIds.map((e) => int.tryParse(e.toString())).whereType<int>().toList();

      try {
        final success = await onConfirmComplete(ids);
        if (success) {
          onReload();
        }

        if (!context.mounted) return;
        Navigator.of(context).pop();
        showSnackBarSuccess(context, "Thao tác thành công");
      } on ApiException catch (e) {
        Navigator.of(context).pop();

        final errorText = switch (e.errorCode) {
          'LACK_QUANTITY' => 'Chưa đủ số lượng để hoàn thành',
          'PLANNING_NOT_FINALIZED' => e.message!,
          _ => 'Có lỗi xảy ra, vui lòng thử lại',
        };

        showSnackBarError(context, errorText);
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

Widget buildDropdownItems({
  required String value,
  required List<String> items,
  required void Function(String?) onChanged,
  String Function(String)? itemLabelBuilder,
  double width = 175,
}) {
  return SizedBox(
    width: width,
    child: DropdownButtonFormField<String>(
      value: value,
      items:
          items
              .map(
                (String v) => DropdownMenuItem<String>(
                  value: v,
                  child: Text(itemLabelBuilder != null ? itemLabelBuilder(v) : v),
                ),
              )
              .toList(),
      onChanged: onChanged,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    ),
  );
}
