import 'package:dongtam/data/controller/theme_controller.dart';
import 'package:dongtam/utils/helper/style_table.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

const List<Map<String, dynamic>> _headerScrapReport = [
  {"key": "index", "title": "STT"},
  {"key": "status", "title": "Trạng Thái"},

  {"key": "reportedAt", "title": "Ngày Báo Cáo"},
  {"key": "dayCompleted", "title": "Ngày Sản Xuất"},

  {"key": "reportedBy", "title": "Người Báo Cáo"},
  {"key": "shiftProduction", "title": "Ca Sản Xuất"},

  {"key": "qtyForklift", "title": "Xe Nâng"},
  {"key": "qtyInventory", "title": "Lưu Kho"},
  {"key": "qtyCoreTube", "title": "Ống Nòng"},
  {"key": "qtyProduction", "title": "Sản Xuất"},
  {"key": "qtyOther", "title": "Khác"},
  {"key": "totalQtyScrap", "title": "Tổng Phế Liệu"},

  {"key": "machine", "title": "Loại Máy"},
  {"key": "rejectReason", "title": "Lý do"},

  //hidden field
  {"key": "scrapId", "title": "", "visible": false},
  {"key": "reportAt", "title": "", "visible": false},
];

List<GridColumn> buildScrapReportColumn({required ThemeController themeController}) {
  return [
    for (var item in _headerScrapReport)
      GridColumn(
        columnName: item["key"]!,
        label: Obx(() => formatColumn(label: item["title"]!, themeController: themeController)),
        visible: item.containsKey("visible") ? item["visible"]! as bool : true,
      ),
  ];
}
