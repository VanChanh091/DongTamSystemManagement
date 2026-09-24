import 'package:dongtam/data/controller/theme_controller.dart';
import 'package:dongtam/utils/helper/style_table.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

final List<Map<String, dynamic>> _paperRequirementColumns = [
  {"key": "orderId", "title": "Mã Đơn Hàng"},
  {"key": "customerName", "title": "Tên Khách Hàng"},
  {"key": "dateRequestShipping", "title": "Ngày Dự Kiến"},

  {"key": "structure", "title": "Kết Cấu Đặt Hàng"},
  {"key": "isFSC", "title": "Đơn FSC"},
  {"key": "flute", "title": "Sóng"},
  {"key": "ghepKho", "title": "Khổ Cấp Giấy"},
  {"key": "sizePaper", "title": "Khổ (cm)"},
  {"key": "lengthPaper", "title": "Dài (cm)"},
  {"key": "runningPlan", "title": "Kế hoạch Chạy"},
  {"key": "totalRequiredQty", "title": "Khối Lượng Cần (kg)"},
  {"key": "totalPrice", "title": "Tổng Tiền (VNĐ)"},

  {"key": "chooseMachine", "title": "Loại Máy"},
  {"key": "inventoryStatus", "title": "Trạng Thái Kho"},

  // hidden technical fields
  {"key": "requirementId", "title": "", "visible": false},
  {"key": "dayStart", "title": "Ngày Sản Xuất", "visible": false},
];

List<GridColumn> buildPaperRequirementColumns({required ThemeController themeController}) {
  return [
    for (var item in _paperRequirementColumns)
      GridColumn(
        columnName: item['key']!,
        label: Obx(() => formatColumn(label: item['title']!, themeController: themeController)),
        visible: item.containsKey("visible") ? item["visible"]! as bool : true,
      ),
  ];
}
