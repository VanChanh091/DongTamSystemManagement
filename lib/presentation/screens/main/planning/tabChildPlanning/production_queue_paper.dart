import 'package:dongtam/data/controller/badges_controller.dart';
import 'package:dongtam/data/controller/theme_controller.dart';
import 'package:dongtam/data/controller/unsaved_change_controller.dart';
import 'package:dongtam/data/controller/user_controller.dart';
import 'package:dongtam/data/models/planning/planning_paper_model.dart';
import 'package:dongtam/presentation/components/dialog/dialog_change_machine.dart';
import 'package:dongtam/presentation/components/headerTable/header_table_machine_paper.dart';
import 'package:dongtam/presentation/sources/machine_paper_data_source.dart';
import 'package:dongtam/service/planning_service.dart';
import 'package:dongtam/presentation/components/shared/animated_button.dart';
import 'package:dongtam/utils/helper/confirm_dialog.dart';
import 'package:dongtam/utils/helper/grid_resize_helper.dart';
import 'package:dongtam/utils/helper/skeleton/skeleton_loading.dart';
import 'package:dongtam/utils/helper/style_table.dart';
import 'package:dongtam/presentation/components/shared/left_button_search.dart';
import 'package:dongtam/presentation/components/shared/planning/time_and_day_planning.dart';
import 'package:dongtam/utils/helper/warning_unsaved_change.dart';
import 'package:dongtam/utils/logger/app_logger.dart';
import 'package:dongtam/utils/handleError/show_snack_bar.dart';
import 'package:dongtam/utils/storage/sharedPreferences/column_width_table.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class ProductionQueuePaper extends StatefulWidget {
  const ProductionQueuePaper({super.key});

  @override
  State<ProductionQueuePaper> createState() => _ProductionQueuePaperState();
}

class _ProductionQueuePaperState extends State<ProductionQueuePaper> {
  late Future<List<PlanningPaper>> futurePlanning;
  late MachinePaperDatasource machinePaperDatasource;
  late List<GridColumn> columns;
  final DataGridController dataGridController = DataGridController();
  final unsavedChangeController = Get.find<UnsavedChangeController>();
  final badgesController = Get.find<BadgesController>();
  final themeController = Get.find<ThemeController>();
  final userController = Get.find<UserController>();
  final formatter = DateFormat('dd/MM/yyyy');
  final Map<String, String> searchFieldMap = {
    'Mã Đơn Hàng': "orderId",
    'Tên KH': "customerName",
    'Khổ Cấp Giấy': "ghepKho",
    "Theo Sóng": "flute",
  };
  String searchType = "Tất cả";
  Map<String, double> columnWidths = {};
  List<String> selectedPlanningIds = [];
  String machine = "Máy 1350";
  DateTime selectedDate = DateTime.now();
  DateTime? dayStart = DateTime.now();
  bool isLoading = false;
  bool isTextFieldEnabled = false;
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

    columns = buildMachineColumns(themeController: themeController, page: "planning");

