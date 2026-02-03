import 'package:dongtam/data/controller/theme_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ValidationOrder {
  static Widget checkboxForBox({
    required String label,
    required ValueNotifier<bool> notifier,
    bool enabled = true,
  }) {
    return ValueListenableBuilder<bool>(
      valueListenable: notifier,
      builder: (context, checked, _) {
        return Theme(
          data: Theme.of(context).copyWith(
            checkboxTheme: CheckboxThemeData(
              fillColor: WidgetStateProperty.resolveWith<Color>((states) {
                if (states.contains(WidgetState.selected)) {
                  return Colors.red; // nền trắng khi chọn
                }
                return Colors.white; // nền trắng khi không chọn
              }),
              checkColor: WidgetStateProperty.all<Color>(Colors.white),
              side: const BorderSide(color: Colors.black, width: 1),
            ),
          ),
          child: CheckboxListTile(
            title: Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            value: checked,
            onChanged:
                enabled
                    ? (bool? value) {
                      notifier.value = value ?? false;
                    }
                    : null,
            controlAffinity: ListTileControlAffinity.leading,
            tileColor: Colors.transparent,
            contentPadding: EdgeInsets.zero,
          ),
        );
      },
    );
  }

  static Widget validateInput({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    bool readOnly = false,
    bool checkId = false,
    VoidCallback? onTap,
    bool enabled = true,
    bool isCalculate = false,
  }) {
    final FocusNode focusNode = FocusNode();

    return StatefulBuilder(
      builder: (context, setState) {
        if (isCalculate) {
          focusNode.addListener(() {
            if (!focusNode.hasFocus) {
              final text = controller.text.trim();
              final mathPattern = RegExp(r'^(\d+\.?\d*)\s*[\/*]\s*(\d+\.?\d*)$');

              if (mathPattern.hasMatch(text)) {
                final match = mathPattern.firstMatch(text);

                if (match != null) {
                  double val1 = double.parse(match.group(1)!);
                  double val2 = double.parse(match.group(2)!);

                  if (val2 != 0) {
                    double result = val1 / val2;

                    // Example: 113 / 2 is evaluated to 56.5
                    controller.text = result.toStringAsFixed(2).replaceAll(RegExp(r'\.0$'), '');
                    setState(() {});
                  }
                }
              }
            }
          });
        }

        controller.addListener(() {
          setState(() {}); // cập nhật color mỗi khi text thay đổi
        });

        final isFilled = controller.text.isEmpty;
        final effectiveReadOnly = readOnly || !enabled;

        final themeController = Get.find<ThemeController>();

        final isCustomTheme = themeController.isThemeCustomized.value;
        final isCurrentColor = themeController.currentColor.value;
        final defaultFill = const Color.fromARGB(255, 148, 236, 154);

        return TextFormField(
          controller: controller,
          focusNode: focusNode,
          style: const TextStyle(fontSize: 15),
          readOnly: effectiveReadOnly,
          decoration: InputDecoration(
            labelText: label,
            labelStyle: const TextStyle(fontWeight: FontWeight.bold),
            prefixIcon: Icon(icon),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            floatingLabelBehavior: FloatingLabelBehavior.always,
            fillColor:
                effectiveReadOnly
                    ? Colors.grey.shade300
                    : (isFilled ? Colors.white : (isCustomTheme ? isCurrentColor : defaultFill)),
            filled: true,
          ),
          validator: (value) {
            final cleanValue = value?.trim().replaceAll(RegExp(r'[\r\n]+'), ' ') ?? '';

            final requiredFields = [
              "Mã Đơn Hàng",
              "Ngày yêu cầu giao",
              "Số lượng (KH)",
              "Khổ khách đặt (cm)",
              "Số con",
              "Đơn giá (M2)",
            ];

            if (requiredFields.contains(label) && cleanValue.isEmpty) {
              return 'Không được để trống';
            }

            return null;
          },
          onTap: onTap,
        );
      },
    );
  }

  static Widget dropdownForTypes({
    required List<String> items,
    required String type,
    required ValueChanged onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: items.contains(type) ? type : null,
      items:
          items.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Row(
                children: [
                  const SizedBox(width: 10),
                  Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                ],
              ),
            );
          }).toList(),
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
      icon: const Icon(Icons.arrow_drop_down, color: Colors.black),
      style: const TextStyle(fontSize: 16, color: Colors.black),
      dropdownColor: Colors.white,
      borderRadius: BorderRadius.circular(12),
    );
  }
}
