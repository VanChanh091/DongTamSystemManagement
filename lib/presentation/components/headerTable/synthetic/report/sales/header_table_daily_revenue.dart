import 'package:dongtam/data/controller/theme_controller.dart';
import 'package:dongtam/utils/helper/style_table.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

// Cột cố định đầu bảng
const List<Map<String, dynamic>> _fixedStartHeaders = [
  {"key": "index", "title": "STT"},
  {"key": "customerName", "title": "Tên Khách Hàng"},
  {"key": "totalDebt", "title": "Công Nợ"},
  {"key": "totalSales", "title": "Tổng Tiền"},

  //hidden
  {"key": "customerId", "title": "", "visible": false},
];

List<GridColumn> buildDailyRevenueColumn({
  required ThemeController themeController,
  required ValueNotifier<double> zoomNotifier,
  int daysInMonth = 31,
}) => buildGridColumns(
  headerConfig: [
    ..._fixedStartHeaders,
    for (int d = 1; d <= daysInMonth; d++)
      {"key": "d_$d", "title": "$d"},
  ],
  themeController: themeController,
  zoomNotifier: zoomNotifier,
);

List<StackedHeaderRow> buildDailyRevenueSHR({
  required ThemeController themeController,
  required int daysInMonth,
  double zoom = 1.0,
}) {
  return [
    StackedHeaderRow(
      cells: [
        buildStackedHeaderCell(
          columnNames: List.generate(daysInMonth, (i) => "d_${i + 1}"),
          label: "Ngày Trong Tháng",
          themeController: themeController,
          zoom: zoom,
        ),
      ],
    ),
  ];
}
