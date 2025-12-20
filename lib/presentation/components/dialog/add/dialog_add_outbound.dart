import 'package:dongtam/data/models/order/order_model.dart';
import 'package:dongtam/data/models/warehouse/outbound/outbound_history_model.dart';
import 'package:dongtam/data/models/warehouse/outbound/outbound_temp_item.dart';
import 'package:dongtam/presentation/components/shared/animated_button.dart';
import 'package:dongtam/service/order_service.dart';
import 'package:dongtam/service/warehouse_service.dart';
import 'package:dongtam/utils/handleError/show_snack_bar.dart';
import 'package:dongtam/utils/helper/auto_complete_field.dart';
import 'package:dongtam/utils/helper/cardForm/building_card_form.dart';
import 'package:dongtam/utils/helper/cardForm/format_key_value_card.dart';
import 'package:dongtam/utils/helper/confirm_dialog.dart';
import 'package:dongtam/utils/helper/reponsive_size.dart';
import 'package:dongtam/utils/logger/app_logger.dart';
import 'package:dongtam/utils/validation/validation_order.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

class OutBoundDialog extends StatefulWidget {
  final OutboundHistoryModel? outboundHistory;
  final VoidCallback onOutboundHistory;

  const OutBoundDialog({super.key, this.outboundHistory, required this.onOutboundHistory});

  @override
  State<OutBoundDialog> createState() => _OutBoundDialogState();
}

class _OutBoundDialogState extends State<OutBoundDialog> {
  final formKey = GlobalKey<FormState>();
  String lastSearchedOrderId = "";
  int? editingIndex; // null = add, != null = update

  final List<OutboundTempItem> tempItems = [];

  final orderIdController = TextEditingController();
  final customerNameController = TextEditingController();
  final companyNameController = TextEditingController();

  final saleNameController = TextEditingController();
  final typeProductController = TextEditingController();
  final productNameController = TextEditingController();

  final fluteController = TextEditingController();
  final qcBoxController = TextEditingController();
  final dvtController = TextEditingController();

  final quantityCustomerController = TextEditingController();
  final discountController = TextEditingController();
  final priceController = TextEditingController();

  final qtyOutboundController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  void clearController() {
    orderIdController.clear();
    customerNameController.clear();
    companyNameController.clear();
    saleNameController.clear();
    typeProductController.clear();
    productNameController.clear();
    fluteController.clear();
    qcBoxController.clear();
    dvtController.clear();
    quantityCustomerController.clear();
    discountController.clear();
    priceController.clear();
    qtyOutboundController.clear();
  }

