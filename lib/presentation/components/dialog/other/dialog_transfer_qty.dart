import 'package:dongtam/data/models/order/order_model.dart';
import 'package:dongtam/data/models/warehouse/inventory/inventory_model.dart';
import 'package:dongtam/presentation/components/shared/cardForm/building_card_form.dart';
import 'package:dongtam/presentation/components/shared/cardForm/format_key_value_card.dart';
import 'package:dongtam/presentation/components/shared/confirm_dialog.dart';
import 'package:dongtam/service/order_service.dart';
import 'package:dongtam/service/warehouse_service.dart';
import 'package:dongtam/utils/handleError/api_exception.dart';
import 'package:dongtam/utils/handleError/show_snack_bar.dart';
import 'package:dongtam/utils/helper/auto_complete_field.dart';
import 'package:dongtam/utils/helper/reponsive/reponsive_dialog.dart';
import 'package:dongtam/utils/logger/app_logger.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

class DialogTransferQty extends StatefulWidget {
  final InventoryModel inventory;
  final VoidCallback onLoad;

  const DialogTransferQty({super.key, required this.inventory, required this.onLoad});

  @override
  State<DialogTransferQty> createState() => _DialogTransferQtyState();
}

class _DialogTransferQtyState extends State<DialogTransferQty> {
  final formKey = GlobalKey<FormState>();

  final _orderIdController = TextEditingController();
  final _customerNameController = TextEditingController();
  final _songController = TextEditingController();
  final _dvtController = TextEditingController();

  //inventory
  final _qtyInventoryController = TextEditingController();
  final _valueInventoryController = TextEditingController();

  //specs
  final _sizeController = TextEditingController();
  final _lengthController = TextEditingController();

  //structure
  final _matEController = TextEditingController();
  final _matBController = TextEditingController();
  final _matCController = TextEditingController();
  final _matE2Controller = TextEditingController();
  final _songEController = TextEditingController();
  final _songBController = TextEditingController();
  final _songCController = TextEditingController();
  final _songE2Controller = TextEditingController();

  final _orderIdReceiveControler = TextEditingController();
  final _cusNameReceiveControler = TextEditingController();
  final _qtyTransferController = TextEditingController();

  @override
  void initState() {
    super.initState();
    orderInvInitState();
  }

  void orderInvInitState() {
    final inventory = widget.inventory;
    final order = inventory.order!;

    AppLogger.i("Khởi tạo form với orderId=${inventory.orderId}");

    _orderIdController.text = inventory.orderId;
    _customerNameController.text = order.customer?.customerName ?? "";
    _songController.text = order.flute.toString();
    _dvtController.text = order.dvt;

    //inventory
    _qtyInventoryController.text = inventory.qtyInventory.toString();
    _valueInventoryController.text = inventory.valueInventory.toStringAsFixed(1);

    //specs
    _sizeController.text = order.paperSizeCustomer.toString();
    _lengthController.text = order.lengthPaperManufacture.toString();

    //structure
    _matEController.text = order.matE.toString();
    _matBController.text = order.matB.toString();
    _matCController.text = order.matC.toString();
    _matE2Controller.text = order.matE2.toString();
    _songEController.text = order.songE.toString();
    _songBController.text = order.songB.toString();
    _songCController.text = order.songC.toString();
    _songE2Controller.text = order.songE2.toString();
  }

  void submit() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    // Show loading
    showLoadingDialog(context);
    await Future.delayed(const Duration(seconds: 1));

