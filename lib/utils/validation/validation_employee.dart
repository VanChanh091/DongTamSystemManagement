import 'package:dongtam/data/controller/theme_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ValidationEmployee {
  static Widget validateInput({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    bool readOnly = false,
    VoidCallback? onTap,
    String? externalError,
    Function(String)? onChanged,
  }) {
    return StatefulBuilder(
      builder: (context, setState) {
        controller.addListener(() {
          setState(() {}); // cập nhật mỗi khi text thay đổi
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
          onTap: onTap,
          onChanged: onChanged,
          validator: (value) {
            if (externalError != null) return externalError;

            String cleanValue = "";

            if (value != null) {
              // xoá khoảng trắng 2 đầu + dấu xuống dòng
              cleanValue = value.trim().replaceAll(RegExp(r'[\r\n]+'), ' ');
              controller.text = value;
            }

            final requiredFields = [
              'Tên Nhân Viên',
              'Số Điện Thoại',
              "Dân Tộc",
              "Ngày Sinh",
              "Ngày Vào Làm",
              'Trình Độ Văn Hóa',
              'Số CCCD',
              'Ngày Cấp',
              'Nơi Cấp',
              'Ngày Cấp',
              'ĐC Thường Trú',
              'Mã Nhân Viên',
              'Chức Vụ',
              'Mã Nhân Viên',
            ];

            if (requiredFields.contains(label) && cleanValue.isEmpty) {
              return 'Không được để trống';
            }

            //label: Số Điện Thoại, Số Liên Hệ Khẩn Cấp, Số CCCD chỉ chấp nhận chữ số
            if ((label == 'Số Điện Thoại' ||
                    label == 'Số Liên Hệ Khẩn Cấp' ||
                    label == 'Số CCCD') &&
                !RegExp(r'^\d+$').hasMatch(value!)) {
              return '$label chỉ được chứa chữ số';
            }

            return null;
          },
        );
      },
    );
  }
}
