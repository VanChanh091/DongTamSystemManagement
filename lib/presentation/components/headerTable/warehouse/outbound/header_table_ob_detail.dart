import 'package:dongtam/data/controller/theme_controller.dart';
import 'package:dongtam/utils/helper/style_table.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

const List<Map<String, dynamic>> _headerOutboundDetail = [
  {"key": "orderId", "title": "Mã Đơn Hàng"},
  {"key": "typeProduct", "title": "Loại Sản Phẩm"},
  {"key": "productName", "title": "Tên Sản Phẩm"},
  {"key": "isFSC", "title": "FSC"},
  {"key": "QC_box", "title": "QC Thùng"},
  {"key": "flute", "title": "Sóng"},
  {"key": "dvt", "title": "DVT"},
  {"key": "deliveredQty", "title": "Đã Giao"},
  {"key": "outboundQty", "title": "Số Lượng Xuất"},
  {"key": "price", "title": "Đơn Giá"},
  {"key": "discount", "title": "Chiết Khấu"},
  {"key": "totalPriceOutbound", "title": "Thành Tiền"},
  {"key": "type", "title": "Loại"},

  //hidden
  {"key": "outboundDetailId", "title": "", "visible": false},
];

List<GridColumn> buildOutboundDetailColumn({
  required ThemeController themeController,
  required ValueNotifier<double> zoomNotifier,
}) => buildGridColumns(
  headerConfig: _headerOutboundDetail,
  themeController: themeController,
  zoomNotifier: zoomNotifier,
);
