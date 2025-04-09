import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

List<GridColumn> buildCommonColumns() {
  return [
    GridColumn(columnName: 'orderId', label: formatColumn('Mã Đơn Hàng')),
    GridColumn(columnName: 'dayReceiveOrder', label: formatColumn('Ngày Nhận')),
    GridColumn(columnName: 'customerName', label: formatColumn("Tên KH")),
    GridColumn(columnName: 'companyName', label: formatColumn("Tên Cty")),
    GridColumn(columnName: 'song', label: formatColumn("Sóng")),
    GridColumn(columnName: 'typeProduct', label: formatColumn("Loại SP")),
    GridColumn(columnName: 'productName', label: formatColumn("Tên SP")),
    GridColumn(columnName: 'QC_box', label: formatColumn("QC Thùng")),
    GridColumn(
      columnName: 'structure',
      label: formatColumn("Kết Cấu Đặt Thùng"),
    ),
    GridColumn(
      columnName: 'structureReplace',
      label: formatColumn("Kết Cấu Thay Thế"),
    ),
    GridColumn(columnName: 'lengthPaper', label: formatColumn("Cắt")),
    GridColumn(columnName: 'paperSize', label: formatColumn("Khổ")),
    GridColumn(columnName: 'quantity', label: formatColumn("Số Lượng")),
    GridColumn(columnName: 'dvt', label: formatColumn("DVT")),
    GridColumn(columnName: 'acreage', label: formatColumn("Diện Tích")),
    GridColumn(columnName: 'price', label: formatColumn("Đơn Giá")),
    GridColumn(columnName: 'pricePaper', label: formatColumn("Giá Tấm")),
    GridColumn(
      columnName: 'dateRequestShipping',
      label: formatColumn("Ngày YC Giao"),
    ),
    GridColumn(columnName: 'vat', label: formatColumn("VAT")),

    //InfoProduction
    GridColumn(columnName: 'paperSizeInfo', label: formatColumn("Khổ Tấm")),
    GridColumn(columnName: 'quantityInfo', label: formatColumn("Số lượng")),
    GridColumn(columnName: 'numChild', label: formatColumn("Số Con")),
    GridColumn(columnName: 'teBien', label: formatColumn("Tề Biên")),
    GridColumn(columnName: 'CD_Sau', label: formatColumn("CD Sau")),
    GridColumn(columnName: 'totalPrice', label: formatColumn("Doanh thu")),

    //Box
    GridColumn(columnName: 'inMatTruoc', label: formatColumn("In Mặt Trước")),
    GridColumn(columnName: 'inMatSau', label: formatColumn("In Mặt Sau")),
    GridColumn(columnName: 'canMang', label: formatColumn("Cán Màng")),
    GridColumn(columnName: 'xa', label: formatColumn("Xả")),
    GridColumn(columnName: 'catKhe', label: formatColumn("Cắt Khe")),
    GridColumn(columnName: 'be', label: formatColumn("Bế")),
    GridColumn(columnName: 'dan_1_Manh', label: formatColumn("Dán 1 Mảnh")),
    GridColumn(columnName: 'dan_2_Manh', label: formatColumn("Dán 2 Mảnh")),
    GridColumn(columnName: 'dongGhim', label: formatColumn("Đóng Ghim")),
    GridColumn(columnName: 'khac_1', label: formatColumn("Khác 1")),
    GridColumn(columnName: 'khac_2', label: formatColumn("Khác 2")),
    GridColumn(columnName: 'HD_special', label: formatColumn("HD Đặc Biệt")),
  ];
}

Widget formatColumn(String text, {double widthBorder = 0}) {
  return Container(
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: Colors.amberAccent.shade200,
      border: Border(right: BorderSide(color: Colors.grey.shade400, width: 1)),
    ),
    width: widthBorder,
    child: Text(
      text,
      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
    ),
  );
}
