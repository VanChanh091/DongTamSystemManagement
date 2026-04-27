import 'package:dongtam/data/controller/theme_controller.dart';
import 'package:dongtam/data/controller/user_controller.dart';
import 'package:dongtam/data/models/order/order_model.dart';
import 'package:dongtam/presentation/components/headerTable/header_table_order.dart';
import 'package:dongtam/presentation/components/shared/left_button_search.dart';
import 'package:dongtam/presentation/sources/order_data_source.dart';
import 'package:dongtam/service/order_service.dart';
import 'package:dongtam/presentation/components/shared/animated_button.dart';
import 'package:dongtam/utils/helper/grid_resize_helper.dart';
import 'package:dongtam/utils/helper/skeleton/skeleton_loading.dart';
import 'package:dongtam/utils/logger/app_logger.dart';
import 'package:dongtam/utils/storage/sharedPreferences/column_width_table.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class OrderAccept extends StatefulWidget {
  const OrderAccept({super.key});

  @override
  State<OrderAccept> createState() => _OrderAcceptAndPlanningState();
}

class _OrderAcceptAndPlanningState extends State<OrderAccept> {
  late Future<Map<String, dynamic>> futureOrdersAccept;
  late OrderDataSource orderDataSource;
  late List<GridColumn> columns;

  final formatter = DateFormat('dd/MM/yyyy');

  //controllers
  final userController = Get.find<UserController>();
  final themeController = Get.find<ThemeController>();

  //search
  String searchType = "Tất cả";
  final Map<String, String> searchFieldMap = {
    "Mã Đơn Hàng": "orderId",
    "Tên Khách Hàng": "customerName",
    "Tên Sản Phẩm": "productName",
    "QC Thùng": "qcBox",
    "Đơn Giá": "price",
  };

  String? selectedOrderId;
  Map<String, double> columnWidths = {};
  TextEditingController searchController = TextEditingController();

  //flag
  bool isTextFieldEnabled = false;
  bool isSearching = false; //dùng để phân trang cho tìm kiếm
  bool isSeenOrder = false;

  @override
  void initState() {
    super.initState();
    loadOrders(ownOnly: isSeenOrder);

    columns = buildOrderColumns(themeController: themeController, userController: userController);

    ColumnWidthTable.loadWidths(tableKey: 'order', columns: columns).then((w) {
      setState(() {
        columnWidths = w;
      });
    });
  }

  // void _fetchData({bool ownOnly = false}) {
  //   final String keyword = searchController.text.trim().toLowerCase();
  //   final String selectedField = searchFieldMap[searchType] ?? "";

  //   // Điều kiện để xác định có thực hiện search hay load mặc định
  //   final bool shouldSearch = isSearching && searchType != "Tất cả";

  //   futureOrdersAccept = ensureMinLoading(
  //     OrderService().getOrderAcceptted(
  //       field: shouldSearch ? selectedField : null,
  //       keyword: shouldSearch ? keyword : null,
  //       ownOnly: ownOnly,
  //     ),
  //   );

  //   selectedOrderId = null;
  // }

  void loadOrders({bool ownOnly = false}) {
    setState(() {
      final String selectedField = searchFieldMap[searchType] ?? "";

      String keyword = searchController.text.trim().toLowerCase();

      if (isSearching && searchType != "Tất cả" && keyword.isNotEmpty) {
        AppLogger.d("loadOrderAccept_Planning: isSearching=true | keyword='$keyword'");

        futureOrdersAccept = ensureMinLoading(
          OrderService().getOrderAcceptted(field: selectedField, keyword: keyword),
        );
      } else {
        futureOrdersAccept = ensureMinLoading(OrderService().getOrderAcceptted(ownOnly: ownOnly));
      }
    });

    selectedOrderId = null;
  }

