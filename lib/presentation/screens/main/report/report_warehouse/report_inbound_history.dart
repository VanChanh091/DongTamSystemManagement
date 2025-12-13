import 'package:dongtam/data/controller/theme_controller.dart';
import 'package:dongtam/data/models/warehouse/inbound_history_model.dart';
import 'package:dongtam/presentation/components/headerTable/report/header_report_inbound.dart';
import 'package:dongtam/presentation/components/shared/left_button_search.dart';
import 'package:dongtam/presentation/sources/report/report_inbound_data_source.dart';
import 'package:dongtam/presentation/components/shared/animated_button.dart';
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
  final themeController = Get.find<ThemeController>();
  final Map<String, String> searchFieldMap = {
    "Theo Mã ĐH": "orderId",
    "Tên KH": "customerName",
    "Ngày Báo Cáo": "dayReported",
    "SL Báo Cáo": "qtyProduced",
    "Ghép Khổ": "ghepKho",
    "Quản Ca": "shiftManagement",
  };
  List<int> selectedInboundId = [];
  TextEditingController searchController = TextEditingController();
  TextEditingController dateController = TextEditingController();
  Map<String, double> columnWidths = {};
  String searchType = "Tất cả";
  bool isTextFieldEnabled = false;
  bool isSearching = false;

  int currentPage = 1;
  int pageSize = 30;
  int pageSizeSearch = 20;

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

  void loadReportInbound() {
    setState(() {
      futureReportInbound = ensureMinLoading(
        WarehouseService().getAllInboundHistory(page: currentPage, pageSize: pageSize),
      );
    });
  }

  void searchReportInbound() {
    String keyword = searchController.text.trim().toLowerCase();
    String date = dateController.text.trim().toLowerCase();

    AppLogger.i("searchReportInbound => searchType=$searchType | keyword=$keyword | date=$date");

    if (isTextFieldEnabled && keyword.isEmpty) {
      AppLogger.w("searchReportInbound => searchType=$searchType nhưng keyword rỗng");
      return;
    }

    setState(() {
      currentPage = 1;
      isSearching = (searchType != "Tất cả");

      if (searchType == "Tất cả") {
        futureReportInbound = ensureMinLoading(
          WarehouseService().getAllInboundHistory(page: currentPage, pageSize: pageSize),
        );
      } else {
        final selectedField = searchFieldMap[searchType] ?? "";

        futureReportInbound = ensureMinLoading(
          WarehouseService().getInboundByField(
            field: selectedField,
            keyword: keyword,
            page: currentPage,
            pageSize: pageSizeSearch,
          ),
        );
      }
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
                      child: Obx(
                        () => Text(
                          "LỊCH SỬ NHẬP KHO",
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
                              "Theo Mã ĐH",
                              'Tên KH',
                              "Ngày Báo Cáo",
                              "SL Báo Cáo",
                              "Ghép Khổ",
                              "Quản Ca",
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
                            onSearch: () => searchReportInbound(),
                            customInputBuilder: (inputWidth) {
                              if (searchType != 'Ngày Báo Cáo') return null;

                              return SizedBox(
                                width: inputWidth,
                                height: 50,
                                child: InkWell(
                                  onTap: () async {
                                    final now = DateTime.now();

                                    DateTime? picked = await showDatePicker(
                                      context: context,
                                      initialDate: now,
                                      firstDate: DateTime(2020),
                                      lastDate: DateTime(2100),
                                      builder: (BuildContext context, Widget? child) {
                                        return Theme(
                                          data: Theme.of(context).copyWith(
                                            colorScheme: ColorScheme.light(
                                              primary: Colors.blue,
                                              onPrimary: Colors.white,
                                              onSurface: Colors.black,
                                            ),
                                            dialogTheme: DialogThemeData(
                                              backgroundColor: Colors.white12,
                                            ),
                                          ),
                                          child: child!,
                                        );
                                      },
                                    );

                                    if (picked != null) {
                                      final displayDate = DateFormat('dd/MM/yyyy').format(picked);

                                      setState(() {
                                        dateController.text =
                                            "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";

                                        searchController.text = displayDate;
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
                                  // onPressed: () async {
                                  //   showDialog(
                                  //     context: context,
                                  //     builder:
                                  //         (_) => DialogSelectExportExcel(
                                  //           selectedInboundId: selectedInboundId,
                                  //           onPlanningIdsOrRangeDate: () => loadReportInbound(),
                                  //           machine: machine,
                                  //         ),
                                  //   );
                                  // },
                                  onPressed: () {},
                                  label: "Xuất Excel",
                                  icon: Symbols.export_notes,
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

            //table
            Expanded(
              child: FutureBuilder(
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
                    return const Center(
                      child: Text(
                        "Không có báo cáo nào",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
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
                  );

                  return Column(
                    children: [
                      //table
                      Expanded(
                        child: SfDataGrid(
                          source: reportInboundDataSource,
                          isScrollbarAlwaysShown: true,
                          allowExpandCollapseGroup: true, // Bật grouping
                          autoExpandGroups: true,
                          columnWidthMode: ColumnWidthMode.auto,
                          navigationMode: GridNavigationMode.row,
                          selectionMode: SelectionMode.multiple,
                          headerRowHeight: 35,
                          rowHeight: 40,
                          columns: ColumnWidthTable.applySavedWidths(
                            columns: columns,
                            widths: columnWidths,
                          ),
                          stackedHeaderRows: <StackedHeaderRow>[
                            StackedHeaderRow(
                              cells: [
                                StackedHeaderCell(
                                  columnNames: ['quantityOrd', 'qtyPaper', 'qtyInbound'],
                                  child: Obx(
                                    () => formatColumn(
                                      label: 'Số Lượng',
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
                                tableKey: 'reportInbound',
                                columnWidths: columnWidths,
                                setState: setState,
                              ),

                          onSelectionChanged: (addedRows, removedRows) {
                            setState(() {
                              for (var row in addedRows) {
                                final inboundId =
                                    row
                                        .getCells()
                                        .firstWhere((cell) => cell.columnName == 'inboundId')
                                        .value;
                                if (selectedInboundId.contains(inboundId)) {
                                  selectedInboundId.remove(inboundId);
                                } else {
                                  selectedInboundId.add(inboundId);
                                }
                              }

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
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => loadReportInbound(),
        backgroundColor: themeController.buttonColor.value,
        child: const Icon(Icons.refresh, color: Colors.white),
      ),
    );
  }
}
