import 'package:dongtam/data/controller/badges_controller.dart';
import 'package:dongtam/data/controller/theme_controller.dart';
import 'package:dongtam/data/controller/unsaved_change_controller.dart';
import 'package:dongtam/data/controller/user_controller.dart';
import 'package:dongtam/data/models/order/order_model.dart';
import 'package:dongtam/data/models/planning/planning_paper_model.dart';
import 'package:dongtam/presentation/components/dialog/other/dialog_change_machine.dart';
import 'package:dongtam/presentation/components/headerTable/planning/header_table_machine_paper.dart';
import 'package:dongtam/presentation/components/shared/planning/save_planning.dart';
import 'package:dongtam/presentation/components/shared/slider_zoom.dart';
import 'package:dongtam/presentation/sources/planning/machine_paper_data_source.dart';
import 'package:dongtam/service/planning_service.dart';
import 'package:dongtam/presentation/components/shared/animated_button.dart';
import 'package:dongtam/presentation/components/shared/dialog_shared.dart';
import 'package:dongtam/utils/extension/extension_helper.dart';
import 'package:dongtam/utils/handleError/api_exception.dart';
import 'package:dongtam/utils/helper/grid_resize_helper.dart';
import 'package:dongtam/utils/helper/skeleton/skeleton_loading.dart';
import 'package:dongtam/utils/helper/style_table.dart';
import 'package:dongtam/presentation/components/shared/left_button_search.dart';
import 'package:dongtam/presentation/components/shared/planning/widgets_planning.dart';
import 'package:dongtam/utils/helper/warning_unsaved_change.dart';
import 'package:dongtam/utils/logger/app_logger.dart';
import 'package:dongtam/utils/handleError/show_snack_bar.dart';
import 'package:dongtam/utils/storage/sharedPreferences/column_width_table.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class ProductionQueuePaper extends StatefulWidget {
  const ProductionQueuePaper({super.key});

  @override
  State<ProductionQueuePaper> createState() => _ProductionQueuePaperState();
}

class _ProductionQueuePaperState extends State<ProductionQueuePaper> {
  late Future<List<PlanningPaperModel>> futurePlanning;
  late List<GridColumn> columns;

  //controllers
  final formatter = DateFormat('dd/MM/yyyy');
  final dataGridController = DataGridController();
  final userController = Get.find<UserController>();
  final themeController = Get.find<ThemeController>();
  final badgesController = Get.find<BadgesController>();
  final unsavedChangeController = Get.find<UnsavedChangeController>();

  //search
  String machine = "Máy 1350";
  String searchType = "Tất cả";
  final Map<String, String> searchFieldMap = {
    'Mã Đơn Hàng': "orderId",
    'Tên Khách Hàng': "customerName",
    'Khổ Cấp Giấy': "ghepKho",
  };

  double displayTotalPrice = 0.0;
  Map<String, double> columnWidths = {};

  //notifiers
  final _zoomNotifier = ValueNotifier<double>(1.0);
  final _isSavingNotifier = ValueNotifier<bool>(false);
  final _selectedPlanningIdsNotifier = ValueNotifier<List<String>>([]);

  //datasource and cache
  List<PlanningPaperModel>? _cachedPapers;
  MachinePaperDatasource? _cachedDatasource;

  //date
  DateTime? dayStart = DateTime.now();
  DateTime selectedDate = DateTime.now();

  //flag
  bool isLoading = false;
  bool showGroup = true;
  bool isTextFieldEnabled = false;
  bool _cachedShowGroup = false;
  bool _isSelectionChange = false;

  //text controller
  TextEditingController noteController = TextEditingController();
  TextEditingController searchController = TextEditingController();
  TextEditingController dayStartController = TextEditingController();
  TextEditingController timeStartController = TextEditingController();
  TextEditingController totalTimeWorkingController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadPlanning();

    columns = buildMachinePaperColumns(themeController: themeController, page: "planning");
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

