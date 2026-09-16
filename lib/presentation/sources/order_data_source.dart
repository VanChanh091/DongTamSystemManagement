import "package:dongtam/data/controller/user_controller.dart";
import "package:dongtam/data/models/order/order_model.dart";
import "package:dongtam/utils/helper/build_color_row.dart";
import "package:dongtam/utils/helper/style_table.dart";
import "package:flutter/material.dart";
import "package:get/get.dart";
import "package:syncfusion_flutter_datagrid/datagrid.dart";
import "package:intl/intl.dart";

const Set<String> _boolColumns = {
  "chongTham",
  "canLanBox",
  "canMang",
  "xa",
  "catKhe",
  "be",
  "dan_1_Manh",
  "dan_2_Manh",
  "dongGhimMotManh",
  "dongGhimHaiManh",
  "isBox",
  "CTPaper",
  "isFSC",
};

class OrderDataSource extends DataGridSource {
  final BuildContext context;
  late List<DataGridRow> orderDataGridRows;

  List<OrderModel> orders;
  String? selectedOrderId;

  final userController = Get.find<UserController>();
  final formatter = DateFormat("dd/MM/yyyy");

  OrderDataSource({required this.orders, this.selectedOrderId, required this.context}) {
    buildDataCell();
  }

  List<DataGridCell> buildOrderCells(OrderModel order, int index) {
    DataGridCell<double> buildCurrencyCell(String columnName, double value) {
      return DataGridCell<double>(columnName: columnName, value: value);
    }

    return [
      DataGridCell<int>(columnName: "index", value: index + 1),
      DataGridCell<String>(columnName: "orderId", value: order.orderId),

      DataGridCell<String>(
        columnName: "dateShipping",
        value: formatter.format(order.dateRequestShipping!),
      ),

      DataGridCell<String>(columnName: "customerName", value: order.customer?.customerName ?? ""),
      DataGridCell<String>(columnName: "typeProduct", value: order.product?.typeProduct ?? ""),
      DataGridCell<String>(columnName: "productName", value: order.product?.productName ?? ""),

      DataGridCell<String>(columnName: "flute", value: order.flute != "0" ? "${order.flute}" : "-"),
      DataGridCell<String>(columnName: "QC_box", value: order.QC_box ?? ""),
      DataGridCell<String>(columnName: "structure", value: order.formatterStructureOrder),
      DataGridCell<bool>(columnName: "isFSC", value: order.isFSC),
      DataGridCell<bool>(columnName: "CTPaper", value: order.chongTham),
      DataGridCell<String>(columnName: "canLan", value: order.canLan ?? ""),
      DataGridCell<String>(columnName: "daoXaOrd", value: order.daoXa),

      buildCurrencyCell("sizeCus", order.paperSizeCustomer),
      buildCurrencyCell("lengthCus", order.lengthPaperCustomer),
      buildCurrencyCell("sizeManu", order.paperSizeManufacture),
      buildCurrencyCell("lengthManu", order.lengthPaperManufacture),

      DataGridCell<int>(columnName: "quantityCustomer", value: order.quantityCustomer),
      DataGridCell<int>(columnName: "qtyManufacture", value: order.quantityManufacture),

      DataGridCell<double>(columnName: "volume", value: order.volume ?? 0),
      DataGridCell<int>(columnName: "child", value: order.numberChild),
      DataGridCell<String>(columnName: "dvt", value: order.dvt),

      buildCurrencyCell("acreage", order.acreage ?? 0),
      DataGridCell<String>(columnName: "vat", value: order.vat! > 0 ? "${order.vat ?? 0}%" : "-"),

      buildCurrencyCell("price", order.price),
      buildCurrencyCell("pricePaper", order.pricePaper ?? 0),
      buildCurrencyCell("discounts", order.discount ?? 0),
      buildCurrencyCell("profitOrd", order.profit),
      buildCurrencyCell("totalPrice", order.totalPrice ?? 0),

      DataGridCell<String>(columnName: "instructSpecial", value: order.instructSpecial ?? ""),

      ...buildBoxCells(order),
    ];
  }

