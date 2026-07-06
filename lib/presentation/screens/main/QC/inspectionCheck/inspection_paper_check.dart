import 'package:dongtam/data/controller/theme_controller.dart';
import 'package:dongtam/data/controller/user_controller.dart';
import 'package:dongtam/data/models/planning/planning_paper_model.dart';
import 'package:dongtam/presentation/components/dialog/qc/dialog_inspection_check.dart';
import 'package:dongtam/presentation/components/headerTable/planning/header_table_machine_paper.dart';
import 'package:dongtam/presentation/components/shared/animated_button.dart';
import 'package:dongtam/presentation/components/shared/planning/widgets_planning.dart';
import 'package:dongtam/presentation/sources/planning/machine_paper_data_source.dart';
import 'package:dongtam/service/manufacture_service.dart';
import 'package:dongtam/utils/handleError/show_snack_bar.dart';
import 'package:dongtam/utils/helper/grid_resize_helper.dart';
import 'package:dongtam/utils/helper/skeleton/skeleton_loading.dart';
import 'package:dongtam/utils/helper/style_table.dart';
import 'package:dongtam/utils/logger/app_logger.dart';
import 'package:dongtam/utils/storage/sharedPreferences/column_width_table.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class InspectionPaperCheck extends StatefulWidget {
  const InspectionPaperCheck({super.key});

  @override
  State<InspectionPaperCheck> createState() => _InspectionPaperCheckState();
}

class _InspectionPaperCheckState extends State<InspectionPaperCheck> {
  late Future<List<PlanningPaper>> futurePlanning;
  late MachinePaperDatasource machinePaperDatasource;
  late List<GridColumn> columns;

  //controller
  final dataGridController = DataGridController();
  final userController = Get.find<UserController>();
  final themeController = Get.find<ThemeController>();

  Map<String, double> columnWidths = {};
  List<String> selectedPlanningIds = [];
  List<PlanningPaper> planningList = [];

  //filter
  String machine = "Máy 1350";
  String filterType = "all";
  final Map<String, String> filterOptions = {
    "all": "Tất cả",
    "gtZero": "Còn SL Chạy",
    "ltZero": "Hết SL Chạy",
  };

  @override
  void initState() {
    super.initState();
    loadInspectionPaper();

    columns = buildMachinePaperColumns(themeController: themeController, page: "production");
    ColumnWidthTable.loadWidths(tableKey: 'queuePaper', columns: columns).then((w) {
      setState(() {
        columnWidths = w;
      });
    });
  }

  void loadInspectionPaper() {
    setState(() {
      futurePlanning = ensureMinLoading(
        ManufactureService().getPlanningPaper(machine: machine, filterType: filterType),
      );

      selectedPlanningIds.clear();
    });
  }

