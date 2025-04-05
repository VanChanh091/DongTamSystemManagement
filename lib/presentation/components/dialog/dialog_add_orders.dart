import 'package:dongtam/data/models/order/box_model.dart';
import 'package:dongtam/data/models/order/info_production_model.dart';
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
  final List<String> itemsTypeProduct = [
    'Thùng/hộp',
    "Giấy tấm",
    "Giấy quấn cuồn",
    "Giấy cuộn",
    "Giấy kg",
  ];
  final List<String> itemsDvt = ['Kg', 'Cái', 'M2'];
  final List<String> itemsTeBien = [
    "Cấn lằn",
    "Quấn cuồn",
    "Tề gọn",
    "Tề biên đẹp",
    "Tề biên cột",
  ];

  //order
  final orderIdController = TextEditingController();
  final customerIdController = TextEditingController();
  final dayReceiveController = TextEditingController();
  final songController = TextEditingController();
  String typeProduct = "Thùng/hộp";
  String typeDVT = "Kg";
  String typeTeBien = "Cấn lằn";
  // final typeSpController = TextEditingController();
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
  final lengthController = TextEditingController();
  final sizeController = TextEditingController();
  final quantityController = TextEditingController();
  final dvtController = TextEditingController();
  final priceController = TextEditingController();
  final pricePaperController = TextEditingController();
  final dateShippingController = TextEditingController();
  final vatController = TextEditingController();
  DateTime? dayReceive;
  DateTime? dateShipping;

  //info Production
  final middle_1ControllerReplace = TextEditingController();
  final middle_2ControllerReplace = TextEditingController();
  final matControllerReplace = TextEditingController();
  final songEControllerReplace = TextEditingController();
  final songBControllerReplace = TextEditingController();
  final songCControllerReplace = TextEditingController();
  final songE2ControllerReplace = TextEditingController();
  final sizeInfoController = TextEditingController();
  final quantityInfoController = TextEditingController();
  final instructSpecialController = TextEditingController();
  final numChildController = TextEditingController();
  final teBienController = TextEditingController();
  final nextStepController = TextEditingController();

  //box
  final inMatTruocController = TextEditingController();
  final inMatSauController = TextEditingController();
  ValueNotifier<bool> canMangChecked = ValueNotifier<bool>(false);
  ValueNotifier<bool> xaChecked = ValueNotifier<bool>(false);
  ValueNotifier<bool> catKheChecked = ValueNotifier<bool>(false);
  ValueNotifier<bool> beChecked = ValueNotifier<bool>(false);
  ValueNotifier<bool> dan1ManhChecked = ValueNotifier<bool>(false);
  ValueNotifier<bool> dan2ManhChecked = ValueNotifier<bool>(false);
  ValueNotifier<bool> dongGhimChecked = ValueNotifier<bool>(false);
  final khac_1Controller = TextEditingController();
  final khac_2Controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.order != null) {
      //order
      orderIdController.text = widget.order!.orderId;
      customerIdController.text = widget.order!.customerId;
      songController.text = widget.order!.song ?? "";
      // typeSpController.text = widget.order!.typeProduct ?? "";
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
      lengthController.text = widget.order!.lengthPaper.toStringAsFixed(2);
      sizeController.text = widget.order!.paperSize.toStringAsFixed(2);
      quantityController.text = widget.order!.quantity.toStringAsFixed(2);
      dvtController.text = widget.order!.dvt;
      priceController.text = widget.order!.price.toStringAsFixed(2);
      pricePaperController.text = widget.order!.pricePaper.toStringAsFixed(2);
      vatController.text = widget.order!.vat.toString();
      dayReceive = DateTime.now();
      dateShipping = DateTime.now();

      //info Production
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

      //box
      inMatTruocController.text = widget.order!.box!.inMatTruoc.toString();
      inMatSauController.text = widget.order!.box!.inMatSau.toString();
      canMangChecked = ValueNotifier<bool>(widget.order!.box!.canMang ?? false);
      xaChecked = ValueNotifier<bool>(widget.order!.box!.Xa ?? false);
      catKheChecked = ValueNotifier<bool>(widget.order!.box!.catKhe ?? false);
      beChecked = ValueNotifier<bool>(widget.order!.box!.be ?? false);
      dan1ManhChecked = ValueNotifier<bool>(
        widget.order!.box!.dan_1_Manh ?? false,
      );
      dan2ManhChecked = ValueNotifier<bool>(
        widget.order!.box!.dan_2_Manh ?? false,
      );
      dongGhimChecked = ValueNotifier<bool>(
        widget.order!.box!.dongGhim ?? false,
      );
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
    // typeSpController.dispose();
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
    canMangChecked = ValueNotifier<bool>(false);
    xaChecked = ValueNotifier<bool>(false);
    catKheChecked = ValueNotifier<bool>(false);
    beChecked = ValueNotifier<bool>(false);
    dan1ManhChecked = ValueNotifier<bool>(false);
    dan2ManhChecked = ValueNotifier<bool>(false);
    dongGhimChecked = ValueNotifier<bool>(false);
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

    String totalPricePaper = Order.totalPricePaper(
      dvtController.text,
      double.tryParse(sizeController.text) ?? 0.0,
      double.tryParse(lengthController.text) ?? 0.0,
      double.tryParse(sizeController.text) ?? 0.0,
    );

    String totalPriceOrder = Order.totalPriceOrder(
      int.tryParse(quantityController.text) ?? 0,
      double.tryParse(totalPricePaper) ?? 0.0,
    );

    final newInfoProduction = InfoProduction(
      dayReplace: dayControllerReplace.text,
      middle_1Replace: middle_1Controller.text,
      middle_2Replace: middle_2ControllerReplace.text,
      matReplace: matControllerReplace.text,
      songE_Replace: songEControllerReplace.text,
      songB_Replace: songBControllerReplace.text,
      songC_Replace: songCControllerReplace.text,
      songE2_Replace: songE2ControllerReplace.text,
      sizePaper: double.tryParse(sizeInfoController.text) ?? 0.0,
      quantity: int.tryParse(quantityInfoController.text) ?? 0,
      instructSpecial: instructSpecialController.text,
      numberChild: int.tryParse(numChildController.text) ?? 0,
      teBien: typeTeBien,
      nextStep: nextStepController.text,
    );

    final newBox = Box(
      inMatTruoc: int.tryParse(inMatTruocController.text) ?? 0,
      inMatSau: int.tryParse(inMatSauController.text) ?? 0,
      canMang: canMangChecked.value,
      Xa: xaChecked.value,
      catKhe: catKheChecked.value,
      be: beChecked.value,
      dan_1_Manh: dan1ManhChecked.value,
      dan_2_Manh: dan2ManhChecked.value,
      dongGhim: dongGhimChecked.value,
      khac_1: khac_1Controller.text,
      khac_2: khac_2Controller.text,
    );

    final newOrder = Order(
      orderId: orderIdController.text.toUpperCase(),
      dayReceiveOrder: dayReceive ?? DateTime.now(),
      customerId: customerIdController.text,
      song: songController.text,
      typeProduct: typeProduct,
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
      dvt: typeDVT,
      price: double.tryParse(priceController.text) ?? 0.0,
      pricePaper: double.tryParse(totalPricePaper) ?? 0.0,
      dateRequestShipping: dateShipping ?? DateTime.now(),
      vat: int.tryParse(vatController.text) ?? 0,
      totalPrice: double.tryParse(totalPriceOrder) ?? 0.0,

      infoProduction: newInfoProduction,
      box: newBox,
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

      widget.onCustomerAddOrUpdate();
      Navigator.of(context).pop();
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
                                  child: DropdownButtonFormField<String>(
                                    value:
                                        typeProduct.isEmpty
                                            ? typeProduct
                                            : null,
                                    items:
                                        itemsTypeProduct.map((String value) {
                                          return DropdownMenuItem<String>(
                                            value: value,
                                            child: Row(
                                              children: [
                                                SizedBox(width: 10),
                                                Text(
                                                  value,
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        }).toList(),
                                    onChanged: (value) {
                                      setState(() {
                                        typeProduct = value!;
                                      });
                                    },
                                    decoration: InputDecoration(
                                      filled: true,
                                      fillColor: Colors.white,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: BorderSide(
                                          color: Colors.grey,
                                        ),
                                      ),
                                      contentPadding: EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 8,
                                      ),
                                    ),
                                    hint: Text(
                                      "Loại sản phẩm",
                                      style: TextStyle(color: Colors.black),
                                    ),
                                    icon: Icon(
                                      Icons.arrow_drop_down,
                                      color: Colors.black,
                                    ),
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.black,
                                    ),
                                    dropdownColor: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
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
                                    "Đơn giá",
                                    priceController,
                                    Symbols.price_change,
                                  ),
                                ),
                                SizedBox(
                                  width: 290,
                                  child: DropdownButtonFormField<String>(
                                    value: typeDVT.isEmpty ? typeDVT : null,
                                    items:
                                        itemsDvt.map((String value) {
                                          return DropdownMenuItem<String>(
                                            value: value,
                                            child: Row(
                                              children: [
                                                SizedBox(width: 10),
                                                Text(
                                                  value,
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        }).toList(),
                                    onChanged: (value) {
                                      setState(() {
                                        typeDVT = value!;
                                      });
                                    },
                                    decoration: InputDecoration(
                                      filled: true,
                                      fillColor: Colors.white,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: BorderSide(
                                          color: Colors.grey,
                                        ),
                                      ),
                                      contentPadding: EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 8,
                                      ),
                                    ),
                                    hint: Text(
                                      "Đơn vị tính",
                                      style: TextStyle(color: Colors.black),
                                    ),
                                    icon: Icon(
                                      Icons.arrow_drop_down,
                                      color: Colors.black,
                                    ),
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.black,
                                    ),
                                    dropdownColor: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
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
                                    "VAT",
                                    vatController,
                                    Symbols.percent,
                                  ),
                                ),
                                SizedBox(width: 290),
                                SizedBox(width: 290),
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
                                SizedBox(width: 290),
                              ],
                            ),

                            SizedBox(height: 15),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                SizedBox(
                                  width: 290,
                                  child: ValidationOrder.validateInput(
                                    "Số con",
                                    numChildController,
                                    Symbols.counter_5,
                                  ),
                                ),
                                SizedBox(
                                  width: 290,
                                  child: DropdownButtonFormField<String>(
                                    value:
                                        typeTeBien.isEmpty ? typeTeBien : null,
                                    items:
                                        itemsTeBien.map((String value) {
                                          return DropdownMenuItem<String>(
                                            value: value,
                                            child: Row(
                                              children: [
                                                SizedBox(width: 10),
                                                Text(
                                                  value,
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        }).toList(),
                                    onChanged: (value) {
                                      setState(() {
                                        typeTeBien = value!;
                                      });
                                    },
                                    decoration: InputDecoration(
                                      filled: true,
                                      fillColor: Colors.white,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: BorderSide(
                                          color: Colors.grey,
                                        ),
                                      ),
                                      contentPadding: EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 8,
                                      ),
                                    ),
                                    hint: Text(
                                      "Tề Biên",
                                      style: TextStyle(color: Colors.black),
                                    ),
                                    icon: Icon(
                                      Icons.arrow_drop_down,
                                      color: Colors.black,
                                    ),
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.black,
                                    ),
                                    dropdownColor: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),

                                SizedBox(
                                  width: 290,
                                  child: ValidationOrder.validateInput(
                                    "Công đoạn sau",
                                    nextStepController,
                                    Symbols.fast_forward,
                                  ),
                                ),
                                SizedBox(width: 290),
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
