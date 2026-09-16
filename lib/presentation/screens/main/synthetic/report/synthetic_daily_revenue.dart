import 'package:dongtam/presentation/components/dialog/other/dialog_picker_month.dart';
import 'package:dongtam/utils/helper/style_table.dart';
import 'package:flutter/material.dart';
import 'package:dongtam/data/controller/theme_controller.dart';
import 'package:dongtam/data/controller/user_controller.dart';
import 'package:dongtam/data/models/reportRevenue/report_daily_revenue_model.dart';
import 'package:dongtam/presentation/components/headerTable/synthetic/report/header_table_daily_revenue.dart';
import 'package:dongtam/presentation/components/shared/left_button_search.dart';
import 'package:dongtam/presentation/components/shared/grid_resize_helper.dart';
import 'package:dongtam/presentation/components/shared/pagination_controls.dart';
import 'package:dongtam/presentation/components/shared/planning/widgets_planning.dart';
import 'package:dongtam/presentation/components/shared/slider_zoom.dart';
import 'package:dongtam/presentation/sources/synthetic/report/daily_revenue_data_source.dart';
import 'package:dongtam/service/customer_service.dart';
import 'package:dongtam/service/synthetic_service.dart';
import 'package:dongtam/utils/helper/helper_model.dart';
import 'package:dongtam/utils/helper/skeleton/skeleton_loading.dart';
import 'package:dongtam/utils/logger/app_logger.dart';
import 'package:dongtam/utils/storage/sharedPreferences/column_width_table.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class SyntheticDailyRevenue extends StatefulWidget {
  const SyntheticDailyRevenue({super.key});

  @override
  State<SyntheticDailyRevenue> createState() => _SyntheticDailyRevenueState();
}

class _SyntheticDailyRevenueState extends State<SyntheticDailyRevenue> {
  late Future<Map<String, dynamic>> futureSynthetic;
  late List<GridColumn> columns;

  // Controllers
  final userController = Get.find<UserController>();
  final themeController = Get.find<ThemeController>();

  final headerScrollController = ScrollController();
  final searchController = TextEditingController();

  //notifiers
  Map<String, double> columnWidths = {};
  final _zoomNotifier = ValueNotifier<double>(1.0);
  final _selectedCustomerIdNotifier = ValueNotifier<String?>(null);

  //sales user filter
  String selectedSalesUser = "Tất cả";
  String? selectedUserId;
  List<String> salesUserItems = ["Tất cả"];
  Map<String, String?> salesUserMap = {"Tất cả": null};

  // Datasource & Cache
  List<CustomerDailyRevenueRow>? _cachedDailyRevenue;
  DailyRevenueDataSource? _cachedDatasource;

  // Filter
  late int selectedMonth;
  late int selectedYear;
  late bool isManager;

  // Paging
  int currentPage = 1;
  int pageSize = 30;

  @override
  void initState() {
    super.initState();
    isManager = userController.hasAnyRole(roles: ["admin", "manager"]);

    final now = DateTime.now();
    selectedMonth = now.month;
    selectedYear = now.year;

    _loadSalesUsers();
    _loadDailyRevenue();

    columns = buildDailyRevenueColumn(themeController: themeController);
    ColumnWidthTable.loadWidths(tableKey: 'daily_revenue', columns: columns).then((w) {
      if (mounted) setState(() => columnWidths = w);
    });
  }

  String _getShortName(String fullName) {
    // Tách chuỗi theo khoảng trắng
    final parts = fullName.trim().split(RegExp(r"\s+"));

    // Nếu tên chỉ có 1 hoặc 2 từ thì giữ nguyên
    if (parts.length <= 2) {
      return fullName.trim();
    }

    // Lấy 2 từ cuối cùng và ghép lại
    return parts.sublist(parts.length - 2).join(" ");
  }

  Future<void> _loadSalesUsers() async {
    try {
      final users = await CustomerService().getUserSales();

      if (mounted) {
        setState(() {
          final Map<String, String?> newMap = {"Tất cả": null};
          final List<String> newItems = ["Tất cả"];

          for (final user in users) {
            final name = user.fullName?.trim();
            if (name != null && name.isNotEmpty) {
              final shortName = _getShortName(name);

              // Nếu tên chưa có trong danh sách thì mới thêm vào
              if (!newMap.containsKey(shortName)) {
                newItems.add(shortName);
                newMap[shortName] = user.userId.toString();
              }
            }
          }

          salesUserMap = newMap;
          salesUserItems = newItems;
        });
      }
    } catch (e, s) {
      AppLogger.e("Lỗi tải danh sách nhân viên sale: $e", error: e, stackTrace: s);
    }
  }

