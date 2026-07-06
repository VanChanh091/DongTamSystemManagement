import 'package:dongtam/data/controller/theme_controller.dart';
import 'package:dongtam/data/models/report/report_box_model.dart';
import 'package:dongtam/presentation/components/dialog/export/dialog_export_excel_report.dart';
import 'package:dongtam/presentation/components/headerTable/report/header_table_report_box.dart';
import 'package:dongtam/presentation/components/shared/left_button_search.dart';
import 'package:dongtam/presentation/components/shared/planning/widgets_planning.dart';
import 'package:dongtam/presentation/sources/report/report_box_data_source.dart';
import 'package:dongtam/service/report_planning_service.dart';
import 'package:dongtam/presentation/components/shared/animated_button.dart';
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

class ReportPlanningBox extends StatefulWidget {
  const ReportPlanningBox({super.key});

  @override
  State<ReportPlanningBox> createState() => _ReportPlanningBoxState();
}

class _ReportPlanningBoxState extends State<ReportPlanningBox> {
  late Future<Map<String, dynamic>> futureReportBox;
  late ReportBoxDatasource reportBoxDatasource;
  late List<GridColumn> columns;

  //controller
  final dataGridController = DataGridController();
  final themeController = Get.find<ThemeController>();

  String machine = "Máy In";
  String searchType = "Tất cả";
  final Map<String, String> searchFieldMap = {
    "Mã Đơn Hàng": "orderId",
    "Tên Khách Hàng": "customerName",
    "Ngày Báo Cáo": "dayReported",
    "QC Thùng": "QcBox",
    "Trưởng Máy": "shiftManagement",
  };

  //text controller
  TextEditingController searchController = TextEditingController();
  TextEditingController dateController = TextEditingController();

  List<int> selectedReportId = [];
  Map<String, double> columnWidths = {}; //map header table

  //flag
  bool isTextFieldEnabled = false;
  bool isSearching = false;

  //date range
  DateTime? startDate;
  DateTime? endDate;

  //paging
  int currentPage = 1;
  int pageSize = 35;
  int pageSizeSearch = 30;

