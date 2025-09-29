import 'package:dongtam/data/models/order/order_model.dart';
import 'package:dongtam/data/models/planning/planning_paper_model.dart';
import 'package:dongtam/service/planning_service.dart';
import 'package:dongtam/utils/logger/app_logger.dart';
import 'package:dongtam/utils/showSnackBar/show_snack_bar.dart';
import 'package:dongtam/utils/validation/validation_order.dart';
import 'package:dongtam/utils/validation/validation_planning.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

class PLanningDialog extends StatefulWidget {
  final Order? order;
  final VoidCallback onPlanningOrder;

  const PLanningDialog({
    super.key,
    required this.order,
    required this.onPlanningOrder,
  });

  @override
  State<PLanningDialog> createState() => _PLanningDialogState();
}

class _PLanningDialogState extends State<PLanningDialog> {
  final formKey = GlobalKey<FormState>();
  late String originalOrderId;
  final List<String> machineList = [
    'Máy 1350',
    'Máy 1900',
    'Máy 2 Lớp',
    "Máy Quấn Cuồn",
  ];

  //order
  final orderIdController = TextEditingController();
  final customerNameController = TextEditingController();
  final companyNameController = TextEditingController();
  final dateShippingController = TextEditingController();
  DateTime? dateShipping;
  final dayOrderController = TextEditingController();
  final matEOrderController = TextEditingController();
  final matBOrderController = TextEditingController();
  final matCOrderController = TextEditingController();
  final songEOrderController = TextEditingController();
  final songBOrderController = TextEditingController();
  final songCOrderController = TextEditingController();
  final songE2OrderController = TextEditingController();
  final lengthOrderController = TextEditingController();
  final sizeOrderController = TextEditingController();
  final quantityOrderController = TextEditingController();
  final totalPriceOrderController = TextEditingController();
  final songController = TextEditingController();
  final qcBoxController = TextEditingController();
  final daoXaOrderController = TextEditingController();
  final instructSpecialController = TextEditingController();

  //planning
  final ghepKhoController = TextEditingController();
  final fluteController = TextEditingController();
  late String chooseMachine = 'Máy 1350';
  final dayReplaceController = TextEditingController();
  final matEReplaceController = TextEditingController();
  final matBReplaceController = TextEditingController();
  final matCReplaceController = TextEditingController();
  final songEReplaceController = TextEditingController();
  final songBReplaceController = TextEditingController();
  final songCReplaceController = TextEditingController();
  final songE2ReplaceController = TextEditingController();
  final lengthPaperPlanningController = TextEditingController();
  final sizePaperPLaningController = TextEditingController();
  final runningPlanController = TextEditingController();
  final quantityPLanningsController = TextEditingController();
  final numberLayerPaperController = TextEditingController();
  ValueNotifier<bool> isBoxChecked = ValueNotifier<bool>(false);

  //paper consumption norm
  final dayController = TextEditingController();
  final songEController = TextEditingController();
  final matEController = TextEditingController();
  final songBController = TextEditingController();
  final matBController = TextEditingController();
  final songCController = TextEditingController();
  final matCController = TextEditingController();
  final songE2Controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    orderInitState();

