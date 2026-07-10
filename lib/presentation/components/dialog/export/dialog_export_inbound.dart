import "dart:io";

import "package:dongtam/service/warehouse_service.dart";
import "package:dongtam/utils/handleError/show_snack_bar.dart";
import "package:dongtam/utils/logger/app_logger.dart";
import "package:flutter/material.dart";

class DialogExportInbound extends StatefulWidget {
  const DialogExportInbound({super.key});

  @override
  State<DialogExportInbound> createState() => _DialogExportInboundState();
}

class _DialogExportInboundState extends State<DialogExportInbound> {
  ValueNotifier<String?> selectedOption = ValueNotifier<String?>(null);
  DateTimeRange? selectedRange;

  Future<void> pickDateRange(BuildContext context) async {
    final size = MediaQuery.of(context).size;

    final DateTimeRange? result = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2025),
      lastDate: DateTime(2100),
      initialDateRange: selectedRange,
      builder: (context, child) {
        return Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: size.width * 0.3, maxHeight: size.height * 0.8),
            child: Material(
              borderRadius: BorderRadius.circular(16),
              clipBehavior: Clip.antiAlias,
              child: child!,
            ),
          ),
        );
      },
    );

    if (result != null) {
      setState(() {
        selectedRange = result;
      });
    }
  }

  void submit() async {
    try {
      if (selectedOption.value == "dateInbound") {
        if (selectedRange == null) {
          showSnackBarError(context, "Vui lòng chọn khoảng thời gian");
          return;
        }
      }

      File? file;

      file = await WarehouseService().exportExcelInbounds(
        fromDate: selectedRange?.start,
        toDate: selectedRange?.end,
      );

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
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text("Xuất Lịch Sử Nhập Kho"),
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
                  title: const Text("Ngày Nhập Kho", style: TextStyle(fontSize: 16)),
                  value: "dateInbound",
                ),

                const SizedBox(height: 10),
                if (value == "dateInbound") ...[
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
                          onPressed: () => pickDateRange(context),
                          icon: Icon(Icons.date_range, color: Colors.blue.shade400),
                          label: Text(
                            selectedRange == null
                                ? "Chọn khoảng thời gian"
                                : "${selectedRange!.start.day}/${selectedRange!.start.month}/${selectedRange!.start.year} - "
                                    "${selectedRange!.end.day}/${selectedRange!.end.month}/${selectedRange!.end.year}",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.blue.shade700,
                            ),
                          ),
                        ),
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
