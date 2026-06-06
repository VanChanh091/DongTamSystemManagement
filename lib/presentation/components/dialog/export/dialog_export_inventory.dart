import 'dart:io';

import 'package:dongtam/service/warehouse_service.dart';
import 'package:dongtam/utils/handleError/show_snack_bar.dart';
import 'package:dongtam/utils/logger/app_logger.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DialogExportInventory extends StatefulWidget {
  const DialogExportInventory({super.key});

  @override
  State<DialogExportInventory> createState() => _DialogExportInventoryState();
}

class _DialogExportInventoryState extends State<DialogExportInventory> {
  ValueNotifier<String?> selectedOption = ValueNotifier<String?>(null);
  DateTime? selectedDate;

  Future<void> pickDate(BuildContext context) async {
    final DateTime? result = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2026),
      lastDate: DateTime(2100),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.blue,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
            dialogTheme: DialogThemeData(backgroundColor: Colors.white12),
          ),
          child: child!,
        );
      },
    );

    if (result != null) {
      setState(() {
        selectedDate = result;
      });
    }
  }

  void submit() async {
    try {
      if (selectedOption.value == 'dateInbound') {
        if (selectedDate == null) {
          showSnackBarError(context, 'Vui lòng chọn ngày');
          return;
        }
      }

      File? file;
      file = await WarehouseService().exportExcelInventory(date: selectedDate);

      if (mounted) {
        if (file != null) {
          showSnackBarSuccess(context, 'Xuất dữ liệu thành công');
        } else {
          showSnackBarError(context, "Xuất file thất bại");
        }
      }

      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e, s) {
      if (mounted) {
        AppLogger.e("Lỗi khi xuất excel", error: e, stackTrace: s);
        showSnackBarError(context, 'Lỗi: Không thể xuất dữ liệu');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text(
        "Xuất Danh Sách Tồn Kho",
        style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
      ),
      content: ValueListenableBuilder<String?>(
        valueListenable: selectedOption,
        builder: (context, value, _) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Option 1: Theo Tất Cả
              RadioListTile<String>(
                title: const Text("Tồn Hiện Tại", style: TextStyle(fontSize: 16)),
                value: 'all',
                groupValue: value,
                onChanged: (val) => selectedOption.value = val,
              ),
              // Option 2: Theo ngày nhập kho
              RadioListTile<String>(
                title: const Text("Tồn Đầu Ngày", style: TextStyle(fontSize: 16)),
                value: 'dateInbound',
                groupValue: value,
                onChanged: (val) => selectedOption.value = val,
              ),

              const SizedBox(height: 10),
              if (value == 'dateInbound') ...[
                Column(
                  children: [
                    SizedBox(
                      width: 250,
                      height: 50,
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          side: BorderSide(color: Colors.blue.shade400, width: 1.5),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () => pickDate(context),
                        icon: Icon(Icons.date_range, color: Colors.blue.shade400),
                        label: Text(
                          selectedDate == null
                              ? "Chọn ngày"
                              : DateFormat('dd/MM/yyyy').format(selectedDate!),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 5),
                    if (selectedDate == null)
                      const Text(
                        "Chưa chọn ngày nhập kho",
                        style: TextStyle(color: Colors.red, fontSize: 13),
                      ),
                  ],
                ),
              ],
            ],
          );
        },
      ),

      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(
            "Hủy",
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.black54),
          ),
        ),
        ElevatedButton(
          onPressed: submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: const Text(
            "Xác nhận",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Colors.white),
          ),
        ),
      ],
    );
  }
}
