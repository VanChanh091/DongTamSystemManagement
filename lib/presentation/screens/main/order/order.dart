import 'package:dongtam/presentation/components/dialog/dialog_add_orders.dart';
import 'package:dongtam/presentation/components/headerTable/header_table_order.dart';
import 'package:dongtam/presentation/sources/order_DataSource.dart';
import 'package:dongtam/service/order_Service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class OrderPage extends StatefulWidget {
  const OrderPage({super.key});

  @override
  State<OrderPage> createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  List<String> isSelected = [];
  bool selectedAll = false;
  TextEditingController searchController = TextEditingController();
  String searchType = "Tất cả";
  bool isTextFieldEnabled = false;
  final formatter = DateFormat('dd/MM/yyyy');

  late OrderDataSource orderDataSource;
  final OrderService orderService = OrderService();
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadOrders();
  }

  Future<void> loadOrders() async {
    try {
      final orders = await orderService.getAllOrders();
      print('Orders: $orders');
      setState(() {
        orderDataSource = OrderDataSource(
          orders: orders,
          isSelected: isSelected,
          onCheckboxChanged: handleCheckboxChanged,
        );
        isLoading = false;
      });
    } catch (e) {
      print(e);
    }
  }

  void handleCheckboxChanged(String orderId, bool? value) {
    setState(() {
      if (value == true) {
        if (!isSelected.contains(orderId)) {
          isSelected.add(orderId);
        }
      } else {
        isSelected.remove(orderId);
      }

      selectedAll = isSelected.length == orderDataSource.orders.length;
    });

    orderDataSource.notifyListeners();
  }

  // void searchCustomer() {
  //   String keyword = searchController.text.trim().toLowerCase();

  //   if (isTextFieldEnabled && keyword.isEmpty) return;

  //   if (searchType == "Tất cả") {
  //     setState(() {
  //       futureOrder = OrderService().getAllOrders();
  //     });
  //   } else if (searchType == "Theo Mã") {
  //     setState(() {
  //       futureOrder = OrderService().getOrdersById(keyword);
  //     });
  //   } else if (searchType == "Theo Tên KH") {
  //     setState(() {
  //       // futureOrder = OrderService().getCustomerByName(keyword);
  //     });
  //   }
  // }

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
                Container(
                  padding: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                  child: Row(
                    children: [
                      // dropdown
                      DropdownButton<String>(
                        value: searchType,
                        items:
                            ['Tất cả', "Theo Mã"].map((String value) {
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
                          // onSubmitted: (_) => searchCustomer(),
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
                          // searchCustomer();
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

                Container(
                  padding: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                  child: Row(
                    children: [
                      // refresh
                      ElevatedButton.icon(
                        onPressed: () {
                          setState(() {
                            loadOrders();
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
                                      loadOrders();
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

                      //delete customers
                      ElevatedButton.icon(
                        onPressed:
                            isSelected.isNotEmpty
                                ? () {
                                  showDialog(
                                    context: context,
                                    builder:
                                        (context) => AlertDialog(
                                          title: Text("Xác nhận"),
                                          content: Text(
                                            'Bạn có chắc chắn muốn xóa ${isSelected.length} khách hàng?',
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed:
                                                  () => Navigator.pop(context),
                                              child: Text("Hủy"),
                                            ),
                                            TextButton(
                                              onPressed: () async {
                                                // for (String id in isSelected) {
                                                //   await CustomerService()
                                                //       .deleteCustomer(id);
                                                // }

                                                // setState(() {
                                                //   isSelected.clear();
                                                //   futureCustomer =
                                                //       CustomerService()
                                                //           .getAllCustomers();
                                                // });

                                                // Navigator.pop(context);
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
          isLoading
              ? Center(child: CircularProgressIndicator())
              : Expanded(
                child: SfDataGrid(
                  source: orderDataSource,
                  frozenColumnsCount: 1,
                  isScrollbarAlwaysShown: true,
                  allowSorting: true,
                  selectionMode: SelectionMode.multiple,
                  onSelectionChanged: (
                    List<DataGridRow> selectedRows,
                    List<DataGridRow> deselectedRows,
                  ) {
                    print("Dòng đã chọn: ${selectedRows.length}");
                  },

                  columnWidthMode: ColumnWidthMode.auto,
                  columns: [
                    GridColumn(
                      columnName: "checkbox",
                      label: Center(
                        child: Checkbox(
                          value: selectedAll,
                          onChanged: (value) {
                            setState(() {
                              selectedAll = value ?? false;
                              if (selectedAll) {
                                isSelected =
                                    orderDataSource.orders
                                        .map((row) => row.orderId)
                                        .toList();
                              } else {
                                isSelected.clear();
                              }
                            });

                            orderDataSource
                                .notifyListeners(); // Ensure all rows update
                          },
                        ),
                      ),
                    ),

                    ...buildCommonColumns(),
                  ],
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