  void loadPlanning({bool clearSelection = false}) {
    setState(() {
      final String selectedField = searchFieldMap[searchType] ?? "";
      String keyword = searchController.text.trim().toLowerCase();

      if (searchType != "Tất cả") {
        futurePlanning = ensureMinLoading(
          PlanningService().getPlanningByMachine(
            field: selectedField,
            keyword: keyword,
            machine: machine,
          ),
        );
      } else {
        futurePlanning = ensureMinLoading(
          PlanningService().getPlanningByMachine(
            machine: machine,
            onTotalCalculated: (total) {
              setState(() {
                displayTotalPrice = total;
              });
            },
          ),
        );
      }
    });

    if (clearSelection) {
      _selectedPlanningIdsNotifier.value = [];
    }
    dataGridController.selectedRows = [];
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
          PlanningService().getPlanningByMachine(
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
      _selectedPlanningIdsNotifier.value = [];
      loadPlanning(clearSelection: true);
    });
  }

  void _updateSelectedIdsFromRows(List<DataGridRow> rows) {
    final newIds =
        rows
            .map((row) {
              final cell = row.getCells().firstWhere(
                (c) => c.columnName == 'planningId',
                orElse: () => const DataGridCell(columnName: '', value: ''),
              );
              return cell.value.toString();
            })
            .where((id) => id.isNotEmpty)
            .toList();

    _selectedPlanningIdsNotifier.value = newIds;
    _cachedDatasource?.selectedPlanningIds = newIds;
  }

  void _updateZoom(double newZoom) {
    _zoomNotifier.value = newZoom.clamp(0.5, 1.5);
  }

  @override
  void dispose() {
    super.dispose();
    noteController.dispose();
    searchController.dispose();
    dayStartController.dispose();
    timeStartController.dispose();
    totalTimeWorkingController.dispose();
    _zoomNotifier.dispose();
    _isSavingNotifier.dispose();
    _selectedPlanningIdsNotifier.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Listener(
        onPointerSignal:
            (pointerSignal) => handleScrollZoom(
              pointerSignal: pointerSignal,
              currentZoom: _zoomNotifier.value,
              onZoomChanged: _updateZoom,
            ),
        child: Stack(
          children: [
            ValueListenableBuilder<double>(
              valueListenable: _zoomNotifier,
              builder: (context, zoom, cachedChild) {
                return LayoutBuilder(
                  builder: (context, constraints) {
                    return SizedBox(
                      width: constraints.maxWidth,
                      height: constraints.maxHeight,
                      child: OverflowBox(
                        minWidth: constraints.maxWidth / zoom,
                        maxWidth: constraints.maxWidth / zoom,
                        minHeight: constraints.maxHeight / zoom,
                        maxHeight: constraints.maxHeight / zoom,
                        alignment: Alignment.topLeft,
                        child: Transform.scale(
                          scale: zoom,
                          alignment: Alignment.topLeft,
                          child: cachedChild,
                        ),
                      ),
                    );
                  },
                );
              },
              child: Container(
                color: Colors.white,
                padding: const EdgeInsets.all(5),
                child: Column(
                  children: [
                    //button
                    SizedBox(
                      height: 140,
                      width: double.infinity,
                      child: Column(
                        children: [
                          //title
                          SizedBox(
                            height: 35,
                            width: double.infinity,
                            child: Center(
                              child: Text(
                                "KẾ HOẠCH SẢN XUẤT GIẤY TẤM",
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
                            height: 105,
                            width: double.infinity,
                            child: Column(
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
                                          'Tên Khách Hàng',
                                          'Khổ Cấp Giấy',
                                        ],
                                        onTypeChanged: (value) {
                                          setState(() {
                                            searchType = value;
                                            isTextFieldEnabled = value != 'Tất cả';

                                            if (searchType == "Tất cả" &&
                                                searchController.text.isNotEmpty) {
                                              searchController.clear();
                                              loadPlanning();
                                            }
                                          });
                                        },
                                        controller: searchController,
                                        textFieldEnabled: isTextFieldEnabled,
                                        buttonColor: themeController.buttonColor,
                                        onSearch: () {
                                          unsavedChangeController.runSafe(() {
                                            searchPlanning();
                                          });
                                        },
                                      ),
                                    ),

                                    //right button
                                    Expanded(
                                      flex: 1,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 8,
                                          horizontal: 10,
                                        ),
                                        child: ValueListenableBuilder(
                                          valueListenable: _selectedPlanningIdsNotifier,
                                          builder: (context, selectedPlanningIds, _) {
                                            final bool hasSelection =
                                                selectedPlanningIds.isNotEmpty;

                                            return SingleChildScrollView(
                                              scrollDirection: Axis.horizontal,
                                              reverse: true,
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.end,
                                                children: [
                                                  // nút lên xuống
                                                  rowMoveButtons(
                                                    enabled: hasSelection,
                                                    onMoveUp: () {
                                                      _cachedDatasource!.moveRowUp(
                                                        selectedPlanningIds,
                                                      );
                                                    },
                                                    onMoveDown: () {
                                                      _cachedDatasource!.moveRowDown(
                                                        selectedPlanningIds,
                                                      );
                                                    },
                                                  ),
                                                  const SizedBox(width: 10),

                                                  // save
                                                  ValueListenableBuilder<bool>(
                                                    valueListenable: _isSavingNotifier,
                                                    builder: (context, isSaving, _) {
                                                      return SavePlanning(
                                                        isLoading: isSaving,
                                                        dayStartController: dayStartController,
                                                        timeStartController: timeStartController,
                                                        totalTimeWorkingController:
                                                            totalTimeWorkingController,
                                                        getRows: () => _cachedDatasource!.rows,
                                                        idColumn: 'planningId',
                                                        isBox: false,
                                                        backgroundColor:
                                                            themeController.buttonColor,
                                                        machine: machine,
                                                        onSuccess: () {
                                                          loadPlanning(clearSelection: true);
                                                          unsavedChangeController
                                                              .resetUnsavedChanges();
                                                        },
                                                        onStartLoading:
                                                            () => _isSavingNotifier.value = true,
                                                        onEndLoading:
                                                            () => _isSavingNotifier.value = false,
                                                      );
                                                    },
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
                                                    icon:
                                                        showGroup
                                                            ? Symbols.ungroup
                                                            : Symbols.ad_group,
                                                    backgroundColor: themeController.buttonColor,
                                                  ),
                                                  const SizedBox(width: 10),

                                                  //confirm complete
                                                  confirmCompleteButton(
                                                    context: context,
                                                    selectedIds: selectedPlanningIds,
                                                    onConfirmComplete: (ids) async {
                                                      return await PlanningService()
                                                          .confirmCompletePlanning(
                                                            ids: ids,
                                                            action: 'CONFIRM_COMPLETE',
                                                          );
                                                    },
                                                    backgroundColor: themeController.buttonColor,
                                                    onReload:
                                                        () => loadPlanning(clearSelection: true),
                                                  ),
                                                  const SizedBox(width: 10),

                                                  //change machine
                                                  buildDropdownItems(
                                                    value: machine,
                                                    items: const [
                                                      'Máy 1350',
                                                      "Máy 1900",
                                                      "Máy 2 Lớp",
                                                      "Máy Quấn Cuồn",
                                                    ],
                                                    onChanged: (value) async {
                                                      if (value == null) return;

                                                      bool canChange = await UnsavedChangeDialog(
                                                        unsavedChangeController,
                                                      );

                                                      if (canChange) {
                                                        changeMachine(value);
                                                      } else {
                                                        setState(() {}); // reset dropdown về máy cũ
                                                      }
                                                    },
                                                  ),
                                                  const SizedBox(width: 10),

                                                  //popup menu
                                                  PopupMenuButton<String>(
                                                    icon: const Icon(
                                                      Icons.more_vert,
                                                      color: Colors.black,
                                                    ),
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
                                                                  (p) =>
                                                                      selectedPlanningIds.contains(
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
                                                                onChangeMachine:
                                                                    () => loadPlanning(),
                                                              ),
                                                        );
                                                        return;
                                                      } else if (value == "stop") {
                                                        await handlePlanningAction(
                                                          context: context,
                                                          selectedPlanningIds: selectedPlanningIds,
                                                          planningList: _cachedDatasource!.planning,
                                                          status: "stop",
                                                          title: "Xác nhận dừng sản xuất",
                                                          message:
                                                              "Bạn có chắc muốn dừng các kế hoạch đã chọn không?",
                                                          successMessage:
                                                              "Dừng sản xuất thành công",
                                                          errorMessage:
                                                              "Có lỗi xảy ra khi thực thi",
                                                          onSuccess: () {
                                                            loadPlanning(clearSelection: true);
                                                            badgesController.fetchPlanningStop();
                                                          },
                                                        );
                                                      } else if (value == 'reject') {
                                                        await handlePlanningAction(
                                                          context: context,
                                                          selectedPlanningIds: selectedPlanningIds,
                                                          planningList: _cachedDatasource!.planning,
                                                          status: "reject",
                                                          title: "Xác nhận hủy kế hoạch",
                                                          message:
                                                              "Bạn có chắc muốn hủy kế hoạch đơn này không?",
                                                          successMessage: "Hủy kế hoạch thành công",
                                                          errorMessage:
                                                              "Có lỗi xảy ra khi thực thi",
                                                          onSuccess: () {
                                                            loadPlanning(clearSelection: true);
                                                            badgesController.fetchPlanningStop();
                                                          },
                                                        );
                                                      } else if (value == 'acceptLack') {
                                                        await handlePlanningAction(
                                                          context: context,
                                                          selectedPlanningIds: selectedPlanningIds,
                                                          planningList: _cachedDatasource!.planning,
                                                          status: "complete",
                                                          title: "Xác nhận thiếu số lượng",
                                                          message:
                                                              "Bạn có chắc muốn chấp nhận thiếu không?",
                                                          successMessage:
                                                              "Chấp nhận thiếu thành công",
                                                          errorMessage:
                                                              "Có lỗi xảy ra khi thực thi",
                                                          onSuccess:
                                                              () => loadPlanning(
                                                                clearSelection: true,
                                                              ),
                                                        );
                                                      } else if (value == 'forceComplete') {
                                                        runCompletePlanningFlow(
                                                          context: context,
                                                          selectedIds: selectedPlanningIds,
                                                          onConfirmComplete: (ids) async {
                                                            return await PlanningService()
                                                                .confirmCompletePlanning(
                                                                  ids: ids,
                                                                  action: 'CONFIRM_COMPLETE',
                                                                  forceComplete: true,
                                                                );
                                                          },
                                                          onReload:
                                                              () => loadPlanning(
                                                                clearSelection: true,
                                                              ),
                                                        );
                                                      } else if (value == 'notify') {
                                                        bool confirm = await showConfirmDialog(
                                                          context: context,
                                                          title: "Xác Nhận Lịch Sản Xuất",
                                                          content:
                                                              "Bạn có muốn gửi lịch sản xuất này không?",
                                                          confirmText: "Xác nhận",
                                                          confirmColor: const Color(0xffEA4346),
                                                        );

                                                        if (confirm) {
                                                          try {
                                                            final success = await PlanningService()
                                                                .notifyUpdatePlanning(
                                                                  machine: machine,
                                                                  isPaper: true,
                                                                );

                                                            if (!context.mounted) return;
                                                            if (success) {
                                                              showSnackBarSuccess(
                                                                context,
                                                                "Gửi lịch sản xuất thành công",
                                                              );
                                                            }
                                                          } catch (e) {
                                                            if (!context.mounted) return;
                                                            showSnackBarError(
                                                              context,
                                                              "Lỗi khi gửi lịch sản xuất",
                                                            );
                                                          }
                                                        }
                                                      } else if (value == 'note') {
                                                        if (selectedPlanningIds.isEmpty) {
                                                          showSnackBarError(
                                                            context,
                                                            "Chưa chọn kế hoạch cần ghi chú",
                                                          );
                                                          return;
                                                        } else if (selectedPlanningIds.length > 1) {
                                                          showSnackBarError(
                                                            context,
                                                            "Chỉ chọn một kế hoạch để thêm ghi chú",
                                                          );
                                                          return;
                                                        }

                                                        //clear text field
                                                        noteController.clear();

                                                        await showInputQtyDialog(
                                                          context: context,
                                                          controller: noteController,
                                                          maxLines: 3,
                                                          title: "Thêm Ghi Chú",
                                                          labelText: "Ghi chú",
                                                          onConfirm: () async {
                                                            try {
                                                              final success =
                                                                  await PlanningService()
                                                                      .addNoteToPlanning(
                                                                        planningId: int.parse(
                                                                          selectedPlanningIds.first,
                                                                        ),
                                                                        note:
                                                                            noteController.text
                                                                                .trim(),
                                                                        action: "NOTE",
                                                                      );

                                                              if (success) {
                                                                if (context.mounted) {
                                                                  showSnackBarSuccess(
                                                                    context,
                                                                    "Thêm ghi chú thành công",
                                                                  );
                                                                }

                                                                loadPlanning();
                                                                return true;
                                                              }
                                                              return false;
                                                            } catch (e) {
                                                              if (context.mounted) {
                                                                showSnackBarError(
                                                                  context,
                                                                  "Thêm ghi chú thất bại",
                                                                );
                                                              }
                                                              return false;
                                                            }
                                                          },
                                                        );
                                                      } else if (value == 'export') {
                                                        bool confirm = await showConfirmDialog(
                                                          context: context,
                                                          title: "Xác Nhận Xuất Excel",
                                                          content:
                                                              "Bạn có muốn xuất excel kế hoạch sản xuất này không?",
                                                          confirmText: "Xác nhận",
                                                          confirmColor: const Color(0xffEA4346),
                                                        );

                                                        if (confirm) {
                                                          final file = await PlanningService()
                                                              .exportPlanningExcel(machine);

                                                          if (context.mounted) {
                                                            if (file != null) {
                                                              showSnackBarSuccess(
                                                                context,
                                                                "Xuất excel thành công",
                                                              );
                                                            } else {
                                                              showSnackBarError(
                                                                context,
                                                                "Xuất excel thất bại",
                                                              );
                                                            }
                                                          }
                                                        }
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
                                                              leading: Icon(
                                                                Icons.approval_outlined,
                                                              ),
                                                              title: Text('Chấp Nhận Thiếu SL'),
                                                            ),
                                                          ),
                                                          const PopupMenuItem<String>(
                                                            value: 'forceComplete',
                                                            child: ListTile(
                                                              leading: Icon(
                                                                Icons.check_circle_outline,
                                                              ),
                                                              title: Text('Hoàn Thành Ngay'),
                                                            ),
                                                          ),
                                                          const PopupMenuItem<String>(
                                                            value: 'notify',
                                                            child: ListTile(
                                                              leading: Icon(Symbols.send),
                                                              title: Text('Gửi Kế Hoạch SX'),
                                                            ),
                                                          ),
                                                          const PopupMenuItem<String>(
                                                            value: 'note',
                                                            child: ListTile(
                                                              leading: Icon(Symbols.note_add),
                                                              title: Text('Thêm Ghi Chú'),
                                                            ),
                                                          ),
                                                          const PopupMenuItem<String>(
                                                            value: 'export',
                                                            child: ListTile(
                                                              leading: Icon(Symbols.download),
                                                              title: Text('Xuất Excel'),
                                                            ),
                                                          ),
                                                        ],
                                                  ),
                                                  const SizedBox(width: 10),
                                                ],
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                                //set day and time for time running
                                const SizedBox(height: 5),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    timeAndDayPlanning(
                                      context: context,
                                      dayStartController: dayStartController,
                                      timeStartController: timeStartController,
                                      totalTimeWorkingController: totalTimeWorkingController,
                                    ),

                                    //total price
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 8.0, right: 10.0),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          Text(
                                            "Tổng Giá Trị Tồn: ",
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                          Text(
                                            "${OrderModel.formatCurrency(displayTotalPrice)} VNĐ",
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18,
                                              color: Colors.green.shade500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
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

                          final List<PlanningPaperModel> data = snapshot.data!;

                          if (_cachedPapers == null ||
                              _cachedPapers != data ||
                              _cachedShowGroup != showGroup) {
                            _cachedPapers = data;
                            _cachedShowGroup = showGroup;
                            _cachedDatasource = MachinePaperDatasource(
                              planning: data,
                              selectedPlanningIds: _selectedPlanningIdsNotifier.value,
                              unsavedChange: unsavedChangeController,
                              showGroup: showGroup,
                              page: 'planning',
                            );
                          }

                          return StatefulBuilder(
                            builder: (context, localSetState) {
                              return SfDataGridTheme(
                                data: SfDataGridThemeData(
                                  selectionColor: Colors.blue.withValues(alpha: 0.3),
                                  currentCellStyle: const DataGridCurrentCellStyle(
                                    borderColor: Colors.transparent,
                                    borderWidth: 0,
                                  ),
                                ),
                                child: SfDataGrid(
                                  controller: dataGridController,
                                  source: _cachedDatasource!,
                                  allowExpandCollapseGroup: true, // Bật grouping
                                  autoExpandGroups: true,
                                  isScrollbarAlwaysShown: true,
                                  columnWidthMode: ColumnWidthMode.auto,
                                  selectionMode: SelectionMode.multiple,
                                  headerRowHeight: 35,
                                  rowHeight: 40,
                                  columns: ColumnWidthTable.applySavedWidths(
                                    columns: columns,
                                    widths: columnWidths,
                                  ),
                                  frozenColumnsCount: 8,
                                  stackedHeaderRows: <StackedHeaderRow>[
                                    StackedHeaderRow(
                                      cells: [
                                        StackedHeaderCell(
                                          columnNames: [
                                            'quantityOrd',
                                            'runningPlanProd',
                                            'qtyProduced',
                                          ],
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
                                              label: 'Định Mức Phế Liệu (Kg)',
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
                                        setState: localSetState,
                                      ),
                                  onColumnResizeEnd:
                                      (details) => GridResizeHelper.onResizeEnd(
                                        details: details,
                                        tableKey: 'queuePaper',
                                        columnWidths: columnWidths,
                                        setState: setState,
                                      ),

                                  onSelectionChanging: (addedRows, removedRows) {
                                    if (_isSelectionChange) return true;

                                    final keys = HardwareKeyboard.instance.logicalKeysPressed;
                                    final isShiftPressed =
                                        keys.contains(LogicalKeyboardKey.shiftLeft) ||
                                        keys.contains(LogicalKeyboardKey.shiftRight);

                                    // Nếu đè phím Shift và trước đó đã có dòng được chọn
                                    if (isShiftPressed &&
                                        dataGridController.selectedRows.isNotEmpty &&
                                        addedRows.isNotEmpty) {
                                      final lastSelected = dataGridController.selectedRows.last;
                                      final newlyClicked = addedRows.last;

                                      // Lấy tất cả các dòng dữ liệu trong datasource (không bao gồm caption row)
                                      final allRows = _cachedDatasource!.rows;
                                      final startIdx = allRows.indexOf(lastSelected);
                                      final endIdx = allRows.indexOf(newlyClicked);

                                      if (startIdx != -1 && endIdx != -1) {
                                        final min = startIdx < endIdx ? startIdx : endIdx;
                                        final max = startIdx > endIdx ? startIdx : endIdx;

                                        // Tự gom tất cả các dòng dữ liệu nằm giữa khoảng click
                                        final List<DataGridRow> rangeSelection = [];
                                        for (int i = min; i <= max; i++) {
                                          rangeSelection.add(allRows[i]);
                                        }

                                        // Ép controller chọn dải dòng
                                        _isSelectionChange = true;
                                        dataGridController.selectedRows = List.from(rangeSelection);
                                        _isSelectionChange = false;

                                        // Cập nhật ID đơn hàng
                                        Future.microtask(() {
                                          _isSelectionChange = true;
                                          dataGridController.selectedRows = List.from(
                                            rangeSelection,
                                          );
                                          _isSelectionChange = false;

                                          _updateSelectedIdsFromRows(rangeSelection);
                                        });
                                        return false;
                                      }
                                    }
                                    return true;
                                  },

                                  onSelectionChanged: (addedRows, removedRows) {
                                    if (_isSelectionChange) return;
                                    if (addedRows.isEmpty && removedRows.isEmpty) return;

                                    // bắt sự kiện từ bàn phím
                                    final keys = HardwareKeyboard.instance.logicalKeysPressed;
                                    final isCtrlPressed =
                                        keys.contains(LogicalKeyboardKey.controlLeft) ||
                                        keys.contains(LogicalKeyboardKey.controlRight);
                                    final isShiftPressed =
                                        keys.contains(LogicalKeyboardKey.shiftLeft) ||
                                        keys.contains(LogicalKeyboardKey.shiftRight);

                                    if (!isCtrlPressed && !isShiftPressed) {
                                      if (addedRows.isNotEmpty) {
                                        // Nếu click vào một dòng mới thì Xóa hết các dòng cũ, chỉ chọn duy nhất dòng này
                                        final latestRow = addedRows.last;

                                        _isSelectionChange = true;
                                        dataGridController.selectedRows = [latestRow];

                                        _isSelectionChange = false;
                                      } else if (removedRows.isNotEmpty &&
                                          dataGridController.selectedRows.isNotEmpty) {
                                        //ép chọn lại dòng vừa click vào nếu xóa hết các dòng cũ
                                        final clickedRow = removedRows.first;
                                        _isSelectionChange = true;
                                        dataGridController.selectedRows = [clickedRow];
                                        _isSelectionChange = false;
                                      }
                                    }

                                    _updateSelectedIdsFromRows(dataGridController.selectedRows);
                                  },
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),

            //slider zoom
            ValueListenableBuilder<double>(
              valueListenable: _zoomNotifier,
              builder: (context, zoom, _) {
                return SliderZoom(
                  zoomLevel: zoom,
                  onZoomChanged: _updateZoom,
                  initialMargin: Offset(73, 125),
                  buttonColor: themeController.buttonColor.value,
                );
              },
            ),
          ],
        ),
      ),

      floatingActionButton: Obx(
        () => FloatingActionButton(
          onPressed:
              () => {
                unsavedChangeController.runSafe(() {
                  loadPlanning();
                }),
              },
          backgroundColor: themeController.buttonColor.value,
          child: const Icon(Icons.refresh, color: Colors.white),
        ),
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
    List<PlanningPaperModel>? planningList,
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
      //check dayCompleted
      final hasDayCompleted = selectedPlannings.any((p) => p.dayCompleted == null);
      if (hasDayCompleted) {
        showSnackBarError(context, "Đơn hàng chưa có ngày hoàn thành");
        return;
      }
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
          action: 'PAUSE_OR_ACCEPT_LACK',
        );

        if (success) {
          if (context.mounted) {
            showSnackBarSuccess(context, successMessage);
            onSuccess();
          }
        }
      } on ApiException catch (e) {
        final errorText = switch (e.errorCode) {
          'CANNOT_REJECT_PRODUCED_PLANNING' => e.message!,
          'CANNOT_COMPLETE_WITHOUT_SORT' => e.message!,
          "PLANNING_NOT_REQUESTED" => e.message!,
          "PLANNING_HAS_OUTBOUND_DETAILS" => e.message!,
          _ => 'Có lỗi xảy ra, vui lòng thử lại',
        };

        if (context.mounted) {
          showSnackBarError(context, errorText);
        }
      } catch (e) {
        if (!context.mounted) return;
        showSnackBarError(context, errorMessage);
      }
    }
  }
}
