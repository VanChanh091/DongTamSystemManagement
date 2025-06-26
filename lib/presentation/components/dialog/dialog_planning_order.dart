import 'package:dongtam/data/models/order/order_model.dart';
import 'package:dongtam/data/models/planning/paper_consumption_norm_model.dart';
import 'package:dongtam/data/models/planning/planning_model.dart';
import 'package:dongtam/service/planning_service.dart';
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
  final List<String> machineList = ['Máy 1350', 'Máy 1900', 'Máy 2 Lớp'];

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
  final timeRunningController = TextEditingController();
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
  final numberChildController = TextEditingController();
  final numberLayerPaperController = TextEditingController();

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

    // addListenerForField();
    fillDataOrderToPlanning();
  }

  void orderInitState() {
    originalOrderId = widget.order!.orderId;
    orderIdController.text = widget.order!.orderId;
    customerNameController.text = widget.order!.customer!.customerName;
    companyNameController.text = widget.order!.customer!.companyName;
    dayOrderController.text = widget.order!.day.toString();
    matEOrderController.text = widget.order!.matE.toString();
    matBOrderController.text = widget.order!.matB.toString();
    matCOrderController.text = widget.order!.matC.toString();
    songEOrderController.text = widget.order!.songE.toString();
    songBOrderController.text = widget.order!.songB.toString();
    songCOrderController.text = widget.order!.songC.toString();
    songE2OrderController.text = widget.order!.songE2.toString();
    songController.text = widget.order!.flute.toString();
    qcBoxController.text = widget.order!.QC_box.toString();
    instructSpecialController.text = widget.order!.instructSpecial.toString();
    daoXaOrderController.text = widget.order!.daoXa.toString();
    lengthOrderController.text = widget.order!.lengthPaperManufacture
        .toStringAsFixed(1);
    sizeOrderController.text = widget.order!.paperSizeManufacture
        .toStringAsFixed(1);
    quantityOrderController.text = widget.order!.quantityManufacture
        .toStringAsFixed(1);
    totalPriceOrderController.text = widget.order!.totalPrice.toStringAsFixed(
      1,
    );

    //date
    dateShipping = widget.order!.dateRequestShipping;
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

    //Dinh Muc
    dayController.text = extractNumbers(dayOrderController.text);
    songEController.text = extractNumbers(songEOrderController.text);
    songBController.text = extractNumbers(songBOrderController.text);
    songCController.text = extractNumbers(songCOrderController.text);
    songE2Controller.text = extractNumbers(songE2OrderController.text);
    matEController.text = extractNumbers(matEOrderController.text);
    matBController.text = extractNumbers(matBOrderController.text);
    matCController.text = extractNumbers(matCOrderController.text);
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

  String mapFluteToLayerType(String fluteText) {
    final fluteNumber = int.tryParse(fluteText);

    if (fluteNumber == null) return '2_LAYER';

    if (fluteNumber == 2) return '2_LAYER';
    if (fluteNumber == 3) return '3_LAYER';
    if (fluteNumber == 4 || fluteNumber == 5) return '4_5_LAYER';
    if (fluteNumber > 5) return 'MORE_5_LAYER';

    return '2_LAYER';
  }

  void submit() async {
    if (!formKey.currentState!.validate()) return;

    final newPaperConsumptionNorm = PaperConsumptionNorm(
      day: int.tryParse(dayController.text) ?? 0,
      songE: int.tryParse(songEController.text) ?? 0,
      matE: int.tryParse(matEController.text) ?? 0,
      songB: int.tryParse(songBController.text) ?? 0,
      matB: int.tryParse(matBController.text) ?? 0,
      songC: int.tryParse(songCController.text) ?? 0,
      matC: int.tryParse(matCController.text) ?? 0,
      songE2: int.tryParse(matCController.text) ?? 0,
    );

    final newPlanning = Planning(
      planningId: 0,
      runningPlan: int.tryParse(runningPlanController.text) ?? 0,
      timeRunning: TimeOfDay(
        hour: int.parse(timeRunningController.text.split(':')[0]),
        minute: int.parse(timeRunningController.text.split(':')[1]),
      ),
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
      numberChild: int.tryParse(numberChildController.text) ?? 0,
      ghepKho: int.tryParse(ghepKhoController.text) ?? 0,
      chooseMachine: chooseMachine,
      orderId: widget.order!.orderId,
      order: widget.order,
      paperConsumptionNorm: newPaperConsumptionNorm,
    );

    //add layerType into toJson
    final planningJson = newPlanning.toJson();
    final layerType = mapFluteToLayerType(fluteController.text);
    planningJson['layerType'] = layerType;

    try {
      await PlanningService().planningOrder(
        originalOrderId,
        'planning',
        planningJson,
      );
      showSnackBarSuccess(context, "Lưu thành công");

      widget.onPlanningOrder();
      Navigator.of(context).pop();
    } catch (e) {
      print("Error: $e");
      showSnackBarError(context, 'Lỗi: Không thể lưu dữ liệu');
    }
  }

  @override
  void dispose() {
    super.dispose();
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
    runningPlanController.dispose();
    timeRunningController.dispose();
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
    quantityPLanningsController.dispose();
    numberChildController.dispose();
    dayController.dispose();
    songEController.dispose();
    matEController.dispose();
    songBController.dispose();
    matBController.dispose();
    songCController.dispose();
    matCController.dispose();
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
              "Thời gian chạy",
              timeRunningController,
              Symbols.clock_arrow_down,
              readOnly: true,
              onTap: () async {
                // Hiển thị time picker
                TimeOfDay? pickedTime = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.now(),
                );

                if (pickedTime != null) {
                  // Cập nhật controller text
                  final formattedTime =
                      '${pickedTime.hour.toString().padLeft(2, '0')}:${pickedTime.minute.toString().padLeft(2, '0')}';
                  timeRunningController.text = formattedTime;
                }
              },
            ),

        'middle_1':
            () => ValidationPlanning.validateInput(
              "Ghép khổ",
              ghepKhoController,
              Symbols.layers,
            ),

        'middle_2':
            () => ValidationOrder.dropdownForTypes(machineList, chooseMachine, (
              value,
            ) {
              setState(() {
                chooseMachine = value!;
              });
            }),

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
              "Số con",
              numberChildController,
              Symbols.filter_9_plus,
            ),
      },
    ];

    final List<Map<String, dynamic>> dinhMuc = [
      {
        'left':
            () => ValidationPlanning.validateInput(
              "Đáy (g)",
              dayController,
              Symbols.vertical_align_bottom,
            ),

        'middle_1':
            () => ValidationPlanning.validateInput(
              "Mặt E (g)",
              matEController,
              Symbols.vertical_align_center,
            ),

        'middle_2':
            () => ValidationPlanning.validateInput(
              "Mặt B (g)",
              matBController,
              Symbols.vertical_align_center,
            ),

        'right':
            () => ValidationPlanning.validateInput(
              "Mặt C (g)",
              matCController,
              Symbols.vertical_align_bottom,
            ),
      },

      {
        'left':
            () => ValidationPlanning.validateInput(
              "Sóng E (g)",
              songEController,
              Symbols.airware,
            ),
        'middle_1':
            () => ValidationPlanning.validateInput(
              "Sóng B (g)",
              songBController,
              Symbols.airware,
            ),

        'middle_2':
            () => ValidationPlanning.validateInput(
              "Sóng C (g)",
              songCController,
              Symbols.airware,
            ),

        'right':
            () => ValidationPlanning.validateInput(
              "Sóng E2 (g)",
              songE2Controller,
              Symbols.airware,
            ),
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
            height: 900,
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Form(
                key: formKey,
                child: Column(
                  children: [
                    //Order
                    SizedBox(height: 10),
                    Text(
                      "Đơn Hàng",
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
                                    SizedBox(width: 30),
                                    Expanded(
                                      child:
                                          row['middle_1'] is Function
                                              ? row['middle_1']()
                                              : row['middle_1'],
                                    ),
                                    SizedBox(width: 30),
                                    Expanded(
                                      child:
                                          row['middle_2'] is Function
                                              ? row['middle_2']()
                                              : row['middle_2'],
                                    ),
                                    SizedBox(width: 30),
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
                    SizedBox(height: 20),

                    // Planning
                    Text(
                      "Kế Hoạch",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    SizedBox(height: 20),
                    Container(
                      decoration: BoxDecoration(
                        color: Color(0xffF2E873),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: EdgeInsets.all(15),
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
                                    SizedBox(width: 30),
                                    Expanded(
                                      child:
                                          row['middle_1'] is Function
                                              ? row['middle_1']()
                                              : row['middle_1'],
                                    ),
                                    SizedBox(width: 30),
                                    Expanded(
                                      child:
                                          row['middle_2'] is Function
                                              ? row['middle_2']()
                                              : row['middle_2'],
                                    ),
                                    SizedBox(width: 30),
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
                    SizedBox(height: 20),

                    //Định mức
                    Text(
                      "Định Mức",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    SizedBox(height: 20),
                    Container(
                      decoration: BoxDecoration(
                        color: Color(0xffF2E873),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: EdgeInsets.all(15),
                      child: Column(
                        children:
                            dinhMuc.map((row) {
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
                                    SizedBox(width: 30),
                                    Expanded(
                                      child:
                                          row['middle_1'] is Function
                                              ? row['middle_1']()
                                              : row['middle_1'],
                                    ),
                                    SizedBox(width: 30),
                                    Expanded(
                                      child:
                                          row['middle_2'] is Function
                                              ? row['middle_2']()
                                              : row['middle_2'],
                                    ),
                                    SizedBox(width: 30),
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
