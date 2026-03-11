import 'dart:async';
import 'dart:typed_data';
import 'package:dongtam/data/controller/badges_controller.dart';
import 'package:dongtam/data/controller/upload_process_controller.dart';
import 'package:dongtam/data/models/customer/customer_model.dart';
import 'package:dongtam/data/models/order/box_model.dart';
import 'package:dongtam/data/models/order/order_model.dart';
import 'package:dongtam/data/models/product/product_model.dart';
import 'package:dongtam/presentation/components/dialog/add/dialog_add_customer.dart';
import 'package:dongtam/presentation/components/dialog/add/dialog_add_product.dart';
import 'package:dongtam/presentation/components/shared/confirm_dialog.dart';
import 'package:dongtam/service/config/upload_cloudinary_service.dart';
import 'package:dongtam/service/customer_service.dart';
import 'package:dongtam/service/order_service.dart';
import 'package:dongtam/service/product_service.dart';
import 'package:dongtam/utils/extension/extension_helper.dart';
import 'package:dongtam/utils/handleError/api_exception.dart';
import 'package:dongtam/utils/helper/auto_complete_field.dart';
import 'package:dongtam/presentation/components/shared/cardForm/building_card_form.dart';
import 'package:dongtam/presentation/components/shared/cardForm/format_key_value_card.dart';
import 'package:dongtam/utils/helper/reponsive/reponsive_dialog.dart';
import 'package:dongtam/utils/logger/app_logger.dart';
import 'package:dongtam/utils/handleError/show_snack_bar.dart';
import 'package:dongtam/utils/validation/validation_order.dart';
import 'package:file_picker/file_picker.dart';
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

  double uploadProgress = 0.0;
  bool isUploading = false;

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
  final orderIdCustomerController = TextEditingController();

  final dvtController = TextEditingController();
  final daoXaController = TextEditingController();
  late String typeDVT = "Tấm";
  late String typeDaoXa = "Tề Gọn";

  final dateShippingController = TextEditingController(); //ngày giao
  DateTime? dateShipping; //ngày giao
  DateTime? dayReceive = DateTime.now(); //ngày nhận

  final customerIdController = TextEditingController();
  final nameSpController = TextEditingController();
  final typeProduct = TextEditingController();

  final productIdController = TextEditingController();
  final customerNameController = TextEditingController();
  final customerCompanyController = TextEditingController();

  Uint8List? pickedOrderImage;
  String? orderImageUrl;

  //box
  ValueNotifier<bool> isBoxChecked = ValueNotifier<bool>(false);

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
    }

    fetchAllCustomers();
    fetchAllProduct();
    addListenerForField();

    vatController.text = "8";
  }

  //init data to update
  void orderInitState() {
    final order = widget.order!;

    originalOrderId = order.orderId;
    _fillFormWithOrder(order);
  }

  //fetch all customer for create in dialog
  Future<void> fetchAllCustomers() async {
    try {
      final result = await CustomerService().getCustomers(noPaging: true);

      allCustomers = result['customers'] as List<Customer>;
      AppLogger.i("Fetch thành công tất cả khách hàng vào order");
    } catch (e, s) {
      AppLogger.e("Lỗi khi tải danh sách khách hàng", error: e, stackTrace: s);
    }
  }

  //fetch all product for create in dialog
  Future<void> fetchAllProduct() async {
    try {
      final result = await ProductService().getProducts(noPaging: true);

      allProducts = result['products'] as List<Product>;
      AppLogger.i("Fetch thành công tất cả sản phẩm vào order");
    } catch (e, s) {
      AppLogger.e("Lỗi khi tải danh sách sản phẩm", error: e, stackTrace: s);
    }
  }

  void _fillFormWithOrder(Order selectedOrder) {
    // 1. Group các String/Number fields (Dùng Map để duyệt cho nhanh hoặc gán thẳng 1 cụm)
    orderIdController.text = selectedOrder.orderId;
    customerIdController.text = selectedOrder.customerId;
    productIdController.text = selectedOrder.productId;
    qcBoxController.text = selectedOrder.QC_box ?? "";
    canLanController.text = selectedOrder.canLan ?? "";
    orderIdCustomerController.text = selectedOrder.orderIdCustomer ?? "";

    // Cụm các field Sóng/Mặt
    dayController.text = selectedOrder.day ?? "";
    matEController.text = selectedOrder.matE ?? "";
    matBController.text = selectedOrder.matB ?? "";
    matCController.text = selectedOrder.matC ?? "";
    matE2Controller.text = selectedOrder.matE2 ?? "";
    songEController.text = selectedOrder.songE ?? "";
    songBController.text = selectedOrder.songB ?? "";
    songCController.text = selectedOrder.songC ?? "";
    songE2Controller.text = selectedOrder.songE2 ?? "";

    // Cụm các field Số (Chuyển toString một loạt)
    lengthCustomerController.text = selectedOrder.lengthPaperCustomer.toString();
    lengthManufactureController.text = selectedOrder.lengthPaperManufacture.toString();
    sizeCustomerController.text = selectedOrder.paperSizeCustomer.toString();
    sizeManufactureController.text = selectedOrder.paperSizeManufacture.toString();
    quantityCustomerController.text = selectedOrder.quantityCustomer.toString();
    quantityManufactureController.text = selectedOrder.quantityManufacture.toString();
    numberChildController.text = selectedOrder.numberChild.toString();

    // Định dạng số tiền
    priceController.text = selectedOrder.price.toStringAsFixed(2);
    pricePaperController.text = selectedOrder.pricePaper?.toStringAsFixed(2) ?? "0.00";
    discountController.text = selectedOrder.discount?.toStringAsFixed(1) ?? "0.0";
    profitController.text = selectedOrder.profit.toStringAsFixed(1);
    vatController.text = selectedOrder.vat.toString();

    // Dropdown & Date
    setState(() {
      typeDVT = selectedOrder.dvt;
      typeDaoXa = selectedOrder.daoXa;
    });

    instructSpecialController.text = selectedOrder.instructSpecial ?? "";

    if (selectedOrder.dateRequestShipping != null) {
      dateShipping = selectedOrder.dateRequestShipping;
      dateShippingController.text = DateFormat('dd/MM/yyyy').format(dateShipping!);
    }

    //image
    orderImageUrl = selectedOrder.orderImage?.imageUrl;
    if (orderImageUrl != null && orderImageUrl!.isEmpty) {
      orderImageUrl = null;
    }

    // 2. Cập nhật Box Fields (Chỉ cập nhật .value, không khởi tạo lại Notifier)
    isBoxChecked.value = selectedOrder.isBox;
    final box = selectedOrder.box;

    inMatTruocController.text = box?.inMatTruoc?.toString() ?? "";
    inMatSauController.text = box?.inMatSau?.toString() ?? "";
    dongGoiController.text = box?.dongGoi ?? "";
    maKhuonController.text = box?.maKhuon ?? "";

    // Cập nhật cụm Checkbox
    canMangChecked.value = box?.canMang ?? false;
    xaChecked.value = box?.Xa ?? false;
    catKheChecked.value = box?.catKhe ?? false;
    canLanChecked.value = box?.canLan ?? false;
    beChecked.value = box?.be ?? false;
    dan1ManhChecked.value = box?.dan_1_Manh ?? false;
    dan2ManhChecked.value = box?.dan_2_Manh ?? false;
    chongThamChecked.value = box?.chongTham ?? false;
    dongGhim1ManhChecked.value = box?.dongGhim1Manh ?? false;
    dongGhim2ManhChecked.value = box?.dongGhim2Manh ?? false;
  }

  void addListenerForField() {
    Order.listenerForFieldNeed(lengthCustomerController, lengthManufactureController);
    Order.listenerForFieldNeed(sizeCustomerController, sizeManufactureController);
    Order.listenerForFieldNeed(quantityCustomerController, quantityManufactureController);
  }

  Future<void> pickImage() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image, withData: true);
    if (result != null && result.files.single.bytes != null) {
      setState(() {
        pickedOrderImage = result.files.single.bytes;
      });
    } else {
      AppLogger.d("Không chọn ảnh nào");
    }
  }

  void submit() async {
    //bắt validate form
    if (!formKey.currentState!.validate()) {
      AppLogger.w("Form không hợp lệ, dừng submit");
      return;
    }

    // showLoadingDialog(context);
    // await Future.delayed(const Duration(seconds: 1));

    // if (!mounted) return;
    // Navigator.pop(context); // đóng dialog loading

    try {
      final prefix = orderIdController.text.toUpperCase();

      // determine wave fields
      final String songEValue = Order.addPrefixIfNeeded(songEController.text, 'E');
      final String songBValue = Order.addPrefixIfNeeded(songBController.text, 'B');
      final String songCValue = Order.addPrefixIfNeeded(songCController.text, 'C');
      final String songE2Value = Order.addPrefixIfNeeded(songE2Controller.text, 'E');

      final newBox = Box(
        inMatTruoc: int.tryParse(inMatTruocController.trimmed) ?? 0,
        inMatSau: int.tryParse(inMatSauController.trimmed) ?? 0,
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
        dongGoi: dongGoiController.superClean,
        maKhuon: maKhuonController.trimmed,
      );

      final newOrder = Order(
        orderId: Order.generateOrderCode(prefix),
        orderIdCustomer: orderIdCustomerController.trimmed.toUpperCase(),
        customerId: customerIdController.trimmed.toUpperCase(),
        productId: productIdController.trimmed.toUpperCase(),

        dayReceiveOrder: dayReceive ?? DateTime.now(),
        QC_box: qcBoxController.trimmed.toLowerCase(),
        canLan: canLanController.trimmed,
        daoXa: typeDaoXa,

        day: dayController.trimmed.toUpperCase(),
        matE: matEController.trimmed.toUpperCase(),
        matB: matBController.trimmed.toUpperCase(),
        matC: matCController.trimmed.toUpperCase(),
        matE2: matE2Controller.trimmed.toUpperCase(),
        songE: songEValue,
        songB: songBValue,
        songC: songCValue,
        songE2: songE2Value,

        lengthPaperCustomer: double.tryParse(lengthCustomerController.trimmed) ?? 0.0,
        lengthPaperManufacture: double.tryParse(lengthManufactureController.trimmed) ?? 0.0,
        paperSizeCustomer: double.tryParse(sizeCustomerController.trimmed) ?? 0.0,
        paperSizeManufacture: double.tryParse(sizeManufactureController.trimmed) ?? 0.0,
        quantityCustomer: int.tryParse(quantityCustomerController.trimmed) ?? 0,
        quantityManufacture: int.tryParse(quantityManufactureController.trimmed) ?? 0,

        numberChild: int.tryParse(numberChildController.trimmed) ?? 0,
        dvt: typeDVT,

        price: double.tryParse(priceController.trimmed) ?? 0.0,
        pricePaper: double.tryParse(pricePaperController.trimmed) ?? 0.0,
        discount: double.tryParse(discountController.trimmed) ?? 0.0,
        profit: double.tryParse(profitController.trimmed) ?? 0.0,

        dateRequestShipping: dateShipping ?? DateTime.now(),
        vat: int.tryParse(vatController.trimmed) ?? 0,
        instructSpecial: instructSpecialController.trimmed,

        isBox: isBoxChecked.value,
        box: newBox,
        status: 'pending',
      );

      final bool isAdd = widget.order == null;
      final imageBytes = pickedOrderImage;
      final callback = widget.onOrderAddOrUpdate;

      final bool success = await _startBackgroundUpload(newOrder, imageBytes, isAdd, callback);

      if (success) {
        if (!mounted) return;
        Navigator.of(context).pop(); // Đóng Form nhập đơn
      }
    } catch (e, s) {
      if (!mounted) return;
      Navigator.pop(context); // đóng dialog loading

      AppLogger.e(
        widget.order == null ? "Lỗi khi thêm đơn hàng" : "Lỗi khi sửa đơn hàng",
        error: e,
        stackTrace: s,
      );

      showSnackBarError(context, 'Lỗi: Không thể lưu dữ liệu');
    }
  }

  Future<bool> _startBackgroundUpload(
    Order order,
    Uint8List? imageBytes,
    bool isAdd,
    void Function(String)? callback,
  ) async {
    final uploadCtrl = Get.find<UploadProcessController>();

    try {
      uploadCtrl.isUploading.value = true;

      //khởi tạo dữ liệu (15%)
      uploadCtrl.updateProgress(0.15, "Đang xử lý...");

      String? finalImageUrl;
      String? finalPublicId;

      //upload ảnh (15% -> 80%)
      if (imageBytes != null) {
        final uploadResult = await UploadCloudinaryService().uploadToCloudinary(
          imageBytes: imageBytes,
          onProgress: (p) {
            double totalProgress = 0.15 + (p * 0.65);
            uploadCtrl.updateProgress(totalProgress, "Đang tải ảnh...");
          },
        );
        finalImageUrl = uploadResult?['imageUrl'];
        finalPublicId = uploadResult?['publicId'];
      } else {
        uploadCtrl.updateProgress(0.8, "Bỏ qua tải ảnh...");
      }

      // Lưu dữ liệu (80% -> 85%)
      uploadCtrl.updateProgress(0.85, "Đang lưu đơn hàng vào hệ thống...");

      AppLogger.i(
        isAdd ? "Thêm đơn hàng mới: ${order.orderId}" : "Cập nhật đơn hàng: ${order.orderId}",
      );

      final orderJson = order.toJson();
      orderJson['imageData'] = {'imageUrl': finalImageUrl, 'publicId': finalPublicId};

      String? orderId;
      if (isAdd) {
        final response = await OrderService().addOrders(orderData: orderJson);
        orderId = response['orderId'];
      } else {
        await OrderService().updateOrder(orderId: originalOrderId, orderUpdated: orderJson);
      }

      // Hoàn thành (85% -> 100%)
      uploadCtrl.updateProgress(1.0, "Đã lưu xong!");
      await Future.delayed(const Duration(milliseconds: 800));

      uploadCtrl.complete(isAdd ? "Tạo đơn hàng thành công" : "Cập nhật đơn hàng thành công");

      // Fetch badge
      badgesController.fetchPendingApprovals();
      if (badgesController.numberOrderReject > 0) badgesController.fetchOrderReject();

      callback?.call(orderId ?? order.orderId);

      return true;
    } on ApiException catch (e) {
      uploadCtrl.updateProgress(0.7, "Có lỗi xảy ra");
      await Future.delayed(const Duration(milliseconds: 1500));

      setState(() {
        switch (e.errorCode) {
          case 'PREFIX_CUSTOMER_MISMATCH':
            showSnackBarError(context, e.message!);
            break;
          default:
            showSnackBarError(context, 'Có lỗi xảy ra, vui lòng thử lại');
        }
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        formKey.currentState!.validate();
      });

      uploadCtrl.isUploading.value = false;
      return false;
    } catch (e, s) {
      AppLogger.e("Lỗi lưu dữ liệu ngầm", error: e, stackTrace: s);
      uploadCtrl.handleError("Không thể lưu dữ liệu đơn hàng");
      return false;
    }
  }

  @override
  void dispose() {
    super.dispose();
    orderIdController.dispose();
    orderIdCustomerController.dispose();
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
        "leftValue": AutoCompleteField<Order>(
          controller: orderIdController,
          labelText: "Mã Đơn Hàng",
          icon: Symbols.orders,
          readOnly: isEdit,
          checkId: !isEdit,
          suggestionsCallback: (pattern) async {
            if (pattern.trim().length < 3) return [];
            return await OrderService().getOrderIdRaw(orderId: pattern);
          },
          displayStringForItem: (order) => order.orderId,
          itemBuilder: (context, order) {
            return ListTile(
              title: Text(order.orderId),
              subtitle: Text(order.customer?.customerName ?? ""),
            );
          },
          onSelected: (order) async {
            final selectedOrder = await OrderService().getOrderDetail(orderId: order.orderId);

            if (selectedOrder == null) return;

            _fillFormWithOrder(selectedOrder);
          },
          onChanged: (value) {
            if (value.isEmpty) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                orderIdController.clear();
              });
            }
          },
        ),

        "middleKey": "QC Thùng",
        "middleValue": ValidationOrder.validateInput(
          label: "QC Thùng",
          controller: qcBoxController,
          icon: Symbols.deployed_code,
        ),
        "rightKey": "Ngày Giao",
        "rightValue": ValidationOrder.validateInput(
          label: "Ngày Yêu Cầu Giao",
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
            final result = await CustomerService().getCustomers(
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
        "rightKey": "Tên Công Ty",
        "rightValue": ValidationOrder.validateInput(
          label: "Tên Công Ty KH",
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
            final result = await ProductService().getProducts(field: 'productId', keyword: pattern);
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
        "middleKey": "Loại Sản Phẩm",
        "middleValue": ValidationOrder.validateInput(
          label: "Loại Sản Phẩm",
          controller: typeProduct,
          icon: Symbols.comment,
          readOnly: true,
        ),
        "rightKey": "Tên Sản Phẩm",
        "rightValue": ValidationOrder.validateInput(
          label: "Tên Sản Phẩm",
          controller: nameSpController,
          icon: Symbols.box,
          readOnly: true,
        ),
      },

      {
        "leftKey": "Dài Khách Đặt",
        "leftValue": ValidationOrder.validateInput(
          label: "Dài Khách Đặt (cm)",
          controller: lengthCustomerController,
          icon: Symbols.vertical_distribute,
        ),
        "middleKey": "Khổ Khách Đặt",
        "middleValue": ValidationOrder.validateInput(
          label: "Khổ Khách Đặt (cm)",
          controller: sizeCustomerController,
          icon: Symbols.horizontal_distribute,
          isCalculate: true,
        ),
        "rightKey": "Số Lượng",
        "rightValue": ValidationOrder.validateInput(
          label: "Số Lượng (KH)",
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
        "middleKey": "Số Con",
        "middleValue": ValidationOrder.validateInput(
          label: "Số Con",
          controller: numberChildController,
          icon: Symbols.box,
        ),
        "rightKey": "PO Khách",
        "rightValue": ValidationOrder.validateInput(
          label: "PO Khách",
          controller: orderIdCustomerController,
          icon: Symbols.orders,
        ),
      },
    ];

    final List<Map<String, dynamic>> costRows = [
      {
        "leftKey": "Đơn Giá",
        "leftValue": ValidationOrder.validateInput(
          label: "Đơn Giá (M2)",
          controller: priceController,
          icon: Symbols.price_change,
        ),
        "middleKey": "Chiết Khấu",
        "middleValue": ValidationOrder.validateInput(
          label: "Chiết Khấu",
          controller: discountController,
          icon: Symbols.price_change,
        ),
        "rightKey": "Lợi Nhuận",
        "rightValue": ValidationOrder.validateInput(
          label: "Lợi Nhuận",
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
    ];

    //box
    List<Map<String, dynamic>> buildBoxes(bool isEnabled) {
      return [
        {
          'left':
              () => ValidationOrder.validateInput(
                label: "Số Màu In Mặt Trước",
                controller: inMatTruocController,
                icon: Symbols.print,
                enabled: isEnabled,
              ),
          'middle_1':
              () => ValidationOrder.validateInput(
                label: "Số Màu In Mặt Sau",
                controller: inMatSauController,
                icon: Symbols.print,
                enabled: isEnabled,
              ),
          'middle_2':
              () => ValidationOrder.validateInput(
                label: "Cách Đóng Gói",
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
                label: "Chống Thấm",
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
                label: "Cắt Khe",
                notifier: catKheChecked,
                enabled: isEnabled,
              ),
          'middle_3':
              () => ValidationOrder.checkboxForBox(
                label: "Dán 1 Mảnh",
                notifier: dan1ManhChecked,
                enabled: isEnabled,
              ),
          'right':
              () => ValidationOrder.checkboxForBox(
                label: "Dán 2 Mảnh",
                notifier: dan2ManhChecked,
                enabled: isEnabled,
              ),
        },
        {
          'left':
              () => ValidationOrder.checkboxForBox(
                label: "Cán Màng",
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
                label: "Đóng Ghim 1 Mảnh",
                notifier: dongGhim1ManhChecked,
                enabled: isEnabled,
              ),

          'right':
              () => ValidationOrder.checkboxForBox(
                label: "Đóng Ghim 2 Mảnh",
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
                    const SizedBox(height: 20),

                    Center(
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ElevatedButton.icon(
                                onPressed: pickImage,
                                icon: const Icon(Icons.upload),
                                label: const Text(
                                  "Chọn ảnh đơn hàng",
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blueAccent,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                              if (pickedOrderImage != null ||
                                  (orderImageUrl != null && orderImageUrl!.isNotEmpty)) ...[
                                const SizedBox(width: 10),
                                ElevatedButton.icon(
                                  onPressed: () {
                                    setState(() {
                                      pickedOrderImage = null;
                                      orderImageUrl = null;
                                    });
                                  },
                                  icon: const Icon(Icons.delete_outline),
                                  label: const Text(
                                    "Xóa ảnh",
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.redAccent,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 15,
                                      vertical: 15,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          if (pickedOrderImage != null) ...[
                            const SizedBox(height: 15),
                            Image.memory(
                              pickedOrderImage!,
                              height: 600,
                              width: 800,
                              fit: BoxFit.contain,
                            ),
                          ] else if (orderImageUrl != null && orderImageUrl!.isNotEmpty) ...[
                            const SizedBox(height: 15),
                            Image.network(
                              orderImageUrl!,
                              height: 600,
                              width: 800,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  height: 200,
                                  width: double.infinity,
                                  alignment: Alignment.center,
                                  child: const Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.error_outline, color: Colors.red, size: 50),
                                      SizedBox(height: 10),
                                      Text(
                                        'Lỗi tải ảnh',
                                        style: TextStyle(color: Colors.red, fontSize: 16),
                                      ),
                                    ],
                                  ),
                                );
                              },
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Container(
                                  height: 200,
                                  width: double.infinity,
                                  alignment: Alignment.center,
                                  child: const CircularProgressIndicator(),
                                );
                              },
                            ),
                          ] else ...[
                            const SizedBox(height: 30),
                            const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.image_not_supported_outlined,
                                  color: Colors.grey,
                                  size: 50,
                                ),
                                SizedBox(height: 10),
                                Text(
                                  'Không có ảnh',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontStyle: FontStyle.italic,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
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
