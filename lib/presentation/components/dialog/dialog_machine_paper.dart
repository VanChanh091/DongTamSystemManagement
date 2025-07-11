import 'package:dongtam/data/models/admin/admin_machinePaper_model.dart';
import 'package:dongtam/service/admin_service.dart';
import 'package:dongtam/utils/showSnackBar/show_snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

class DialogMachinePaper extends StatefulWidget {
  final AdminMachinePaperModel? machine;
  final VoidCallback onUpdateMachine;

  const DialogMachinePaper({
    super.key,
    this.machine,
    required this.onUpdateMachine,
  });

  @override
  State<DialogMachinePaper> createState() => _DialogMachinePaperState();
}

class _DialogMachinePaperState extends State<DialogMachinePaper> {
  final formKey = GlobalKey<FormState>();
  late int originalMachineId;
  late String machineName = widget.machine!.machineName;

  final machineNameController = TextEditingController();
  final timeChangeSizeController = TextEditingController();
  final timeChangeSameSizeController = TextEditingController();
  final speed2LayerController = TextEditingController();
  final speed3LayerController = TextEditingController();
  final speed4LayerController = TextEditingController();
  final speed5LayerController = TextEditingController();
  final speed6LayerController = TextEditingController();
  final speed7LayerController = TextEditingController();
  final paperRollSpeedController = TextEditingController();
  final machinePerformanceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    machineInitState();
  }

  void machineInitState() {
    originalMachineId = widget.machine!.machineId;
    machineNameController.text = widget.machine!.machineName;
    timeChangeSizeController.text = widget.machine!.timeChangeSize.toString();
    timeChangeSameSizeController.text =
        widget.machine!.timeChangeSameSize.toString();
    speed2LayerController.text = widget.machine!.speed2Layer.toString();
    speed3LayerController.text = widget.machine!.speed3Layer.toString();
    speed4LayerController.text = widget.machine!.speed4Layer.toString();
    speed5LayerController.text = widget.machine!.speed5Layer.toString();
    speed6LayerController.text = widget.machine!.speed6Layer.toString();
    speed7LayerController.text = widget.machine!.speed7Layer.toString();
    paperRollSpeedController.text = widget.machine!.paperRollSpeed.toString();
    machinePerformanceController.text =
        widget.machine!.machinePerformance.toString();
  }

  void submit() async {
    if (!formKey.currentState!.validate()) return;

    final updateMachine = AdminMachinePaperModel(
      machineId: 0,
      machineName: machineNameController.text,
      timeChangeSize: int.tryParse(timeChangeSizeController.text) ?? 0,
      timeChangeSameSize: int.tryParse(timeChangeSameSizeController.text) ?? 0,
      speed2Layer: int.tryParse(speed2LayerController.text) ?? 0,
      speed3Layer: int.tryParse(speed3LayerController.text) ?? 0,
      speed4Layer: int.tryParse(speed4LayerController.text) ?? 0,
      speed5Layer: int.tryParse(speed5LayerController.text) ?? 0,
      speed6Layer: int.tryParse(speed6LayerController.text) ?? 0,
      speed7Layer: int.tryParse(speed7LayerController.text) ?? 0,
      paperRollSpeed: int.tryParse(paperRollSpeedController.text) ?? 0,
      machinePerformance:
          double.tryParse(machinePerformanceController.text) ?? 0,
    );

    try {
      await AdminService().updateMachine(
        originalMachineId,
        updateMachine.toJson(),
      );
      showSnackBarSuccess(context, "Cập nhật thành công");

      widget.onUpdateMachine();
      Navigator.of(context).pop();
    } catch (e) {
      print("Error: $e");
      showSnackBarError(context, 'Lỗi: Không thể lưu dữ liệu');
    }
  }

  @override
  void dispose() {
    super.dispose();
    machineNameController.dispose();
    timeChangeSizeController.dispose();
    timeChangeSameSizeController.dispose();
    speed2LayerController.dispose();
    speed3LayerController.dispose();
    speed4LayerController.dispose();
    speed5LayerController.dispose();
    speed6LayerController.dispose();
    speed7LayerController.dispose();
    paperRollSpeedController.dispose();
    machinePerformanceController.dispose();
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
          title: Center(
            child: Text(
              machineNameController.text,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 22,
                color: Colors.red,
              ),
            ),
          ),
          content: SizedBox(
            width: 460,
            height: 520,
            child: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(height: 10),
                    validateInput(
                      "Thời gian đổi khổ",
                      timeChangeSizeController,
                      Symbols.time_auto_sharp,
                    ),
                    SizedBox(height: 10),

                    if (machineName != "Máy Quấn Cuồn") ...[
                      validateInput(
                        "Thời gian đổi mã hàng cùng khổ",
                        timeChangeSameSizeController,
                        Symbols.time_auto_sharp,
                      ),
                      SizedBox(height: 10),
                    ],

                    validateInput(
                      "Hiệu suất máy",
                      machinePerformanceController,
                      Symbols.time_auto_sharp,
                    ),
                    SizedBox(height: 10),

                    Text(
                      "Tốc độ máy chạy",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    SizedBox(height: 10),

                    if (machineName == "Máy 2 Lớp") ...[
                      validateInput(
                        "Giấy 2 lớp",
                        speed2LayerController,
                        Symbols.time_auto_sharp,
                      ),
                      SizedBox(height: 10),
                    ],

                    if (machineName == "Máy 1900" ||
                        machineName == "Máy 1350") ...[
                      validateInput(
                        "Giấy 3 lớp",
                        speed3LayerController,
                        Symbols.time_auto_sharp,
                      ),
                      SizedBox(height: 10),

                      validateInput(
                        "Giấy 4 lớp",
                        speed4LayerController,
                        Symbols.time_auto_sharp,
                      ),
                      SizedBox(height: 10),

                      validateInput(
                        "Giấy 5 lớp",
                        speed5LayerController,
                        Symbols.time_auto_sharp,
                      ),
                      SizedBox(height: 10),

                      validateInput(
                        "Giấy 6 lớp",
                        speed6LayerController,
                        Symbols.time_auto_sharp,
                      ),
                      SizedBox(height: 10),

                      validateInput(
                        "Giấy 7 lớp",
                        speed7LayerController,
                        Symbols.time_auto_sharp,
                      ),
                      SizedBox(height: 10),
                    ],

                    if (machineName == "Máy Quấn Cuồn") ...[
                      validateInput(
                        "Tốc độ quấn cuồn",
                        paperRollSpeedController,
                        Symbols.time_auto_sharp,
                      ),
                      SizedBox(height: 10),
                    ],
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
                  fontSize: 18,
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
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget validateInput(
    String label,
    TextEditingController controller,
    IconData icon,
  ) {
    return StatefulBuilder(
      builder: (context, setState) {
        controller.addListener(() {
          setState(() {});
        });
        // final isFilled = controller.text.isEmpty;

        return TextFormField(
          controller: controller,
          decoration: InputDecoration(
            labelText: label,
            labelStyle: TextStyle(fontWeight: FontWeight.bold),
            prefixIcon: Icon(icon),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            floatingLabelBehavior: FloatingLabelBehavior.always,
            // fillColor:
            //     isFilled ? Colors.white : Color.fromARGB(255, 148, 236, 154),
            fillColor: Colors.grey[100],
            filled: true,
          ),
        );
      },
    );
  }
}
