import 'package:flutter/material.dart';

class ValidationOrder {
  static Widget checkboxForBox(String label, ValueNotifier<bool> notifier) {
    return ValueListenableBuilder<bool>(
      valueListenable: notifier,
      builder: (context, checked, _) {
        return CheckboxListTile(
          title: Text(
            label,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          value: checked,
          onChanged: (bool? value) {
            notifier.value = value ?? false;
          },
          activeColor: Colors.red,
          checkColor: Colors.white,
        );
      },
    );
  }

  static Widget validateInput(
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
        fillColor: readOnly ? Colors.grey.shade300 : Colors.white,
        filled: true,
      ),
      validator: (value) {
        if ((label == "Mã Đơn Hàng" ||
                label == "Ngày nhận đơn hàng" ||
                label == "Ngày yêu cầu giao" ||
                label == "Mã Khách Hàng" ||
                label == "Mã Sản Phẩm" ||
                label == "Khổ" ||
                label == "Cắt" ||
                label == "Số lượng" ||
                label == "Đơn giá") &&
            (value == null || value.isEmpty)) {
          return 'Vui lòng nhập $label';
        }
        if (label == "Mã Đơn Hàng" && value!.length > 10) {
          return 'Mã đơn hàng chỉ được nhập tối đa 10 ký tự';
        }
        return null;
      },
      onTap: onTap,
    );
  }

  static Widget dropdownForTypes(
    List<String> items,
    String type,
    ValueChanged onChanged,
  ) {
    return DropdownButtonFormField<String>(
      value: items.contains(type) ? type : null,
      items:
          items.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Row(
                children: [
                  SizedBox(width: 10),
                  Text(
                    value,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
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
          borderSide: BorderSide(color: Colors.grey),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      icon: Icon(Icons.arrow_drop_down, color: Colors.black),
      style: TextStyle(fontSize: 16, color: Colors.black),
      dropdownColor: Colors.white,
      borderRadius: BorderRadius.circular(12),
    );
  }
}
