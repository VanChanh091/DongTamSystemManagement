import 'package:dongtam/data/controller/theme_controller.dart';
import 'package:dongtam/utils/helper/style_table.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

final List<Map<String, dynamic>> _inventoryColumns = [
  {"key": "index", "title": "STT"},

  {"key": "orderId", "title": "Mã Đơn Hàng"},
  {"key": "customerName", "title": "Khách Hàng"},
  {"key": "typeProduct", "title": "Loại Sản Phẩm"},
  {"key": "productName", "title": "Tên Sản Phẩm"},
  {"key": "isFSC", "title": "Đơn FSC"},

  {"key": "QcBox", "title": "QC Thùng"},
  {"key": "flute", "title": "Sóng"},
  {"key": "structure", "title": "Kết Cấu Đặt Hàng"},
  {"key": "size", "title": "Khổ (SX)"},
  {"key": "length", "title": "Dài (SX)"},

  {"key": "totalQtyInbound", "title": "Nhập Kho"},
  {"key": "totalQtyOutbound", "title": "Tổng Xuất"},
  {"key": "qtyTransfer", "title": "Chuyển Giao"},
  {"key": "qtyInventory", "title": "Tồn"},

  {"key": "dvt", "title": "DVT"},
  {"key": "price", "title": "Đơn Giá"},
  {"key": "valueInventory", "title": "Giá Trị Tồn"},

  {"key": "fullName", "title": "Nhân Viên"},

  //hidden
  {"key": "inventoryId", "title": "", "visible": false},
];

List<GridColumn> buildInventoryColumn({
  required ThemeController themeController,
  required ValueNotifier<double> zoomNotifier,
}) => buildGridColumns(
  headerConfig: _inventoryColumns,
  themeController: themeController,
  zoomNotifier: zoomNotifier,
);

List<StackedHeaderRow> buildInventorySHR({
  required ThemeController themeController,
  required double zoom,
}) {
  return [
    StackedHeaderRow(
      cells: [
        buildStackedHeaderCell(
          columnNames: ["quantityOrd", "runningPlanProd", "qtyProduced"],
          label: "Số Lượng",
          themeController: themeController,
          zoom: zoom,
        ),
        buildStackedHeaderCell(
          columnNames: ["totalQtyInbound", "totalQtyOutbound", "qtyTransfer", "qtyInventory"],
          label: "Số Lượng",
          themeController: themeController,
          zoom: zoom,
        ),
        buildStackedHeaderCell(
          columnNames: ["totalPrice", "totalPriceVAT"],
          label: "Tổng Tiền",
          themeController: themeController,
          zoom: zoom,
        ),
      ],
    ),
  ];
}
