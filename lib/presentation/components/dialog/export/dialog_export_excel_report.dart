import "package:dongtam/service/report_planning_service.dart";
import "package:dongtam/utils/logger/app_logger.dart";
import "package:dongtam/utils/handleError/show_snack_bar.dart";
import "package:flutter/material.dart";
import "package:google_fonts/google_fonts.dart";
import "package:intl/intl.dart";

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
  final planningIdsController = TextEditingController();

  DateTime? startDateTime;
  DateTime? endDateTime;

  Future<void> pickDateTimeRange(BuildContext context) async {
    final size = MediaQuery.of(context).size;
    bool isSelectingStart = true;

    // Khởi tạo giá trị tạm thời dựa
    final DateTime initialStart = DateTime.now();
    final DateTime initialEnd = DateTime.now().add(const Duration(hours: 1));

    DateTime tempStartDate = DateTime(initialStart.year, initialStart.month, initialStart.day);
    TimeOfDay tempStartTime = TimeOfDay(hour: initialStart.hour, minute: initialStart.minute);

    DateTime tempEndDate = DateTime(initialEnd.year, initialEnd.month, initialEnd.day);
    TimeOfDay tempEndTime = TimeOfDay(hour: initialEnd.hour, minute: initialEnd.minute);

    final List<DateTime>? result = await showDialog<List<DateTime>>(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Container(
            padding: const EdgeInsets.all(16),
            width: 600,
            child: StatefulBuilder(
              builder: (context, dialogSetState) {
                final currentStart = DateTime(
                  tempStartDate.year,
                  tempStartDate.month,
                  tempStartDate.day,
                  tempStartTime.hour,
                  tempStartTime.minute,
                );
                final currentEnd = DateTime(
                  tempEndDate.year,
                  tempEndDate.month,
                  tempEndDate.day,
                  tempEndTime.hour,
                  tempEndTime.minute,
                );
                final isInvalid = currentEnd.isBefore(currentStart);

                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Chọn Khoảng Ngày & Giờ",
                      style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 16),

                    // --- KHU VỰC TAB CHỌN BẮT ĐẦU / KẾT THÚC ---
                    Row(
                      children: [
                        // Tab Bắt đầu
                        Expanded(
                          child: InkWell(
                            onTap: () => dialogSetState(() => isSelectingStart = true),
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                              decoration: BoxDecoration(
                                color: isSelectingStart ? Colors.blue.shade50 : Colors.transparent,
                                border: Border.all(
                                  color: isSelectingStart ? Colors.blue : Colors.grey.shade300,
                                  width: 1.5,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "BẮT ĐẦU",
                                    style: GoogleFonts.inter(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color:
                                          isSelectingStart ? Colors.blue.shade700 : Colors.black54,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "${DateFormat("dd/MM/yyyy").format(tempStartDate)} - ${tempStartTime.format(context)}",
                                    style: GoogleFonts.inter(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      color:
                                          isSelectingStart ? Colors.blue.shade900 : Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Tab Kết thúc
                        Expanded(
                          child: InkWell(
                            onTap: () => dialogSetState(() => isSelectingStart = false),
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                              decoration: BoxDecoration(
                                color: !isSelectingStart ? Colors.blue.shade50 : Colors.transparent,
                                border: Border.all(
                                  color: !isSelectingStart ? Colors.blue : Colors.grey.shade300,
                                  width: 1.5,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "KẾT THÚC",
                                    style: GoogleFonts.inter(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color:
                                          !isSelectingStart ? Colors.blue.shade700 : Colors.black54,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "${DateFormat("dd/MM/yyyy").format(tempEndDate)} - ${tempEndTime.format(context)}",
                                    style: GoogleFonts.inter(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      color:
                                          !isSelectingStart ? Colors.blue.shade900 : Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    // Cảnh báo nếu chọn giờ kết thúc trước giờ bắt đầu
                    if (isInvalid) ...[
                      const SizedBox(height: 8),
                      Text(
                        "⚠️ Thời gian kết thúc phải sau thời gian bắt đầu!",
                        style: GoogleFonts.inter(
                          color: Colors.red.shade700,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],

                    const SizedBox(height: 16),
                    const Divider(height: 1),
                    const SizedBox(height: 12),

                    // --- KHU VỰC CHỌN NGÀY & GIỜ (2 CỘT) ---
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Cột trái: Lịch chọn ngày
                        Expanded(
                          flex: 3,
                          child: SizedBox(
                            height: 280,
                            child: CalendarDatePicker(
                              // Sử dụng ValueKey để buộc widget vẽ lại khi đổi tab cấu hình
                              key: ValueKey<bool>(isSelectingStart),
                              initialDate: isSelectingStart ? tempStartDate : tempEndDate,
                              firstDate: DateTime(2020),
                              lastDate: DateTime(2100),
                              onDateChanged: (date) {
                                dialogSetState(() {
                                  if (isSelectingStart) {
                                    tempStartDate = date;
                                  } else {
                                    tempEndDate = date;
                                  }
                                });
                              },
                            ),
                          ),
                        ),

                        const VerticalDivider(width: 20, thickness: 1),

                        // Cột phải: Chọn giờ tương ứng
                        Expanded(
                          flex: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 30),
                              Text(
                                isSelectingStart ? "Giờ bắt đầu:" : "Giờ kết thúc:",
                                style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w500),
                              ),
                              const SizedBox(height: 8),

                              OutlinedButton.icon(
                                onPressed: () async {
                                  final time = await showTimePicker(
                                    context: context,
                                    initialTime: isSelectingStart ? tempStartTime : tempEndTime,
                                    builder: (context, child) {
                                      return Theme(
                                        data: Theme.of(context).copyWith(
                                          timePickerTheme: TimePickerTheme.of(context).copyWith(
                                            backgroundColor: Colors.white,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(16),
                                            ),
                                          ),
                                          colorScheme: Theme.of(
                                            context,
                                          ).colorScheme.copyWith(surface: Colors.white),
                                        ),
                                        child: Center(
                                          child: ConstrainedBox(
                                            constraints: BoxConstraints(
                                              maxWidth: size.width * 0.3,
                                              maxHeight: size.height * 0.8,
                                            ),
                                            child: Material(
                                              color: Colors.transparent,
                                              borderRadius: BorderRadius.circular(16),
                                              clipBehavior: Clip.antiAlias,
                                              child: child!,
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                  if (time != null) {
                                    dialogSetState(() {
                                      if (isSelectingStart) {
                                        tempStartTime = time;
                                      } else {
                                        tempEndTime = time;
                                      }
                                    });
                                  }
                                },
                                icon: const Icon(Icons.access_time, size: 18),
                                label: Text(
                                  (isSelectingStart ? tempStartTime : tempEndTime).format(context),
                                ),
                                style: OutlinedButton.styleFrom(
                                  minimumSize: const Size.fromHeight(45),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const Divider(height: 24),

                    // Nút điều hướng dưới cùng của Dialog con
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text(
                            "Hủy",
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.black54,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          // Vô hiệu hóa nút nếu khoảng thời gian không hợp lệ
                          onPressed:
                              isInvalid
                                  ? null
                                  : () {
                                    Navigator.pop(context, [currentStart, currentEnd]);
                                  },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            disabledBackgroundColor: Colors.grey.shade300,
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: Text(
                            "Xác nhận",
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: isInvalid ? Colors.black38 : Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );

    if (result != null && result.length == 2) {
      setState(() {
        startDateTime = result[0];
        endDateTime = result[1];
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
        if (startDateTime == null || endDateTime == null) {
          showSnackBarError(context, "Vui lòng chọn khoảng thời gian");
          return;
        }
      }

      final String? machineParam = (currentOption == "dateHasMachine") ? widget.machine : null;

      if (widget.isBox) {
        await ReportPlanningService().exportExcelReportBox(
          fromDate: startDateTime,
          toDate: endDateTime,
          machine: machineParam,
        );
      } else {
        await ReportPlanningService().exportExcelReportPaper(
          fromDate: startDateTime,
          toDate: endDateTime,
          machine: machineParam,
        );
      }

      if (mounted) {
        showSnackBarSuccess(context, "Lưu thành công");
        widget.onPlanningIdsOrRangeDate();
        Navigator.of(context).pop();
      }
    } catch (e, s) {
      if (mounted) {
        AppLogger.e("Lỗi khi xuất báo cáo", error: e, stackTrace: s);
        showSnackBarError(context, "Lỗi: Không thể lưu dữ liệu");
      }
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
                // Option 1: Theo ngày từng máy
                RadioListTile<String>(
                  title: const Text("Theo Ngày (Từng Máy)", style: TextStyle(fontSize: 16)),
                  value: "dateHasMachine",
                ),

                // Option 2: Theo ngày tất cả máy
                RadioListTile<String>(
                  title: const Text("Theo Ngày (Tất Cả Máy)", style: TextStyle(fontSize: 16)),
                  value: "dateNoMachine",
                ),
                const SizedBox(height: 10),

                if (value == "dateHasMachine" || value == "dateNoMachine")
                  Column(
                    children: [
                      SizedBox(
                        width: 320,
                        height: 50,
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            side: BorderSide(color: Colors.blue.shade400, width: 1.5),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: () => pickDateTimeRange(context),
                          icon: Icon(Icons.date_range, color: Colors.blue.shade400),
                          label: Text(
                            (startDateTime == null || endDateTime == null)
                                ? "Chọn khoảng thời gian"
                                : "${DateFormat("dd/MM/yyyy HH:mm").format(startDateTime!)} - ${DateFormat("dd/MM/yyyy HH:mm").format(endDateTime!)}",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.blue.shade700,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 5),
                      if (startDateTime == null || endDateTime == null)
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
