import 'package:dongtam/data/controller/theme_controller.dart';
import 'package:dongtam/utils/helper/style_table.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

const List<Map<String, dynamic>> _headerPaperClassification = [
  {"key": "paperCode", "title": "Mã Giấy Lưu Kho"},
  {"key": "weightCategory", "title": "Phân Loại Theo Định Lượng"},
  {"key": "paperCodeType", "title": "Loại Giấy"},
  {"key": "paperName", "title": "Tên Giấy"},

  {"key": "supplierName", "title": "Tên NCC"},
  {"key": "supplierCode", "title": "Mã NCC"},
  {"key": "companyCode", "title": "Mã Đồng Tâm"},
  {"key": "grade", "title": "Cấp Độ"},
  {"key": "basisWeight", "title": "Định Lượng"},

  {"key": "burstRatio", "title": "Tỉ Lệ Độ Bục"},
  {"key": "burstStrength", "title": "Độ Bục (kgf/cm2)"},
  {"key": "ringCrush", "title": "Độ Nén Vòng (kff/6 inch)"},
  {"key": "pricePaper", "title": "Giá Giấy (VNĐ)"},

  //hidden field
  {"key": "classificationId", "title": "", "visible": false},
];

List<GridColumn> buildPaperClassificationColumn({required ThemeController themeController}) {
  return [
    for (var item in _headerPaperClassification)
      GridColumn(
        columnName: item["key"]!,
        label: Obx(() => formatColumn(label: item["title"]!, themeController: themeController)),
        visible: item.containsKey("visible") ? item["visible"]! as bool : true,
      ),
  ];
}