  List<DataGridCell> buildBoxCells(OrderModel order) {
    return [
      DataGridCell<int>(columnName: "inMatTruoc", value: order.box?.inMatTruoc ?? 0),
      DataGridCell<int>(columnName: "inMatSau", value: order.box?.inMatSau ?? 0),

      DataGridCell<bool>(columnName: "chongTham", value: order.box?.chongTham ?? false),
      DataGridCell<bool>(columnName: "canLanBox", value: order.box?.canLan ?? false),
      DataGridCell<bool>(columnName: "canMang", value: order.box?.canMang ?? false),
      DataGridCell<bool>(columnName: "xa", value: order.box?.Xa ?? false),
      DataGridCell<bool>(columnName: "catKhe", value: order.box?.catKhe ?? false),
      DataGridCell<bool>(columnName: "be", value: order.box?.be ?? false),
      DataGridCell<bool>(columnName: "dan_1_Manh", value: order.box?.dan_1_Manh ?? false),
      DataGridCell<bool>(columnName: "dan_2_Manh", value: order.box?.dan_2_Manh ?? false),
      DataGridCell<bool>(columnName: "dongGhimMotManh", value: order.box?.dongGhim1Manh ?? false),
      DataGridCell<bool>(columnName: "dongGhimHaiManh", value: order.box?.dongGhim2Manh ?? false),
      DataGridCell<String>(columnName: "maKhuon", value: order.box?.maKhuon ?? ""),
      DataGridCell<String>(columnName: "dongGoi", value: order.box?.dongGoi ?? ""),

      DataGridCell<String>(columnName: "orderIdCustomer", value: order.orderIdCustomer ?? ""),

      ...userController.hasAnyRole(roles: ["admin", "manager"])
          ? [
            DataGridCell(
              columnName: "staffOrder",
              value: () {
                final fullName = order.user?.fullName ?? ""; //Nguyễn Văn Chánh
                final parts = fullName.trim().split(" "); //["Nguyễn", "Văn", "Chánh"]
                if (parts.length >= 2) {
                  return parts.sublist(parts.length - 2).join(" "); //Văn Chánh
                } else {
                  return fullName;
                }
              }(),
            ),
          ]
          : [],

      DataGridCell(columnName: "status", value: formatStatus(order.status)),
      DataGridCell(columnName: "rejectReason", value: order.rejectReason ?? ""),
      DataGridCell(columnName: "note", value: order.note ?? ""),
      DataGridCell(columnName: "orderImage", value: order.orderImage?.imageUrl ?? ""),
    ];
  }

  String formatStatus(String status) {
    if (status == "accept") {
      return "Chấp nhận";
    } else if (status == "reject") {
      return "Từ chối";
    } else if (status == "planning") {
      return "Đã lên kế hoạch";
    }
    return "Chờ Duyệt";
  }

  @override
  List<DataGridRow> get rows => orderDataGridRows;

  void buildDataCell() {
    orderDataGridRows =
        orders.asMap().entries.map<DataGridRow>((entry) {
          int index = entry.key;
          return DataGridRow(cells: buildOrderCells(entry.value, index));
        }).toList();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

  Widget _buildImageCell(String imageUrl) {
    final hasImage = imageUrl.isNotEmpty && imageUrl != "Không có ảnh";

    return Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
        border: Border(right: BorderSide(color: Colors.grey.shade300, width: 1)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child:
          hasImage
              ? TextButton(
                onPressed: () => _showImageDialog(imageUrl),
                child: const Text(
                  "Xem ảnh",
                  style: TextStyle(color: Colors.blue, decoration: TextDecoration.underline),
                ),
              )
              : const Text("Không có ảnh"),
    );
  }

  void _showImageDialog(String imageUrl) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder:
          (_) => GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Scaffold(
              backgroundColor: Colors.black54,
              body: Center(
                child: GestureDetector(
                  onTap: () {}, // Ngăn đóng dialog khi bấm trúng ảnh
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: SizedBox(
                      width: 800,
                      height: 800,
                      child: Image.network(
                        imageUrl,
                        fit: BoxFit.contain,
                        errorBuilder:
                            (_, _, _) => Container(
                              width: 300,
                              height: 300,
                              color: Colors.grey.shade300,
                              alignment: Alignment.center,
                              child: const Text("Lỗi ảnh", style: TextStyle(color: Colors.black)),
                            ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
    );
  }

  Widget _buildCell(DataGridCell dataCell) {
    // Xử lý cột ảnh
    if (dataCell.columnName == "orderImage") {
      return _buildImageCell(dataCell.value?.toString() ?? "");
    }

    final value = dataCell.value;
    String displayValue = "";
    Alignment alignment = Alignment.centerLeft;

    // Xử lý cột dạng số
    if (value is num) {
      alignment = Alignment.centerRight;

      final numVal = value.toDouble();
      displayValue = (numVal == 0) ? "-" : OrderModel.formatCurrency(numVal);
    }
    //Xử lý cột dạng Boolean
    else if (_boolColumns.contains(dataCell.columnName)) {
      alignment = Alignment.center;
      displayValue = (value == true) ? "✅" : "";
    }
    // Các cột văn bản thông thường
    else {
      displayValue = value?.toString() ?? "";
    }

    return formatDataTable(label: displayValue, alignment: alignment);
  }

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    //get value cell
    final orderId = getCellValue<String>(row, "orderId", "");
    final status = getCellValue<String>(row, "status", "").toLowerCase();

    // Chọn màu nền theo status
    Color backgroundColor;
    if (selectedOrderId == orderId) {
      backgroundColor = Colors.blue.withValues(alpha: 0.3);
    } else {
      switch (status) {
        case "từ chối":
          backgroundColor = Colors.red.withValues(alpha: 0.4);
          break;
        case "đã lên kế hoạch":
          backgroundColor = Colors.white;
          break;
        default:
          backgroundColor = Colors.transparent;
      }
    }

    return DataGridRowAdapter(
      color: backgroundColor,
      cells: row.getCells().map(_buildCell).toList(),
    );
  }
}
