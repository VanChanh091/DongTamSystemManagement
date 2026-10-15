import "package:dongtam/data/controller/theme_controller.dart";
import "package:dongtam/data/models/order/order_model.dart";
import "package:dongtam/presentation/components/shared/dialog_shared.dart";
import "package:dongtam/service/planning_service.dart";
import "package:dongtam/utils/handleError/show_snack_bar.dart";
import "package:dongtam/utils/helper/reponsive/reponsive_dialog.dart";
import "package:dongtam/utils/validation/validation_helper.dart";
import "package:flutter/material.dart";
import "package:get/get.dart";
import "package:intl/intl.dart";

class DialogSummaryRequirement extends StatefulWidget {
  final String initialMachine;
  final List<String> machineList;

  const DialogSummaryRequirement({
    super.key,
    required this.initialMachine,
    required this.machineList,
  });

  @override
  State<DialogSummaryRequirement> createState() => _DialogSummaryRequirementState();
}

class _DialogSummaryRequirementState extends State<DialogSummaryRequirement> {
  final formKey = GlobalKey<FormState>();
  final ghepKhoController = TextEditingController();
  final dayStartController = TextEditingController();

  late String machine;
  DateTime selectedDate = DateTime.now();
  double? calculationResult;
  bool isCalculating = false;

  @override
  void initState() {
    super.initState();
    machine = widget.initialMachine;
    dayStartController.text = DateFormat("dd/MM/yyyy").format(selectedDate);
  }

  @override
  void dispose() {
    super.dispose();
    ghepKhoController.dispose();
    dayStartController.dispose();
  }

  Future<void> _submit() async {
    if (!formKey.currentState!.validate()) return;

    setState(() {
      isCalculating = true;
      calculationResult = null;
    });

    try {
      final ghepKho = int.parse(ghepKhoController.text.trim());
      final total = await PlanningService().calculateSummaryByGhepKho(
        ghepKho: ghepKho,
        machine: machine,
        dayStart: selectedDate,
      );

      setState(() {
        calculationResult = total ?? 0.0;
        isCalculating = false;
      });
    } catch (e) {
      setState(() => isCalculating = false);
      if (mounted) {
        showSnackBarError(context, "Lỗi khi tính toán định mức: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final dialogWidth = ResponsiveSize.getWidth(context, ResponsiveType.xSmall);
    final themeController = Get.find<ThemeController>();

    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Icon(Icons.calculate_outlined, color: themeController.currentColor.value),
          const SizedBox(width: 8),
          const Text(
            "Tính Tổng Định Mức",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
        ],
      ),
      content: SizedBox(
        width: dialogWidth,
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Dropdown chọn máy
              ValidationHelper.dropdownForTypes<String>(
                items: widget.machineList,
                type: machine,
                onChanged: (val) {
                  if (val != null) setState(() => machine = val);
                },
              ),
              const SizedBox(height: 12),

              // Ô nhập khổ ghép
              ValidationHelper.planningInput(
                controller: ghepKhoController,
                label: "Ghép Khổ",
                icon: Icons.straighten,
              ),
              const SizedBox(height: 12),

              // Chọn ngày bắt đầu
              ValidationHelper.adminInput(
                controller: dayStartController,
                label: "Ngày Sản Xuất",
                icon: Icons.calendar_today,
                readOnly: true,
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: selectedDate,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2100),
                    builder: (BuildContext context, Widget? child) {
                      return Theme(
                        data: Theme.of(context).copyWith(
                          colorScheme: const ColorScheme.light(
                            primary: Colors.blue,
                            onPrimary: Colors.white,
                            surface: Colors.white,
                            onSurface: Colors.black87,
                          ),
                          dialogTheme: const DialogThemeData(backgroundColor: Colors.white),
                          textButtonTheme: TextButtonThemeData(
                            style: TextButton.styleFrom(foregroundColor: Colors.blue),
                          ),
                        ),
                        child: child!,
                      );
                    },
                  );

                  if (picked != null) {
                    setState(() {
                      selectedDate = picked;
                      dayStartController.text = DateFormat("dd/MM/yyyy").format(picked);
                    });
                  }
                },
              ),

              // Hiển thị kết quả tính toán
              if (calculationResult != null) ...[
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Định mức giấy:",
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                      ),
                      Row(
                        children: [
                          Text(
                            OrderModel.formatCurrency(calculationResult!),
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade800,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            "Kg",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.blue.shade800,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      actionsPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      actions: buildDialogActions(
        context: context,
        isLoading: isCalculating,
        confirmText: "Tính toán",
        confirmColor: themeController.buttonColor.value,
        onConfirm: _submit,
      ),
    );
  }
}
