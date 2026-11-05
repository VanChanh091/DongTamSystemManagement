import 'package:dongtam/data/controller/theme_controller.dart';
import 'package:dongtam/utils/helper/style_table.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

final List<Map<String, dynamic>> _layerRequirementColumns = [
  {"key": "paperCode", "title": "Mã Giấy"},
  {"key": "layerRole", "title": "Vị Trí Lớp Giấy"},
  {"key": "weightGsm", "title": "Định Lượng (gsm)"},
  {"key": "fluteType", "title": "Loại Sóng"},
  {"key": "availableStock", "title": "Tồn Kho"},
  {"key": "shortageQty", "title": "Số Lượng Thiếu"},
  {"key": "isEnoughQty", "title": "Đủ Số Lượng?"},

  // hidden technical fields
  {"key": "layerId", "title": "", "visible": false},
];

List<GridColumn> buildLayerRequirementColumns({
  required ThemeController themeController,
  required ValueNotifier<double> zoomNotifier,
}) => buildGridColumns(
  headerConfig: _layerRequirementColumns,
  themeController: themeController,
  zoomNotifier: zoomNotifier,
);
