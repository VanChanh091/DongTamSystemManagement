import "package:dongtam/service/planning_service.dart";
import "package:dongtam/utils/logger/app_logger.dart";
import "package:dongtam/utils/handleError/show_snack_bar.dart";
import "package:flutter/material.dart";

class DialogExportPlanning extends StatefulWidget {
  final String machine;
  final VoidCallback onSubmit;

  const DialogExportPlanning({super.key, required this.machine, required this.onSubmit});

  @override
  State<DialogExportPlanning> createState() => _DialogExportPlanningState();
}

class _DialogExportPlanningState extends State<DialogExportPlanning> {
  ValueNotifier<String?> selectedOption = ValueNotifier<String?>(null);

  void submit() async {
    try {
      final currentOption = selectedOption.value;

      if (currentOption == null) {
        showSnackBarError(context, "Vui lòng chọn phương thức xuất báo cáo");
        return;
      }

      await PlanningService().exportPlanningExcel(
        machine: widget.machine,
        isAll: currentOption == "all" ? true : false,
      );
      if (mounted) {
        showSnackBarSuccess(context, "Lưu thành công");

        if (!mounted) return; // check context
        widget.onSubmit();
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
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text("Xuất Lịch Sản Xuất"),
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
                RadioListTile<String>(
                  title: const Text("Lịch Sản Xuất (Rút Gọn)", style: TextStyle(fontSize: 16)),
                  value: "partial",
                ),
                RadioListTile<String>(
                  title: const Text("Lịch Sản Xuất (Đầy Đủ)", style: TextStyle(fontSize: 16)),
                  value: "all",
                ),
                const SizedBox(height: 10),
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
