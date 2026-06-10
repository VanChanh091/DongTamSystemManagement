import 'package:flutter/material.dart';
import 'package:diacritic/diacritic.dart';
import 'package:dongtam/presentation/components/shared/base_validate_input.dart';

class ValidationHelper {
  //----------------------------HELPER INPUT-----------------------------------
  static Widget scrapReport({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    bool readOnly = false,
    Function(String)? onChanged,
    VoidCallback? onTap,
    String? prefix,
  }) {
    return BaseValidateInput(
      label: label,
      controller: controller,
      icon: icon,
      readOnly: readOnly,
      onChanged: onChanged,
      onTap: onTap,
      prefixText: prefix,
      validator: (value) {
        final cleanValue = value?.trim().replaceAll(RegExp(r'[\r\n]+'), ' ') ?? '';

        final requiredFields = ["Phế Liệu Sản Xuất"];
        final numericFields = [
          "Phế Liệu Sản Xuất",
          "Phế Liệu Xe Nâng",
          "Phế Liệu Ống Nòng",
          "Phế Liệu Lưu Kho",
          "Phế Liệu Khác",
        ];

        if (requiredFields.contains(label) && cleanValue.isEmpty) {
          return 'Không được để trống';
        }

        if (numericFields.contains(label) &&
            cleanValue.isNotEmpty &&
            !RegExp(r'^\d+(\.\d+)?$').hasMatch(cleanValue)) {
          return 'Vui lòng nhập một giá trị số';
        }
        return null;
      },
    );
  }

  static Widget adminInput({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    bool readOnly = false,
    VoidCallback? onTap,
  }) {
    return BaseValidateInput(
      label: label,
      controller: controller,
      icon: icon,
      readOnly: readOnly,
      onTap: onTap,
    );
  }

