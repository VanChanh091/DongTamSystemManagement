import 'package:dongtam/data/controller/theme_controller.dart';
import 'package:dongtam/utils/helper/style_table.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

final List<Map<String, dynamic>> _reportPaperColumns = [
  {"key": "index", "title": "STT"},
  {"key": "orderId", "title": "Mã Đơn Hàng"},
  {"key": "customerName", "title": "Tên Khách Hàng"},

  {"key": "dayStartProduction", "title": "Ngày Sản Xuất"},
  {"key": "dayReported", "title": "Ngày Báo Cáo"},

  {"key": "structure", "title": "Kết Cấu Đặt Hàng"},
  {"key": "flute", "title": "Sóng"},
  {"key": "daoXa", "title": "Dao Xả"},

  {"key": "size", "title": "Khổ (cm)"},
  {"key": "length", "title": "Dài (cm)"},
  {"key": "numberChild", "title": "Số Con"},
  {"key": "khoCapGiay", "title": "Khổ Cấp Giấy"},

  {"key": "runningPlanProd", "title": "Kế Hoạch Chạy"},
  {"key": "qtyReported", "title": "SL Báo Cáo"},
  {"key": "lackOfQty", "title": "Thiếu/Đủ SL"},

  {"key": "timeRunningProd", "title": "Thời Gian Chạy"},
  {"key": "averageSpeed", "title": "Hiệu Suất (m/p)"},
  {"key": "dvt", "title": "DVT"},

  {"key": "HD_special", "title": "HD Đặc Biệt"},

  //waste norm
  {"key": "bottom", "title": "Đáy"},
  {"key": "fluteE", "title": "Sóng E"},
  {"key": "fluteB", "title": "Sóng B"},
  {"key": "fluteC", "title": "Sóng C"},
  {"key": "knife", "title": "Dao"},
  {"key": "totalLoss", "title": "Tổng PL"},
  {"key": "qtyWasteRp", "title": "PL Báo Cáo"},

  {"key": "shiftProduction", "title": "Ca SX"},
  {"key": "shiftManager", "title": "Trưởng Máy"},
  {"key": "reportedBy", "title": "Người Báo Cáo"},

  // box
  {"key": "hasMadeBox", "title": "Làm Thùng?"},

  //hidden fields
  {"key": "reportPaperId", "title": "", "visible": false},
  {"key": "dateTimeRp", "title": "", "visible": false},
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
