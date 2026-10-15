import "package:dongtam/data/models/planning/planning_paper_model.dart";
import "package:dongtam/presentation/components/shared/dialog_shared.dart";
import "package:dongtam/presentation/components/shared/planning/handle_request_complete.dart";
import "package:dongtam/service/planning_service.dart";
import "package:dongtam/utils/helper/reponsive/reponsive_dialog.dart";
import "package:dongtam/utils/logger/app_logger.dart";
import "package:dongtam/utils/handleError/show_snack_bar.dart";
import "package:dongtam/utils/validation/validation_helper.dart";
import "package:flutter/material.dart";

class ChangeMachineDialog extends StatefulWidget {
  final List<PlanningPaperModel> planning;
  final VoidCallback onChangeMachine;

  const ChangeMachineDialog({super.key, required this.planning, required this.onChangeMachine});

  @override
  State<ChangeMachineDialog> createState() => _ChangeMachineDialogState();
}

class _ChangeMachineDialogState extends State<ChangeMachineDialog> {
  final formKey = GlobalKey<FormState>();
  late List<int> planningIds = [];

  late String machine = "Máy 1350";
  List<String> machineList = [];
  Map<String, int?> rawMachineMap = {};

  @override
  void initState() {
    super.initState();
    _loadRawMachine();

    planningIds = widget.planning.map((p) => p.planningId).toList();

    if (widget.planning.isNotEmpty) {
      machine = widget.planning.first.chooseMachine;
    }
  }

  Future<void> _loadRawMachine() async {
    await loadMachineDropdown(
      context: context,
      currentMachine: machine,
      onUpdate: (map, list, selected) {
        setState(() {
          rawMachineMap = map;
          machineList = list;
          if (selected != null) {
            machine = selected;
          }
        });
      },
    );
  }

  void submit() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    try {
      await PlanningService().changeMachinePlanning(
        newMachine: machine,
        planningIds: planningIds,
        action: "CHANGE_MACHINE",
      );

      if (!mounted) return; // check context
      showSnackBarSuccess(context, "Chuyển đơn hàng sang $machine thành công");

      if (!mounted) return; // check context
      widget.onChangeMachine();
      Navigator.of(context).pop();
    } catch (e, s) {
      if (!mounted) return; // check context
      AppLogger.e("Lỗi khi chuyển đơn hàng sang máy khác", error: e, stackTrace: s);
      showSnackBarError(context, "Lỗi: Không thể lưu dữ liệu");
    }
  }

  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(
      builder: (context, state) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          content: SizedBox(
            width: ResponsiveSize.getWidth(context, ResponsiveType.small),
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 10),
                    const Text(
                      "Chuyển máy",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                    ),
                    const SizedBox(height: 10),

                    // Danh sách Order đã chọn
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(10),
                      margin: const EdgeInsets.only(bottom: 15),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade400),
                      ),
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Đơn hàng cần chuyển máy:",
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            const SizedBox(height: 5),
                            ...widget.planning.map(
                              (p) => Padding(
                                padding: const EdgeInsets.symmetric(vertical: 2.0),
                                child: Row(
                                  children: [
                                    const Text("- Mã đơn hàng: ", style: TextStyle(fontSize: 16)),
                                    Text(
                                      p.orderId,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: Colors.red,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Dropdown chọn máy
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(10),
                      margin: const EdgeInsets.only(bottom: 15),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade400),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Chọn máy cần chuyển",
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          const SizedBox(height: 12),
                          ValidationHelper.dropdownForTypes(
                            items: machineList,
                            type: machine,
                            onChanged: (value) {
                              setState(() {
                                machine = value!;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
          ),
          actionsPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          actions: buildDialogActions(context: context, onConfirm: submit, confirmText: "Chuyển"),
        );
      },
    );
  }
}
