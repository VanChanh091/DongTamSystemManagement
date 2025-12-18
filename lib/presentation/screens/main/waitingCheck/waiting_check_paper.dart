import 'package:dongtam/data/controller/theme_controller.dart';
import 'package:dongtam/data/controller/user_controller.dart';
import 'package:dongtam/data/models/planning/planning_paper_model.dart';
import 'package:dongtam/presentation/components/dialog/qualityControl/dialog_check_qc_paper.dart';
import 'package:dongtam/presentation/components/headerTable/planning/header_table_machine_paper.dart';
import 'package:dongtam/presentation/sources/waitingCheck/waiting_check_paper_data_source.dart';
import 'package:dongtam/service/quality_control_service.dart';
import 'package:dongtam/service/warehouse_service.dart';
import 'package:dongtam/presentation/components/shared/animated_button.dart';
import 'package:dongtam/utils/handleError/show_snack_bar.dart';
import 'package:dongtam/utils/helper/grid_resize_helper.dart';
import 'package:dongtam/utils/helper/skeleton/skeleton_loading.dart';
import 'package:dongtam/utils/helper/style_table.dart';
import 'package:dongtam/utils/logger/app_logger.dart';
import 'package:dongtam/utils/storage/sharedPreferences/column_width_table.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class WaitingCheckPaper extends StatefulWidget {
  const WaitingCheckPaper({super.key});

  @override
  State<WaitingCheckPaper> createState() => _WaitingCheckPaperState();
}

class _WaitingCheckPaperState extends State<WaitingCheckPaper> {
  late Future<List<PlanningPaper>> futurePlanning;
  late WaitingCheckPaperDataSource waitingCheckPaperDS;
  late List<GridColumn> columns;
  final userController = Get.find<UserController>();
  final themeController = Get.find<ThemeController>();
  final formatter = DateFormat('dd/MM/yyyy');
  final dataGridController = DataGridController();
  Map<String, double> columnWidths = {};
  List<String> selectedPlanningIds = [];
  List<PlanningPaper> planningList = [];
  bool showGroup = true;

  @override
  void initState() {
    super.initState();

    loadPaperWaiting();

    columns = buildMachineColumns(themeController: themeController, page: "production");

    ColumnWidthTable.loadWidths(tableKey: 'queuePaper', columns: columns).then((w) {
      setState(() {
        columnWidths = w;
      });
    });
  }

  void loadPaperWaiting() {
    AppLogger.i("Loading all data waiting check paper");
    setState(() {
      futurePlanning = ensureMinLoading(WarehouseService().getPaperWaitingChecked());

      selectedPlanningIds.clear();
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
                        "DANH SÁCH GIẤY TẤM CHỜ KIỂM",
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
                        SizedBox(),

                        //right button
                        Expanded(
                          flex: 1,
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                // final maxWidth = constraints.maxWidth;
                                // final dropdownWidth = (maxWidth * 0.2).clamp(125.0, 175.0);

                                return Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    //inbound warehouse
                                    AnimatedButton(
                                      onPressed: () {
                                        final int selectedPlanningId = int.parse(
                                          selectedPlanningIds.first,
                                        );

                                        final selectedPlanning = planningList.firstWhere(
                                          (p) => p.planningId == selectedPlanningId,
                                          orElse: () => throw Exception("Không tìm thấy kế hoạch"),
                                        );

                                        showDialog(
                                          context: context,
                                          builder:
                                              (_) => DialogCheckQcPaper(
                                                planningId: selectedPlanning.planningId,
                                                onQcSessionAddOrUpdate: () => loadPaperWaiting(),
                                                type: 'paper',
                                              ),
                                        );
                                      },
                                      label: "Nhập Kho",
                                      icon: Symbols.input,
                                      backgroundColor: themeController.buttonColor,
                                    ),
                                    const SizedBox(width: 10),

                                    //confirm Finalized Session
                                    AnimatedButton(
                                      onPressed: () async {
                                        try {
                                          final int selectedPlanningId = int.parse(
                                            selectedPlanningIds.first,
                                          );

                                          // Tìm planning tương ứng
                                          final selectedPlanning = planningList.firstWhere(
                                            (p) => p.planningId == selectedPlanningId,
                                            orElse:
                                                () => throw Exception("Không tìm thấy kế hoạch"),
                                          );

                                          // Gửi yêu cầu xác nhận sản xuất
                                          await QualityControlService().confirmFinalizeSession(
                                            planningId: selectedPlanning.planningId,
                                            isPaper: true,
                                          );

                                          if (!context.mounted) return;

                                          loadPaperWaiting();
                                        } catch (e, s) {
                                          AppLogger.e(
                                            "Lỗi khi xác nhận SX",
                                            error: e,
                                            stackTrace: s,
                                          );
                                          if (!context.mounted) return;
                                          showSnackBarError(
                                            context,
                                            "Có lỗi khi hoàn thành phiên kiểm tra: $e",
                                          );
                                        }
                                      },
                                      label: "Hoàn Tất Nhập",
                                      icon: Symbols.done_outline,
                                      backgroundColor: themeController.buttonColor,
                                    ),
                                    const SizedBox(width: 10),
                                  ],
                                );
                              },
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

                  waitingCheckPaperDS = WaitingCheckPaperDataSource(
                    planning: data,
                    selectedPlanningIds: selectedPlanningIds,
                    showGroup: showGroup,
                  );

                  return SfDataGrid(
                    controller: dataGridController,
                    source: waitingCheckPaperDS,
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
                            child: formatColumn(
                              label: 'Số Lượng',
                              themeController: themeController,
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
                        waitingCheckPaperDS.selectedPlanningIds = selectedPlanningIds;
                        waitingCheckPaperDS.notifyListeners();
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
        onPressed: () => loadPaperWaiting(),
        backgroundColor: themeController.buttonColor.value,
        child: const Icon(Icons.refresh, color: Colors.white),
      ),
    );
  }
}
