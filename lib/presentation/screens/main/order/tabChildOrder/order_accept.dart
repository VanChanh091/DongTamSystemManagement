import "package:dongtam/data/controller/theme_controller.dart";
import "package:dongtam/data/controller/user_controller.dart";
import "package:dongtam/data/models/order/order_model.dart";
import "package:dongtam/presentation/components/dialog/notification/dialog_order_notification.dart";
import "package:dongtam/presentation/components/headerTable/header_table_order.dart";
import "package:dongtam/presentation/components/shared/left_button_search.dart";
import "package:dongtam/presentation/components/shared/slider_zoom.dart";
import "package:dongtam/presentation/sources/order_data_source.dart";
import "package:dongtam/service/order_service.dart";
import "package:dongtam/presentation/components/shared/animation/animated_button.dart";
import "package:dongtam/presentation/components/shared/grid_resize_helper.dart";
import "package:dongtam/utils/helper/skeleton/skeleton_loading.dart";
import "package:dongtam/utils/helper/style_table.dart";
import "package:dongtam/utils/logger/app_logger.dart";
import "package:dongtam/utils/storage/sharedPreferences/column_width_table.dart";
import "package:flutter/material.dart";
import "package:intl/intl.dart";
import "package:get/get.dart";
import "package:syncfusion_flutter_core/theme.dart";
import "package:syncfusion_flutter_datagrid/datagrid.dart";

class OrderAccept extends StatefulWidget {
  const OrderAccept({super.key});

  @override
  State<OrderAccept> createState() => _OrderAcceptAndPlanningState();
}

class _OrderAcceptAndPlanningState extends State<OrderAccept> {
  late Future<Map<String, dynamic>> futureOrdersAccept;
  late List<GridColumn> columns;

  //controllers
  final formatter = DateFormat("dd/MM/yyyy");
  final userController = Get.find<UserController>();
  final themeController = Get.find<ThemeController>();

  //search
  String searchType = "Tất cả";
  final Map<String, String> searchFieldMap = {
    "Mã Đơn Hàng": "orderId",
    "Tên Khách Hàng": "customerName",
    "Tên Sản Phẩm": "productName",
    "QC Thùng": "qcBox",
  };

  final _zoomNotifier = ValueNotifier<double>(1.0);
  final _selectedOrderIdNotifier = ValueNotifier<String?>(null);
  Map<String, double> columnWidths = {};

  //datasource and cache
  List<OrderModel>? _cachedOrders;
  OrderDataSource? _cachedDatasource;

  //text controller
  final searchController = TextEditingController();
  final headerScrollController = ScrollController();

  //flag
  late bool isManager;
  bool isTextFieldEnabled = false;
  bool isSearching = false; //dùng để phân trang cho tìm kiếm
  bool isSeenOrder = false;

  @override
  void initState() {
    super.initState();
    loadOrders(ownOnly: isSeenOrder);

    isManager = userController.hasAnyRole(roles: ["manager", "admin"]);

    columns = buildOrderColumns(themeController: themeController, userController: userController);
    ColumnWidthTable.loadWidths(tableKey: "order", columns: columns).then((w) {
      setState(() {
        columnWidths = w;
      });
    });
  }

