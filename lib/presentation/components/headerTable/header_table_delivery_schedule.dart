import 'package:dongtam/data/controller/theme_controller.dart';
import 'package:dongtam/utils/helper/style_table.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

const List<Map<String, dynamic>> _headerDeliverySchedule = [
  //order
  {"key": "orderId", "title": "Mã Đơn Hàng"},
  {"key": "customerName", "title": "Tên Khách Hàng"},
  {"key": "productName", "title": "Tên Sản Phẩm"},
  {"key": "flute", "title": "Sóng"},
  {"key": "QC_box", "title": "Quy Cách"},
  {"key": "structure", "title": "Kết Cấu Đặt Hàng"},
  {"key": "lengthProd", "title": "Dài"},
  {"key": "sizeProd", "title": "Khổ"},
  {"key": "quantity", "title": "Số Lượng"},
  {"key": "qtyInventory", "title": "Tồn Kho"},
  {"key": "dvt", "title": "DVT"},

  //vehicle
  {"key": "vehicleName", "title": "Tên Xe"},
  {"key": "licensePlate", "title": "Biển Số"},
  {"key": "maxPayload", "title": "Tải Trọng"},
  {"key": "volumeCapacity", "title": "Thể Tích"},

  //delivery item
  {"key": "note", "title": "Ghi Chú"},

  //hidden field
  {"key": "deliveryId", "title": "Mã Giao Hàng", "visible": false},
  {"key": "deliveryDate", "title": "Ngày Giao Hàng", "visible": false},
  {"key": "status", "title": "Trạng Thái", "visible": false}, //statts of delivery item
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
