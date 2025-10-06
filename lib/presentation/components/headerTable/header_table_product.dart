import 'package:dongtam/data/controller/theme_controller.dart';
import 'package:dongtam/utils/helper/style_table.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

const List<Map<String, dynamic>> headerProduct = [
  {"key": "stt", "title": "STT"},
  {"key": "productId", "title": "Mã Sản Phẩm"},
  {"key": "typeProduct", "title": "Loại Sản Phẩm"},
  {"key": "productName", "title": "Tên Sản Phẩm"},
  {"key": "maKhuon", "title": "Mã Khuôn"},
  {"key": "imageProduct", "title": "Hình ảnh"},
];

double? getColumnWidth(String key) {
  if (key == "stt") return 60;
  if (key == "imageProduct") return 150;
  return double.nan;
}

List<GridColumn> buildProductColumn({
  required ThemeController themeController,
}) {
  return [
    for (var item in headerProduct)
      GridColumn(
        columnName: item["key"]!,
        width: getColumnWidth(item["key"]!) ?? double.nan,
        label: Obx(
          () => formatColumn(
            label: item["title"]!,
            themeController: themeController,
          ),
        ),
      ),
  ];
}
