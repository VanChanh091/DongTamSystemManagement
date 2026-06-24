import "package:dongtam/data/models/delivery/delivery_item_model.dart";
import "package:dongtam/data/models/order/order_model.dart";
import "package:dongtam/data/models/warehouse/outbound/outbound_history_model.dart";
import "package:dongtam/data/models/warehouse/outbound/outbound_temp_item.dart";
import "package:dongtam/presentation/components/shared/animated_button.dart";
import "package:dongtam/service/delivery_service.dart";
import "package:dongtam/service/warehouse_service.dart";
import "package:dongtam/utils/handleError/api_exception.dart";
import "package:dongtam/utils/handleError/show_snack_bar.dart";
import "package:dongtam/utils/helper/auto_complete_field.dart";
import "package:dongtam/presentation/components/shared/cardForm/building_card_form.dart";
import "package:dongtam/presentation/components/shared/cardForm/format_key_value_card.dart";
import "package:dongtam/presentation/components/shared/dialog_shared.dart";
import "package:dongtam/utils/helper/reponsive/reponsive_dialog.dart";
import "package:dongtam/utils/logger/app_logger.dart";
import "package:dongtam/utils/validation/validation_helper.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:google_fonts/google_fonts.dart";
import "package:intl/intl.dart";
import "package:material_symbols_icons/material_symbols_icons.dart";

class OutBoundDialog extends StatefulWidget {
  final OutboundHistoryModel? outbound;
  final VoidCallback onOutboundHistory;
  final List<OutboundTempItem>? initialItems;

  const OutBoundDialog({
    super.key,
    this.outbound,
    required this.onOutboundHistory,
    this.initialItems,
  });

  @override
  State<OutBoundDialog> createState() => _OutBoundDialogState();
}

class _OutBoundDialogState extends State<OutBoundDialog> {
  final formKey = GlobalKey<FormState>();

  int? editingIndex; // null = add, != null = update
  int? currentDeliveryItemId;
  String? errRemainQty;
  String lastSearchedOrderId = "";

  List<dynamic> availableDeliveries = [];
  dynamic selectedDelivery;

  final List<OutboundTempItem> tempItems = [];

  final orderIdController = TextEditingController();
  final oubDetailIdController = TextEditingController();
  final customerNameController = TextEditingController();

  final lengthManuController = TextEditingController();
  final sizeManuController = TextEditingController();
  final lengthCustController = TextEditingController();
  final sizeCustController = TextEditingController();

  final fluteController = TextEditingController();
  final qcBoxController = TextEditingController();
  final typeProductController = TextEditingController();
  final productNameController = TextEditingController();

  final quantityCustomerController = TextEditingController();
  final pricePaperController = TextEditingController();
  final dvtController = TextEditingController();

  //other fields
  final remainingQtyController = TextEditingController();
  final totalOutboundController = TextEditingController();
  final qtyOutboundController = TextEditingController();

  final dayStartController = TextEditingController();
  final orderIdDeliveryController = TextEditingController();
  final qtyRegisterController = TextEditingController();
  final vehicleNameController = TextEditingController();

  late String typeOrderId = "";
  final List<String> itemOrderId = [];

  //checkbox
  ValueNotifier<bool> isDeliveryChecked = ValueNotifier<bool>(false);
  ValueNotifier<bool> isPromotionChecked = ValueNotifier<bool>(false);
  ValueNotifier<bool> isNegativeStockAllowed = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();

    final now = DateTime.now();
    dayStartController.text =
        "${now.day.toString().padLeft(2, "0")}/"
        "${now.month.toString().padLeft(2, "0")}/"
        "${now.year}";

