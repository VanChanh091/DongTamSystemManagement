import 'package:dongtam/data/models/order/order_model.dart';
import 'package:dongtam/data/models/planning/planning_paper_model.dart';
import 'package:dongtam/service/planning_service.dart';
import 'package:dongtam/utils/helper/building_card_form.dart';
import 'package:dongtam/utils/helper/reponsive_size.dart';
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
    totalPriceOrderController.text = order.totalPrice.toStringAsFixed(1);
    numberChildController.text = order.numberChild.toString();

    //date
    dateShipping = order.dateRequestShipping;
    dateShippingController.text = DateFormat('dd/MM/yyyy').format(dateShipping!);
  }

  void fillDataOrderToPlanning() {
    int leftQty =
        (int.tryParse(quantityOrderController.text) ?? 0) - (widget.order?.totalQtyProduced ?? 0);

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

    // check flute để sắp đúng máy
    if (flute.startsWith("2") && chooseMachine != "Máy 2 Lớp") {
      showSnackBarError(context, "Đơn 2 lớp, chỉ được chạy ở Máy 2 Lớp!");
      return;
    } else if (!flute.startsWith("2") && chooseMachine == "Máy 2 Lớp") {
      showSnackBarError(context, "Đơn này không được chạy ở Máy 2 Lớp!");
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
      await PlanningService().planningOrder(newPlanning.toJson(), originalOrderId);

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
        "rightKey": "Hướng Dẫn Đặc Biệt",
        "rightValue": instructSpecialController.text,
      },
      {"leftKey": "Dao Xả", "leftValue": daoXaOrderController.text},
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
                      children:
                          orderInfoRows.map((row) {
                            final leftKey = row['leftKey']?.toString().trim() ?? '';
                            final leftValue = row['leftValue']?.toString().trim() ?? '';
                            final rightKey = row['rightKey']?.toString().trim() ?? '';
                            final rightValue = row['rightValue']?.toString().trim() ?? '';

                            // Nếu tất cả đều rỗng -> bỏ qua
                            final isEmptyRow = [
                              leftKey,
                              leftValue,
                              rightKey,
                              rightValue,
                            ].every((e) => e.isEmpty);

                            if (isEmptyRow) return const SizedBox.shrink();

                            return Column(
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Left
                                    Expanded(
                                      flex: 1,
                                      child: RichText(
                                        text: TextSpan(
                                          children: [
                                            TextSpan(
                                              text: leftKey.isNotEmpty ? "$leftKey: " : "",
                                              style: GoogleFonts.inter(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black,
                                                fontSize: 16,
                                              ),
                                            ),
                                            TextSpan(
                                              text: leftValue.isNotEmpty ? leftValue : "",
                                              style: GoogleFonts.inter(
                                                fontWeight: FontWeight.w500,
                                                fontSize: 16,
                                                color: Colors.black87,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 25),

                                    // Right
                                    Expanded(
                                      flex: 1,
                                      child: RichText(
                                        text: TextSpan(
                                          children: [
                                            TextSpan(
                                              text: rightKey.isNotEmpty ? "$rightKey: " : "",
                                              style: GoogleFonts.inter(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black,
                                                fontSize: 16,
                                              ),
                                            ),
                                            TextSpan(
                                              text: rightValue.isNotEmpty ? rightValue : "",
                                              style: GoogleFonts.inter(
                                                fontWeight: FontWeight.w500,
                                                fontSize: 16,
                                                color: Colors.black87,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const Divider(height: 18, thickness: 0.6, color: Color(0xFFE0E0E0)),
                              ],
                            );
                          }).toList(),
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

                        // 🧾 CẤU TRÚC GIẤY
                        buildingCard(
                          title: "🧾 CẤU TRÚC GIẤY",
                          children: [
                            buildFieldRow([
                              ValidationPlanning.validateInput(
                                "Sóng E thay thế (g)",
                                songEReplaceController,
                                Symbols.airwave,
                              ),
                              ValidationPlanning.validateInput(
                                "Sóng B thay thế (g)",
                                songBReplaceController,
                                Symbols.airwave,
                              ),
                              ValidationPlanning.validateInput(
                                "Sóng C thay thế (g)",
                                songCReplaceController,
                                Symbols.airwave,
                              ),
                            ]),
                            buildFieldRow([
                              ValidationPlanning.validateInput(
                                "Mặt E thay thế (g)",
                                matEReplaceController,
                                Symbols.vertical_align_center,
                              ),
                              ValidationPlanning.validateInput(
                                "Mặt B thay thế (g)",
                                matBReplaceController,
                                Symbols.vertical_align_center,
                              ),
                              ValidationPlanning.validateInput(
                                "Mặt C thay thế (g)",
                                matCReplaceController,
                                Symbols.vertical_align_top,
                              ),
                            ]),
                            buildFieldRow([
                              ValidationPlanning.validateInput(
                                "Đáy thay thế (g)",
                                dayReplaceController,
                                Symbols.vertical_align_bottom,
                              ),
                              ValidationPlanning.validateInput(
                                "Sóng E2 thay thế (g)",
                                songE2ReplaceController,
                                Symbols.airwave,
                              ),
                              ValidationPlanning.validateInput(
                                "Sóng E2 thay thế (g)",
                                songE2ReplaceController,
                                Symbols.airwave,
                              ),
                            ]),
                            buildFieldRow([
                              ValidationPlanning.validateInput(
                                "Kết Cấu Thay thế",
                                structureController,
                                Symbols.waves,
                                readOnly: true,
                              ),
                            ]),
                          ],
                        ),

                        // 📏 THÔNG SỐ SẢN XUẤT
                        buildingCard(
                          title: "📏 THÔNG SỐ SẢN XUẤT",
                          children: [
                            buildFieldRow([
                              ValidationPlanning.validateInput(
                                "Dài sản xuất (cm)",
                                lengthPaperPlanningController,
                                Symbols.horizontal_distribute,
                              ),
                              ValidationPlanning.validateInput(
                                "Khổ sản xuất (cm)",
                                sizePaperPLaningController,
                                Symbols.horizontal_distribute,
                              ),
                              ValidationPlanning.validateInput(
                                "Số Lớp Sóng",
                                fluteController,
                                Symbols.stacks,
                              ),
                            ]),
                            buildFieldRow([
                              ValidationPlanning.validateInput(
                                "Kế hoạch chạy",
                                runningPlanController,
                                Symbols.production_quantity_limits,
                              ),
                              ValidationPlanning.validateInput(
                                "Ghép Khổ",
                                ghepKhoController,
                                Symbols.layers,
                              ),
                              ValidationPlanning.validateInput(
                                "Số Con",
                                numberChildController,
                                Symbols.numbers,
                              ),
                            ]),
                            buildFieldRow([
                              ValidationOrder.dropdownForTypes(machineList, chooseMachine, (value) {
                                setState(() => chooseMachine = value!);
                              }),
                            ]),
                          ],
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
