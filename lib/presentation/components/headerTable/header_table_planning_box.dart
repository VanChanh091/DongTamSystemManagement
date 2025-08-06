import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

List<GridColumn> buildMachineBoxColumns() {
  return [
    //planning
    GridColumn(columnName: 'orderId', label: formatColumn('Mã Đơn Hàng')),
    GridColumn(columnName: 'planningBoxId', label: Container(), visible: false),
    GridColumn(columnName: 'customerName', label: formatColumn("Tên KH")),
    GridColumn(columnName: 'dateShipping', label: formatColumn("Ngày YC Giao")),
    GridColumn(
      columnName: 'dayStartProduction',
      label: formatColumn("Ngày Sản Xuất"),
    ),
    GridColumn(
      columnName: 'dayCompletedProd',
      label: formatColumn("Ngày Hoàn Thành"),
    ),
    GridColumn(
      columnName: 'structure',
      label: formatColumn("Kết Cấu Đặt Hàng"),
    ),
    GridColumn(columnName: 'flute', label: formatColumn("Sóng")),
    GridColumn(columnName: 'QC_box', label: formatColumn("Quy cách")),
    GridColumn(columnName: 'length', label: formatColumn("Dài")),
    GridColumn(columnName: 'size', label: formatColumn("Khổ")),
    GridColumn(
      columnName: 'runningPlans',
      label: formatColumn("Kế Hoạch Chạy"),
    ),
    GridColumn(columnName: 'qtyProduced', label: formatColumn("SL Sản Xuất")),
    GridColumn(
      columnName: 'timeRunnings',
      label: formatColumn("Thời Gian Chạy"),
    ),
    GridColumn(columnName: 'wasteLoss', label: formatColumn("Phế Liệu")),
    GridColumn(columnName: 'rpWasteNorm', label: formatColumn("PL Thực Tế")),
    GridColumn(
      columnName: 'shiftManagement',
      label: formatColumn("Trưởng Máy"),
    ),
    GridColumn(columnName: 'status', label: SizedBox(), visible: false),
    GridColumn(
      columnName: 'index',
      label: formatColumn("Index"),
      visible: false,
    ),
  ];
}

Widget formatColumn(String text, {double widthBorder = 0}) {
  return Container(
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: Color(0xffcfa381),
      border: Border(right: BorderSide(color: Colors.grey.shade400, width: 1)),
    ),
    width: widthBorder,
    child: Text(
      text,
      style: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 15,
        color: Colors.white,
      ),
    ),
  );
}
