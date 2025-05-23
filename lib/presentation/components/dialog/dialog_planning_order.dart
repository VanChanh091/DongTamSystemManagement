import 'package:dongtam/data/models/order/order_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class PLanningDialog extends StatefulWidget {
  final Order? order;
  final VoidCallback onPlanningOrder;

  const PLanningDialog({super.key, this.order, required this.onPlanningOrder});

  @override
  State<PLanningDialog> createState() => _PLanningDialogState();
}

class _PLanningDialogState extends State<PLanningDialog> {
  final formKey = GlobalKey<FormState>();
  // Timer? _debounce;
  final List<String> machineList = ['1350', '1900', '2 Lớp'];

  final orderIdController = TextEditingController();
  final customerNameController = TextEditingController();
  final companyNameController = TextEditingController();
  final dayController = TextEditingController();
  final middle_1Controller = TextEditingController();
  final middle_2Controller = TextEditingController();
  final matController = TextEditingController();
  final songEController = TextEditingController();
  final songBController = TextEditingController();
  final songCController = TextEditingController();
  final songE2Controller = TextEditingController();
  final qcBoxController = TextEditingController();
  final instructSpecialController = TextEditingController();
  final soConController = TextEditingController();
  late String chooseMachine = '1350';
  DateTime? dateShipping;

  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(
      builder: (context, state) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          content: SizedBox(width: 1400, height: 900),
        );
      },
    );
  }
}
