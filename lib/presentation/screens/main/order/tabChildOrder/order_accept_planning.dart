import 'package:dongtam/data/controller/user_controller.dart';
import 'package:dongtam/data/models/order/order_model.dart';
import 'package:dongtam/presentation/components/headerTable/header_table_order.dart';
import 'package:dongtam/presentation/sources/order_data_source.dart';
import 'package:dongtam/service/order_service.dart';
import 'package:dongtam/utils/helper/animated_button.dart';
import 'package:dongtam/utils/helper/pagination_controls.dart';
import 'package:dongtam/utils/helper/skeleton/skeleton_loading.dart';
import 'package:dongtam/utils/helper/style_table.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class OrderAcceptAndPlanning extends StatefulWidget {
  const OrderAcceptAndPlanning({super.key});

  @override
  State<OrderAcceptAndPlanning> createState() => _OrderAcceptAndPlanningState();
}

class _OrderAcceptAndPlanningState extends State<OrderAcceptAndPlanning> {
  late Future<Map<String, dynamic>> futureOrdersAccept;
  late OrderDataSource orderDataSource;
  late List<GridColumn> columns;
  final userController = Get.find<UserController>();
  final formatter = DateFormat('dd/MM/yyyy');
  TextEditingController searchController = TextEditingController();
  String searchType = "Tất cả";
  String? selectedOrderId;
  bool isTextFieldEnabled = false;
  bool isSearching = false; //dùng để phân trang cho tìm kiếm
  bool isSeenOrder = false;

  int currentPage = 1;
  int pageSize = 25;
  int pageSizeSearch = 20;

  @override
  void initState() {
    super.initState();
    loadOrders(true, isSeenOrder);

    columns = buildOrderColumns();
  }

  void loadOrders(bool refresh, bool ownOnly) {
    setState(() {
      if (isSearching) {
        String keyword = searchController.text.trim().toLowerCase();

        if (searchType == "Tên KH") {
          futureOrdersAccept = ensureMinLoading(
            OrderService().getOrderByCustomerName(
              inputCustomerName: keyword,
              page: currentPage,
              pageSize: pageSizeSearch,
            ),
          );
        } else if (searchType == "Tên SP") {
          futureOrdersAccept = ensureMinLoading(
            OrderService().getOrderByProductName(
              inputProductName: keyword,
              page: currentPage,
              pageSize: pageSizeSearch,
            ),
          );
        } else if (searchType == "QC Thùng") {
          futureOrdersAccept = ensureMinLoading(
            OrderService().getOrderByQcBox(
              inputQcBox: keyword,
              page: currentPage,
              pageSize: pageSizeSearch,
            ),
          );
        } else if (searchType == "Đơn giá") {
          futureOrdersAccept = ensureMinLoading(
            OrderService().getOrderByPrice(
              price: keyword,
              page: currentPage,
              pageSize: pageSizeSearch,
            ),
          );
        }
      } else {
        futureOrdersAccept = ensureMinLoading(
          OrderService().getOrderAcceptAndPlanning(
            page: currentPage,
            pageSize: pageSize,
            refresh: refresh,
            ownOnly: ownOnly,
          ),
        );
      }
    });
  }

