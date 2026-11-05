import 'package:dongtam/data/controller/theme_controller.dart';
import 'package:dongtam/utils/helper/style_table.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

// Cột cố định đầu bảng
const List<Map<String, dynamic>> _fixedStartHeaders = [
  {"key": "index", "title": "STT"},
  {"key": "machine", "title": "Tên Máy"},
  {"key": "employeeName", "title": "Tên Nhân Viên"},
  {"key": "totalErrors", "title": "Tổng Lỗi"},
];

List<GridColumn> buildMonthlyErrProductionColumn({
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

List<StackedHeaderRow> buildMonthlyErrProductionSHR({
  required ThemeController themeController,
  required int effectiveDaysInMonth,
  double zoom = 1.0,
}) {
  return [
    StackedHeaderRow(
      cells: [
        buildStackedHeaderCell(
          columnNames: List.generate(effectiveDaysInMonth, (i) => 'd_${i + 1}'),
          label: 'Ngày Trong Tháng',
          themeController: themeController,
          zoom: zoom,
        ),
      ],
    ),
  ];
}
