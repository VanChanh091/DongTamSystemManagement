import 'package:dongtam/service/report_planning_service.dart';
import 'package:dongtam/utils/showSnackBar/show_snack_bar.dart';
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
    final now = DateTime.now();
    final DateTimeRange? result = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 1),
      initialDateRange:
          selectedRange ??
          DateTimeRange(start: now.subtract(const Duration(days: 7)), end: now),
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
        await ReportPlanningService().exportExcelReportBox(
          fromDate: selectedRange?.start,
          toDate: selectedRange?.end,
          reportBoxId: widget.selectedReportId,
          machine: widget.machine,
        );
      } else {
        await ReportPlanningService().exportExcelReportPaper(
          fromDate: selectedRange?.start,
          toDate: selectedRange?.end,
          reportPaperId: widget.selectedReportId,
          machine: widget.machine,
        );
      }

      showSnackBarSuccess(context, "Lưu thành công");
      widget.onPlanningIdsOrRangeDate();
      Navigator.of(context).pop();
    } catch (e) {
      print("Error: $e");
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
              if (value == 'date')
                Column(
                  children: [
                    OutlinedButton.icon(
                      onPressed: () => pickDateRange(context),
                      icon: const Icon(Icons.date_range),
                      label: Text(
                        selectedRange == null
                            ? "Chọn khoảng thời gian"
                            : "${selectedRange!.start.day}/${selectedRange!.start.month}/${selectedRange!.start.year} - "
                                "${selectedRange!.end.day}/${selectedRange!.end.month}/${selectedRange!.end.year}",
                      ),
                    ),
                    if (selectedRange == null)
                      const Text(
                        "Chưa chọn khoảng thời gian",
                        style: TextStyle(color: Colors.red, fontSize: 12),
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
          child: Text(
            "Hủy",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Colors.red,
            ),
          ),
        ),
        ElevatedButton(
          onPressed: submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(
            "Xác nhận",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}
