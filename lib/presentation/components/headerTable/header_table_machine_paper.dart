import 'package:dongtam/data/controller/theme_controller.dart';
import 'package:dongtam/utils/helper/style_table.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

const List<Map<String, dynamic>> _headerMachinePaper = [
  {"key": "changeDiffSize", "title": "Khác khổ"},
  {"key": "changeSameSize", "title": "Cùng khổ"},
  {"key": "speed2Layer", "title": "2 Lớp"},
  {"key": "speed3Layer", "title": "3 Lớp"},
  {"key": "speed4Layer", "title": "4 Lớp"},
  {"key": "speed5Layer", "title": "5 Lớp"},
  {"key": "speed6Layer", "title": "6 Lớp"},
  {"key": "speed7Layer", "title": "7 Lớp"},
  {"key": "machineRollPaper", "title": "Quấn Cuồn"},
  {"key": "efficiency", "title": "Hiệu Suất"},
  {"key": "machineName", "title": "Tên Máy"},
  {"key": "type", "title": "Loại"},

  //hidden field
  {"key": "machineId", "title": "", "visible": false},
];

List<GridColumn> buildMachinePaperColumn({required ThemeController themeController}) {
  return [
    for (var item in _headerMachinePaper)
      GridColumn(
        columnName: item["key"]!,
        label: Obx(() => formatColumn(label: item["title"]!, themeController: themeController)),
        visible: item.containsKey("visible") ? item["visible"]! as bool : true,
      ),
  ];
}
