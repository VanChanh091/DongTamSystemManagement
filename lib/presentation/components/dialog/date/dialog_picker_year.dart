import 'package:dongtam/presentation/components/shared/dialog_shared.dart';
import 'package:flutter/material.dart';

class YearRangeResult {
  final int fromYear;
  final int toYear;

  const YearRangeResult({required this.fromYear, required this.toYear});

  int get totalYears => toYear - fromYear + 1;
}

Future<YearRangeResult?> showYearRangePickerDialog({
  required BuildContext context,
  required int initialFromYear,
  required int initialToYear,
  int maxYears = 3,
  Color accentColor = const Color.fromARGB(255, 177, 116, 69),
}) {
  return showDialog<YearRangeResult>(
    context: context,
    builder:
        (ctx) => DialogPickerYearRange(
          initialFromYear: initialFromYear,
          initialToYear: initialToYear,
          maxYears: maxYears,
          accentColor: accentColor,
        ),
  );
}

class DialogPickerYearRange extends StatefulWidget {
  final int initialFromYear;
  final int initialToYear;
  final int maxYears;
  final Color accentColor;

  const DialogPickerYearRange({
    super.key,
    required this.initialFromYear,
    required this.initialToYear,
    this.maxYears = 3,
    required this.accentColor,
  });

  @override
  State<DialogPickerYearRange> createState() => _DialogPickerYearRangeState();
}

class _DialogPickerYearRangeState extends State<DialogPickerYearRange> {
  late int _startYear;
  late int _endYear;
  late int _decadeStart;
  bool _isSelectingEnd = false;

  @override
  void initState() {
    super.initState();
    _startYear = widget.initialFromYear;
    _endYear = widget.initialToYear;
    _decadeStart = (_startYear ~/ 10) * 10;
  }

  void _onYearTapped(int year) {
    setState(() {
      if (!_isSelectingEnd) {
        // Bước 1: Chọn năm bắt đầu (chỉ chọn 1 năm)
        _startYear = year;
        _endYear = year;
        _isSelectingEnd = true;
      } else {
        // Bước 2: Chọn năm kết thúc
        if (year == _startYear) {
          _endYear = year;
          _isSelectingEnd = false;
        } else if (year > _startYear) {
          if (year - _startYear + 1 <= widget.maxYears) {
            _endYear = year;
            _isSelectingEnd = false;
          } else {
            // Quá 3 năm -> Bắt đầu mốc mới tại năm vừa nhấn
            _startYear = year;
            _endYear = year;
            _isSelectingEnd = true;
          }
        } else {
          // year < _startYear
          if (_startYear - year + 1 <= widget.maxYears) {
            _endYear = _startYear;
            _startYear = year;
            _isSelectingEnd = false;
          } else {
            _startYear = year;
            _endYear = year;
            _isSelectingEnd = true;
          }
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    const calendarBgColor = Color(0xFFF5F5F7);
    final totalYears = _endYear - _startYear + 1;
    final now = DateTime.now().year;

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
                child: Icon(Icons.calendar_today_rounded, size: 18, color: widget.accentColor),
              ),
              const SizedBox(width: 10),
              const Text(
                "Chọn năm báo cáo",
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
              setState(() {
                _startYear = now;
                _endYear = now;
                _isSelectingEnd = false;
                _decadeStart = (now ~/ 10) * 10;
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
            // --- PREVIEW KHOẢNG NĂM ĐANG CHỌN ---
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: calendarBgColor,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Text(
                        "Thời gian: ",
                        style: TextStyle(fontSize: 12.5, color: Color(0xFF64748B)),
                      ),
                      Text(
                        _startYear == _endYear
                            ? "Năm $_startYear"
                            : "Năm $_startYear - $_endYear ($totalYears năm)",
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.bold,
                          color: widget.accentColor,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    "(Tối đa ${widget.maxYears} năm)",
                    style: TextStyle(
                      fontSize: 11.5,
                      fontStyle: FontStyle.italic,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // --- DECADE HEADER VÀ GRID ---
            Container(
              decoration: BoxDecoration(
                color: calendarBgColor,
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(10),
              child: Column(
                children: [
                  // Thanh điều hướng thập kỷ
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: () => setState(() => _decadeStart -= 10),
                        icon: const Icon(Icons.chevron_left, size: 22),
                        splashRadius: 18,
                      ),
                      Text(
                        "$_decadeStart - ${_decadeStart + 9}",
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      IconButton(
                        onPressed: () => setState(() => _decadeStart += 10),
                        icon: const Icon(Icons.chevron_right, size: 22),
                        splashRadius: 18,
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),

                  // Lưới 12 năm
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 6,
                      childAspectRatio: 1.8,
                    ),
                    itemCount: 12,
                    itemBuilder: (context, index) {
                      final year = _decadeStart - 1 + index;
                      final isCurrentYear = year == now;
                      final isStart = year == _startYear;
                      final isEnd = year == _endYear;
                      final isInRange = year >= _startYear && year <= _endYear;
                      final isOutOfDecade = year < _decadeStart || year > _decadeStart + 9;

                      Color bgColor = Colors.transparent;
                      Color textColor =
                          isOutOfDecade ? Colors.grey.shade400 : const Color(0xFF334155);
                      BorderRadius? borderRadius;

                      if (isStart && isEnd) {
                        bgColor = widget.accentColor;
                        textColor = Colors.white;
                        borderRadius = BorderRadius.circular(8);
                      } else if (isStart) {
                        bgColor = widget.accentColor;
                        textColor = Colors.white;
                        borderRadius = const BorderRadius.horizontal(left: Radius.circular(8));
                      } else if (isEnd) {
                        bgColor = widget.accentColor;
                        textColor = Colors.white;
                        borderRadius = const BorderRadius.horizontal(right: Radius.circular(8));
                      } else if (isInRange) {
                        bgColor = widget.accentColor.withValues(alpha: 0.18);
                        textColor = widget.accentColor;
                      } else if (isCurrentYear) {
                        textColor = widget.accentColor;
                      }

                      return InkWell(
                        onTap: () => _onYearTapped(year),
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          decoration: BoxDecoration(
                            color: bgColor,
                            borderRadius: borderRadius,
                            border:
                                !isInRange && isCurrentYear
                                    ? Border.all(
                                      color: widget.accentColor.withValues(alpha: 0.5),
                                      width: 1.2,
                                    )
                                    : null,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            "$year",
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight:
                                  isInRange || isCurrentYear ? FontWeight.w600 : FontWeight.w500,
                              color: textColor,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: buildDialogActions(
        context: context,
        onConfirm:
            () => Navigator.pop(
              context,
              YearRangeResult(fromYear: _startYear, toYear: _endYear),
            ),
      ),
    );
  }
}
