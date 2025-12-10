import 'package:dongtam/data/controller/theme_controller.dart';
import 'package:dongtam/data/controller/unsaved_change_controller.dart';
import 'package:dongtam/data/controller/user_controller.dart';
import 'package:dongtam/data/models/planning/planning_box_model.dart';
import 'package:dongtam/presentation/components/headerTable/header_table_machine_box.dart';
import 'package:dongtam/presentation/components/shared/planning/save_planning.dart';
import 'package:dongtam/presentation/sources/planning/machine_box_data_source.dart';
import 'package:dongtam/service/planning_service.dart';
import 'package:dongtam/presentation/components/shared/animated_button.dart';
import 'package:dongtam/utils/helper/confirm_dialog.dart';
import 'package:dongtam/utils/helper/grid_resize_helper.dart';
import 'package:dongtam/utils/helper/skeleton/skeleton_loading.dart';
import 'package:dongtam/utils/helper/style_table.dart';
import 'package:dongtam/presentation/components/shared/left_button_search.dart';
import 'package:dongtam/presentation/components/shared/planning/widgets_planning.dart';
import 'package:dongtam/utils/logger/app_logger.dart';
import 'package:dongtam/utils/handleError/show_snack_bar.dart';
import 'package:dongtam/utils/storage/sharedPreferences/column_width_table.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class ProductionQueueBox extends StatefulWidget {
  const ProductionQueueBox({super.key});

  @override
  State<ProductionQueueBox> createState() => _ProductionQueueBoxState();
}

class _ProductionQueueBoxState extends State<ProductionQueueBox> {
  late Future<List<PlanningBox>> futurePlanning;
  late MachineBoxDatasource machineBoxDatasource;
  late List<GridColumn> columns;
  final DataGridController dataGridController = DataGridController();
  final unsavedChangeController = Get.find<UnsavedChangeController>();
  final userController = Get.find<UserController>();
  final themeController = Get.find<ThemeController>();
  final formatter = DateFormat('dd/MM/yyyy');
  final Map<String, String> searchFieldMap = {
    'Mã Đơn Hàng': "orderId",
    'Tên KH': "customerName",
    'Quy Cách': "QcBox",
  };
  String searchType = "Tất cả";
  Map<String, double> columnWidths = {};
  List<String> selectedPlanningBoxIds = [];
  String machine = "Máy In";
  DateTime? dayStart = DateTime.now();
  DateTime selectedDate = DateTime.now();
  bool isTextFieldEnabled = false;
  bool isLoading = false;
  bool showGroup = true;

  TextEditingController searchController = TextEditingController();
  TextEditingController dayStartController = TextEditingController();
  TextEditingController timeStartController = TextEditingController();
  TextEditingController totalTimeWorkingController = TextEditingController();

  @override
  void initState() {
    super.initState();

    if (userController.hasPermission(permission: "plan")) {
      loadPlanning();
    } else {
      futurePlanning = Future.error("NO_PERMISSION");
    }

    columns = buildMachineBoxColumns(machine: machine, themeController: themeController);

    ColumnWidthTable.loadWidths(tableKey: 'queueBox', columns: columns).then((w) {
      setState(() {
        columnWidths = w;
      });
    });

    final now = DateTime.now();
    dayStartController.text =
        "${now.day.toString().padLeft(2, '0')}/"
        "${now.month.toString().padLeft(2, '0')}/"
        "${now.year}";
    timeStartController.text = '6:00';
    totalTimeWorkingController.text = "16";
  }

