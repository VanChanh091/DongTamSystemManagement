import 'package:dongtam/data/models/order/order_model.dart';
import 'package:dongtam/data/models/warehouse/outbound/outbound_history_model.dart';
import 'package:dongtam/data/models/warehouse/outbound/outbound_temp_item.dart';
import 'package:dongtam/presentation/components/shared/animated_button.dart';
import 'package:dongtam/service/warehouse_service.dart';
import 'package:dongtam/utils/handleError/api_exception.dart';
import 'package:dongtam/utils/handleError/show_snack_bar.dart';
import 'package:dongtam/utils/helper/auto_complete_field.dart';
import 'package:dongtam/presentation/components/shared/cardForm/building_card_form.dart';
import 'package:dongtam/presentation/components/shared/cardForm/format_key_value_card.dart';
import 'package:dongtam/presentation/components/shared/confirm_dialog.dart';
import 'package:dongtam/utils/helper/reponsive/reponsive_dialog.dart';
import 'package:dongtam/utils/logger/app_logger.dart';
import 'package:dongtam/utils/validation/validation_order.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

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
  String lastSearchedOrderId = "";
  int? editingIndex; // null = add, != null = update
  String? errRemainQty;

  final List<OutboundTempItem> tempItems = [];

  final orderIdController = TextEditingController();
  final customerNameController = TextEditingController();
  final saleNameController = TextEditingController();

  final lengthController = TextEditingController();
  final sizeController = TextEditingController();
  final fluteController = TextEditingController();

  final qcBoxController = TextEditingController();
  final typeProductController = TextEditingController();
  final productNameController = TextEditingController();

  final quantityCustomerController = TextEditingController();
  final pricePaperController = TextEditingController();
  final dvtController = TextEditingController();

  //other fields
  final remainingQtyController = TextEditingController();
  final qtyOutboundController = TextEditingController();

  @override
  void initState() {
    super.initState();

    if (widget.outbound != null) {
      outboundInitState();
    } else if (widget.initialItems != null) {
      tempItems.addAll(widget.initialItems!);
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
    orderIdController.clear();
    customerNameController.clear();
    lengthController.clear();
    sizeController.clear();
    saleNameController.clear();
    typeProductController.clear();
    productNameController.clear();
    fluteController.clear();
    qcBoxController.clear();
    dvtController.clear();
    quantityCustomerController.clear();
    pricePaperController.clear();
    qtyOutboundController.clear();
    remainingQtyController.clear();
  }

  void addToTempTable() {
    if (orderIdController.text.isEmpty) return;

    if (editingIndex == null && tempItems.any((x) => x.orderId == orderIdController.text)) {
      showSnackBarError(context, "Đơn hàng này đã được thêm");
      return;
    }

    int qtyOutbound = (int.tryParse(qtyOutboundController.text) ?? 0);
    int remainQty = (int.tryParse(remainingQtyController.text) ?? 0);

    if (qtyOutbound > remainQty) {
      setState(() {
        errRemainQty = 'Vượt quá số lượng tồn';
      });
      return;
    }

    setState(() {
      errRemainQty = null;
    });

    final newOutboundItem = OutboundTempItem(
      orderId: orderIdController.text,
      typeProduct: typeProductController.text,
      productName: productNameController.text,
      customerName: customerNameController.text,
      length: double.tryParse(lengthController.text) ?? 0,
      size: double.tryParse(sizeController.text) ?? 0,
      saleName: saleNameController.text,
      flute: fluteController.text,
      QC_box: qcBoxController.text,
      dvt: dvtController.text,
      pricePaper: double.tryParse(pricePaperController.text) ?? 0,
      quantityCustomer: double.tryParse(quantityCustomerController.text) ?? 0,
      qtyOutbound: int.tryParse(qtyOutboundController.text) ?? 0,
      qtyInventory: remainQty,
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
    orderIdController.text = temp.orderId;
    customerNameController.text = temp.customerName;
    lengthController.text = temp.length?.toString() ?? "";
    sizeController.text = temp.size?.toString() ?? "";
    saleNameController.text = temp.saleName;
    typeProductController.text = temp.typeProduct;
    productNameController.text = temp.productName;
    fluteController.text = temp.flute ?? "";
    qcBoxController.text = temp.QC_box ?? "";
    dvtController.text = temp.dvt;
    quantityCustomerController.text = temp.quantityCustomer.toString();
    pricePaperController.text = temp.pricePaper.toString();
    qtyOutboundController.text = temp.qtyOutbound.toString();
    remainingQtyController.text = temp.qtyInventory?.toString() ?? "0";
  }

  void submit() async {
    if (tempItems.any((item) => item.qtyOutbound <= 0)) {
      showSnackBarError(context, "Số lượng xuất kho phải lớn hơn 0");
      return;
    }

    // Show loading
    showLoadingDialog(context);
    await Future.delayed(const Duration(seconds: 1));

    try {
      final bool isAdd = widget.outbound == null;
      AppLogger.i(isAdd ? "Thêm phiếu xuất kho mới" : "Cập nhật phiếu xuất kho");

      final bool success;
      if (isAdd) {
        success = await WarehouseService().createOutbound(
          list:
              tempItems.map((outbound) {
                return {"orderId": outbound.orderId, "outboundQty": outbound.qtyOutbound};
              }).toList(),
        );
      } else {
        success = await WarehouseService().updateOutbound(
          outboundId: widget.outbound!.outboundId,
          list:
              tempItems.map((outbound) {
                return {"orderId": outbound.orderId, "outboundQty": outbound.qtyOutbound};
              }).toList(),
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
        'EMPTY_ORDER_LIST' => "Phải chọn ít nhất 1 đơn hàng",
        'CUSTOMER_MISMATCH' => "Các đơn hàng không cùng khách hàng",
        _ => 'Có lỗi xảy ra, vui lòng thử lại',
      };

      if (mounted) {
        showSnackBarError(context, errorText);
        Navigator.pop(context); // đóng dialog loading
      }
    } catch (e, s) {
      if (widget.outbound == null) {
        AppLogger.e("Lỗi khi thêm phiếu xuất kho", error: e, stackTrace: s);
      } else {
        AppLogger.e("Lỗi khi sửa phiếu xuất kho", error: e, stackTrace: s);
      }

      if (!mounted) return;
      showSnackBarError(context, "Lỗi: Không thể lưu dữ liệu");
    }
  }

  @override
  void dispose() {
    orderIdController.dispose();
    productNameController.dispose();
    typeProductController.dispose();
    customerNameController.dispose();
    lengthController.dispose();
    sizeController.dispose();
    qcBoxController.dispose();
    quantityCustomerController.dispose();
    pricePaperController.dispose();
    dvtController.dispose();
    saleNameController.dispose();
    fluteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.outbound != null;

    final List<Map<String, dynamic>> infoOrderRows = [
      {
        "leftKey": "Mã Đơn Hàng",
        "leftValue": AutoCompleteField<Order>(
          controller: orderIdController,
          labelText: "Mã Đơn Hàng",
          icon: Symbols.box,
          suggestionsCallback: (pattern) async {
            if (pattern.trim().length < 2) return [];
            return await WarehouseService().searchOrderIds(orderId: pattern);
          },
          displayStringForItem: (order) => order.orderId,
          itemBuilder: (context, order) {
            return ListTile(
              title: Text(order.orderId),
              subtitle: Text(order.customer?.customerName ?? ""),
            );
          },
          onSelected: (order) async {
            orderIdController.text = order.orderId;

            final selectedOrder = await WarehouseService().getOrderInboundQty(
              orderId: order.orderId,
            );

            if (selectedOrder == null) return;

            customerNameController.text = selectedOrder.customer?.customerName ?? "";
            lengthController.text = selectedOrder.lengthPaperManufacture.toString();
            sizeController.text = selectedOrder.paperSizeManufacture.toString();
            saleNameController.text = selectedOrder.user?.fullName ?? "";
            typeProductController.text = selectedOrder.product?.typeProduct ?? "";
            productNameController.text = selectedOrder.product?.productName ?? "";
            fluteController.text = selectedOrder.flute ?? "";
            qcBoxController.text = selectedOrder.QC_box ?? "";
            dvtController.text = selectedOrder.dvt;
            quantityCustomerController.text = selectedOrder.quantityCustomer.toStringAsFixed(1);
            pricePaperController.text = selectedOrder.pricePaper?.toStringAsFixed(1) ?? "";

            remainingQtyController.text = selectedOrder.remainingQty.toString();
          },

          onChanged: (value) {
            if (value.isEmpty) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                clearController();
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

        "rightKey": "NV Bán Hàng",
        "rightValue": ValidationOrder.validateInput(
          label: "NV Bán Hàng",
          controller: saleNameController,
          icon: Symbols.orders,
          readOnly: true,
        ),
      },

      {
        "leftKey": "QC Thùng",
        "leftValue": ValidationOrder.validateInput(
          label: "QC Thùng",
          controller: qcBoxController,
          icon: Symbols.deployed_code,
          readOnly: true,
        ),
        "middleKey": "Loại sản phẩm",
        "middleValue": ValidationOrder.validateInput(
          label: "Loại sản phẩm",
          controller: typeProductController,
          icon: Symbols.comment,
          readOnly: true,
        ),
        "rightKey": "Tên sản phẩm",
        "rightValue": ValidationOrder.validateInput(
          label: "Tên sản phẩm",
          controller: productNameController,
          icon: Symbols.box,
          readOnly: true,
        ),
      },

      {
        "leftKey": "Số lượng",
        "leftValue": ValidationOrder.validateInput(
          label: "Số lượng (KH)",
          controller: quantityCustomerController,
          icon: Symbols.filter_9_plus,
          readOnly: true,
        ),

        "middleKey": "Đơn giá",
        "middleValue": ValidationOrder.validateInput(
          label: "Đơn giá (M2)",
          controller: pricePaperController,
          icon: Symbols.price_change,
          readOnly: true,
        ),

        "rightKey": "Đơn Vị Tính",
        "rightValue": ValidationOrder.validateInput(
          label: "Đơn Vị Tính",
          controller: dvtController,
          icon: Symbols.deployed_code,
          readOnly: true,
        ),
      },

      {
        "leftKey": "Dài (SX)",
        "leftValue": ValidationOrder.validateInput(
          label: "Dài (SX)",
          controller: lengthController,
          icon: Symbols.business,
          readOnly: true,
        ),

        "middleKey": "Khổ (SX)",
        "middleValue": ValidationOrder.validateInput(
          label: "Khổ (SX)",
          controller: sizeController,
          icon: Symbols.price_change,
          readOnly: true,
        ),

        "rightKey": "Sóng",
        "rightValue": ValidationOrder.validateInput(
          label: "Sóng",
          controller: fluteController,
          icon: Symbols.waves,
          readOnly: true,
        ),
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
                    const SizedBox(height: 4),

                    //button
                    Align(
                      alignment: Alignment.centerRight,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          //qty remain
                          SizedBox(
                            width: 260,
                            child: Row(
                              children: [
                                Text(
                                  "Số lượng còn lại:",
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

                          //button add
                          AnimatedButton(
                            onPressed: () {
                              //bắt validate form
                              if (!formKey.currentState!.validate()) {
                                AppLogger.w("Form không hợp lệ, dừng submit");
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
                          dataRowMinHeight: 42,
                          columnSpacing: 24,
                          horizontalMargin: 16,
                          dividerThickness: 0.6,
                          headingRowColor: WidgetStateProperty.all(Colors.grey.shade100),
                          border: TableBorder(
                            horizontalInside: BorderSide(color: Colors.grey.shade300),
                            top: BorderSide(color: Colors.grey.shade300),
                            bottom: BorderSide(color: Colors.grey.shade300),
                          ),
                          columns: [
                            buildHeader("Mã Đơn Hàng"),
                            buildHeader("Tên Khách Hàng"),
                            buildHeader("Loại Sản Phẩm"),
                            buildHeader("Tên Sản phẩm"),
                            buildHeader("Quy Cách"),
                            buildHeader("DVT"),
                            buildHeader("Số Lượng Xuất"),
                            buildHeader("Giá Tấm"),
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
                                    });
                                  },
                                  cells: [
                                    buildCell(e.orderId),
                                    buildCell(e.customerName),
                                    buildCell(e.typeProduct),
                                    buildCell(e.productName),
                                    buildCell(e.QC_box ?? ""),
                                    buildCell(e.dvt),
                                    buildCell(e.qtyOutbound.toString()),
                                    buildCell(e.pricePaper.toString()),
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
}
