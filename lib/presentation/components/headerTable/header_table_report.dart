import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:flutter/material.dart';

List<GridColumn> buildReportColumn() {
  return [
    GridColumn(columnName: "orderId", label: formatColumn('Mã Đơn Hàng')),
    GridColumn(
      columnName: "customerName",
      label: formatColumn('Tên Khách Hàng'),
    ),
    GridColumn(
      columnName: "structure",
      label: formatColumn('Kết Cấu Đơn Hàng'),
    ),
    GridColumn(columnName: "flute", label: formatColumn('Sóng')),
    GridColumn(columnName: "qc_box", label: formatColumn('Quy cách')),
    GridColumn(
      columnName: "dateToShipping",
      label: formatColumn('Ngày Giao Hàng'),
    ),
    GridColumn(
      columnName: "dayProduction",
      label: formatColumn('Ngày sản xuất'),
    ),
    GridColumn(
      columnName: "instructSpecial",
      label: formatColumn('HD Đặc Biệt'),
    ),
    GridColumn(columnName: "daoXa", label: formatColumn('Dao Xả')),
    GridColumn(columnName: "length", label: formatColumn('Dài')),
    GridColumn(columnName: "size", label: formatColumn('Khổ')),
    GridColumn(
      columnName: "runningForPlan",
      label: formatColumn('Kế Hoạch Chạy'),
    ),
    GridColumn(columnName: "totalPrice", label: formatColumn('Doanh Thu')),
    GridColumn(columnName: "bottom", label: formatColumn('Đáy')),
    GridColumn(columnName: "fluteE", label: formatColumn('Sóng E')),
    GridColumn(columnName: "fluteB", label: formatColumn('Sóng B')),
    GridColumn(columnName: "fluteC", label: formatColumn('Sóng C')),
    GridColumn(
      columnName: "totalLossWaste",
      label: formatColumn('Tổng Phế Liệu'),
    ),
    GridColumn(columnName: "qtyActually", label: formatColumn('SL Thực Tế')),
    GridColumn(columnName: "wasteActually", label: formatColumn('PL Thực Tế')),
    GridColumn(columnName: "shiftManager", label: formatColumn('Quản Ca')),
    GridColumn(
      columnName: "shiftProduction",
      label: formatColumn('Ca Sản Xuất'),
    ),
    GridColumn(columnName: "note", label: formatColumn('Ghi Chú')),
  ];
}

Widget formatColumn(String text, {double widthBorder = 0}) {
  return Container(
    alignment: Alignment.center,
    decoration: BoxDecoration(
      // color: Colors.amberAccent.shade200,
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
