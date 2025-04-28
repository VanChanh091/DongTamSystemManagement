import 'package:flutter/material.dart';

class ValidationCustomer {
  static Widget validateInput(
    String label,
    TextEditingController controller,
    IconData icon, {
    bool readOnly = false,
  }) {
    return TextFormField(
      controller: controller,
      readOnly: readOnly,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        fillColor: readOnly ? Colors.grey.shade300 : Colors.white,
        filled: true,
      ),
      validator: (value) {
        if ((label == 'Mã Khách hàng' ||
                label == "Tên khách hàng" ||
                label == "Tên công ty" ||
                label == "Địa chỉ công ty" ||
                label == "Địa chỉ giao hàng" ||
                label == "CSKH") &&
            (value == null || value.isEmpty)) {
          return 'Vui lòng nhập $label';
        }
        if (label == "SDT" && value != null && value.isNotEmpty) {
          if (!RegExp(r'^\d+$').hasMatch(value)) {
            return 'Số điện thoại chỉ được chứa chữ số';
          }
        }
        if (label == "MST" && value != null && value.isNotEmpty) {
          if (!RegExp(r'^\d+$').hasMatch(value)) {
            return 'Mã số thuế chỉ được chứa chữ số';
          }
        }

        return null;
      },
    );
  }
}
