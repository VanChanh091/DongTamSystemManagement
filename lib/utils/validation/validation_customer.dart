import 'package:diacritic/diacritic.dart';
import 'package:dongtam/data/controller/theme_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ValidationCustomer {
  static Widget validateInput({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    bool readOnly = false,
    bool checkId = false,
    String? externalError,
    Function(String)? onChanged,
  }) {
    return StatefulBuilder(
      builder: (context, setState) {
        controller.addListener(() {
          setState(() {}); // cập nhật color mỗi khi text thay đổi
        });

        final isFilled = controller.text.isEmpty;

        final themeController = Get.find<ThemeController>();

        final isCustomTheme = themeController.isThemeCustomized.value;
        final isCurrentColor = themeController.currentColor.value;
        final defaultFill = const Color.fromARGB(255, 148, 236, 154);

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
            errorText: externalError,
          ),
          onChanged: onChanged,
          validator: (value) {
            if (externalError != null) return externalError;

            final cleanValue = value?.trim().replaceAll(RegExp(r'[\r\n]+'), ' ') ?? '';
            final requiredFields = [
              'Mã khách hàng',
              "Tên khách hàng",
              "Tên công ty",
              "Địa chỉ công ty",
              "Địa chỉ giao hàng",
              "Hạn Mức Công Nợ",
              "Hạn Thanh Toán",
              "CSKH",
              "Nguồn Khách Hàng",
            ];

            if (requiredFields.contains(label) && cleanValue.isEmpty) {
              return 'Không được để trống';
            }

            //regex customerID
            if (label == 'Mã khách hàng' && value != null) {
              final withoutDiacritics = removeDiacritics(value);
              if (value != withoutDiacritics) {
                return "Mã khách hàng không được có dấu tiếng Việt";
              }

              if (checkId) {
                if (value.length < 10) {
                  return 'Mã khách hàng phải nhập 10 ký tự';
                } else if (value.length > 10) {
                  return 'Mã khách hàng vượt quá 10 ký tự';
                }

                if (value.length == 10) {
                  final lastChar = value.substring(value.length - 1);
                  if (RegExp(r'[0-9]').hasMatch(lastChar)) {
                    return "Ký tự cuối không được là số";
                  }
                }
              }

              final pattern = RegExp(r"^[a-zA-Z0-9]+$");
              if (!pattern.hasMatch(value)) {
                return "Mã khách hàng không được chứa ký tự đặc biệt";
              }
            }

            //check sdt
            if (label == "SDT" && value != null && value.isNotEmpty) {
              if (!RegExp(r'^\d+$').hasMatch(value.trim())) {
                return 'Số điện thoại chỉ được chứa chữ số';
              }
            }

            return null;
          },
        );
      },
    );
  }
}
