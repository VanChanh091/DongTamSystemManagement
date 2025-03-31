import 'package:flutter/material.dart';

class ValidationOrder {
  static checkboxForBox(String label, bool checked) {
    return StatefulBuilder(
      builder: (context, setState) {
        return CheckboxListTile(
          title: Text(
            label,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          value: checked,
          onChanged: (bool? value) {
            setState(() {
              checked = value!;
            });
          },
          activeColor: Colors.red,
          checkColor: Colors.white,
        );
      },
    );
  }

  static validateInput(
    String label,
    TextEditingController controller,
    IconData icon, {
    bool readOnly = false,
    VoidCallback? onTap,
  }) {
    return TextFormField(
      controller: controller,
      readOnly: readOnly,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        fillColor: readOnly ? Colors.grey.shade200 : Colors.white,
        filled: true,
      ),
      validator: (value) {
        if ((label == "Mã Đơn Hàng" ||
                label == "Loại sản phẩm" ||
                label == "Ngày nhận đơn hàng" ||
                label == "Ngày yêu cầu giao" ||
                label == "Mã Khách Hàng" ||
                label == "Khổ" ||
                label == "Cắt" ||
                label == "Số lượng" ||
                label == "Đơn vị tính" ||
                label == "Đơn giá" ||
                label == "Giá tấm" ||
                label == "Khổ tấm" ||
                label == "Số lượng" ||
                label == "Số con") &&
            (value == null || value.isEmpty)) {
          return 'Vui lòng nhập $label';
        }
        return null;
      },

      onTap: onTap,
    );
  }
}
