import 'dart:async';
import 'package:dongtam/data/models/customer/customer_model.dart';
import 'package:dongtam/data/models/order/box_model.dart';
import 'package:dongtam/data/models/order/order_model.dart';
import 'package:dongtam/data/models/product/product_model.dart';
import 'package:dongtam/presentation/components/dialog/dialog_add_customer.dart';
import 'package:dongtam/presentation/components/dialog/dialog_add_product.dart';
import 'package:dongtam/service/customer_Service.dart';
import 'package:dongtam/service/order_Service.dart';
import 'package:dongtam/service/product_Service.dart';
import 'package:dongtam/utils/helper/auto_complete_field.dart';
import 'package:dongtam/utils/showSnackBar/show_snack_bar.dart';
import 'package:dongtam/utils/validation/validation_order.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

class OrderDialog extends StatefulWidget {
  final Order? order;
  final VoidCallback onOrderAddOrUpdate;

  const OrderDialog({super.key, this.order, required this.onOrderAddOrUpdate});

  @override
  State<OrderDialog> createState() => _OrderDialogState();
}

class _OrderDialogState extends State<OrderDialog> {
  final formKey = GlobalKey<FormState>();
  Timer? _customerIdDebounce;
  Timer? _productIdDebounce;
  String lastSearchedCustomerId = "";
  String lastSearchedProductId = "";
  final List<String> itemsDvt = ['Kg', 'Cái', 'M2'];
  final List<String> itemsDaoXa = [
    "Tề Gọn",
    "Tề Biên Đẹp",
    "Tề Biên Cột",
    "Quấn Cuồn",
  ];
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
  final discountController = TextEditingController();
  final profitController = TextEditingController();
  final vatController = TextEditingController();
  final instructSpecialController = TextEditingController();
  final dvtController = TextEditingController();
  final daoXaController = TextEditingController();
  late String typeDVT = "Kg";
  late String typeDaoXa = "Tề Gọn";
  final dateShippingController = TextEditingController();
  DateTime? dateShipping;
  DateTime? dayReceive = DateTime.now();
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

