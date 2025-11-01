import 'package:flutter/material.dart';

class ValidationOrder {
  static Widget checkboxForBox({
    required String label,
    required ValueNotifier<bool> notifier,
    bool enabled = true,
  }) {
    return ValueListenableBuilder<bool>(
      valueListenable: notifier,
      builder: (context, checked, _) {
        return Theme(
          data: Theme.of(context).copyWith(
            checkboxTheme: CheckboxThemeData(
              fillColor: WidgetStateProperty.resolveWith<Color>((states) {
                if (states.contains(WidgetState.selected)) {
                  return Colors.red; // nền trắng khi chọn
                }
                return Colors.white; // nền trắng khi không chọn
              }),
              checkColor: WidgetStateProperty.all<Color>(Colors.white),
              side: const BorderSide(color: Colors.black, width: 1),
            ),
          ),
          child: CheckboxListTile(
            title: Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            value: checked,
            onChanged:
                enabled
                    ? (bool? value) {
                      notifier.value = value ?? false;
                    }
                    : null,
            controlAffinity: ListTileControlAffinity.leading,
            tileColor: Colors.transparent,
            contentPadding: EdgeInsets.zero,
          ),
        );
      },
    );
  }

  static Widget validateInput({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    bool readOnly = false,
    bool checkId = false,
    VoidCallback? onTap,
    bool enabled = true,
  }) {
    return StatefulBuilder(
      builder: (context, setState) {
        controller.addListener(() {
          setState(() {}); // cập nhật mỗi khi text thay đổi
        });

        final isFilled = controller.text.isEmpty;
        final effectiveReadOnly = readOnly || !enabled;

        return TextFormField(
          controller: controller,
          style: const TextStyle(fontSize: 15),
          readOnly: effectiveReadOnly,
          decoration: InputDecoration(
            labelText: label,
            labelStyle: const TextStyle(fontWeight: FontWeight.bold),
            prefixIcon: Icon(icon),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            floatingLabelBehavior: FloatingLabelBehavior.always,
            fillColor:
                effectiveReadOnly
                    ? Colors.grey.shade300
                    : (isFilled ? Colors.white : Color.fromARGB(255, 148, 236, 154)),
            filled: true,
          ),
          validator: (value) {
            if ((label == "Mã Đơn Hàng" ||
                    label == "Ngày yêu cầu giao" ||
                    label == "Số lượng (KH)" ||
                    label == "Khổ khách đặt (cm)" ||
                    label == "Số con" ||
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

  static Widget dropdownForTypes({
    required List<String> items,
    required String type,
    required ValueChanged onChanged,
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
                  Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
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
