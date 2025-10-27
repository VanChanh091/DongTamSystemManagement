import 'package:flutter/material.dart';

class ValidationEmployee {
  static Widget validateInput({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    bool readOnly = false,
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

        if ((label == 'Mã khách hàng') && (value == null || value.isEmpty)) {
          return 'Vui lòng nhập $label';
        }

        return null;
      },
    );
  }
}
