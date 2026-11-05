import 'package:dongtam/data/controller/theme_controller.dart';
import 'package:dongtam/utils/helper/style_table.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

final List<Map<String, dynamic>> _liquidationColumns = [
  {"key": "index", "title": "STT"},
  {"key": "orderId", "title": "Mã Đơn Hàng"},
  {"key": "customerName", "title": "Khách Hàng"},
  {"key": "productName", "title": "Tên Sản Phẩm"},
  {"key": "flute", "title": "Sóng"},
  {"key": "structure", "title": "Kết Cấu Đặt Hàng"},
  {"key": "size", "title": "Khổ"},
  {"key": "length", "title": "Dài"},
  {"key": "dvt", "title": "DVT"},
  {"key": "qtyTransferred", "title": "Chuyển Giao"},
  {"key": "qtySold", "title": "Đã Bán"},
  {"key": "qtyRemaining", "title": "Còn Lại"},
  {"key": "liquidationValue", "title": "Giá Trị"},
  {"key": "reason", "title": "Lý Do Thanh Lý"},
  {"key": "status", "title": "Trạng Thái"},

  //hidden
  {"key": "liquidationId", "title": "", "visible": false},
];

List<GridColumn> buildLiquidationColumn({
  required ThemeController themeController,
  required ValueNotifier<double> zoomNotifier,
}) => buildGridColumns(
  headerConfig: _liquidationColumns,
  themeController: themeController,
  zoomNotifier: zoomNotifier,
);

List<StackedHeaderRow> buildLiquidationSHR({
  required ThemeController themeController,
  required double zoom,
}) {
  return [
    StackedHeaderRow(
      cells: [
        buildStackedHeaderCell(
          columnNames: ["qtyTransferred", "qtySold", "qtyRemaining"],
          label: "Số Lượng",
          themeController: themeController,
          zoom: zoom,
        ),
      ],
    ),
  ];
}
