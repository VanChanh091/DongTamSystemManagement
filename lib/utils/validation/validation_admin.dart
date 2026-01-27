import 'package:dongtam/data/controller/theme_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ValidationAdmin {
  static Widget validateInput({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    bool readOnly = false,
    bool checkId = false,
    VoidCallback? onTap,
  }) {
    return StatefulBuilder(
      builder: (context, setState) {
        controller.addListener(() {
          setState(() {}); // cập nhật color mỗi khi text thay đổi
        });

        final themeController = Get.find<ThemeController>();

        final isFilled = controller.text.isEmpty;

        final isCustomTheme = themeController.isThemeCustomized.value;
        final isCurrentColor = themeController.currentColor.value;
        final defaultFill = const Color.fromARGB(255, 148, 236, 154);

        return TextFormField(
          controller: controller,
          readOnly: readOnly,
          decoration: InputDecoration(
            labelText: label,
            labelStyle: TextStyle(fontWeight: FontWeight.bold),
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
          onTap: onTap,
        );
      },
    );
  }
}
