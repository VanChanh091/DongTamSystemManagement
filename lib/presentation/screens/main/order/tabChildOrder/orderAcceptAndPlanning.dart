import 'package:dongtam/data/models/order/order_model.dart';
import 'package:dongtam/presentation/components/headerTable/header_table_order.dart';
import 'package:dongtam/presentation/sources/order_DataSource.dart';
import 'package:dongtam/service/order_Service.dart';
import 'package:dongtam/utils/showSnackBar/show_snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class OrderAcceptAndPlanning extends StatefulWidget {
  const OrderAcceptAndPlanning({super.key});

  @override
  State<OrderAcceptAndPlanning> createState() => _OrderAcceptAndPlanningState();
}

class _OrderAcceptAndPlanningState extends State<OrderAcceptAndPlanning> {
  late Future<Map<String, dynamic>> futureOrdersAccept;
  late OrderDataSource orderDataSource;
  TextEditingController searchController = TextEditingController();
  String searchType = "Tất cả";
  String? selectedOrderId;
  bool isTextFieldEnabled = false;
  final formatter = DateFormat('dd/MM/yyyy');

  int currentPage = 1;
  int totalPages = 1;
  int pageSize = 3; //change here

  @override
  void initState() {
    super.initState();
    loadOrders();
  }

  void loadOrders() {
    setState(() {
      futureOrdersAccept = OrderService().getOrderAcceptAndPlanning(
        currentPage,
        pageSize,
      );
    });
  }

  void searchOrders() {
    String keyword = searchController.text.trim().toLowerCase();

    if (isTextFieldEnabled && keyword.isEmpty) return;

    if (searchType == "Tất cả") {
      setState(() {
        futureOrdersAccept = OrderService().getOrderAcceptAndPlanning(
          currentPage,
          pageSize,
        );
      });
    } else if (searchType == "Tên KH") {
      setState(() {
        futureOrdersAccept = OrderService().getOrderByCustomerName(keyword);
      });
    } else if (searchType == "Tên SP") {
      setState(() {
        futureOrdersAccept = OrderService().getOrderByProductName(keyword);
      });
    } else if (searchType == "QC Thùng") {
      setState(() {
        futureOrdersAccept = OrderService().getOrderByQcBox(keyword);
      });
    } else if (searchType == "Đơn giá") {
      setState(() {
        try {
          final price = double.parse(keyword);
          futureOrdersAccept = OrderService().getOrderByPrice(price);
        } catch (e) {
          showSnackBarError(context, 'Vui lòng nhập số hợp lệ cho đơn giá');
        }
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
                              "QC Thùng",
                              'Đơn giá',
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
                            futureOrdersAccept = OrderService()
                                .getOrderAcceptAndPlanning(currentPage, 30);
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
            child: FutureBuilder<Map<String, dynamic>>(
              future: futureOrdersAccept,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text("Lỗi: ${snapshot.error}"));
                } else if (!snapshot.hasData ||
                    snapshot.data!['orders'].isEmpty) {
                  return Center(child: Text("Không có đơn hàng nào"));
                }

                final data = snapshot.data!;
                final orders = data['orders'] as List<Order>;
                final currentPg = data['currentPage'];
                final totalPgs = data['totalPages'];

                orderDataSource = OrderDataSource(
                  orders: orders,
                  selectedOrderId: selectedOrderId,
                );

                return Column(
                  children: [
                    //table
                    Expanded(
                      child: SfDataGrid(
                        source: orderDataSource,
                        columns: buildCommonColumns(),
                        isScrollbarAlwaysShown: true,
                        selectionMode: SelectionMode.single,
                        columnWidthMode: ColumnWidthMode.auto,
                        onSelectionChanged: (addedRows, removedRows) {
                          if (addedRows.isNotEmpty) {
                            final selectedRow = addedRows.first;
                            final orderId =
                                selectedRow.getCells()[0].value.toString();
                            final selectedOrder = orders.firstWhere(
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
                      ),
                    ),

                    // Nút chuyển trang
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            onPressed:
                                currentPage > 1
                                    ? () {
                                      setState(() {
                                        currentPage--;
                                        loadOrders();
                                      });
                                    }
                                    : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xff78D761),
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 15,
                              ),
                              shadowColor: Colors.black.withOpacity(0.2),
                              elevation: 5,
                            ),
                            child: Text(
                              "Trang trước",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          SizedBox(width: 20),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              'Trang: $currentPg / $totalPgs',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          SizedBox(width: 20),
                          ElevatedButton(
                            onPressed:
                                currentPage < totalPgs
                                    ? () {
                                      setState(() {
                                        currentPage++;
                                        loadOrders();
                                      });
                                    }
                                    : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xff78D761),
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 15,
                              ),
                              shadowColor: Colors.black.withOpacity(0.2),
                              elevation: 5,
                            ),
                            child: Text(
                              "Trang sau",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
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
