import 'package:dongtam/data/controller/theme_controller.dart';
import 'package:dongtam/utils/helper/style_table.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

final List<Map<String, dynamic>> _reportInboundColumns = [
  {"key": "index", "title": "STT"},
  {"key": "dateInbound", "title": "Ngày Nhập"},
  {"key": "orderId", "title": "Mã Đơn Hàng"},
  {"key": "customerName", "title": "Tên Khách Hàng"},
  {"key": "companyName", "title": "Tên Công Ty"},
  {"key": "typeProduct", "title": "Loại Sản Phẩm"},
  {"key": "productName", "title": "Tên Sản Phẩm"},
  {"key": "isFSC", "title": "Đơn FSC"},
  {"key": "QcBox", "title": "QC Thùng"},
  {"key": "flute", "title": "Sóng"},
  {"key": "structure", "title": "Kết Cấu Đặt Hàng"},
  {"key": "size", "title": "Khổ (SX)"},
  {"key": "length", "title": "Dài (SX)"},
  {"key": "quantityOrd", "title": "Đơn Hàng"},
  {"key": "qtyPaper", "title": "Giấy Tấm"},
  {"key": "qtyInbound", "title": "Nhập Kho"},
  {"key": "checkedBy", "title": "Người Kiểm Hàng"},

  //hidden
  {"key": "inboundId", "title": "", "visible": false},
];

List<GridColumn> buildReportInboundColumn({
  required ThemeController themeController,
  required ValueNotifier<double> zoomNotifier,
}) => buildGridColumns(
  headerConfig: _reportInboundColumns,
  themeController: themeController,
  zoomNotifier: zoomNotifier,
);


List<StackedHeaderRow> buildReportInboundSHR({
  required ThemeController themeController,
  required double zoom,
}) {
  return [
    StackedHeaderRow(
      cells: [
        buildStackedHeaderCell(
          columnNames: ["quantityOrd", "qtyPaper", "qtyInbound"],
          label: "Số Lượng",
          themeController: themeController,
          zoom: zoom,
        ),
      ],
    ),
  ];
}
