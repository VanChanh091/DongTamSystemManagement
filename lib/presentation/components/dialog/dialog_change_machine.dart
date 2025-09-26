import 'package:dongtam/data/models/planning/planning_paper_model.dart';
import 'package:dongtam/service/planning_service.dart';
import 'package:dongtam/utils/logger/app_logger.dart';
import 'package:dongtam/utils/showSnackBar/show_snack_bar.dart';
import 'package:dongtam/utils/validation/validation_order.dart';
import 'package:flutter/material.dart';

class ChangeMachineDialog extends StatefulWidget {
  final List<PlanningPaper> planning;
  final VoidCallback onChangeMachine;

  const ChangeMachineDialog({
    super.key,
    required this.planning,
    required this.onChangeMachine,
  });

  @override
  State<ChangeMachineDialog> createState() => _ChangeMachineDialogState();
}

class _ChangeMachineDialogState extends State<ChangeMachineDialog> {
  final formKey = GlobalKey<FormState>();
  late List<int> planningIds = [];
  final List<String> machineList = [
    'Máy 1350',
    'Máy 1900',
    'Máy 2 Lớp',
    "Máy Quấn Cuồn",
  ];

  //planning
  late String chooseMachine = 'Máy 1350';

  @override
  void initState() {
    super.initState();

    planningIds = widget.planning.map((p) => p.planningId).toList();

    if (widget.planning.isNotEmpty) {
      chooseMachine = widget.planning.first.chooseMachine;
    }
  }

  void submit() async {
    if (!formKey.currentState!.validate()) return;

    try {
      await PlanningService().changeMachinePlanning(planningIds, chooseMachine);
      if (!mounted) return; // check context
      showSnackBarSuccess(
        context,
        'Chuyển đơn hàng sang $chooseMachine thành công',
      );

      if (!mounted) return; // check context
      widget.onChangeMachine();
      Navigator.of(context).pop();
    } catch (e, s) {
      if (!mounted) return; // check context
      AppLogger.e(
        "Lỗi khi chuyển đơn hàng sang máy khác",
        error: e,
        stackTrace: s,
      );
      showSnackBarError(context, 'Lỗi: Không thể lưu dữ liệu');
    }
  }

  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(
      builder: (context, state) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          content: SizedBox(
            width: 500,
            height: 400,
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
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
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
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 5),
                            ...widget.planning.map(
                              (p) => Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 2.0,
                                ),
                                child: Row(
                                  children: [
                                    const Text(
                                      "- Mã đơn hàng: ",
                                      style: TextStyle(fontSize: 16),
                                    ),
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
                            'Chọn máy cần chuyển',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 12),
                          ValidationOrder.dropdownForTypes(
                            machineList,
                            chooseMachine,
                            (value) {
                              setState(() {
                                chooseMachine = value!;
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

          actionsPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 10,
          ),
          actionsAlignment: MainAxisAlignment.spaceBetween,
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                "Chuyển",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
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
