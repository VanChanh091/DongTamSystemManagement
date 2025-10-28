import 'package:dongtam/data/models/employee/employee_basic_info.dart';
import 'package:flutter/material.dart';

class ValidationEmployee {
  static Widget validateInput({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    bool readOnly = false,
    List<EmployeeBasicInfo>? allEmployees,
    int? currentEmployeeId,
  }) {
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
        fillColor: readOnly ? Colors.grey.shade300 : Colors.white,
        filled: true,
      ),
      validator: (value) {
        if (value != null) {
          // xoá khoảng trắng 2 đầu + dấu xuống dòng
          value = value.trim().replaceAll(RegExp(r'[\r\n]+'), ' ');
          controller.text = value;
        }

        if ((label == 'Tên Nhân Viên' ||
                label == 'Số Điện Thoại' ||
                label == 'Ngày Sinh' ||
                label == 'Trình Độ Văn Hóa' ||
                label == 'Số CCCD' ||
                label == 'Ngày Cấp' ||
                label == 'Nơi Cấp' ||
                label == 'ĐC Thường Trú' ||
                label == 'ĐC Tạm Trú' ||
                label == 'Mã Nhân Viên' ||
                label == 'Số Liên Hệ Khẩn Cấp' ||
                label == 'Trạng Thái Làm Việc') &&
            (value == null || value.isEmpty)) {
          return 'Vui lòng nhập $label';
        }

        //label: Số Điện Thoại, Số Liên Hệ Khẩn Cấp, Số CCCD chỉ chấp nhận chữ số
        if ((label == 'Số Điện Thoại' || label == 'Số Liên Hệ Khẩn Cấp' || label == 'Số CCCD') &&
            !RegExp(r'^\d+$').hasMatch(value!)) {
          return '$label chỉ được chứa chữ số';
        }

        if (label == 'Mã Nhân Viên' && value != null && value.isNotEmpty) {
          final trimmed = value.replaceAll(RegExp(r'\s+'), '');

          final isDuplicate =
              allEmployees?.any((e) {
                if (currentEmployeeId != null && e.employeeId == currentEmployeeId) {
                  return false;
                }

                final employeeCode = e.companyInfo!.employeeCode.replaceAll(RegExp(r'\s+'), '');
                if (employeeCode.isEmpty) {
                  return false;
                }

                return employeeCode == trimmed.toUpperCase();
              }) ??
              false;

          if (isDuplicate) {
            return "Mã nhân viên đã tồn tại";
          }

          controller.text = trimmed;
        }

        return null;
      },
    );
  }
}
