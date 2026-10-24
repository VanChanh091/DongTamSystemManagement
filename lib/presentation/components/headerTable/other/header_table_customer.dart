import 'package:dongtam/data/controller/theme_controller.dart';
import 'package:dongtam/utils/helper/style_table.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

const List<Map<String, dynamic>> _headerCustomer = [
  {"key": "index", "title": "STT"},
  {"key": "customerId", "title": "Mã Khách Hàng"},
  {"key": "maSoThue", "title": "Mã Số Thuế"},
  {"key": "customerName", "title": "Tên Khách Hàng"},
  {"key": "phone", "title": "Số Điện Thoại"},
  {"key": "contactPerson", "title": "Người Liên Hệ"},

  //payment
  {"key": "debtLimit", "title": "Hạn Mức"},
  {"key": "debtCurrent", "title": "Hiện Tại"},
  {"key": "paymentType", "title": "Kiểu Thanh Toán"},
  {"key": "closingDays", "title": "Ngày Chốt"},
  {"key": "paymentTermDays", "title": "Thời Gian"},

  {"key": "companyName", "title": "Tên Công Ty"},
  {"key": "companyAddress", "title": "Địa Chỉ Công Ty"},
  {"key": "shippingAddress", "title": "Địa Chỉ Giao Hàng"},
  {"key": "distanceShip", "title": "Khoảng Cách (Km)"},
  {"key": "CSKH", "title": "CSKH"},
  {"key": "customerSource", "title": "Nguồn Khách"},
  {"key": "rateCustomer", "title": "Đánh Giá"},
  {"key": "createdAt", "title": "Ngày Tạo"},
];

List<GridColumn> buildCustomerColumn({required ThemeController themeController}) {
  return [
    for (var item in _headerCustomer)
      GridColumn(
        columnName: item["key"]!,
        label: Obx(() => formatColumn(label: item["title"]!, themeController: themeController)),
        visible: item.containsKey("visible") ? item["visible"]! as bool : true,
      ),
  ];
}