    // debounce
    customerIdController.addListener(_onCustomerIdChanged);
    productIdController.addListener(_onProductIdChanged);
  }

  void orderInitState() {
    originalOrderId = widget.order!.orderId;
    orderIdController.text = widget.order!.orderId;
    customerIdController.text = widget.order!.customerId;
    productIdController.text = widget.order!.productId;
    qcBoxController.text = widget.order!.QC_box.toString();
    canLanController.text = widget.order!.canLan.toString();
    dayController.text = widget.order!.day.toString();
    matEController.text = widget.order!.matE.toString();
    matBController.text = widget.order!.matB.toString();
    matCController.text = widget.order!.matC.toString();
    songEController.text = widget.order!.songE.toString();
    songBController.text = widget.order!.songB.toString();
    songCController.text = widget.order!.songC.toString();
    songE2Controller.text = widget.order!.songE2.toString();
    lengthCustomerController.text = widget.order!.lengthPaperCustomer
        .toStringAsFixed(1);
    lengthManufactureController.text = widget.order!.lengthPaperManufacture
        .toStringAsFixed(1);
    sizeCustomerController.text = widget.order!.paperSizeCustomer
        .toStringAsFixed(1);
    sizeManufactureController.text = widget.order!.paperSizeManufacture
        .toStringAsFixed(1);
    quantityCustomerController.text = widget.order!.quantityCustomer.toString();
    quantityManufactureController.text =
        widget.order!.quantityManufacture.toString();
    numberChildController.text = widget.order!.numberChild.toString();
    priceController.text = widget.order!.price.toString();
    discountController.text =
        widget.order!.discount?.toStringAsFixed(1) ?? '0.0';
    profitController.text = widget.order!.profit.toStringAsFixed(1);
    vatController.text = widget.order!.vat.toString();
    instructSpecialController.text = widget.order!.instructSpecial.toString();

    isBoxChecked = ValueNotifier<bool>(widget.order!.isBox);

    //dropdown
    typeDVT = widget.order!.dvt;
    typeDaoXa = widget.order!.daoXa;

    //date
    dayReceive = widget.order!.dayReceiveOrder;
    dateShipping = widget.order!.dateRequestShipping;
    dateShippingController.text = DateFormat(
      'dd/MM/yyyy',
    ).format(dateShipping!);
  }

  void boxInitState() {
    final box = widget.order!.box;
    if (box == null) return;

    inMatTruocController.text = box.inMatTruoc?.toString() ?? '';
    inMatSauController.text = box.inMatSau?.toString() ?? '';
    canMangChecked = ValueNotifier<bool>(box.canMang ?? false);
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

  Future<void> getCustomerById(String customerId) async {
    try {
      final customers = await CustomerService().getCustomerById(customerId);

      if (customerId != lastSearchedCustomerId) return;

      if (customers.isNotEmpty) {
        final customer = customers.first;
        if (mounted) {
          setState(() {
            customerNameController.text = customer.customerName;
            customerCompanyController.text = customer.companyName;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            customerNameController.clear();
            customerCompanyController.clear();
          });

          showSnackBarError(context, 'Không tìm thấy khách hàng');
        }
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  Future<void> getProductById(String productId) async {
    try {
      final products = await ProductService().getProductById(productId);

      if (productId != lastSearchedProductId) return;

      if (products.isNotEmpty) {
        final product = products.first;
        if (mounted) {
          setState(() {
            typeProduct.text = product.typeProduct;
            nameSpController.text = product.productName ?? "";
            maKhuonController.text = product.maKhuon ?? "";
          });
        }
      } else {
        if (mounted) {
          setState(() {
            nameSpController.clear();
            typeProduct.clear();
            maKhuonController.clear();
          });

          showSnackBarError(context, "Không tìm thấy sản phẩm");
        }
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  // debounce customer
  void _onCustomerIdChanged() {
    if (_customerIdDebounce?.isActive ?? false) _customerIdDebounce!.cancel();

    final input = customerIdController.text.trim();

    _customerIdDebounce = Timer(Duration(milliseconds: 800), () {
      if (input.isNotEmpty) {
        lastSearchedCustomerId = input;
        getCustomerById(input);
      }
    });
  }

  // debounce product
  void _onProductIdChanged() {
    if (_productIdDebounce?.isActive ?? false) _productIdDebounce!.cancel();

    final input = productIdController.text.trim();

    _productIdDebounce = Timer(Duration(milliseconds: 800), () {
      if (input.isNotEmpty) {
        lastSearchedProductId = input;
        getProductById(input);
      }
    });
  }

  Future<void> fetchAllCustomers() async {
    try {
      allCustomers = await CustomerService().getAllCustomers(false);
    } catch (e) {
      print("Lỗi lấy danh sách khách hàng: $e");
    }
  }

  Future<void> fetchAllProduct() async {
    try {
      allProducts = await ProductService().getAllProducts(false);
    } catch (e) {
      print("Lỗi lấy danh sách khách hàng: $e");
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
    listenerForFieldNeed(
      quantityCustomerController,
      quantityManufactureController,
    );
  }

  String generateOrderCode(String prefix) {
    final now = DateTime.now();
    final String month = now.month.toString().padLeft(2, '0');
    final String year = now.year.toString().substring(2);
    return "$prefix/$month/$year/D";
  }

  void submit() async {
    if (!formKey.currentState!.validate()) return;
    final prefix = orderIdController.text.toUpperCase();

    double totalAcreage =
        Order.acreagePaper(
          double.tryParse(lengthCustomerController.text) ?? 0.0,
          double.tryParse(sizeCustomerController.text) ?? 0.0,
          int.tryParse(quantityCustomerController.text) ?? 0,
        ).roundToDouble();

    late double totalPricePaper =
        Order.totalPricePaper(
          typeDVT,
          double.tryParse(lengthCustomerController.text) ?? 0.0,
          double.tryParse(sizeCustomerController.text) ?? 0.0,
          double.tryParse(priceController.text) ?? 0.0,
        ).roundToDouble();

    late double totalPriceOrder =
        Order.totalPriceOrder(
          int.tryParse(quantityCustomerController.text) ?? 0,
          totalPricePaper,
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
      songE2Value = addPrefixIfNeeded(songE2Controller.text, 'E2');
    } else {
      // update mode
      songEValue = addPrefixIfNeeded(songEController.text, 'E');
      songBValue = addPrefixIfNeeded(songBController.text, 'B');
      songCValue = addPrefixIfNeeded(songCController.text, 'C');
      songE2Value = addPrefixIfNeeded(songE2Controller.text, 'E2');
    }

    // flute
    late String flutePaper = Order.flutePaper(
      dayController.text,
      matEController.text,
      matBController.text,
      matCController.text,
      songEValue,
      songBValue,
      songCValue,
      songE2Value,
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
      songE: songEValue,
      songB: songBValue,
      songC: songCValue,
      songE2: songE2Value,
      lengthPaperCustomer:
          double.tryParse(lengthCustomerController.text) ?? 0.0,
      lengthPaperManufacture:
          double.tryParse(lengthManufactureController.text) ?? 0.0,
      paperSizeCustomer: double.tryParse(sizeCustomerController.text) ?? 0.0,
      paperSizeManufacture:
          double.tryParse(sizeManufactureController.text) ?? 0.0,
      quantityCustomer: int.tryParse(quantityCustomerController.text) ?? 0,
      quantityManufacture:
          int.tryParse(quantityManufactureController.text) ?? 0,
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
      box: newBox,
      status: 'pending',
    );

    try {
      if (widget.order == null) {
        await OrderService().addOrders(newOrder.toJson());
        showSnackBarSuccess(context, "Lưu thành công");
      } else {
        await OrderService().updateOrderById(
          originalOrderId,
          newOrder.toJson(),
        );
        showSnackBarSuccess(context, 'Cập nhật thành công');
      }

      widget.onOrderAddOrUpdate();
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
    discountController.dispose();
    profitController.dispose();
    inMatTruocController.dispose();
    inMatSauController.dispose();
    canMangChecked = ValueNotifier<bool>(false);
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
    customerIdController.removeListener(_onCustomerIdChanged);
    productIdController.removeListener(_onProductIdChanged);
    _customerIdDebounce?.cancel();
    _productIdDebounce?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.order != null;

    final List<Map<String, dynamic>> orders = [
      {
        'left':
            () => ValidationOrder.validateInput(
              "Mã Đơn Hàng",
              orderIdController,
              Symbols.orders,
              readOnly: isEdit,
              checkId: !isEdit,
            ),
        'middle_1':
            () => AutoCompleteField<Customer>(
              controller: customerIdController,
              labelText: "Mã Khách Hàng",
              icon: Symbols.badge,
              suggestionsCallback:
                  (pattern) => CustomerService().getCustomerById(pattern),
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

        'middle_2':
            () => ValidationOrder.validateInput(
              "Tên KH",
              customerNameController,
              Symbols.person,
              readOnly: true,
            ),
        'middle_3':
            () => ValidationOrder.validateInput(
              "Tên công ty KH",
              customerCompanyController,
              Symbols.business,
              readOnly: true,
            ),
        'right':
            () => ValidationOrder.validateInput(
              "Ngày yêu cầu giao",
              dateShippingController,
              Symbols.calendar_month,
              readOnly: true,
              onTap: () async {
                DateTime baseDate = dayReceive ?? DateTime.now();
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: dateShipping ?? dayReceive,
                  firstDate: baseDate,
                  lastDate: DateTime(2100),
                );
                if (pickedDate != null) {
                  setState(() {
                    dateShipping = pickedDate;
                    dateShippingController.text = DateFormat(
                      'dd/MM/yyyy',
                    ).format(pickedDate);
                  });
                }
              },
            ),
      },

      {
        'left':
            () => AutoCompleteField<Product>(
              controller: productIdController,
              labelText: "Mã Sản Phẩm",
              icon: Symbols.box,
              suggestionsCallback:
                  (pattern) => ProductService().getProductById(pattern),
              displayStringForItem: (product) => product.productId,
              itemBuilder: (context, product) {
                return ListTile(
                  title: Text(product.productId),
                  subtitle: Text(product.productId),
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
        'middle_1':
            () => ValidationOrder.validateInput(
              "Loại sản phẩm",
              typeProduct,
              Symbols.comment,
              readOnly: true,
            ),
        'middle_2':
            () => ValidationOrder.validateInput(
              "Tên sản phẩm",
              nameSpController,
              Symbols.box,
              readOnly: true,
            ),
        'middle_3':
            () => ValidationOrder.validateInput(
              "Số lượng (KH)",
              quantityCustomerController,
              Symbols.filter_9_plus,
            ),
        'right':
            () => ValidationOrder.validateInput(
              "Số lượng (SX)",
              quantityManufactureController,
              Symbols.filter_9_plus,
            ),
      },

      {
        'left':
            () => ValidationOrder.validateInput(
              "QC Thùng",
              qcBoxController,
              Symbols.deployed_code,
            ),
        'middle_1':
            () => ValidationOrder.validateInput(
              "Dài khách đặt (cm)",
              lengthCustomerController,
              Symbols.vertical_distribute,
            ),
        'middle_2':
            () => ValidationOrder.validateInput(
              "Dài sản xuất (cm)",
              lengthManufactureController,
              Symbols.vertical_distribute,
            ),
        'middle_3':
            () => ValidationOrder.validateInput(
              "Khổ khách đặt (cm)",
              sizeCustomerController,
              Symbols.horizontal_distribute,
            ),
        'right':
            () => ValidationOrder.validateInput(
              "Khổ sản xuất (cm)",
              sizeManufactureController,
              Symbols.horizontal_distribute,
            ),
      },

      {
        'left':
            () => ValidationOrder.validateInput(
              "Đơn giá",
              priceController,
              Symbols.price_change,
            ),
        'middle_1':
            () => ValidationOrder.validateInput(
              "Chiết khấu",
              discountController,
              Symbols.price_change,
            ),
        'middle_2':
            () => ValidationOrder.validateInput(
              "Lợi nhuận",
              profitController,
              Symbols.price_change,
            ),
        'middle_3':
            () => ValidationOrder.validateInput(
              "VAT",
              vatController,
              Symbols.percent,
            ),

        'right':
            () => ValidationOrder.dropdownForTypes(itemsDvt, typeDVT, (value) {
              setState(() {
                typeDVT = value!;
              });
            }),
      },
    ];

    final List<Map<String, dynamic>> structure = [
      {
        'left':
            () => ValidationOrder.validateInput(
              "Đáy (g)",
              dayController,
              Symbols.vertical_align_bottom,
            ),
        'middle_1':
            () => ValidationOrder.validateInput(
              "Mặt E (g)",
              matEController,
              Symbols.vertical_align_center,
            ),
        'middle_2':
            () => ValidationOrder.validateInput(
              "Mặt B (g)",
              matBController,
              Symbols.vertical_align_center,
            ),
        'middle_3':
            () => ValidationOrder.validateInput(
              "Mặt C (g)",
              matCController,
              Symbols.vertical_align_top,
            ),
        'right':
            () => ValidationOrder.validateInput(
              "Cấn Lằn",
              canLanController,
              Symbols.bottom_sheets,
            ),
      },

      {
        'left':
            () => ValidationOrder.validateInput(
              "Sóng E (g)",
              songEController,
              Symbols.airwave,
            ),
        'middle_1':
            () => ValidationOrder.validateInput(
              "Sóng B (g)",
              songBController,
              Symbols.airwave,
            ),
        'middle_2':
            () => ValidationOrder.validateInput(
              "Sóng C (g)",
              songCController,
              Symbols.airwave,
            ),
        'middle_3':
            () => ValidationOrder.validateInput(
              "Sóng E2 (g)",
              songE2Controller,
              Symbols.airwave,
            ),
        'right':
            () => ValidationOrder.dropdownForTypes(itemsDaoXa, typeDaoXa, (
              value,
            ) {
              setState(() {
                typeDaoXa = value!;
              });
            }),
      },
    ];

    List<Map<String, dynamic>> buildBoxes(bool isEnabled) {
      return [
        {
          'left':
              () => ValidationOrder.validateInput(
                "Số màu in mặt trước",
                inMatTruocController,
                Symbols.print,
                enabled: isEnabled,
              ),
          'middle_1':
              () => ValidationOrder.validateInput(
                "Số màu in mặt sau",
                inMatSauController,
                Symbols.print,
                enabled: isEnabled,
              ),
          'middle_2':
              () => ValidationOrder.validateInput(
                "Cách Đóng gói",
                dongGoiController,
                Symbols.box,
                enabled: isEnabled,
              ),
          'middle_3':
              () => ValidationOrder.validateInput(
                "Mã Khuôn",
                maKhuonController,
                Symbols.box,
                readOnly: true,
                enabled: isEnabled,
              ),
          'right':
              () => ValidationOrder.validateInput(
                "Số con",
                numberChildController,
                Symbols.box,
              ),
        },
        {
          'left':
              () => ValidationOrder.checkboxForBox(
                "Chống thấm",
                chongThamChecked,
                enabled: isEnabled,
              ),
          'middle_1':
              () => ValidationOrder.checkboxForBox(
                "Xả",
                xaChecked,
                enabled: isEnabled,
              ),
          'middle_2':
              () => ValidationOrder.checkboxForBox(
                "Cắt khe",
                catKheChecked,
                enabled: isEnabled,
              ),
          'middle_3':
              () => ValidationOrder.checkboxForBox(
                "Dán 1 mảnh",
                dan1ManhChecked,
                enabled: isEnabled,
              ),
          'right':
              () => ValidationOrder.checkboxForBox(
                "Dán 2 mảnh",
                dan2ManhChecked,
                enabled: isEnabled,
              ),
        },
        {
          'left':
              () => ValidationOrder.checkboxForBox(
                "Cán màng",
                canMangChecked,
                enabled: isEnabled,
              ),
          'middle_1':
              () => ValidationOrder.checkboxForBox(
                "Bế",
                beChecked,
                enabled: isEnabled,
              ),
          'middle_2':
              () => ValidationOrder.checkboxForBox(
                "Đóng ghim 1 mảnh",
                dongGhim1ManhChecked,
                enabled: isEnabled,
              ),
          'middle_3':
              () => ValidationOrder.checkboxForBox(
                "Đóng ghim 2 mảnh",
                dongGhim2ManhChecked,
                enabled: isEnabled,
              ),
          'right':
              () => ValidationOrder.checkboxForBox(
                "Làm thùng?",
                isBoxChecked,
              ), // checkbox chính luôn bật
        },
      ];
    }

    return StatefulBuilder(
      builder: (context, state) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
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
                                          row['middle_3'] is Function
                                              ? row['middle_3']()
                                              : row['middle_3'],
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
                    const SizedBox(height: 20),

                    //structure
                    const Text(
                      "Kết Cấu",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      decoration: BoxDecoration(
                        color: Color(0xffF2E873),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: EdgeInsets.all(15),
                      child: Column(
                        children:
                            structure.map((row) {
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
                                          row['middle_3'] is Function
                                              ? row['middle_3']()
                                              : row['middle_3'],
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
                    const SizedBox(height: 20),

                    //box
                    const Text(
                      "Làm Thùng",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      decoration: BoxDecoration(
                        color: Color(0xffF2E873),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: EdgeInsets.all(15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ValueListenableBuilder<bool>(
                            valueListenable: isBoxChecked,
                            builder: (context, isEnabled, _) {
                              final boxes = buildBoxes(isEnabled);
                              return Column(
                                children:
                                    boxes.map((row) {
                                      return Padding(
                                        padding: const EdgeInsets.only(
                                          bottom: 15,
                                        ),
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
                                                  row['middle_3'] is Function
                                                      ? row['middle_3']()
                                                      : row['middle_3'],
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
                              );
                            },
                          ),

                          const Text(
                            'Hướng dẫn đặc biệt:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
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
                                borderSide: BorderSide(color: Colors.grey),
                              ),
                            ),
                            maxLines: 3,
                          ),
                        ],
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
