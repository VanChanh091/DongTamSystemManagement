import 'package:dongtam/data/controller/theme_controller.dart';
import 'package:dongtam/data/controller/user_controller.dart';
import 'package:dongtam/data/models/planning/planning_paper_model.dart';
import 'package:dongtam/presentation/components/headerTable/header_table_machine_paper.dart';
import 'package:dongtam/presentation/sources/machine_paper_data_source.dart';
import 'package:dongtam/service/planning_service.dart';
import 'package:dongtam/utils/helper/animated_button.dart';
import 'package:dongtam/utils/helper/grid_resize_helper.dart';
import 'package:dongtam/utils/helper/pagination_controls.dart';
import 'package:dongtam/utils/helper/skeleton/skeleton_loading.dart';
import 'package:dongtam/utils/helper/style_table.dart';
import 'package:dongtam/utils/logger/app_logger.dart';
import 'package:dongtam/utils/storage/sharedPreferences/column_width_table.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class PlanningStop extends StatefulWidget {
  const PlanningStop({super.key});

  @override
  State<PlanningStop> createState() => _PlanningStopState();
}

class _PlanningStopState extends State<PlanningStop> {
  late Future<Map<String, dynamic>> futurePlanning;
  late MachinePaperDatasource machinePaperDatasource;
  late List<GridColumn> columns;
  final DataGridController dataGridController = DataGridController();
  final themeController = Get.find<ThemeController>();
  final userController = Get.find<UserController>();
  final formatter = DateFormat('dd/MM/yyyy');
  final Map<String, String> searchFieldMap = {};

  TextEditingController searchController = TextEditingController();
  Map<String, double> columnWidths = {}; //map header table
  bool selectedAll = false;
  bool isTextFieldEnabled = false;
  bool isSearching = false; //dùng để phân trang cho tìm kiếm
  String searchType = "Tất cả";
  List<String> selectedPlanningIds = [];

  int currentPage = 1;
  int pageSize = 30;
  int pageSizeSearch = 20;

  @override
  void initState() {
    super.initState();
    loadPlanning();

    columns = buildMachineColumns(themeController: themeController, page: "planning");

    ColumnWidthTable.loadWidths(tableKey: 'planningStop', columns: columns).then((w) {
      setState(() {
        columnWidths = w;
      });
    });
  }

  void loadPlanning() {
    setState(() {
      // final String selectedField = searchFieldMap[searchType] ?? "";

      String keyword = searchController.text.trim().toLowerCase();

      if (isSearching && searchType != "Tất cả") {
        AppLogger.i("loadPlanning: isSearching=true, keyword='$keyword'");

        // futurePlanning = ensureMinLoading(
        //   PlanningService().getCustomerByField(
        //     field: selectedField,
        //     keyword: keyword,
        //     page: currentPage,
        //     pageSize: pageSizeSearch,
        //   ),
        // );
      } else {
        futurePlanning = ensureMinLoading(
          PlanningService().getPlanningStop(page: currentPage, pageSize: pageSize),
        );
      }

      selectedPlanningIds.clear();
    });
  }

  void searchPlanning() {
    String keyword = searchController.text.trim().toLowerCase();
    AppLogger.i("searchPlanning: searchType=$searchType, keyword='$keyword'");

    if (isTextFieldEnabled && keyword.isEmpty) {
      AppLogger.w("searchPlanning: search bị bỏ qua vì keyword trống");
      return;
    }

    setState(() {
      currentPage = 1;
      isSearching = (searchType != "Tất cả");

      if (searchType == "Tất cả") {
        futurePlanning = ensureMinLoading(
          PlanningService().getPlanningStop(page: currentPage, pageSize: pageSize),
        );
      } else {
        // final selectedField = searchFieldMap[searchType] ?? "";

        // futurePlanning = ensureMinLoading(
        //   PlanningService().getCustomerByField(
        //     field: selectedField,
        //     keyword: keyword,
        //     page: currentPage,
        //     pageSize: pageSizeSearch,
        //   ),
        // );
      }
    });
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
                        "DANH SÁCH KẾ HOẠCH BỊ DỪNG",
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
                                final dropdownWidth = (maxWidth * 0.2).clamp(120.0, 170.0);
                                final textInputWidth = (maxWidth * 0.3).clamp(200.0, 250.0);

                                return Row(
                                  children: [
                                    //dropdown
                                    SizedBox(
                                      width: dropdownWidth,
                                      child: DropdownButtonFormField<String>(
                                        value: searchType,
                                        items:
                                            ['Tất cả'].map((String value) {
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
                                        onSubmitted: (_) => searchPlanning(),
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
                                        searchPlanning();
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
                            child:
                                isSale
                                    ? Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [SizedBox()],
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
                future: futurePlanning,
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
                  } else if (!snapshot.hasData || snapshot.data!['plannings'].isEmpty) {
                    return const Center(
                      child: Text(
                        "Không có đơn hàng nào",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
                      ),
                    );
                  }

                  final data = snapshot.data!;
                  final plannings = data['plannings'] as List<PlanningPaper>;
                  final currentPg = data['currentPage'];
                  final totalPgs = data['totalPages'];

                  machinePaperDatasource = MachinePaperDatasource(
                    planning: plannings,
                    selectedPlanningIds: selectedPlanningIds,
                    showGroup: true,
                    page: 'planning',
                  );

                  return Column(
                    children: [
                      //table
                      Expanded(
                        child: SfDataGrid(
                          controller: dataGridController,
                          source: machinePaperDatasource,
                          allowExpandCollapseGroup: true, // Bật grouping
                          autoExpandGroups: true,
                          isScrollbarAlwaysShown: true,
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
                                  columnNames: ['quantityOrd', 'runningPlanProd', 'qtyProduced'],
                                  child: Obx(
                                    () => formatColumn(
                                      label: 'Số Lượng',
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
                                columns: columns,
                                setState: setState,
                              ),
                          onColumnResizeEnd:
                              (details) => GridResizeHelper.onResizeEnd(
                                details: details,
                                tableKey: 'planningStop',
                                columnWidths: columnWidths,
                                setState: setState,
                              ),

                          onSelectionChanged: (addedRows, removedRows) {
                            if (addedRows.isEmpty && removedRows.isEmpty) return;

                            setState(() {
                              // Lấy selection thật sự từ controller
                              final selectedRows = dataGridController.selectedRows;

                              selectedPlanningIds =
                                  selectedRows
                                      .map((row) {
                                        final cell = row.getCells().firstWhere(
                                          (c) => c.columnName == 'planningId',
                                          orElse:
                                              () => const DataGridCell(
                                                columnName: 'planningId',
                                                value: '',
                                              ),
                                        );
                                        return cell.value.toString();
                                      })
                                      .where((id) => id.isNotEmpty)
                                      .toList();

                              // cập nhật cho datasource
                              machinePaperDatasource.selectedPlanningIds = selectedPlanningIds;
                              machinePaperDatasource.notifyListeners();
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
                            loadPlanning();
                          });
                        },
                        onNext: () {
                          setState(() {
                            currentPage++;
                            loadPlanning();
                          });
                        },
                        onJumpToPage: (page) {
                          setState(() {
                            currentPage = page;
                            loadPlanning();
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
        onPressed: () => loadPlanning(),
        backgroundColor: themeController.buttonColor.value,
        child: const Icon(Icons.refresh, color: Colors.white),
      ),
    );
  }
}
