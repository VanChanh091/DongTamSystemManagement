import 'package:dongtam/data/controller/theme_controller.dart';
import 'package:dongtam/utils/helper/style_table.dart';
import 'package:flutter/material.dart';
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

List<GridColumn> buildCustomerColumn({
  required ThemeController themeController,
  required ValueNotifier<double> zoomNotifier,
}) => buildGridColumns(
  headerConfig: _headerCustomer,
  themeController: themeController,
  zoomNotifier: zoomNotifier,
);

List<StackedHeaderRow> buildCustomersSHR({
  required ThemeController themeController,
  required double zoom,
}) {
  return [
    StackedHeaderRow(
      cells: [
        buildStackedHeaderCell(
          columnNames: [
            "debtLimit",
            "debtCurrent",
            "paymentTermDays",
            "paymentType",
            "closingDays",
          ],
          label: "Công Nợ",
          themeController: themeController,
          zoom: zoom,
        ),
      ],
    ),
  ];
}
