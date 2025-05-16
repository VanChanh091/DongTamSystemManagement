import 'package:dongtam/data/models/order/order_model.dart';
import 'package:dongtam/presentation/components/dialog/dialog_add_orders.dart';
import 'package:dongtam/presentation/components/headerTable/header_table_order.dart';
import 'package:dongtam/presentation/sources/order_DataSource.dart';
import 'package:dongtam/service/order_Service.dart';
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

  int currentPage = 1;
  int pageSize = 2;
  int totalPages = 1;
  List<dynamic> orders = [];

  @override
  void initState() {
    super.initState();
    loadOrders();
  }

  void loadOrders() {
    setState(() {
      futureOrdersPending = OrderService().getOrderPendingAndReject();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.all(5),
      child: Column(
        children: [
          //button
          SizedBox(
            height: 80,
            width: double.infinity,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(),

                //button
                Container(
                  padding: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                  child: Row(
                    children: [
                      // refresh
                      ElevatedButton.icon(
                        onPressed: loadOrders,
                        label: Text(
                          "Tải lại",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        icon: Icon(Icons.refresh, color: Colors.white),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xff78D761),
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
                      const SizedBox(width: 10),

                      //add
                      ElevatedButton.icon(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder:
                                (_) => OrderDialog(
                                  order: null,
                                  onOrderAddOrUpdate: () {
                                    loadOrders();
                                  },
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

                      //update
                      ElevatedButton.icon(
                        onPressed:
                            selectedOrderId == null
                                ? null
                                : () async {
                                  try {
                                    final orders = await futureOrdersPending;
                                    final selectedOrder = orders.firstWhere(
                                      (order) =>
                                          order.orderId == selectedOrderId,
                                    );

                                    showDialog(
                                      context: context,
                                      builder:
                                          (_) => OrderDialog(
                                            order: selectedOrder,
                                            onOrderAddOrUpdate: loadOrders,
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
                        icon: Icon(Symbols.construction, color: Colors.white),
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

                      //delete customers
                      ElevatedButton.icon(
                        onPressed:
                            selectedOrderId == null
                                ? null
                                : () {
                                  showDialog(
                                    context: context,
                                    builder:
                                        (_) => AlertDialog(
                                          title: Text("Xác nhận"),
                                          content: Text(
                                            "Bạn có chắc chắn muốn xóa đơn hàng này?",
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed:
                                                  () => Navigator.pop(context),
                                              child: Text("Hủy"),
                                            ),
                                            TextButton(
                                              onPressed: () async {
                                                await OrderService()
                                                    .deleteOrder(
                                                      selectedOrderId!,
                                                    );

                                                setState(() {
                                                  selectedOrderId = null;
                                                  loadOrders();
                                                });

                                                Navigator.pop(context);
                                              },
                                              child: Text("Xoá"),
                                            ),
                                          ],
                                        ),
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
    );
  }
}

Widget styleText(String text) {
  return Text(text, style: TextStyle(fontWeight: FontWeight.bold));
}

Widget styleCell(double? width, String text) {
  return SizedBox(width: width, child: Text(text, maxLines: 3));
}
