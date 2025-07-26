import 'package:dongtam/data/models/order/order_model.dart';
import 'package:dongtam/presentation/components/dialog/dialog_add_orders.dart';
import 'package:dongtam/presentation/components/headerTable/header_table_order.dart';
import 'package:dongtam/presentation/sources/order_dataSource.dart';
import 'package:dongtam/service/order_Service.dart';
import 'package:dongtam/utils/showSnackBar/show_snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class OrderRejectAndPending extends StatefulWidget {
  const OrderRejectAndPending({super.key});

  @override
  State<OrderRejectAndPending> createState() => _OrderRejectAndPendingState();
}

class _OrderRejectAndPendingState extends State<OrderRejectAndPending> {
  late Future<List<Order>> futureOrdersPending;
  String? selectedOrderId;
  final formatter = DateFormat('dd/MM/yyyy');

  @override
  void initState() {
    super.initState();
    loadOrders(false);
  }

  void loadOrders(bool refresh) {
    setState(() {
      futureOrdersPending = OrderService().getOrderPendingAndReject(refresh);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.white,
        padding: EdgeInsets.all(5),
        child: Column(
          children: [
            //button
            SizedBox(
              height: 70,
              width: double.infinity,

              child: Column(
                children: [
                  SizedBox(height: 10),

                  Row(
                    children: [
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            SizedBox(),
                            //title
                            Text(
                              "ĐƠN HÀNG ĐANG CHỜ DUYỆT/TỪ CHỐI",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 25,
                                color: Color(0xffcfa381),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Các nút bên phải
                      Container(
                        padding: EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 10,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // nút thêm
                            ElevatedButton.icon(
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder:
                                      (_) => OrderDialog(
                                        order: null,
                                        onOrderAddOrUpdate:
                                            () => loadOrders(true),
                                      ),
                                );
                              },
                              label: Text(
                                "Thêm mới",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              icon: Icon(Icons.add, color: Colors.white),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xff78D761),
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(
                                  horizontal: 15,
                                  vertical: 15,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),

                            // nút sửa
                            ElevatedButton.icon(
                              onPressed:
                                  selectedOrderId == null
                                      ? null
                                      : () async {
                                        try {
                                          final orders =
                                              await futureOrdersPending;
                                          final selectedOrder = orders
                                              .firstWhere(
                                                (order) =>
                                                    order.orderId ==
                                                    selectedOrderId,
                                              );

                                          showDialog(
                                            context: context,
                                            builder:
                                                (_) => OrderDialog(
                                                  order: selectedOrder,
                                                  onOrderAddOrUpdate:
                                                      () => loadOrders(true),
                                                ),
                                          );
                                        } catch (e) {
                                          print("Không tìm thấy đơn hàng: $e");
                                        }
                                      },
                              label: Text(
                                "Sửa",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              icon: Icon(
                                Symbols.construction,
                                color: Colors.white,
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xff78D761),
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(
                                  horizontal: 15,
                                  vertical: 15,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),

                            // nút xóa
                            ElevatedButton.icon(
                              onPressed:
                                  selectedOrderId == null
                                      ? null
                                      : () {
                                        showDialog(
                                          context: context,
                                          builder: (context) {
                                            bool isDeleting = false;

                                            return StatefulBuilder(
                                              builder: (
                                                context,
                                                setStateDialog,
                                              ) {
                                                return AlertDialog(
                                                  backgroundColor: Colors.white,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          16,
                                                        ),
                                                  ),
                                                  title: Row(
                                                    children: const [
                                                      Icon(
                                                        Icons
                                                            .warning_amber_rounded,
                                                        color: Colors.red,
                                                        size: 30,
                                                      ),
                                                      SizedBox(width: 8),
                                                      Text(
                                                        "Xác nhận xoá",
                                                        style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  content:
                                                      isDeleting
                                                          ? Row(
                                                            children: const [
                                                              CircularProgressIndicator(
                                                                strokeWidth: 2,
                                                              ),
                                                              SizedBox(
                                                                width: 12,
                                                              ),
                                                              Text(
                                                                "Đang xoá...",
                                                              ),
                                                            ],
                                                          )
                                                          : Text(
                                                            'Bạn có chắc chắn muốn xoá đơn hàng này?',
                                                            style: TextStyle(
                                                              fontSize: 16,
                                                            ),
                                                          ),
                                                  actions:
                                                      isDeleting
                                                          ? []
                                                          : [
                                                            TextButton(
                                                              onPressed:
                                                                  () =>
                                                                      Navigator.pop(
                                                                        context,
                                                                      ),
                                                              child: Text(
                                                                "Huỷ",
                                                                style: TextStyle(
                                                                  fontSize: 16,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  color:
                                                                      Colors
                                                                          .black54,
                                                                ),
                                                              ),
                                                            ),
                                                            ElevatedButton(
                                                              style: ElevatedButton.styleFrom(
                                                                backgroundColor:
                                                                    const Color(
                                                                      0xffEA4346,
                                                                    ),
                                                                foregroundColor:
                                                                    Colors
                                                                        .white,
                                                                shape: RoundedRectangleBorder(
                                                                  borderRadius:
                                                                      BorderRadius.circular(
                                                                        8,
                                                                      ),
                                                                ),
                                                              ),
                                                              onPressed: () async {
                                                                setStateDialog(
                                                                  () {
                                                                    isDeleting =
                                                                        true;
                                                                  },
                                                                );

                                                                await OrderService()
                                                                    .deleteOrder(
                                                                      selectedOrderId!,
                                                                    );

                                                                await Future.delayed(
                                                                  const Duration(
                                                                    milliseconds:
                                                                        500,
                                                                  ),
                                                                );

                                                                loadOrders(
                                                                  true,
                                                                );

                                                                Navigator.pop(
                                                                  context,
                                                                );

                                                                // Optional: Show success toast
                                                                showSnackBarSuccess(
                                                                  context,
                                                                  'Xoá thành công',
                                                                );
                                                              },
                                                              child: const Text(
                                                                "Xoá",
                                                                style: TextStyle(
                                                                  fontSize: 16,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                );
                                              },
                                            );
                                          },
                                        );
                                      },
                              label: Text(
                                "Xóa",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              icon: Icon(Icons.delete, color: Colors.white),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xffEA4346),
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 15,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // table
            Expanded(
              child: FutureBuilder(
                future: futureOrdersPending,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text("Lỗi: ${snapshot.error}"));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text("Không có đơn hàng nào"));
                  }

                  final List<Order> data = snapshot.data!;

                  final orderDataSource = OrderDataSource(
                    orders: data,
                    selectedOrderId: selectedOrderId,
                  );

                  return SfDataGrid(
                    source: orderDataSource,
                    isScrollbarAlwaysShown: true,
                    selectionMode: SelectionMode.single,
                    onSelectionChanged: (addedRows, removedRows) {
                      if (addedRows.isNotEmpty) {
                        final selectedRow = addedRows.first;
                        final orderId =
                            selectedRow.getCells()[0].value.toString();

                        final selectedOrder = data.firstWhere(
                          (order) => order.orderId == orderId,
                        );

                        setState(() {
                          selectedOrderId = selectedOrder.orderId;
                          // print("Selected Order ID: $selectedOrderId");
                        });
                      } else {
                        setState(() {
                          selectedOrderId = null;
                        });
                      }
                    },
                    columnWidthMode: ColumnWidthMode.auto,
                    columns: buildCommonColumns(),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => loadOrders(true),
        backgroundColor: Color(0xff78D761),
        child: const Icon(Icons.refresh, color: Colors.white),
      ),
    );
  }
}
