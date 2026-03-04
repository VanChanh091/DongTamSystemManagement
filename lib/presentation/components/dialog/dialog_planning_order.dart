import 'package:dongtam/data/models/order/order_model.dart';
import 'package:dongtam/data/models/planning/planning_paper_model.dart';
import 'package:dongtam/service/planning_service.dart';
import 'package:dongtam/presentation/components/shared/cardForm/building_card_form.dart';
import 'package:dongtam/presentation/components/shared/cardForm/format_key_value_card.dart';
import 'package:dongtam/presentation/components/shared/confirm_dialog.dart';
import 'package:dongtam/utils/helper/reponsive/reponsive_dialog.dart';
import 'package:dongtam/utils/logger/app_logger.dart';
import 'package:dongtam/utils/handleError/show_snack_bar.dart';
import 'package:dongtam/utils/validation/validation_order.dart';
import 'package:dongtam/utils/validation/validation_planning.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

class PLanningDialog extends StatefulWidget {
  final Order? order;
  final VoidCallback onPlanningOrder;

  const PLanningDialog({super.key, required this.order, required this.onPlanningOrder});

  @override
  State<PLanningDialog> createState() => _PLanningDialogState();
}

class _PLanningDialogState extends State<PLanningDialog> {
  final formKey = GlobalKey<FormState>();
  late String originalOrderId;
  final List<String> machineList = ['Máy 1350', 'Máy 1900', 'Máy 2 Lớp', "Máy Quấn Cuồn"];

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
  final matE2OrderController = TextEditingController();
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
  final numberChildController = TextEditingController();
  final fluteController = TextEditingController();
  late String chooseMachine = 'Máy 1350';
  final dayReplaceController = TextEditingController();
  final matEReplaceController = TextEditingController();
  final matBReplaceController = TextEditingController();
  final matCReplaceController = TextEditingController();
  final matE2ReplaceController = TextEditingController();
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
  final structureController = TextEditingController();

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
    calculateDefaultGhepKho();

    numberChildController.addListener(calculateDefaultGhepKho);
    sizePaperPLaningController.addListener(calculateDefaultGhepKho);

    _listenStructureChanges();
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
    matE2OrderController.text = order.matE2.toString();
    songEOrderController.text = order.songE.toString();
    songBOrderController.text = order.songB.toString();
    songCOrderController.text = order.songC.toString();
    songE2OrderController.text = order.songE2.toString();
    songController.text = order.flute.toString();
    qcBoxController.text = order.QC_box.toString();
    instructSpecialController.text = order.instructSpecial.toString();
    daoXaOrderController.text = order.daoXa.toString();
    lengthOrderController.text = order.lengthPaperManufacture.toStringAsFixed(1);
    sizeOrderController.text = order.paperSizeManufacture.toStringAsFixed(1);
    quantityOrderController.text = order.quantityManufacture.toString();
    totalPriceOrderController.text = order.totalPrice?.toStringAsFixed(1) ?? "";
    numberChildController.text = order.numberChild.toString();

