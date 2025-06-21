import 'package:dongtam/data/models/admin/admin_paperFactor_model.dart';
import 'package:dongtam/service/admin_Service.dart';
import 'package:dongtam/utils/showSnackBar/show_snack_bar.dart';
import 'package:dongtam/utils/validation/validation_admin.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

class UpdateAdminPFDialog extends StatefulWidget {
  final AdminPaperFactorModel? adminPaperFactorModel;
  final VoidCallback onPaperFactorUpdate;

  const UpdateAdminPFDialog({
    super.key,
    this.adminPaperFactorModel,
    required this.onPaperFactorUpdate,
  });

  @override
  State<UpdateAdminPFDialog> createState() => _UpdateAdminPFDialogState();
}

class _UpdateAdminPFDialogState extends State<UpdateAdminPFDialog> {
  final formKey = GlobalKey<FormState>();
  late int originalPaperFactorId;

  final paperFactorIdController = TextEditingController();
  final layerTypeController = TextEditingController();
  final paperTypeController = TextEditingController();
  final rollLossPercentController = TextEditingController();
  final processLossPercentController = TextEditingController();
  final coefficientController = TextEditingController();

  @override
  void initState() {
    super.initState();
    adminPaperFactorInitState();
  }

  void adminPaperFactorInitState() {
    originalPaperFactorId = widget.adminPaperFactorModel!.paperFactorId;
    paperFactorIdController.text = widget.adminPaperFactorModel!.paperFactorId
        .toStringAsFixed(1);
    layerTypeController.text = widget.adminPaperFactorModel!.layerType;
    paperTypeController.text = widget.adminPaperFactorModel!.paperType;
    rollLossPercentController.text =
        widget.adminPaperFactorModel!.rollLossPercent!.toString();
    processLossPercentController.text =
        widget.adminPaperFactorModel!.processLossPercent!.toString();
    coefficientController.text =
        widget.adminPaperFactorModel!.coefficient!.toString();
  }

  @override
  void dispose() {
    super.dispose();
    layerTypeController.dispose();
    paperTypeController.dispose();
    rollLossPercentController.dispose();
    processLossPercentController.dispose();
    coefficientController.dispose();
  }

  void submit() async {
    if (!formKey.currentState!.validate()) return;

    final updatedAdminPaperFactor = AdminPaperFactorModel(
      paperFactorId: 0,
      layerType: layerTypeController.text,
      paperType: paperTypeController.text,
      rollLossPercent: double.tryParse(rollLossPercentController.text),
      processLossPercent: double.tryParse(processLossPercentController.text),
      coefficient: int.tryParse(coefficientController.text),
    );
    try {
      await AdminService().updatePaperFactor(
        originalPaperFactorId,
        updatedAdminPaperFactor.toJson(),
      );
      showSnackBarSuccess(context, "Lưu thành công");

      widget.onPaperFactorUpdate();
      Navigator.of(context).pop();
    } catch (e) {
      print("Error: $e");
      showSnackBarError(context, 'Lỗi: Không thể lưu dữ liệu');
    }
  }

  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(
      builder: (context, setState) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          title: const Text("Cập nhật định mức giấy"),
          content: SizedBox(
            width: 350,
            height: 350,
            child: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(height: 10),
                    ValidationAdmin.validateInput(
                      "Loại lớp giấy",
                      paperTypeController,
                      Icons.layers,
                      readOnly: true,
                    ),
                    SizedBox(height: 10),

                    ValidationAdmin.validateInput(
                      "Số lớp giấy",
                      layerTypeController,
                      Icons.layers,
                      readOnly: true,
                    ),
                    SizedBox(height: 10),

                    ValidationAdmin.validateInput(
                      "Hệ số giấy",
                      coefficientController,
                      Symbols.numbers,
                    ),
                    SizedBox(height: 10),

                    ValidationAdmin.validateInput(
                      "% Chạy quấn cuồn",
                      rollLossPercentController,
                      Symbols.percent,
                    ),
                    SizedBox(height: 10),

                    ValidationAdmin.validateInput(
                      "% Quá trình chạy",
                      processLossPercentController,
                      Symbols.percent,
                    ),
                    SizedBox(height: 10),
                  ],
                ),
              ),
            ),
          ),
          actionsPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          actionsAlignment: MainAxisAlignment.spaceBetween,
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                "Hủy",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.red,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: EdgeInsets.symmetric(horizontal: 15, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                "Lưu",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
