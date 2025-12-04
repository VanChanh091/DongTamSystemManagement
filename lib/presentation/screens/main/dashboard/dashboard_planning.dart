import 'package:dongtam/data/controller/theme_controller.dart';
import 'package:dongtam/data/controller/user_controller.dart';
import 'package:dongtam/data/models/planning/planning_paper_model.dart';
import 'package:dongtam/data/models/planning/planning_stages.dart';
import 'package:dongtam/presentation/components/dialog/dialog_export_db_planning.dart';
import 'package:dongtam/presentation/components/headerTable/header_table_db_planning.dart';
import 'package:dongtam/presentation/components/headerTable/header_table_stages.dart';
import 'package:dongtam/presentation/components/shared/left_button_search.dart';
import 'package:dongtam/presentation/sources/dashboard_planning_data_source.dart';
import 'package:dongtam/presentation/sources/stages_data_source.dart';
import 'package:dongtam/service/dashboard_service.dart';
import 'package:dongtam/presentation/components/shared/animated_button.dart';
import 'package:dongtam/utils/helper/grid_resize_helper.dart';
import 'package:dongtam/presentation/components/shared/pagination_controls.dart';
import 'package:dongtam/utils/helper/skeleton/skeleton_loading.dart';
import 'package:dongtam/utils/helper/style_table.dart';
import 'package:dongtam/utils/logger/app_logger.dart';
import 'package:dongtam/utils/storage/sharedPreferences/column_width_table.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class DashboardPlanning extends StatefulWidget {
  const DashboardPlanning({super.key});

  @override
  State<DashboardPlanning> createState() => _DashboardPlanningState();
}

class _DashboardPlanningState extends State<DashboardPlanning> {
  late Future<Map<String, dynamic>> futureDbPaper;
  late DashboardPaperDataSource dbPaperDatasource;
  late List<GridColumn> columnsPaper;
  late List<GridColumn> columnsStages;
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

  final Map<String, String> statusFieldMap = {
    "Hoàn Thành": "complete",
    "Đã Sắp Xếp": "planning",
    "Thiếu Số Lượng": "lackQty",
    "Đang Sản Xuất": "producing",
    "Bị Dừng": "stop",
    "Bị Hủy": "cancel",
  };
  String status = "Đã Sắp Xếp";

  TextEditingController searchController = TextEditingController();
  Map<String, double> columnWidthsPlanning = {};
  Map<String, double> columnWidthsStage = {};
  bool selectedAll = false;
  bool isTextFieldEnabled = false;
  bool isSearching = false; //dùng để phân trang cho tìm kiếm
  int? selectedDbPaperId;
  List<PlanningStage> selectedStages = [];

  int currentPage = 1;
  int pageSize = 25;
  int pageSizeSearch = 20;

  @override
  void initState() {
    super.initState();
    loadDashboard();

    columnsPaper = buildDbPaperColumn(themeController: themeController);
    columnsStages = buildStageColumn(themeController: themeController);

    ColumnWidthTable.loadWidths(tableKey: 'dashboard', columns: columnsPaper).then((w) {
      setState(() {
        columnWidthsPlanning = w;
      });
    });

    ColumnWidthTable.loadWidths(tableKey: 'stage', columns: columnsStages).then((w) {
      setState(() {
        columnWidthsStage = w;
      });
    });
  }

  void loadDashboard() {
    setState(() {
      final String selectedField = searchFieldMap[searchType] ?? "";
      final String selectedStatus = statusFieldMap[status] ?? "";

      String keyword = searchController.text.trim().toLowerCase();

      if (isSearching && searchType != "Tất cả") {
        AppLogger.i("loadDbPaper: isSearching=true, keyword='$keyword'");

        futureDbPaper = ensureMinLoading(
          DashboardService().getDbPlanningByFields(
            field: selectedField,
            keyword: keyword,
            page: currentPage,
            pageSize: pageSizeSearch,
          ),
        );
      } else {
        futureDbPaper = ensureMinLoading(
          DashboardService().getAllDataDashboard(
            page: currentPage,
            pageSize: pageSize,
            status: selectedStatus,
          ),
        );
      }

      selectedDbPaperId = null;
      selectedStages = [];
    });
  }

