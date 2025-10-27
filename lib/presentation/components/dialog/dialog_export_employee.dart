import 'package:dongtam/service/employee_service.dart';
import 'package:dongtam/utils/handleError/show_snack_bar.dart';
import 'package:dongtam/utils/logger/app_logger.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DialogExportEmployee extends StatefulWidget {
  final VoidCallback onEmployee;

  const DialogExportEmployee({super.key, required this.onEmployee});

  @override
  State<DialogExportEmployee> createState() => _DialogExportEmployeeState();
}

class _DialogExportEmployeeState extends State<DialogExportEmployee> {
  final statusController = TextEditingController();
  final joinDateController = TextEditingController();
  DateTime? selectedDate;
  ValueNotifier<String?> selectedOption = ValueNotifier<String?>(null);

  Future<void> pickedDate(BuildContext context) async {
    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2019),
      lastDate: DateTime(2100),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.blue,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
            dialogTheme: const DialogThemeData(backgroundColor: Colors.white),
          ),
          child: child!,
        );
      },
    );

    if (date != null && mounted) {
      setState(() {
        selectedDate = date;
        joinDateController.text = DateFormat('dd/MM/yyyy').format(date);
      });
    }
  }

  void submit() async {
    try {
      if (selectedOption.value == 'joinDate') {
        if (selectedDate == null) {
          showSnackBarError(context, 'Vui lòng chọn thời gian');
          return;
        }
      }

      await EmployeeService().exportExcelEmployee(
        status: selectedOption.value == 'status' ? statusController.text : "",
        joinDate: selectedOption.value == 'joinDate' ? selectedDate : null,
        all: selectedOption.value == 'all' ? true : false,
      );

      if (!mounted) return;
      showSnackBarSuccess(context, "Xuất thành công");

      widget.onEmployee();
      Navigator.of(context).pop();
    } catch (e, s) {
      if (!mounted) return; // check context
      AppLogger.e("Lỗi khi xuất báo cáo", error: e, stackTrace: s);
      showSnackBarError(context, 'Lỗi: Không thể xuất dữ liệu');
    }
  }

  @override
  void dispose() {
    statusController.dispose();
    joinDateController.dispose();
    selectedOption.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text("Xuất File Excel"),
      content: ValueListenableBuilder<String?>(
        valueListenable: selectedOption,
        builder: (context, value, _) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<String>(
                title: const Text("Tất cả", style: TextStyle(fontSize: 17)),
                value: 'all',
                groupValue: value,
                onChanged: (val) => selectedOption.value = val,
              ),

              RadioListTile<String>(
                title: const Text("Tình Trạng", style: TextStyle(fontSize: 17)),
                value: 'status',
                groupValue: value,
                onChanged: (val) => selectedOption.value = val,
              ),
              SizedBox(height: 5),

              if (value == 'status') ...[
                TextFormField(
                  controller: statusController,
                  style: const TextStyle(fontSize: 15),
                  decoration: InputDecoration(
                    labelText: "Nhập tình trạng",
                    labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    fillColor: Colors.white,
                    filled: true,
                  ),
                ),
              ],

              RadioListTile<String>(
                title: const Text("Ngày vào làm", style: TextStyle(fontSize: 17)),
                value: 'joinDate',
                groupValue: value,
                onChanged: (val) => selectedOption.value = val,
              ),
              SizedBox(height: 5),

              if (value == 'joinDate') ...[
                Column(
                  children: [
                    SizedBox(
                      width: 250,
                      height: 40,
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          side: BorderSide(color: Colors.blue.shade400, width: 1.5),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () => pickedDate(context),
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
                    SizedBox(height: 5),
                    if (selectedDate == null)
                      const Text(
                        "Chưa chọn thời gian",
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
