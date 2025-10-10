import 'package:dongtam/service/report_planning_service.dart';
import 'package:dongtam/utils/logger/app_logger.dart';
import 'package:dongtam/utils/handleError/show_snack_bar.dart';
import 'package:flutter/material.dart';

class DialogSelectExportExcel extends StatefulWidget {
  final List<int> selectedReportId;
  final VoidCallback onPlanningIdsOrRangeDate;
  final String machine;
  final bool isBox;

  const DialogSelectExportExcel({
    super.key,
    required this.selectedReportId,
    required this.onPlanningIdsOrRangeDate,
    required this.machine,
    this.isBox = false,
  });

  @override
  State<DialogSelectExportExcel> createState() =>
      _DialogSelectExportExcelState();
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
            constraints: BoxConstraints(
              maxWidth: size.width * 0.3,
              maxHeight: size.height * 0.8,
            ),
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
      if (selectedOption.value == 'list') {
        if (widget.selectedReportId.isEmpty) {
          showSnackBarError(context, "Chưa chọn báo cáo nào");
          return;
        }
      } else if (selectedOption.value == 'date') {
        if (selectedRange == null) {
          showSnackBarError(context, 'Vui lòng chọn khoảng thời gian');
          return;
        }
      }

      if (widget.isBox) {
        AppLogger.i(
          "Export báo cáo BOX | "
          "from=${selectedRange?.start}, to=${selectedRange?.end}, "
          "machine=${widget.machine}",
        );

        await ReportPlanningService().exportExcelReportBox(
          fromDate: selectedRange?.start,
          toDate: selectedRange?.end,
          reportBoxId: widget.selectedReportId,
          machine: widget.machine,
        );
      } else {
        AppLogger.i(
          "Export báo cáo PAPER | "
          "from=${selectedRange?.start}, to=${selectedRange?.end}, "
          "machine=${widget.machine}",
        );

        await ReportPlanningService().exportExcelReportPaper(
          fromDate: selectedRange?.start,
          toDate: selectedRange?.end,
          reportPaperId: widget.selectedReportId,
          machine: widget.machine,
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
      showSnackBarError(context, 'Lỗi: Không thể lưu dữ liệu');
    }
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
              // Option 1: Các báo cáo đã chọn
              RadioListTile<String>(
                title: const Text(
                  "Các Báo Cáo Đã Chọn",
                  style: TextStyle(fontSize: 16),
                ),
                value: 'list',
                groupValue: value,
                onChanged: (val) => selectedOption.value = val,
              ),

              // Option 2: Theo thời gian
              RadioListTile<String>(
                title: const Text(
                  "Theo Thời Gian",
                  style: TextStyle(fontSize: 16),
                ),
                value: 'date',
                groupValue: value,
                onChanged: (val) => selectedOption.value = val,
              ),
              const SizedBox(height: 10),
              if (value == 'date')
                Column(
                  children: [
                    SizedBox(
                      width: 250,
                      height: 50,
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          side: BorderSide(
                            color: Colors.blue.shade400,
                            width: 1.5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () => pickDateRange(context),
                        icon: Icon(
                          Icons.date_range,
                          color: Colors.blue.shade400,
                        ),
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
                    SizedBox(height: 5),
                    if (selectedRange == null)
                      const Text(
                        "Chưa chọn khoảng thời gian",
                        style: TextStyle(color: Colors.red, fontSize: 13),
                      ),
                  ],
                ),
            ],
          );
        },
      ),

      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(
            "Hủy",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 17,
              color: Colors.red,
            ),
          ),
        ),
        ElevatedButton(
          onPressed: submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text(
            "Xác nhận",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 17,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}