  void searchOrders() {
    String keyword = searchController.text.trim().toLowerCase();
    if (isTextFieldEnabled && keyword.isEmpty) return;

    currentPage = 1;
    if (searchType == "Tất cả") {
      setState(() {
        futureOrdersAccept = OrderService().getOrderAcceptAndPlanning(
          page: currentPage,
          pageSize: pageSize,
          refresh: false,
          ownOnly: false,
        );
      });
    } else if (searchType == "Tên KH") {
      isSearching = true;
      setState(() {
        futureOrdersAccept = OrderService().getOrderByCustomerName(
          inputCustomerName: keyword,
          page: currentPage,
          pageSize: pageSizeSearch,
        );
      });
    } else if (searchType == "Tên SP") {
      isSearching = true;
      setState(() {
        futureOrdersAccept = OrderService().getOrderByProductName(
          inputProductName: keyword,
          page: currentPage,
          pageSize: pageSizeSearch,
        );
      });
    } else if (searchType == "QC Thùng") {
      isSearching = true;
      setState(() {
        futureOrdersAccept = OrderService().getOrderByQcBox(
          inputQcBox: keyword,
          page: currentPage,
          pageSize: pageSizeSearch,
        );
      });
    } else if (searchType == "Đơn giá") {
      isSearching = true;
      setState(() {
        futureOrdersAccept = OrderService().getOrderByPrice(
          price: keyword,
          page: currentPage,
          pageSize: pageSizeSearch,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isManager = userController.hasAnyRole(['manager', 'admin']);

    return Scaffold(
      body: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(5),
        child: Column(
          children: [
            //button
            SizedBox(
              height: 70,
              width: double.infinity,
              child: Row(
                children: [
                  //left button
                  Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 10,
                    ),
                    child: Row(
                      children: [
                        // dropdown
                        SizedBox(
                          width: 140,
                          child: DropdownButtonFormField<String>(
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

                                searchController.clear();
                              });
                            },
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(
                                  color: Colors.grey,
                                ),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),

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
                        AnimatedButton(
                          onPressed: () {
                            searchOrders();
                          },
                          label: "Tìm kiếm",
                          icon: Icons.search,
                        ),
                        const SizedBox(width: 10),

                        //see all/see only
                        isManager
                            ? SizedBox(
                              width: 150,
                              child: AnimatedButton(
                                onPressed: () {
                                  setState(() {
                                    isSeenOrder = !isSeenOrder;
                                  });

                                  loadOrders(false, isSeenOrder);
                                },
                                label:
                                    isSeenOrder ? "Xem Tất Cả" : "Đơn Bản Thân",
                                icon: null,
                              ),
                            )
                            : const SizedBox.shrink(),
                        const SizedBox(width: 10),
                      ],
                    ),
                  ),
                  const SizedBox(width: 15),

                  //button
                  Center(
                    child: const Text(
                      "ĐƠN HÀNG ĐÃ DUYỆT/CHỜ LÊN KẾ HOẠCH",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 25,
                        color: Color(0xffcfa381),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // table
            Expanded(
              child: FutureBuilder<Map<String, dynamic>>(
                future: futureOrdersAccept,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: SizedBox(
                        height: 400,
                        child: buildShimmerSkeletonTable(
                          context: context,
                          rowCount: 10,
                        ),
                      ),
                    );
                  } else if (snapshot.hasError) {
                    return Center(child: Text("Lỗi: ${snapshot.error}"));
                  } else if (!snapshot.hasData ||
                      //get data from paging
                      snapshot.data!['orders'].isEmpty) {
                    return const Center(
                      child: Text(
                        "Không có đơn hàng nào",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                        ),
                      ),
                    );
                  }

                  final data = snapshot.data!;
                  final orders = data['orders'] as List<Order>;
                  final currentPg =
                      data['currentPage']; //current page of response
                  final totalPgs = data['totalPages']; //total  page of response

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
                          isScrollbarAlwaysShown: true,
                          selectionMode: SelectionMode.single,
                          columnWidthMode: ColumnWidthMode.auto,
                          columns: columns,
                          headerRowHeight: 40,
                          rowHeight: 45,
                          stackedHeaderRows: <StackedHeaderRow>[
                            StackedHeaderRow(
                              cells: [
                                StackedHeaderCell(
                                  columnNames: [
                                    'inMatTruoc',
                                    'inMatSau',
                                    'canMang',
                                    'canLanBox',
                                    'xa',
                                    'catKhe',
                                    'be',
                                    'dan_1_Manh',
                                    'dan_2_Manh',
                                    'dongGhimMotManh',
                                    'dongGhimHaiManh',
                                    'chongTham',
                                    'dongGoi',
                                    'maKhuon',
                                  ],
                                  child: formatColumn('Công Đoạn 2'),
                                ),
                              ],
                            ),
                          ],
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
                      PaginationControls(
                        currentPage: currentPg,
                        totalPages: totalPgs,
                        onPrevious: () {
                          setState(() {
                            currentPage--;
                            loadOrders(false, isSeenOrder);
                          });
                        },
                        onNext: () {
                          setState(() {
                            currentPage++;
                            loadOrders(false, isSeenOrder);
                          });
                        },
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => loadOrders(true, isSeenOrder),
        backgroundColor: const Color(0xff78D761),
        child: const Icon(Icons.refresh, color: Colors.white),
      ),
    );
  }
}
