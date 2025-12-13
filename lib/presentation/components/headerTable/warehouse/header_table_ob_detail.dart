import 'package:dongtam/data/controller/theme_controller.dart';
import 'package:dongtam/utils/helper/style_table.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

const List<Map<String, dynamic>> _headerOutboundDetail = [
  {"key": "orderId", "title": "Mã Đơn Hàng"},
  {"key": "typeProduct", "title": "Loại Sản Phẩm"},
  {"key": "productName", "title": "Tên Sản Phẩm"},
  {"key": "QC_box", "title": "QC Thùng"},
  {"key": "flute", "title": "Sóng"},
  {"key": "dvt", "title": "DVT"},
  {"key": "deliveredQty", "title": "Đã Giao"},
  {"key": "outboundQty", "title": "Số Lượng Xuất"},
  {"key": "price", "title": "Giá Tiền"},
  {"key": "discount", "title": "Chiết Khấu"},
  {"key": "totalPriceOutbound", "title": "Thành Tiền"},

  //hidden
  {"key": "outboundDetailId", "title": "", "visible": false},
];

List<GridColumn> buildOutboundDetailColumn({required ThemeController themeController}) {
  return [
    for (var item in _headerOutboundDetail)
      GridColumn(
        columnName: item["key"]!,
        label: Obx(() => formatColumn(label: item["title"]!, themeController: themeController)),
        visible: item.containsKey("visible") ? item["visible"]! as bool : true,
      ),
  ];
}
