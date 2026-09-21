import "package:dongtam/data/controller/theme_controller.dart";
import "package:dongtam/utils/helper/style_table.dart";
import "package:get/get.dart";
import "package:syncfusion_flutter_datagrid/datagrid.dart";

// Cột cố định đầu bảng: STT + Tên Tiêu Chí + Tổng (Lỗi, Tấn, Tỉ Lệ)
const List<Map<String, dynamic>> _fixedHeaderYearlyErr = [
  {"key": "index", "title": "STT"},
  {"key": "criteriaName", "title": "Tên Tiêu Chí"},
  {"key": "totalTonnage", "title": "Tổng Tấn Giấy"},
  {"key": "totalErrors", "title": "Tổng Lỗi"},
  {"key": "totalErrorRate", "title": "Tỉ Lệ (%)"},
];

List<GridColumn> buildYearlyErrProductionColumn({required ThemeController themeController}) {
  final columns = <GridColumn>[
    // Cột cố định đầu bảng
    for (var item in _fixedHeaderYearlyErr)
      GridColumn(
        columnName: item["key"]!,
        label: Obx(() => formatColumn(label: item["title"]!, themeController: themeController)),
        visible: item.containsKey("visible") ? item["visible"]! as bool : true,
      ),

    // Cột động cho 12 tháng: Tấn, Lỗi, Tỉ Lệ (‰)
    for (int m = 1; m <= 12; m++) ...[
      GridColumn(
        columnName: "m_${m}_tonnage",
        label: Obx(() => formatColumn(label: "Tấn Giấy", themeController: themeController)),
      ),
      GridColumn(
        columnName: "m_${m}_errors",
        label: Obx(() => formatColumn(label: "Số Lỗi", themeController: themeController)),
      ),
      GridColumn(
        columnName: "m_${m}_rate",
        label: Obx(() => formatColumn(label: "Tỉ Lệ (%)", themeController: themeController)),
      ),
    ],
  ];

  return columns;
}
