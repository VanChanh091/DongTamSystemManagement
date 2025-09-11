import 'package:diacritic/diacritic.dart';
import 'package:dongtam/data/models/customer/customer_model.dart';
import 'package:flutter/material.dart';

class ValidationCustomer {
  static Widget validateInput(
    String label,
    TextEditingController controller,
    IconData icon, {
    bool readOnly = false,
    bool checkId = false,
    List<Customer>? allCustomers,
    String? currentCustomerId, // 👈 thêm dòng này
  }) {
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
        fillColor: readOnly ? Colors.grey.shade300 : Colors.white,
        filled: true,
      ),
      validator: (value) {
        if ((label == 'Mã khách hàng' ||
                label == "Tên khách hàng" ||
                label == "Tên công ty" ||
                label == "Địa chỉ công ty" ||
                label == "Địa chỉ giao hàng" ||
                label == "CSKH") &&
            (value == null || value.isEmpty)) {
          return 'Vui lòng nhập $label';
        }

        if (label == 'Mã khách hàng') {
          final withoutDiacritics = removeDiacritics(value!);
          if (value != withoutDiacritics) {
            return "Mã khách hàng không được có dấu tiếng Việt";
          }
          if (checkId && value.length > 10) {
            return 'Mã khách hàng chỉ được tối đa 10 ký tự';
          }
        }

        if (label == "SDT" && value != null && value.trim().isNotEmpty) {
          final trimmed = value.trim();
          if (!RegExp(r'^\d+$').hasMatch(trimmed)) {
            return 'Số điện thoại chỉ được chứa chữ số';
          }
          // gán lại giá trị đã trim vào controller để lưu luôn
          controller.text = trimmed;
        }

        if (label == "MST" && value != null && value.trim().isNotEmpty) {
          final trimmed = value.trim();

          final isDuplicate =
              allCustomers?.any((c) {
                if (currentCustomerId != null &&
                    c.customerId == currentCustomerId) {
                  return false;
                }

                final customerMst = c.mst.replaceAll(RegExp(r'\s+'), '');
                if (customerMst.isEmpty) return false;

                return customerMst == trimmed;
              }) ??
              false;

          if (isDuplicate) {
            return 'Mã số thuế đã tồn tại';
          }

          controller.text = trimmed;
        }

        return null;
      },
    );
  }
}
