import 'package:dongtam/data/controller/theme_controller.dart';
import 'package:dongtam/utils/helper/style_table.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

const List<Map<String, dynamic>> _headerBoxWaiting = [
  {"key": "orderId", "title": "Mã Đơn Hàng"},
  {"key": "customerName", "title": "Tên Khách Hàng"},
  {"key": "dateShipping", "title": "Ngày Dự Kiến"},
  {"key": "structure", "title": "Kết Cấu Đặt Hàng"},
  {"key": "flute", "title": "Sóng"},
  {"key": "QC_box", "title": "QC Thùng"},
  {"key": "length", "title": "Dài"},
  {"key": "size", "title": "Khổ"},
  {"key": "child", "title": "Số Con"},
  {"key": "quantityOrd", "title": "Đơn Hàng"},
  {"key": "qtyPaper", "title": "Giấy Tấm"},
  {"key": "inboundQty", "title": "Đã Nhập Kho"},

  //checked
  {"key": "inMatTruoc", "title": "Mặt Trước"},
  {"key": "inMatSau", "title": "Mặt Sau"},
  {"key": "dan_1_Manh", "title": "1 Mảnh"},
  {"key": "dan_2_Manh", "title": "2 Mảnh"},
  {"key": "dongGhim1Manh", "title": "1 Mảnh"},
  {"key": "dongGhim2Manh", "title": "2 Mảnh"},

  //statusRequest
  {"key": "statusRequest", "title": "Trạng Thái"},

  // hidden technical fields
  {"key": "planningBoxId", "title": "", "visible": false},
];

List<GridColumn> buildBoxWaitingColumn({required ThemeController themeController}) {
  return [
    for (var item in _headerBoxWaiting)
      GridColumn(
        columnName: item["key"]!,
        label: Obx(() => formatColumn(label: item["title"]!, themeController: themeController)),
        visible: item.containsKey("visible") ? item["visible"]! as bool : true,
      ),
  ];
}
