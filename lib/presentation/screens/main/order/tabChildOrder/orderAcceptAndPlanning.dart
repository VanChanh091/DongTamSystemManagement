import 'package:dongtam/data/models/order/order_model.dart';
import 'package:dongtam/presentation/components/headerTable/header_table_order.dart';
import 'package:dongtam/presentation/sources/order_DataSource.dart';
import 'package:dongtam/service/order_Service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class OrderAcceptAndPlanning extends StatefulWidget {
  const OrderAcceptAndPlanning({super.key});

  @override
  State<OrderAcceptAndPlanning> createState() => _OrderAcceptAndPlanningState();
}

class _OrderAcceptAndPlanningState extends State<OrderAcceptAndPlanning> {
  late Future<List<Order>> futureOrdersAccept;
  late OrderDataSource orderDataSource;
  TextEditingController searchController = TextEditingController();
  String searchType = "Tất cả";
  String? selectedOrderId;
  bool isTextFieldEnabled = false;
  final formatter = DateFormat('dd/MM/yyyy');

  @override
  void initState() {
    super.initState();
    futureOrdersAccept = OrderService().getOrderAcceptAndPlanning();
  }

  void searchOrders() {
    String keyword = searchController.text.trim().toLowerCase();

    if (isTextFieldEnabled && keyword.isEmpty) return;

    if (searchType == "Tất cả") {
      setState(() {
        futureOrdersAccept = OrderService().getOrderAcceptAndPlanning();
      });
    } else if (searchType == "Tên KH") {
      setState(() {
        futureOrdersAccept = OrderService().getOrderByCustomerName(keyword);
      });
    } else if (searchType == "Tên SP") {
      setState(() {
        futureOrdersAccept = OrderService().getOrderByProductName(keyword);
      });
    } else if (searchType == "Loại SP") {
      setState(() {
        futureOrdersAccept = OrderService().getOrderByTypeProduct(keyword);
      });
    } else if (searchType == "QC Thùng") {
      setState(() {
        futureOrdersAccept = OrderService().getOrderByQcBox(keyword);
      });
    }
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
                //dropdown
                Container(
                  padding: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                  child: Row(
                    children: [
                      // dropdown
                      DropdownButton<String>(
                        value: searchType,
                        items:
                            [
                              'Tất cả',
                              "Tên KH",
                              "Tên SP",
                              "Loại SP",
                              "QC Thùng",
                            ].map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                        onChanged: (value) {
                          setState(() {
                            searchType = value!;
                            isTextFieldEnabled = searchType != 'Tất cả';

                            if (!isTextFieldEnabled) {
                              searchController.clear();
                            }
                          });
                        },
                      ),
                      SizedBox(width: 10),

                      // input
                      SizedBox(
                        width: 250,
                        height: 50,
                        child: TextField(
                          controller: searchController,
                          enabled: isTextFieldEnabled,
                          onSubmitted: (_) => searchOrders(),
                          decoration: InputDecoration(
                            hintText: 'Tìm kiếm...',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 10,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),

                      // find
                      ElevatedButton.icon(
                        onPressed: () {
                          searchOrders();
                        },
                        label: Text(
                          "Tìm kiếm",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        icon: Icon(Icons.search, color: Colors.white),
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
                      // refresh
                      ElevatedButton.icon(
                        onPressed: () {
                          setState(() {
                            futureOrdersAccept =
                                OrderService().getOrderAcceptAndPlanning();
                          });
                        },
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
                    ],
                  ),
                ),

                //button
                Container(),
              ],
            ),
          ),

          // table
          Expanded(
            child: FutureBuilder(
              future: futureOrdersAccept,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text("Lỗi: ${snapshot.error}"));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text("Không có đơn hàng nào"));
                }

                final List<Order> data = snapshot.data!;

                orderDataSource = OrderDataSource(
                  orders: data,
                  selectedOrderId: selectedOrderId,
                );

                return SfDataGrid(
                  source: orderDataSource,
                  isScrollbarAlwaysShown: true,
                  // allowSorting: true,
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
