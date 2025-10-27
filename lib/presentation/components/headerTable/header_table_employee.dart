import 'package:dongtam/data/controller/theme_controller.dart';
import 'package:dongtam/utils/helper/style_table.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

const List<Map<String, dynamic>> headerCustomer = [
  {"key": "employeeId", "title": "", "visible": false},
  {"key": "employeeCode", "title": "Mã Nhân Viên"},
  {"key": "fullName", "title": "Tên Nhân Viên"},
  {"key": "joinDate", "title": "Ngày Vào Làm"},
  {"key": "department", "title": "Bộ Phận"},
  {"key": "position", "title": "Chức Vụ"},
  {"key": "gender", "title": "Giới Tính"},
  {"key": "birthday", "title": "Ngày Sinh"},
  {"key": "birthPlace", "title": "Nơi Sinh"},
  {"key": "homeTown", "title": "Nguyên Quán"},
  {"key": "citizenId", "title": "Số CCCD"},
  {"key": "citizenDate", "title": "Ngày Cấp"},
  {"key": "citizenIssuedPlace", "title": "Nơi Cấp"},
  {"key": "permanentAddress", "title": "ĐC Thường Trú"},
  {"key": "temporaryAddress", "title": "ĐC Tạm Trú"},
  {"key": "ethnicity", "title": "Dân Tộc"},
  {"key": "educationLevel", "title": "Trình Độ Văn Hóa"},
  {"key": "educationSystem", "title": "Hệ Đào Tạo"},
  {"key": "major", "title": "Ngành Học"},
  {"key": "phoneNumber", "title": "Số Điện Thoại"},
  {"key": "emergencyPhone", "title": "SDT (Khẩn Cấp)"},
  {"key": "status", "title": "Tình Trạng"},
];

List<GridColumn> buildEmployeeColumn({required ThemeController themeController}) {
  return [
    for (var item in headerCustomer)
      GridColumn(
        columnName: item["key"]!,
        label: Obx(() => formatColumn(label: item["title"]!, themeController: themeController)),
        visible: item.containsKey("visible") ? item["visible"]! as bool : true,
      ),
  ];
}