  void searchOrders() {
    String keyword = searchController.text.trim().toLowerCase();
    AppLogger.i("searchOrder => searchType=$searchType | keyword=$keyword");

    if (isTextFieldEnabled && keyword.isEmpty) {
      AppLogger.w("searchOrder => searchType=$searchType nhưng keyword rỗng");
      return;
    }

    setState(() {
      isSearching = (searchType != "Tất cả");

      if (searchType == "Tất cả") {
        futureOrdersAccept = ensureMinLoading(OrderService().getOrderAcceptted(ownOnly: false));
      } else {
        final selectedField = searchFieldMap[searchType] ?? "";

        futureOrdersAccept = ensureMinLoading(
          OrderService().getOrderAcceptted(field: selectedField, keyword: keyword),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isManager = userController.hasAnyRole(roles: ['manager', 'admin']);

    return Scaffold(
      body: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(5),
        child: Column(
          children: [
            //button
            SizedBox(
              height: 100,
              width: double.infinity,
              child: Column(
                children: [
                  SizedBox(
                    height: 30,
                    width: double.infinity,
                    child: Center(
                      child: Obx(
                        () => Text(
                          "ĐƠN HÀNG ĐÃ DUYỆT/CHỜ LÊN KẾ HOẠCH",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 22,
                            color: themeController.currentColor.value,
                          ),
                        ),
                      ),
                    ),
                  ),

                  SizedBox(
                    height: 70,
                    width: double.infinity,
                    child: Row(
                      children: [
                        //button
                        Expanded(
                          flex: 1,
                          child: LeftButtonSearch(
                            selectedType: searchType,
                            types: const [
                              'Tất cả',
                              "Mã Đơn Hàng",
                              "Tên Khách Hàng",
                              "Tên Sản Phẩm",
                              "QC Thùng",
                              'Đơn giá',
                            ],
                            onTypeChanged: (value) {
                              setState(() {
                                searchType = value;
                                isTextFieldEnabled = value != 'Tất cả';
                                searchType == 'Tất cả' ? searchController.clear() : null;
                              });
                            },
                            controller: searchController,
                            textFieldEnabled: isTextFieldEnabled,
                            buttonColor: themeController.buttonColor,
                            onSearch: () => searchOrders(),
                            extraWidgets: [
                              isManager
                                  ? AnimatedButton(
                                    onPressed: () {
                                      setState(() {
                                        isSeenOrder = !isSeenOrder;
                                      });
                                      loadOrders(ownOnly: isSeenOrder);
                                    },
                                    label: isSeenOrder ? "Xem Tất Cả" : "Đơn Bản Thân",
                                    icon: null,
                                    backgroundColor: themeController.buttonColor,
                                  )
                                  : const SizedBox.shrink(),
                            ],
                          ),
                        ),

                        //right button
                        Expanded(flex: 1, child: Container()),
                      ],
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
                        child: buildShimmerSkeletonTable(context: context, rowCount: 10),
                      ),
                    );
                  } else if (snapshot.hasError) {
                    return Center(child: Text("Lỗi: ${snapshot.error}"));
                  } else if (!snapshot.hasData || snapshot.data!['orders'].isEmpty) {
                    return const Center(
                      child: Text(
                        "Không có đơn hàng nào",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
                      ),
                    );
                  }

                  final data = snapshot.data!;
                  final orders = data['orders'] as List<Order>;

                  orderDataSource = OrderDataSource(
                    context: context,
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
                          headerRowHeight: 40,
                          rowHeight: 40,
                          columns: ColumnWidthTable.applySavedWidths(
                            columns: columns,
                            widths: columnWidths,
                          ),

                          //auto resize
                          allowColumnsResizing: true,
                          columnResizeMode: ColumnResizeMode.onResize,

                          onColumnResizeStart: GridResizeHelper.onResizeStart,
                          onColumnResizeUpdate:
                              (details) => GridResizeHelper.onResizeUpdate(
                                details: details,
                                columns: columns,
                                setState: setState,
                              ),
                          onColumnResizeEnd:
                              (details) => GridResizeHelper.onResizeEnd(
                                details: details,
                                tableKey: 'order',
                                columnWidths: columnWidths,
                                setState: setState,
                              ),

                          onSelectionChanged: (addedRows, removedRows) {
                            if (addedRows.isNotEmpty) {
                              final selectedRow = addedRows.first;
                              final orderId = selectedRow.getCells()[0].value.toString();
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
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Obx(
        () => FloatingActionButton(
          onPressed: () => loadOrders(ownOnly: isSeenOrder),
          backgroundColor: themeController.buttonColor.value,
          child: const Icon(Icons.refresh, color: Colors.white),
        ),
      ),
    );
  }
}
