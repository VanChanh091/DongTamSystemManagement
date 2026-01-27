import 'dart:async';
import 'package:dongtam/data/controller/badges_controller.dart';
import 'package:dongtam/data/models/customer/customer_model.dart';
import 'package:dongtam/data/models/order/box_model.dart';
import 'package:dongtam/data/models/order/order_model.dart';
import 'package:dongtam/data/models/product/product_model.dart';
import 'package:dongtam/presentation/components/dialog/add/dialog_add_customer.dart';
import 'package:dongtam/presentation/components/dialog/add/dialog_add_product.dart';
import 'package:dongtam/service/customer_service.dart';
import 'package:dongtam/service/order_service.dart';
import 'package:dongtam/service/product_service.dart';
import 'package:dongtam/utils/helper/auto_complete_field.dart';
import 'package:dongtam/utils/helper/cardForm/building_card_form.dart';
import 'package:dongtam/utils/helper/cardForm/format_key_value_card.dart';
import 'package:dongtam/utils/helper/confirm_dialog.dart';
import 'package:dongtam/utils/helper/reponsive/reponsive_dialog.dart';
import 'package:dongtam/utils/logger/app_logger.dart';
import 'package:dongtam/utils/handleError/show_snack_bar.dart';
import 'package:dongtam/utils/validation/validation_order.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

class OrderDialog extends StatefulWidget {
  final Order? order;
  final void Function(String orderId)? onOrderAddOrUpdate;

  const OrderDialog({super.key, this.order, required this.onOrderAddOrUpdate});

  @override
  State<OrderDialog> createState() => _OrderDialogState();
}

class _OrderDialogState extends State<OrderDialog> {
  final formKey = GlobalKey<FormState>();
  final badgesController = Get.find<BadgesController>();
  Timer? _customerIdDebounce;
  Timer? _productIdDebounce;
  String lastSearchedCustomerId = "";
  String lastSearchedProductId = "";
  final List<String> itemsDvt = ['Tấm', 'Tấm Bao Khổ', 'Kg', 'Cái', 'M2', 'Lần'];
  final List<String> itemsDaoXa = ["Tề Gọn", "Tề Biên Đẹp", "Tề Biên Cột", "Quấn Cuồn"];
  late String originalOrderId;
  List<Customer> allCustomers = [];
  List<Product> allProducts = [];

  //order
  final orderIdController = TextEditingController();
  final qcBoxController = TextEditingController();
  final canLanController = TextEditingController();
  final dayController = TextEditingController();
  final matEController = TextEditingController();
  final matBController = TextEditingController();
  final matCController = TextEditingController();
  final matE2Controller = TextEditingController();
  final songEController = TextEditingController();
  final songBController = TextEditingController();
  final songCController = TextEditingController();
  final songE2Controller = TextEditingController();
  final lengthCustomerController = TextEditingController();
  final lengthManufactureController = TextEditingController();
  final sizeCustomerController = TextEditingController();
  final sizeManufactureController = TextEditingController();
  final quantityCustomerController = TextEditingController();
  final quantityManufactureController = TextEditingController();
  final numberChildController = TextEditingController();
  final priceController = TextEditingController();
  final pricePaperController = TextEditingController();
  final discountController = TextEditingController();
  final profitController = TextEditingController();
  final vatController = TextEditingController();
  final instructSpecialController = TextEditingController();
  final dvtController = TextEditingController();
  final daoXaController = TextEditingController();
  late String typeDVT = "Tấm";
  late String typeDaoXa = "Tề Gọn";
  final dateShippingController = TextEditingController(); //ngày giao
  DateTime? dateShipping; //ngày giao
  DateTime? dayReceive = DateTime.now(); //ngày nhận
  final customerIdController = TextEditingController();
  final productIdController = TextEditingController();
  final nameSpController = TextEditingController();
  final typeProduct = TextEditingController();
  final customerNameController = TextEditingController();
  final customerCompanyController = TextEditingController();
  ValueNotifier<bool> isBoxChecked = ValueNotifier<bool>(false);

