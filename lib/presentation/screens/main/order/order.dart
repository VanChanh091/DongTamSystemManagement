import 'package:dongtam/data/models/order/order_model.dart';
import 'package:dongtam/presentation/components/dialog/dialog_add_orders.dart';
import 'package:dongtam/presentation/components/headerTable/header_table_order.dart';
import 'package:dongtam/presentation/sources/order_DataSource.dart';
import 'package:dongtam/service/order_Service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class OrderPage extends StatefulWidget {
  const OrderPage({super.key});

  @override
  State<OrderPage> createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  late Future<List<Order>> futureOrders;
  late OrderDataSource orderDataSource;
  TextEditingController searchController = TextEditingController();
  String searchType = "Tất cả";
  String? selectedOrderId;
  bool isTextFieldEnabled = false;
  final formatter = DateFormat('dd/MM/yyyy');

  @override
  void initState() {
    super.initState();
    futureOrders = OrderService().getAllOrders();
  }

  void searchOrders() {
    String keyword = searchController.text.trim().toLowerCase();

    if (isTextFieldEnabled && keyword.isEmpty) return;

    if (searchType == "Tất cả") {
      setState(() {
        futureOrders = OrderService().getAllOrders();
      });
    } else if (searchType == "Tên KH") {
      setState(() {
        futureOrders = OrderService().getOrderByCustomerName(keyword);
      });
    } else if (searchType == "Tên SP") {
      setState(() {
        futureOrders = OrderService().getOrderByProductName(keyword);
      });
    } else if (searchType == "Loại SP") {
      setState(() {
        futureOrders = OrderService().getOrderByTypeProduct(keyword);
      });
    } else if (searchType == "QC Thùng") {
      setState(() {
        futureOrders = OrderService().getOrderByQcBox(keyword);
      });
    } else if (searchType == "Đơn Giá") {
      setState(() {
        futureOrders = OrderService().getOrderByPrice(double.parse(keyword));
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
                              "Đơn Giá",
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
                    ],
                  ),
                ),

                //button
                Container(
                  padding: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                  child: Row(
                    children: [
                      // refresh
                      ElevatedButton.icon(
                        onPressed: () {
                          setState(() {
                            futureOrders = OrderService().getAllOrders();
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

                      //add
                      ElevatedButton.icon(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder:
                                (_) => OrderDialog(
                                  order: null,
                                  onCustomerAddOrUpdate: () {
                                    setState(() {
                                      futureOrders =
                                          OrderService().getAllOrders();
                                    });
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
                        onPressed: () {
                          if (selectedOrderId == null) {
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  "Vui lòng chọn một đơn hàng để sửa!",
                                ),
                              ),
                            );
                            return;
                          }

                          // Tìm đơn hàng dựa trên selectedOrderId
                          final selectedOrder = futureOrders.then(
                            (orders) => orders.firstWhere(
                              (order) => order.orderId == selectedOrderId,
                            ),
                          );

                          selectedOrder
                              .then((order) {
                                showDialog(
                                  context: context,
                                  builder:
                                      (_) => OrderDialog(
                                        order: order,
                                        onCustomerAddOrUpdate: () {
                                          setState(() {
                                            futureOrders =
                                                OrderService().getAllOrders();
                                          });
                                        },
                                      ),
                                );
                              })
                              .catchError((e) {
                                print("Không tìm thấy đơn hàng: $e");
                              });
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
                            selectedOrderId != null
                                ? () {
                                  showDialog(
                                    context: context,
                                    builder:
                                        (context) => AlertDialog(
                                          title: Text("Xác nhận"),
                                          content: Text(
                                            'Bạn có chắc chắn muốn xóa khách hàng này?',
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
                                                  orderDataSource
                                                      .removeItemById(
                                                        selectedOrderId!,
                                                      );
                                                  selectedOrderId = null;
                                                  futureOrders =
                                                      OrderService()
                                                          .getAllOrders();
                                                });

                                                Navigator.pop(context);
                                              },
                                              child: Text("Xoá"),
                                            ),
                                          ],
                                        ),
                                  );
                                }
                                : null,

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
              future: futureOrders,
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
                    // get selected row
                    setState(() {
                      if (addedRows.isNotEmpty) {
                        selectedOrderId =
                            addedRows.first.getCells()[0].value.toString();
                      } else {
                        selectedOrderId = null;
                      }
                    });
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
  return Container(width: width, child: Text(text, maxLines: 3));
}