  void addToTempTable() {
    if (orderIdController.text.isEmpty) return;

    if (editingIndex == null && tempItems.any((x) => x.orderId == orderIdController.text)) {
      showSnackBarError(context, "Đơn hàng này đã được thêm");
      return;
    }

    final newOutboundItem = OutboundTempItem(
      orderId: orderIdController.text,
      typeProduct: typeProductController.text,
      productName: productNameController.text,
      customerName: customerNameController.text,
      companyName: companyNameController.text,
      saleName: saleNameController.text,
      flute: fluteController.text,
      qcBox: qcBoxController.text,
      dvt: dvtController.text,
      price: double.tryParse(priceController.text) ?? 0,
      quantityCustomer: double.tryParse(quantityCustomerController.text) ?? 0,
      discount: double.tryParse(discountController.text) ?? 0,
      qtyOutbound: int.tryParse(qtyOutboundController.text) ?? 0,
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

  void fillFormFromTempItem(OutboundTempItem outbound) {
    orderIdController.text = outbound.orderId;
    customerNameController.text = outbound.customerName;
    companyNameController.text = outbound.companyName;
    saleNameController.text = outbound.saleName;
    typeProductController.text = outbound.typeProduct;
    productNameController.text = outbound.productName;
    fluteController.text = outbound.flute ?? "";
    qcBoxController.text = outbound.qcBox ?? "";
    dvtController.text = outbound.dvt;
    quantityCustomerController.text = outbound.quantityCustomer.toString();
    discountController.text = outbound.discount.toString();
    priceController.text = outbound.price.toString();
    qtyOutboundController.text = outbound.qtyOutbound.toString();
  }

  void submit() async {
    try {
      final bool isAdd = widget.outboundHistory == null;

      AppLogger.i(isAdd ? "Thêm phiếu xuất kho mới" : "Cập nhật phiếu xuất kho");

      await WarehouseService().createOutbound(
        list:
            tempItems.map((outbound) {
              return {"orderId": outbound.orderId, "outboundQty": outbound.qtyOutbound};
            }).toList(),
      );

      // Show loading
      if (!mounted) return;
      showLoadingDialog(context);
      await Future.delayed(const Duration(seconds: 1));

      if (!mounted) return;
      Navigator.pop(context); // đóng dialog loading

      // Thông báo thành công
      if (!mounted) return;
      showSnackBarSuccess(context, isAdd ? "Thêm thành công" : "Cập nhật thành công");

      widget.onOutboundHistory();

      if (!mounted) return;
      Navigator.of(context).pop();
    } catch (e, s) {
      if (widget.outboundHistory == null) {
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
    companyNameController.dispose();
    qcBoxController.dispose();
    quantityCustomerController.dispose();
    priceController.dispose();
    discountController.dispose();
    dvtController.dispose();
    saleNameController.dispose();
    fluteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.outboundHistory != null;

    final List<Map<String, dynamic>> infoOrderRows = [
      {
        "leftKey": "Mã Đơn Hàng",
        "leftValue": AutoCompleteField<Order>(
          controller: orderIdController,
          labelText: "Mã Đơn Hàng",
          icon: Symbols.box,
          suggestionsCallback: (pattern) async {
            final result = await OrderService().getOrderByField(field: 'orderId', keyword: pattern);
            if (result['orders'] != null && result['orders'] is List<Order>) {
              return result['orders'] as List<Order>;
            }

            return [];
          },
          displayStringForItem: (order) => order.orderId,
          itemBuilder: (context, order) {
            return ListTile(
              title: Text(order.orderId),
              subtitle: Text(order.customer?.customerName ?? ""),
            );
          },
          onSelected: (order) {
            customerNameController.text = order.customer?.customerName ?? "";
            companyNameController.text = order.customer?.companyName ?? "";
            saleNameController.text = order.user?.fullName ?? "";
            typeProductController.text = order.product?.typeProduct ?? "";
            productNameController.text = order.product?.productName ?? "";
            fluteController.text = order.flute ?? "";
            qcBoxController.text = order.QC_box ?? "";
            dvtController.text = order.dvt;
            quantityCustomerController.text = order.quantityCustomer.toStringAsFixed(1);
            discountController.text = order.discount.toString();
            priceController.text = order.price.toStringAsFixed(1);
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
        "rightKey": "Tên công ty",
        "rightValue": ValidationOrder.validateInput(
          label: "Tên công ty",
          controller: companyNameController,
          icon: Symbols.business,
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
        "leftKey": "Sóng",
        "leftValue": ValidationOrder.validateInput(
          label: "Sóng",
          controller: fluteController,
          icon: Symbols.waves,
          readOnly: true,
        ),
        "middleKey": "Số lượng",
        "middleValue": ValidationOrder.validateInput(
          label: "Số lượng (KH)",
          controller: quantityCustomerController,
          icon: Symbols.filter_9_plus,
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
        "leftKey": "Chiết khấu",
        "leftValue": ValidationOrder.validateInput(
          label: "Chiết khấu",
          controller: discountController,
          icon: Symbols.price_change,
          readOnly: true,
        ),
        "middleKey": "Đơn giá",
        "middleValue": ValidationOrder.validateInput(
          label: "Đơn giá (M2)",
          controller: priceController,
          icon: Symbols.price_change,
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
                    const SizedBox(height: 12),

                    //button
                    Align(
                      alignment: Alignment.centerRight,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 360,
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
                                        vertical: 16,
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    validator: (value) {
                                      if (value == null || value.trim().isEmpty) {
                                        return "Số lượng không được để trống";
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

                          //button
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
                            buildHeader("Đơn Giá"),
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
                                    buildCell(e.qcBox ?? ""),
                                    buildCell(e.dvt),
                                    buildCell(e.qtyOutbound.toString()),
                                    buildCell(e.price.toString()),
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
