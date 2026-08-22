import 'package:dongtam/data/controller/theme_controller.dart';
import 'package:dongtam/utils/helper/style_table.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

final List<Map<String, dynamic>> _layerRequirementColumns = [
  {"key": "paperCode", "title": "Mã Giấy"},
  {"key": "layerRole", "title": "Vị Trí Lớp"},
  {"key": "weightGsm", "title": "Trọng Lượng (gsm)"},
  {"key": "fluteType", "title": "Loại Sóng"},
  {"key": "paperRollWidth", "title": "Khổ Cấp Giấy"},
  {"key": "availableStock", "title": "Tồn Kho"},
  {"key": "shortageQty", "title": "Số Lượng Thiếu"},
  {"key": "isEnoughQty", "title": "Đủ Số Lượng?"},

  // hidden technical fields
  {"key": "layerId", "title": "", "visible": false},
];

List<GridColumn> buildLayerRequirementColumns({required ThemeController themeController}) {
  return [
    for (var item in _layerRequirementColumns)
      GridColumn(
        columnName: item['key']!,
        label: Obx(() => formatColumn(label: item['title']!, themeController: themeController)),
        visible: item.containsKey("visible") ? item["visible"]! as bool : true,
      ),
  ];
}
