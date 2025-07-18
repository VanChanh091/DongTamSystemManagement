import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

List<GridColumn> buildColumnPlanning() {
  return [
    //order
    GridColumn(columnName: 'orderId', label: formatColumn('Mã Đơn Hàng')),
    GridColumn(
      columnName: 'dateRequestShipping',
      label: formatColumn("Ngày YC Giao"),
    ),
    GridColumn(columnName: 'companyName', label: formatColumn("Tên Công Ty")),
    GridColumn(columnName: 'typeProduct', label: formatColumn("Loại SP")),
    GridColumn(columnName: 'productName', label: formatColumn("Tên SP")),
    GridColumn(columnName: 'flute', label: formatColumn("Sóng")),
    GridColumn(columnName: 'QC_box', label: formatColumn("QC Thùng")),
    GridColumn(
      columnName: 'structure',
      label: formatColumn("Kết Cấu Đặt Hàng"),
    ),
    GridColumn(columnName: 'canLan', label: formatColumn("Cấn Lằn")),
    GridColumn(columnName: 'daoXa', label: formatColumn("Dao Xả")),
    GridColumn(columnName: 'lengthMf', label: formatColumn("Dài (SX)")),
    GridColumn(columnName: 'sizeManufacture', label: formatColumn("Khổ (SX)")),
    GridColumn(
      columnName: 'qtyManufacture',
      label: formatColumn("Số Lượng (SX)"),
    ),
    GridColumn(
      columnName: 'instructSpecial',
      label: formatColumn("HD Đặc Biệt"),
    ),
    GridColumn(columnName: 'haveMadeBox', label: formatColumn("Làm Thùng?")),
    GridColumn(columnName: 'totalPrice', label: formatColumn("Doanh thu")),
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
