import "dart:io";
import "package:dongtam/presentation/components/shared/dialog_shared.dart";
import "package:dongtam/service/debt_service.dart";
import "package:dongtam/utils/handleError/show_snack_bar.dart";
import "package:dongtam/utils/logger/app_logger.dart";
import "package:flutter/material.dart";

class DialogExportDebtCustomer extends StatefulWidget {
  final VoidCallback onLoading;

  const DialogExportDebtCustomer({super.key, required this.onLoading});

  @override
  State<DialogExportDebtCustomer> createState() => _DialogExportDebtCustomerState();
}

class _DialogExportDebtCustomerState extends State<DialogExportDebtCustomer> {
  ValueNotifier<String?> selectedOption = ValueNotifier<String?>(null);
  DateTime? selectedDate;

  Future<void> pickDate(BuildContext context) async {
    final DateTime? result = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2025),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(surface: Colors.white),
            datePickerTheme: DatePickerThemeData(
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.transparent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
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
      if (selectedOption.value == "closingDate") {
        if (selectedDate == null) {
          showSnackBarError(context, "Vui lòng chọn ngày xuất file");
          return;
        }
      }

      File? file;

      file = await DebtService().exportDebtCustomer(targetDate: selectedDate!);

      if (!mounted) return;

      if (file != null) {
        showSnackBarSuccess(context, "Xuất dữ liệu thành công");
      } else {
        showSnackBarError(context, "Xuất file thất bại");
      }

      if (!mounted) return; // check context
      Navigator.of(context).pop();
    } catch (e, s) {
      if (!mounted) return; // check context
      AppLogger.e("Lỗi khi xuất excel", error: e, stackTrace: s);
      showSnackBarError(context, "Lỗi: Không thể xuất dữ liệu");
    }
  }

  @override
  void dispose() {
    super.dispose();
    selectedOption.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text("Xuất Công Nợ Khách Hàng", style: TextStyle(fontSize: 20)),
      content: ValueListenableBuilder<String?>(
        valueListenable: selectedOption,
        builder: (context, value, _) {
          return RadioGroup(
            groupValue: value,
            onChanged: (val) {
              if (val != null) selectedOption.value = val;
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Option 2: Theo thời gian
                RadioListTile<String>(
                  title: const Text("Theo Ngày Chốt", style: TextStyle(fontSize: 16)),
                  value: "closingDate",
                ),

                const SizedBox(height: 10),
                if (value == "closingDate") ...[
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
                          icon: Icon(Icons.calendar_today_outlined, color: Colors.blue.shade400),
                          label: Text(
                            selectedDate == null
                                ? "Chọn ngày chốt công nợ"
                                : "${selectedDate!.day.toString().padLeft(2, '0')}/${selectedDate!.month.toString().padLeft(2, '0')}/${selectedDate!.year}",
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
                          "Chưa chọn ngày chốt công nợ",
                          style: TextStyle(color: Colors.red, fontSize: 13),
                        ),
                    ],
                  ),
                ],
              ],
            ),
          );
        },
      ),

      actions: buildDialogActions(context: context, onConfirm: submit),
    );
  }
}
