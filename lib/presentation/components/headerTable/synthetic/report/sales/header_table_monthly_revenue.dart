import 'package:dongtam/data/controller/theme_controller.dart';
import 'package:dongtam/utils/helper/style_table.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

const List<Map<String, dynamic>> _headerMonthlyRevenue = [
  {"key": "index", "title": "STT"},
  {"key": "date", "title": "Ngày"},
  {"key": "orderApprovedAmount", "title": "DS Nhận Đơn"},
  {"key": "productionAmount", "title": "DS Sản Xuất"},
  {"key": "totalBeforeVat", "title": "Tổng Tiền (T)"},
  {"key": "totalVat", "title": "Tổng VAT"},
  {"key": "salesAmount", "title": "Tổng Tiền (S)"},
  {"key": "returnAmount", "title": "DS Trả Về"},
];

List<GridColumn> buildMonthlyRevenueColumn({
  required ThemeController themeController,
  required ValueNotifier<double> zoomNotifier,
}) => buildGridColumns(
  headerConfig: _headerMonthlyRevenue,
  themeController: themeController,
  zoomNotifier: zoomNotifier,
);

List<StackedHeaderRow> buildMonthlyRevenueSHR({
  required ThemeController themeController,
  double zoom = 1.0,
}) {
  return [
    StackedHeaderRow(
      cells: [
        buildStackedHeaderCell(
          columnNames: ["totalBeforeVat", "totalVat", "salesAmount"],
          label: "DS Bán Hàng",
          themeController: themeController,
          zoom: zoom,
        ),
      ],
    ),
  ];
}
