import 'package:dongtam/service/dashboard_service.dart';
import 'package:dongtam/utils/handleError/show_snack_bar.dart';
import 'package:dongtam/utils/logger/app_logger.dart';
import 'package:dongtam/utils/validation/validation_order.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DialogExportDbPlannings extends StatefulWidget {
  const DialogExportDbPlannings({super.key});

  @override
  State<DialogExportDbPlannings> createState() => _DialogExportDbPlanningsState();
}

class _DialogExportDbPlanningsState extends State<DialogExportDbPlannings> {
  ValueNotifier<String?> selectedOption = ValueNotifier<String?>(null);

  final usernameController = TextEditingController();
  final dayStartController = TextEditingController();
  DateTime? selectedDayStart;
  //machine
  String machine = "Máy 1350";
  final List<String> itemsMachine = ['Máy 1350', "Máy 1900", "Máy 2 Lớp", "Máy Quấn Cuồn"];

  Future<void> pickedDate(BuildContext context) async {
    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: selectedDayStart ?? DateTime.now(),
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
        selectedDayStart = date;
        dayStartController.text = DateFormat('dd/MM/yyyy').format(date);
      });
    }
  }

  void submit() async {
    try {
      await DashboardService().exportExcelDbPlanning(
        username: selectedOption.value == 'username' ? usernameController.text : "",
        dayStart: selectedOption.value == 'dayStart' ? selectedDayStart : null,
        machine: selectedOption.value == 'machine' ? machine : null,
        all: selectedOption.value == 'all' ? true : false,
      );

      if (!mounted) return;
      showSnackBarSuccess(context, "Xuất thành công");

      if (!mounted) return; // check context
      Navigator.of(context).pop();
    } catch (e, s) {
      if (!mounted) return; // check context
      AppLogger.e("Lỗi khi xuất báo cáo", error: e, stackTrace: s);
      showSnackBarError(context, 'Lỗi: Không thể xuất dữ liệu');
    }
  }

  @override
  void dispose() {
    usernameController.dispose();
    dayStartController.dispose();
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
                title: const Text("Tất cả", style: TextStyle(fontSize: 16)),
                value: 'all',
                groupValue: value,
                onChanged: (val) => selectedOption.value = val,
              ),

              const SizedBox(height: 5),
              RadioListTile<String>(
                title: const Text("Tên Nhân Viên", style: TextStyle(fontSize: 16)),
                value: 'username',
                groupValue: value,
                onChanged: (val) => selectedOption.value = val,
              ),
              const SizedBox(height: 5),
              if (value == 'username') ...[
                textInputExport(controller: usernameController, label: 'Nhập tên nhân viên'),
              ],

              const SizedBox(height: 5),
              RadioListTile<String>(
                title: const Text("Ngày Sản Xuất", style: TextStyle(fontSize: 16)),
                value: 'dayStart',
                groupValue: value,
                onChanged: (val) => selectedOption.value = val,
              ),
              const SizedBox(height: 5),
              if (value == 'dayStart') ...[
                Column(
                  children: [
                    SizedBox(
                      width: 240,
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
                          selectedDayStart == null
                              ? "Chọn ngày"
                              : DateFormat('dd/MM/yyyy').format(selectedDayStart!),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 5),
                    if (selectedDayStart == null)
                      const Text(
                        "Chưa chọn thời gian",
                        style: TextStyle(color: Colors.red, fontSize: 13),
                      ),
                  ],
                ),
              ],

              const SizedBox(height: 5),
              RadioListTile<String>(
                title: const Text("Loại Máy", style: TextStyle(fontSize: 16)),
                value: 'machine',
                groupValue: value,
                onChanged: (val) => selectedOption.value = val,
              ),
              const SizedBox(height: 5),
              if (value == 'machine') ...[
                ValidationOrder.dropdownForTypes(
                  items: itemsMachine,
                  type: machine,
                  onChanged: (value) {
                    setState(() {
                      machine = value!;
                    });
                  },
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

Widget textInputExport({required TextEditingController controller, required String label}) {
  return TextFormField(
    controller: controller,
    style: const TextStyle(fontSize: 15),
    decoration: InputDecoration(
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      floatingLabelBehavior: FloatingLabelBehavior.auto,
      fillColor: Colors.white,
      filled: true,
    ),
  );
}
