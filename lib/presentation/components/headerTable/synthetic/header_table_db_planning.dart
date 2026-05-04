import 'package:dongtam/data/controller/theme_controller.dart';
import 'package:dongtam/utils/helper/style_table.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

const List<Map<String, dynamic>> _headerDbPaper = [
  // Order
  {"key": "index", "title": "STT"},
  {"key": "orderId", "title": "Mã Đơn Hàng"},

  // Customer & Product
  {"key": "customerName", "title": "Tên Khách Hàng"},
  {"key": "productName", "title": "Tên SP"},

  //structure
  {"key": "structure", "title": "Kết Cấu Đặt Hàng"},

  //day
  {"key": "dayReceive", "title": "Nhận Đơn"},
  {"key": "dayStartProduction", "title": "Sản Xuất"},
  {"key": "dayCompletedProd", "title": "Hoàn Thành"},
  {"key": "dayCompletedOvfl", "title": "Hoàn Thành (Tràn)"},

  //other fields
  {"key": "flute", "title": "Sóng"},
  {"key": "khoCapGiay", "title": "Khổ Cấp Giấy"},
  {"key": "QcBox", "title": "QC Thùng"},
  {"key": "daoXa", "title": "Dao Xả"},
  {"key": "size", "title": "Khổ"},
  {"key": "length", "title": "Dài"},
  {"key": "child", "title": "Số Con"},

  // Quantity
  {"key": "quantityOrd", "title": "Đơn Hàng"},
  {"key": "qtyProduced", "title": "Đã Sản Xuất"},
  {"key": "runningPlanProd", "title": "Kế Hoạch Chạy"},
  {"key": "qtyInventory", "title": "Tồn Kho"},

  //time running
  {"key": "timeRunningProd", "title": "Chạy"},
  {"key": "timeRunningOvfl", "title": "Tràn"},

  {"key": "instructSpecial", "title": "HD Đặc Biệt"},
  {"key": "dvt", "title": "DVT"},

  //Waste
  {"key": "bottom", "title": "Đáy"},
  {"key": "fluteE", "title": "Sóng E"},
  {"key": "fluteE2", "title": "Sóng E2"},
  {"key": "fluteB", "title": "Sóng B"},
  {"key": "fluteC", "title": "Sóng C"},
  {"key": "knife", "title": "Dao"},
  {"key": "totalLoss", "title": "Tổng PL"},

  // Sản xuất
  {"key": "qtyWastes", "title": "PL Thực Tế"},
  {"key": "shiftProduct", "title": "Ca Sản Xuất"},
  {"key": "shiftManager", "title": "Trưởng Máy"},
  {"key": "machine", "title": "Loại Máy"},

  {"key": "chongTham", "title": "Chống Thấm"},
  {"key": "isBox", "title": "Làm Thùng?"},

  // Hidden
  {"key": "planningId", "title": "", "visible": false},
];

List<GridColumn> buildDbPaperColumn({
  required ThemeController themeController,
  required String page,
}) {
  return [
    for (var item in _headerDbPaper)
      if (!item.containsKey("visiblePages") || (item["visiblePages"] as List).contains(page))
        GridColumn(
          columnName: item["key"]!,
          label: Obx(() => formatColumn(label: item["title"]!, themeController: themeController)),
          visible: item.containsKey("visible") ? item["visible"]! as bool : true,
        ),
  ];
}
