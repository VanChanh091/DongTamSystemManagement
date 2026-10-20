import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PickerDateHelper extends StatefulWidget {
  final TextEditingController? controller;
  final DateTime? startDate;
  final DateTime? endDate;
  final ValueChanged<DateTimeRange> onDateRangeChanged;
  final double? width;
  final double height;
  final String hintText;
  final String dateFormat;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final InputDecoration? decoration;
  final TextStyle? textStyle;

  const PickerDateHelper({
    super.key,
    this.controller,
    this.startDate,
    this.endDate,
    required this.onDateRangeChanged,
    this.width,
    this.height = 50,
    this.hintText = 'Chọn ngày...',
    this.dateFormat = 'dd/MM/yyyy',
    this.firstDate,
    this.lastDate,
    this.decoration,
    this.textStyle,
  });

  @override
  State<PickerDateHelper> createState() => _PickerDateHelpersState();
}

class _PickerDateHelpersState extends State<PickerDateHelper> {
  TextEditingController? _internalController;
  TextEditingController get _effectiveController => widget.controller ?? _internalController!;

  @override
  void initState() {
    super.initState();
    if (widget.controller == null) {
      _internalController = TextEditingController();
    }
    _updateText();
  }

  @override
  void didUpdateWidget(covariant PickerDateHelper oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller == null && _internalController == null) {
      _internalController = TextEditingController();
    } else if (widget.controller != null && _internalController != null) {
      _internalController!.dispose();
      _internalController = null;
    }
    if (oldWidget.startDate != widget.startDate ||
        oldWidget.endDate != widget.endDate ||
        oldWidget.dateFormat != widget.dateFormat) {
      _updateText();
    }
  }

  void _updateText() {
    final newText = (widget.startDate != null && widget.endDate != null)
        ? '${DateFormat(widget.dateFormat).format(widget.startDate!)} - ${DateFormat(widget.dateFormat).format(widget.endDate!)}'
        : '';
    if (_effectiveController.text != newText) {
      _effectiveController.text = newText;
    }
  }

  @override
  void dispose() {
    _internalController?.dispose();
    super.dispose();
  }

  Future<void> _handleTap() async {
    final now = DateTime.now();
    final size = MediaQuery.of(context).size;

    final initialRange =
        (widget.startDate != null && widget.endDate != null)
            ? DateTimeRange(start: widget.startDate!, end: widget.endDate!)
            : DateTimeRange(start: now.subtract(const Duration(days: 7)), end: now);

    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: widget.firstDate ?? DateTime(2020),
      lastDate: widget.lastDate ?? DateTime(2100),
      initialDateRange: initialRange,
      saveText: "Áp dụng",
      helpText: "Chọn khoảng thời gian",
      builder: (context, child) {
        // Tự động co giãn theo thiết bị (Desktop/Web: 0.35, Mobile: 0.9)
        final isMobile = size.width < 600;
        final maxWidth = isMobile ? size.width * 0.9 : size.width * 0.35;

        const primaryColor = Color.fromARGB(255, 80, 161, 59); // Xanh lá đậm
        const rangeColor = Color.fromARGB(255, 225, 245, 227); // Xanh nhạt cho dải ở giữa
        const textColor = Color(0xFF1F2937);

        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: primaryColor,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: textColor,
              primaryContainer: rangeColor,
              onPrimaryContainer: const Color.fromARGB(255, 80, 161, 59),
            ),
            datePickerTheme: DatePickerThemeData(
              // Nền tổng thể
              backgroundColor: Colors.white,
              elevation: 6,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),

              // Phần tiêu đề
              rangePickerHeaderBackgroundColor: primaryColor,
              rangePickerHeaderForegroundColor: Colors.white,
              rangePickerHeaderHelpStyle: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              rangePickerHeaderHeadlineStyle: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),

              // Dải ngày đang được chọn
              rangeSelectionBackgroundColor: rangeColor,

              // Màu ngày hiện tại
              todayBorder: const BorderSide(color: primaryColor, width: 1.5),
              todayForegroundColor: WidgetStateProperty.all(primaryColor),

              // Nút bấm xác nhận / đóng
              confirmButtonStyle: TextButton.styleFrom(
                foregroundColor: Colors.white,
                textStyle: const TextStyle(fontWeight: FontWeight.bold),
              ),
              cancelButtonStyle: TextButton.styleFrom(foregroundColor: Colors.white),
            ),
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxWidth * 0.8, maxHeight: size.height * 0.8),
              child: Material(
                borderRadius: BorderRadius.circular(16),
                clipBehavior: Clip.antiAlias,
                child: child!,
              ),
            ),
          ),
        );
      },
    );

    if (picked != null) {
      widget.onDateRangeChanged(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final defaultDecoration = InputDecoration(
      hintText: widget.hintText,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      suffixIcon: const Icon(Icons.calendar_today, size: 20),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12),
    );

    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: InkWell(
        onTap: _handleTap,
        borderRadius: BorderRadius.circular(12),
        child: IgnorePointer(
          child: TextField(
            controller: _effectiveController,
            textAlignVertical: TextAlignVertical.center,
            style: widget.textStyle,
            decoration: widget.decoration ?? defaultDecoration,
          ),
        ),
      ),
    );
  }
}
