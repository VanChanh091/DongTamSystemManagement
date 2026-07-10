import "package:dongtam/service/report_planning_service.dart";
import "package:dongtam/utils/logger/app_logger.dart";
import "package:dongtam/utils/handleError/show_snack_bar.dart";
import "package:flutter/material.dart";

class DialogSelectExportExcel extends StatefulWidget {
  final VoidCallback onPlanningIdsOrRangeDate;
  final String machine;
  final bool isBox;

  const DialogSelectExportExcel({
    super.key,
    required this.onPlanningIdsOrRangeDate,
    required this.machine,
    this.isBox = false,
  });

  @override
  State<DialogSelectExportExcel> createState() => _DialogSelectExportExcelState();
}

class _DialogSelectExportExcelState extends State<DialogSelectExportExcel> {
  ValueNotifier<String?> selectedOption = ValueNotifier<String?>(null);

  final TextEditingController planningIdsController = TextEditingController();
  DateTimeRange? selectedRange;

  Future<void> pickDateRange(BuildContext context) async {
    final size = MediaQuery.of(context).size;

    final DateTimeRange? result = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
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
      final currentOption = selectedOption.value;

      if (currentOption == null) {
        showSnackBarError(context, "Vui lòng chọn phương thức xuất báo cáo");
        return;
      }

      if (currentOption == "dateHasMachine" || currentOption == "dateNoMachine") {
        if (selectedRange == null) {
          showSnackBarError(context, "Vui lòng chọn khoảng thời gian");
          return;
        }
      }

      final String? machineParam = (currentOption == "dateHasMachine") ? widget.machine : null;

      if (widget.isBox) {
        AppLogger.i(
          "Export báo cáo BOX | "
          "from=${selectedRange?.start}, to=${selectedRange?.end}, "
          "machine=$machineParam",
        );

        await ReportPlanningService().exportExcelReportBox(
          fromDate: selectedRange?.start,
          toDate: selectedRange?.end,
          machine: machineParam,
        );
      } else {
        AppLogger.i(
          "Export báo cáo PAPER | "
          "from=${selectedRange?.start}, to=${selectedRange?.end}, "
          "machine=$machineParam",
        );

        await ReportPlanningService().exportExcelReportPaper(
          fromDate: selectedRange?.start,
          toDate: selectedRange?.end,
          machine: machineParam,
        );
      }
      if (!mounted) return;
      showSnackBarSuccess(context, "Lưu thành công");

      if (!mounted) return; // check context
      widget.onPlanningIdsOrRangeDate();
      Navigator.of(context).pop();
    } catch (e, s) {
      if (!mounted) return; // check context
      AppLogger.e("Lỗi khi xuất báo cáo", error: e, stackTrace: s);
      showSnackBarError(context, "Lỗi: Không thể lưu dữ liệu");
    }
  }

  @override
  void dispose() {
    super.dispose();
    selectedOption.dispose();
    planningIdsController.dispose();
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
          return RadioGroup(
            groupValue: value,
            onChanged: (val) {
              if (val != null) selectedOption.value = val;
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Option 1: Theo thời gian (has machine)
                RadioListTile<String>(
                  title: const Text("Theo Ngày (Từng Máy)", style: TextStyle(fontSize: 16)),
                  value: "dateHasMachine",
                ),

                // Option 2: Theo thời gian (no machine machine)
                RadioListTile<String>(
                  title: const Text("Theo Ngày (Tất Cả Máy)", style: TextStyle(fontSize: 16)),
                  value: "dateNoMachine",
                ),
                const SizedBox(height: 10),

                if (value == "dateHasMachine" || value == "dateNoMachine")
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
