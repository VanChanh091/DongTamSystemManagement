import 'package:flutter/material.dart';

class ValidationOrder {
  static Widget checkboxForBox(String label, ValueNotifier<bool> notifier) {
    return ValueListenableBuilder<bool>(
      valueListenable: notifier,
      builder: (context, checked, _) {
        return Theme(
          data: Theme.of(context).copyWith(
            checkboxTheme: CheckboxThemeData(
              fillColor: MaterialStateProperty.resolveWith<Color>((states) {
                if (states.contains(MaterialState.selected)) {
                  return Colors.red; // nền trắng khi chọn
                }
                return Colors.white; // nền trắng khi không chọn
              }),
              checkColor: MaterialStateProperty.all<Color>(Colors.white),
              side: BorderSide(color: Colors.black, width: 1),
            ),
          ),
          child: CheckboxListTile(
            title: Text(
              label,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            value: checked,
            onChanged: (bool? value) {
              notifier.value = value ?? false;
            },
            controlAffinity: ListTileControlAffinity.leading,
            tileColor: Colors.transparent, // không ảnh hưởng nền tile
            contentPadding: EdgeInsets.zero,
          ),
        );
      },
    );
  }

  static Widget validateInput(
    String label,
    TextEditingController controller,
    IconData icon, {
    bool readOnly = false,
    bool checkId = false,
    VoidCallback? onTap,
  }) {
    return StatefulBuilder(
      builder: (context, setState) {
        controller.addListener(() {
          setState(() {}); // cập nhật mỗi khi text thay đổi
        });

        final isFilled = controller.text.isEmpty;

        return TextFormField(
          controller: controller,
          readOnly: readOnly,
          decoration: InputDecoration(
            labelText: label,
            labelStyle: TextStyle(fontWeight: FontWeight.bold),
            prefixIcon: Icon(icon),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            floatingLabelBehavior: FloatingLabelBehavior.always,
            fillColor:
                readOnly
                    ? Colors.grey.shade300
                    : (isFilled
                        ? Colors.white
                        : Color.fromARGB(255, 148, 236, 154)),
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
              return 'Không được để trống';
            }
            if (checkId && label == "Mã Đơn Hàng") {
              if (value!.length > 3) {
                return "Mã đơn hàng chỉ được tối đa 3 ký tự";
              }
              if (!RegExp(r'^\d+$').hasMatch(value)) {
                return "Mã đơn hàng chỉ được chứa số";
              }
            }
            return null;
          },
          onTap: onTap,
        );
      },
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
