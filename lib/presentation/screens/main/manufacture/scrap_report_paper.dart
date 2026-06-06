import 'package:dongtam/data/controller/theme_controller.dart';
import 'package:dongtam/data/controller/user_controller.dart';
import 'package:dongtam/data/models/scrap/scrap_report_model.dart';
import 'package:dongtam/presentation/components/headerTable/header_table_scrap_report.dart';
import 'package:dongtam/presentation/components/shared/left_button_search.dart';
import 'package:dongtam/presentation/sources/scrap_report_data_source.dart';
import 'package:dongtam/presentation/components/shared/animated_button.dart';
import 'package:dongtam/service/scrap_report_service.dart';
import 'package:dongtam/utils/helper/grid_resize_helper.dart';
import 'package:dongtam/presentation/components/shared/pagination_controls.dart';
import 'package:dongtam/utils/helper/skeleton/skeleton_loading.dart';
import 'package:dongtam/utils/logger/app_logger.dart';
import 'package:dongtam/utils/storage/sharedPreferences/column_width_table.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class ScrapReportPaper extends StatefulWidget {
  const ScrapReportPaper({super.key});

  @override
  State<ScrapReportPaper> createState() => _ScrapReportPaperState();
}

class _ScrapReportPaperState extends State<ScrapReportPaper> {
  late Future<Map<String, dynamic>> futureScrap;
  late ScrapReportDataSource scrapReportDatasource;
  late List<GridColumn> columns;

  //controller
  final dataGridController = DataGridController();
  final userController = Get.find<UserController>();
  final themeController = Get.find<ThemeController>();

  //search
  String searchType = "Tất cả";
  final Map<String, String> searchFieldMap = {"Mã Khách Hàng": "customerId"};

  List<int> selectedScrapIds = [];
  Map<String, double> columnWidths = {}; //map header table

  //text controller
  TextEditingController searchController = TextEditingController();

  //date range
  DateTime? startDate;
  DateTime? endDate;

  //flag
  bool isTextFieldEnabled = false;
  bool isSearching = false; //dùng để phân trang cho tìm kiếm

  //paging
  int currentPage = 1;
  int pageSize = 35;
  int pageSizeSearch = 30;

  @override
  void initState() {
    super.initState();
    loadScrapReports();

    columns = buildScrapReportColumn(themeController: themeController);

    ColumnWidthTable.loadWidths(tableKey: 'scrapReport', columns: columns).then((w) {
      setState(() {
        columnWidths = w;
      });
    });
  }

  void _fetchData() {
    final String keyword = searchController.text.trim().toLowerCase();
    final String selectedField = searchFieldMap[searchType] ?? "";

    // Điều kiện để xác định có thực hiện search hay load mặc định
    final bool shouldSearch = (searchType != "Tất cả");
    final bool isDateSearch = searchType == "Ngày Tạo";

    futureScrap = ensureMinLoading(
      ScrapReportService().getAllScrapReports(
        page: currentPage,
        pageSize: pageSize,
        field: shouldSearch ? selectedField : null,
        keyword: shouldSearch ? keyword : null,
        startDate: (shouldSearch && isDateSearch) ? startDate : null,
        endDate: (shouldSearch && isDateSearch) ? endDate : null,
      ),
    );

    selectedScrapIds.clear();
  }

  void loadScrapReports() {
    setState(() => _fetchData());
  }

