import 'package:dongtam/presentation/components/shared/dialog_shared.dart';
import 'package:dongtam/service/notification/notification_service.dart';
import 'package:dongtam/utils/handleError/show_snack_bar.dart';
import 'package:dongtam/utils/logger/app_logger.dart';
import 'package:flutter/material.dart';

class DialogOrderNotification extends StatefulWidget {
  final String orderId;
  final VoidCallback onLoading;

  const DialogOrderNotification({super.key, required this.orderId, required this.onLoading});

  @override
  State<DialogOrderNotification> createState() => _DialogOrderNotificationState();
}

class _DialogOrderNotificationState extends State<DialogOrderNotification> {
  final reasonController = TextEditingController();

  DateTime? selectedDate;
  ValueNotifier<String?> selectedOption = ValueNotifier<String?>(null);

  void pickDate(BuildContext context) async {
    final DateTime? result = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xffEA4346),
              onPrimary: Colors.white,
              onSurface: Colors.black87,
            ),
            dialogTheme: DialogThemeData(backgroundColor: Colors.white),
          ),
          child: child!,
        );
      },
    );

    if (result != null) {
      setState(() {
        selectedDate = result;
      });
    }
  }

  void submit() async {
    // Show loading
    showLoadingDialog(context);
    await Future.delayed(const Duration(seconds: 1));

    try {
      if (selectedOption.value == "changeDate") {
        if (selectedDate == null) {
          if (!mounted) return;
          showSnackBarError(context, "Vui lòng chọn ngày giao hàng mới");
          return;
        }
      }

      final bool success = await NotificationService().requestChangeInfoOrder(
        receiverId: 13,
        orderId: widget.orderId,
        requestType: "ORDER_CHANGE_DATE",
        newDeliveryDate: selectedDate,
        reason: reasonController.text,
      );

      if (success) {
        if (!mounted) return;
        Navigator.pop(context); // đóng dialog loading

        // Thông báo thành công
        showSnackBarSuccess(context, "Xuất dữ liệu thành công");

        if (!mounted) return; // check context
        Navigator.of(context).pop();
      }
    } catch (e, s) {
      if (!mounted) return; // check context
      AppLogger.e("Lỗi khi xử lý yêu cầu", error: e, stackTrace: s);
      showSnackBarError(context, "Đã xảy ra lỗi khi xử lý yêu cầu. Vui lòng thử lại sau.");
    }
  }

  @override
  void dispose() {
    selectedOption.dispose();
    reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      contentPadding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
      title: const Text(
        "Chọn loại yêu cầu",
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      content: SizedBox(
        width: 400,
        child: ValueListenableBuilder<String?>(
          valueListenable: selectedOption,
          builder: (context, value, _) {
            return RadioGroup<String>(
              groupValue: value,
              onChanged: (val) {
                if (val != null) selectedOption.value = val;
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildOptionCard(
                    context: context,
                    title: "Đổi ngày giao hàng",
                    subtitle: "Chọn mốc thời gian nhận hàng mới",
                    icon: Icons.calendar_today_rounded,
                    value: "changeDate",
                    groupValue: value,
                    onTap: () => selectedOption.value = "changeDate",
                    expandedContent: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // select date
                        const SizedBox(height: 12),
                        InkWell(
                          onTap: () => pickDate(context),
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.event_available_rounded,
                                  color: Colors.grey.shade700,
                                  size: 20,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    selectedDate == null
                                        ? "Bấm để chọn ngày giao mới"
                                        : "Ngày chọn: ${selectedDate!.day.toString().padLeft(2, '0')}/${selectedDate!.month.toString().padLeft(2, '0')}/${selectedDate!.year}",
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight:
                                          selectedDate == null
                                              ? FontWeight.normal
                                              : FontWeight.w600,
                                      color:
                                          selectedDate == null
                                              ? Colors.grey.shade600
                                              : Colors.blue.shade600,
                                    ),
                                  ),
                                ),
                                Icon(
                                  Icons.chevron_right_rounded,
                                  color: Colors.grey.shade500,
                                  size: 20,
                                ),
                              ],
                            ),
                          ),
                        ),

                        if (selectedDate == null) ...[
                          const SizedBox(height: 6),
                          const Padding(
                            padding: EdgeInsets.only(left: 4),
                            child: Row(
                              children: [
                                Icon(Icons.info_outline_rounded, size: 13, color: Colors.redAccent),
                                SizedBox(width: 4),
                                Text(
                                  "Vui lòng chọn ngày giao hàng",
                                  style: TextStyle(color: Colors.redAccent, fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                        ],

                        //text input
                        const SizedBox(height: 12),
                        TextField(
                          controller: reasonController,
                          maxLines: 3,
                          style: const TextStyle(fontSize: 14, color: Colors.black87),
                          decoration: InputDecoration(
                            hintText: "Nhập lý do thay đổi ngày",
                            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.all(12),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: Colors.grey.shade300),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: Colors.grey.shade300),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(color: Color(0xffEA4346), width: 1.2),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
      actionsPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      actionsAlignment: MainAxisAlignment.spaceBetween,
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(
            "Hủy",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black54),
          ),
        ),
        ElevatedButton(
          onPressed: submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xffEA4346),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            elevation: 0,
          ),
          child: const Text(
            "Xác nhận",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _buildOptionCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required String value,
    required String? groupValue,
    required VoidCallback onTap,
    Widget? expandedContent,
  }) {
    final isSelected = groupValue == value;

    return Container(
      decoration: BoxDecoration(
        color: isSelected ? Colors.grey.shade50 : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? Colors.grey.shade400 : Colors.grey.shade200,
          width: 1.0,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Row(
                children: [
                  // Icon biểu tượng phía trước
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.grey.shade200 : Colors.grey.shade100,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      icon,
                      size: 18,
                      color: isSelected ? Colors.black87 : Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Tiêu đề & Subtitle
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                      ],
                    ),
                  ),

                  // Nút Radio dùng tông đỏ chuẩn App
                  Radio<String>(
                    value: value,
                    groupValue: groupValue,
                    activeColor: const Color(0xffEA4346),
                    onChanged: (_) => onTap(),
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),

              // Nội dung đính kèm khi chọn (DatePicker / TextField)
              if (isSelected && expandedContent != null) expandedContent,
            ],
          ),
        ),
      ),
    );
  }
}
