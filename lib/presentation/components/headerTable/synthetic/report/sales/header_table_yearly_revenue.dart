import "package:dongtam/data/controller/theme_controller.dart";
import "package:dongtam/utils/helper/style_table.dart";
import "package:get/get.dart";
import "package:syncfusion_flutter_datagrid/datagrid.dart";

// Cột cố định (không phụ thuộc vào danh sách năm)
const List<Map<String, dynamic>> _fixedHeaderYearlyRevenue = [
  {"key": "index", "title": "STT"},
  {"key": "customerName", "title": "Tên Khách Hàng"},
  {"key": "currentDebt", "title": "Công Nợ"},
  {"key": "grandTotal", "title": "Tổng Cộng"},

  //hidden
  {"key": "customerId", "title": "", "visible": false},
];

List<GridColumn> buildYearlyRevenueColumn({
  required ThemeController themeController,
  List<int> years = const [],
}) {
  final columns = <GridColumn>[
    // Cột cố định đầu bảng
    for (var item in _fixedHeaderYearlyRevenue)
      GridColumn(
        columnName: item["key"]!,
        label: Obx(() => formatColumn(label: item["title"]!, themeController: themeController)),
        visible: item.containsKey("visible") ? item["visible"]! as bool : true,
      ),

    // Cột động: 12 tháng + tổng cho mỗi năm
    for (final y in years) ...[
      for (int m = 1; m <= 12; m++)
        GridColumn(
          columnName: "y_${y}_m_$m",
          label: Obx(() => formatColumn(label: "T$m", themeController: themeController)),
        ),
      GridColumn(
        columnName: "y_${y}_total",
        label: Obx(() => formatColumn(label: "Tổng $y", themeController: themeController)),
      ),
    ],
  ];

  return columns;
}
