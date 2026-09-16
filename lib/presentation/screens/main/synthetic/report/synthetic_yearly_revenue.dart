import "package:dongtam/data/controller/theme_controller.dart";
import "package:dongtam/presentation/components/dialog/other/dialog_picker_year.dart";
import "package:dongtam/data/controller/user_controller.dart";
import "package:dongtam/data/models/reportRevenue/report_yearly_revenue_model.dart";
import "package:dongtam/presentation/components/headerTable/synthetic/report/header_table_yearly_revenue.dart";
import "package:dongtam/presentation/components/shared/left_button_search.dart";
import "package:dongtam/presentation/components/shared/grid_resize_helper.dart";
import "package:dongtam/presentation/components/shared/pagination_controls.dart";
import "package:dongtam/presentation/components/shared/planning/widgets_planning.dart";
import "package:dongtam/presentation/components/shared/slider_zoom.dart";
import "package:dongtam/presentation/sources/synthetic/report/yearly_revenue_data_source.dart";
import "package:dongtam/service/customer_service.dart";
import "package:dongtam/service/synthetic_service.dart";
import "package:dongtam/utils/helper/helper_model.dart";
import "package:dongtam/utils/helper/skeleton/skeleton_loading.dart";
import "package:dongtam/utils/helper/style_table.dart";
import "package:dongtam/utils/logger/app_logger.dart";
import "package:dongtam/utils/storage/sharedPreferences/column_width_table.dart";
import "package:flutter/material.dart";
import "package:get/get.dart";
import "package:syncfusion_flutter_core/theme.dart";
import "package:syncfusion_flutter_datagrid/datagrid.dart";

class SyntheticYearlyRevenue extends StatefulWidget {
  const SyntheticYearlyRevenue({super.key});

  @override
  State<SyntheticYearlyRevenue> createState() => _SyntheticYearlyRevenueState();
}

class _SyntheticYearlyRevenueState extends State<SyntheticYearlyRevenue> {
  late Future<Map<String, dynamic>> futureSynthetic;
  late List<GridColumn> columns;

  // Controllers
  final userController = Get.find<UserController>();
  final themeController = Get.find<ThemeController>();

  final headerScrollController = ScrollController();
  final searchController = TextEditingController();

  Map<String, double> columnWidths = {};
  final _zoomNotifier = ValueNotifier<double>(1.0);
  final _selectedCustomerIdNotifier = ValueNotifier<String?>(null);

  //sales user filter
  String selectedSalesUser = "Tất cả";
  String? selectedUserId;
  List<String> salesUserItems = ["Tất cả"];
  Map<String, String?> salesUserMap = {"Tất cả": null};

  // Datasource & Cache
  List<CustomerYearRevenue>? _cachedYearlyRevenue;
  YearlyRevenueDataSource? _cachedDatasource;

  // Date Range & Flags
  bool isTextFieldEnabled = false;
  bool isSearching = false;

  // Filter
  late int fromYear;
  late int toYear;
  late bool isManager;

  // Paging
  int currentPage = 1;
  int pageSize = 30;

