import 'package:dongtam/presentation/components/shared/dialog_shared.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

Future<DateTime?> showMonthYearPickerDialog({
  required BuildContext context,
  required int initialMonth,
  required int initialYear,
  Color accentColor = const Color.fromARGB(255, 177, 116, 69),
}) {
  return showDialog<DateTime>(
    context: context,
    builder:
        (ctx) => DialogPickerMonth(
          initialMonth: initialMonth,
          initialYear: initialYear,
          accentColor: accentColor,
        ),
  );
}

class DialogPickerMonth extends StatefulWidget {
  final int initialMonth;
  final int initialYear;
  final Color accentColor;

  const DialogPickerMonth({
    super.key,
    required this.initialMonth,
    required this.initialYear,
    required this.accentColor,
  });

  @override
  State<DialogPickerMonth> createState() => DialogPickerMonthState();
}

class DialogPickerMonthState extends State<DialogPickerMonth> {
  late DateTime _tempDate;
  late DateRangePickerController _pickerController;

  @override
  void initState() {
    super.initState();
    _tempDate = DateTime(widget.initialYear, widget.initialMonth);
    _pickerController =
        DateRangePickerController()
          ..selectedDate = _tempDate
          ..displayDate = _tempDate;
  }

  @override
  void dispose() {
    _pickerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const calendarBgColor = Color(0xFFF5F5F7);

    return AlertDialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),

      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: widget.accentColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.calendar_month_rounded, size: 18, color: widget.accentColor),
              ),
              const SizedBox(width: 10),
              const Text(
                "Chọn kỳ báo cáo",
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1E293B),
                ),
              ),
            ],
          ),
          TextButton.icon(
            onPressed: () {
              final now = DateTime.now();
              setState(() {
                _tempDate = DateTime(now.year, now.month);
                _pickerController.selectedDate = _tempDate;
                _pickerController.displayDate = _tempDate;
              });
            },
            icon: Icon(Icons.history_rounded, size: 16, color: widget.accentColor),
            label: Text(
              "Hiện tại",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: widget.accentColor,
              ),
            ),
            style: TextButton.styleFrom(
              visualDensity: VisualDensity.compact,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            ),
          ),
        ],
      ),

      content: SizedBox(
        width: 380,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- PREVIEW THÁNG ĐANG CHỌN ---
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: calendarBgColor,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                  const Text(
                    "Thời gian đã chọn: ",
                    style: TextStyle(fontSize: 12.5, color: Color(0xFF64748B)),
                  ),
                  Text(
                    "Tháng ${_tempDate.month}, ${_tempDate.year}",
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.bold,
                      color: widget.accentColor,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // --- SYNCFUSION PICKER ---
            Container(
              height: 250,
              decoration: BoxDecoration(
                color: calendarBgColor,
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: SfDateRangePicker(
                controller: _pickerController,
                view: DateRangePickerView.year,
                allowViewNavigation: false,
                showNavigationArrow: true,
                navigationDirection: DateRangePickerNavigationDirection.horizontal,
                selectionMode: DateRangePickerSelectionMode.single,
                selectionColor: Colors.transparent,
                todayHighlightColor: Colors.transparent,
                backgroundColor: Colors.transparent,
                headerHeight: 40,
                headerStyle: const DateRangePickerHeaderStyle(
                  backgroundColor: Colors.transparent,
                  textAlign: TextAlign.center,
                  textStyle: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
                cellBuilder: (context, details) {
                  final isSelected =
                      details.date.year == _tempDate.year && details.date.month == _tempDate.month;
                  final now = DateTime.now();
                  final isCurrentMonth =
                      details.date.year == now.year && details.date.month == now.month;

                  return Container(
                    margin: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: isSelected ? widget.accentColor : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      border:
                          !isSelected && isCurrentMonth
                              ? Border.all(
                                color: widget.accentColor.withValues(alpha: 0.5),
                                width: 1.2,
                              )
                              : null,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      "Tháng ${details.date.month}",
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight:
                            isSelected || isCurrentMonth ? FontWeight.w600 : FontWeight.w500,
                        color:
                            isSelected
                                ? Colors.white
                                : (isCurrentMonth ? widget.accentColor : const Color(0xFF334155)),
                      ),
                    ),
                  );
                },
                onSelectionChanged: (args) {
                  if (args.value is DateTime) {
                    setState(() {
                      _tempDate = args.value;
                      _pickerController.selectedDate = _tempDate;
                    });
                  }
                },
              ),
            ),
          ],
        ),
      ),

      actions: buildDialogActions(
        context: context,
        onConfirm: () => Navigator.pop(context, _tempDate),
      ),
    );
  }
}
