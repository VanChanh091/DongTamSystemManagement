import 'package:dongtam/data/controller/badges_controller.dart';
import 'package:dongtam/data/controller/theme_controller.dart';
import 'package:dongtam/data/controller/user_controller.dart';
import 'package:dongtam/data/models/planning/planning_paper_model.dart';
import 'package:dongtam/presentation/components/dialog/other/dialog_report_production.dart';
import 'package:dongtam/presentation/components/headerTable/planning/header_table_machine_paper.dart';
import 'package:dongtam/presentation/components/shared/left_button_search.dart';
import 'package:dongtam/presentation/components/shared/planning/handle_request_complete.dart';
import 'package:dongtam/presentation/components/shared/planning/widgets_planning.dart';
import 'package:dongtam/service/planning_service.dart';
import 'package:dongtam/utils/socket/init_socket_manufacture.dart';
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

  final socketService = SocketService();
  final formatter = DateFormat('dd/MM/yyyy');
  final dataGridController = DataGridController();
  final userController = Get.find<UserController>();
  final themeController = Get.find<ThemeController>();
  final badgesController = Get.find<BadgesController>();

  Map<String, double> columnWidths = {};
  List<String> selectedPlanningIds = [];
  List<PlanningPaper> planningList = [];

  //search
  final Map<String, String> searchFieldMap = {
    'Mã Đơn Hàng': "orderId",
    'Tên KH': "customerName",
    'Khổ Cấp Giấy': "ghepKho",
  };
  String searchType = "Tất cả";
  String machine = "Máy 1350";

  //flag
  bool isTextFieldEnabled = false;
  bool showGroup = true;

  //permission
  Map<String, String> permissionToMachineMap = {
    "machine1350": "Máy 1350",
    "machine1900": "Máy 1900",
    "machine2Layer": "Máy 2 Lớp",
    "MachineRollPaper": "Máy Quấn Cuồn",
  };

  //filter by runningPlan
  String filterType = "all";
  final Map<String, String> filterOptions = {
    'all': 'Tất cả',
    'gtZero': 'Còn SL Chạy',
    'ltZero': 'Hết SL Chạy',
  };

  //text controller
  TextEditingController searchController = TextEditingController();

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
      final String selectedField = searchFieldMap[searchType] ?? "";

      String keyword = searchController.text.trim().toLowerCase();

      if (searchType == "Tất cả") {
        futurePlanning = ensureMinLoading(
          ManufactureService().getPlanningPaper(machine: machine, filterType: filterType),
        );
      } else {
        futurePlanning = ensureMinLoading(
          PlanningService().getPlanningByMachine(
            field: selectedField,
            keyword: keyword,
            machine: machine,
          ),
        );
      }

      selectedPlanningIds.clear();
    });
  }

  void searchPlanning() {
    String keyword = searchController.text.trim().toLowerCase();
    AppLogger.i("searchPaper => searchType=$searchType | keyword=$keyword | machine=$machine");

    if (isTextFieldEnabled && keyword.isEmpty) {
      AppLogger.w("searchPaper => searchType=$searchType nhưng keyword rỗng");
      return;
    }

    setState(() {
      if (searchType == "Tất cả") {
        futurePlanning = ensureMinLoading(
          ManufactureService().getPlanningPaper(machine: machine, filterType: filterType),
        );
      } else {
        final selectedField = searchFieldMap[searchType] ?? "";

        futurePlanning = ensureMinLoading(
          PlanningService().getPlanningByMachine(
            field: selectedField,
            keyword: keyword,
            machine: machine,
          ),
        );
      }
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

    if (userController.role.value == 'admin') return true;

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

  //user for edit report
  bool canEditAction({
    required List<int> selectedPlanningIds,
    required List<PlanningPaper> planningList,
  }) {
    if (selectedPlanningIds.length != 1) return false;

    if (userController.role.value == 'admin') return true;

    final selectedPlanning = planningList.firstWhere(
      (p) => p.planningId == selectedPlanningIds.first,
      orElse: () => throw Exception("Không tìm thấy kế hoạch"),
    );

    // check số lượng sản xuất
    if ((selectedPlanning.qtyProduced ?? 0) <= 0) return false;

    //Check thời gian: Nếu now > dayCompleted thì disable
    if (selectedPlanning.dayCompleted != null) {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      final completionDate = DateTime(
        selectedPlanning.dayCompleted!.year,
        selectedPlanning.dayCompleted!.month,
        selectedPlanning.dayCompleted!.day,
      );

      if (today.isAfter(completionDate)) return false;
    }

    return true;
  }

  @override
  void dispose() {
    _initSocket.stop(machine);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool permissionCheck = userController.hasAnyPermission(
      permission: ["machine1350", "machine1900", "machine2Layer", "MachineRollPaper"],
    );

    //production check
    final bool isProduction =
        permissionCheck &&
        canExecuteAction(
          selectedPlanningIds: selectedPlanningIds.map(int.parse).toList(),
          planningList: planningList,
        );

    bool isEdit =
        permissionCheck &&
        canEditAction(
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
                        //left button
                        Expanded(
                          flex: 1,
                          child:
                              (userController.role.value == "admin" ||
                                      userController.role.value == "manager" ||
                                      !permissionCheck)
                                  ? LeftButtonSearch(
                                    selectedType: searchType,
                                    types: const [
                                      'Tất cả',
                                      'Mã Đơn Hàng',
                                      'Tên KH',
                                      'Khổ Cấp Giấy',
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
                                    onSearch: () => searchPlanning(),
                                  )
                                  : const SizedBox.shrink(),
                        ),

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
                                                if (selectedPlanningIds.isEmpty) {
                                                  showSnackBarError(
                                                    context,
                                                    "Chưa chọn dòng cần báo cáo",
                                                  );
                                                } else {
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
                                            }
                                            : null,
                                    label: "Báo Cáo",
                                    icon: Icons.assignment,
                                    backgroundColor: themeController.buttonColor,
                                  ),
                                  const SizedBox(width: 10),

                                  //edit qty report
                                  AnimatedButton(
                                    onPressed:
                                        isEdit
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

                                                final existingData = {
                                                  "manager": selectedPlanning.shiftManagement,
                                                  "shift": selectedPlanning.shiftProduction,
                                                };

                                                showDialog(
                                                  context: context,
                                                  builder:
                                                      (_) => DialogReportProduction(
                                                        planningId: selectedPlanning.planningId,
                                                        initialData: existingData,
                                                        onReport: () => loadPlanning(),
                                                      ),
                                                );

                                                //cập nhật badge
                                                badgesController.fetchPaperWaitingCheck();
                                                badgesController.fetchOrderPendingPlanning();
                                              } catch (e, s) {
                                                if (selectedPlanningIds.isEmpty) {
                                                  showSnackBarError(
                                                    context,
                                                    "Chưa chọn dòng cần sửa",
                                                  );
                                                } else {
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
                                            }
                                            : null,
                                    label: "Sửa Báo Cáo",
                                    icon: Symbols.construction,
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

                                  //filter
                                  buildDropdownItems(
                                    value: filterType,
                                    items: const ['all', 'gtZero', 'ltZero'],
                                    onChanged:
                                        (value) => {
                                          setState(() {
                                            filterType = value!;
                                            selectedPlanningIds.clear();
                                            loadPlanning();
                                          }),
                                        },
                                    itemLabelBuilder: (value) => filterOptions[value] ?? value,
                                  ),
                                  const SizedBox(width: 10),

                                  //popup menu
                                  PopupMenuButton(
                                    icon: const Icon(Icons.more_vert, color: Colors.black),
                                    color: Colors.white,
                                    onSelected: (value) async {
                                      if (value == 'confirm') {
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

                                          await ManufactureService().confirmProducingPaper(
                                            planningId: selectedPlanning.planningId,
                                          );

                                          loadPlanning();

                                          if (!context.mounted) return;
                                          showSnackBarSuccess(
                                            context,
                                            "Xác nhận sản xuất thành công",
                                          );
                                        } on ApiException catch (e) {
                                          final errorText = switch (e.errorCode) {
                                            'PLANNING_HAS_COMPLETED' => 'Đơn hàng đã hoàn thành',
                                            _ => 'Có lỗi xảy ra, vui lòng thử lại',
                                          };

                                          if (!context.mounted) return;
                                          showSnackBarError(context, errorText);
                                        } catch (e, s) {
                                          AppLogger.e(
                                            "Lỗi khi xác nhận SX",
                                            error: e,
                                            stackTrace: s,
                                          );
                                          if (!context.mounted) return;
                                          showSnackBarError(context, "Có lỗi khi xác nhận SX: $e");
                                        }
                                      } else if (value == 'request') {
                                        await handlePlanningTask(
                                          context: context,
                                          selectedPlanningIds: selectedPlanningIds,
                                          onExecute:
                                              (ids) => ManufactureService().requestCompletePapers(
                                                planningId: ids,
                                                action: 'REQUEST_COMPLETE',
                                              ),
                                          onLoadPlanning: loadPlanning,
                                        );
                                      }
                                    },
                                    itemBuilder:
                                        (BuildContext context) => [
                                          const PopupMenuItem<String>(
                                            value: 'confirm',
                                            child: ListTile(
                                              leading: Icon(Symbols.done_outline),
                                              title: Text('Xác Nhận Sản Xuất'),
                                            ),
                                          ),
                                          const PopupMenuItem<String>(
                                            value: 'request',
                                            child: ListTile(
                                              leading: Icon(Symbols.send),
                                              title: Text('Yêu Cầu Hoàn Thành'),
                                            ),
                                          ),
                                        ],
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
        onPressed: () => loadPlanning(),
        backgroundColor: themeController.buttonColor.value,
        child: const Icon(Icons.refresh, color: Colors.white),
      ),
    );
  }
}
