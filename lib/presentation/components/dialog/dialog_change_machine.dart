import 'package:dongtam/data/models/planning/planning_model.dart';
import 'package:dongtam/service/planning_service.dart';
import 'package:dongtam/utils/showSnackBar/show_snack_bar.dart';
import 'package:dongtam/utils/validation/validation_order.dart';
import 'package:flutter/material.dart';

class ChangeMachineDialog extends StatefulWidget {
  final List<Planning> planning;
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
  final List<String> machineList = ['Máy 1350', 'Máy 1900', 'Máy 2 Lớp'];

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
      await PlanningService().changeMachinePlanning(
        planningIds, //fix here
        chooseMachine,
      );

      widget.onChangeMachine();
      Navigator.of(context).pop();
    } catch (e) {
      print("Error: $e");
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
            width: 700,
            height: 500,
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Form(
                key: formKey,
                child: Column(
                  children: [
                    SizedBox(height: 10),
                    Text(
                      "Chuyển máy",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    SizedBox(height: 10),

                    Container(
                      decoration: BoxDecoration(
                        color: Color(0xffF2E873),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: EdgeInsets.all(15),
                      child: ValidationOrder.dropdownForTypes(
                        machineList,
                        chooseMachine,
                        (value) {
                          setState(() {
                            chooseMachine = value!;
                          });
                        },
                      ),
                    ),
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
                "Lưu",
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
