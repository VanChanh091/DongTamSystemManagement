import "dart:io";

import "package:dongtam/presentation/components/shared/dialog_shared.dart";
import "package:dongtam/service/debt_service.dart";
import "package:dongtam/service/warehouse_service.dart";
import "package:dongtam/utils/handleError/show_snack_bar.dart";
import "package:dongtam/utils/helper/picker_date_helper.dart";
import "package:dongtam/utils/logger/app_logger.dart";
import "package:flutter/material.dart";

class DialogExportOutbound extends StatefulWidget {
  final VoidCallback onLoading;

  const DialogExportOutbound({super.key, required this.onLoading});

  @override
  State<DialogExportOutbound> createState() => _DialogExportOutboundState();
}

class _DialogExportOutboundState extends State<DialogExportOutbound> {
  ValueNotifier<String?> selectedOption = ValueNotifier<String?>(null);
  DateTimeRange? selectedRange;

  void submit() async {
    try {
      if (selectedOption.value == "dateOutbound" || selectedOption.value == "paymentAllocation") {
        if (selectedRange == null) {
          showSnackBarError(context, "Vui lòng chọn khoảng thời gian");
          return;
        }
      }

      File? file;

      if (selectedOption.value == "dateOutbound") {
        file = await WarehouseService().exportOutboundDetail(
          fromDate: selectedRange?.start,
          toDate: selectedRange?.end,
        );
      } else if (selectedOption.value == "paymentAllocation") {
        file = await DebtService().exportExcelPaymentAllocations(
          fromDate: selectedRange!.start,
          toDate: selectedRange!.end,
        );
      }

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
      title: const Text("Xuất Dữ Liệu Xuất Kho"),
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
                // Option 1: Chi tiết PXK theo thời gian
                RadioListTile<String>(
                  title: const Text("Chi Tiết PXK (Ngày Xuất)", style: TextStyle(fontSize: 16)),
                  value: "dateOutbound",
                ),

                // Option 2: Lịch sử cấn trừ công nợ
                RadioListTile<String>(
                  title: const Text("Lịch Sử Trừ Công Nợ", style: TextStyle(fontSize: 16)),
                  value: "paymentAllocation",
                ),

                const SizedBox(height: 10),
                if (value == "dateOutbound" || value == "paymentAllocation") ...[
                  Column(
                    children: [
                      PickerDateHelper(
                        width: 260,
                        height: 48,
                        startDate: selectedRange?.start,
                        endDate: selectedRange?.end,
                        hintText: "Chọn khoảng thời gian",
                        onDateRangeChanged: (range) {
                          setState(() {
                            selectedRange = range;
                          });
                        },
                      ),
                      const SizedBox(height: 5),
                      if (selectedRange == null)
                        const Text(
                          "Chưa chọn khoảng thời gian",
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
