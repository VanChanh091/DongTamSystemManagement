import 'package:dongtam/data/controller/theme_controller.dart';
import 'package:dongtam/utils/helper/style_table.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

const List<Map<String, dynamic>> _headerDeliverySchedule = [
  //order
  {"key": "orderId", "title": "Mã Đơn Hàng"},
  {"key": "orderIdCus", "title": "Mã PO"},
  {
    "key": "licensePlate",
    "title": "Biển Số Xe",
    "visiblePages": ["prepare"],
  },
  {"key": "status", "title": "Trạng Thái"},
  {"key": "customerName", "title": "Khách Hàng"},
  {"key": "productName", "title": "Tên Sản Phẩm"},

  {"key": "QC_box", "title": "Quy Cách"},
  {"key": "structure", "title": "Kết Cấu Đặt Hàng"},
  {"key": "isFSC", "title": "Đơn FSC"},

  {"key": "sizeProd", "title": "Khổ (SX)"},
  {"key": "lengthProd", "title": "Dài (SX)"},

  {"key": "qtyCustomer", "title": "Đơn Hàng"},
  {"key": "totalQtyOutbound", "title": "Tổng Xuất"},
  {"key": "qtyRegistered", "title": "Yêu Cầu"},
  {"key": "qtyOutbound", "title": "Đã Xuất"},

  {"key": "note", "title": "Ghi Chú"},
  {"key": "dvt", "title": "DVT"},
  {"key": "volume", "title": "Khối Lượng"},
  {"key": "vehicleHouse", "title": "Nhà Xe"},

  //hidden field
  {"key": "deliveryId", "title": "Mã Giao Hàng", "visible": false},
  {"key": "deliveryItemId", "title": "", "visible": false},
  {"key": "deliveryDate", "title": "Ngày Giao Hàng", "visible": false},
  {"key": "vehicleName", "title": "Tên Xe", "visible": false},
  {"key": "sequence", "title": "Tài", "visible": false},
];

List<GridColumn> buildDeliveryScheduleColumn({
  required ThemeController themeController,
  required ValueNotifier<double> zoomNotifier,
  required String page,
}) => buildGridColumns(
  headerConfig: _headerDeliverySchedule,
  themeController: themeController,
  zoomNotifier: zoomNotifier,
  page: page,
);

List<StackedHeaderRow> buildDeliveryScheduleSHR({
  required ThemeController themeController,
  required double zoom,
  String page = "schedule",
}) {
  return [
    StackedHeaderRow(
      cells: [
        buildStackedHeaderCell(
          columnNames:
              page == "prepare"
                  ? ["qtyRegistered", "qtyOutbound"]
                  : ["qtyRegistered", "qtyOutbound", "qtyCustomer", "totalQtyOutbound"],
          label: "Số Lượng",
          themeController: themeController,
          zoom: zoom,
        ),
      ],
    ),
  ];
}
