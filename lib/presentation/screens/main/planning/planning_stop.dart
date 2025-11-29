import 'package:dongtam/data/controller/badges_controller.dart';
import 'package:dongtam/data/controller/theme_controller.dart';
import 'package:dongtam/data/controller/user_controller.dart';
import 'package:dongtam/data/models/planning/planning_paper_model.dart';
import 'package:dongtam/presentation/components/headerTable/header_table_machine_paper.dart';
import 'package:dongtam/presentation/sources/machine_paper_data_source.dart';
import 'package:dongtam/service/planning_service.dart';
import 'package:dongtam/utils/handleError/show_snack_bar.dart';
import 'package:dongtam/utils/helper/animated_button.dart';
import 'package:dongtam/utils/helper/confirm_dialog.dart';
import 'package:dongtam/utils/helper/grid_resize_helper.dart';
import 'package:dongtam/utils/helper/pagination_controls.dart';
import 'package:dongtam/utils/helper/skeleton/skeleton_loading.dart';
import 'package:dongtam/utils/helper/style_table.dart';
import 'package:dongtam/utils/logger/app_logger.dart';
import 'package:dongtam/utils/storage/sharedPreferences/column_width_table.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';
import 'package:material_symbols_icons/symbols.dart';
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
  final badgesController = Get.find<BadgesController>();
  final themeController = Get.find<ThemeController>();
  final userController = Get.find<UserController>();
  final formatter = DateFormat('dd/MM/yyyy');

  TextEditingController searchController = TextEditingController();
  Map<String, double> columnWidths = {}; //map header table
  bool selectedAll = false;
  bool isTextFieldEnabled = false;

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
      futurePlanning = ensureMinLoading(
        PlanningService().getPlanningStop(page: currentPage, pageSize: pageSize),
      );

      selectedPlanningIds.clear();
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
                        Expanded(flex: 1, child: SizedBox()),

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
                                        handleCancelOrContinue(
                                          isSale: isSale,
                                          action: 'planning',
                                          label: "Tiếp Tục Chạy",
                                          iconData: Symbols.check,
                                        ),
                                        const SizedBox(width: 10),

                                        handleCancelOrContinue(
                                          isSale: isSale,
                                          action: 'cancel',
                                          label: "Hủy Đơn",
                                          iconData: Symbols.cancel,
                                        ),
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

  Widget handleCancelOrContinue({
    required bool isSale,
    required String action,
    required String label,
    required IconData iconData,
  }) {
    return AnimatedButton(
      onPressed:
          isSale
              ? () async {
                if (selectedPlanningIds.isEmpty) {
                  showSnackBarError(context, 'Vui lòng chọn kế hoạch cần thao tác');
                  return;
                }

                final confirm = await showConfirmDialog(
                  context: context,
                  title: "⚠️ Xác nhận",
                  content: "Bạn có chắc muốn thực hiện thao tác này?",
                  confirmText: "Ok",
                  confirmColor: const Color(0xffEA4346),
                );

                if (!confirm) return;

                if (!mounted) return;
                showLoadingDialog(context);

                try {
                  final success = await PlanningService().cancelOrContinuePlannning(
                    planningId:
                        selectedPlanningIds
                            .map((e) => int.tryParse(e.toString()))
                            .whereType<int>()
                            .toList(),
                    action: action,
                  );

                  if (success) {
                    badgesController.fetchPlanningStop();
                    loadPlanning();
                  }

                  if (!mounted) return;
                  Navigator.of(context).pop();
                  showSnackBarSuccess(context, "Thao tác thành công");
                } catch (e, s) {
                  if (mounted) Navigator.of(context).pop();
                  AppLogger.e("Error in cancelOrContinue: $e", stackTrace: s);

                  if (mounted) {
                    showSnackBarError(context, 'Có lỗi xảy ra, vui lòng thử lại');
                  }
                }
              }
              : null,
      label: label,
      icon: iconData,
      backgroundColor: action == 'cancel' ? const Color(0xffEA4346) : themeController.buttonColor,
    );
  }
}
