import 'package:dongtam/data/controller/theme_controller.dart';
import 'package:dongtam/data/controller/user_controller.dart';
import 'package:dongtam/data/models/warehouse/outbound/outbound_detail_model.dart';
import 'package:dongtam/data/models/warehouse/outbound/outbound_history_model.dart';
import 'package:dongtam/presentation/components/dialog/add/dialog_add_outbound.dart';
import 'package:dongtam/presentation/components/headerTable/warehouse/header_table_ob_detail.dart';
import 'package:dongtam/presentation/components/headerTable/warehouse/header_table_ob_history.dart';
import 'package:dongtam/presentation/components/shared/animated_button.dart';
import 'package:dongtam/presentation/components/shared/left_button_search.dart';
import 'package:dongtam/presentation/sources/outbound/ob_detail_data_source.dart';
import 'package:dongtam/presentation/sources/outbound/ob_history_data_source.dart';
import 'package:dongtam/service/warehouse_service.dart';
import 'package:dongtam/utils/helper/grid_resize_helper.dart';
import 'package:dongtam/presentation/components/shared/pagination_controls.dart';
import 'package:dongtam/utils/helper/skeleton/skeleton_loading.dart';
import 'package:dongtam/utils/logger/app_logger.dart';
import 'package:dongtam/utils/storage/sharedPreferences/column_width_table.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class OutboundHistory extends StatefulWidget {
  const OutboundHistory({super.key});

  @override
  State<OutboundHistory> createState() => _OutboundHistoryState();
}

class _OutboundHistoryState extends State<OutboundHistory> {
  late Future<Map<String, dynamic>> futureOutbound;
  late ObHistoryDataSource obHistoryDataSource;
  late List<GridColumn> columnsOutbound;
  late List<GridColumn> columnsObDetail;
  final userController = Get.find<UserController>();
  final themeController = Get.find<ThemeController>();

  final Map<String, String> searchFieldMap = {
    "Theo Mã Đơn": "orderId",
    "Ghép Khổ": "ghepKho",
    "Theo Máy": "machine",
    "Tên Khách Hàng": "customerName",
    "Tên Công Ty": "companyName",
    "Tên Nhân Viên": "username",
  };
  String searchType = "Tất cả";

  TextEditingController searchController = TextEditingController();
  Map<String, double> columnWidthsOutbound = {};
  Map<String, double> columnWidthsObDetail = {};
  bool selectedAll = false;
  bool isTextFieldEnabled = false;
  bool isSearching = false; //dùng để phân trang cho tìm kiếm
  int? selectedOutboundId;
  List<OutboundDetailModel> selectedObDetail = [];

  int currentPage = 1;
  int pageSize = 25;
  int pageSizeSearch = 20;

  @override
  void initState() {
    super.initState();
    loadOutbound();

    columnsOutbound = buildOutboundHistoryColumn(themeController: themeController);
    columnsObDetail = buildOutboundDetailColumn(themeController: themeController);

    ColumnWidthTable.loadWidths(tableKey: 'outbound', columns: columnsOutbound).then((w) {
      setState(() {
        columnWidthsOutbound = w;
      });
    });

    ColumnWidthTable.loadWidths(tableKey: 'obDetail', columns: columnsObDetail).then((w) {
      setState(() {
        columnWidthsObDetail = w;
      });
    });
  }

  void loadOutbound() {
    setState(() {
      // final String selectedField = searchFieldMap[searchType] ?? "";

      String keyword = searchController.text.trim().toLowerCase();

      if (isSearching && searchType != "Tất cả") {
        AppLogger.i("loadOutbound: isSearching=true, keyword='$keyword'");

        // futureOutbound = ensureMinLoading(
        //   DashboardService().getDbPlanningByFields(
        //     field: selectedField,
        //     keyword: keyword,
        //     page: currentPage,
        //     pageSize: pageSizeSearch,
        //   ),
        // );
      } else {
        futureOutbound = ensureMinLoading(
          WarehouseService().getOutboundHistory(page: currentPage, pageSize: pageSize),
        );
      }

      selectedOutboundId = null;
      selectedObDetail = [];
    });
  }