  @override
  void initState() {
    super.initState();
    isManager = userController.hasAnyRole(roles: ["admin", "manager"]);

    final now = DateTime.now();
    fromYear = now.year;
    toYear = now.year;

    _loadSalesUsers();
    _loadYearlyRevenue();

    columns = buildYearlyRevenueColumn(themeController: themeController);
    ColumnWidthTable.loadWidths(tableKey: "yearly_revenue", columns: columns).then((w) {
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
      SyntheticService().getRevenueReport<CustomerYearRevenue>(
        type: "yearly",
        page: currentPage,
        pageSize: pageSize,
        fromYear: fromYear,
        toYear: toYear,
        targetUserId: selectedUserId,
        keyword: keyword.isNotEmpty ? keyword : null,
        dataKey: "yearlyRevenue",
        fromJson: (json) => CustomerYearRevenue.fromJson(json),
      ),
    );

    _selectedCustomerIdNotifier.value = null;
  }

  void _loadYearlyRevenue() {
    setState(() => _fetchData());
  }

  void searchRevenue() {
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
        onPressed: () => _loadYearlyRevenue(),
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
          "BÁO CÁO DOANH THU THEO NĂM",
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
                      //search
                      LeftButtonSearch(
                        showDropdown: false,
                        controller: searchController,
                        hintText: "Tìm theo khách hàng...",
                        buttonColor: themeController.buttonColor,
                        onSearch: searchRevenue,
                      ),
                      const SizedBox(width: 12),

                      //buttons
                      ValueListenableBuilder(
                        valueListenable: _selectedCustomerIdNotifier,
                        builder: (context, selectedCustomerId, _) {
                          return Row(
                            children: [
                              // Bộ chọn khoảng năm
                              SizedBox(
                                width: 200,
                                child: InkWell(
                                  onTap: () async {
                                    final result = await showYearRangePickerDialog(
                                      context: context,
                                      initialFromYear: fromYear,
                                      initialToYear: toYear,
                                      maxYears: 3,
                                    );
                                    if (result != null) {
                                      // Kiểm tra nếu tháng hoặc năm có sự thay đổi
                                      final hasChanged =
                                          fromYear != result.fromYear || toYear != result.toYear;

                                      if (hasChanged) {
                                        setState(() {
                                          fromYear = result.fromYear;
                                          toYear = result.toYear;
                                          currentPage = 1;
                                        });
                                        _loadYearlyRevenue();
                                      }
                                    }
                                  },
                                  borderRadius: BorderRadius.circular(10),
                                  child: InputDecorator(
                                    decoration: InputDecoration(
                                      labelText: "Thời gian",
                                      filled: true,
                                      fillColor: Colors.white,
                                      suffixIcon: const Icon(Icons.calendar_today, size: 18),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 10,
                                      ),
                                    ),
                                    child: Text(
                                      fromYear == toYear
                                          ? "Năm $fromYear"
                                          : "Năm $fromYear - $toYear",
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
                                        _loadYearlyRevenue();
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
        final rawList = responseMap?["yearlyRevenue"] as List<CustomerYearRevenue>?;

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

        final List<CustomerYearRevenue> customers = rawList;

        final currentPg = toInt(responseMap["currentPage"]);
        final totalPgs = toInt(responseMap["totalPages"]);

        // Parse summary an toàn qua factory từ Map thô
        final MultiYearSummary summary = MultiYearSummary.fromJson(
          responseMap["summary"] as Map<String, dynamic>? ?? {},
        );

        // Lấy danh sách năm trả về từ API (ví dụ [2024, 2025, 2026])
        final List<int> years =
            (responseMap["years"] as List<dynamic>? ?? []).map((e) => toInt(e)).toList();

        // Tự động rebuild columns nếu số năm thay đổi
        columns = buildYearlyRevenueColumn(themeController: themeController, years: years);

        if (_cachedYearlyRevenue != customers || _cachedDatasource == null) {
          _cachedYearlyRevenue = customers;
          _cachedDatasource = YearlyRevenueDataSource(
            customers: customers,
            summary: summary,
            years: years,
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

                      // Stacked Header nhóm 12 tháng vào từng Năm
                      stackedHeaderRows: [
                        StackedHeaderRow(
                          cells:
                              years.map((y) {
                                return StackedHeaderCell(
                                  columnNames: [
                                    for (int m = 1; m <= 12; m++) "y_${y}_m_$m",
                                    "y_${y}_total",
                                  ],
                                  child: Obx(
                                    () => formatColumn(
                                      label: "Năm $y",
                                      themeController: themeController,
                                    ),
                                  ),
                                );
                              }).toList(),
                        ),
                      ],

                      // Dòng tổng cộng ở đáy bảng
                      tableSummaryRows: [
                        GridTableSummaryRow(
                          showSummaryInRow: false,
                          title: "Tổng cộng",
                          position: GridTableSummaryRowPosition.bottom,
                          columns: [
                            const GridSummaryColumn(
                              name: "sumDebt",
                              columnName: "currentDebt",
                              summaryType: GridSummaryType.sum,
                            ),
                            for (final y in years) ...[
                              for (int m = 1; m <= 12; m++)
                                GridSummaryColumn(
                                  name: "sum_y_${y}_m_$m",
                                  columnName: "y_${y}_m_$m",
                                  summaryType: GridSummaryType.sum,
                                ),
                              GridSummaryColumn(
                                name: "sum_y_${y}_total",
                                columnName: "y_${y}_total",
                                summaryType: GridSummaryType.sum,
                              ),
                            ],
                            const GridSummaryColumn(
                              name: "sumGrandTotal",
                              columnName: "grandTotal",
                              summaryType: GridSummaryType.sum,
                            ),
                          ],
                        ),
                      ],

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
                            tableKey: "yearly_revenue",
                            columnWidths: columnWidths,
                            setState: setState,
                          ),
                      onSelectionChanged: (addedRows, _) {
                        if (addedRows.isNotEmpty) {
                          final selectedRow = addedRows.first;
                          final customerId =
                              selectedRow
                                  .getCells()
                                  .firstWhere((cell) => cell.columnName == "customerId")
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

            const SizedBox(height: 8),
            PaginationControls(
              currentPage: currentPg,
              totalPages: totalPgs,
              onPrevious:
                  () => setState(() {
                    currentPage--;
                    _loadYearlyRevenue();
                  }),
              onNext:
                  () => setState(() {
                    currentPage++;
                    _loadYearlyRevenue();
                  }),
              onJumpToPage:
                  (page) => setState(() {
                    currentPage = page;
                    _loadYearlyRevenue();
                  }),
            ),
          ],
        );
      },
    );
  }
}
