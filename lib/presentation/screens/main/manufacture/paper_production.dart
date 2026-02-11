import 'package:dongtam/data/controller/badges_controller.dart';
import 'package:dongtam/data/controller/theme_controller.dart';
import 'package:dongtam/data/controller/user_controller.dart';
import 'package:dongtam/data/models/planning/planning_paper_model.dart';
import 'package:dongtam/presentation/components/dialog/dialog_report_production.dart';
import 'package:dongtam/presentation/components/headerTable/planning/header_table_machine_paper.dart';
import 'package:dongtam/presentation/components/shared/init_socket_manufacture.dart';
import 'package:dongtam/presentation/sources/planning/machine_paper_data_source.dart';
import 'package:dongtam/service/manufacture_service.dart';
import 'package:dongtam/socket/socket_service.dart';
import 'package:dongtam/presentation/components/shared/animated_button.dart';
import 'package:dongtam/utils/handleError/api_exception.dart';
import 'package:dongtam/utils/helper/grid_resize_helper.dart';
import 'package:dongtam/utils/helper/skeleton/skeleton_loading.dart';
import 'package:dongtam/utils/helper/style_table.dart';
import 'package:dongtam/utils/logger/app_logger.dart';
import 'package:dongtam/utils/handleError/show_snack_bar.dart';
import 'package:dongtam/utils/storage/sharedPreferences/column_width_table.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class PaperProduction extends StatefulWidget {
  const PaperProduction({super.key});

  @override
  State<PaperProduction> createState() => _PaperProductionState();
}

class _PaperProductionState extends State<PaperProduction> {
  late Future<List<PlanningPaper>> futurePlanning;
  late MachinePaperDatasource machinePaperDatasource;
  late InitSocketManufacture _initSocket;
  late List<GridColumn> columns;
  final userController = Get.find<UserController>();
  final themeController = Get.find<ThemeController>();
  final badgesController = Get.find<BadgesController>();
  final socketService = SocketService();
  final formatter = DateFormat('dd/MM/yyyy');
  final DataGridController dataGridController = DataGridController();
  Map<String, double> columnWidths = {};
  List<String> selectedPlanningIds = [];
  List<PlanningPaper> planningList = [];
  String machine = "Máy 1350";
  bool showGroup = true;

  Map<String, String> permissionToMachineMap = {
    "machine1350": "Máy 1350",
    "machine1900": "Máy 1900",
    "machine2Layer": "Máy 2 Lớp",
    "MachineRollPaper": "Máy Quấn Cuồn",
  };

  @override
  void initState() {
    super.initState();

    _initSocket = InitSocketManufacture(
      context: context,
      socketService: socketService,
      eventName: "planningPaperUpdated",
      onLoadData: loadPlanning,
      onMachineChanged: (newMachine) {
        setState(() {
          machine = newMachine;
          selectedPlanningIds.clear();
        });
      },
    );

    _initSocket.registerSocket(machine);

    loadPlanning();

    columns = buildMachinePaperColumns(themeController: themeController, page: "production");

    ColumnWidthTable.loadWidths(tableKey: 'queuePaper', columns: columns).then((w) {
      setState(() {
        columnWidths = w;
      });
    });
  }

  void loadPlanning() {
    setState(() {
      futurePlanning = ensureMinLoading(ManufactureService().getPlanningPaper(machine: machine));

      selectedPlanningIds.clear();
    });
  }

  Future<void> changeMachine(String newMachine) async {
    _initSocket.changeMachine(oldMachine: machine, newMachine: newMachine);
  }

  bool userHasPermissionForMachine({
    required UserController userController,
    required String machine,
  }) {
    return permissionToMachineMap.entries.any(
      (entry) => entry.value == machine && userController.hasPermission(permission: entry.key),
    );
  }

  bool canExecuteAction({
    required List<int> selectedPlanningIds,
    required List<PlanningPaper> planningList,
  }) {
    if (selectedPlanningIds.length != 1) return false;

    final selectedPlanning = planningList.firstWhere(
      (p) => p.planningId == selectedPlanningIds.first,
      orElse: () => throw Exception("Không tìm thấy kế hoạch"),
    );

    // disable nếu đã complete
    if (selectedPlanning.status == "complete") return false;

    // ❌ disable nếu sản xuất đủ số lượng rồi
    if ((selectedPlanning.qtyProduced ?? 0) >= selectedPlanning.runningPlan) return false;

    // ❌ đứng sai máy
    if (!userHasPermissionForMachine(
      userController: userController,
      machine: selectedPlanning.chooseMachine,
    )) {
      return false;
    }

    return true;
  }

