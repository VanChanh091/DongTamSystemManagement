import 'package:dongtam/data/controller/theme_controller.dart';
import 'package:dongtam/utils/helper/style_table.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

const List<Map<String, dynamic>> _headerDeliverySchedule = [
  {"key": "vehicleName", "title": "Tên Xe"},
  {"key": "licensePlate", "title": "Biển Số"},

  //order
  {"key": "orderId", "title": "Mã Đơn Hàng"},
  {"key": "customerName", "title": "Tên Khách Hàng"},
  {"key": "companyName", "title": "Tên Công Ty"},
  {"key": "productName", "title": "Tên Sản Phẩm"},

  {"key": "flute", "title": "Sóng"},
  {"key": "QC_box", "title": "Quy Cách"},
  {"key": "structure", "title": "Kết Cấu Đặt Hàng"},

  {"key": "sizeProd", "title": "Khổ (SX)"},
  {"key": "lengthProd", "title": "Dài (SX)"},
  {"key": "qtyRegistered", "title": "Số Lượng Giao"},
  {"key": "dvt", "title": "DVT"},
  {"key": "volume", "title": "Khối Lượng"},

  //vehicle
  {"key": "maxPayload", "title": "Tải Trọng"},
  {"key": "volumeCapacity", "title": "Thể Tích Xe"},
  {"key": "vehicleHouse", "title": "Nhà Xe"},

  //delivery item
  {"key": "note", "title": "Ghi Chú"},
  {"key": "status", "title": "Trạng Thái"},

  //hidden field
  {"key": "deliveryId", "title": "Mã Giao Hàng", "visible": false},
  {"key": "deliveryItemId", "title": "", "visible": false},
  {"key": "deliveryDate", "title": "Ngày Giao Hàng", "visible": false},
  {"key": "status", "title": "Trạng Thái", "visible": false}, //status of delivery item
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
