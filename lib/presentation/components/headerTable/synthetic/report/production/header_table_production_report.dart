import 'package:dongtam/data/controller/theme_controller.dart';
import 'package:dongtam/utils/helper/style_table.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

List<GridColumn> buildProductionReportColumns({
  required ThemeController themeController,
  required bool isMachine,
}) {
  final List<Map<String, dynamic>> headers = [
    {"key": "index", "title": "STT"},
    {"key": "dimensionKey", "title": isMachine ? "Máy Sản Xuất" : "Thợ Vận Hành"},
    {"key": "totalPaperTon", "title": "Tấn Giấy SD"},
    {"key": "totalLength", "title": "Số Mét Chạy"},
    {"key": "totalScrapKg", "title": "Số Kg Phế"},
    {"key": "scrapRate", "title": "% Phế Liệu"},
    {"key": "averageSpeed", "title": "Tốc Độ Máy"},
    {"key": "totalRevenue", "title": "Tổng Doanh Số"},
    if (isMachine) {"key": "fulfillmentRate", "title": "% Đạt KH"},
    {"key": "timeAdherenceRate", "title": "% tuân thủ TG/Tốc Độ"},
    {"key": "totalQcErrors", "title": "Số Lỗi"},
    {"key": "qcErrorPerTon", "title": "% Lỗi (Tấn Giấy)"},
  ];

  return [
    for (var item in headers)
      GridColumn(
        columnName: item["key"]!,
        label: Obx(() => formatColumn(label: item["title"]!, themeController: themeController)),
      ),
  ];
}
