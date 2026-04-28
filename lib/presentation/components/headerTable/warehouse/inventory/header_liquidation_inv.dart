import 'package:dongtam/data/controller/theme_controller.dart';
import 'package:dongtam/utils/helper/style_table.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

final List<Map<String, dynamic>> _liquidationColumns = [
  {"key": "index", "title": "STT"},
  {"key": "orderId", "title": "Mã Đơn Hàng"},
  {"key": "customerName", "title": "Khách Hàng"},
  {"key": "productName", "title": "Tên Sản Phẩm"},
  {"key": "flute", "title": "Sóng"},
  {"key": "structure", "title": "Kết Cấu Đặt Hàng"},
  {"key": "size", "title": "Khổ"},
  {"key": "length", "title": "Dài"},
  {"key": "dvt", "title": "DVT"},
  {"key": "qtyTransferred", "title": "Chuyển Giao"},
  {"key": "qtySold", "title": "Đã Bán"},
  {"key": "qtyRemaining", "title": "Còn Lại"},
  {"key": "liquidationValue", "title": "Giá Trị"},
  {"key": "reason", "title": "Lý Do Thanh Lý"},
  {"key": "status", "title": "Trạng Thái"},

  //hidden
  {"key": "liquidationId", "title": "", "visible": false},
];

List<GridColumn> buildLiquidationColumn({required ThemeController themeController}) {
  return [
    for (var item in _liquidationColumns)
      GridColumn(
        columnName: item["key"]!,
        label: Obx(() => formatColumn(label: item["title"]!, themeController: themeController)),
        visible: item.containsKey("visible") ? item["visible"]! as bool : true,
      ),
  ];
}
