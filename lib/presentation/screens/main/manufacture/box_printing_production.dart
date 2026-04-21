import 'package:dongtam/data/controller/badges_controller.dart';
import 'package:dongtam/data/controller/theme_controller.dart';
import 'package:dongtam/data/controller/user_controller.dart';
import 'package:dongtam/data/models/planning/planning_box_model.dart';
import 'package:dongtam/presentation/components/dialog/other/dialog_report_production.dart';
import 'package:dongtam/presentation/components/headerTable/planning/header_table_machine_box.dart';
import 'package:dongtam/presentation/components/shared/left_button_search.dart';
import 'package:dongtam/presentation/components/shared/planning/handle_request_complete.dart';
import 'package:dongtam/presentation/components/shared/planning/widgets_planning.dart';
import 'package:dongtam/service/planning_service.dart';
import 'package:dongtam/utils/socket/init_socket_manufacture.dart';
import 'package:dongtam/presentation/sources/planning/machine_box_data_source.dart';
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

class BoxPrintingProduction extends StatefulWidget {
  const BoxPrintingProduction({super.key});

  @override
  State<BoxPrintingProduction> createState() => _BoxPrintingProductionState();
}

class _BoxPrintingProductionState extends State<BoxPrintingProduction> {
  late Future<List<PlanningBox>> futurePlanning;
  late MachineBoxDatasource machineBoxDatasource;
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
  List<PlanningBox> planningList = [];

  //search
  final Map<String, String> searchFieldMap = {
    'Mã Đơn Hàng': "orderId",
    'Tên KH': "customerName",
    'Quy Cách': "QcBox",
  };
  String searchType = "Tất cả";
  String machine = "Máy In";

  //flag
  bool isTextFieldEnabled = false;
  bool showGroup = true;

  //text controller
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();

