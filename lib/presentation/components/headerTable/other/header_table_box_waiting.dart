import 'package:dongtam/data/controller/theme_controller.dart';
import 'package:dongtam/utils/helper/style_table.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

const List<Map<String, dynamic>> _headerBoxWaiting = [
  {"key": "orderId", "title": "Mã Đơn Hàng"},
  {"key": "customerName", "title": "Tên Khách Hàng"},
  {"key": "dateShipping", "title": "Ngày Dự Kiến"},
  {"key": "structure", "title": "Kết Cấu Đặt Hàng"},
  {"key": "isFSC", "title": "Đơn FSC"},
  {"key": "flute", "title": "Sóng"},
  {"key": "QC_box", "title": "QC Thùng"},
  {"key": "size", "title": "Khổ"},
  {"key": "length", "title": "Dài"},
  {"key": "child", "title": "Số Con"},
  {"key": "quantityOrd", "title": "Đơn Hàng"},
  {"key": "qtyPaper", "title": "Giấy Tấm"},
  {"key": "inboundQty", "title": "Đã Nhập Kho"},

  //checked
  {"key": "inMatTruoc", "title": "Mặt Trước"},
  {"key": "inMatSau", "title": "Mặt Sau"},
  {"key": "dan_1_Manh", "title": "1 Mảnh"},
  {"key": "dan_2_Manh", "title": "2 Mảnh"},
  {"key": "dongGhim1Manh", "title": "1 Mảnh"},
  {"key": "dongGhim2Manh", "title": "2 Mảnh"},

  //statusRequest
  {"key": "statusRequest", "title": "Trạng Thái"},

  // hidden technical fields
  {"key": "planningBoxId", "title": "", "visible": false},
];

List<GridColumn> buildBoxWaitingColumn({
  required ThemeController themeController,
  required ValueNotifier<double> zoomNotifier,
}) => buildGridColumns(
  headerConfig: _headerBoxWaiting,
  themeController: themeController,
  zoomNotifier: zoomNotifier,
);

List<StackedHeaderRow> buildWaitingCheckBoxSHR({
  required ThemeController themeController,
  required double zoom,
}) {
  return [
    StackedHeaderRow(
      cells: [
        buildStackedHeaderCell(
          columnNames: ["quantityOrd", "qtyPaper", "inboundQty"],
          label: "Số Lượng",
          themeController: themeController,
          zoom: zoom,
        ),
        buildStackedHeaderCell(
          columnNames: ["inMatTruoc", "inMatSau"],
          label: "In Ấn",
          themeController: themeController,
          zoom: zoom,
        ),
        buildStackedHeaderCell(
          columnNames: ["dan_1_Manh", "dan_2_Manh"],
          label: "Dán",
          themeController: themeController,
          zoom: zoom,
        ),
        buildStackedHeaderCell(
          columnNames: ["dongGhim1Manh", "dongGhim2Manh"],
          label: "Đóng Ghim",
          themeController: themeController,
          zoom: zoom,
        ),
      ],
    ),
  ];
}