    fillDataOrderToPlanning();
  }

  void orderInitState() {
    final order = widget.order!;
    AppLogger.i("Khởi tạo form với orderId=${order.orderId}");

    originalOrderId = order.orderId;
    orderIdController.text = order.orderId;
    customerNameController.text = order.customer!.customerName;
    companyNameController.text = order.customer!.companyName;
    dayOrderController.text = order.day.toString();
    matEOrderController.text = order.matE.toString();
    matBOrderController.text = order.matB.toString();
    matCOrderController.text = order.matC.toString();
    songEOrderController.text = order.songE.toString();
    songBOrderController.text = order.songB.toString();
    songCOrderController.text = order.songC.toString();
    songE2OrderController.text = order.songE2.toString();
    songController.text = order.flute.toString();
    qcBoxController.text = order.QC_box.toString();
    instructSpecialController.text = order.instructSpecial.toString();
    daoXaOrderController.text = order.daoXa.toString();
    lengthOrderController.text = order.lengthPaperManufacture.toStringAsFixed(
      1,
    );
    sizeOrderController.text = order.paperSizeManufacture.toStringAsFixed(1);
    quantityOrderController.text = order.quantityManufacture.toString();
    totalPriceOrderController.text = order.totalPrice.toStringAsFixed(1);

    //date
    dateShipping = order.dateRequestShipping;
    dateShippingController.text = DateFormat(
      'dd/MM/yyyy',
    ).format(dateShipping!);
  }

  void fillDataOrderToPlanning() {
    dayReplaceController.text = dayOrderController.text;
    matEReplaceController.text = matEOrderController.text;
    matBReplaceController.text = matBOrderController.text;
    matCReplaceController.text = matCOrderController.text;
    songEReplaceController.text = songEOrderController.text;
    songBReplaceController.text = songBOrderController.text;
    songCReplaceController.text = songCOrderController.text;
    songE2ReplaceController.text = songE2OrderController.text;
    lengthPaperPlanningController.text = lengthOrderController.text;
    sizePaperPLaningController.text = sizeOrderController.text;
    runningPlanController.text = quantityOrderController.text;
    fluteController.text = extractNumbers(songController.text);
  }

  /// Trích xuất số từ chuỗi văn bản
  String extractNumbers(String input, {String mode = 'all'}) {
    if (mode == 'first') {
      final match = RegExp(r'\d+').firstMatch(input);
      return match?.group(0) ?? '';
    } else {
      return input.replaceAll(RegExp(r'[^0-9]'), '');
    }
  }

  void submit() async {
    if (!formKey.currentState!.validate()) {
      AppLogger.w("Form không hợp lệ, dừng submit");
      return;
    }

    final newPlanning = PlanningPaper(
      planningId: 0,
      dayStart: DateTime.now(),
      runningPlan: int.tryParse(runningPlanController.text) ?? 0,
      timeRunning: const TimeOfDay(hour: 0, minute: 0),
      dayReplace: dayReplaceController.text,
      matEReplace: matEReplaceController.text,
      matBReplace: matBReplaceController.text,
      matCReplace: matCReplaceController.text,
      songEReplace: songEReplaceController.text,
      songBReplace: songBReplaceController.text,
      songCReplace: songCReplaceController.text,
      songE2Replace: songE2ReplaceController.text,
      lengthPaperPlanning:
          double.tryParse(lengthPaperPlanningController.text) ?? 0,
      sizePaperPLaning: double.tryParse(sizePaperPLaningController.text) ?? 0,
      ghepKho: int.tryParse(ghepKhoController.text) ?? 0,
      chooseMachine: chooseMachine,
      hasBox: widget.order!.isBox,
      status: 'planning',

      orderId: widget.order!.orderId,
      order: widget.order,
    );

    try {
      AppLogger.i("Lên kế hoạch cho 1 đơn hàng mới: $originalOrderId");
      await PlanningService().planningOrder(
        originalOrderId,
        'planning',
        newPlanning.toJson(),
      );

      if (!mounted) return;
      showSnackBarSuccess(context, "Lưu thành công");

      if (!mounted) return;
      widget.onPlanningOrder();
      Navigator.of(context).pop();
    } catch (e, s) {
      if (!mounted) return;
      AppLogger.e("Lỗi khi lên kế hoạch cho đơn hàng", error: e, stackTrace: s);
      showSnackBarError(context, 'Lỗi: Không thể lưu dữ liệu');
    }
  }

  @override
  void dispose() {
    super.dispose();
    //order
    orderIdController.dispose();
    customerNameController.dispose();
    companyNameController.dispose();
    dayOrderController.dispose();
    matEOrderController.dispose();
    matBOrderController.dispose();
    matCOrderController.dispose();
    songEOrderController.dispose();
    songBOrderController.dispose();
    songCOrderController.dispose();
    songE2OrderController.dispose();
    songController.dispose();
    qcBoxController.dispose();
    instructSpecialController.dispose();
    daoXaOrderController.dispose();
    lengthOrderController.dispose();
    sizeOrderController.dispose();
    quantityOrderController.dispose();
    totalPriceOrderController.dispose();
    //planning
    ghepKhoController.dispose();
    dayReplaceController.dispose();
    matEReplaceController.dispose();
    matBReplaceController.dispose();
    matCReplaceController.dispose();
    songEReplaceController.dispose();
    songBReplaceController.dispose();
    songCReplaceController.dispose();
    songE2ReplaceController.dispose();
    lengthPaperPlanningController.dispose();
    sizePaperPLaningController.dispose();
    runningPlanController.dispose();
    quantityPLanningsController.dispose();
    numberLayerPaperController.dispose();

    // _debounce?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> orders = [
      {
        'left':
            () => ValidationPlanning.validateInput(
              "Mã Đơn Hàng",
              orderIdController,
              Symbols.orders,
              readOnly: true,
            ),
        'middle_1':
            () => ValidationPlanning.validateInput(
              "Tên Khách Hàng",
              customerNameController,
              Symbols.person,
              readOnly: true,
            ),
        'middle_2':
            () => ValidationPlanning.validateInput(
              "Tên Công Ty",
              companyNameController,
              Symbols.business,
              readOnly: true,
            ),
        'right':
            () => ValidationPlanning.validateInput(
              "Ngày Giao Hàng",
              dateShippingController, //fix here
              Symbols.calendar_month,
              readOnly: true,
            ),
      },

      {
        'left':
            () => ValidationPlanning.validateInput(
              "Đáy (g)",
              dayOrderController,
              Symbols.vertical_align_bottom,
              readOnly: true,
            ),
        'middle_1':
            () => ValidationPlanning.validateInput(
              "Mặt E (g)",
              matEOrderController,
              Symbols.vertical_align_center,
              readOnly: true,
            ),
        'middle_2':
            () => ValidationPlanning.validateInput(
              "Mặt B (g)",
              matBOrderController,
              Symbols.vertical_align_center,
              readOnly: true,
            ),
        'right':
            () => ValidationPlanning.validateInput(
              "Mặt C (g)",
              matCOrderController,
              Symbols.vertical_align_top,
              readOnly: true,
            ),
      },

      {
        'left':
            () => ValidationPlanning.validateInput(
              "Sóng E (g)",
              songEOrderController,
              Symbols.airwave,
              readOnly: true,
            ),
        'middle_1':
            () => ValidationPlanning.validateInput(
              "Sóng B (g)",
              songBOrderController,
              Symbols.airwave,
              readOnly: true,
            ),
        'middle_2':
            () => ValidationPlanning.validateInput(
              "Sóng C (g)",
              songCOrderController,
              Symbols.airwave,
              readOnly: true,
            ),
        'right':
            () => ValidationPlanning.validateInput(
              "Sóng E2 (g)",
              songE2OrderController,
              Symbols.airwave,
              readOnly: true,
            ),
      },

      {
        'left':
            () => ValidationPlanning.validateInput(
              "Khổ sản xuất (cm)",
              sizeOrderController,
              Symbols.horizontal_distribute,
              readOnly: true,
            ),
        'middle_1':
            () => ValidationPlanning.validateInput(
              "Dài sản xuất (cm)",
              lengthOrderController,
              Symbols.vertical_distribute,
              readOnly: true,
            ),
        'middle_2':
            () => ValidationPlanning.validateInput(
              "Số lượng (SX)",
              quantityOrderController,
              Symbols.filter_9_plus,
              readOnly: true,
            ),
        'right':
            () => ValidationPlanning.validateInput(
              "Doanh số",
              totalPriceOrderController,
              Symbols.filter_9_plus,
              readOnly: true,
            ),
      },

      {
        'left':
            () => ValidationPlanning.validateInput(
              "Sóng",
              songController,
              Symbols.waves,
              readOnly: true,
            ),

        'middle_1':
            () => ValidationPlanning.validateInput(
              "QC Thùng",
              qcBoxController,
              Symbols.deployed_code,
              readOnly: true,
            ),

        'middle_2':
            () => ValidationPlanning.validateInput(
              "Dao Xả",
              daoXaOrderController,
              Symbols.cut,
              readOnly: true,
            ),

        'right':
            () => ValidationPlanning.validateInput(
              "Hướng dẫn đặc biệt",
              instructSpecialController,
              Symbols.description,
              readOnly: true,
            ),
      },
    ];

    final List<Map<String, dynamic>> planning = [
      {
        'left':
            () => ValidationPlanning.validateInput(
              "Đáy thay thế (g)",
              dayReplaceController,
              Symbols.vertical_align_bottom,
            ),
        'middle_1':
            () => ValidationPlanning.validateInput(
              "Mặt E thay thế (g)",
              matEReplaceController,
              Symbols.vertical_align_center,
            ),
        'middle_2':
            () => ValidationPlanning.validateInput(
              "Mặt B thay thế (g)",
              matBReplaceController,
              Symbols.vertical_align_center,
            ),
        'right':
            () => ValidationPlanning.validateInput(
              "Mặt C thay thế (g)",
              matCReplaceController,
              Symbols.vertical_align_top,
            ),
      },

      {
        'left':
            () => ValidationPlanning.validateInput(
              "Sóng E thay thế (g)",
              songEReplaceController,
              Symbols.airwave,
            ),
        'middle_1':
            () => ValidationPlanning.validateInput(
              "Sóng B thay thế (g)",
              songBReplaceController,
              Symbols.airwave,
            ),
        'middle_2':
            () => ValidationPlanning.validateInput(
              "Sóng C thay thế (g)",
              songCReplaceController,
              Symbols.airwave,
            ),
        'right':
            () => ValidationPlanning.validateInput(
              "Sóng E2 thay thế (g)",
              songE2ReplaceController,
              Symbols.airwave,
            ),
      },

      {
        'left':
            () => ValidationPlanning.validateInput(
              "Dài sản xuất (cm)",
              lengthPaperPlanningController,
              Symbols.horizontal_distribute,
            ),
        'middle_1':
            () => ValidationPlanning.validateInput(
              "Khổ sản xuất (cm)",
              sizePaperPLaningController,
              Symbols.horizontal_distribute,
            ),
        'middle_2':
            () => ValidationPlanning.validateInput(
              "Kế hoạch chạy",
              runningPlanController,
              Symbols.production_quantity_limits,
            ),
        'right':
            () => ValidationPlanning.validateInput(
              "Số Lớp Sóng",
              fluteController,
              Symbols.stacks,
            ),
      },

      {
        'left':
            () => ValidationPlanning.validateInput(
              "Ghép Khổ",
              ghepKhoController,
              Symbols.layers,
            ),

        'middle_1':
            () => ValidationOrder.dropdownForTypes(machineList, chooseMachine, (
              value,
            ) {
              setState(() {
                chooseMachine = value!;
              });
            }),

        'middle_2': () => SizedBox(),

        'right': () => SizedBox(),
      },
    ];

    return StatefulBuilder(
      builder: (context, state) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          content: SizedBox(
            width: 1400,
            height: 800,
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Form(
                key: formKey,
                child: Column(
                  children: [
                    //Order
                    const SizedBox(height: 10),
                    const Text(
                      "Đơn Hàng",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xffF2E873),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.all(15),
                      child: Column(
                        children:
                            orders.map((row) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 15),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child:
                                          row['left'] is Function
                                              ? row['left']()
                                              : row['left'],
                                    ),
                                    const SizedBox(width: 30),
                                    Expanded(
                                      child:
                                          row['middle_1'] is Function
                                              ? row['middle_1']()
                                              : row['middle_1'],
                                    ),
                                    const SizedBox(width: 30),
                                    Expanded(
                                      child:
                                          row['middle_2'] is Function
                                              ? row['middle_2']()
                                              : row['middle_2'],
                                    ),
                                    const SizedBox(width: 30),
                                    Expanded(
                                      child:
                                          row['right'] is Function
                                              ? row['right']()
                                              : row['right'],
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Planning
                    const Text(
                      "Kế Hoạch",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xffF2E873),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.all(15),
                      child: Column(
                        children:
                            planning.map((row) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 15),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child:
                                          row['left'] is Function
                                              ? row['left']()
                                              : row['left'],
                                    ),
                                    const SizedBox(width: 30),
                                    Expanded(
                                      child:
                                          row['middle_1'] is Function
                                              ? row['middle_1']()
                                              : row['middle_1'],
                                    ),
                                    const SizedBox(width: 30),
                                    Expanded(
                                      child:
                                          row['middle_2'] is Function
                                              ? row['middle_2']()
                                              : row['middle_2'],
                                    ),
                                    const SizedBox(width: 30),
                                    Expanded(
                                      child:
                                          row['right'] is Function
                                              ? row['right']()
                                              : row['right'],
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                      ),
                    ),
                    const SizedBox(height: 20),
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