  void searchScrapReports() {
    String keyword = searchController.text.trim().toLowerCase();
    AppLogger.i("searchScrapReports: searchType=$searchType, keyword='$keyword'");

    if (isTextFieldEnabled && keyword.isEmpty) {
      AppLogger.w("searchScrapReports: search bị bỏ qua vì keyword trống");
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
  }

  @override
  Widget build(BuildContext context) {
    final bool isSale = userController.hasPermission(permission: "sale");

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
                        "BÁO CÁO PHẾ LIỆU",
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
                            types: const ['Tất cả', "Mã Khách Hàng"],
                            onTypeChanged: (value) {
                              setState(() {
                                searchType = value;
                                isTextFieldEnabled = searchType != 'Tất cả';

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
                            onSearch: () => searchScrapReports(),
                            customInputBuilder: (inputWidth) {
                              if (searchType != 'Ngày Báo Cáo') return null;

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
                                        "dd/MM/yyyy",
                                      ).format(picked.start);
                                      final displayEnd = DateFormat(
                                        "dd/MM/yyyy",
                                      ).format(picked.end);

                                      setState(() {
                                        startDate = picked.start;
                                        endDate = picked.end;
                                        searchController.text = "$displayStart - $displayEnd";
                                      });
                                    }
                                  },
                                  child: IgnorePointer(
                                    child: TextField(
                                      controller: searchController,
                                      decoration: InputDecoration(
                                        hintText: "Chọn khoảng thời gian...",
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
                        ),

                        //right button
                        Expanded(
                          flex: 1,
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                            child:
                                isSale
                                    ? Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        //export excel
                                        AnimatedButton(
                                          onPressed: () async {
                                            // showDialog(
                                            //   context: context,
                                            //   builder: (_) => DialogExportCusOrProd(),
                                            // );
                                          },
                                          label: "Xuất Excel",
                                          icon: Symbols.export_notes,
                                          backgroundColor: themeController.buttonColor,
                                        ),
                                        const SizedBox(width: 10),

                                        //add
                                        AnimatedButton(
                                          onPressed: () {
                                            // showDialog(
                                            //   context: context,
                                            //   builder:
                                            //       (_) => CustomerDialog(
                                            //         customer: null,
                                            //         onCustomerAddOrUpdate: () => loadScrapReports(),
                                            //       ),
                                            // );
                                          },
                                          label: "Thêm mới",
                                          icon: Icons.add,
                                          backgroundColor: themeController.buttonColor,
                                        ),
                                        const SizedBox(width: 10),

                                        // update
                                        AnimatedButton(
                                          onPressed: () {},
                                          // isSale &&
                                          //         selectedScrapIds != null &&
                                          //         selectedScrapIds!.isNotEmpty
                                          //     ? () async {
                                          //       try {
                                          //         final customersData = await futureCustomer;
                                          //         final List<Customer> customerList =
                                          //             (customersData['customers'] as List? ??
                                          //                     [])
                                          //                 .cast<Customer>();
                                          //         final selectedCustomer = customerList
                                          //             .firstWhere(
                                          //               (customer) =>
                                          //                   customer.customerId ==
                                          //                   selectedScrapIds,
                                          //               orElse:
                                          //                   () =>
                                          //                       throw Exception(
                                          //                         "Không tìm thấy khách hàng",
                                          //                       ),
                                          //             );

                                          //         if (context.mounted) {
                                          //           showDialog(
                                          //             context: context,
                                          //             builder:
                                          //                 (_) => CustomerDialog(
                                          //                   customer: selectedCustomer,
                                          //                   onCustomerAddOrUpdate:
                                          //                       () => loadScrapReports(),
                                          //                 ),
                                          //           );
                                          //         }
                                          //       } catch (e, s) {
                                          //         AppLogger.e(
                                          //           "Error in getCustomerById: $e",
                                          //           stackTrace: s,
                                          //         );

                                          //         if (!context.mounted) return;
                                          //         showSnackBarError(
                                          //           context,
                                          //           'Có lỗi xảy ra, vui lòng thử lại sau',
                                          //         );
                                          //       }
                                          // }
                                          // : null,
                                          label: "Sửa",
                                          icon: Symbols.construction,
                                          backgroundColor: themeController.buttonColor,
                                        ),
                                        const SizedBox(width: 10),
                                      ],
                                    )
                                    : const SizedBox.shrink(),
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
                future: futureScrap,
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
                  } else if (!snapshot.hasData || snapshot.data!['scrapReports'].isEmpty) {
                    return const Center(
                      child: Text(
                        "Không có báo cáo thanh lý nào",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
                      ),
                    );
                  }

                  final data = snapshot.data!;
                  final scrapReports = data['scrapReports'] as List<ScrapReportModel>;
                  final currentPg = data['currentPage'];
                  final totalPgs = data['totalPages'];

                  scrapReportDatasource = ScrapReportDataSource(
                    scrapReports: scrapReports,
                    selectedScrapIds: selectedScrapIds,
                    currentPage: currentPage,
                    pageSize: pageSize,
                  );

                  return Column(
                    children: [
                      //table
                      Expanded(
                        child: SfDataGrid(
                          controller: dataGridController,
                          source: scrapReportDatasource,
                          isScrollbarAlwaysShown: true,
                          columnWidthMode: ColumnWidthMode.auto,
                          selectionMode: SelectionMode.single,
                          headerRowHeight: 45,
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
                                tableKey: 'scrapReport',
                                columnWidths: columnWidths,
                                setState: setState,
                              ),

                          onSelectionChanged: (addedRows, removedRows) async {
                            if (addedRows.isEmpty && removedRows.isEmpty) return;

                            setState(() {
                              // Lấy selection thật sự từ controller
                              final selectedRows = dataGridController.selectedRows;

                              selectedScrapIds =
                                  selectedRows.map((row) {
                                    final cell = row.getCells().firstWhere(
                                      (c) => c.columnName == 'scrapId',
                                      orElse:
                                          () =>
                                              const DataGridCell(columnName: 'scrapId', value: ''),
                                    );
                                    return cell.value as int;
                                  }).toList();

                              // cập nhật cho datasource
                              scrapReportDatasource.selectedScrapIds = selectedScrapIds;
                              scrapReportDatasource.notifyListeners();
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
                            loadScrapReports();
                          });
                        },
                        onNext: () {
                          setState(() {
                            currentPage++;
                            loadScrapReports();
                          });
                        },
                        onJumpToPage: (page) {
                          setState(() {
                            currentPage = page;
                            loadScrapReports();
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
        onPressed: () => loadScrapReports(),
        backgroundColor: themeController.buttonColor.value,
        child: const Icon(Icons.refresh, color: Colors.white),
      ),
    );
  }
}
