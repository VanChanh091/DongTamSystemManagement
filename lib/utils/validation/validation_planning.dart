import 'package:flutter/material.dart';

class ValidationPlanning {
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
            labelStyle: const TextStyle(fontWeight: FontWeight.bold),
            prefixIcon: Icon(icon),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
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
            if (label == "Ghép Khổ") {
              if (value == null || value.isEmpty) {
                return 'Không được để trống';
              } else if (value == "0") {
                return "Ghép khổ phải lớn hơn 0";
              } else if (!RegExp(r'^\d+$').hasMatch(value)) {
                return "Ghép Khổ chỉ được chứa số";
              }
            }
            return null;
          },
          onTap: onTap,
        );
      },
    );
  }

  static Widget dropdownForLayerType(
    List<String> items,
    String type,
    Map<String, String> labels,
    ValueChanged<String?> onChanged,
  ) {
    return DropdownButtonFormField<String>(
      value: items.contains(type) ? type : null,
      items:
          items.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Row(
                children: [
                  const SizedBox(width: 10),
                  Text(
                    labels[value] ?? value,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
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
