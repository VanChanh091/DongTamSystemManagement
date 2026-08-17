import 'package:dongtam/data/controller/theme_controller.dart';
import 'package:dongtam/data/controller/user_controller.dart';
import 'package:dongtam/data/models/warehouse/inbound_history_model.dart';
import 'package:dongtam/presentation/components/dialog/export/dialog_export_inbound.dart';
import 'package:dongtam/presentation/components/headerTable/warehouse/header_report_inbound.dart';
import 'package:dongtam/presentation/components/shared/animation/animated_button.dart';
import 'package:dongtam/presentation/components/shared/left_button_search.dart';
import 'package:dongtam/presentation/sources/warehouse/report_inbound_data_source.dart';
import 'package:dongtam/service/warehouse_service.dart';
import 'package:dongtam/utils/helper/grid_resize_helper.dart';
import 'package:dongtam/presentation/components/shared/pagination_controls.dart';
import 'package:dongtam/utils/helper/skeleton/skeleton_loading.dart';
import 'package:dongtam/utils/helper/style_table.dart';
import 'package:dongtam/utils/logger/app_logger.dart';
import 'package:dongtam/utils/storage/sharedPreferences/column_width_table.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class ReportInboundHistory extends StatefulWidget {
  const ReportInboundHistory({super.key});

  @override
  State<ReportInboundHistory> createState() => _ReportInboundHistoryState();
}

class _ReportInboundHistoryState extends State<ReportInboundHistory> {
  late Future<Map<String, dynamic>> futureReportInbound;
  late ReportInboundDataSource reportInboundDataSource;
  late List<GridColumn> columns;

  //controller
  final userController = Get.find<UserController>();
  final themeController = Get.find<ThemeController>();
  final dataGridController = DataGridController();
  final headerScrollController = ScrollController();

  String searchType = "Tất cả";
  final Map<String, String> searchFieldMap = {
    "Mã Đơn Hàng": "orderId",
    "Tên Khách Hàng": "customerName",
    "Ngày Nhập Kho": "dateInbound",
    "Người Kiểm": "checkedBy",
  };

  //text controller
  TextEditingController searchController = TextEditingController();
  TextEditingController dateController = TextEditingController();

  //date range
  DateTime? startDate;
  DateTime? endDate;

  List<int> selectedInboundId = [];
  Map<String, double> columnWidths = {}; //map header table

  //flag
  bool isTextFieldEnabled = false;
  bool isSearching = false;

  //paging
  int currentPage = 1;
  int pageSize = 35;
  int pageSizeSearch = 30;

  @override
  void initState() {
    super.initState();
    loadReportInbound();

    columns = buildReportInboundColumn(themeController: themeController);

    ColumnWidthTable.loadWidths(tableKey: 'reportInbound', columns: columns).then((w) {
      setState(() {
        columnWidths = w;
      });
    });
  }

  void _fetchData() {
    final String keyword = searchController.text.trim().toLowerCase();
    final String selectedField = searchFieldMap[searchType] ?? "";

    // Điều kiện để xác định có thực hiện search hay load mặc định
    final bool shouldSearch = isSearching && searchType != "Tất cả";
    final bool isDateSearch = searchType == "Ngày Nhập Kho";

    futureReportInbound = ensureMinLoading(
      WarehouseService().getAllInboundHistory(
        page: currentPage,
        pageSize: pageSize,
        field: shouldSearch ? selectedField : null,
        keyword: shouldSearch ? keyword : null,
        startDate: (shouldSearch && isDateSearch) ? startDate : null,
        endDate: (shouldSearch && isDateSearch) ? endDate : null,
      ),
    );

    selectedInboundId.clear();
  }

  void loadReportInbound() {
    setState(() => _fetchData());
  }

  void searchReportInbound() {
    String keyword = searchController.text.trim().toLowerCase();
    final bool isDateSearch = searchType == "Ngày Nhập Kho";

    if (isDateSearch) {
      if (startDate == null || endDate == null) {
        AppLogger.w("searchOrders => chưa chọn khoảng thời gian");
        return;
      }
    } else if (isTextFieldEnabled && keyword.isEmpty) {
      AppLogger.w("searchReportInbound => searchType=$searchType nhưng keyword rỗng");
      return;
    }

    setState(() {
      currentPage = 1;
      isSearching = (searchType != "Tất cả");
      _fetchData();
    });
  }

  @override
  void dispose() {
    super.dispose();
    searchController.dispose();
    dateController.dispose();
    headerScrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isAccountant = userController.hasPermission(permission: "accountant");

    return Scaffold(
      backgroundColor: themeController.backgroundColor.value, // Nền xám nhạt giúp bảng nổi bật
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // title & buttons
          Container(padding: const EdgeInsets.all(12), child: _buildHeaderBar(isAccountant)),

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
      floatingActionButton: FloatingActionButton(
        onPressed: () => loadReportInbound(),
        backgroundColor: themeController.buttonColor.value,
        child: const Icon(Icons.refresh, color: Colors.white),
      ),
    );
  }