  void _fetchData() {
    final keyword = searchController.text.trim();

    futureSynthetic = ensureMinLoading(
      SyntheticService().getRevenueReport<CustomerDailyRevenueRow>(
        type: "daily",
        page: currentPage,
        pageSize: pageSize,
        month: selectedMonth,
        year: selectedYear,
        targetUserId: selectedUserId,
        keyword: keyword.isNotEmpty ? keyword : null,
        dataKey: "dailyRevenue",
        fromJson: (json) => CustomerDailyRevenueRow.fromJson(json),
      ),
    );

    _selectedCustomerIdNotifier.value = null;
  }

  void _loadDailyRevenue() {
    setState(() => _fetchData());
  }

  void _searchCustomer() {
    setState(() {
      currentPage = 1;
      _fetchData();
    });
  }

  void _updateZoom(double newZoom) {
    _zoomNotifier.value = newZoom.clamp(0.5, 1.5);
  }

  @override
  void dispose() {
    super.dispose();
    _zoomNotifier.dispose();
    _selectedCustomerIdNotifier.dispose();
    headerScrollController.dispose();
    searchController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: themeController.backgroundColor.value,
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

            // Zoom Control Floating
            ValueListenableBuilder<double>(
              valueListenable: _zoomNotifier,
              builder: (context, zoom, _) {
                return SliderZoom(
                  zoomLevel: zoom,
                  onZoomChanged: _updateZoom,
                  initialMargin: Offset(73, 200),
                  buttonColor: themeController.buttonColor.value,
                );
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _loadDailyRevenue(),
        backgroundColor: themeController.buttonColor.value,
        child: const Icon(Icons.refresh, color: Colors.white),
      ),
    );
  }