  void searchOutbound() {
    String keyword = searchController.text.trim().toLowerCase();
    AppLogger.i("searchOutbound: searchType=$searchType, keyword='$keyword'");

    if (isTextFieldEnabled && keyword.isEmpty) {
      AppLogger.w("searchOutbound: search bị bỏ qua vì keyword trống");
      return;
    }

    setState(() {
      currentPage = 1;
      isSearching = (searchType != "Tất cả");

      if (searchType == "Tất cả") {
        futureOutbound = ensureMinLoading(
          WarehouseService().getOutboundHistory(page: currentPage, pageSize: pageSize),
        );
      } else {
        // final selectedField = searchFieldMap[searchType] ?? "";

        // futureOutbound = ensureMinLoading(
        //   DashboardService().getDbPlanningByFields(
        //     field: selectedField,
        //     keyword: keyword,
        //     page: currentPage,
        //     pageSize: pageSizeSearch,
        //   ),
        // );
      }

      selectedOutboundId = null;
      selectedObDetail = [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(5),
        child: Column(
          children: [
            //button
            SizedBox(
              height: 105,
              width: double.infinity,
              child: Column(
                children: [
                  //title
                  SizedBox(
                    height: 35,
                    width: double.infinity,
                    child: Center(
                      child: Text(
                        "XUẤT KHO",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                          color: themeController.currentColor.value,
                        ),
                      ),
                    ),
                  ),

                  //button
                  SizedBox(
                    height: 70,
                    width: double.infinity,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        //left button
                        Expanded(
                          flex: 1,
                          child: LeftButtonSearch(
                            selectedType: searchType,
                            types: const [
                              'Tất cả',
                              "Theo Mã Đơn",
                              "Ghép Khổ",
                              "Theo Máy",
                              "Tên Khách Hàng",
                              "Tên Công Ty",
                              "Tên Nhân Viên",
                            ],
                            onTypeChanged: (value) {
                              setState(() {
                                searchType = value;
                                isTextFieldEnabled = value != 'Tất cả';
                                searchController.clear();
                              });
                            },
                            controller: searchController,
                            textFieldEnabled: isTextFieldEnabled,
                            buttonColor: themeController.buttonColor,
                            onSearch: () => searchOutbound(),
                            minDropdownWidth: 170,
                            maxDropdownWidth: 200,
                          ),
                        ),

                        //right button
                        Expanded(
                          flex: 1,
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                AnimatedButton(
                                  onPressed: () async {
                                    showDialog(
                                      context: context,
                                      builder:
                                          (_) => OutBoundDialog(
                                            outboundHistory: null,
                                            onOutboundHistory: () => loadOutbound(),
                                          ),
                                    );
                                  },
                                  label: "Xuất Kho",
                                  icon: Symbols.input,
                                  backgroundColor: themeController.buttonColor,
                                ),
                                const SizedBox(width: 10),
                              ],
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
                future: futureOutbound,
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
                  } else if (!snapshot.hasData || snapshot.data!['outbounds'].isEmpty) {
                    return const Center(
                      child: Text(
                        "Không có đơn hàng nào",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
                      ),
                    );
                  }

                  final data = snapshot.data!;
                  final outbounds = data['outbounds'] as List<OutboundHistoryModel>;
                  final currentPg = data['currentPage'];
                  final totalPgs = data['totalPages'];

                  obHistoryDataSource = ObHistoryDataSource(
                    outbounds: outbounds,
                    selectedOutboundId: selectedOutboundId,
                  );

                  return Column(
                    children: [
                      //table
                      Expanded(
                        child: Column(
                          children: [
                            Expanded(
                              flex: 2,
                              child: SfDataGrid(
                                source: obHistoryDataSource,
                                isScrollbarAlwaysShown: true,
                                columnWidthMode: ColumnWidthMode.fill,
                                selectionMode: SelectionMode.single,
                                headerRowHeight: 45,
                                rowHeight: 40,
                                columns: ColumnWidthTable.applySavedWidths(
                                  columns: columnsOutbound,
                                  widths: columnWidthsOutbound,
                                ),

                                //auto resize
                                allowColumnsResizing: true,
                                columnResizeMode: ColumnResizeMode.onResize,

                                onColumnResizeStart: GridResizeHelper.onResizeStart,
                                onColumnResizeUpdate:
                                    (details) => GridResizeHelper.onResizeUpdate(
                                      details: details,
                                      columns: columnsOutbound,
                                      setState: setState,
                                    ),
                                onColumnResizeEnd:
                                    (details) => GridResizeHelper.onResizeEnd(
                                      details: details,
                                      tableKey: 'outbound',
                                      columnWidths: columnWidthsOutbound,
                                      setState: setState,
                                    ),

                                onSelectionChanged: (addedRows, removedRows) async {
                                  if (addedRows.isEmpty) {
                                    setState(() {
                                      selectedOutboundId = null;
                                    });
                                    return;
                                  }

                                  final selectedRow = addedRows.first;

                                  final outboundId =
                                      selectedRow
                                          .getCells()
                                          .firstWhere((cell) => cell.columnName == 'outboundId')
                                          .value;

                                  // Lấy data của list (summary)
                                  final selectedOutbound = outbounds.firstWhere(
                                    (ob) => ob.outboundId == outboundId,
                                  );

                                  setState(() {
                                    selectedOutboundId = selectedOutbound.outboundId;
                                  });

                                  final detail = await WarehouseService().getOutboundDetail(
                                    outboundId: selectedOutbound.outboundId,
                                  );

                                  setState(() {
                                    selectedObDetail = detail;
                                  });
                                },
                              ),
                            ),

                            selectedObDetail.isNotEmpty
                                ? Expanded(
                                  flex: 1,
                                  child: AnimatedSize(
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeInOut,
                                    child: SfDataGrid(
                                      source: ObDetailDataSource(detail: selectedObDetail),
                                      isScrollbarAlwaysShown: true,
                                      headerRowHeight: 30,
                                      rowHeight: 35,
                                      columnWidthMode: ColumnWidthMode.fill,
                                      selectionMode: SelectionMode.single,
                                      columns: ColumnWidthTable.applySavedWidths(
                                        columns: columnsObDetail,
                                        widths: columnWidthsObDetail,
                                      ),

                                      //auto resize
                                      allowColumnsResizing: true,
                                      columnResizeMode: ColumnResizeMode.onResize,

                                      onColumnResizeStart: GridResizeHelper.onResizeStart,
                                      onColumnResizeUpdate:
                                          (details) => GridResizeHelper.onResizeUpdate(
                                            details: details,
                                            columns: columnsObDetail,
                                            setState: setState,
                                          ),
                                      onColumnResizeEnd:
                                          (details) => GridResizeHelper.onResizeEnd(
                                            details: details,
                                            tableKey: 'obDetail',
                                            columnWidths: columnWidthsObDetail,
                                            setState: setState,
                                          ),
                                    ),
                                  ),
                                )
                                : const SizedBox.shrink(),
                          ],
                        ),
                      ),

                      // Nút chuyển trang
                      PaginationControls(
                        currentPage: currentPg,
                        totalPages: totalPgs,
                        onPrevious: () {
                          setState(() {
                            currentPage--;
                            loadOutbound();
                          });
                        },
                        onNext: () {
                          setState(() {
                            currentPage++;
                            loadOutbound();
                          });
                        },
                        onJumpToPage: (page) {
                          setState(() {
                            currentPage = page;
                            loadOutbound();
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
        onPressed: () => loadOutbound(),
        backgroundColor: themeController.buttonColor.value,
        child: const Icon(Icons.refresh, color: Colors.white),
      ),
    );
  }
}