  @override
  void dispose() {
    final room = _initSocket.machineRoomName(machine);
    socketService.leaveRoom(room);
    socketService.off('planningPaperUpdated');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //production check
    final bool isProduction =
        userController.hasAnyPermission(
          permission: ["machine1350", "machine1900", "machine2Layer", "MachineRollPaper"],
        ) &&
        canExecuteAction(
          selectedPlanningIds: selectedPlanningIds.map(int.parse).toList(),
          planningList: planningList,
        );

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
                        "LỊCH SẢN XUẤT GIẤY TẤM",
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
                                final maxWidth = constraints.maxWidth;
                                final dropdownWidth = (maxWidth * 0.2).clamp(125.0, 175.0);

                                return Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    //report production
                                    AnimatedButton(
                                      onPressed:
                                          isProduction
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
                                                    context: context,
                                                    builder:
                                                        (_) => DialogReportProduction(
                                                          planningId: selectedPlanning.planningId,
                                                          onReport: () => loadPlanning(),
                                                        ),
                                                  );

                                                  //cập nhật badge
                                                  badgesController.fetchPaperWaitingCheck();
                                                  badgesController.fetchOrderPendingPlanning();
                                                } catch (e, s) {
                                                  AppLogger.e(
                                                    "Lỗi khi mở dialog",
                                                    error: e,
                                                    stackTrace: s,
                                                  );
                                                  showSnackBarError(
                                                    context,
                                                    "Đã xảy ra lỗi khi mở báo cáo.",
                                                  );
                                                }
                                              }
                                              : null,
                                      label: "Báo Cáo SX",
                                      icon: Icons.assignment,
                                      backgroundColor: themeController.buttonColor,
                                    ),
                                    const SizedBox(width: 10),

                                    //confirm production
                                    AnimatedButton(
                                      onPressed:
                                          isProduction
                                              ? () async {
                                                try {
                                                  // Lấy planningId (đang ở dạng String → convert sang int)
                                                  final int selectedPlanningId = int.parse(
                                                    selectedPlanningIds.first,
                                                  );

                                                  // Tìm planning tương ứng
                                                  final selectedPlanning = planningList.firstWhere(
                                                    (p) => p.planningId == selectedPlanningId,
                                                    orElse:
                                                        () =>
                                                            throw Exception(
                                                              "Không tìm thấy kế hoạch",
                                                            ),
                                                  );

                                                  // Gửi yêu cầu xác nhận sản xuất
                                                  await ManufactureService().confirmProducingPaper(
                                                    planningId: selectedPlanning.planningId,
                                                  );

                                                  if (!context.mounted) return;

                                                  loadPlanning();
                                                } on ApiException catch (e) {
                                                  final errorText = switch (e.errorCode) {
                                                    'PLANNING_HAS_COMPLETED' =>
                                                      'Đơn hàng đã hoàn thành',
                                                    _ => 'Có lỗi xảy ra, vui lòng thử lại',
                                                  };

                                                  if (mounted) {
                                                    showSnackBarError(context, errorText);
                                                  }
                                                } catch (e, s) {
                                                  AppLogger.e(
                                                    "Lỗi khi xác nhận SX",
                                                    error: e,
                                                    stackTrace: s,
                                                  );
                                                  if (!context.mounted) return;
                                                  showSnackBarError(
                                                    context,
                                                    "Có lỗi khi xác nhận SX: $e",
                                                  );
                                                }
                                              }
                                              : null,
                                      label: "Xác Nhận SX",
                                      icon: Symbols.done_outline,
                                      backgroundColor: themeController.buttonColor,
                                    ),
                                    const SizedBox(width: 10),

                                    //choose machine
                                    SizedBox(
                                      width: dropdownWidth,
                                      child: DropdownButtonFormField<String>(
                                        value: machine,
                                        items:
                                            [
                                              'Máy 1350',
                                              "Máy 1900",
                                              "Máy 2 Lớp",
                                              "Máy Quấn Cuồn",
                                            ].map((String value) {
                                              return DropdownMenuItem<String>(
                                                value: value,
                                                child: Text(value),
                                              );
                                            }).toList(),
                                        onChanged: (value) {
                                          if (value != null) {
                                            changeMachine(value);
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

                  machinePaperDatasource = MachinePaperDatasource(
                    planning: data,
                    selectedPlanningIds: selectedPlanningIds,
                    showGroup: showGroup,
                    page: 'production',
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
        onPressed: () => loadPlanning(),
        backgroundColor: themeController.buttonColor.value,
        child: const Icon(Icons.refresh, color: Colors.white),
      ),
    );
  }
}