    try {
      final bool success = await WarehouseService().transferQtyToOrderOrQilidation(
        action: 'TRANSFER_QTY',
        sourceOrderId: _orderIdController.text,
        targetOrderId: _orderIdReceiveControler.text,
        qtyTransfer: int.parse(_qtyTransferController.text),
      );

      if (success) {
        if (!mounted) return;
        Navigator.pop(context); // đóng dialog loading

        if (!mounted) return;
        showSnackBarSuccess(context, "Chuyển giao số lượng thành công");

        widget.onLoad();
        Navigator.of(context).pop();
      }
    } on ApiException catch (e) {
      setState(() {
        switch (e.errorCode) {
          case 'INSUFFICIENT_QUANTITY':
            showSnackBarError(context, "Số lượng tồn không đủ để chuyển giao");
            break;
          default:
            showSnackBarError(context, 'Có lỗi xảy ra, vui lòng thử lại');
        }
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        formKey.currentState!.validate();
      });

      if (!mounted) return;
      Navigator.pop(context); // đóng dialog loading
    } catch (e) {
      AppLogger.e("Lỗi khi submit form chuyển giao số lượng", error: e);

      if (!mounted) return;
      showSnackBarError(context, "Có lỗi xảy ra. Vui lòng thử lại.");
    }
  }

  @override
  void dispose() {
    super.dispose();
    _orderIdController.dispose();
    _customerNameController.dispose();
    _songController.dispose();
    _sizeController.dispose();
    _lengthController.dispose();
    _dvtController.dispose();
    _qtyInventoryController.dispose();
    _valueInventoryController.dispose();
    _matEController.dispose();
    _matBController.dispose();
    _matCController.dispose();
    _matE2Controller.dispose();
    _songEController.dispose();
    _songBController.dispose();
    _songCController.dispose();
    _songE2Controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final order = widget.inventory.order!;
    final dvt = _dvtController.text;
    final qtyInventory = int.parse(_qtyInventoryController.text);
    final valueInventory = double.parse(_valueInventoryController.text);

    final List<Map<String, String>> inventoryInfo = [
      {
        "leftKey": "Mã Đơn Hàng",
        "leftValue": _orderIdController.text,
        "rightKey": "Kết Cấu Giấy",
        "rightValue": order.formatterStructureOrder,
      },
      {
        "leftKey": "Khách Hàng",
        "leftValue": _customerNameController.text,
        "rightKey": "Sóng",
        "rightValue": _songController.text,
      },
      {
        "leftKey": "Cắt",
        "leftValue": '${_lengthController.text} cm',
        "rightKey": "Khổ",
        "rightValue": "${_sizeController.text} cm",
      },
      {
        "leftKey": "Số Lượng Tồn",
        "leftValue": "$qtyInventory ($dvt)",
        "rightKey": "Giá Trị Tồn",
        "rightValue": "${Order.formatCurrency(valueInventory)} VNĐ",
      },
    ];

    final List<Map<String, dynamic>> inputRows = [
      {
        "leftKey": "Mã Đơn Hàng",
        // "leftValue": validateInput(
        //   label: "Mã Đơn Hàng Nhận",
        //   controller: _orderIdReceiveControler,
        //   icon: Symbols.orders,
        // ),
        "leftValue": AutoCompleteField<Order>(
          controller: _orderIdReceiveControler,
          labelText: "Mã Đơn Hàng Nhận",
          icon: Symbols.orders,
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

            if (selectedOrder != null) {
              _orderIdReceiveControler.text = selectedOrder.orderId;
              _cusNameReceiveControler.text = selectedOrder.customer?.customerName ?? "";
            }
          },
          onChanged: (value) {
            if (value.isEmpty) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _orderIdReceiveControler.clear();
                _cusNameReceiveControler.clear();
              });
            }
          },
        ),

        "rightKey": "Tên Khách Hàng",
        "rightValue": validateInput(
          label: "Tên Khách Hàng Nhận",
          controller: _cusNameReceiveControler,
          icon: Symbols.person,
          readOnly: true,
        ),
      },
      {
        "leftKey": "Số lượng chuyển",
        "leftValue": validateInput(
          label: "Số lượng chuyển giao",
          controller: _qtyTransferController,
          icon: Icons.numbers,
        ),
        "rightKey": "",
        "rightValue": "",
      },
    ];

    return StatefulBuilder(
      builder: (context, state) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          content: SizedBox(
            width: ResponsiveSize.getWidth(context, ResponsiveType.large),
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),

                    //specifications inventory source
                    buildingCard(
                      title: "📦 Thông Tin Đơn Hàng",
                      children: formatKeyValueRows(
                        rows: inventoryInfo,
                        labelWidth: 145,
                        columnCount: 2,
                      ),
                    ),
                    const SizedBox(height: 10),

                    //input qty transfer
                    buildingCard(
                      title: "✏️ Thông Tin Chuyển Giao Số Lượng",
                      children: formatKeyValueRows(
                        rows: inputRows,
                        labelWidth: 150,
                        columnCount: 2,
                        centerAlign: true,
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
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black54),
              ),
            ),
            ElevatedButton(
              onPressed: submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff78D761),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text(
                "Lưu",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }
}

Widget validateInput({
  required String label,
  bool readOnly = false,
  required TextEditingController controller,
  required IconData icon,
}) {
  return TextFormField(
    controller: controller,
    readOnly: readOnly,
    decoration: InputDecoration(
      labelText: label,
      labelStyle: TextStyle(fontWeight: FontWeight.bold),
      prefixIcon: Icon(icon),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      floatingLabelBehavior: FloatingLabelBehavior.always,
      fillColor: readOnly ? Colors.grey[300] : Colors.white,
      filled: true,
    ),

    validator: (value) {
      final cleanValue = value?.trim().replaceAll(RegExp(r'[\r\n]+'), ' ') ?? '';

      final requiredFields = ["Mã Đơn Hàng Nhận", "Số lượng chuyển giao"];

      if (requiredFields.contains(label) && cleanValue.isEmpty) {
        return 'Không được để trống';
      }

      if (label == 'Số lượng chuyển giao' && value != null) {
        final qty = int.tryParse(value);
        if (qty == null) {
          return "Chỉ chấp nhận số nguyên";
        }

        if (qty <= 0) {
          return "Số lượng phải lớn hơn 0";
        }
      }

      return null;
    },
  );
}
