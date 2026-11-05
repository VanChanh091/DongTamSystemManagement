import 'package:dongtam/data/controller/theme_controller.dart';
import 'package:dongtam/utils/helper/style_table.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

const List<Map<String, dynamic>> _headerOutboundHistory = [
  {"key": "index", "title": "STT"},
  {"key": "outboundSlipCode", "title": "Mã Số PXK"},

  {"key": "customerName", "title": "Tên Khách Hàng"},
  {"key": "companyName", "title": "Tên Công Ty"},
  {"key": "totalOutboundQty", "title": "Số Lượng Xuất"},
  {"key": "dueDate", "title": "Ngày Đến Hạn"},

  //money
  {"key": "totalPriceOrder", "title": "Hàng"},
  {"key": "totalPriceVAT", "title": "Thuế"},
  {"key": "totalPricePayment", "title": "Cần Thanh Toán"},
  {"key": "paidAmount", "title": "Đã Thanh Toán"},
  {"key": "remainingAmount", "title": "Còn Lại"},

  {"key": "status", "title": "Trạng Thái"},
  {"key": "outboundBy", "title": "Người Lập Phiếu"},
  {"key": "allocationHistory", "title": "Lịch Sử Trừ Nợ", "width": 140.0},

  //hidden
  {"key": "outboundId", "title": "", "visible": false},
  {"key": "dateOutbound", "title": "Ngày Xuất Kho", "visible": false},
];

List<GridColumn> buildOutboundHistoryColumn({
  required ThemeController themeController,
  required ValueNotifier<double> zoomNotifier,
  bool showAllocationHistory = false,
}) => buildGridColumns(
  headerConfig: [
    for (var item in _headerOutboundHistory)
      if (item["key"] != "allocationHistory" || showAllocationHistory) item,
  ],
  themeController: themeController,
  zoomNotifier: zoomNotifier,
);

List<StackedHeaderRow> buildOutboundHistorySHR({
  required ThemeController themeController,
  required double zoom,
}) {
  return [
    StackedHeaderRow(
      cells: [
        buildStackedHeaderCell(
          columnNames: [
            "totalPriceOrder",
            "totalPriceVAT",
            "totalPricePayment",
            "paidAmount",
            "remainingAmount",
          ],
          label: "Tổng Tiền (VNĐ)",
          themeController: themeController,
          zoom: zoom,
        ),
      ],
    ),
  ];
}
