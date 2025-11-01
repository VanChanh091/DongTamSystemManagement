import 'package:diacritic/diacritic.dart';
import 'package:dongtam/data/models/customer/customer_model.dart';
import 'package:flutter/material.dart';

class ValidationCustomer {
  static Widget validateInput({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    bool readOnly = false,
    bool checkId = false,
    List<Customer>? allCustomers,
    String? currentCustomerId,
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

        if ((label == 'Mã khách hàng' ||
                label == "Tên khách hàng" ||
                label == "Tên công ty" ||
                label == "Địa chỉ công ty" ||
                label == "Địa chỉ giao hàng" ||
                label == "Hạn Mức Công Nợ" ||
                label == "Hạn Thanh Toán" ||
                label == "CSKH") &&
            (value == null || value.isEmpty)) {
          return 'Vui lòng nhập $label';
        }

        if (label == 'Mã khách hàng' && value != null) {
          final withoutDiacritics = removeDiacritics(value);
          if (value != withoutDiacritics) {
            return "Mã khách hàng không được có dấu tiếng Việt";
          }

          if (checkId) {
            if (value.length < 10) {
              return 'Mã khách hàng phải nhập 10 ký tự';
            } else if (value.length > 10) {
              return 'Mã khách hàng vượt quá 10 ký tự';
            }
          }

          final pattern = RegExp(r"^[a-zA-Z0-9]+$");
          if (!pattern.hasMatch(value)) {
            return "Mã khách hàng không được chứa ký tự đặc biệt";
          }

          //check prefix
          if (allCustomers != null && allCustomers.isNotEmpty) {
            final prefix = value.toUpperCase();

            final hasDuplicatePrefix = allCustomers.any((c) {
              // bỏ qua khách hiện tại nếu đang edit
              if (currentCustomerId != null && c.customerId == currentCustomerId) {
                return false;
              }

              if (c.customerId.length > 10) {
                final existingPreifx = c.customerId.substring(0, c.customerId.length - 4);

                return existingPreifx == prefix;
              }

              return false;
            });

            if (hasDuplicatePrefix) {
              return "Tiền mã khách hàng đã tồn tại";
            }
          }
        }

        if (label == "SDT" && value != null && value.isNotEmpty) {
          if (!RegExp(r'^\d+$').hasMatch(value)) {
            return 'Số điện thoại chỉ được chứa chữ số';
          }
        }

        if (label == "MST" && value != null && value.isNotEmpty) {
          final trimmed = value.replaceAll(RegExp(r'\s+'), '');

          final isDuplicate =
              allCustomers?.any((c) {
                if (currentCustomerId != null && c.customerId == currentCustomerId) {
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