  Widget _buildHeaderBar() {
    return Column(
      children: [
        //title
        Text(
          "BÁO CÁO DOANH THU THEO NGÀY",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
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
                      // search
                      LeftButtonSearch(
                        showDropdown: false,
                        controller: searchController,
                        hintText: "Tìm theo khách hàng...",
                        buttonColor: themeController.buttonColor,
                        onSearch: _searchCustomer,
                      ),
                      const SizedBox(width: 12),

                      //buttons
                      ValueListenableBuilder(
                        valueListenable: _selectedCustomerIdNotifier,
                        builder: (context, selectedCustomerId, _) {
                          return Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                width: 180,
                                child: InkWell(
                                  onTap: () async {
                                    final result = await showMonthYearPickerDialog(
                                      context: context,
                                      initialMonth: selectedMonth,
                                      initialYear: selectedYear,
                                    );

                                    if (result != null) {
                                      // Kiểm tra nếu tháng hoặc năm có sự thay đổi
                                      final hasChanged =
                                          selectedMonth != result.month ||
                                          selectedYear != result.year;

                                      if (hasChanged) {
                                        setState(() {
                                          selectedMonth = result.month;
                                          selectedYear = result.year;
                                          currentPage = 1;
                                        });

                                        _loadDailyRevenue();
                                      }
                                    }
                                  },
                                  borderRadius: BorderRadius.circular(10),
                                  child: InputDecorator(
                                    decoration: InputDecoration(
                                      labelText: "Thời gian",
                                      filled: true,
                                      fillColor: Colors.white,
                                      suffixIcon: const Icon(Icons.calendar_month, size: 20),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 10,
                                      ),
                                    ),
                                    child: Text(
                                      "Tháng $selectedMonth / $selectedYear",
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),

                              if (isManager) ...[
                                buildDropdownItems(
                                  value:
                                      salesUserItems.contains(selectedSalesUser)
                                          ? selectedSalesUser
                                          : salesUserItems.first,
                                  items: salesUserItems,
                                  width: 160,
                                  onChanged: (value) {
                                    if (value != null && value != selectedSalesUser) {
                                      setState(() {
                                        selectedSalesUser = value;
                                        selectedUserId = salesUserMap[value];
                                        currentPage = 1;
                                        _loadDailyRevenue();
                                      });
                                    }
                                  },
                                ),
                                const SizedBox(width: 8),
                              ],
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
      future: futureSynthetic,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return buildShimmerSkeletonTable(context: context, rowCount: 10);
        }
        if (snapshot.hasError) {
          return Center(child: Text("Lỗi: ${snapshot.error}"));
        }

        final responseMap = snapshot.data;
        final rawList = responseMap?["dailyRevenue"] as List<CustomerDailyRevenueRow>?;

        if (responseMap == null || rawList == null || rawList.isEmpty) {
          return Container(
            color: themeController.backgroundColor.value,
            child: Center(
              child: Text(
                "Không có dữ liệu",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
              ),
            ),
          );
        }

        final List<CustomerDailyRevenueRow> customers = rawList;

        final int daysInMonth = toInt(responseMap['daysInMonth']);
        final currentPg = toInt(responseMap['currentPage']);
        final totalPgs = toInt(responseMap['totalPages']);

        DailyRevenueSummary? summary;
        if (responseMap['summary'] != null && responseMap['summary'] is Map<String, dynamic>) {
          summary = DailyRevenueSummary.fromJson(responseMap['summary'] as Map<String, dynamic>);
        }

        // Rebuild columns nếu daysInMonth thay đổi
        columns = buildDailyRevenueColumn(
          themeController: themeController,
          daysInMonth: daysInMonth,
        );

        if (_cachedDailyRevenue != customers || _cachedDatasource == null) {
          _cachedDailyRevenue = customers;
          _cachedDatasource = DailyRevenueDataSource(
            customers: customers,
            summary: summary,
            daysInMonth: daysInMonth,
            currentPage: currentPage,
            pageSize: pageSize,
          );
        }

        return Column(
          children: [
            Expanded(
              child: StatefulBuilder(
                builder: (context, localSetState) {
                  return SfDataGridTheme(
                    data: SfDataGridThemeData(selectionColor: Colors.blue.withValues(alpha: 0.3)),
                    child: SfDataGrid(
                      source: _cachedDatasource!,
                      isScrollbarAlwaysShown: true,
                      columnWidthMode: ColumnWidthMode.auto,
                      selectionMode: SelectionMode.single,
                      headerRowHeight: 33,
                      rowHeight: 38,
                      frozenColumnsCount: 4,
                      columns: ColumnWidthTable.applySavedWidths(
                        columns: columns,
                        widths: columnWidths,
                      ),
                      stackedHeaderRows: <StackedHeaderRow>[
                        StackedHeaderRow(
                          cells: [
                            StackedHeaderCell(
                              columnNames: List.generate(daysInMonth, (i) => 'd_${i + 1}'),
                              child: Obx(
                                () => formatColumn(
                                  label: 'Ngày Trong Tháng',
                                  themeController: themeController,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],

                      //table summary
                      tableSummaryRows: [
                        GridTableSummaryRow(
                          showSummaryInRow: false,
                          title: "Tổng",
                          position: GridTableSummaryRowPosition.bottom,
                          columns: [
                            const GridSummaryColumn(
                              name: "totalDebt",
                              columnName: "totalDebt",
                              summaryType: GridSummaryType.sum,
                            ),
                            const GridSummaryColumn(
                              name: "totalSales",
                              columnName: "totalSales",
                              summaryType: GridSummaryType.sum,
                            ),
                            for (int d = 1; d <= daysInMonth; d++)
                              GridSummaryColumn(
                                name: "d_$d",
                                columnName: "d_$d",
                                summaryType: GridSummaryType.sum,
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
                            tableKey: 'daily_revenue',
                            columnWidths: columnWidths,
                            setState: setState,
                          ),

                      onSelectionChanged: (addedRows, _) {
                        if (addedRows.isNotEmpty) {
                          final selectedRow = addedRows.first;
                          final customerId =
                              selectedRow
                                  .getCells()
                                  .firstWhere((cell) => cell.columnName == 'customerId')
                                  .value
                                  .toString();
                          _selectedCustomerIdNotifier.value = customerId;
                        } else {
                          _selectedCustomerIdNotifier.value = null;
                        }
                      },
                    ),
                  );
                },
              ),
            ),

            // Nút chuyển trang
            PaginationControls(
              currentPage: currentPg,
              totalPages: totalPgs,
              onPrevious:
                  () => setState(() {
                    currentPage--;
                    _loadDailyRevenue();
                  }),
              onNext:
                  () => setState(() {
                    currentPage++;
                    _loadDailyRevenue();
                  }),
              onJumpToPage:
                  (page) => setState(() {
                    currentPage = page;
                    _loadDailyRevenue();
                  }),
            ),
          ],
        );
      },
    );
  }
}
