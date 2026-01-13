import 'package:dongtam/data/controller/theme_controller.dart';
import 'package:dongtam/utils/helper/style_table.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

const List<Map<String, dynamic>> _headerCustomer = [
  {"key": "customerId", "title": "Mã Khách Hàng"},
  {"key": "maSoThue", "title": "Mã Số Thuế"},
  {"key": "customerName", "title": "Tên Khách Hàng"},
  {"key": "phone", "title": "Số Điện Thoại"},
  {"key": "contactPerson", "title": "Người Liên Hệ"},
  {"key": "dayCreatedCus", "title": "Ngày Tạo"},
  {"key": "debtLimitCustomer", "title": "Hạn Mức Công Nợ"},
  {"key": "debtCurrentCustomer", "title": "Công Nợ Hiện Tại"},
  {"key": "termPaymentCost", "title": "Hạn Thanh Toán"},
  {"key": "companyName", "title": "Tên Công Ty"},
  {"key": "companyAddress", "title": "Địa Chỉ Công Ty"},
  {"key": "shippingAddress", "title": "Địa Chỉ Giao Hàng"},
  {"key": "distanceShip", "title": "Khoảng Cách"},
  {"key": "CSKH", "title": "CSKH"},
  {"key": "customerSource", "title": "Nguồn Khách"},
  {"key": "rateCustomer", "title": "Đánh Giá"},
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