  void loadPlanning() {
    setState(() {
      final String selectedField = searchFieldMap[searchType] ?? "";

      String keyword = searchController.text.trim().toLowerCase();

      if (searchType != "Tất cả") {
        AppLogger.i("loadPlanning: keyword='$keyword'");

        futurePlanning = ensureMinLoading(
          PlanningService().getPlanningSearch(
            field: selectedField,
            keyword: keyword,
            machine: machine,
            isBox: true,
          ),
        );
      } else {
        futurePlanning = ensureMinLoading(
          PlanningService().getPlanningByMachine(machine: machine, isBox: true),
        );
      }

      selectedPlanningBoxIds.clear();
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
        futurePlanning = ensureMinLoading(
          PlanningService().getPlanningByMachine(machine: machine, isBox: true),
        );
      } else {
        final selectedField = searchFieldMap[searchType] ?? "";

        futurePlanning = ensureMinLoading(
          PlanningService().getPlanningSearch(
            field: selectedField,
            keyword: keyword,
            machine: machine,
            isBox: true,
          ),
        );
      }
    });
  }

  void changeMachine(String selectedMachine) {
    AppLogger.i("changeMachineBox | from=$machine -> to=$selectedMachine");
    setState(() {
      machine = selectedMachine;
      selectedPlanningBoxIds.clear();
      loadPlanning();
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isPlan = userController.hasPermission(permission: "plan");

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
              child:
                  isPlan
                      ? Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              //left button
                              Expanded(
                                flex: 1,
                                child: LeftButtonSearch(
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
                                      // nút lên xuống
                                      rowMoveButtons(
                                        enabled: selectedPlanningBoxIds.isNotEmpty,
                                        onMoveUp: () {
                                          setState(() {
                                            machineBoxDatasource.moveRowUp(selectedPlanningBoxIds);
                                          });
                                        },
                                        onMoveDown: () {
                                          setState(() {
                                            machineBoxDatasource.moveRowDown(
                                              selectedPlanningBoxIds,
                                            );
                                          });
                                        },
                                      ),
                                      const SizedBox(width: 20),

                                      // save
                                      SavePlanning(
                                        isLoading: isLoading,
                                        dayStartController: dayStartController,
                                        timeStartController: timeStartController,
                                        totalTimeWorkingController: totalTimeWorkingController,
                                        getRows: () => machineBoxDatasource.rows,
                                        idColumn: 'planningBoxId',
                                        isBox: true,
                                        backgroundColor: themeController.buttonColor,
                                        machine: machine,
                                        onSuccess: () {
                                          loadPlanning();
                                          unsavedChangeController.resetUnsavedChanges();
                                        },
                                        onStartLoading: () => setState(() => isLoading = true),
                                        onEndLoading: () => setState(() => isLoading = false),
                                      ),
                                      const SizedBox(width: 10),

                                      //group/unGroup
                                      AnimatedButton(
                                        onPressed: () {
                                          setState(() {
                                            showGroup = !showGroup;
                                          });
                                        },
                                        label: showGroup ? 'Tắt nhóm' : 'Bật nhóm',
                                        icon: showGroup ? Symbols.ungroup : Symbols.ad_group,
                                        backgroundColor: themeController.buttonColor,
                                      ),
                                      const SizedBox(width: 10),

                                      //confirm complete
                                      confirmCompleteButton(
                                        context: context,
                                        selectedIds: selectedPlanningBoxIds,
                                        onConfirmComplete: (ids) async {
                                          return await PlanningService().confirmCompletePlanning(
                                            ids: ids,
                                            machine: machine,
                                            isBox: true,
                                          );
                                        },
                                        backgroundColor: themeController.buttonColor,
                                        onReload: () => loadPlanning(),
                                      ),
                                      const SizedBox(width: 10),

                                      //choose machine
                                      buildMachineDropdown(
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
                                          if (value != null) changeMachine(value);
                                        },
                                      ),
                                      const SizedBox(width: 10),

                                      //popup menu
                                      PopupMenuButton<String>(
                                        icon: const Icon(Icons.more_vert, color: Colors.black),
                                        color: Colors.white,
                                        onSelected: (value) async {
                                          if (value == 'acceptLack') {
                                            await handlePlanningAction(
                                              context: context,
                                              selectedPlanningIds: selectedPlanningBoxIds,
                                              planningList: machineBoxDatasource.planning,
                                              machine: machine,
                                              status: "complete",
                                              title: "Xác nhận thiếu số lượng",
                                              message: "Bạn có chắc muốn chấp nhận thiếu không?",
                                              successMessage: "Thực thi thành công",
                                              errorMessage: "Có lỗi xảy ra khi thực thi",
                                              onSuccess: () => loadPlanning(),
                                            );
                                          }
                                        },
                                        itemBuilder:
                                            (BuildContext context) => [
                                              const PopupMenuItem<String>(
                                                value: 'acceptLack',
                                                child: ListTile(
                                                  leading: Icon(Icons.approval_outlined),
                                                  title: Text('Chấp Nhận Thiếu SL'),
                                                ),
                                              ),
                                            ],
                                      ),
                                      const SizedBox(width: 10),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),

                          //set day and time for time running
                          const SizedBox(height: 5),
                          timeAndDayPlanning(
                            context: context,
                            dayStartController: dayStartController,
                            timeStartController: timeStartController,
                            totalTimeWorkingController: totalTimeWorkingController,
                          ),
                        ],
                      )
                      : const SizedBox.shrink(),
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
                    if (snapshot.error.toString().contains("NO_PERMISSION")) {
                      return const Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.lock_outline, color: Colors.redAccent, size: 35),
                            SizedBox(width: 8),
                            Text(
                              "Bạn không có quyền xem chức năng này",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 26,
                                color: Colors.redAccent,
                              ),
                            ),
                          ],
                        ),
                      );
                    }
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

                  machineBoxDatasource = MachineBoxDatasource(
                    planning: data,
                    selectedPlanningIds: selectedPlanningBoxIds,
                    unsavedChange: unsavedChangeController,
                    machine: machine,
                    showGroup: showGroup,
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

                        selectedPlanningBoxIds =
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
                        machineBoxDatasource.selectedPlanningIds = selectedPlanningBoxIds;
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
      floatingActionButton: Obx(
        () =>
            isPlan
                ? FloatingActionButton(
                  onPressed: () => loadPlanning(),
                  backgroundColor: themeController.buttonColor.value,
                  child: const Icon(Icons.refresh, color: Colors.white),
                )
                : SizedBox.shrink(),
      ),
    );
  }

  Future<void> handlePlanningAction({
    required BuildContext context,
    required List<String> selectedPlanningIds,
    List<PlanningBox>? planningList,
    required String status,
    required String machine,
    required String title,
    required String message,
    required String successMessage,
    required String errorMessage,
    required VoidCallback onSuccess,
  }) async {
    if (selectedPlanningIds.isEmpty) {
      showSnackBarError(context, "Chưa chọn kế hoạch cần thực hiện");
      return;
    }

    final planningIds =
        selectedPlanningIds
            .map((e) => int.tryParse(e))
            .whereType<int>() // lọc bỏ phần tử null nếu parse fail
            .toList();

    final selectedPlannings =
        planningList?.where((p) => planningIds.contains(p.planningBoxId)).toList() ?? [];

    // check sortPlanning
    final hasNoSortPlanning = selectedPlannings.any((p) {
      final boxTime = (p.boxTimes != null && p.boxTimes!.isNotEmpty) ? p.boxTimes!.first : null;
      return boxTime == null || boxTime.sortPlanning == null || boxTime.sortPlanning == 0;
    });
    if (hasNoSortPlanning) {
      showSnackBarError(context, "Đơn hàng chưa được sắp xếp");
      return;
    }

    // check dayCompleted
    final hasNoDayCompleted = selectedPlannings.any((p) {
      final boxTime = (p.boxTimes != null && p.boxTimes!.isNotEmpty) ? p.boxTimes!.first : null;
      return boxTime == null || boxTime.dayCompleted == null;
    });
    if (hasNoDayCompleted) {
      showSnackBarError(context, "Đơn hàng chưa có ngày hoàn thành");
      return;
    }

    bool confirm = await showConfirmDialog(
      context: context,
      title: title,
      content: message,
      confirmText: "Xác nhận",
    );

    if (confirm) {
      try {
        final success = await PlanningService().pauseOrAcceptLackQty(
          ids: planningIds,
          newStatus: status,
          machine: machine,
          isBox: true,
        );

        if (!context.mounted) return;

        if (success) {
          showSnackBarSuccess(context, successMessage);
          onSuccess();
        }
      } catch (e) {
        if (!context.mounted) return;
        showSnackBarError(context, errorMessage);
      }
    }
  }
}
