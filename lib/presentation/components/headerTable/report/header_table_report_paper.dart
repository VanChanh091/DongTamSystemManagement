import 'package:dongtam/data/controller/theme_controller.dart';
import 'package:dongtam/utils/helper/style_table.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

final List<Map<String, dynamic>> _reportPaperColumns = [
  {"key": "orderId", "title": "Mã Đơn Hàng"},
  {"key": "reportPaperId", "title": "", "visible": false},
  {"key": "customerName", "title": "Tên Khách Hàng"},
  {"key": "dateShipping", "title": "Ngày Dự Kiến"},
  {"key": "dayStartProduction", "title": "Ngày Sản Xuất"},
  {"key": "dayReported", "title": "Ngày Báo Cáo"},
  {"key": "dateTimeRp", "title": "", "visible": false},
  {"key": "structure", "title": "Kết Cấu Đặt Hàng"},
  {"key": "flute", "title": "Sóng"},
  {"key": "daoXa", "title": "Dao Xả"},
  {"key": "length", "title": "Dài"},
  {"key": "size", "title": "Khổ"},
  {"key": "child", "title": "Số Con"},
  {"key": "khoCapGiay", "title": "Khổ Cấp Giấy"},
  {"key": "quantityOrd", "title": "SL Đơn Hàng"},
  {"key": "runningPlanProd", "title": "Kế Hoạch Chạy"},
  {"key": "qtyReported", "title": "SL Báo Cáo"},
  {"key": "lackOfQty", "title": "Thiếu/Đủ SL"},
  {"key": "timeRunningProd", "title": "Thời Gian Chạy"},
  {"key": "HD_special", "title": "HD Đặc Biệt"},
  {"key": "totalPrice", "title": "Doanh thu"},

  // waste norm
  {"key": "bottom", "title": "Đáy"},
  {"key": "fluteE", "title": "Sóng E"},
  {"key": "fluteB", "title": "Sóng B"},
  {"key": "fluteC", "title": "Sóng C"},
  {"key": "knife", "title": "Dao"},
  {"key": "totalLoss", "title": "Tổng PL"},
  {"key": "qtyWasteRp", "title": "PL Báo Cáo"},
  {"key": "shiftProduct", "title": "Ca Sản Xuất"},
  {"key": "shiftManager", "title": "Trưởng Máy"},

  // box
  {"key": "hasMadeBox", "title": "Làm Thùng?"},
];

List<GridColumn> buildReportPaperColumn({required ThemeController themeController}) {
  return [
    for (var item in _reportPaperColumns)
      GridColumn(
        columnName: item["key"]!,
        label: Obx(() => formatColumn(label: item["title"]!, themeController: themeController)),
        visible: item.containsKey("visible") ? item["visible"]! as bool : true,
      ),
  ];
}
