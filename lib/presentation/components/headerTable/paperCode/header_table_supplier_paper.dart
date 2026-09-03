import 'package:dongtam/data/controller/theme_controller.dart';
import 'package:dongtam/utils/helper/style_table.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

const List<Map<String, dynamic>> _headerSupplierPaperCode = [
  {"key": "supplierCode", "title": "Mã Nhà Cung Cấp"},
  {"key": "companyCode", "title": "Mã Đồng Tâm"},
  {"key": "layerType", "title": "Loại Giấy"},
  {"key": "paperName", "title": "Tên Giấy"},
  {"key": "paperCode", "title": "Mã Giấy"},
  {"key": "grade", "title": "Cấp Độ"},
  {"key": "supplierName", "title": "Tên NCC"},

  //hidden field
  {"key": "supplierPaperId", "title": "", "visible": false},
  {"key": "supplierId", "title": "", "visible": false},
];

List<GridColumn> buildSupplierPaperColumn({required ThemeController themeController}) {
  return [
    for (var item in _headerSupplierPaperCode)
      GridColumn(
        columnName: item["key"]!,
        label: Obx(() => formatColumn(label: item["title"]!, themeController: themeController)),
        visible: item.containsKey("visible") ? item["visible"]! as bool : true,
      ),
  ];
}