  static Widget customerInput({
    required String label,
    required IconData icon,
    required TextEditingController controller,
    bool readOnly = false,
    bool checkId = false, // dùng cho validator
    VoidCallback? onTap,
    String? externalError,
    Function(String)? onChanged,
  }) {
    return BaseValidateInput(
      label: label,
      controller: controller,
      icon: icon,
      readOnly: readOnly,
      onChanged: onChanged,
      onTap: onTap,
      errorText: externalError,
      validator: (value) {
        if (externalError != null) return externalError;

        final cleanValue = value?.trim().replaceAll(RegExp(r'[\r\n]+'), ' ') ?? '';

        final requiredFields = [
          "Mã khách hàng",
          "Tên khách hàng",
          "Tên công ty",
          "Địa chỉ công ty",
          "Địa chỉ giao hàng",
          "Hạn Mức Công Nợ",
          "Thời Hạn Thanh Toán",
          "Nguồn Khách Hàng",
          "Ngày Chốt Công Nợ",
          "CSKH",
          "SDT",
        ];

        if (requiredFields.contains(label) && cleanValue.isEmpty) {
          return 'Không được để trống';
        }

        //regex customerID
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

            if (value.contains(' ')) {
              return "Mã khách hàng không được chứa dấu cách";
            } else if (value.length == 10) {
              final lastChar = value.substring(value.length - 1);
              if (RegExp(r'[0-9]').hasMatch(lastChar)) {
                return "Ký tự cuối không được là số";
              }
            }
          }

          final pattern = RegExp(r"^[a-zA-Z0-9]+$");
          if (!pattern.hasMatch(value)) {
            return "Mã khách hàng không được chứa ký tự đặc biệt";
          }
        }

        //check sdt
        if (label == "SDT" && value != null && value.isNotEmpty) {
          if (!RegExp(r'^\d+$').hasMatch(value.trim())) {
            return 'Số điện thoại chỉ được chứa chữ số';
          }
        }

        return null;
      },
    );
  }

  static Widget orderInput({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    VoidCallback? onTap,
    bool readOnly = false,
    bool enabled = true,
    bool isCalculate = false,
  }) {
    return BaseValidateInput(
      label: label,
      controller: controller,
      icon: icon,
      readOnly: readOnly,
      onTap: onTap,
      isCalculate: isCalculate,
      validator: (value) {
        final cleanValue = value?.trim().replaceAll(RegExp(r'[\r\n]+'), ' ') ?? '';

        final requiredFields = [
          "Mã Đơn Hàng",
          "Ngày Yêu Cầu Giao",
          "Số Lượng Tính Tiền",
          "Khổ Khách Đặt (cm)",
          "Số Con",
          "Đơn Giá (M2)",
        ];

        if (requiredFields.contains(label) && cleanValue.isEmpty) {
          return 'Không được để trống';
        }

        return null;
      },
    );
  }

  static Widget employeeInput({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    Function(String)? onChanged,
    VoidCallback? onTap,
    String? externalError,
    bool readOnly = false,
    bool empCode = false, //using for validator
  }) {
    return BaseValidateInput(
      label: label,
      icon: icon,
      controller: controller,
      readOnly: readOnly,
      onChanged: onChanged,
      onTap: onTap,
      validator: (value) {
        if (externalError != null) return externalError;

        String cleanValue = "";

        if (value != null) {
          // xoá khoảng trắng 2 đầu + dấu xuống dòng
          cleanValue = value.trim().replaceAll(RegExp(r'[\r\n]+'), ' ');
          controller.text = value;
        }

        final requiredFields = [
          'Tên Nhân Viên',
          'Số Điện Thoại',
          "Dân Tộc",
          "Ngày Sinh",
          "Ngày Vào Làm",
          'Trình Độ Văn Hóa',
          'Số CCCD',
          'Ngày Cấp',
          'Nơi Cấp',
          'Ngày Cấp',
          'ĐC Thường Trú',
          'Mã Nhân Viên',
          'Chức Vụ',
          'Mã Nhân Viên',
        ];

        if (requiredFields.contains(label) && cleanValue.isEmpty) {
          return 'Không được để trống';
        }

        //label: Số Điện Thoại, Số Liên Hệ Khẩn Cấp, Số CCCD chỉ chấp nhận chữ số
        const numericLabels = ['Số Điện Thoại', 'Số Liên Hệ Khẩn Cấp', 'Số CCCD'];
        if ((numericLabels.contains(label)) && !RegExp(r'^\d+$').hasMatch(cleanValue)) {
          return '$label chỉ được chứa chữ số';
        }

        if (empCode) {
          if (label == 'Mã Nhân Viên') {
            if (RegExp(r'[0-9]').hasMatch(cleanValue)) {
              return 'Mã nhân viên không được chứa số';
            }
          }
        }

        return null;
      },
    );
  }

  static Widget planningInput({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool readOnly = false,
    VoidCallback? onTap,
    int? qtyProduced,
    TextEditingController? qtyOrderController,
  }) {
    return BaseValidateInput(
      label: label,
      controller: controller,
      icon: icon,
      readOnly: readOnly,
      onTap: onTap,
      validator: (value) {
        if (label == "Ghép Khổ") {
          if (value == null || value.isEmpty) {
            return 'Không được để trống';
          } else if (value == "0") {
            return "Ghép khổ phải lớn hơn 0";
          } else if (!RegExp(r'^\d+$').hasMatch(value)) {
            return "Ghép Khổ chỉ được chứa số";
          }
        } else if (label == "Kế hoạch chạy") {
          if (qtyOrderController != null && qtyProduced != null) {
            final runningPlan = int.parse(value ?? "");
            final quantityOrder = int.tryParse(qtyOrderController.text) ?? 0;

            if (runningPlan <= 0) {
              return "Kế hoạch chạy phải lớn hơn 0";
            }

            // case 1: chưa có lần sx
            if (qtyProduced == 0) {
              if (runningPlan > quantityOrder) {
                return "Không được vượt quá số lượng đơn hàng";
              }
            }
            // case 2: đã có lần sx
            else {
              if (runningPlan + qtyProduced > quantityOrder) {
                return "Vượt quá số lượng đơn hàng";
              }
            }
          }
        }
        return null;
      },
    );
  }

  //---------------------HELPER CHECKBOX AND DROPDOWN--------------------------
  static Widget checkboxForBox({
    required String label,
    required ValueNotifier<bool> notifier,
    bool enabled = true,
    ListTileControlAffinity controlAffinity = ListTileControlAffinity.leading,
    void Function(bool?)? onChanged,
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

                      if (onChanged != null) {
                        onChanged(value);
                      }
                    }
                    : null,
            controlAffinity: controlAffinity,
            tileColor: Colors.transparent,
            contentPadding: EdgeInsets.zero,
          ),
        );
      },
    );
  }

  static Widget dropdownForTypes({
    required List<String> items,
    required String type,
    required ValueChanged onChanged,
    Map<String, String>? labels,
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
                  Text(
                    labels?[value] ?? value,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
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
