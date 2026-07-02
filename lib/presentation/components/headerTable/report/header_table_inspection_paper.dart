import 'package:dongtam/data/controller/theme_controller.dart';
import 'package:dongtam/utils/helper/style_table.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

final List<Map<String, dynamic>> _inspectionPaperColumns = [
  {"key": "index", "title": "STT"},

  //hidden fields
  {"key": "inspecPaperId", "title": "", "visible": false},
];

List<GridColumn> buildInspectionPaperColumn({required ThemeController themeController}) {
  return [
    for (var item in _inspectionPaperColumns)
      GridColumn(
        columnName: item["key"]!,
        label: Obx(() => formatColumn(label: item["title"]!, themeController: themeController)),
        visible: item.containsKey("visible") ? item["visible"]! as bool : true,
      ),
  ];
}