  void changeMachine(String selectedMachine) {
    AppLogger.i("changeMachine | from=$machine -> to=$selectedMachine");
    setState(() {
      machine = selectedMachine;
      selectedPlanningIds.clear();
      loadInspectionPaper();
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
                        "DANH SÁCH GIẤY TẤM CHỜ KIỂM TRA",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                          color: themeController.currentColor.value,
                        ),
                      ),
                    ),
                  ),

                  //button menu
                  SizedBox(
                    height: 70,
                    width: double.infinity,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        //left button
                        const SizedBox(),

                        //right button
                        Expanded(
                          flex: 1,
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              reverse: true,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  //dialog inspection check
                                  AnimatedButton(
                                    onPressed:
                                        selectedPlanningIds.isNotEmpty
                                            ? () async {
                                              try {
                                                final int selectedPlanningId = int.parse(
                                                  selectedPlanningIds.first,
                                                );

                                                final selectedPlanning = planningList.firstWhere(
                                                  (p) => p.planningId == selectedPlanningId,
                                                  orElse:
                                                      () =>
                                                          throw Exception(
                                                            "Không tìm thấy kế hoạch",
                                                          ),
                                                );

                                                showDialog(
                                                  barrierDismissible: false,
                                                  context: context,
                                                  builder:
                                                      (_) => DialogInspectionCheck(
                                                        isQC: true,
                                                        isPaper: true,
                                                        planningId: selectedPlanning.planningId,
                                                        machine: machine,
                                                        onSubmit: () {
                                                          loadInspectionPaper();
                                                        },
                                                      ),
                                                );
                                              } catch (e, s) {
                                                if (selectedPlanningIds.isEmpty) {
                                                  showSnackBarError(
                                                    context,
                                                    "Vui lòng chọn một kế hoạch để kiểm tra",
                                                  );
                                                } else {
                                                  AppLogger.e(
                                                    "Lỗi khi mở dialog",
                                                    error: e,
                                                    stackTrace: s,
                                                  );
                                                  showSnackBarError(
                                                    context,
                                                    "Đã xảy ra lỗi khi mở form kiểm tra.",
                                                  );
                                                }
                                              }
                                            }
                                            : null,
                                    label: "Kiểm Tra",
                                    icon: Icons.check_circle,
                                    backgroundColor: themeController.buttonColor,
                                  ),
                                  const SizedBox(width: 10),

                                  //choose machine
                                  buildDropdownItems(
                                    value: machine,
                                    items: const [
                                      'Máy 1350',
                                      "Máy 1900",
                                      "Máy 2 Lớp",
                                      "Máy Quấn Cuồn",
                                    ],
                                    onChanged: (value) {
                                      if (value != null) {
                                        changeMachine(value);
                                      }
                                    },
                                  ),
                                  const SizedBox(width: 10),

                                  buildDropdownItems(
                                    width: 155,
                                    value: filterType,
                                    items: const ["all", "gtZero", "ltZero"],
                                    onChanged:
                                        (value) => {
                                          setState(() {
                                            filterType = value!;
                                            selectedPlanningIds.clear();
                                            loadInspectionPaper();
                                          }),
                                        },
                                    itemLabelBuilder: (value) => filterOptions[value] ?? value,
                                  ),
                                  const SizedBox(width: 10),
                                ],
                              ),
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
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                      child: Text(
                        "Không có đơn hàng nào",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
                      ),
                    );
                  }

                  final data = snapshot.data as List<PlanningPaper>;
                  planningList = data;

                  machinePaperDatasource = MachinePaperDatasource(
                    planning: data,
                    selectedPlanningIds: selectedPlanningIds,
                    showGroup: true,
                    page: 'production',
                    onRowTap: (PlanningPaper item) {
                      showDialog(
                        context: context,
                        builder:
                            (_) => DialogInspectionCheck(
                              isQC: false,
                              isPaper: true,
                              planningId: item.planningId,
                              machine: item.chooseMachine,
                              onSubmit: () {},
                            ),
                      );
                    },
                  );

                  return SfDataGrid(
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
                    frozenColumnsCount: 7,
                    stackedHeaderRows: <StackedHeaderRow>[
                      StackedHeaderRow(
                        cells: [
                          StackedHeaderCell(
                            columnNames: ['qtyProduced', 'runningPlanProd'],
                            child: Obx(
                              () =>
                                  formatColumn(label: 'Số Lượng', themeController: themeController),
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
                            child: formatColumn(
                              label: 'Định Mức Phế Liệu',
                              themeController: themeController,
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
                          tableKey: 'queuePaper',
                          columnWidths: columnWidths,
                          setState: setState,
                        ),

                    onSelectionChanged: (addedRows, removedRows) {
                      if (addedRows.isEmpty && removedRows.isEmpty) return;

                      setState(() {
                        final selectedRows = dataGridController.selectedRows;

                        selectedPlanningIds =
                            selectedRows
                                .map((row) {
                                  final cell = row.getCells().firstWhere(
                                    (c) => c.columnName == 'planningId',
                                    orElse:
                                        () =>
                                            const DataGridCell(columnName: 'planningId', value: ''),
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
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => loadInspectionPaper(),
        backgroundColor: themeController.buttonColor.value,
        child: const Icon(Icons.refresh, color: Colors.white),
      ),
    );
  }
}
