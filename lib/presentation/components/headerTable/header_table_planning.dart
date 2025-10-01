import 'package:dongtam/data/controller/theme_controller.dart';
import 'package:dongtam/utils/helper/style_table.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

final List<Map<String, dynamic>> planningColumns = [
  // order
  {"key": "orderId", "title": "Mã Đơn Hàng"},
  {"key": "dateRequestShipping", "title": "Ngày YC Giao"},
  {"key": "companyName", "title": "Tên Công Ty"},
  {"key": "typeProduct", "title": "Loại SP"},
  {"key": "productName", "title": "Tên SP"},
  {"key": "flute", "title": "Sóng"},
  {"key": "QC_box", "title": "QC Thùng"},
  {"key": "structure", "title": "Kết Cấu Đặt Hàng"},
  {"key": "canLan", "title": "Cấn Lằn"},
  {"key": "daoXa", "title": "Dao Xả"},
  {"key": "lengthMf", "title": "Dài (SX)"},
  {"key": "sizeManufacture", "title": "Khổ (SX)"},
  {"key": "qtyManufacture", "title": "Số Lượng (SX)"},
  {"key": "instructSpecial", "title": "HD Đặc Biệt"},
  {"key": "haveMadeBox", "title": "Làm Thùng?"},
  {"key": "totalPrice", "title": "Doanh thu"},
];

List<GridColumn> buildColumnPlanning({
  required ThemeController themeController,
}) {
  return [
    for (var item in planningColumns)
      GridColumn(
        columnName: item["key"]!,
        label: Obx(
          () => formatColumn(
            label: item["title"]!,
            themeController: themeController,
          ),
        ),
        visible: item.containsKey("visible") ? item["visible"]! as bool : true,
      ),
  ];
}
