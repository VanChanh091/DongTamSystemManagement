import 'package:dongtam/service/manufacture_service.dart';
import 'package:dongtam/utils/helper/confirm_dialog.dart';
import 'package:dongtam/utils/logger/app_logger.dart';
import 'package:dongtam/utils/handleError/show_snack_bar.dart';
import 'package:dongtam/utils/validation/validation_order.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

class DialogReportProduction extends StatefulWidget {
  final int planningId;
  final VoidCallback onReport;
  final String? machine;
  final bool isPaper;
  final int? qtyPaper;

  const DialogReportProduction({
    super.key,
    required this.planningId,
    required this.onReport,
    this.isPaper = true,
    this.machine,
    this.qtyPaper,
  });

  @override
  State<DialogReportProduction> createState() => _DialogReportProductionState();
}

class _DialogReportProductionState extends State<DialogReportProduction> {
  final formKey = GlobalKey<FormState>();

  final qtyProducedController = TextEditingController();
  final qtyWasteNormController = TextEditingController();
  final dayCompletedController = TextEditingController();
  final shiftProductionController = TextEditingController();
  late String shiftProduction = "Ca 1";
  final List<String> itemShiftProduction = ["Ca 1", "Ca 2", "Ca 3"];
  final shiftManagementController = TextEditingController();

  void submit() async {
    if (!formKey.currentState!.validate()) {
      AppLogger.w("Form không hợp lệ, dừng submit");
      return;
    }

    try {
      final int qtyProduced = int.tryParse(qtyProducedController.text) ?? 0;
      final double qtyWasteNorm = double.tryParse(qtyWasteNormController.text) ?? 0;

      final DateTime completedDate = DateTime.now();

      final Map<String, dynamic> reportData = {
        "shiftManagement": shiftManagementController.text,
        "shiftProduction": shiftProduction,
      };

      bool success;
      if (widget.isPaper == true) {
        AppLogger.i("Báo cáo sản xuất giấy tấm: ${widget.planningId}");
        success = await ManufactureService().createReportPaper(
          planningId: widget.planningId,
          qtyProduced: qtyProduced,
          qtyWasteNorm: qtyWasteNorm,
          dayCompleted: completedDate,
          reportData: reportData,
        );
      } else {
        if (widget.qtyPaper == null || widget.qtyPaper == 0) {
          final confirm = await showConfirmDialog(
            context: context,
            title: "⚠️ Thiếu số lượng giấy tấm",
            content:
                "Kế hoạch này chưa có số lượng giấy tấm.\n"
                "Bạn có chắc muốn tiếp tục báo cáo không?",
            confirmText: "Tiếp tục",
            cancelText: "Hủy",
          );

          if (confirm != true) {
            return;
          }
        }

        AppLogger.i("Báo cáo sản xuất thùng: ${widget.planningId}");
        success = await ManufactureService().createReportBox(
          planningBoxId: widget.planningId,
          machine: widget.machine ?? "",
          dayCompleted: completedDate,
          qtyProduced: qtyProduced,
          rpWasteLoss: qtyWasteNorm,
          shiftManagement: shiftManagementController.text,
        );
      }

      if (success) {
        if (!mounted) return;
        showSnackBarSuccess(context, 'Báo cáo sản xuất thành công');
        widget.onReport();
        Navigator.of(context).pop();
      }
    } catch (e, s) {
      if (!mounted) return;
      final message = e.toString();

      if (message.contains('403')) {
        showSnackBarError(context, 'Bạn không có quyền báo cáo máy này.');
      } else {
        AppLogger.e("Lỗi khi báo cáo sản xuất", error: e, stackTrace: s);
        showSnackBarError(context, 'Lỗi: Không thể lưu dữ liệu');
      }
    }
  }

  Widget validateInput(
    String label,
    TextEditingController controller,
    IconData icon, {
    VoidCallback? onTap,
  }) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(fontSize: 16),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontWeight: FontWeight.bold),
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        floatingLabelBehavior: FloatingLabelBehavior.always,
        fillColor: Colors.white,
        filled: true,
      ),
      validator: (value) {
        final text = value?.trim() ?? "";

        if (text.isEmpty) return "Vui lòng nhập $label";

        if (label == "Số Lượng Đã Sản Xuất") {
          if (!RegExp(r'^\d+$').hasMatch(text)) {
            return "Chỉ được nhập số nguyên dương";
          }
        } else if (label == "Phế Liệu Thực Tế") {
          if (!RegExp(r'^\d+([.]\d+)?$').hasMatch(text)) {
            return "Chỉ được nhập số thực, chỉ được dùng dấu chấm";
          }
        } else if (label == "Trưởng Máy") {
          if (!RegExp(r"^[a-zA-ZÀ-ỹ\s]+$").hasMatch(text)) {
            return "Chỉ được chứa chữ cái và khoảng trắng";
          }
        }

        return null;
      },
      onTap: onTap,
    );
  }

  @override
  void dispose() {
    super.dispose();
    qtyProducedController.dispose();
    qtyWasteNormController.dispose();
    dayCompletedController.dispose();
    shiftManagementController.dispose();
    shiftProductionController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Center(
        child: const Text(
          "Báo Cáo Sản Xuất",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
      ),
      content: SizedBox(
        width: 400,
        child: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              children: [
                const SizedBox(height: 15),
                validateInput(
                  "Số Lượng Đã Sản Xuất",
                  qtyProducedController,
                  Symbols.production_quantity_limits,
                ),
                const SizedBox(height: 15),

                validateInput("Phế Liệu Thực Tế", qtyWasteNormController, Symbols.box),
                const SizedBox(height: 15),

                validateInput("Trưởng Máy", shiftManagementController, Symbols.person),
                const SizedBox(height: 15),

                if (widget.isPaper) ...[
                  ValidationOrder.dropdownForTypes(
                    items: itemShiftProduction,
                    type: shiftProduction,
                    onChanged: (value) {
                      setState(() {
                        shiftProduction = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 10),
                ],
              ],
            ),
          ),
        ),
      ),
      actionsPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(
            "Hủy",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black54),
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
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),
          ),
        ),
      ],
    );
  }
}