    _initSocket = InitSocketManufacture(
      context: context,
      socketService: socketService,
      eventName: "planningBoxUpdated",
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

    columns = buildMachineBoxColumns(machine: machine, themeController: themeController);

    ColumnWidthTable.loadWidths(tableKey: 'queueBox', columns: columns).then((w) {
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
        futurePlanning = ensureMinLoading(ManufactureService().getPlanningBox(machine: machine));
      } else {
        futurePlanning = ensureMinLoading(
          PlanningService().getPlanningByMachine(
            field: selectedField,
            keyword: keyword,
            machine: machine,
            isBox: true,
          ),
        );
      }

      selectedPlanningIds.clear();
    });
  }

  void searchPlanning() {
    String keyword = searchController.text.trim().toLowerCase();
    AppLogger.i("searchBox => searchType=$searchType | keyword=$keyword | machine=$machine");

    if (isTextFieldEnabled && keyword.isEmpty) {
      AppLogger.w("searchBox => searchType=$searchType nhưng keyword rỗng");
      return;
    }

    setState(() {
      if (searchType == "Tất cả") {
        futurePlanning = ensureMinLoading(ManufactureService().getPlanningBox(machine: machine));
      } else {
        final selectedField = searchFieldMap[searchType] ?? "";

        futurePlanning = ensureMinLoading(
          PlanningService().getPlanningByMachine(
            field: selectedField,
            keyword: keyword,
            machine: machine,
            isBox: true,
          ),
        );
      }
    });
  }

  Future<void> changeMachine(String newMachine) async {
    _initSocket.changeMachine(oldMachine: machine, newMachine: newMachine);
  }

  bool canExecuteAction({
    required List<int> selectedPlanningIds,
    required List<PlanningBox> planningList,
    bool isRequest = false,
  }) {
    if (selectedPlanningIds.length != 1) return false;

    if (userController.role.value == 'admin') return true;

    final int selectedPlanningBoxId = selectedPlanningIds.first;

    final selectedPlanning = planningList.firstWhere(
      (p) => p.planningBoxId == selectedPlanningBoxId,
      orElse: () => throw Exception("Không tìm thấy kế hoạch"),
    );

    final boxTimes = selectedPlanning.boxTimes;
    if (boxTimes == null || boxTimes.isEmpty) return false;

    final box = boxTimes.first;

    // disable nếu đã complete
    if (box.status == "complete") return false;

    // ❌ disable nếu sản xuất đủ số lượng rồi
    // if ((box.qtyProduced ?? 0) >= box.runningPlan) return false;

    if (!isRequest) {
      // Nếu chưa có số lượng (runningPlan <= 0) thì không cho báo cáo
      if (box.runningPlan <= 0) return false;

      // Nếu now > dayCompleted thì return false
      if (box.dayCompleted != null) {
        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);
        final completionDate = DateTime(
          box.dayCompleted!.year,
          box.dayCompleted!.month,
          box.dayCompleted!.day,
        );

        if (today.isAfter(completionDate)) return false;
      }
    }

    if (isRequest) {
      return (box.qtyProduced ?? 0) > 0;
    } else {
      return (box.qtyProduced ?? 0) < box.runningPlan;
    }
  }

  @override
  void dispose() {
    _initSocket.stop(machine);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //production check
    bool permissionCheck = userController.hasPermission(permission: "step2Production");

    final bool isProduction =
        permissionCheck &&
        canExecuteAction(
          selectedPlanningIds: selectedPlanningIds.map(int.parse).toList(),
          planningList: planningList,
        );

    final bool canRequestCheck =
        permissionCheck &&
        canExecuteAction(
          selectedPlanningIds: selectedPlanningIds.map(int.parse).toList(),
          planningList: planningList,
          isRequest: true,
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
                        "LỊCH SẢN XUẤT THÙNG",
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
                                    types: const ['Tất cả', 'Mã Đơn Hàng', 'Tên KH', 'Quy Cách'],
                                    onTypeChanged: (value) {
                                      setState(() {
                                        searchType = value;
                                        isTextFieldEnabled = searchType != 'Tất cả';
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
                                                final int selectedPlanningBoxId = int.parse(
                                                  selectedPlanningIds.first,
                                                );

                                                final selectedPlanning = planningList.firstWhere(
                                                  (p) => p.planningBoxId == selectedPlanningBoxId,
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
                                                        planningId: selectedPlanning.planningBoxId,
                                                        qtyPaper: selectedPlanning.qtyPaper,
                                                        onReport: () => loadPlanning(),
                                                        machine: machine,
                                                        isPaper: false,
                                                      ),
                                                );
                                              } catch (e, s) {
                                                if (!context.mounted) return;
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
                                    label: "Báo Cáo",
                                    icon: Icons.assignment,
                                    backgroundColor: themeController.buttonColor,
                                  ),
                                  const SizedBox(width: 10),

                                  //edit qty report
                                  AnimatedButton(
                                    onPressed:
                                        canRequestCheck
                                            ? () async {
                                              try {
                                                final int selectedPlanningBoxId = int.parse(
                                                  selectedPlanningIds.first,
                                                );

                                                final selectedPlanning = planningList.firstWhere(
                                                  (p) => p.planningBoxId == selectedPlanningBoxId,
                                                  orElse:
                                                      () =>
                                                          throw Exception(
                                                            "Không tìm thấy kế hoạch",
                                                          ),
                                                );

                                                final boxTimes = selectedPlanning.boxTimes?.first;

                                                final existingData = {
                                                  "qty": boxTimes!.qtyProduced ?? 0,
                                                  "waste": boxTimes.wasteBox ?? 0,
                                                  "manager": boxTimes.shiftManagement,
                                                };

                                                // print("Existing data for report: $existingData");

                                                showDialog(
                                                  context: context,
                                                  builder:
                                                      (_) => DialogReportProduction(
                                                        planningId: selectedPlanning.planningBoxId,
                                                        initialData: existingData,
                                                        qtyPaper: selectedPlanning.qtyPaper,
                                                        onReport: () => loadPlanning(),
                                                        machine: machine,
                                                        isPaper: false,
                                                      ),
                                                );
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
                                    label: "Sửa Báo Cáo",
                                    icon: Symbols.construction,
                                    backgroundColor: themeController.buttonColor,
                                  ),
                                  const SizedBox(width: 10),

                                  //confirm production
                                  AnimatedButton(
                                    onPressed:
                                        isProduction
                                            ? () async {
                                              try {
                                                //get planning first
                                                final int selectedPlanningBoxId = int.parse(
                                                  selectedPlanningIds.first,
                                                );

                                                // find planning by planningId
                                                final selectedPlanning = planningList.firstWhere(
                                                  (p) => p.planningBoxId == selectedPlanningBoxId,
                                                  orElse:
                                                      () =>
                                                          throw Exception(
                                                            "Không tìm thấy kế hoạch",
                                                          ),
                                                );

                                                await ManufactureService().confirmProducingBox(
                                                  planningBoxId: selectedPlanning.planningBoxId,
                                                  machine: machine,
                                                );

                                                loadPlanning();

                                                if (!context.mounted) return;
                                                showSnackBarSuccess(
                                                  context,
                                                  "Xác nhận sản xuất thành công",
                                                );
                                              } on ApiException catch (e) {
                                                final errorText = switch (e.errorCode) {
                                                  'PLANNING_COMPLETED' => 'Đơn hàng đã hoàn thành',
                                                  _ => 'Có lỗi xảy ra, vui lòng thử lại',
                                                };

                                                if (!context.mounted) return;
                                                showSnackBarError(context, errorText);
                                              } catch (e) {
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

                                  //popupmenu
                                  PopupMenuButton(
                                    icon: const Icon(Icons.more_vert, color: Colors.black),
                                    color: Colors.white,
                                    onSelected: (value) async {
                                      if (value == 'sendCheck') {
                                        try {
                                          //get planning first
                                          final int selectedPlanningBoxId = int.parse(
                                            selectedPlanningIds.first,
                                          );

                                          // find planning by planningId
                                          final selectedPlanning = planningList.firstWhere(
                                            (p) => p.planningBoxId == selectedPlanningBoxId,
                                            orElse:
                                                () => throw Exception("Không tìm thấy kế hoạch"),
                                          );

                                          await ManufactureService().updateRequestStockCheck(
                                            planningBoxId: selectedPlanning.planningBoxId,
                                            machine: machine,
                                          );

                                          //cập nhật badge
                                          badgesController.fetchBoxWaitingCheck();

                                          loadPlanning();

                                          if (!context.mounted) return;
                                          showSnackBarSuccess(
                                            context,
                                            "Gửi yêu cầu kiểm tra thành công",
                                          );
                                        } on ApiException catch (e) {
                                          final errorText = switch (e.errorCode) {
                                            'PLANNING_ALREADY_REQUESTED' =>
                                              "Đơn này đã yêu cầu kiểm tra rồi",
                                            'STEP_QUANTITY_EQUAL_ZERO' =>
                                              "Có công đoạn chưa có số lượng, không thể yêu cầu nhập kho.",
                                            _ => 'Có lỗi xảy ra, vui lòng thử lại',
                                          };

                                          if (mounted) {
                                            showSnackBarError(context, errorText);
                                          }
                                        } catch (e) {
                                          if (!context.mounted) return;
                                          showSnackBarError(context, "Có lỗi khi xác nhận SX: $e");
                                        }
                                      } else if (value == 'request') {
                                        await handlePlanningTask(
                                          context: context,
                                          selectedPlanningIds: selectedPlanningIds,
                                          onExecute:
                                              (ids) => ManufactureService().requestCompleteBoxes(
                                                planningBoxId: ids,
                                                machine: machine,
                                                action: 'REQUEST_COMPLETE',
                                              ),
                                          onLoadPlanning: loadPlanning,
                                        );
                                      }
                                    },
                                    itemBuilder:
                                        (BuildContext context) => [
                                          const PopupMenuItem<String>(
                                            value: 'sendCheck',
                                            child: ListTile(
                                              leading: Icon(Symbols.send),
                                              title: Text('Yêu Cầu Kiểm'),
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

                  final List<PlanningBox> data = snapshot.data!;
                  planningList = data;

                  machineBoxDatasource = MachineBoxDatasource(
                    planning: data,
                    selectedPlanningIds: selectedPlanningIds,
                    showGroup: showGroup,
                    machine: machine,
                  );

                  return SfDataGrid(
                    controller: dataGridController,
                    source: machineBoxDatasource,
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
                                label: 'Số Lượng Của Các Công Đoạn',
                                themeController: themeController,
                              ),
                            ),
                          ),
                          StackedHeaderCell(
                            columnNames: ["quantityOrd", "qtyPaper", "needProd"],
                            child: Obx(
                              () =>
                                  formatColumn(label: 'Số Lượng', themeController: themeController),
                            ),
                          ),
                          StackedHeaderCell(
                            columnNames: ["inMatTruoc", "inMatSau"],
                            child: Obx(
                              () => formatColumn(label: 'In Ấn', themeController: themeController),
                            ),
                          ),
                          StackedHeaderCell(
                            columnNames: ["dan_1_Manh", "dan_2_Manh"],
                            child: Obx(
                              () => formatColumn(label: 'Dán', themeController: themeController),
                            ),
                          ),
                          StackedHeaderCell(
                            columnNames: ["dongGhim1Manh", "dongGhim2Manh"],
                            child: Obx(
                              () => formatColumn(
                                label: 'Đóng Ghim',
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
                          tableKey: 'queueBox',
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
                                    (c) => c.columnName == 'planningBoxId',
                                    orElse:
                                        () => const DataGridCell(
                                          columnName: 'planningBoxId',
                                          value: '',
                                        ),
                                  );
                                  return cell.value.toString();
                                })
                                .where((id) => id.isNotEmpty)
                                .toList();

                        // cập nhật cho datasource
                        machineBoxDatasource.selectedPlanningIds = selectedPlanningIds;
                        machineBoxDatasource.notifyListeners();
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
