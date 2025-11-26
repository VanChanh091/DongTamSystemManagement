import 'package:dongtam/data/controller/theme_controller.dart';
import 'package:dongtam/data/controller/user_controller.dart';
import 'package:dongtam/data/models/planning/planning_paper_model.dart';
import 'package:dongtam/data/models/planning/planning_stages.dart';
import 'package:dongtam/presentation/components/dialog/dialog_export_db_planning.dart';
import 'package:dongtam/presentation/components/headerTable/header_table_db_planning.dart';
import 'package:dongtam/presentation/components/headerTable/header_table_stages.dart';
import 'package:dongtam/presentation/sources/dashboard_planning_data_source.dart';
import 'package:dongtam/presentation/sources/stages_data_source.dart';
import 'package:dongtam/service/dashboard_service.dart';
import 'package:dongtam/utils/helper/animated_button.dart';
import 'package:dongtam/utils/helper/grid_resize_helper.dart';
import 'package:dongtam/utils/helper/pagination_controls.dart';
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

  TextEditingController searchController = TextEditingController();
  Map<String, double> columnWidthsPlanning = {};
  Map<String, double> columnWidthsStage = {};
  bool selectedAll = false;
  bool isTextFieldEnabled = false;
  bool isSearching = false; //dùng để phân trang cho tìm kiếm
  String searchType = "Tất cả";
  int? selectedDbPaperId;
  List<PlanningStage> selectedStages = [];

  int currentPage = 1;
  int pageSize = 25;
  int pageSizeSearch = 20;

  @override
  void initState() {
    super.initState();
    loadDbPaper();

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

  void loadDbPaper() {
    setState(() {
      final String selectedField = searchFieldMap[searchType] ?? "";

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
          DashboardService().getAllDataDashboard(page: currentPage, pageSize: pageSize),
        );
      }

      selectedDbPaperId = null;
      selectedStages = [];
    });
  }

  void searchDbPaper() {
    String keyword = searchController.text.trim().toLowerCase();
    AppLogger.i("searchDbPaper: searchType=$searchType, keyword='$keyword'");

    if (isTextFieldEnabled && keyword.isEmpty) {
      AppLogger.w("searchDbPaper: search bị bỏ qua vì keyword trống");
      return;
    }

    setState(() {
      currentPage = 1;
      isSearching = (searchType != "Tất cả");

      if (searchType == "Tất cả") {
        futureDbPaper = ensureMinLoading(
          DashboardService().getAllDataDashboard(page: currentPage, pageSize: pageSize),
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
                        "TỔNG HỢP SẢN XUẤT GIẤY TẤM",
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
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                final maxWidth = constraints.maxWidth;
                                final dropdownWidth = (maxWidth * 0.2).clamp(170.0, 200.0);
                                final textInputWidth = (maxWidth * 0.3).clamp(200.0, 250.0);

                                return Row(
                                  children: [
                                    //dropdown
                                    SizedBox(
                                      width: dropdownWidth,
                                      child: DropdownButtonFormField<String>(
                                        value: searchType,
                                        items:
                                            [
                                              'Tất cả',
                                              "Theo Mã Đơn",
                                              "Ghép Khổ",
                                              "Theo Máy",
                                              "Tên Khách Hàng",
                                              "Tên Công Ty",
                                              "Tên Nhân Viên",
                                            ].map((String value) {
                                              return DropdownMenuItem<String>(
                                                value: value,
                                                child: Text(value),
                                              );
                                            }).toList(),
                                        onChanged: (value) {
                                          setState(() {
                                            searchType = value!;
                                            isTextFieldEnabled = searchType != 'Tất cả';

                                            searchController.clear();
                                          });
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

                                    //input
                                    SizedBox(
                                      width: textInputWidth,
                                      height: 50,
                                      child: TextField(
                                        controller: searchController,
                                        enabled: isTextFieldEnabled,
                                        onSubmitted: (_) => searchDbPaper(),
                                        decoration: InputDecoration(
                                          hintText: 'Tìm kiếm...',
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          contentPadding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),

                                    //find
                                    AnimatedButton(
                                      onPressed: () {
                                        searchDbPaper();
                                      },
                                      label: "Tìm kiếm",
                                      icon: Icons.search,
                                      backgroundColor: themeController.buttonColor,
                                    ),
                                  ],
                                );
                              },
                            ),
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
                            loadDbPaper();
                          });
                        },
                        onNext: () {
                          setState(() {
                            currentPage++;
                            loadDbPaper();
                          });
                        },
                        onJumpToPage: (page) {
                          setState(() {
                            currentPage = page;
                            loadDbPaper();
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
        onPressed: () => loadDbPaper(),
        backgroundColor: themeController.buttonColor.value,
        child: const Icon(Icons.refresh, color: Colors.white),
      ),
    );
  }
}
