import 'package:dongtam/data/controller/theme_controller.dart';
import 'package:dongtam/utils/helper/style_table.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

const List<Map<String, dynamic>> _headerScrapReport = [
  {"key": "index", "title": "STT"},
  {"key": "createdAt", "title": "Ngày Tạo"},
];

List<GridColumn> buildScrapReportColumn({required ThemeController themeController}) {
  return [
    for (var item in _headerScrapReport)
      GridColumn(
        columnName: item["key"]!,
        label: Obx(() => formatColumn(label: item["title"]!, themeController: themeController)),
        visible: item.containsKey("visible") ? item["visible"]! as bool : true,
      ),
  ];
}
