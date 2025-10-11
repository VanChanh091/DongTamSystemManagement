import 'package:dongtam/data/controller/theme_controller.dart';
import 'package:dongtam/utils/helper/style_table.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

final List<Map<String, dynamic>> machinePaperColumns = [
  // planning
  {"key": "orderId", "title": "Mã Đơn Hàng"},
  {"key": "customerName", "title": "Tên Khách Hàng"},
  {"key": "dateShipping", "title": "Ngày Dự Kiến Giao"},
  {"key": "structure", "title": "Kết Cấu Đặt Hàng"},
  {"key": "flute", "title": "Sóng"},
  {"key": "daoXa", "title": "Dao Xả"},
  {"key": "length", "title": "Dài"},
  {"key": "size", "title": "Khổ"},
  {"key": "child", "title": "Số Con"},
  {"key": "khoCapGiay", "title": "Khổ Cấp Giấy"},
  {"key": "timeRunningProd", "title": "Thời Gian Chạy"},
  {"key": "quantityOrd", "title": "Đơn Hàng"},
  {"key": "qtyProduced", "title": "Đã Sản Xuất"},
  {"key": "runningPlanProd", "title": "Kế Hoạch Chạy"},
  {"key": "HD_special", "title": "HD Đặc Biệt"},
  {"key": "totalPrice", "title": "Tổng Tiền"},
  {"key": "totalPriceAfterVAT", "title": "Tổng Tiền Sau VAT"},
  {"key": "bottom", "title": "Đáy"},
  {"key": "fluteE", "title": "Sóng E"},
  {"key": "fluteB", "title": "Sóng B"},
  {"key": "fluteC", "title": "Sóng C"},
  {"key": "knife", "title": "Dao"},
  {"key": "totalLoss", "title": "Tổng PL"},
  {"key": "qtyWastes", "title": "PL Thực Tế"},
  {"key": "shiftProduct", "title": "Ca Sản Xuất"},
  {"key": "shiftManager", "title": "Trưởng Máy"},
  {"key": "haveMadeBox", "title": "Làm Thùng?"},

  // hidden technical fields
  {"key": "status", "title": "", "visible": false},
  {"key": "index", "title": "Index", "visible": false},
  {"key": "planningId", "title": "", "visible": false},
  {"key": "dayStartProduction", "title": "Ngày Sản Xuất", "visible": false},
  {"key": "dayCompletedProd", "title": "Ngày Hoàn Thành", "visible": false},
];

List<GridColumn> buildMachineColumns({
  required ThemeController themeController,
}) {
  return [
    for (var item in machinePaperColumns)
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