    //date
    dateShipping = order.dateRequestShipping;
    dateShippingController.text = DateFormat('dd/MM/yyyy').format(dateShipping!);
  }

  void fillDataOrderToPlanning() {
    final fieldPairs = {
      dayReplaceController: dayOrderController,
      matEReplaceController: matEOrderController,
      matBReplaceController: matBOrderController,
      matCReplaceController: matCOrderController,
      matE2ReplaceController: matE2OrderController,
      songEReplaceController: songEOrderController,
      songBReplaceController: songBOrderController,
      songCReplaceController: songCOrderController,
      songE2ReplaceController: songE2OrderController,
      lengthPaperPlanningController: lengthOrderController,
      sizePaperPLaningController: sizeOrderController,
    };

    fieldPairs.forEach((target, source) {
      target.text = source.text;
    });

    int leftQty =
        (int.tryParse(quantityOrderController.text) ?? 0) - (widget.order?.totalQtyProduced ?? 0);
    runningPlanController.text = leftQty.toString();

    fluteController.text = extractNumbers(songController.text);

    //structure replace
    _updateStructureController();
  }

  String formatterStructureOrder({
    required String dayReplace,
    required String songEReplace,
    required String matEReplace,
    required String songBReplace,
    required String matBReplace,
    required String songCReplace,
    required String matCReplace,
    required String songE2Replace,
    required String matE2Replace,
  }) {
    return [
      dayReplace,
      songEReplace,
      matEReplace,
      songBReplace,
      matBReplace,
      songCReplace,
      matCReplace,
      songE2Replace,
      matE2Replace,
    ].where((e) => e.trim().isNotEmpty).join('/');
  }

  void _updateStructureController() {
    structureController.text = formatterStructureOrder(
      dayReplace: dayReplaceController.text,
      songEReplace: songEReplaceController.text,
      matEReplace: matEReplaceController.text,
      songBReplace: songBReplaceController.text,
      matBReplace: matBReplaceController.text,
      songCReplace: songCReplaceController.text,
      matCReplace: matCReplaceController.text,
      songE2Replace: songE2ReplaceController.text,
      matE2Replace: matE2ReplaceController.text,
    );
  }

  void _listenStructureChanges() {
    for (final ctrl in [
      dayReplaceController,
      songEReplaceController,
      matEReplaceController,
      songBReplaceController,
      matBReplaceController,
      songCReplaceController,
      matCReplaceController,
      songE2ReplaceController,
      matE2ReplaceController,
    ]) {
      ctrl.addListener(_updateStructureController);
    }
  }

  void calculateDefaultGhepKho() {
    final numberChild = int.tryParse(numberChildController.text) ?? 0;
    final sizeOrder = double.tryParse(sizePaperPLaningController.text) ?? 0;

    final ghepKho = (numberChild * sizeOrder).ceil();
    ghepKhoController.text = ghepKho.toString();
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

    final flute = fluteController.text.trim();
    final lengthVal = double.tryParse(lengthPaperPlanningController.text) ?? 0;

    // check flute để sắp đúng máy
    if (flute.startsWith("2")) {
      if (chooseMachine == "Máy 2 Lớp") {
        // Máy 2 lớp bắt buộc phải có cả Dài và Khổ (length > 0)
        if (lengthVal <= 0) {
          showSnackBarError(context, "Máy 2 Lớp yêu cầu phải có dài khổ!");
          return;
        }
      } else if (chooseMachine == "Máy Quấn Cuồn") {
        // Máy Quấn Cuộn chỉ có Khổ, không có Dài (length phải bằng 0)
        if (lengthVal > 0) {
          showSnackBarError(context, "Máy Quấn Cuộn không được có dài khổ!");
          return;
        }
      } else {
        // Nếu flute là 2 nhưng chọn máy khác (ví dụ máy 3-5-7 lớp)
        showSnackBarError(context, "Đơn này chỉ được chạy ở Máy 2 Lớp hoặc Máy Quấn Cuồn!");
        return;
      }
    } else {
      if (chooseMachine == "Máy 2 Lớp" && chooseMachine == "Máy Quấn Cuồn") {
        showSnackBarError(context, "Đơn này không được chạy ở Máy 2 Lớp!");
        return;
      }
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
      matE2Replace: matE2ReplaceController.text,
      songEReplace: songEReplaceController.text,
      songBReplace: songBReplaceController.text,
      songCReplace: songCReplaceController.text,
      songE2Replace: songE2ReplaceController.text,
      lengthPaperPlanning: double.tryParse(lengthPaperPlanningController.text) ?? 0,
      sizePaperPLaning: double.tryParse(sizePaperPLaningController.text) ?? 0,
      ghepKho: int.tryParse(ghepKhoController.text) ?? 0,
      numberChild: int.tryParse(numberChildController.text) ?? 0,
      chooseMachine: chooseMachine,
      hasBox: widget.order!.isBox,
      status: 'planning',

      orderId: widget.order!.orderId,
      order: widget.order,
    );

    try {
      AppLogger.i("Lên kế hoạch cho 1 đơn hàng mới: $originalOrderId");
      await PlanningService().planningOrder(
        orderId: originalOrderId,
        orderPlanning: newPlanning.toJson(),
      );

      // Show loading
      if (!mounted) return;
      showLoadingDialog(context);
      await Future.delayed(const Duration(milliseconds: 700));

      if (!mounted) return;
      Navigator.pop(context); // đóng dialog loading

      // Thông báo thành công
      if (!mounted) return;
      showSnackBarSuccess(context, "Lưu thành công");

      widget.onPlanningOrder();

      if (!mounted) return;
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
    matE2OrderController.dispose();
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
    matE2ReplaceController.dispose();
    songEReplaceController.dispose();
    songBReplaceController.dispose();
    songCReplaceController.dispose();
    songE2ReplaceController.dispose();
    lengthPaperPlanningController.dispose();
    sizePaperPLaningController.dispose();
    runningPlanController.dispose();
    quantityPLanningsController.dispose();
    numberLayerPaperController.dispose();
    numberChildController.dispose();
    numberChildController.removeListener(calculateDefaultGhepKho);
    sizeOrderController.removeListener(calculateDefaultGhepKho);
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> orderInfoRows = [
      {
        "leftKey": "Mã Đơn Hàng",
        "leftValue": orderIdController.text,
        "rightKey": "Kết Cấu Giấy",
        "rightValue": widget.order!.formatterStructureOrder,
      },
      {
        "leftKey": "Ngày Giao Hàng",
        "leftValue": dateShippingController.text,
        "rightKey": "Số Lượng SX",
        "rightValue": quantityOrderController.text,
      },
      {
        "leftKey": "Khách Hàng",
        "leftValue": customerNameController.text,
        "rightKey": "Dài SX (cm)",
        "rightValue": lengthOrderController.text,
      },
      {
        "leftKey": "Công Ty",
        "leftValue": companyNameController.text,
        "rightKey": "Khổ SX (cm)",
        "rightValue": sizeOrderController.text,
      },
      {
        "leftKey": "QC Thùng",
        "leftValue": qcBoxController.text,
        "rightKey": "Doanh Số",
        "rightValue": totalPriceOrderController.text,
      },
      {
        "leftKey": "Sóng",
        "leftValue": songController.text,
        "rightKey": "Dao Xả",
        "rightValue": daoXaOrderController.text,
      },
      {"leftKey": "HD Đặc Biệt", "leftValue": instructSpecialController.text},
    ];

    final List<Map<String, dynamic>> structureInfoRows = [
      {
        "leftKey": "Mặt E",
        "leftValue": ValidationPlanning.validateInput(
          label: "Mặt E thay thế (g)",
          controller: matEReplaceController,
          icon: Symbols.vertical_align_center,
        ),
        "middleKey": "Mặt B",
        "middleValue": ValidationPlanning.validateInput(
          label: "Mặt B thay thế (g)",
          controller: matBReplaceController,
          icon: Symbols.vertical_align_center,
        ),
        "rightKey": "Mặt C",
        "rightValue": ValidationPlanning.validateInput(
          label: "Mặt C thay thế (g)",
          controller: matCReplaceController,
          icon: Symbols.vertical_align_center,
        ),
      },

      {
        "leftKey": "Sóng E",
        "leftValue": ValidationPlanning.validateInput(
          label: "Sóng E thay thế (g)",
          controller: songEReplaceController,
          icon: Symbols.airwave,
        ),
        "middleKey": "Sóng B",
        "middleValue": ValidationPlanning.validateInput(
          label: "Sóng B thay thế (g)",
          controller: songBReplaceController,
          icon: Symbols.airwave,
        ),
        "rightKey": "Sóng C",
        "rightValue": ValidationPlanning.validateInput(
          label: "Sóng C thay thế (g)",
          controller: songCReplaceController,
          icon: Symbols.airwave,
        ),
      },

      {
        "leftKey": "Sóng E2",
        "leftValue": ValidationPlanning.validateInput(
          label: "Sóng E2 thay thế (g)",
          controller: songE2ReplaceController,
          icon: Symbols.airwave,
        ),
        "middleKey": "Mặt E2",
        "middleValue": ValidationPlanning.validateInput(
          label: "Mặt E2 thay thế (g)",
          controller: matE2ReplaceController,
          icon: Symbols.vertical_align_center,
        ),
        "rightKey": "Đáy",
        "rightValue": ValidationPlanning.validateInput(
          label: "Đáy thay thế (g)",
          controller: dayReplaceController,
          icon: Symbols.vertical_align_bottom,
        ),
      },

      {
        "leftKey": "Kết Cấu",
        "leftValue": ValidationPlanning.validateInput(
          label: "Kết Cấu Thay thế",
          controller: structureController,
          icon: Symbols.waves,
          readOnly: true,
        ),
      },
    ];

    final List<Map<String, dynamic>> manufactureInfoRows = [
      {
        "leftKey": "Dài sản xuất",
        "leftValue": ValidationPlanning.validateInput(
          label: "Dài sản xuất (cm)",
          controller: lengthPaperPlanningController,
          icon: Symbols.horizontal_distribute,
        ),
        "middleKey": "Khổ sản xuất",
        "middleValue": ValidationPlanning.validateInput(
          label: "Khổ sản xuất (cm)",
          controller: sizePaperPLaningController,
          icon: Symbols.horizontal_distribute,
        ),
        "rightKey": "Số Lớp Sóng",
        "rightValue": ValidationPlanning.validateInput(
          label: "Số Lớp Sóng",
          controller: fluteController,
          icon: Symbols.stacks,
        ),
      },

      {
        "leftKey": "Số Con",
        "leftValue": ValidationPlanning.validateInput(
          label: "Số Con",
          controller: numberChildController,
          icon: Symbols.numbers,
        ),
        "middleKey": "Ghép Khổ",
        "middleValue": ValidationPlanning.validateInput(
          label: "Ghép Khổ",
          controller: ghepKhoController,
          icon: Symbols.layers,
        ),

        "rightKey": "Kế hoạch chạy",
        "rightValue": ValidationPlanning.validateInput(
          label: "Kế hoạch chạy",
          controller: runningPlanController,
          icon: Symbols.production_quantity_limits,
          qtyProduced: widget.order?.totalQtyProduced,
          quantityOrderController: quantityOrderController,
        ),
      },

      {
        "leftKey": "Chọn Máy",
        "leftValue": ValidationOrder.dropdownForTypes(
          items: machineList,
          type: chooseMachine,
          onChanged: (value) {
            setState(() => chooseMachine = value!);
          },
        ),
        "middleKey": "",
        "middleValue": const SizedBox(),
        "rightKey": "",
        "rightValue": const SizedBox(),
      },
    ];

    return StatefulBuilder(
      builder: (context, state) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          content: SizedBox(
            width: ResponsiveSize.getWidth(context, ResponsiveType.xLarge),
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    //order
                    buildingCard(
                      title: "📦 Thông Tin Đơn Hàng",
                      children: formatKeyValueRows(
                        rows: orderInfoRows,
                        labelWidth: 145,
                        columnCount: 2,
                      ),
                    ),

                    const SizedBox(height: 15),

                    // planning
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "⚙️ KẾ HOẠCH SẢN XUẤT",
                          style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 20),
                        ),
                        const SizedBox(height: 15),

                        // CẤU TRÚC GIẤY
                        buildingCard(
                          title: "🧾 CẤU TRÚC GIẤY THAY THẾ",
                          children: formatKeyValueRows(
                            rows: structureInfoRows,
                            labelWidth: 170,
                            centerAlign: true,
                            columnCount: 3,
                          ),
                        ),

                        // THÔNG SỐ SẢN XUẤT
                        buildingCard(
                          title: "📏 THÔNG SỐ SẢN XUẤT",
                          children: formatKeyValueRows(
                            rows: manufactureInfoRows,
                            labelWidth: 170,
                            centerAlign: true,
                            columnCount: 3,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
          actionsPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                "Hủy",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.black54),
              ),
            ),
            ElevatedButton(
              onPressed: submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text(
                "Lưu",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }
}
