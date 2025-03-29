import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

List<GridColumn> buildCommonColumns() {
  return [
    GridColumn(
      columnName: 'orderId',
      label: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          border: Border(
            right: BorderSide(
              color: Colors.grey, // màu border
              width: 1, // độ dày border
            ),
          ),
        ),
        child: Text('Mã đơn'),
      ),
      width: 160,
    ),
    GridColumn(
      columnName: 'dayReceiveOrder',
      label: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          border: Border(
            right: BorderSide(
              color: Colors.grey, // màu border
              width: 1, // độ dày border
            ),
          ),
        ),
        child: Text('Ngày nhận'),
      ),
      width: 100,
    ),
    GridColumn(columnName: 'customerName', label: Text('Tên KH')),
    GridColumn(columnName: 'companyName', label: Text('Tên Cty')),
    GridColumn(columnName: 'song', label: Text('Sóng')),
    GridColumn(columnName: 'typeProduct', label: Text('Loại SP')),
    GridColumn(columnName: 'productName', label: Text('Tên SP')),
    GridColumn(columnName: 'QC_box', label: Text('QC Thùng')),
    GridColumn(columnName: 'structure', label: Text('Kết Cấu Đặt Thùng')),
    GridColumn(columnName: 'structureReplace', label: Text('Kết Cấu Thay Thế')),
    GridColumn(columnName: 'lengthPaper', label: Text('Cắt')),
    GridColumn(columnName: 'paperSize', label: Text('Khổ')),
    GridColumn(columnName: 'quantity', label: Text('Số Lượng ĐH')),
    GridColumn(columnName: 'acreage', label: Text('Diện Tích')),
    GridColumn(columnName: 'dvt', label: Text('DVT')),
    GridColumn(columnName: 'price', label: Text('Đơn Giá')),
    GridColumn(columnName: 'pricePaper', label: Text('Giá Tấm')),
    GridColumn(columnName: 'dateRequestShipping', label: Text('Ngày YC Giao')),

    //InfoProduction
    GridColumn(columnName: 'paperSizeInfo', label: Text('Khổ Tấm')),
    GridColumn(columnName: 'quantityInfo', label: Text('Số lượng')),
    GridColumn(columnName: 'HD_special', label: Text('HD Đặc Biệt')),
    GridColumn(columnName: 'numChild', label: Text('Số Con')),
    GridColumn(columnName: 'teBien', label: Text('Tề Biên')),
    GridColumn(columnName: 'CD_Sau', label: Text('Công Đoạn Sau')),
    GridColumn(columnName: 'totalPrice', label: Text('Doanh thu')),

    //Box
    GridColumn(columnName: 'inMatTruoc', label: Text('In Mặt Trước')),
    GridColumn(columnName: 'inMatSau', label: Text('In Mặt Sau')),
    GridColumn(columnName: 'canMang', label: Text('Cấn Màng')),
    GridColumn(columnName: 'xa', label: Text('Xả')),
    GridColumn(columnName: 'catKhe', label: Text('Cắt Khe')),
    GridColumn(columnName: 'be', label: Text('Bế')),
    GridColumn(columnName: 'dan_1_Manh', label: Text('Dán 1 Mảnh')),
    GridColumn(columnName: 'dan_2_Manh', label: Text('Dán 2 Mảnh')),
    GridColumn(columnName: 'dongGhim', label: Text('Đóng Ghim')),
    GridColumn(columnName: 'khac_1', label: Text('Khác 1')),
    GridColumn(columnName: 'khac_2', label: Text('Khác 2')),
  ];
}
