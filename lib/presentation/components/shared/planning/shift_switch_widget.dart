import "package:dongtam/data/models/qualityControl/qc_shift.dart";
import "package:dongtam/presentation/components/shared/dialog_shared.dart";
import "package:dongtam/utils/handleError/show_snack_bar.dart";
import "package:flutter/material.dart";

class ShiftSwitchWidget extends StatefulWidget {
  final Future<QcShiftModel?> Function() getCurrentShift;
  final Future<bool> Function() onStartShift;
  final Future<bool> Function() onEndShift;

  const ShiftSwitchWidget({
    super.key,
    required this.getCurrentShift,
    required this.onStartShift,
    required this.onEndShift,
  });

  @override
  State<ShiftSwitchWidget> createState() => _ShiftSwitchWidgetState();
}

class _ShiftSwitchWidgetState extends State<ShiftSwitchWidget> {
  QcShiftModel? _currentShift;
  bool _isLoading = true;

  bool get _isActive => _currentShift?.isActive ?? false;

  @override
  void initState() {
    super.initState();
    _fetchCurrentShift();
  }

  // Lấy dữ liệu ca hiện tại
  Future<void> _fetchCurrentShift() async {
    try {
      final shift = await widget.getCurrentShift();
      if (mounted) {
        setState(() {
          _currentShift = shift;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // Xử lý bật/tắt switch
  Future<void> _handleToggle(bool value) async {
    if (_isLoading) return;

    if (value) {
      // Vào ca
      await _executeShiftAction(
        action: widget.onStartShift,
        successMsg: "Bắt đầu ca làm việc thành công",
      );
    } else {
      // Kết thúc ca
      final bool confirm = await showConfirmDialog(
        context: context,
        title: "Kết thúc ca làm việc",
        content: "Xác nhận kết thúc ca làm việc hiện tại?",
        confirmText: "Kết thúc ca",
      );

      if (confirm == true) {
        await _executeShiftAction(action: widget.onEndShift, successMsg: "Đã kết thúc ca làm việc");
      }
    }
  }

  Future<void> _executeShiftAction({
    required Future<bool> Function() action,
    required String successMsg,
  }) async {
    setState(() => _isLoading = true);
    try {
      final success = await action();
      if (!mounted) return;

      if (success) {
        // Sau khi start/end thành công, gọi lại getCurrentShift để đồng bộ model mới nhất
        final updatedShift = await widget.getCurrentShift();
        if (mounted) {
          setState(() {
            _currentShift = updatedShift;
            _isLoading = false;
          });

          showSnackBarSuccess(context, successMsg);
        }
      } else {
        setState(() => _isLoading = false);
        showSnackBarError(context, "Thao tác thất bại, vui lòng thử lại!");
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      showSnackBarError(context, "Lỗi chưa xác định, vui lòng thử lại sau!");
    }
  }

  String _formatDateTime(DateTime dt) {
    return "${dt.hour.toString().padLeft(2, "0")}:${dt.minute.toString().padLeft(2, "0")} ${dt.day}/${dt.month}/${dt.year}";
  }

  @override
  Widget build(BuildContext context) {
    final Color activeColor = Colors.green.shade600;
    final Color inactiveColor = Colors.grey.shade500;
    final Color bgColor = _isActive ? Colors.green.shade50 : Colors.grey.shade100;
    final Color borderColor = _isActive ? Colors.green.shade200 : Colors.grey.shade300;

    final String tooltipMessage =
        _isActive
            ? "QC: ${_currentShift?.username.isNotEmpty == true ? _currentShift!.username : "Đang hoạt động"}\nBắt đầu: ${_currentShift?.startedAt != null ? _formatDateTime(_currentShift!.startedAt!) : "Không xác định"}"
            : "Chưa kích hoạt ca làm việc";

    return Tooltip(
      message: tooltipMessage,
      waitDuration: const Duration(milliseconds: 300),
      child: Material(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: _isLoading ? null : () => _handleToggle(!_isActive),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: borderColor, width: 1),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Status dot indicator
                Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _isActive ? activeColor : inactiveColor,
                    boxShadow:
                        _isActive
                            ? [
                              BoxShadow(
                                color: activeColor.withValues(alpha: 0.5),
                                blurRadius: 4,
                                spreadRadius: 1,
                              ),
                            ]
                            : null,
                  ),
                ),
                const SizedBox(width: 6),

                // Status label
                Text(
                  _isActive ? "Đang trong ca" : "Chưa vào ca",
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: _isActive ? Colors.green.shade800 : Colors.grey.shade700,
                  ),
                ),
                const SizedBox(width: 8),

                // Mini animated custom switch
                _isLoading
                    ? SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: _isActive ? activeColor : inactiveColor,
                      ),
                    )
                    : AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 32,
                      height: 18,
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: _isActive ? activeColor : Colors.grey.shade300,
                      ),
                      child: AnimatedAlign(
                        duration: const Duration(milliseconds: 200),
                        alignment: _isActive ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          width: 14,
                          height: 14,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(color: Colors.black26, blurRadius: 2, offset: Offset(0, 1)),
                            ],
                          ),
                        ),
                      ),
                    ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
