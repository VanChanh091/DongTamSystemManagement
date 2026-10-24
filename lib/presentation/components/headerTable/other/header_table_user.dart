import 'package:dongtam/data/controller/theme_controller.dart';
import 'package:dongtam/utils/helper/style_table.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

const List<Map<String, dynamic>> _headerCustomer = [
  {"key": "fullName", "title": "Họ Tên"},
  {"key": "email", "title": "Email"},
  {"key": "sex", "title": "Giới Tính"},
  {"key": "phone", "title": "Số Điện Thoại"},
  {"key": "role", "title": "Vai Trò"},
  {"key": "permission", "title": "Quyền Truy Cập"},
  {"key": "avatar", "title": "Hình Đại Diện"},
];

List<GridColumn> buildUserColumns({required ThemeController themeController}) {
  return [
    for (var item in _headerCustomer)
      GridColumn(
        columnName: item["key"]!,
        label: Obx(() => formatColumn(label: item["title"]!, themeController: themeController)),
        visible: item.containsKey("visible") ? item["visible"]! as bool : true,
      ),
  ];
}
