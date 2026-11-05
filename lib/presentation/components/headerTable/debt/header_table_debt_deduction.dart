import 'package:dongtam/data/controller/theme_controller.dart';
import 'package:dongtam/utils/helper/style_table.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

List<GridColumn> buildDebtDeductionColumn({
  required ThemeController themeController,
  required ValueNotifier<double> zoomNotifier,
  required bool isReport,
}) {
  final List<Map<String, dynamic>> headers = [
    {"key": "index", "title": "STT"},
    {"key": "customerName", "title": "Tên Khách Hàng"},

    {"key": "createdAt", "title": "Ngày Yêu Cầu"},
    {"key": "amountRequested", "title": "Số Tiền Yêu Cầu"},
    if (isReport != true) {"key": "currentDebt", "title": "Công Nợ Hiện Tại"},
    {"key": "paymentMethod", "title": "Kiểu Thanh Toán"},
    {"key": "requestedBy", "title": "Người Yêu Cầu"},
    if (isReport) {"key": "approvedBy", "title": "Người Duyệt"},
    {"key": "isUrgent", "title": "Khẩn Cấp?"},
    {"key": "status", "title": "Trạng Thái"},

    //hidden field
    {"key": "requestId", "title": "", "visible": false},
    {"key": "createdRequest", "title": "", "visible": false},
  ];

  return buildGridColumns(
    headerConfig: headers,
    themeController: themeController,
    zoomNotifier: zoomNotifier,
  );
}