  Widget _buildHeaderBar(bool isAccountant) {
    return Column(
      children: [
        //title
        Text(
          "LỊCH SỬ NHẬP KHO",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: themeController.currentColor.value,
          ),
        ),
        const SizedBox(height: 8),

        //button
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
                          'Tất cả',
                          "Mã Đơn Hàng",
                          "Tên Khách Hàng",
                          "Ngày Nhập Kho",
                          "Người Kiểm",
                        ],
                        onTypeChanged: (value) {
                          setState(() {
                            searchType = value;
                            isTextFieldEnabled = value != 'Tất cả';

                            startDate = null;
                            endDate = null;

                            if (searchType == "Tất cả" && searchController.text.isNotEmpty) {
                              searchController.clear();
                              currentPage = 1;
                              _fetchData();
                            }
                          });
                        },
                        controller: searchController,
                        textFieldEnabled: isTextFieldEnabled,
                        buttonColor: themeController.buttonColor,
                        onSearch: () => searchReportInbound(),
                        customInputBuilder: (inputWidth) {
                          if (searchType != "Ngày Nhập Kho") return null;

                          return SizedBox(
                            width: inputWidth,
                            height: 50,
                            child: InkWell(
                              onTap: () async {
                                final now = DateTime.now();
                                final size = MediaQuery.of(context).size;

                                final DateTimeRange? picked = await showDateRangePicker(
                                  context: context,
                                  firstDate: DateTime(2025),
                                  lastDate: DateTime(2100),
                                  initialDateRange:
                                      (startDate != null && endDate != null)
                                          ? DateTimeRange(start: startDate!, end: endDate!)
                                          : DateTimeRange(
                                            start: now.subtract(const Duration(days: 7)),
                                            end: now,
                                          ),
                                  builder: (context, child) {
                                    return Center(
                                      child: ConstrainedBox(
                                        constraints: BoxConstraints(
                                          maxWidth: size.width * 0.3,
                                          maxHeight: size.height * 0.8,
                                        ),
                                        child: Material(
                                          borderRadius: BorderRadius.circular(16),
                                          clipBehavior: Clip.antiAlias,
                                          child: child!,
                                        ),
                                      ),
                                    );
                                  },
                                );

                                if (picked != null) {
                                  final displayStart = DateFormat(
                                    'dd/MM/yyyy',
                                  ).format(picked.start);
                                  final displayEnd = DateFormat('dd/MM/yyyy').format(picked.end);

                                  setState(() {
                                    startDate = picked.start;
                                    endDate = picked.end;
                                    searchController.text = '$displayStart - $displayEnd';
                                  });
                                }
                              },
                              child: IgnorePointer(
                                child: TextField(
                                  controller: searchController,
                                  decoration: InputDecoration(
                                    hintText: 'Chọn ngày...',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    suffixIcon: const Icon(Icons.calendar_today),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 20),

                      //right button
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          //export excel
                          isAccountant
                              ? AnimatedButton(
                                onPressed: () async {
                                  showDialog(
                                    context: context,
                                    builder: (_) => DialogExportInbound(),
                                  );
                                },
                                label: "Xuất Excel",
                                icon: Symbols.file_download,
                                backgroundColor: themeController.buttonColor,
                              )
                              : const SizedBox.shrink(),
                          const SizedBox(width: 8),
                        ],
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
      future: futureReportInbound,
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
        } else if (!snapshot.hasData || snapshot.data!['inbounds'].isEmpty) {
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
        final reportInbounds = data['inbounds'] as List<InboundHistoryModel>;
        final currentPg = data['currentPage'];
        final totalPgs = data['totalPages'];

        reportInboundDataSource = ReportInboundDataSource(
          reportInbounds: reportInbounds,
          selectedInboundId: selectedInboundId,
          currentPage: currentPage,
          pageSize: pageSize,
        );

        return Column(
          children: [
            //table
            Expanded(
              child: SfDataGrid(
                controller: dataGridController,
                source: reportInboundDataSource,
                isScrollbarAlwaysShown: true,
                allowExpandCollapseGroup: true, // Bật grouping
                autoExpandGroups: true,
                columnWidthMode: ColumnWidthMode.auto,
                navigationMode: GridNavigationMode.row,
                selectionMode: SelectionMode.multiple,
                headerRowHeight: 35,
                rowHeight: 40,
                columns: ColumnWidthTable.applySavedWidths(columns: columns, widths: columnWidths),
                stackedHeaderRows: <StackedHeaderRow>[
                  StackedHeaderRow(
                    cells: [
                      StackedHeaderCell(
                        columnNames: ['quantityOrd', 'qtyPaper', 'qtyInbound'],
                        child: Obx(
                          () => formatColumn(label: 'Số Lượng', themeController: themeController),
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
                      setState: setState,
                    ),
                onColumnResizeEnd:
                    (details) => GridResizeHelper.onResizeEnd(
                      details: details,
                      tableKey: 'reportInbound',
                      columnWidths: columnWidths,
                      setState: setState,
                    ),

                onSelectionChanged: (addedRows, removedRows) {
                  if (addedRows.isEmpty && removedRows.isEmpty) return;

                  setState(() {
                    final selectedRows = dataGridController.selectedRows;

                    selectedInboundId =
                        selectedRows
                            .map((row) {
                              final cell = row.getCells().firstWhere(
                                (c) => c.columnName == 'inboundId',
                                orElse:
                                    () => const DataGridCell(columnName: 'inboundId', value: ''),
                              );

                              return int.tryParse(cell.value.toString());
                            })
                            .where((id) => id != null)
                            .cast<int>()
                            .toList();

                    reportInboundDataSource.selectedInboundId = selectedInboundId;
                    reportInboundDataSource.notifyListeners();
                  });
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
                  loadReportInbound();
                });
              },
              onNext: () {
                setState(() {
                  currentPage++;
                  loadReportInbound();
                });
              },
              onJumpToPage: (page) {
                setState(() {
                  currentPage = page;
                  loadReportInbound();
                });
              },
            ),
          ],
        );
      },
    );
  }
}
