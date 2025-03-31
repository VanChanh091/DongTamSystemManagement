import 'package:dongtam/data/models/order/order_model.dart';
import 'package:dongtam/service/order_Service.dart';
import 'package:dongtam/utils/validation/validation_order.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

class OrderDialog extends StatefulWidget {
  final Order? order;
  final VoidCallback onCustomerAddOrUpdate;

  const OrderDialog({
    super.key,
    this.order,
    required this.onCustomerAddOrUpdate,
  });

  @override
  State<OrderDialog> createState() => _OrderDialogState();
}

class _OrderDialogState extends State<OrderDialog> {
  final formKey = GlobalKey<FormState>();

  final orderIdController = TextEditingController();
  final customerIdController = TextEditingController();
  final dayReceiveController = TextEditingController();
  DateTime? dayReceive;
  final songController = TextEditingController();
  final typeSpController = TextEditingController();
  final nameSpController = TextEditingController();
  final qcBoxController = TextEditingController();
  final dayController = TextEditingController();
  final middle_1Controller = TextEditingController();
  final middle_2Controller = TextEditingController();
  final matController = TextEditingController();
  final songEController = TextEditingController();
  final songBController = TextEditingController();
  final songCController = TextEditingController();
  final songE2Controller = TextEditingController();
  final dayControllerReplace = TextEditingController();
  final middle_1ControllerReplace = TextEditingController();
  final middle_2ControllerReplace = TextEditingController();
  final matControllerReplace = TextEditingController();
  final songEControllerReplace = TextEditingController();
  final songBControllerReplace = TextEditingController();
  final songCControllerReplace = TextEditingController();
  final songE2ControllerReplace = TextEditingController();
  final lengthController = TextEditingController();
  final sizeController = TextEditingController();
  final quantityController = TextEditingController();
  final acreageController = TextEditingController();
  final dvtController = TextEditingController();
  final priceController = TextEditingController();
  final pricePaperController = TextEditingController();
  final dateShippingController = TextEditingController();
  final totalPrice = TextEditingController();
  final vatController = TextEditingController();
  DateTime? dateShipping;
  final sizeInfoController = TextEditingController();
  final quantityInfoController = TextEditingController();
  final instructSpecialController = TextEditingController();
  final numChildController = TextEditingController();
  final teBienController = TextEditingController();
  final nextStepController = TextEditingController();
  final inMatTruocController = TextEditingController();
  final inMatSauController = TextEditingController();
  bool canMangChecked = false;
  bool xaChecked = false;
  bool catKheChecked = false;
  bool beChecked = false;
  bool dan1ManhChecked = false;
  bool dan2ManhChecked = false;
  bool dongGhimChecked = false;
  final khac_1Controller = TextEditingController();
  final khac_2Controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.order != null) {
      orderIdController.text = widget.order!.orderId;
      dayReceive = DateTime.now();
      customerIdController.text = widget.order!.customerId;
      songController.text = widget.order!.song ?? "";
      typeSpController.text = widget.order!.typeProduct ?? "";
      nameSpController.text = widget.order!.productName ?? "";
      qcBoxController.text = widget.order!.QC_box ?? "";
      dayController.text = widget.order!.day ?? "";
      middle_1Controller.text = widget.order!.middle_1 ?? "";
      middle_2Controller.text = widget.order!.middle_2 ?? "";
      matController.text = widget.order!.mat ?? "";
      songEController.text = widget.order!.songE ?? "";
      songBController.text = widget.order!.songB ?? "";
      songCController.text = widget.order!.songC ?? "";
      songE2Controller.text = widget.order!.songE2 ?? "";
      dayControllerReplace.text =
          widget.order!.infoProduction!.dayReplace ?? "";
      middle_1ControllerReplace.text =
          widget.order!.infoProduction!.middle_1Replace ?? "";
      middle_2ControllerReplace.text =
          widget.order!.infoProduction!.middle_2Replace ?? "";
      matControllerReplace.text =
          widget.order!.infoProduction!.matReplace ?? "";
      songEControllerReplace.text =
          widget.order!.infoProduction!.songE_Replace ?? "";
      songBControllerReplace.text =
          widget.order!.infoProduction!.songB_Replace ?? "";
      songCControllerReplace.text =
          widget.order!.infoProduction!.songC_Replace ?? "";
      songE2ControllerReplace.text =
          widget.order!.infoProduction!.songE2_Replace ?? "";
      lengthController.text = widget.order!.lengthPaper.toStringAsFixed(2);
      sizeController.text = widget.order!.paperSize.toStringAsFixed(2);
      quantityController.text = widget.order!.quantity.toStringAsFixed(2);
      dvtController.text = widget.order!.dvt;
      priceController.text = widget.order!.price.toStringAsFixed(2);
      pricePaperController.text = widget.order!.pricePaper.toStringAsFixed(2);
      dateShipping = DateTime.now();
      totalPrice.text = widget.order!.totalPrice.toStringAsFixed(2);
      vatController.text = widget.order!.vat!.toStringAsFixed(2);
      sizeInfoController.text = widget.order!.infoProduction!.sizePaper
          .toStringAsFixed(2);
      quantityInfoController.text = widget.order!.infoProduction!.quantity
          .toStringAsFixed(0);
      instructSpecialController.text =
          widget.order!.infoProduction!.instructSpecial ?? "";
      numChildController.text =
          widget.order!.infoProduction!.numberChild.toString();
      teBienController.text = widget.order!.infoProduction!.teBien ?? "";
      nextStepController.text =
          widget.order!.infoProduction!.nextStep.toString();
      inMatTruocController.text = widget.order!.box!.inMatTruoc.toString();
      inMatSauController.text = widget.order!.box!.inMatSau.toString();
      canMangChecked = widget.order!.box!.canMang ?? false;
      xaChecked = widget.order!.box!.xa ?? false;
      catKheChecked = widget.order!.box!.catKhe ?? false;
      beChecked = widget.order!.box!.be ?? false;
      dan1ManhChecked = widget.order!.box!.dan_1_Manh ?? false;
      dan2ManhChecked = widget.order!.box!.dan_2_Manh ?? false;
      dongGhimChecked = widget.order!.box!.dongGhim ?? false;
      khac_1Controller.text = widget.order!.box!.khac_1 ?? "";
      khac_2Controller.text = widget.order!.box!.khac_2 ?? "";
    }
  }

  @override
  void dispose() {
    super.dispose();
    orderIdController.dispose();
    customerIdController.dispose();
    songController.dispose();
    typeSpController.dispose();
    nameSpController.dispose();
    qcBoxController.dispose();
    dayController.dispose();
    middle_1Controller.dispose();
    middle_2Controller.dispose();
    matController.dispose();
    songEController.dispose();
    songBController.dispose();
    songCController.dispose();
    songE2Controller.dispose();
    dayControllerReplace.dispose();
    middle_1ControllerReplace.dispose();
    middle_2ControllerReplace.dispose();
    matControllerReplace.dispose();
    songEControllerReplace.dispose();
    songBControllerReplace.dispose();
    songCControllerReplace.dispose();
    songE2ControllerReplace.dispose();
    lengthController.dispose();
    sizeController.dispose();
    quantityController.dispose();
    dvtController.dispose();
    priceController.dispose();
    pricePaperController.dispose();
    sizeInfoController.dispose();
    quantityInfoController.dispose();
    instructSpecialController.dispose();
    numChildController.dispose();
    teBienController.dispose();
    nextStepController.dispose();
    inMatTruocController.dispose();
    inMatSauController.dispose();
    canMangChecked = false;
    xaChecked = false;
    catKheChecked = false;
    beChecked = false;
    dan1ManhChecked = false;
    dan2ManhChecked = false;
    dongGhimChecked = false;
    khac_1Controller.dispose();
    khac_2Controller.dispose();
  }

  void submit() async {
    if (!formKey.currentState!.validate()) return;

    double totalAcreage = Order.acreagePaper(
      double.tryParse(lengthController.text) ?? 0.0,
      double.tryParse(sizeController.text) ?? 0.0,
      int.tryParse(quantityController.text) ?? 0,
    );

    String totalPrice = Order.totalPricePaper(
      dvtController.text,
      double.tryParse(sizeController.text) ?? 0.0,
      double.tryParse(lengthController.text) ?? 0.0,
      double.tryParse(sizeController.text) ?? 0.0,
    );

    final newOrder = Order(
      orderId: orderIdController.text.toUpperCase(),
      dayReceiveOrder: dayReceive ?? DateTime.now(),
      customerId: customerIdController.text,
      song: songController.text,
      typeProduct: typeSpController.text,
      productName: nameSpController.text,
      QC_box: qcBoxController.text,
      day: dayController.text,
      middle_1: middle_1Controller.text,
      middle_2: middle_2Controller.text,
      mat: matController.text,
      songE: songEController.text,
      songE2: songE2Controller.text,
      lengthPaper: double.tryParse(lengthController.text) ?? 0.0,
      paperSize: double.tryParse(sizeController.text) ?? 0.0,
      quantity: int.tryParse(quantityController.text) ?? 0,
      acreage: totalAcreage,
      dvt: dvtController.text,
      price: double.tryParse(priceController.text) ?? 0.0,
      pricePaper: double.tryParse(pricePaperController.text) ?? 0.0,
      dateRequestShipping: dateShipping ?? DateTime.now(),
      vat: double.tryParse(vatController.text) ?? 0.0,
      totalPrice: double.tryParse(totalPrice) ?? 0.0,
    );
    print(newOrder);

    try {
      if (widget.order == null) {
        //add
        await OrderService().addOrders(newOrder.toJson());
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Thêm thành công")));
      } else {
        //update
        await OrderService().updateOrderById(
          newOrder.orderId,
          newOrder.toJson(),
        );
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Cập nhật thành công")));
      }
    } catch (e) {
      print("Error: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Lỗi: không thể lưu dữ liệu")));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.order != null;

    return StatefulBuilder(
      builder: (context, state) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Center(
            child: Text(
              isEdit ? "Cập nhật khách hàng" : "Thêm khách hàng",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
          ),
          content: SizedBox(
            width: 1300,
            height: 800,
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Form(
                key: formKey,
                child: Column(
                  children: [
                    //Order
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
                      child: Expanded(
                        child: Column(
                          children: [
                            SizedBox(height: 15),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                SizedBox(
                                  width: 290,
                                  child: ValidationOrder.validateInput(
                                    "Mã Đơn Hàng",
                                    orderIdController,
                                    Symbols.orders,
                                    readOnly: isEdit,
                                  ),
                                ),
                                SizedBox(
                                  width: 290,
                                  child: ValidationOrder.validateInput(
                                    "Loại sản phẩm",
                                    typeSpController,
                                    Symbols.box,
                                  ),
                                ),

                                SizedBox(
                                  width: 290,
                                  child: ValidationOrder.validateInput(
                                    "Sóng",
                                    songController,
                                    Symbols.airwave,
                                  ),
                                ),
                                SizedBox(
                                  width: 290,
                                  child: ValidationOrder.validateInput(
                                    "Ngày nhận đơn hàng",
                                    dayReceiveController,
                                    Symbols.calendar_month,
                                    readOnly: true,
                                    onTap: () async {
                                      DateTime? pickedDate =
                                          await showDatePicker(
                                            context: context,
                                            initialDate:
                                                dayReceive ?? DateTime.now(),
                                            firstDate: DateTime(2000),
                                            lastDate: DateTime(2100),
                                          );
                                      if (pickedDate != null) {
                                        setState(() {
                                          dayReceive = pickedDate;
                                          dayReceiveController
                                              .text = DateFormat(
                                            'dd/MM/yyyy',
                                          ).format(pickedDate);
                                        });
                                      }
                                    },
                                  ),
                                ),
                              ],
                            ),

                            SizedBox(height: 15),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                SizedBox(
                                  width: 290,
                                  child: ValidationOrder.validateInput(
                                    "Mã Khách Hàng",
                                    customerIdController,
                                    Symbols.badge,
                                  ),
                                ),
                                SizedBox(
                                  width: 290,
                                  child: ValidationOrder.validateInput(
                                    "Tên sản phẩm",
                                    nameSpController,
                                    Symbols.box,
                                  ),
                                ),
                                SizedBox(
                                  width: 290,
                                  child: ValidationOrder.validateInput(
                                    "QC Thùng",
                                    qcBoxController,
                                    Symbols.deployed_code,
                                  ),
                                ),
                                SizedBox(
                                  width: 290,
                                  child: ValidationOrder.validateInput(
                                    "Ngày yêu cầu giao",
                                    dateShippingController,
                                    Symbols.calendar_month,
                                    readOnly: true,
                                    onTap: () async {
                                      DateTime? pickedDate =
                                          await showDatePicker(
                                            context: context,
                                            initialDate:
                                                dateShipping ?? DateTime.now(),
                                            firstDate: DateTime(2000),
                                            lastDate: DateTime(2100),
                                          );
                                      if (pickedDate != null) {
                                        setState(() {
                                          dateShipping = pickedDate;
                                          dateShippingController
                                              .text = DateFormat(
                                            'dd/MM/yyyy',
                                          ).format(pickedDate);
                                        });
                                      }
                                    },
                                  ),
                                ),
                              ],
                            ),

                            SizedBox(height: 15),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                SizedBox(
                                  width: 290,
                                  child: ValidationOrder.validateInput(
                                    "Cắt",
                                    lengthController,
                                    Symbols.vertical_distribute,
                                  ),
                                ),
                                SizedBox(
                                  width: 290,
                                  child: ValidationOrder.validateInput(
                                    "Số lượng",
                                    quantityController,
                                    Symbols.filter_9_plus,
                                  ),
                                ),
                                SizedBox(
                                  width: 290,
                                  child: ValidationOrder.validateInput(
                                    "Đơn vị tính",
                                    dvtController,
                                    Symbols.communities,
                                  ),
                                ),
                                SizedBox(
                                  width: 290,
                                  child: ValidationOrder.validateInput(
                                    "Diện tích",
                                    acreageController,
                                    Symbols.thermostat_carbon,
                                    readOnly: true,
                                  ),
                                ),
                              ],
                            ),

                            SizedBox(height: 15),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                SizedBox(
                                  width: 290,
                                  child: ValidationOrder.validateInput(
                                    "Khổ",
                                    sizeController,
                                    Symbols.horizontal_distribute,
                                  ),
                                ),
                                SizedBox(
                                  width: 290,
                                  child: ValidationOrder.validateInput(
                                    "Đơn giá",
                                    priceController,
                                    Symbols.price_change,
                                  ),
                                ),
                                SizedBox(
                                  width: 290,
                                  child: ValidationOrder.validateInput(
                                    "Giá tấm",
                                    pricePaperController,
                                    Symbols.price_change,
                                  ),
                                ),
                                SizedBox(
                                  width: 290,
                                  child: ValidationOrder.validateInput(
                                    "Doanh số",
                                    totalPrice,
                                    Symbols.attach_money,
                                    readOnly: true,
                                  ),
                                ),
                              ],
                            ),

                            SizedBox(height: 15),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                SizedBox(
                                  width: 290,
                                  child: ValidationOrder.validateInput(
                                    "Đáy",
                                    dayController,
                                    Symbols.vertical_align_bottom,
                                  ),
                                ),
                                SizedBox(
                                  width: 290,
                                  child: ValidationOrder.validateInput(
                                    "Giữa 1",
                                    middle_1Controller,
                                    Symbols.vertical_align_center,
                                  ),
                                ),
                                SizedBox(
                                  width: 290,
                                  child: ValidationOrder.validateInput(
                                    "Giữa 2",
                                    middle_2Controller,
                                    Symbols.vertical_align_center,
                                  ),
                                ),
                                SizedBox(
                                  width: 290,
                                  child: ValidationOrder.validateInput(
                                    "Mặt",
                                    matController,
                                    Symbols.vertical_align_top,
                                  ),
                                ),
                              ],
                            ),

                            SizedBox(height: 15),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                SizedBox(
                                  width: 290,
                                  child: ValidationOrder.validateInput(
                                    "Sóng E",
                                    songEController,
                                    Symbols.airwave,
                                  ),
                                ),
                                SizedBox(
                                  width: 290,
                                  child: ValidationOrder.validateInput(
                                    "Sóng B",
                                    songBController,
                                    Symbols.airwave,
                                  ),
                                ),
                                SizedBox(
                                  width: 290,
                                  child: ValidationOrder.validateInput(
                                    "Sóng C",
                                    songCController,
                                    Symbols.airwave,
                                  ),
                                ),
                                SizedBox(
                                  width: 290,
                                  child: ValidationOrder.validateInput(
                                    "Sóng E2",
                                    songE2Controller,
                                    Symbols.airwave,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 15),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 20),

                    //infoProduction
                    Text(
                      "Thông Tin Sản Xuất",
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
                      child: Expanded(
                        child: Column(
                          children: [
                            SizedBox(height: 15),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                SizedBox(
                                  width: 290,
                                  child: ValidationOrder.validateInput(
                                    "Đáy thay thế",
                                    dayControllerReplace,
                                    Symbols.vertical_align_bottom,
                                  ),
                                ),
                                SizedBox(
                                  width: 290,
                                  child: ValidationOrder.validateInput(
                                    "Giữa 1 thay thế",
                                    middle_1ControllerReplace,
                                    Symbols.vertical_align_center,
                                  ),
                                ),
                                SizedBox(
                                  width: 290,
                                  child: ValidationOrder.validateInput(
                                    "Giữa 2 thay thế",
                                    middle_2ControllerReplace,
                                    Symbols.vertical_align_center,
                                  ),
                                ),
                                SizedBox(
                                  width: 290,
                                  child: ValidationOrder.validateInput(
                                    "Mặt thay thế",
                                    matControllerReplace,
                                    Symbols.vertical_align_top,
                                  ),
                                ),
                              ],
                            ),

                            SizedBox(height: 15),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                SizedBox(
                                  width: 290,
                                  child: ValidationOrder.validateInput(
                                    "Sóng E thay thế",
                                    songEControllerReplace,
                                    Symbols.airwave,
                                  ),
                                ),
                                SizedBox(
                                  width: 290,
                                  child: ValidationOrder.validateInput(
                                    "Sóng B thay thế",
                                    songBControllerReplace,
                                    Symbols.airwave,
                                  ),
                                ),
                                SizedBox(
                                  width: 290,
                                  child: ValidationOrder.validateInput(
                                    "Sóng C thay thế",
                                    songCControllerReplace,
                                    Symbols.airwave,
                                  ),
                                ),
                                SizedBox(
                                  width: 290,
                                  child: ValidationOrder.validateInput(
                                    "Sóng E2 thay thế",
                                    songE2ControllerReplace,
                                    Symbols.airwave,
                                  ),
                                ),
                              ],
                            ),

                            SizedBox(height: 15),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                SizedBox(
                                  width: 290,
                                  child: ValidationOrder.validateInput(
                                    "Khổ tấm",
                                    sizeInfoController,
                                    Symbols.horizontal_distribute,
                                  ),
                                ),
                                SizedBox(
                                  width: 290,
                                  child: ValidationOrder.validateInput(
                                    "Số lượng",
                                    quantityInfoController,
                                    Symbols.filter_9_plus,
                                  ),
                                ),
                                SizedBox(
                                  width: 290,
                                  child: ValidationOrder.validateInput(
                                    "HD đặc biệt",
                                    instructSpecialController,
                                    Symbols.developer_guide,
                                  ),
                                ),
                                SizedBox(
                                  width: 290,
                                  child: ValidationOrder.validateInput(
                                    "VAT",
                                    vatController,
                                    Symbols.money,
                                  ),
                                ),
                              ],
                            ),

                            SizedBox(height: 15),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                SizedBox(
                                  width: 400,
                                  child: ValidationOrder.validateInput(
                                    "Số con",
                                    numChildController,
                                    Symbols.counter_5,
                                  ),
                                ),
                                SizedBox(
                                  width: 400,
                                  child: ValidationOrder.validateInput(
                                    "Tề biên",
                                    teBienController,
                                    Symbols.border_outer,
                                  ),
                                ),
                                SizedBox(
                                  width: 400,
                                  child: ValidationOrder.validateInput(
                                    "Công đoạn sau",
                                    nextStepController,
                                    Symbols.fast_forward,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 15),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 20),

                    //box
                    Text(
                      "Làm Thùng",
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
                      child: Expanded(
                        child: Column(
                          children: [
                            SizedBox(height: 15),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                SizedBox(
                                  width: 400,
                                  child: Column(
                                    children: [
                                      ValidationOrder.validateInput(
                                        "In mặt trước",
                                        inMatTruocController,
                                        Symbols.print,
                                      ),
                                      SizedBox(height: 15),
                                      ValidationOrder.validateInput(
                                        "In mặt sau",
                                        inMatSauController,
                                        Symbols.print,
                                      ),
                                    ],
                                  ),
                                ),

                                SizedBox(
                                  width: 400,
                                  child: Column(
                                    children: [
                                      ValidationOrder.validateInput(
                                        "Khác 1",
                                        khac_1Controller,
                                        Symbols.chat_bubble,
                                      ),
                                      SizedBox(height: 15),
                                      ValidationOrder.validateInput(
                                        "Khác 2",
                                        khac_2Controller,
                                        Symbols.chat_bubble,
                                      ),
                                    ],
                                  ),
                                ),

                                SizedBox(
                                  width: 185,
                                  child: Column(
                                    children: [
                                      ValidationOrder.checkboxForBox(
                                        "Cán màng",
                                        canMangChecked,
                                      ),
                                      ValidationOrder.checkboxForBox(
                                        "Xả",
                                        xaChecked,
                                      ),
                                    ],
                                  ),
                                ),

                                SizedBox(
                                  width: 185,
                                  child: Column(
                                    children: [
                                      ValidationOrder.checkboxForBox(
                                        "Dán 1 mảnh",
                                        dan1ManhChecked,
                                      ),
                                      ValidationOrder.checkboxForBox(
                                        "Dán 2 mảnh",
                                        dan2ManhChecked,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                SizedBox(width: 400),
                                SizedBox(width: 400),
                                SizedBox(
                                  width: 185,
                                  child: Column(
                                    children: [
                                      ValidationOrder.checkboxForBox(
                                        "Cắt khe",
                                        catKheChecked,
                                      ),
                                      ValidationOrder.checkboxForBox(
                                        "Bế",
                                        beChecked,
                                      ),
                                    ],
                                  ),
                                ),

                                SizedBox(
                                  width: 185,
                                  child: Column(
                                    children: [
                                      ValidationOrder.checkboxForBox(
                                        "Đóng ghim",
                                        dongGhimChecked,
                                      ),
                                      SizedBox(height: 50),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 15),
                          ],
                        ),
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
                isEdit ? "Cập nhật" : "Thêm",
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
