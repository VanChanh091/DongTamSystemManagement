import 'package:dongtam/data/controller/theme_controller.dart';
import 'package:dongtam/utils/helper/style_table.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

const List<Map<String, dynamic>> _headerDeliverySchedule = [
  //order
  {"key": "orderId", "title": "Mã Đơn Hàng"},
  {"key": "orderIdCus", "title": "Mã PO"},
  {"key": "status", "title": "Trạng Thái"},
  {"key": "customerName", "title": "Khách Hàng"},
  {"key": "productName", "title": "Tên Sản Phẩm"},

  {"key": "QC_box", "title": "Quy Cách"},
  {"key": "structure", "title": "Kết Cấu Đặt Hàng"},

  {"key": "sizeProd", "title": "Khổ (SX)"},
  {"key": "lengthProd", "title": "Dài (SX)"},

  {"key": "qtyCustomer", "title": "Đơn Hàng"},
  {"key": "totalQtyOutbound", "title": "Tổng Xuất"},
  {"key": "qtyRegistered", "title": "Yêu Cầu"},
  {"key": "qtyOutbound", "title": "Xuất Kho"},

  {"key": "note", "title": "Ghi Chú"},
  {"key": "dvt", "title": "DVT"},
  {"key": "volume", "title": "Khối Lượng"},
  {"key": "vehicleHouse", "title": "Nhà Xe"},

  //hidden field
  {"key": "deliveryId", "title": "Mã Giao Hàng", "visible": false},
  {"key": "deliveryItemId", "title": "", "visible": false},
  {"key": "deliveryDate", "title": "Ngày Giao Hàng", "visible": false},
  {"key": "status", "title": "Trạng Thái", "visible": false}, //status of delivery item
  {"key": "vehicleName", "title": "Tên Xe", "visible": false},
  {"key": "sequence", "title": "Tài", "visible": false},
];

List<GridColumn> buildDeliveryScheduleColumn({required ThemeController themeController}) {
  return [
    for (var item in _headerDeliverySchedule)
      GridColumn(
        columnName: item["key"]!,
        label: Obx(() => formatColumn(label: item["title"]!, themeController: themeController)),
        visible: item.containsKey("visible") ? item["visible"]! as bool : true,
      ),
  ];
}