  @override
  void initState() {
    super.initState();
    loadReportBox();

    columns = buildReportBoxColumn(themeController: themeController);

    ColumnWidthTable.loadWidths(tableKey: 'reportBox', columns: columns).then((w) {
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
    final bool isDateSearch = searchType == "Ngày Báo Cáo";

    futureReportBox = ensureMinLoading(
      ReportPlanningService().getReportBoxes(
        page: currentPage,
        pageSize: pageSize,
        machine: machine,
        field: shouldSearch ? selectedField : null,
        keyword: shouldSearch ? keyword : null,
        startDate: (shouldSearch && isDateSearch) ? startDate : null,
        endDate: (shouldSearch && isDateSearch) ? endDate : null,
      ),
    );

    selectedReportId.clear();
  }

  void loadReportBox() {
    setState(() => _fetchData());
  }

  void searchReportBox() {
    String keyword = searchController.text.trim().toLowerCase();
    final bool isDateSearch = searchType == "Ngày Báo Cáo";

    if (isDateSearch) {
      if (startDate == null || endDate == null) {
        AppLogger.w("searchOrders => chưa chọn khoảng thời gian");
        return;
      }
    } else if (isTextFieldEnabled && keyword.isEmpty) {
      AppLogger.w("searchReportBox => searchType=$searchType nhưng keyword rỗng");
      return;
    }

    setState(() {
      currentPage = 1;
      isSearching = (searchType != "Tất cả");
      _fetchData();
    });
  }

  void changeMachine(String selectedMachine) {
    AppLogger.i("changeMachine | from=$machine -> to=$selectedMachine");
    setState(() {
      machine = selectedMachine;
      selectedReportId.clear();
      loadReportBox();
    });
  }

  @override
  void dispose() {
    super.dispose();
    searchController.dispose();
    dateController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(5),
        child: Column(
          children: [
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
                      child: Obx(
                        () => Text(
                          "LỊCH SỬ BÁO CÁO THÙNG",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 22,
                            color: themeController.currentColor.value,
                          ),
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
                              "Mã Đơn Hàng",
                              "Tên Khách Hàng",
                              "Ngày Báo Cáo",
                              "QC Thùng",
                              "Trưởng Máy",
                            ],
                            onTypeChanged: (value) {
                              setState(() {
                                searchType = value;
                                isTextFieldEnabled = value != 'Tất cả';

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
                            onSearch: () => searchReportBox(),
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
                                      firstDate: DateTime(2020),
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
                                      final displayEnd = DateFormat(
                                        'dd/MM/yyyy',
                                      ).format(picked.end);

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
                        ),

                        //right button
                        Expanded(
                          flex: 1,
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                //export excel
                                AnimatedButton(
                                  onPressed: () async {
                                    showDialog(
                                      context: context,
                                      builder:
                                          (_) => DialogSelectExportExcel(
                                            onPlanningIdsOrRangeDate: () => loadReportBox(),
                                            machine: machine,
                                            isBox: true,
                                          ),
                                    );
                                  },
                                  label: "Xuất Excel",
                                  icon: Symbols.export_notes,
                                  backgroundColor: themeController.buttonColor,
                                ),
                                const SizedBox(width: 10),

                                //choose machine
                                buildDropdownItems(
                                  value: machine,
                                  items: const [
                                    'Máy In',
                                    "Máy Bế",
                                    "Máy Xả",
                                    "Máy Dán",
                                    'Máy Cấn Lằn',
                                    "Máy Cắt Khe",
                                    "Máy Cán Màng",
                                    "Máy Đóng Ghim",
                                  ],
                                  onChanged: (value) {
                                    if (value != null) {
                                      changeMachine(value);
                                    }
                                  },
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

            //table
            Expanded(
              child: FutureBuilder(
                future: futureReportBox,
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
                  } else if (!snapshot.hasData || snapshot.data!['reportBoxes'].isEmpty) {
                    return const Center(
                      child: Text(
                        "Không có báo cáo nào",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
                      ),
                    );
                  }

                  final data = snapshot.data!;
                  final reportBoxes = data['reportBoxes'] as List<ReportBoxModel>;
                  final currentPg = data['currentPage'];
                  final totalPgs = data['totalPages'];

                  reportBoxDatasource = ReportBoxDatasource(
                    reportPapers: reportBoxes,
                    selectedReportId: selectedReportId,
                    machine: machine,
                    currentPage: currentPage,
                    pageSize: pageSize,
                  );

                  return Column(
                    children: [
                      //table
                      Expanded(
                        child: SfDataGrid(
                          controller: dataGridController,
                          source: reportBoxDatasource,
                          isScrollbarAlwaysShown: true,
                          allowExpandCollapseGroup: true, // Bật grouping
                          autoExpandGroups: true,
                          columnWidthMode: ColumnWidthMode.auto,
                          selectionMode: SelectionMode.single,
                          headerRowHeight: 35,
                          rowHeight: 40,
                          columns: ColumnWidthTable.applySavedWidths(
                            columns: columns,
                            widths: columnWidths,
                          ),
                          frozenColumnsCount: 7,
                          stackedHeaderRows: <StackedHeaderRow>[
                            StackedHeaderRow(
                              cells: [
                                StackedHeaderCell(
                                  columnNames: [
                                    'qtyPrinted',
                                    'qtyCanLan',
                                    'qtyCanMang',
                                    'qtyXa',
                                    'qtyCatKhe',
                                    'qtyBe',
                                    'qtyDan',
                                    'qtyDongGhim',
                                  ],
                                  child: Obx(
                                    () => formatColumn(
                                      label: 'Báo Cáo Số Lượng Các Công Đoạn',
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
                                setState: setState,
                              ),
                          onColumnResizeEnd:
                              (details) => GridResizeHelper.onResizeEnd(
                                details: details,
                                tableKey: 'reportBox',
                                columnWidths: columnWidths,
                                setState: setState,
                              ),

                          onSelectionChanged: (addedRows, removedRows) {
                            if (addedRows.isEmpty && removedRows.isEmpty) return;

                            setState(() {
                              // Lấy selection thật sự từ controller
                              final selectedRows = dataGridController.selectedRows;

                              selectedReportId =
                                  selectedRows
                                      .map((row) {
                                        final cell = row.getCells().firstWhere(
                                          (c) => c.columnName == 'reportBoxId',
                                          orElse:
                                              () => const DataGridCell(
                                                columnName: 'reportBoxId',
                                                value: '',
                                              ),
                                        );
                                        return int.tryParse(cell.value.toString()) ?? 0;
                                      })
                                      .where((id) => id != 0)
                                      .toList();

                              reportBoxDatasource.selectedReportId = selectedReportId;
                              reportBoxDatasource.notifyListeners();
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
                            loadReportBox();
                          });
                        },
                        onNext: () {
                          setState(() {
                            currentPage++;
                            loadReportBox();
                          });
                        },
                        onJumpToPage: (page) {
                          setState(() {
                            currentPage = page;
                            loadReportBox();
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
        onPressed: () => loadReportBox(),
        backgroundColor: themeController.buttonColor.value,
        child: const Icon(Icons.refresh, color: Colors.white),
      ),
    );
  }
}