    ColumnWidthTable.loadWidths(tableKey: 'queuePaper', columns: columns).then((w) {
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
    totalTimeWorkingController.text = "24";
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
          ),
        );
      } else {
        futurePlanning = ensureMinLoading(PlanningService().getPlanningByMachine(machine: machine));
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
        futurePlanning = ensureMinLoading(PlanningService().getPlanningByMachine(machine: machine));
      } else {
        final selectedField = searchFieldMap[searchType] ?? "";

        futurePlanning = ensureMinLoading(
          PlanningService().getPlanningSearch(
            field: selectedField,
            keyword: keyword,
            machine: machine,
          ),
        );
      }
    });
  }

  void changeMachine(String selectedMachine) {
    AppLogger.i("changeMachinePaper | from=$machine -> to=$selectedMachine");
    setState(() {
      machine = selectedMachine;
      selectedPlanningIds.clear();
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
                                  types: const [
                                    'Tất cả',
                                    'Mã Đơn Hàng',
                                    'Tên KH',
                                    'Khổ Cấp Giấy',
                                    'Theo Sóng',
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
                                  buttonColor: themeController.buttonColor.value,

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
                                        enabled: selectedPlanningIds.isNotEmpty,
                                        onMoveUp: () {
                                          setState(() {
                                            machinePaperDatasource.moveRowUp(selectedPlanningIds);
                                          });
                                        },
                                        onMoveDown: () {
                                          setState(() {
                                            machinePaperDatasource.moveRowDown(selectedPlanningIds);
                                          });
                                        },
                                      ),
                                      const SizedBox(width: 20),

                                      // save
                                      Stack(
                                        alignment: Alignment.center,
                                        children: [
                                          AnimatedButton(
                                            onPressed:
                                                isLoading
                                                    ? null
                                                    : () async {
                                                      if (dayStartController.text.isEmpty ||
                                                          timeStartController.text.isEmpty ||
                                                          totalTimeWorkingController.text.isEmpty) {
                                                        showSnackBarError(
                                                          context,
                                                          "Vui lòng nhập đầy đủ ngày bắt đầu, giờ bắt đầu và tổng thời gian.",
                                                        );
                                                        return;
                                                      }

                                                      setState(() => isLoading = true);

                                                      try {
                                                        final List<DataGridRow> visibleRows =
                                                            machinePaperDatasource.rows;

                                                        // 1️⃣ Lấy các đơn chưa complete và gán sortPlanning
                                                        final List<Map<String, dynamic>>
                                                        updateIndex =
                                                            visibleRows
                                                                .asMap()
                                                                .entries
                                                                .where((entry) {
                                                                  final status =
                                                                      entry.value
                                                                          .getCells()
                                                                          .firstWhere(
                                                                            (cell) =>
                                                                                cell.columnName ==
                                                                                "status",
                                                                            orElse:
                                                                                () => DataGridCell(
                                                                                  columnName:
                                                                                      'status',
                                                                                  value: null,
                                                                                ),
                                                                          )
                                                                          .value;

                                                                  return status != 'complete';
                                                                })
                                                                .map((entry) {
                                                                  final planningId =
                                                                      entry.value
                                                                          .getCells()
                                                                          .firstWhere(
                                                                            (cell) =>
                                                                                cell.columnName ==
                                                                                "planningId",
                                                                          )
                                                                          .value;

                                                                  return {
                                                                    "planningId": planningId,
                                                                    "sortPlanning": entry.key + 1,
                                                                  };
                                                                })
                                                                .toList();

                                                        // 2️⃣ Lấy 1 đơn complete cuối cùng (để BE tính timeRunning, không update sortPlanning)
                                                        DataGridRow? lastCompleteRow;

                                                        for (var row in visibleRows.reversed) {
                                                          final status =
                                                              row
                                                                  .getCells()
                                                                  .firstWhere(
                                                                    (cell) =>
                                                                        cell.columnName == "status",
                                                                    orElse:
                                                                        () => DataGridCell(
                                                                          columnName: 'status',
                                                                          value: null,
                                                                        ),
                                                                  )
                                                                  .value;

                                                          if (status == 'complete') {
                                                            lastCompleteRow = row;
                                                            break;
                                                          }
                                                        }

                                                        if (lastCompleteRow != null) {
                                                          final planningId =
                                                              lastCompleteRow
                                                                  .getCells()
                                                                  .firstWhere(
                                                                    (cell) =>
                                                                        cell.columnName ==
                                                                        "planningId",
                                                                  )
                                                                  .value;

                                                          updateIndex.add({
                                                            "planningId": planningId,
                                                          });
                                                        }

                                                        // 3️⃣ Parse ngày, giờ, tổng thời gian
                                                        final DateTime parsedDayStart = DateFormat(
                                                          'dd/MM/yyyy',
                                                        ).parse(dayStartController.text);

                                                        final List<String> timeParts =
                                                            timeStartController.text.split(':');

                                                        final TimeOfDay parsedTimeStart = TimeOfDay(
                                                          hour: int.parse(timeParts[0]),
                                                          minute: int.parse(timeParts[1]),
                                                        );

                                                        final int parsedTotalTime =
                                                            int.tryParse(
                                                              totalTimeWorkingController.text,
                                                            ) ??
                                                            0;

                                                        // 4️⃣ Gửi xuống BE
                                                        // print(
                                                        //   "=== Các đơn sẽ gửi xuống BE ===",
                                                        // );
                                                        // for (var item
                                                        //     in updateIndex) {
                                                        //   print(item);
                                                        // }
                                                        // print(
                                                        //   "================================",
                                                        // );

                                                        final result = await PlanningService()
                                                            .updateIndexWTimeRunning(
                                                              machine: machine,
                                                              dayStart: parsedDayStart,
                                                              timeStart: parsedTimeStart,
                                                              totalTimeWorking: parsedTotalTime,
                                                              updateIndex: updateIndex,
                                                            );

                                                        if (!context.mounted) {
                                                          return;
                                                        }

                                                        if (result) {
                                                          showSnackBarSuccess(
                                                            context,
                                                            "Cập nhật thành công",
                                                          );
                                                          loadPlanning();

                                                          unsavedChangeController
                                                              .resetUnsavedChanges();
                                                        }
                                                      } catch (e, s) {
                                                        showSnackBarError(context, "Lỗi cập nhật");
                                                        AppLogger.e(
                                                          "Lỗi khi lưu",
                                                          error: e,
                                                          stackTrace: s,
                                                        );
                                                      } finally {
                                                        setState(() => isLoading = false);
                                                      }
                                                    },
                                            label: "Lưu",
                                            icon: Icons.save,
                                            backgroundColor: themeController.buttonColor,
                                          ),

                                          if (isLoading)
                                            const Positioned(
                                              right: 10,
                                              child: SizedBox(
                                                width: 18,
                                                height: 18,
                                                child: CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                        ],
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
                                      AnimatedButton(
                                        onPressed: () async {
                                          if (selectedPlanningIds.isEmpty) {
                                            showSnackBarError(
                                              context,
                                              'Vui lòng chọn kế hoạch cần thao tác',
                                            );
                                            return;
                                          }

                                          final confirm = await showConfirmDialog(
                                            context: context,
                                            title: "⚠️ Xác nhận",
                                            content: "Xác nhận hoàn thành kế hoạch này?",
                                            confirmText: "Ok",
                                            confirmColor: const Color(0xffEA4346),
                                          );

                                          if (!confirm) return;

                                          if (!context.mounted) return;
                                          showLoadingDialog(context);

                                          try {
                                            final planningIds =
                                                selectedPlanningIds
                                                    .map((e) => int.tryParse(e.toString()))
                                                    .whereType<int>()
                                                    .toList();

                                            final success = await PlanningService()
                                                .confirmCompletePlanning(ids: planningIds);

                                            if (success) {
                                              loadPlanning();
                                            }

                                            if (!context.mounted) return;
                                            Navigator.of(context).pop();
                                            showSnackBarSuccess(context, "Thao tác thành công");
                                          } catch (e, s) {
                                            if (mounted) Navigator.of(context).pop();
                                            AppLogger.e(
                                              "Error in update status planning: $e",
                                              stackTrace: s,
                                            );

                                            if (mounted) {
                                              showSnackBarError(
                                                context,
                                                'Có lỗi xảy ra, vui lòng thử lại',
                                              );
                                            }
                                          }
                                        },
                                        label: "Hoàn Thành",
                                        icon: Symbols.check,
                                        backgroundColor: themeController.buttonColor,
                                      ),
                                      const SizedBox(width: 10),

                                      //choose machine
                                      SizedBox(
                                        width: 175,
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
                                          onChanged: (value) async {
                                            if (value == null) return;

                                            bool canChange = await UnsavedChangeDialog(
                                              unsavedChangeController,
                                            );

                                            if (canChange) {
                                              changeMachine(value);
                                            } else {
                                              // reset dropdown về máy cũ
                                              setState(() {});
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

                                      //popup menu
                                      PopupMenuButton<String>(
                                        icon: const Icon(Icons.more_vert, color: Colors.black),
                                        color: Colors.white,
                                        onSelected: (value) async {
                                          if (value == 'change') {
                                            if (selectedPlanningIds.isEmpty) {
                                              showSnackBarError(
                                                context,
                                                "Chưa chọn kế hoạch cần chuyển máy",
                                              );
                                              return;
                                            }

                                            final planning = await futurePlanning;
                                            if (!context.mounted) return;

                                            final selectedPlans =
                                                planning
                                                    .where(
                                                      (p) => selectedPlanningIds.contains(
                                                        p.planningId.toString(),
                                                      ),
                                                    )
                                                    .toList();

                                            if (selectedPlans.isEmpty) {
                                              showSnackBarError(
                                                context,
                                                "Không tìm thấy kế hoạch hợp lệ để chuyển máy",
                                              );
                                              return;
                                            }

                                            await showDialog(
                                              context: context,
                                              builder:
                                                  (_) => ChangeMachineDialog(
                                                    planning: selectedPlans,
                                                    onChangeMachine: () => loadPlanning(),
                                                  ),
                                            );
                                            return;
                                          } else if (value == 'stop') {
                                            await handlePlanningAction(
                                              context: context,
                                              selectedPlanningIds: selectedPlanningIds,
                                              planningList: machinePaperDatasource.planning,
                                              status: "stop",
                                              title: "Xác nhận dừng sản xuất",
                                              message:
                                                  "Bạn có chắc muốn dừng các kế hoạch đã chọn không?",
                                              successMessage: "Dừng sản xuất thành công",
                                              errorMessage: "Có lỗi xảy ra khi thực thi",
                                              onSuccess: () {
                                                loadPlanning();
                                                badgesController.fetchPlanningStop();
                                              },
                                            );
                                          } else if (value == 'reject') {
                                            await handlePlanningAction(
                                              context: context,
                                              selectedPlanningIds: selectedPlanningIds,
                                              planningList: machinePaperDatasource.planning,
                                              status: "reject",
                                              title: "Xác nhận hủy kế hoạch",
                                              message:
                                                  "Bạn có chắc muốn hủy kế hoạch đơn này không?",
                                              successMessage: "Hủy kế hoạch thành công",
                                              errorMessage: "Có lỗi xảy ra khi thực thi",
                                              onSuccess: () => loadPlanning(),
                                            );
                                          } else if (value == 'acceptLack') {
                                            await handlePlanningAction(
                                              context: context,
                                              selectedPlanningIds: selectedPlanningIds,
                                              planningList: machinePaperDatasource.planning,
                                              status: "complete",
                                              title: "Xác nhận thiếu số lượng",
                                              message: "Bạn có chắc muốn chấp nhận thiếu không?",
                                              successMessage: "Chấp nhận thiếu thành công",
                                              errorMessage: "Có lỗi xảy ra khi thực thi",
                                              onSuccess: () => loadPlanning(),
                                            );
                                          }
                                        },
                                        itemBuilder:
                                            (BuildContext context) => [
                                              const PopupMenuItem<String>(
                                                value: 'change',
                                                child: ListTile(
                                                  leading: Icon(Symbols.construction),
                                                  title: Text('Chuyển Máy'),
                                                ),
                                              ),
                                              const PopupMenuItem<String>(
                                                value: 'stop',
                                                child: ListTile(
                                                  leading: Icon(Symbols.pause_circle),
                                                  title: Text('Dừng Chạy Đơn'),
                                                ),
                                              ),
                                              const PopupMenuItem<String>(
                                                value: 'reject',
                                                child: ListTile(
                                                  leading: Icon(Symbols.cancel_rounded),
                                                  title: Text('Hủy Chạy Đơn'),
                                                ),
                                              ),
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

                  final List<PlanningPaper> data = snapshot.data!;

                  machinePaperDatasource = MachinePaperDatasource(
                    planning: data,
                    selectedPlanningIds: selectedPlanningIds,
                    unsavedChange: unsavedChangeController,
                    showGroup: showGroup,
                    page: 'planning',
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
                          tableKey: 'queuePaper',
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
    required String status,
    required String title,
    required String message,
    required String successMessage,
    required String errorMessage,
    required VoidCallback onSuccess,
    List<PlanningPaper>? planningList,
  }) async {
    if (selectedPlanningIds.isEmpty) {
      showSnackBarError(context, "Chưa chọn kế hoạch cần thực hiện");
      return;
    }

    //lấy tất cả planningId
    final planningIds =
        selectedPlanningIds
            .map((e) => int.tryParse(e))
            .whereType<int>() // lọc bỏ phần tử null
            .toList();

    //lọc planningId có chứa trong mảng planningList
    final selectedPlannings =
        planningList?.where((p) => planningIds.contains(p.planningId)).toList() ?? [];

    //pause or cancel order
    if (status == 'complete') {
      //check sort planning
      final hasNoSortPlanning = selectedPlannings.any(
        (p) => p.sortPlanning == null || p.sortPlanning == 0,
      );
      if (hasNoSortPlanning) {
        showSnackBarError(context, "Đơn hàng chưa được sắp xếp");
        return;
      }

      //check dayCompleted
      final hasDayCompleted = selectedPlannings.any((p) => p.dayCompleted == null);
      if (hasDayCompleted) {
        showSnackBarError(context, "Đơn hàng chưa có ngày hoàn thành");
        return;
      }
    } else if (status == 'reject') {
      //check qtyProduced > 0
      final hasQtyProduced = selectedPlannings.any((p) => (p.qtyProduced ?? 0) > 0);
      if (hasQtyProduced) {
        showSnackBarError(context, "Không thể hủy đơn hàng đã có số lượng");
        return;
      }
    }

    //check status complete
    final hasCompleted = selectedPlannings.any((p) => p.status == 'complete');
    if (hasCompleted) {
      showSnackBarError(context, "Không thể thao tác với đơn đã hoàn thành");
      return;
    }

    bool confirm = await showConfirmDialog(
      context: context,
      title: title,
      content: message,
      confirmText: "Xác nhận",
      confirmColor: const Color(0xffEA4346),
    );

    if (confirm) {
      try {
        final success = await PlanningService().pauseOrAcceptLackQty(
          ids: planningIds,
          newStatus: status,
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
