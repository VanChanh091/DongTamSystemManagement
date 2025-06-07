import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

List<GridColumn> buildCommonColumns() {
  return [
    //order
    GridColumn(columnName: 'orderId', label: formatColumn('Mã Đơn Hàng')),
    GridColumn(columnName: 'dayReceiveOrder', label: formatColumn('Ngày Nhận')),
    GridColumn(
      columnName: 'dateRequestShipping',
      label: formatColumn("Ngày YC Giao"),
    ),
    GridColumn(columnName: 'customerName', label: formatColumn("Tên KH")),
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
    GridColumn(columnName: 'lengthCus', label: formatColumn("Dài (KH)")),
    GridColumn(columnName: 'lengthMf', label: formatColumn("Dài (SX)")),
    GridColumn(columnName: 'sizeCustomer', label: formatColumn("Khổ (KH)")),
    GridColumn(columnName: 'sizeManufacture', label: formatColumn("Khổ (SX)")),
    GridColumn(
      columnName: 'quantityCustomer',
      label: formatColumn("Số Lượng (KH)"),
    ),
    GridColumn(
      columnName: 'qtyManufacture',
      label: formatColumn("Số Lượng (SX)"),
    ),
    GridColumn(columnName: 'dvt', label: formatColumn("DVT")),
    GridColumn(columnName: 'acreage', label: formatColumn("Diện Tích")),
    GridColumn(columnName: 'price', label: formatColumn("Đơn Giá")),
    GridColumn(columnName: 'pricePaper', label: formatColumn("Giá Tấm")),
    GridColumn(columnName: 'discount', label: formatColumn("Chiết Khẩu")),
    GridColumn(columnName: 'profit', label: formatColumn("Lợi Nhuận")),
    GridColumn(columnName: 'vat', label: formatColumn("VAT")),
    GridColumn(columnName: 'totalPrice', label: formatColumn("Doanh số")),

    //Box
    GridColumn(columnName: 'inMatTruoc', label: formatColumn("In Mặt Trước")),
    GridColumn(columnName: 'inMatSau', label: formatColumn("In Mặt Sau")),
    GridColumn(columnName: 'canMang', label: formatColumn("Cán Màng")),
    GridColumn(columnName: 'xa', label: formatColumn("Xả")),
    GridColumn(columnName: 'catKhe', label: formatColumn("Cắt Khe")),
    GridColumn(columnName: 'be', label: formatColumn("Bế")),
    GridColumn(columnName: 'dan_1_Manh', label: formatColumn("Dán 1 Mảnh")),
    GridColumn(columnName: 'dan_2_Manh', label: formatColumn("Dán 2 Mảnh")),
    GridColumn(
      columnName: 'dongGhimMotManh',
      label: formatColumn("Đóng Ghim 1 Mảnh"),
    ),
    GridColumn(
      columnName: 'dongGhimHaiManh',
      label: formatColumn("Đóng Ghim 2 Mảnh"),
    ),
    GridColumn(columnName: 'chongTham', label: formatColumn("Chống Thấm")),
    GridColumn(columnName: 'dongGoi', label: formatColumn("Đóng Gói")),
    GridColumn(columnName: 'maKhuon', label: formatColumn("Mã Khuôn")),
    GridColumn(columnName: 'HD_special', label: formatColumn("HD Đặc Biệt")),
    GridColumn(columnName: 'status', label: formatColumn("Trạng thái")),
    GridColumn(columnName: 'rejectReason', label: formatColumn("Lý do")),
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