  //box
  final inMatTruocController = TextEditingController();
  final inMatSauController = TextEditingController();
  final dongGoiController = TextEditingController();
  final maKhuonController = TextEditingController();
  ValueNotifier<bool> canMangChecked = ValueNotifier<bool>(false);
  ValueNotifier<bool> xaChecked = ValueNotifier<bool>(false);
  ValueNotifier<bool> catKheChecked = ValueNotifier<bool>(false);
  ValueNotifier<bool> canLanChecked = ValueNotifier<bool>(false);
  ValueNotifier<bool> beChecked = ValueNotifier<bool>(false);
  ValueNotifier<bool> dan1ManhChecked = ValueNotifier<bool>(false);
  ValueNotifier<bool> dan2ManhChecked = ValueNotifier<bool>(false);
  ValueNotifier<bool> chongThamChecked = ValueNotifier<bool>(false);
  ValueNotifier<bool> dongGhim1ManhChecked = ValueNotifier<bool>(false);
  ValueNotifier<bool> dongGhim2ManhChecked = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
    if (widget.order != null) {
      orderInitState();

      if (widget.order!.box != null) {
        boxInitState();
      }
    }

    fetchAllCustomers();
    fetchAllProduct();
    addListenerForField();
  }

  //init data to update
  void orderInitState() {
    final order = widget.order!;
    AppLogger.i("Khởi tạo form với orderId=${order.orderId}");

    originalOrderId = order.orderId;
    orderIdController.text = order.orderId;
    customerIdController.text = order.customerId;
    productIdController.text = order.productId;
    qcBoxController.text = order.QC_box.toString();
    canLanController.text = order.canLan.toString();
    dayController.text = order.day.toString();
    matEController.text = order.matE.toString();
    matBController.text = order.matB.toString();
    matCController.text = order.matC.toString();
    matE2Controller.text = order.matE2.toString();
    songEController.text = order.songE.toString();
    songBController.text = order.songB.toString();
    songCController.text = order.songC.toString();
    songE2Controller.text = order.songE2.toString();
    lengthCustomerController.text = order.lengthPaperCustomer.toStringAsFixed(1);
    lengthManufactureController.text = order.lengthPaperManufacture.toStringAsFixed(1);
    sizeCustomerController.text = order.paperSizeCustomer.toStringAsFixed(1);
    sizeManufactureController.text = order.paperSizeManufacture.toStringAsFixed(1);
    quantityCustomerController.text = order.quantityCustomer.toString();
    quantityManufactureController.text = order.quantityManufacture.toString();
    numberChildController.text = order.numberChild.toString();
    priceController.text = order.price.toString();
    pricePaperController.text = order.pricePaper.toString();
    discountController.text = order.discount?.toStringAsFixed(1) ?? '0.0';
    profitController.text = order.profit.toStringAsFixed(1);
    vatController.text = order.vat.toString();
    instructSpecialController.text = order.instructSpecial.toString();

    isBoxChecked = ValueNotifier<bool>(order.isBox);

    //dropdown
    typeDVT = order.dvt;
    typeDaoXa = order.daoXa;

    //date
    dayReceive = order.dayReceiveOrder;
    dateShipping = order.dateRequestShipping;
    dateShippingController.text = DateFormat('dd/MM/yyyy').format(dateShipping!);
  }

  //init data to update
  void boxInitState() {
    AppLogger.i("Khởi tạo form với orderId=${widget.order!.box!.boxId}");

    final box = widget.order!.box;
    if (box == null) return;

    inMatTruocController.text = box.inMatTruoc?.toString() ?? '';
    inMatSauController.text = box.inMatSau?.toString() ?? '';
    canMangChecked = ValueNotifier<bool>(box.canMang ?? false);
    canLanChecked = ValueNotifier<bool>(box.canLan ?? false);
    xaChecked = ValueNotifier<bool>(box.Xa ?? false);
    catKheChecked = ValueNotifier<bool>(box.catKhe ?? false);
    beChecked = ValueNotifier<bool>(box.be ?? false);
    dan1ManhChecked = ValueNotifier<bool>(box.dan_1_Manh ?? false);
    dan2ManhChecked = ValueNotifier<bool>(box.dan_2_Manh ?? false);
    dongGhim1ManhChecked = ValueNotifier<bool>(box.dongGhim1Manh ?? false);
    dongGhim2ManhChecked = ValueNotifier<bool>(box.dongGhim2Manh ?? false);
    chongThamChecked = ValueNotifier<bool>(box.chongTham ?? false);
    dongGoiController.text = box.dongGoi ?? "";
    maKhuonController.text = box.maKhuon ?? "";
  }

  Future<void> fetchAllCustomers() async {
    try {
      final result = await CustomerService().getAllCustomers(noPaging: true);

      allCustomers = result['customers'] as List<Customer>;
      AppLogger.i("Fetch thành công tất cả khách hàng vào order");
    } catch (e, s) {
      AppLogger.e("Lỗi khi tải danh sách khách hàng", error: e, stackTrace: s);
    }
  }

  Future<void> fetchAllProduct() async {
    try {
      final result = await ProductService().getAllProducts(noPaging: true);

      allProducts = result['products'] as List<Product>;
      AppLogger.i("Fetch thành công tất cả sản phẩm vào order");
    } catch (e, s) {
      AppLogger.e("Lỗi khi tải danh sách sản phẩm", error: e, stackTrace: s);
    }
  }

  //listener
  void listenerForFieldNeed(
    TextEditingController fieldController,
    TextEditingController fieldControllerReplace,
  ) {
    fieldController.addListener(() {
      if (fieldController.text != fieldControllerReplace.text) {
        fieldControllerReplace.text = fieldController.text;
      }
    });
  }

  void addListenerForField() {
    listenerForFieldNeed(lengthCustomerController, lengthManufactureController);
    listenerForFieldNeed(sizeCustomerController, sizeManufactureController);
    listenerForFieldNeed(quantityCustomerController, quantityManufactureController);
  }

  // create a string after prefix
  String generateOrderCode(String prefix) {
    if (prefix.contains('/D')) return prefix;

    final now = DateTime.now();
    final String month = now.month.toString().padLeft(2, '0');
    final String year = now.year.toString().substring(2);
    return "$prefix/$month/$year/D";
  }

  void submit() async {
    //bắt validate form
    if (!formKey.currentState!.validate()) {
      AppLogger.w("Form không hợp lệ, dừng submit");
      return;
    }
    final prefix = orderIdController.text.toUpperCase();

    double totalAcreage =
        Order.acreagePaper(
          lengthPaper: double.tryParse(lengthCustomerController.text) ?? 0,
          paperSize: double.tryParse(sizeCustomerController.text) ?? 0,
          quantity: int.tryParse(quantityCustomerController.text) ?? 0,
        ).roundToDouble();

    late double totalPricePaper =
        Order.totalPricePaper(
          dvt: typeDVT,
          length: double.tryParse(lengthCustomerController.text) ?? 0,
          size: double.tryParse(sizeCustomerController.text) ?? 0,
          price: double.tryParse(priceController.text) ?? 0,
          pricePaper: double.tryParse(pricePaperController.text) ?? 0,
        ).roundToDouble();

    late double totalPriceOrder =
        Order.totalPriceOrder(
          quantity: int.tryParse(quantityCustomerController.text) ?? 0,
          pricePaper: totalPricePaper,
        ).roundToDouble();

    late double totalPriceVAT =
        Order.totalPriceAfterVAT(
          totalPrice: totalPriceOrder,
          vat: int.tryParse(vatController.text) ?? 0,
        ).roundToDouble();

    // helper: only add prefix if not empty and not already present
    String addPrefixIfNeeded(String value, String prefix) {
      value = value.trim().toUpperCase();
      if (value.isEmpty) return '';
      return value.startsWith(prefix) ? value : '$prefix$value';
    }

    // determine wave fields
    late final String songEValue;
    late final String songBValue;
    late final String songCValue;
    late final String songE2Value;

    if (widget.order == null) {
      // add mode
      songEValue = addPrefixIfNeeded(songEController.text, 'E');
      songBValue = addPrefixIfNeeded(songBController.text, 'B');
      songCValue = addPrefixIfNeeded(songCController.text, 'C');
      songE2Value = addPrefixIfNeeded(songE2Controller.text, 'E');
    } else {
      // update mode
      songEValue = addPrefixIfNeeded(songEController.text, 'E');
      songBValue = addPrefixIfNeeded(songBController.text, 'B');
      songCValue = addPrefixIfNeeded(songCController.text, 'C');
      songE2Value = addPrefixIfNeeded(songE2Controller.text, 'E');
    }

    // flute
    late String flutePaper = Order.flutePaper(
      day: dayController.text,
      matE: matEController.text,
      matB: matBController.text,
      matC: matCController.text,
      matE2: matE2Controller.text,
      songE: songEValue,
      songB: songBValue,
      songC: songCValue,
      songE2: songE2Value,
    );

    final newBox = Box(
      inMatTruoc: int.tryParse(inMatTruocController.text) ?? 0,
      inMatSau: int.tryParse(inMatSauController.text) ?? 0,
      canMang: canMangChecked.value,
      canLan: canLanChecked.value,
      Xa: xaChecked.value,
      catKhe: catKheChecked.value,
      be: beChecked.value,
      dan_1_Manh: dan1ManhChecked.value,
      dan_2_Manh: dan2ManhChecked.value,
      dongGhim1Manh: dongGhim1ManhChecked.value,
      dongGhim2Manh: dongGhim2ManhChecked.value,
      chongTham: chongThamChecked.value,
      dongGoi: dongGoiController.text,
      maKhuon: maKhuonController.text,
    );

    final newOrder = Order(
      orderId: generateOrderCode(prefix),
      customerId: customerIdController.text.toUpperCase(),
      productId: productIdController.text.toUpperCase(),
      dayReceiveOrder: dayReceive ?? DateTime.now(),
      flute: flutePaper,
      QC_box: qcBoxController.text.toLowerCase(),
      canLan: canLanController.text,
      daoXa: typeDaoXa,
      day: dayController.text.toUpperCase(),
      matE: matEController.text.toUpperCase(),
      matB: matBController.text.toUpperCase(),
      matC: matCController.text.toUpperCase(),
      matE2: matE2Controller.text.toUpperCase(),
      songE: songEValue,
      songB: songBValue,
      songC: songCValue,
      songE2: songE2Value,
      lengthPaperCustomer: double.tryParse(lengthCustomerController.text) ?? 0.0,
      lengthPaperManufacture: double.tryParse(lengthManufactureController.text) ?? 0.0,
      paperSizeCustomer: double.tryParse(sizeCustomerController.text) ?? 0.0,
      paperSizeManufacture: double.tryParse(sizeManufactureController.text) ?? 0.0,
      quantityCustomer: int.tryParse(quantityCustomerController.text) ?? 0,
      quantityManufacture: int.tryParse(quantityManufactureController.text) ?? 0,
      numberChild: int.tryParse(numberChildController.text) ?? 0,
      acreage: totalAcreage,
      dvt: typeDVT,
      price: double.tryParse(priceController.text) ?? 0.0,
      discount: double.tryParse(discountController.text) ?? 0.0,
      profit: double.tryParse(profitController.text) ?? 0.0,
      pricePaper: totalPricePaper,
      dateRequestShipping: dateShipping ?? DateTime.now(),
      vat: int.tryParse(vatController.text) ?? 0,
      instructSpecial: instructSpecialController.text,
      isBox: isBoxChecked.value,

      totalPrice: totalPriceOrder,
      totalPriceVAT: totalPriceVAT,
      box: newBox,
      status: 'pending',
    );

    try {
      final bool isAdd = widget.order == null;
      String? orderId;

      AppLogger.i(
        isAdd ? "Thêm đơn hàng mới: ${newOrder.orderId}" : "Cập nhật đơn hàng: ${newOrder.orderId}",
      );

      if (isAdd) {
        final response = await OrderService().addOrders(orderData: newOrder.toJson());
        orderId = response['orderId'];
      } else {
        await OrderService().updateOrderById(
          orderId: originalOrderId,
          orderUpdated: newOrder.toJson(),
        );
      }

      // Show loading
      if (!mounted) return;
      showLoadingDialog(context);
      await Future.delayed(const Duration(seconds: 1));

      if (!mounted) return;
      Navigator.pop(context); // đóng dialog loading

      // Thông báo thành công
      if (!mounted) return;
      showSnackBarSuccess(context, isAdd ? "Thêm thành công" : "Cập nhật thành công");

      //fetch lại badge sau khi add/update
      badgesController.fetchPendingApprovals();

      widget.onOrderAddOrUpdate?.call(orderId ?? newOrder.orderId);

      if (!mounted) return;
      Navigator.of(context).pop();
    } catch (e, s) {
      if (!mounted) return;
      AppLogger.e(
        widget.order == null ? "Lỗi khi thêm đơn hàng" : "Lỗi khi sửa đơn hàng",
        error: e,
        stackTrace: s,
      );

      showSnackBarError(context, 'Lỗi: Không thể lưu dữ liệu');
    }
  }

  @override
  void dispose() {
    super.dispose();
    orderIdController.dispose();
    instructSpecialController.dispose();
    customerIdController.dispose();
    productIdController.dispose();
    dateShippingController.dispose();
    customerNameController.dispose();
    customerCompanyController.dispose();
    typeProduct.dispose();
    qcBoxController.dispose();
    nameSpController.dispose();
    dayController.dispose();
    matEController.dispose();
    matBController.dispose();
    matCController.dispose();
    matE2Controller.dispose();
    songEController.dispose();
    songBController.dispose();
    songCController.dispose();
    songE2Controller.dispose();
    lengthCustomerController.dispose();
    lengthManufactureController.dispose();
    sizeCustomerController.dispose();
    sizeManufactureController.dispose();
    quantityCustomerController.dispose();
    quantityManufactureController.dispose();
    numberChildController.dispose();
    dvtController.dispose();
    daoXaController.dispose();
    priceController.dispose();
    pricePaperController.dispose();
    discountController.dispose();
    profitController.dispose();
    inMatTruocController.dispose();
    inMatSauController.dispose();
    canMangChecked = ValueNotifier<bool>(false);
    canLanChecked = ValueNotifier<bool>(false);
    xaChecked = ValueNotifier<bool>(false);
    catKheChecked = ValueNotifier<bool>(false);
    beChecked = ValueNotifier<bool>(false);
    dan1ManhChecked = ValueNotifier<bool>(false);
    dan2ManhChecked = ValueNotifier<bool>(false);
    chongThamChecked = ValueNotifier<bool>(false);
    dongGhim1ManhChecked = ValueNotifier<bool>(false);
    dongGhim2ManhChecked = ValueNotifier<bool>(false);
    isBoxChecked = ValueNotifier<bool>(false);
    dongGoiController.dispose();
    maKhuonController.dispose();
    _customerIdDebounce?.cancel();
    _productIdDebounce?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.order != null;

    final List<Map<String, dynamic>> infoBasicRows = [
      {
        "leftKey": "Mã Đơn Hàng",
        "leftValue": ValidationOrder.validateInput(
          label: "Mã Đơn Hàng",
          controller: orderIdController,
          icon: Symbols.orders,
          readOnly: isEdit,
          checkId: !isEdit,
        ),
        "middleKey": "QC Thùng",
        "middleValue": ValidationOrder.validateInput(
          label: "QC Thùng",
          controller: qcBoxController,
          icon: Symbols.deployed_code,
        ),
        "rightKey": "Ngày giao",
        "rightValue": ValidationOrder.validateInput(
          label: "Ngày yêu cầu giao",
          controller: dateShippingController,
          icon: Symbols.calendar_month,
          readOnly: true,
          onTap: () async {
            DateTime baseDate = dayReceive ?? DateTime.now();
            DateTime? pickedDate = await showDatePicker(
              context: context,
              initialDate: dateShipping ?? dayReceive,
              firstDate: baseDate,
              lastDate: DateTime(2100),
              builder: (BuildContext context, Widget? child) {
                return Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: ColorScheme.light(
                      primary: Colors.blue,
                      onPrimary: Colors.white,
                      onSurface: Colors.black,
                    ),
                    dialogTheme: DialogThemeData(backgroundColor: Colors.white12),
                  ),
                  child: child!,
                );
              },
            );
            if (pickedDate != null) {
              setState(() {
                dateShipping = pickedDate;
                dateShippingController.text = DateFormat('dd/MM/yyyy').format(pickedDate);
              });
            }
          },
        ),
      },

      {
        "leftKey": "Mã Khách Hàng",
        "leftValue": AutoCompleteField<Customer>(
          controller: customerIdController,
          labelText: "Mã Khách Hàng",
          icon: Symbols.badge,
          suggestionsCallback: (pattern) async {
            final result = await CustomerService().getCustomerByField(
              field: 'customerId',
              keyword: pattern,
            );
            if (result['customers'] != null && result['customers'] is List<Customer>) {
              return result['customers'] as List<Customer>;
            }

            return [];
          },
          displayStringForItem: (customer) => customer.customerId,
          itemBuilder: (context, customer) {
            return ListTile(
              title: Text(customer.customerId),
              subtitle: Text(customer.customerName),
            );
          },
          onSelected: (customer) {
            customerIdController.text = customer.customerId;
            customerNameController.text = customer.customerName;
            customerCompanyController.text = customer.companyName;
          },
          onPlusTap: () {
            showDialog(
              context: context,
              builder:
                  (_) => CustomerDialog(
                    customer: null,
                    onCustomerAddOrUpdate: () {
                      fetchAllCustomers();
                    },
                  ),
            );
          },
          onChanged: (value) {
            if (value.isEmpty) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                customerNameController.clear();
                customerCompanyController.clear();
              });
            }
          },
        ),
        "middleKey": "Tên Khách Hàng",
        "middleValue": ValidationOrder.validateInput(
          label: "Tên Khách Hàng",
          controller: customerNameController,
          icon: Symbols.person,
          readOnly: true,
        ),
        "rightKey": "Tên công ty",
        "rightValue": ValidationOrder.validateInput(
          label: "Tên công ty KH",
          controller: customerCompanyController,
          icon: Symbols.business,
          readOnly: true,
        ),
      },

      {
        "leftKey": "Mã Sản Phẩm",
        "leftValue": AutoCompleteField<Product>(
          controller: productIdController,
          labelText: "Mã Sản Phẩm",
          icon: Symbols.box,
          suggestionsCallback: (pattern) async {
            final result = await ProductService().getProductByField(
              field: 'productId',
              keyword: pattern,
            );
            if (result['products'] != null && result['products'] is List<Product>) {
              return result['products'] as List<Product>;
            }

            return [];
          },
          displayStringForItem: (product) => product.productId,
          itemBuilder: (context, product) {
            return ListTile(
              title: Text(product.productId),
              subtitle: Text(product.productName ?? ""),
            );
          },
          onSelected: (product) {
            productIdController.text = product.productId;
            typeProduct.text = product.typeProduct;
            nameSpController.text = product.productName ?? "";
            maKhuonController.text = product.maKhuon ?? "";
          },
          onPlusTap: () {
            showDialog(
              context: context,
              builder:
                  (_) => ProductDialog(
                    product: null,
                    onProductAddOrUpdate: () {
                      fetchAllProduct();
                    },
                  ),
            );
          },
          onChanged: (value) {
            if (value.isEmpty) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                typeProduct.clear();
                nameSpController.clear();
                maKhuonController.clear();
              });
            }
          },
        ),
        "middleKey": "Loại sản phẩm",
        "middleValue": ValidationOrder.validateInput(
          label: "Loại sản phẩm",
          controller: typeProduct,
          icon: Symbols.comment,
          readOnly: true,
        ),
        "rightKey": "Tên sản phẩm",
        "rightValue": ValidationOrder.validateInput(
          label: "Tên sản phẩm",
          controller: nameSpController,
          icon: Symbols.box,
          readOnly: true,
        ),
      },

      {
        "leftKey": "Dài khách đặt",
        "leftValue": ValidationOrder.validateInput(
          label: "Dài khách đặt (cm)",
          controller: lengthCustomerController,
          icon: Symbols.vertical_distribute,
        ),
        "middleKey": "Khổ khách đặt",
        "middleValue": ValidationOrder.validateInput(
          label: "Khổ khách đặt (cm)",
          controller: sizeCustomerController,
          icon: Symbols.horizontal_distribute,
        ),
        "rightKey": "Số lượng",
        "rightValue": ValidationOrder.validateInput(
          label: "Số lượng (KH)",
          controller: quantityCustomerController,
          icon: Symbols.filter_9_plus,
        ),
      },

      {
        "leftKey": "Dài sản xuất",
        "leftValue": ValidationOrder.validateInput(
          label: "Dài sản xuất (cm)",
          controller: lengthManufactureController,
          icon: Symbols.vertical_distribute,
        ),
        "middleKey": "Khổ sản xuất",
        "middleValue": ValidationOrder.validateInput(
          label: "Khổ sản xuất (cm)",
          controller: sizeManufactureController,
          icon: Symbols.horizontal_distribute,
        ),
        "rightKey": "Số lượng",
        "rightValue": ValidationOrder.validateInput(
          label: "Số lượng (SX)",
          controller: quantityManufactureController,
          icon: Symbols.filter_9_plus,
        ),
      },

      {
        "leftKey": "Dao Tề",
        "leftValue": ValidationOrder.dropdownForTypes(
          items: itemsDaoXa,
          type: typeDaoXa,
          onChanged: (value) {
            setState(() {
              typeDaoXa = value!;
            });
          },
        ),
        "middleKey": "Số con",
        "middleValue": ValidationOrder.validateInput(
          label: "Số con",
          controller: numberChildController,
          icon: Symbols.box,
        ),
        "rightKey": "",
        "rightValue": const SizedBox(),
      },
    ];

    final List<Map<String, dynamic>> costRows = [
      {
        "leftKey": "Đơn giá",
        "leftValue": ValidationOrder.validateInput(
          label: "Đơn giá (M2)",
          controller: priceController,
          icon: Symbols.price_change,
        ),
        "middleKey": "Chiết khấu",
        "middleValue": ValidationOrder.validateInput(
          label: "Chiết khấu",
          controller: discountController,
          icon: Symbols.price_change,
        ),
        "rightKey": "Lợi nhuận",
        "rightValue": ValidationOrder.validateInput(
          label: "Lợi nhuận",
          controller: profitController,
          icon: Symbols.price_change,
        ),
      },
      {
        "leftKey": "VAT",
        "leftValue": ValidationOrder.validateInput(
          label: "VAT",
          controller: vatController,
          icon: Symbols.percent,
        ),
        "middleKey": "Giá Tấm Bao Khổ",
        "middleValue": ValidationOrder.validateInput(
          label: "Giá Tấm Bao Khổ (M2)",
          controller: pricePaperController,
          icon: Symbols.price_change,
          readOnly: typeDVT != 'Tấm Bao Khổ',
        ),
        "rightKey": "Đơn Vị Tính",
        "rightValue": ValidationOrder.dropdownForTypes(
          items: itemsDvt,
          type: typeDVT,
          onChanged: (value) {
            setState(() {
              typeDVT = value!;
            });
          },
        ),
      },
    ];

    final List<Map<String, dynamic>> structureRows = [
      {
        "leftKey": "Mặt E",
        "leftValue": ValidationOrder.validateInput(
          label: "Mặt E (g)",
          controller: matEController,
          icon: Symbols.vertical_align_center,
        ),
        "middle_1Key": "Mặt B",
        "middle_1Value": ValidationOrder.validateInput(
          label: "Mặt B (g)",
          controller: matBController,
          icon: Symbols.vertical_align_center,
        ),
        "middle_2Key": "Mặt C",
        "middle_2Value": ValidationOrder.validateInput(
          label: "Mặt C (g)",
          controller: matCController,
          icon: Symbols.vertical_align_center,
        ),
        "rightKey": "Mặt E2",
        "rightValue": ValidationOrder.validateInput(
          label: "Mặt E2 (g)",
          controller: matE2Controller,
          icon: Symbols.vertical_align_center,
        ),
      },

      {
        "leftKey": "Sóng E",
        "leftValue": ValidationOrder.validateInput(
          label: "Sóng E (g)",
          controller: songEController,
          icon: Symbols.airwave,
        ),
        "middle_1Key": "Sóng B",
        "middle_1Value": ValidationOrder.validateInput(
          label: "Sóng B (g)",
          controller: songBController,
          icon: Symbols.airwave,
        ),
        "middle_2Key": "Sóng C",
        "middle_2Value": ValidationOrder.validateInput(
          label: "Sóng C (g)",
          controller: songCController,
          icon: Symbols.airwave,
        ),
        "rightKey": "Sóng E2",
        "rightValue": ValidationOrder.validateInput(
          label: "Sóng E2 (g)",
          controller: songE2Controller,
          icon: Symbols.airwave,
        ),
      },

      {
        "leftKey": "Đáy",
        "leftValue": ValidationOrder.validateInput(
          label: "Đáy (g)",
          controller: dayController,
          icon: Symbols.vertical_align_bottom,
        ),
        "middle_1Key": "Cấn Lằn",
        "middle_1Value": ValidationOrder.validateInput(
          label: "Cấn Lằn",
          controller: canLanController,
          icon: Symbols.bottom_sheets,
        ),
        "middle_2Key": "",
        "middle_2Value": const SizedBox(),
        "rightKey": "",
        "rightValue": const SizedBox(),
      },
    ];

    //box
    List<Map<String, dynamic>> buildBoxes(bool isEnabled) {
      return [
        {
          'left':
              () => ValidationOrder.validateInput(
                label: "Số màu in mặt trước",
                controller: inMatTruocController,
                icon: Symbols.print,
                enabled: isEnabled,
              ),
          'middle_1':
              () => ValidationOrder.validateInput(
                label: "Số màu in mặt sau",
                controller: inMatSauController,
                icon: Symbols.print,
                enabled: isEnabled,
              ),
          'middle_2':
              () => ValidationOrder.validateInput(
                label: "Cách Đóng gói",
                controller: dongGoiController,
                icon: Symbols.box,
                enabled: isEnabled,
              ),
          'middle_3':
              () => ValidationOrder.validateInput(
                label: "Mã Khuôn",
                controller: maKhuonController,
                icon: Symbols.box,
                readOnly: true,
                enabled: isEnabled,
              ),
          'right': () => const SizedBox(),
        },
        {
          'left':
              () => ValidationOrder.checkboxForBox(
                label: "Chống thấm",
                notifier: chongThamChecked,
                enabled: isEnabled,
              ),
          'middle_1':
              () => ValidationOrder.checkboxForBox(
                label: "Xả",
                notifier: xaChecked,
                enabled: isEnabled,
              ),
          'middle_2':
              () => ValidationOrder.checkboxForBox(
                label: "Cắt khe",
                notifier: catKheChecked,
                enabled: isEnabled,
              ),
          'middle_3':
              () => ValidationOrder.checkboxForBox(
                label: "Dán 1 mảnh",
                notifier: dan1ManhChecked,
                enabled: isEnabled,
              ),
          'right':
              () => ValidationOrder.checkboxForBox(
                label: "Dán 2 mảnh",
                notifier: dan2ManhChecked,
                enabled: isEnabled,
              ),
        },
        {
          'left':
              () => ValidationOrder.checkboxForBox(
                label: "Cán màng",
                notifier: canMangChecked,
                enabled: isEnabled,
              ),
          'middle_1':
              () => ValidationOrder.checkboxForBox(
                label: "Bế",
                notifier: beChecked,
                enabled: isEnabled,
              ),
          'middle_2':
              () => ValidationOrder.checkboxForBox(
                label: "Cấn Lằn",
                notifier: canLanChecked,
                enabled: isEnabled,
              ),

          'middle_3':
              () => ValidationOrder.checkboxForBox(
                label: "Đóng ghim 1 mảnh",
                notifier: dongGhim1ManhChecked,
                enabled: isEnabled,
              ),

          'right':
              () => ValidationOrder.checkboxForBox(
                label: "Đóng ghim 2 mảnh",
                notifier: dongGhim2ManhChecked,
                enabled: isEnabled,
              ),
        },
      ];
    }

    return StatefulBuilder(
      builder: (context, state) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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

                    //Order
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "📜 CÔNG ĐOẠN 1",
                          style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 20),
                        ),
                        const SizedBox(height: 15),

                        buildingCard(
                          title: "📃 Thông Tin Cơ Bản",
                          children: formatKeyValueRows(
                            rows: infoBasicRows,
                            labelWidth: 150,
                            centerAlign: true,
                            columnCount: 3,
                          ),
                        ),
                        const SizedBox(height: 15),

                        buildingCard(
                          title: "📃 Chi Phí",
                          children: formatKeyValueRows(
                            rows: costRows,
                            labelWidth: 150,
                            centerAlign: true,
                            columnCount: 3,
                          ),
                        ),
                        const SizedBox(height: 15),

                        //structure
                        buildingCard(
                          title: "🗜 Kết Cấu Giấy",
                          children: formatKeyValueRows(
                            rows: structureRows,
                            labelWidth: 80,
                            centerAlign: true,
                            columnCount: 4,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),

                    //box
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Stack(
                          children: [
                            Text(
                              "📦 CÔNG ĐOẠN 2",
                              style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 20),
                            ),
                            Align(
                              alignment: Alignment.centerRight,
                              child: SizedBox(
                                width: 150,
                                child: ValidationOrder.checkboxForBox(
                                  label: "Làm thùng?",
                                  notifier: isBoxChecked,
                                ),
                              ),
                            ),
                          ],
                        ),
                        buildingCard(
                          title: "Làm Thùng",
                          children: [
                            // Render các dòng field
                            ValueListenableBuilder<bool>(
                              valueListenable: isBoxChecked,
                              builder: (context, isEnabled, _) {
                                final boxes = buildBoxes(isEnabled);

                                return Column(
                                  children:
                                      boxes.map((row) {
                                        return buildFieldRow(
                                          children: [
                                            row['left'] is Function ? row['left']() : row['left'],
                                            row['middle_1'] is Function
                                                ? row['middle_1']()
                                                : row['middle_1'],
                                            row['middle_2'] is Function
                                                ? row['middle_2']()
                                                : row['middle_2'],
                                            row['middle_3'] is Function
                                                ? row['middle_3']()
                                                : row['middle_3'],
                                            row['right'] is Function
                                                ? row['right']()
                                                : row['right'],
                                          ],
                                        );
                                      }).toList(),
                                );
                              },
                            ),

                            const SizedBox(height: 16),
                            const Text(
                              'Hướng dẫn đặc biệt:',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            const SizedBox(height: 10),

                            TextFormField(
                              controller: instructSpecialController,
                              decoration: InputDecoration(
                                hintText: 'Nhập ghi chú tại đây...',
                                fillColor: Colors.white,
                                filled: true,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(color: Colors.grey),
                                ),
                              ),
                              maxLines: 3,
                            ),
                          ],
                        ),
                      ],
                    ),
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
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.black54),
              ),
            ),
            ElevatedButton(
              onPressed: submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Text(
                isEdit ? "Cập nhật" : "Thêm",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
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