  void searchDashboard() {
    String keyword = searchController.text.trim().toLowerCase();
    AppLogger.i("searchDbPaper: searchType=$searchType, keyword='$keyword'");

    if (isTextFieldEnabled && keyword.isEmpty) {
      AppLogger.w("searchDbPaper: search bị bỏ qua vì keyword trống");
      return;
    }

    setState(() {
      final String selectedStatus = statusFieldMap[status] ?? "";

      currentPage = 1;
      isSearching = (searchType != "Tất cả");

      if (searchType == "Tất cả") {
        futureDbPaper = ensureMinLoading(
          DashboardService().getAllDataDashboard(
            page: currentPage,
            pageSize: pageSize,
            status: selectedStatus,
          ),
        );
      } else {
        final selectedField = searchFieldMap[searchType] ?? "";

        futureDbPaper = ensureMinLoading(
          DashboardService().getDbPlanningByFields(
            field: selectedField,
            keyword: keyword,
            page: currentPage,
            pageSize: pageSizeSearch,
          ),
        );
      }

      selectedDbPaperId = null;
      selectedStages = [];
    });
  }

  void changeStatus(String selectedStatus) {
    AppLogger.i("changeStatusDbPaper | from=$status -> to=$selectedStatus");

    setState(() {
      status = selectedStatus;
      selectedStages.clear();
      loadDashboard();
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
                        "TỔNG HỢP SẢN XUẤT",
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
                            onSearch: () => searchDashboard(),
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
                                //export excel
                                AnimatedButton(
                                  onPressed: () async {
                                    showDialog(
                                      context: context,
                                      builder: (_) => DialogExportDbPlannings(),
                                    );
                                  },
                                  label: "Xuất Excel",
                                  icon: Symbols.export_notes,
                                  backgroundColor: themeController.buttonColor,
                                ),
                                const SizedBox(width: 10),

                                //choose machine
                                SizedBox(
                                  width: 180,
                                  child: DropdownButtonFormField<String>(
                                    value: status,
                                    items:
                                        [
                                          "Hoàn Thành",
                                          "Đã Sắp Xếp",
                                          "Đang Sản Xuất",
                                          "Thiếu Số Lượng",
                                          "Bị Dừng",
                                          "Bị Hủy",
                                        ].map((String value) {
                                          return DropdownMenuItem<String>(
                                            value: value,
                                            child: Text(value),
                                          );
                                        }).toList(),
                                    onChanged: (value) {
                                      if (value != null) {
                                        changeStatus(value);
                                      }
                                    },
                                    decoration: InputDecoration(
                                      filled: true,
                                      fillColor: Colors.white,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: const BorderSide(color: Colors.grey),
                                      ),
                                      contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 8,
                                      ),
                                    ),
                                  ),
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
                future: futureDbPaper,
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
                  } else if (!snapshot.hasData || snapshot.data!['dashboard'].isEmpty) {
                    return const Center(
                      child: Text(
                        "Không có đơn hàng nào",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
                      ),
                    );
                  }

                  final data = snapshot.data!;
                  final dbPlanning = data['dashboard'] as List<PlanningPaper>;
                  final currentPg = data['currentPage'];
                  final totalPgs = data['totalPages'];

                  dbPaperDatasource = DashboardPaperDataSource(
                    dbPlanning: dbPlanning,
                    selectedDbPaperId: selectedDbPaperId,
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
                                source: dbPaperDatasource,
                                isScrollbarAlwaysShown: true,
                                columnWidthMode: ColumnWidthMode.auto,
                                selectionMode: SelectionMode.single,
                                headerRowHeight: 35,
                                rowHeight: 38,
                                columns: ColumnWidthTable.applySavedWidths(
                                  columns: columnsPaper,
                                  widths: columnWidthsPlanning,
                                ),
                                stackedHeaderRows: <StackedHeaderRow>[
                                  StackedHeaderRow(
                                    cells: [
                                      StackedHeaderCell(
                                        columnNames: [
                                          "dayReceive",
                                          "dateShipping",
                                          "dayStartProduction",
                                          "dayCompletedProd",
                                          "dayCompletedOvfl",
                                        ],
                                        child: Obx(
                                          () => formatColumn(
                                            label: 'Ngày',
                                            themeController: themeController,
                                          ),
                                        ),
                                      ),
                                      StackedHeaderCell(
                                        columnNames: [
                                          'quantityOrd',
                                          'qtyProduced',
                                          'runningPlanProd',
                                        ],
                                        child: Obx(
                                          () => formatColumn(
                                            label: 'Số Lượng',
                                            themeController: themeController,
                                          ),
                                        ),
                                      ),
                                      StackedHeaderCell(
                                        columnNames: ['timeRunningProd', 'timeRunningOvfl'],
                                        child: Obx(
                                          () => formatColumn(
                                            label: 'Thời Gian',
                                            themeController: themeController,
                                          ),
                                        ),
                                      ),
                                      StackedHeaderCell(
                                        columnNames: [
                                          'bottom',
                                          'fluteE',
                                          'fluteE2',
                                          'fluteB',
                                          'fluteC',
                                          'knife',
                                          'totalLoss',
                                        ],
                                        child: Obx(
                                          () => formatColumn(
                                            label: 'Định Mức Phế Liệu',
                                            themeController: themeController,
                                          ),
                                        ),
                                      ),
                                      StackedHeaderCell(
                                        columnNames: [
                                          'inMatTruoc',
                                          'inMatSau',
                                          'canLanBox',
                                          'canMang',
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
                                        child: Obx(
                                          () => formatColumn(
                                            label: 'Công Đoạn 2',
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
                                      columns: columnsPaper,
                                      setState: setState,
                                    ),
                                onColumnResizeEnd:
                                    (details) => GridResizeHelper.onResizeEnd(
                                      details: details,
                                      tableKey: 'dashboard',
                                      columnWidths: columnWidthsPlanning,
                                      setState: setState,
                                    ),

                                onSelectionChanged: (addedRows, removedRows) async {
                                  if (addedRows.isEmpty) {
                                    setState(() {
                                      selectedDbPaperId = null;
                                    });
                                    return;
                                  }

                                  final selectedRow = addedRows.first;

                                  final planningId =
                                      selectedRow
                                          .getCells()
                                          .firstWhere((cell) => cell.columnName == 'planningId')
                                          .value;

                                  // Lấy data của list (summary)
                                  final selectedDbPaper = dbPlanning.firstWhere(
                                    (paper) => paper.planningId == planningId,
                                  );

                                  setState(() {
                                    selectedDbPaperId = selectedDbPaper.planningId;
                                  });

                                  final stages = await DashboardService().getDbPlanningDetail(
                                    planningId: selectedDbPaper.planningId,
                                  );

                                  setState(() {
                                    selectedStages = stages;
                                  });
                                },
                              ),
                            ),

                            selectedStages.isNotEmpty
                                ? Expanded(
                                  flex: 1,
                                  child: AnimatedSize(
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeInOut,
                                    child: SfDataGrid(
                                      source: StagesDataSource(stages: selectedStages),
                                      isScrollbarAlwaysShown: true,
                                      headerRowHeight: 30,
                                      rowHeight: 35,
                                      columnWidthMode: ColumnWidthMode.fill,
                                      selectionMode: SelectionMode.single,
                                      columns: ColumnWidthTable.applySavedWidths(
                                        columns: columnsStages,
                                        widths: columnWidthsStage,
                                      ),
                                      stackedHeaderRows: <StackedHeaderRow>[
                                        StackedHeaderRow(
                                          cells: [
                                            StackedHeaderCell(
                                              columnNames: [
                                                "dayStart",
                                                "dayCompleted",
                                                "dayCompletedOvfl",
                                              ],
                                              child: Obx(
                                                () => formatColumn(
                                                  label: 'Ngày',
                                                  themeController: themeController,
                                                ),
                                              ),
                                            ),
                                            StackedHeaderCell(
                                              columnNames: ["timeRunning", "timeRunningOvfl"],
                                              child: Obx(
                                                () => formatColumn(
                                                  label: 'Thời Gian',
                                                  themeController: themeController,
                                                ),
                                              ),
                                            ),
                                            StackedHeaderCell(
                                              columnNames: ["runningPlan", "qtyProduced"],
                                              child: Obx(
                                                () => formatColumn(
                                                  label: 'Số Lượng',
                                                  themeController: themeController,
                                                ),
                                              ),
                                            ),
                                            StackedHeaderCell(
                                              columnNames: ["wasteBox", "rpWasteLoss"],
                                              child: Obx(
                                                () => formatColumn(
                                                  label: 'Phế Liệu',
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
                                            columns: columnsStages,
                                            setState: setState,
                                          ),
                                      onColumnResizeEnd:
                                          (details) => GridResizeHelper.onResizeEnd(
                                            details: details,
                                            tableKey: 'stage',
                                            columnWidths: columnWidthsStage,
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
                            loadDashboard();
                          });
                        },
                        onNext: () {
                          setState(() {
                            currentPage++;
                            loadDashboard();
                          });
                        },
                        onJumpToPage: (page) {
                          setState(() {
                            currentPage = page;
                            loadDashboard();
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
        onPressed: () => loadDashboard(),
        backgroundColor: themeController.buttonColor.value,
        child: const Icon(Icons.refresh, color: Colors.white),
      ),
    );
  }
}
