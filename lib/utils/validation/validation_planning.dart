import 'package:dongtam/data/controller/theme_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ValidationPlanning {
  static Widget validateInput({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    bool readOnly = false,
    bool checkId = false,
    VoidCallback? onTap,

    TextEditingController? quantityOrderController,
    int? qtyProduced,
  }) {
    return StatefulBuilder(
      builder: (context, setState) {
        controller.addListener(() {
          setState(() {}); // cập nhật color mỗi khi text thay đổi
        });

        final isFilled = controller.text.isEmpty;

        final themeController = Get.find<ThemeController>();

        final isCurrentColor = themeController.currentColor.value;
        final defaultFill = const Color.fromARGB(255, 148, 236, 154);
        final isCustomTheme = themeController.isThemeCustomized.value;

        return TextFormField(
          controller: controller,
          readOnly: readOnly,
          decoration: InputDecoration(
            labelText: label,
            labelStyle: const TextStyle(fontWeight: FontWeight.bold),
            prefixIcon: Icon(icon),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            floatingLabelBehavior: FloatingLabelBehavior.always,
            fillColor:
                readOnly
                    ? Colors.grey.shade300
                    : (isFilled ? Colors.white : (isCustomTheme ? isCurrentColor : defaultFill)),
            filled: true,
          ),
          validator: (value) {
            if (label == "Ghép Khổ") {
              if (value == null || value.isEmpty) {
                return 'Không được để trống';
              } else if (value == "0") {
                return "Ghép khổ phải lớn hơn 0";
              } else if (!RegExp(r'^\d+$').hasMatch(value)) {
                return "Ghép Khổ chỉ được chứa số";
              }
            } else if (label == "Kế hoạch chạy") {
              if (quantityOrderController != null && qtyProduced != null) {
                final runningPlan = int.parse(value ?? "");
                final quantityOrder = int.tryParse(quantityOrderController.text) ?? 0;

                if (runningPlan <= 0) {
                  return "Kế hoạch chạy phải lớn hơn 0";
                }

                // case 1: chưa có lần sx
                if (qtyProduced == 0) {
                  if (runningPlan > quantityOrder) {
                    return "Không được vượt quá số lượng đơn hàng";
                  }
                }
                // case 2: đã có lần sx
                else {
                  if (runningPlan + qtyProduced > quantityOrder) {
                    return "Vượt quá số lượng đơn hàng";
                  }
                }
              }
            }
            return null;
          },
          onTap: onTap,
        );
      },
    );
  }

  static Widget dropdownForLayerType({
    required List<String> items,
    required String type,
    required Map<String, String> labels,
    required ValueChanged<String?> onChanged,
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
                  Text(
                    labels[value] ?? value,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
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