    if (widget.outbound != null) {
      outboundInitState();
    } else if (widget.initialItems != null) {
      tempItems.addAll(widget.initialItems!);

      // Automatically check "Xuất Giao Hàng" if any item comes from Delivery
      if (tempItems.any((item) => item.deliveryItemId != null)) {
        isDeliveryChecked.value = true;
      }
    }
  }

  Future<void> outboundInitState() async {
    final outboundUpdate = widget.outbound!;
    AppLogger.i("Khởi tạo form với outboundId=${outboundUpdate.outboundId}");

    try {
      final result = await WarehouseService().getOutboundDetail(
        outboundId: outboundUpdate.outboundId,
      );

      final items = result.map((e) => OutboundTempItem.fromDetailModel(e)).toList();

      if (!mounted) return;
      setState(() {
        tempItems
          ..clear()
          ..addAll(items);
      });
    } catch (e, s) {
      AppLogger.e("Lỗi load outbound detail", error: e, stackTrace: s);
      if (!mounted) return;
      showSnackBarError(context, "Không thể tải chi tiết phiếu xuất kho");
    }
  }

  void clearController() {
    currentDeliveryItemId = null;

    orderIdController.clear();
    oubDetailIdController.clear();
    customerNameController.clear();
    lengthManuController.clear();
    sizeManuController.clear();
    lengthCustController.clear();
    sizeCustController.clear();
    typeProductController.clear();
    productNameController.clear();
    fluteController.clear();
    qcBoxController.clear();
    dvtController.clear();
    quantityCustomerController.clear();
    pricePaperController.clear();
    qtyOutboundController.clear();
    remainingQtyController.clear();
    totalOutboundController.clear();

    //delivery
    orderIdDeliveryController.clear();
    qtyRegisterController.clear();
    vehicleNameController.clear();

    //check box
    isDeliveryChecked.value = false;
    isPromotionChecked.value = false;
    isNegativeStockAllowed.value = false;
  }

  void addToTempTable() {
    if (orderIdController.text.isEmpty) return;

    int qtyOutbound = (int.tryParse(qtyOutboundController.text) ?? 0);
    int remainQty = (int.tryParse(remainingQtyController.text) ?? 0);

    if (qtyOutbound > remainQty && !isNegativeStockAllowed.value) {
      setState(() {
        errRemainQty = "Vượt quá số lượng tồn";
      });
      return;
    }

    setState(() => errRemainQty = null);

    final itemId = isDeliveryChecked.value ? currentDeliveryItemId : null;
    final outboundDetailId = int.tryParse(oubDetailIdController.text);

    // print("qtyCustomer: ${quantityCustomerController.text}");
    // print("totalOutbound: ${totalOutboundController.text}");

    final newOutboundItem = OutboundTempItem(
      deliveryItemId: itemId,
      outboundDetailId: outboundDetailId,
      orderId: orderIdController.text,
      productName: productNameController.text,
      customerName: customerNameController.text,
      lengthManufacture: double.tryParse(lengthManuController.text) ?? 0,
      sizeManufacture: double.tryParse(sizeManuController.text) ?? 0,
      lengthCustomer: double.tryParse(lengthCustController.text) ?? 0,
      sizeCustomer: double.tryParse(sizeCustController.text) ?? 0,
      flute: fluteController.text,
      QC_box: qcBoxController.text,
      dvt: dvtController.text,
      pricePaper: double.tryParse(pricePaperController.text) ?? 0,
      quantityCustomer: int.tryParse(quantityCustomerController.text) ?? 0,
      totalOutbound: int.tryParse(totalOutboundController.text) ?? 0,
      qtyOutbound: int.tryParse(qtyOutboundController.text) ?? 0,
      qtyInventory: remainQty,
      isPromotion: isPromotionChecked.value,
    );

    setState(() {
      if (editingIndex == null) {
        tempItems.add(newOutboundItem);
      } else {
        tempItems[editingIndex!] = newOutboundItem;
        editingIndex = null;
      }

      clearController();
    });
  }

  void fillFormFromTempItem(OutboundTempItem temp) {
    isPromotionChecked.value = temp.isPromotion;
    isDeliveryChecked.value = temp.deliveryItemId != null;
    currentDeliveryItemId = temp.deliveryItemId;
    orderIdController.text = temp.orderId;
    oubDetailIdController.text = temp.outboundDetailId?.toString() ?? "";
    orderIdDeliveryController.text = temp.orderId;
    customerNameController.text = temp.customerName;

    lengthManuController.text = temp.lengthManufacture?.toString() ?? "";
    sizeManuController.text = temp.sizeManufacture?.toString() ?? "";
    lengthCustController.text = temp.lengthCustomer?.toString() ?? "";
    sizeCustController.text = temp.sizeCustomer?.toString() ?? "";

    productNameController.text = temp.productName;
    fluteController.text = temp.flute ?? "";
    qcBoxController.text = temp.QC_box ?? "";
    dvtController.text = temp.dvt;
    quantityCustomerController.text = temp.quantityCustomer.toString();
    qtyOutboundController.text = temp.qtyOutbound.toString();

    if (temp.isPromotion) {
      pricePaperController.text = "0";
    } else {
      pricePaperController.text = temp.pricePaper.toString();
    }

    remainingQtyController.text = temp.qtyInventory?.toString() ?? "0";
    totalOutboundController.text = temp.totalOutbound?.toString() ?? "0";
  }

  void submit() async {
    if (tempItems.any((item) => item.qtyOutbound <= 0)) {
      showSnackBarError(context, "Số lượng xuất kho phải lớn hơn 0");
      return;
    }

    final bool hasExceededItem = tempItems.any((item) {
      final int qtyCustomer = item.quantityCustomer;
      final int qtyOutbound = item.qtyOutbound;
      final int totalQtyOutbound = item.totalOutbound ?? 0;

      // print(
      //   "qtyCustomer=$qtyCustomer, qtyOutbound=$qtyOutbound, totalQtyOutbound=$totalQtyOutbound",
      // );

      return (totalQtyOutbound + qtyOutbound) > qtyCustomer;
    });

    if (hasExceededItem) {
      final bool confirm = await showConfirmDialog(
        context: context,
        title: "Xuất vượt số lượng đơn hàng",
        content:
            "Số lượng đang xuất lớn hơn số lượng khách đặt.\nVui lòng xác nhận để tiếp tục xuất.",
        confirmText: "Xác nhận",
      );

      if (!confirm) return;
    }

    // Show loading
    if (!mounted) return;
    showLoadingDialog(context);
    await Future.delayed(const Duration(seconds: 1));

    try {
      final bool isAdd = widget.outbound == null;

      final payload =
          tempItems.map((outbound) {
            return {
              "orderId": outbound.orderId,
              "outboundQty": outbound.qtyOutbound,
              "deliveryItemId": outbound.deliveryItemId,
              "isPromotion": outbound.isPromotion,
              if (!isAdd) "outboundDetailId": outbound.outboundDetailId,
            };
          }).toList();

      final bool success;
      if (isAdd) {
        success = await WarehouseService().createOutbound(list: payload);
      } else {
        success = await WarehouseService().updateOutbound(
          outboundId: widget.outbound!.outboundId,
          list: payload,
        );
      }

      if (success) {
        if (!mounted) return;
        Navigator.pop(context); // đóng dialog loading

        // Thông báo thành công
        if (!mounted) return;
        showSnackBarSuccess(context, isAdd ? "Thêm thành công" : "Cập nhật thành công");

        widget.onOutboundHistory();
        Navigator.of(context).pop();
      }
    } on ApiException catch (e) {
      final errorText = switch (e.errorCode) {
        "EMPTY_ORDER_LIST" => e.message!,
        "CUSTOMER_MISMATCH" => e.message!,
        "FEE_ORDER_NOT_INCLUDED" => e.message!,
        "INVENTORY_NOT_FOUND" => e.message!,
        "DELIVERY_ITEM_NOT_FOUND" => e.message!,
        _ => "Có lỗi xảy ra, vui lòng thử lại",
      };

      if (mounted) {
        Navigator.pop(context); // đóng dialog loading
        showSnackBarError(context, errorText);
      }
    } catch (e, s) {
      if (widget.outbound == null) {
        AppLogger.e("Lỗi khi thêm phiếu xuất kho", error: e, stackTrace: s);
      } else {
        AppLogger.e("Lỗi khi sửa phiếu xuất kho", error: e, stackTrace: s);
      }

      if (mounted) {
        Navigator.pop(context);
        showSnackBarError(context, "Lỗi: Không thể lưu dữ liệu");
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
    orderIdController.dispose();
    oubDetailIdController.dispose();
    customerNameController.dispose();
    lengthManuController.dispose();
    sizeManuController.dispose();
    lengthCustController.dispose();
    sizeCustController.dispose();
    fluteController.dispose();
    qcBoxController.dispose();
    typeProductController.dispose();
    productNameController.dispose();
    quantityCustomerController.dispose();
    pricePaperController.dispose();
    dvtController.dispose();
    qtyOutboundController.dispose();
    remainingQtyController.dispose();
    totalOutboundController.dispose();
    dayStartController.dispose();
    orderIdDeliveryController.dispose();
    qtyRegisterController.dispose();
    vehicleNameController.dispose();
    isDeliveryChecked = ValueNotifier<bool>(false);
    isPromotionChecked = ValueNotifier<bool>(false);
    isNegativeStockAllowed = ValueNotifier<bool>(false);
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.outbound != null;

    final List<Map<String, dynamic>> infoOrderRows = [
      {
        "leftKey": "Mã Đơn Hàng",
        "leftValue": AutoCompleteField<Order>(
          controller: orderIdController,
          labelText: "",
          icon: Symbols.orders,
          suggestionsCallback: (pattern) async {
            if (pattern.trim().length < 2) return [];
            return await WarehouseService().searchOrderIds(orderId: pattern);
          },
          displayStringForItem: (order) => order.orderId,
          itemBuilder: (context, order) {
            return ListTile(
              title: Text(
                "${order.orderId} - ${formatDimensions(order.lengthPaperManufacture, order.paperSizeManufacture)}",
              ),
              subtitle: Text(order.customer?.customerName ?? ""),
            );
          },
          onSelected: (order) async {
            orderIdController.text = order.orderId;

            final selectedOrder = await WarehouseService().getOrderInboundQty(
              orderId: order.orderId,
            );

            if (selectedOrder == null) return;

            // Điền các thông tin cơ bản
            customerNameController.text = selectedOrder.customer?.customerName ?? "";

            lengthManuController.text = selectedOrder.lengthPaperManufacture.toString();
            sizeManuController.text = selectedOrder.paperSizeManufacture.toString();
            lengthCustController.text = selectedOrder.lengthPaperCustomer.toString();
            sizeCustController.text = selectedOrder.paperSizeCustomer.toString();

            typeProductController.text = selectedOrder.product?.typeProduct ?? "";
            productNameController.text = selectedOrder.product?.productName ?? "";
            fluteController.text = selectedOrder.flute ?? "";
            qcBoxController.text = selectedOrder.QC_box ?? "";
            dvtController.text = selectedOrder.dvt;
            quantityCustomerController.text = selectedOrder.quantityCustomer.toString();
            pricePaperController.text = selectedOrder.pricePaper?.toStringAsFixed(1) ?? "";

            remainingQtyController.text = selectedOrder.remainingQty.toString();
            totalOutboundController.text = selectedOrder.totalOutbound.toString();

            //logic tính sl tồn còn lại
            int alreadyStagedQty = 0;

            for (int i = 0; i < tempItems.length; i++) {
              if (editingIndex != null && i == editingIndex) continue;

              // Nếu trùng mã đơn hàng, cộng dồn số lượng đã gán ở các dòng khác vào
              if (tempItems[i].orderId == order.orderId) {
                alreadyStagedQty += tempItems[i].qtyOutbound;
              }
            }

            // Lấy số lượng tồn kho và đã xuất gốc từ API trả về
            int apiRemainingQty = selectedOrder.remainingQty ?? 0;
            int apiTotalOutbound = selectedOrder.totalOutbound ?? 0;

            // Tính toán lại số liệu hiển thị trên ô nhập dựa trên những gì đã xếp vào phiếu
            int dynamicRemainingQty = apiRemainingQty - alreadyStagedQty;
            int dynamicTotalOutbound = apiTotalOutbound + alreadyStagedQty;

            // Đẩy số liệu đã tính toán động lên giao diện
            remainingQtyController.text = dynamicRemainingQty.toString();
            totalOutboundController.text = dynamicTotalOutbound.toString();

            setState(() {});
          },

          onChanged: (value) {
            if (value.isEmpty) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                clearController();
              });
            }
          },
        ),

        "middleKey": "",
        "middleValue": const SizedBox(),

        "rightKey": "",
        "rightValue": const SizedBox(),
      },

      {
        "leftKey": "Tên Khách Hàng",
        "leftValue": customerNameController.text,

        "middleKey": "Loại sản phẩm",
        "middleValue": typeProductController.text,

        "rightKey": "Tên sản phẩm",
        "rightValue": productNameController.text,
      },

      {
        "leftKey": "Số lượng (KH)",
        "leftValue": quantityCustomerController.text,

        "middleKey": "Đơn giá (M2)",
        "middleValue": pricePaperController.text,

        "rightKey": "Đơn Vị Tính",
        "rightValue": dvtController.text,
      },

      {
        "leftKey": "Dài TT",
        "leftValue": lengthCustController.text,

        "middleKey": "Khổ TT",
        "middleValue": sizeCustController.text,

        "rightKey": "QC Thùng",
        "rightValue": qcBoxController.text,
      },

      {
        "leftKey": "Dài (SX)",
        "leftValue": lengthManuController.text,

        "middleKey": "Khổ (SX)",
        "middleValue": sizeManuController.text,

        "rightKey": "Sóng",
        "rightValue": fluteController.text,
      },
    ];

    final List<Map<String, dynamic>> infoDeliveryRows = [
      {
        "leftKey": "Mã Đơn Hàng",
        "leftValue": AutoCompleteField<DeliveryItemModel>(
          controller: orderIdDeliveryController,
          labelText: "",
          icon: Symbols.orders,
          suggestionsCallback: (pattern) async {
            if (pattern.trim().length < 2) return [];
            return await DeliveryService().searchOrderIdsByKey(orderId: pattern);
          },
          displayStringForItem: (items) => items.request!.paper!.orderId,
          itemBuilder: (context, items) {
            final formatter = DateFormat("dd/MM/yyyy");
            final order = items.request!.paper!.order!;

            final deliveryDate =
                items.DeliverySchedule?.deliveryDate != null
                    ? formatter.format(items.DeliverySchedule!.deliveryDate!)
                    : "";

            return ListTile(
              title: Text(
                "${order.orderId} - ${formatDimensions(order.lengthPaperManufacture, order.paperSizeManufacture)}",
              ),
              subtitle: Text("${order.customer?.customerName ?? ""} - $deliveryDate"),
            );
          },
          onSelected: (items) async {
            final orderId = items.request!.paper!.orderId;
            final itemId = items.deliveryItemId;

            currentDeliveryItemId = itemId;

            final selectedOrder = await DeliveryService().getDeliveryItemsById(
              deliveryItemId: itemId,
            );

            orderIdDeliveryController.text = orderId;
            qtyRegisterController.text = selectedOrder?.request?.qtyRegistered.toString() ?? "";
            vehicleNameController.text = selectedOrder?.vehicle?.vehicleName ?? "";

            setState(() {});
          },

          onChanged: (value) {
            if (value.isEmpty) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                clearController();
              });
            }
          },
        ),

        "middleKey": "Số lượng giao",
        "middleValue": qtyRegisterController.text,

        "rightKey": "Tên Xe",
        "rightValue": vehicleNameController.text,
      },
    ];

    return StatefulBuilder(
      builder: (context, state) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Center(
            child: const Text(
              "Phiếu Xuất Kho",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
          ),
          content: SizedBox(
            width: ResponsiveSize.getWidth(context, ResponsiveType.xLarge),
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// ===== FORM INPUT =====
                    buildingCard(
                      title: "Thông Tin Đơn Hàng",
                      children: formatKeyValueRows(
                        rows: infoOrderRows,
                        columnCount: 3,
                        labelWidth: 150,
                        centerAlign: true,
                      ),
                    ),

                    //outbound for delivery
                    ValueListenableBuilder<bool>(
                      valueListenable: isDeliveryChecked,
                      builder: (context, isChecked, child) {
                        if (!isChecked) return const SizedBox.shrink();

                        return Column(
                          children: [
                            const SizedBox(height: 10),
                            buildingCard(
                              title: "Mã Đơn Giao Hàng",
                              children: formatKeyValueRows(
                                rows: infoDeliveryRows,
                                columnCount: 3,
                                labelWidth: 150,
                                centerAlign: true,
                              ),
                            ),
                          ],
                        );
                      },
                    ),

                    //button
                    Align(
                      alignment: Alignment.centerRight,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.grey.shade200),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.02),
                              blurRadius: 6,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            //CHECKBOX
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                SizedBox(
                                  width: 180,
                                  child: ValidationHelper.checkboxForBox(
                                    label: "Xuất Giao Hàng",
                                    notifier: isDeliveryChecked,
                                    onChanged: (val) {
                                      if (val == false) {
                                        setState(() {
                                          currentDeliveryItemId = null;
                                          orderIdDeliveryController.clear();
                                          qtyRegisterController.clear();
                                          vehicleNameController.clear();
                                        });
                                      }
                                    },
                                  ),
                                ),
                                buildLineVertical(),

                                // Checkbox: Xuất Âm
                                SizedBox(
                                  width: 130,
                                  child: ValidationHelper.checkboxForBox(
                                    label: "Xuất Âm",
                                    notifier: isNegativeStockAllowed,
                                    onChanged: (val) {
                                      if (val == true) {
                                        setState(() => errRemainQty = null);
                                      }
                                    },
                                  ),
                                ),
                                buildLineVertical(),

                                // Checkbox: Hàng Tặng
                                SizedBox(
                                  width: 140,
                                  child: ValidationHelper.checkboxForBox(
                                    label: "Hàng Tặng",
                                    notifier: isPromotionChecked,
                                    onChanged: (val) {
                                      if (val == true) {
                                        pricePaperController.text = "0";
                                      }
                                    },
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),

                            //INPUT QTY OUTBOUND
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                //qty outbound
                                SizedBox(
                                  width: 260,
                                  child: Row(
                                    children: [
                                      Text(
                                        "SL đã xuất:",
                                        style: GoogleFonts.inter(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                          fontSize: 16,
                                        ),
                                      ),
                                      const SizedBox(width: 8),

                                      Expanded(
                                        child: TextFormField(
                                          controller: totalOutboundController,
                                          readOnly: true,
                                          decoration: InputDecoration(
                                            hintText: "0",
                                            contentPadding: const EdgeInsets.symmetric(
                                              horizontal: 15,
                                              vertical: 10,
                                            ),
                                            border: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            fillColor: Colors.grey.shade300,
                                            filled: true,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 15),

                                //qty remain
                                SizedBox(
                                  width: 260,
                                  child: Row(
                                    children: [
                                      Text(
                                        "Số lượng tồn:",
                                        style: GoogleFonts.inter(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                          fontSize: 16,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: TextFormField(
                                          controller: remainingQtyController,
                                          readOnly: true,
                                          decoration: InputDecoration(
                                            hintText: "0",
                                            contentPadding: const EdgeInsets.symmetric(
                                              horizontal: 20,
                                              vertical: 15,
                                            ),
                                            border: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            fillColor: Colors.grey.shade300,
                                            filled: true,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 15),

                                //qty outbound
                                SizedBox(
                                  width: 320,
                                  child: Row(
                                    children: [
                                      Text(
                                        "Số lượng xuất:",
                                        style: GoogleFonts.inter(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                          fontSize: 16,
                                        ),
                                      ),

                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: TextFormField(
                                          controller: qtyOutboundController,
                                          keyboardType: TextInputType.number,
                                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                          decoration: InputDecoration(
                                            hintText: "Nhập số lượng",
                                            isDense: true,
                                            contentPadding: const EdgeInsets.symmetric(
                                              horizontal: 20,
                                              vertical: 15,
                                            ),
                                            border: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            errorText: errRemainQty,
                                          ),
                                          validator: (value) {
                                            if (value == null || value.trim().isEmpty) {
                                              return "Không được để trống";
                                            }

                                            final parsed = int.tryParse(value);
                                            if (parsed == null) {
                                              return "Số lượng phải là số nguyên";
                                            } else if (parsed <= 0) {
                                              return "Số lượng phải lớn hơn 0";
                                            }

                                            return null;
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 15),

                                //btn add/update
                                AnimatedButton(
                                  onPressed: () {
                                    //bắt validate form
                                    if (!formKey.currentState!.validate()) {
                                      return;
                                    }
                                    addToTempTable();
                                  },
                                  label: editingIndex == null ? "Thêm" : "Cập nhật",
                                  icon: editingIndex == null ? Icons.add : Icons.save,
                                ),
                                const SizedBox(width: 5),
                              ],
                            ),
                            const SizedBox(height: 5),
                          ],
                        ),
                      ),
                    ),
                    const Divider(height: 40),

                    /// ===== TABLE =====
                    SizedBox(
                      width: double.infinity,
                      height: 300,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: DataTable(
                          headingRowHeight: 44,
                          dataRowMinHeight: 40,
                          columnSpacing: 24,
                          horizontalMargin: 16,
                          dividerThickness: 0.6,
                          showCheckboxColumn: false,
                          headingRowColor: WidgetStateProperty.all(
                            Color.fromARGB(255, 250, 235, 148),
                          ),
                          border: TableBorder(
                            horizontalInside: BorderSide(color: Colors.grey.shade300),
                            top: BorderSide(color: Colors.grey.shade300),
                            bottom: BorderSide(color: Colors.grey.shade300),
                          ),
                          columns: [
                            buildHeader("Mã Đơn Hàng"),
                            buildHeader("Tên Khách Hàng"),
                            buildHeader("Tên Sản phẩm"),
                            buildHeader("QC Giấy"),
                            buildHeader("QC Thùng"),
                            buildHeader("DVT"),
                            buildHeader("Số Lượng Xuất"),
                            buildHeader("Đơn Giá"),
                            buildHeader("Loại"),
                            buildHeader(""),
                          ],

                          rows:
                              tempItems.asMap().entries.map((entry) {
                                final index = entry.key;
                                final e = entry.value;

                                return DataRow(
                                  selected: editingIndex == index,
                                  onSelectChanged: (selected) {
                                    if (selected != true) return;

                                    state(() {
                                      editingIndex = index;
                                      fillFormFromTempItem(e);
                                      isNegativeStockAllowed.value =
                                          (e.qtyOutbound > (e.qtyInventory ?? 0));
                                      setState(() {});
                                    });
                                  },
                                  cells: [
                                    buildCell(e.orderId),
                                    buildCell(e.customerName),
                                    buildCell(e.productName),
                                    buildCell(
                                      formatDimensions(e.lengthManufacture, e.sizeManufacture),
                                    ),
                                    buildCell(e.QC_box ?? ""),
                                    buildCell(e.dvt),
                                    buildCell(Order.formatCurrency(e.qtyOutbound)),
                                    buildCell(Order.formatCurrency(e.pricePaper)),
                                    DataCell(
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: e.isPromotion ? Colors.orange : Colors.blue,
                                          borderRadius: BorderRadius.circular(5),
                                        ),
                                        child: Text(
                                          e.isPromotion ? "Hàng Tặng" : "Hàng Bán",
                                          style: const TextStyle(color: Colors.white, fontSize: 12),
                                        ),
                                      ),
                                    ),
                                    DataCell(
                                      IconButton(
                                        icon: const Icon(Icons.delete_outline, color: Colors.red),
                                        onPressed: () {
                                          state(() {
                                            tempItems.removeAt(index);
                                            if (editingIndex == index) {
                                              editingIndex = null;
                                              clearController();
                                            }
                                          });
                                        },
                                      ),
                                    ),
                                  ],
                                );
                              }).toList(),
                        ),
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
                isEdit ? "Cập nhật" : "Xuất Kho",
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

  DataColumn buildHeader(String title) {
    return DataColumn(
      label: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
    );
  }

  DataCell buildCell(String value) {
    return DataCell(
      Text(
        value,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
      ),
    );
  }

  Widget buildLineVertical() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(width: 1, height: 30, color: Colors.grey.shade300),
    );
  }

  String formatDimensions(num? length, num? size) {
    if (length == 0 && size == 0) return "";

    // Hàm phụ để xử lý định dạng từng số (cm -> mm -> chuỗi 4 chữ số)
    String formatValue(num? val) {
      if (val == null) return "";
      return (val * 10).round().toString().padLeft(4, "0");
    }

    final lengthStr = formatValue(length);
    final sizeStr = formatValue(size);

    return "${lengthStr}x$sizeStr";
  }
}
