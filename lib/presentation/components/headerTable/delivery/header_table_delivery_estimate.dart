import 'package:dongtam/data/controller/theme_controller.dart';
import 'package:dongtam/utils/helper/style_table.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

const List<Map<String, dynamic>> _headerDeliveryEstimate = [
  // Order
  {"key": "index", "title": "STT"},
  {"key": "orderId", "title": "Mã Đơn Hàng"},
  {"key": "orderIdCust", "title": "PO Khách"},
  {"key": "dateShipping", "title": "Ngày Dự Kiến"},
  {"key": "delivered", "title": "Trạng Thái"},

  // Customer & Product
  {"key": "customerName", "title": "Tên Khách Hàng"},
  {"key": "productName", "title": "Tên SP"},

  {"key": "QcBox", "title": "QC Thùng"},
  {"key": "size", "title": "Khổ"},
  {"key": "length", "title": "Dài"},

  // Quantity
  {"key": "quantityOrd", "title": "Đơn Hàng"},
  {"key": "qtyProduced", "title": "Đã Sản Xuất"},
  {"key": "qtyOutbound", "title": "Đã Xuất Kho"},
  {"key": "qtyInventory", "title": "Tồn Kho"},

  {"key": "dvt", "title": "DVT"},
  {"key": "volume", "title": "Khối Lượng (m³)"},

  //structure
  {"key": "structure", "title": "Kết Cấu Đặt Hàng"},
  {"key": "instructSpecial", "title": "HD Đặc Biệt"},
  {"key": "note", "title": "Ghi Chú"},

  // Staff
  {"key": "staffOrder", "title": "Nhân Viên"},

  // Hidden
  {"key": "planningId", "title": "", "visible": false},
];

List<GridColumn> buildDeliveryEstimateColumn({
  required ThemeController themeController,
  required ValueNotifier<double> zoomNotifier,
}) => buildGridColumns(
  headerConfig: _headerDeliveryEstimate,
  themeController: themeController,
  zoomNotifier: zoomNotifier,
);

List<StackedHeaderRow> buildDeliveryEstimateSHR({
  required ThemeController themeController,
  required double zoom,
}) {
  return [
    StackedHeaderRow(
      cells: [
        buildStackedHeaderCell(
          columnNames: ["size", "length"],
          label: "Quy Cách (cm)",
          themeController: themeController,
          zoom: zoom,
        ),
        buildStackedHeaderCell(
          columnNames: ["quantityOrd", "qtyProduced", "qtyOutbound", "qtyInventory"],
          label: "Số Lượng",
          themeController: themeController,
          zoom: zoom,
        ),
      ],
    ),
  ];
}
