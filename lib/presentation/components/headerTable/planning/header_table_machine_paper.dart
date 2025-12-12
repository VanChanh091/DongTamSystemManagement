import 'package:dongtam/data/controller/theme_controller.dart';
import 'package:dongtam/utils/helper/style_table.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

final List<Map<String, dynamic>> _machinePaperColumns = [
  // planning
  {"key": "orderId", "title": "Mã Đơn Hàng"},
  {
    "key": "dateShipping",
    "title": "Ngày Dự Kiến",
    "visiblePages": ["planning"],
  },
  {"key": "dayStartProduction", "title": "Ngày Sản Xuất"},
  {"key": "dayCompletedProd", "title": "Ngày Hoàn Thành"},
  {"key": "customerName", "title": "Tên Khách Hàng"},
  {"key": "structure", "title": "Kết Cấu Đặt Hàng"},
  {"key": "flute", "title": "Sóng"},
  {"key": "khoCapGiay", "title": "Khổ Cấp Giấy"},
  {"key": "daoXa", "title": "Dao Xả"},
  {"key": "length", "title": "Dài"},
  {"key": "size", "title": "Khổ"},
  {"key": "child", "title": "Số Con"},
  {"key": "quantityOrd", "title": "Đơn Hàng"},
  {"key": "qtyProduced", "title": "Đã Sản Xuất"},
  {"key": "runningPlanProd", "title": "Kế Hoạch Chạy"},
  {"key": "instructSpecial", "title": "HD Đặc Biệt"},
  {"key": "timeRunningProd", "title": "Thời Gian Chạy"},
  {
    "key": "totalPrice",
    "title": "Tổng Tiền",
    "visiblePages": ["planning"],
  },
  {"key": "bottom", "title": "Đáy"},
  {"key": "fluteE", "title": "Sóng E"},
  {"key": "fluteE2", "title": "Sóng E2"},
  {"key": "fluteB", "title": "Sóng B"},
  {"key": "fluteC", "title": "Sóng C"},
  {"key": "knife", "title": "Dao"},
  {"key": "totalLoss", "title": "Tổng PL"},
  {"key": "qtyWastes", "title": "PL Thực Tế"},
  {
    "key": "shiftProduct",
    "title": "Ca Sản Xuất",
    "visiblePages": ["planning"],
  },
  {
    "key": "shiftManager",
    "title": "Trưởng Máy",
    "visiblePages": ["planning"],
  },
  {"key": "haveMadeBox", "title": "Làm Thùng?"},

  //isRequestCheck
  {"key": "statusRequest", "title": "Kiểm Hàng"},

  // hidden technical fields
  {"key": "status", "title": "", "visible": false},
  {"key": "index", "title": "Index", "visible": false},
  {"key": "planningId", "title": "", "visible": false},
];

List<GridColumn> buildMachineColumns({
  required ThemeController themeController,
  required String page,
}) {
  return [
    for (var item in _machinePaperColumns)
      if (!item.containsKey("visiblePages") || (item["visiblePages"] as List).contains(page))
        GridColumn(
          columnName: item["key"]!,
          label: Obx(() => formatColumn(label: item["title"]!, themeController: themeController)),
          visible: item.containsKey("visible") ? item["visible"]! as bool : true,
        ),
  ];
}