  void loadOrders({required bool ownOnly}) {
    setState(() {
      final String keyword = searchController.text.trim().toLowerCase();
      final String selectedField = searchFieldMap[searchType] ?? "";

      if (isSearching && searchType != "Tất cả" && keyword.isNotEmpty) {
        futureOrdersAccept = ensureMinLoading(
          OrderService().getOrderAcceptted(field: selectedField, keyword: keyword),
        );
      } else {
        futureOrdersAccept = ensureMinLoading(OrderService().getOrderAcceptted(ownOnly: ownOnly));
      }
    });
    _selectedOrderIdNotifier.value = null;
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

  void _updateZoom(double newZoom) {
    _zoomNotifier.value = newZoom.clamp(0.5, 1.5);
  }

  @override
  void dispose() {
    super.dispose();
    searchController.dispose();
    _zoomNotifier.dispose();
    _selectedOrderIdNotifier.dispose();
    headerScrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: themeController.backgroundColor.value, // Nền xám nhạt giúp bảng nổi bật
      body: Listener(
        onPointerSignal:
            (pointerSignal) => handleScrollZoom(
              pointerSignal: pointerSignal,
              currentZoom: _zoomNotifier.value,
              onZoomChanged: _updateZoom,
            ),

        child: Stack(
          children: [
            ValueListenableBuilder<double>(
              valueListenable: _zoomNotifier,
              builder: (context, zoom, cachedChild) {
                return LayoutBuilder(
                  builder: (context, constraints) {
                    return SizedBox(
                      width: constraints.maxWidth,
                      height: constraints.maxHeight,
                      child: OverflowBox(
                        minWidth: constraints.maxWidth / zoom,
                        maxWidth: constraints.maxWidth / zoom,
                        minHeight: constraints.maxHeight / zoom,
                        maxHeight: constraints.maxHeight / zoom,
                        alignment: Alignment.topLeft,
                        child: Transform.scale(
                          scale: zoom,
                          alignment: Alignment.topLeft,
                          child: cachedChild,
                        ),
                      ),
                    );
                  },
                );
              },

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // title & buttons
                  Container(padding: const EdgeInsets.all(12), child: _buildHeaderBar()),

                  //table & pagination
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: _buildTableSection(),
                    ),
                  ),
                ],
              ),
            ),

            //slider zoom
            ValueListenableBuilder<double>(
              valueListenable: _zoomNotifier,
              builder: (context, zoom, _) {
                return SliderZoom(
                  zoomLevel: zoom,
                  onZoomChanged: _updateZoom,
                  // initialMargin: Offset(73, 173),
                  initialMargin: Offset(73, 200),
                  buttonColor: themeController.buttonColor.value,
                );
              },
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

  Widget _buildHeaderBar() {
    return Column(
      children: [
        //title
        Text(
          "ĐƠN HÀNG ĐÃ DUYỆT/CHỜ LÊN KẾ HOẠCH",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: themeController.currentColor.value,
          ),
        ),
        const SizedBox(height: 8),

        LayoutBuilder(
          builder: (context, constraints) {
            return Scrollbar(
              controller: headerScrollController,
              child: SingleChildScrollView(
                controller: headerScrollController,
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.only(bottom: 5),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minWidth: constraints.maxWidth),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      //left button
                      LeftButtonSearch(
                        selectedType: searchType,
                        types: const [
                          "Tất cả",
                          "Mã Đơn Hàng",
                          "Tên Khách Hàng",
                          "Tên Sản Phẩm",
                          "QC Thùng",
                        ],
                        onTypeChanged: (value) {
                          setState(() {
                            searchType = value;
                            isTextFieldEnabled = value != "Tất cả";

                            if (searchType == "Tất cả" && searchController.text.isNotEmpty) {
                              searchController.clear();
                              loadOrders(ownOnly: isSeenOrder);
                            }
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
                      const SizedBox(width: 20),

                      //right button
                      ValueListenableBuilder(
                        valueListenable: _selectedOrderIdNotifier,
                        builder: (context, selectedOrderId, _) {
                          final bool hasSelection =
                              selectedOrderId != null && selectedOrderId.isNotEmpty;

                          return Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              //send request
                              AnimatedButton(
                                onPressed:
                                    hasSelection
                                        ? () {
                                          showDialog(
                                            context: context,
                                            builder:
                                                (_) => DialogOrderNotification(
                                                  orderId: selectedOrderId,
                                                  onLoading: () => loadOrders(ownOnly: isSeenOrder),
                                                ),
                                          );
                                        }
                                        : null,
                                label: "Gửi Yêu Cầu",
                                icon: Icons.send,
                                backgroundColor: themeController.buttonColor,
                              ),
                              const SizedBox(width: 4),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildTableSection() {
    return FutureBuilder(
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
        } else if (!snapshot.hasData || snapshot.data!["orders"].isEmpty) {
          return Container(
            color: themeController.backgroundColor.value,
            child: Center(
              child: Text(
                "Không có đơn hàng nào",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
              ),
            ),
          );
        }

        final data = snapshot.data!;
        final orders = data["orders"] as List<OrderModel>;

        if (_cachedOrders == null || _cachedOrders != orders) {
          _cachedOrders = orders;
          _cachedDatasource = OrderDataSource(
            context: context,
            orders: orders,
            selectedOrderId: _selectedOrderIdNotifier.value,
          );
        }

        return Column(
          children: [
            //table
            Expanded(
              child: StatefulBuilder(
                builder: (context, localSetState) {
                  return SfDataGridTheme(
                    data: SfDataGridThemeData(selectionColor: Colors.blue.withValues(alpha: 0.3)),
                    child: SfDataGrid(
                      source: _cachedDatasource!,
                      isScrollbarAlwaysShown: true,
                      selectionMode: SelectionMode.single,
                      columnWidthMode: ColumnWidthMode.auto,
                      headerRowHeight: 30,
                      rowHeight: 38,
                      columns: ColumnWidthTable.applySavedWidths(
                        columns: columns,
                        widths: columnWidths,
                      ),
                      stackedHeaderRows: <StackedHeaderRow>[
                        StackedHeaderRow(
                          cells: [
                            StackedHeaderCell(
                              columnNames: [
                                "sizeCustomer",
                                "sizeManufacture",
                                "lengthCus",
                                "lengthMf",
                              ],
                              child: Obx(
                                () => formatColumn(
                                  label: "Quy Cách Giấy (cm)",
                                  themeController: themeController,
                                ),
                              ),
                            ),
                            StackedHeaderCell(
                              columnNames: [
                                "price",
                                "pricePaper",
                                "discounts",
                                "profitOrd",
                                "totalPrice",
                              ],
                              child: Obx(
                                () => formatColumn(
                                  label: "Khoản Phí (VNĐ)",
                                  themeController: themeController,
                                ),
                              ),
                            ),
                            StackedHeaderCell(
                              columnNames: [
                                "inMatTruoc",
                                "inMatSau",
                                "canMang",
                                "canLanBox",
                                "xa",
                                "catKhe",
                                "be",
                                "dan_1_Manh",
                                "dan_2_Manh",
                                "dongGhimMotManh",
                                "dongGhimHaiManh",
                                "chongTham",
                                "dongGoi",
                                "maKhuon",
                              ],
                              child: Obx(
                                () => formatColumn(
                                  label: "Công Đoạn 2",
                                  themeController: themeController,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],

                      //auto resize
                      allowColumnsResizing: true,
                      columnResizeMode: ColumnResizeMode.onResize,

                      onColumnResizeStart: GridResizeHelper.onResizeStart,
                      onColumnResizeUpdate:
                          (details) => GridResizeHelper.onResizeUpdate(
                            details: details,
                            columns: columns,
                            setState: localSetState,
                          ),
                      onColumnResizeEnd:
                          (details) => GridResizeHelper.onResizeEnd(
                            details: details,
                            tableKey: "order",
                            columnWidths: columnWidths,
                            setState: setState,
                          ),

                      onSelectionChanged: (addedRows, removedRows) {
                        if (addedRows.isNotEmpty) {
                          final selectedRow = addedRows.first;
                          final orderId =
                              selectedRow
                                  .getCells()
                                  .firstWhere((cell) => cell.columnName == "orderId")
                                  .value
                                  .toString();

                          _selectedOrderIdNotifier.value = orderId;
                        } else {
                          _selectedOrderIdNotifier.value = null;
                        }
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
