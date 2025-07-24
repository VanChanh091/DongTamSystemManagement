import 'package:dongtam/service/manufacture_service.dart';
import 'package:dongtam/utils/showSnackBar/show_snack_bar.dart';
import 'package:dongtam/utils/validation/validation_order.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

class DialogReportProduction extends StatefulWidget {
  final int planningId;
  final VoidCallback onReport;

  const DialogReportProduction({
    super.key,
    required this.planningId,
    required this.onReport,
  });

  @override
  State<DialogReportProduction> createState() => _DialogReportProductionState();
}

class _DialogReportProductionState extends State<DialogReportProduction> {
  final formKey = GlobalKey<FormState>();

  final qtyProducedController = TextEditingController();
  final qtyWasteNormController = TextEditingController();
  final dayCompletedController = TextEditingController();
  DateTime? dayCompleted;
  final shiftProductionController = TextEditingController();
  late String shiftProduction = "Ca 1";
  final List<String> itemShiftProduction = ["Ca 1", "Ca 2", "Ca 3"];
  final shiftManagementController = TextEditingController();

  void submit() async {
    if (!formKey.currentState!.validate()) return;

    try {
      final int qtyProduced = int.tryParse(qtyProducedController.text) ?? 0;
      final double qtyWasteNorm =
          double.tryParse(qtyWasteNormController.text) ?? 0;

      final DateTime completedDate = dayCompleted ?? DateTime.now();

      final Map<String, dynamic> reportData = {
        "shiftManagement": shiftManagementController.text,
        "shiftProduction": shiftProduction,
      };

      final success = await ManufactureService().createReportPaper(
        widget.planningId,
        qtyProduced,
        qtyWasteNorm,
        completedDate,
        reportData,
      );

      if (success) {
        showSnackBarSuccess(context, 'Báo cáo kế hoạch thành công');

        widget.onReport();
        Navigator.of(context).pop();
      }
    } catch (e) {
      print("Error: $e");
      showSnackBarError(context, 'Lỗi: Không thể lưu dữ liệu');
    }
  }

  Widget validateInput(
    String label,
    TextEditingController controller,
    IconData icon, {
    bool readOnly = false,
    VoidCallback? onTap,
  }) {
    final isFilled = controller.text.isEmpty;

    return StatefulBuilder(
      builder: (context, setSate) {
        controller.addListener(() {
          setState(() {}); // cập nhật mỗi khi text thay đổi
        });

        return TextFormField(
          controller: controller,
          readOnly: readOnly,
          decoration: InputDecoration(
            labelText: label,
            labelStyle: TextStyle(fontWeight: FontWeight.bold),
            prefixIcon: Icon(icon),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            floatingLabelBehavior: FloatingLabelBehavior.always,
            fillColor:
                readOnly
                    ? Colors.grey.shade300
                    : (isFilled
                        ? Colors.white
                        : Color.fromARGB(255, 148, 236, 154)),
            filled: true,
          ),
          onTap: onTap,
        );
      },
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
        child: Text(
          "Báo Cáo Sản Xuất",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
      ),
      content: SizedBox(
        width: 450,
        height: 500,
        child: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              children: [
                SizedBox(height: 15),
                validateInput(
                  "Số Lượng Thực tế",
                  qtyProducedController,
                  Symbols.production_quantity_limits,
                ),
                SizedBox(height: 15),

                validateInput(
                  "Phế Liệu Thực Tế",
                  qtyWasteNormController,
                  Symbols.box,
                ),
                SizedBox(height: 15),

                validateInput(
                  "Ngày Hoàn Thành",
                  dayCompletedController,
                  Symbols.calendar_month,
                  readOnly: true,
                  onTap: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2100),
                    );
                    if (pickedDate != null) {
                      setState(() {
                        dayCompleted = pickedDate;
                        dayCompletedController.text = DateFormat(
                          'dd/MM/yyyy',
                        ).format(pickedDate);
                      });
                    }
                  },
                ),
                SizedBox(height: 15),

                validateInput(
                  "Quản Ca",
                  shiftManagementController,
                  Symbols.person,
                ),
                SizedBox(height: 15),

                ValidationOrder.dropdownForTypes(
                  itemShiftProduction,
                  shiftProduction,
                  (value) {
                    setState(() {
                      shiftProduction = value!;
                    });
                  },
                ),
                SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
      actionsPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      actionsAlignment: MainAxisAlignment.spaceBetween,
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            "Hủy",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
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
              fontSize: 20,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}
