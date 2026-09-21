import 'package:dongtam/data/controller/theme_controller.dart';
import 'package:dongtam/utils/helper/style_table.dart';
import 'package:get/get.dart';
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
  int daysInMonth = 31,
}) {
  return [
    // Cột cố định đầu
    for (var item in _fixedStartHeaders)
      GridColumn(
        columnName: item["key"]!,
        label: Obx(() => formatColumn(label: item["title"]!, themeController: themeController)),
        visible: item.containsKey("visible") ? item["visible"]! as bool : true,
      ),

    // Cột động: ngày 1 → daysInMonth
    for (int d = 1; d <= daysInMonth; d++)
      GridColumn(
        columnName: 'd_$d',
        label: Obx(() => formatColumn(label: '$d', themeController: themeController)),
      ),
  ];
}
