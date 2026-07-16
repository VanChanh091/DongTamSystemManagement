import "package:dongtam/data/controller/theme_controller.dart";
import "package:dongtam/data/controller/user_controller.dart";
import "package:dongtam/data/models/planning/planning_paper_model.dart";
import "package:dongtam/presentation/components/dialog/add/dialog_add_report_production.dart";
import "package:dongtam/presentation/components/dialog/add/dialog_add_scrap_report.dart";
import "package:dongtam/presentation/components/dialog/qc/dialog_inspection_check.dart";
import "package:dongtam/presentation/components/headerTable/planning/header_table_machine_paper.dart";
import "package:dongtam/presentation/components/shared/left_button_search.dart";
import "package:dongtam/presentation/components/shared/planning/handle_request_complete.dart";
import "package:dongtam/presentation/components/shared/planning/widgets_planning.dart";
import "package:dongtam/presentation/components/shared/slider_zoom.dart";
import "package:dongtam/service/planning_service.dart";
import "package:dongtam/utils/socket/init_socket_manufacture.dart";
import "package:dongtam/presentation/sources/planning/machine_paper_data_source.dart";
import "package:dongtam/service/manufacture_service.dart";
import "package:dongtam/socket/socket_service.dart";
import "package:dongtam/presentation/components/shared/animation/animated_button.dart";
import "package:dongtam/utils/handleError/api_exception.dart";
import "package:dongtam/utils/helper/grid_resize_helper.dart";
import "package:dongtam/utils/helper/skeleton/skeleton_loading.dart";
import "package:dongtam/utils/helper/style_table.dart";
import "package:dongtam/utils/logger/app_logger.dart";
import "package:dongtam/utils/handleError/show_snack_bar.dart";
import "package:dongtam/utils/storage/sharedPreferences/column_width_table.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:get/get.dart";
import "package:material_symbols_icons/material_symbols_icons.dart";
import "package:syncfusion_flutter_core/theme.dart";
import "package:syncfusion_flutter_datagrid/datagrid.dart";

class PaperProduction extends StatefulWidget {
  const PaperProduction({super.key});

  @override
  State<PaperProduction> createState() => _PaperProductionState();
}

class _PaperProductionState extends State<PaperProduction> {
  late Future<List<PlanningPaperModel>> futurePlanning;
  late InitSocketManufacture _initSocket;
  late List<GridColumn> columns;

  //controllers and socket
  final socketService = SocketService();
  final dataGridController = DataGridController();
  final userController = Get.find<UserController>();
  final themeController = Get.find<ThemeController>();

  //search
  String searchType = "Tất cả";
  final Map<String, String> searchFieldMap = {
    "Mã Đơn Hàng": "orderId",
    "Tên Khách Hàng": "customerName",
    "Khổ Cấp Giấy": "ghepKho",
  };

  //notifiers
  final _zoomNotifier = ValueNotifier<double>(1.0);
  final _selectedPlanningIdsNotifier = ValueNotifier<List<String>>([]);

  Map<String, double> columnWidths = {};
  List<PlanningPaperModel> planningList = [];

  //datasource and cache
  List<PlanningPaperModel>? _cachedPapers;
  MachinePaperDatasource? _cachedDatasource;

  //flag
  bool isTextFieldEnabled = false;
  bool showGroup = true;
  bool _isSelectionChange = false;

  //permission
  String machine = "Máy 1350";
  Map<String, String> permissionToMachineMap = {
    "machine1350": "Máy 1350",
    "machine1900": "Máy 1900",
    "machine2Layer": "Máy 2 Lớp",
    "MachineRollPaper": "Máy Quấn Cuồn",
  };

  //filter by machine & runningPlan
  String filterType = "all";
  final Map<String, String> filterOptions = {
    "all": "Tất cả",
    "gtZero": "Còn SL Chạy",
    "ltZero": "Hết SL Chạy",
  };

  //text controller
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();

    _initSocket = InitSocketManufacture(
      context: context,
      socketService: socketService,
      eventNames: ["planningPaperUpdated", "qc-inspection-paper"],
      onLoadData: loadPlanning,
      onMachineChanged: (newMachine) {
        setState(() {
          machine = newMachine;
          _selectedPlanningIdsNotifier.value = [];
        });
      },
    );

    _initSocket.registerSocket(machine);
    loadPlanning();

    columns = buildMachinePaperColumns(themeController: themeController, page: "production");
    ColumnWidthTable.loadWidths(tableKey: "queuePaper", columns: columns).then((w) {
      setState(() {
        columnWidths = w;
      });
    });
  }

  void _fetchData() {
    final String keyword = searchController.text.trim().toLowerCase();
    final String selectedField = searchFieldMap[searchType] ?? "";

    // Điều kiện để xác định có thực hiện search hay load mặc định
    final bool shouldSearch = (searchType != "Tất cả");

    futurePlanning = ensureMinLoading(
      shouldSearch
          ? PlanningService().getPlanningByMachine(
            field: selectedField,
            keyword: keyword,
            machine: machine,
          )
          : ManufactureService().getPlanningPaper(machine: machine, filterType: filterType),
    );

    _selectedPlanningIdsNotifier.value = [];
    dataGridController.selectedRows = [];
  }

  void loadPlanning() {
    setState(() => _fetchData());
  }

  void searchPlanning() {
    String keyword = searchController.text.trim().toLowerCase();
    AppLogger.i("searchPaper => searchType=$searchType | keyword=$keyword | machine=$machine");

    if (isTextFieldEnabled && keyword.isEmpty) {
      AppLogger.w("searchPaper => searchType=$searchType nhưng keyword rỗng");
      return;
    }

    setState(() => _fetchData());
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
    required List<PlanningPaperModel> planningList,
  }) {
    if (selectedPlanningIds.length != 1) return false;
    if (userController.role.value == "admin") return true;

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
    required List<PlanningPaperModel> planningList,
  }) {
    if (selectedPlanningIds.length != 1) return false;
    if (userController.role.value == "admin") return true;

    final selectedPlanning = planningList.firstWhere(
      (p) => p.planningId == selectedPlanningIds.first,
      orElse: () => throw Exception("Không tìm thấy kế hoạch"),
    );

    // check số lượng sản xuất
    if ((selectedPlanning.qtyProduced ?? 0) <= 0) return false;

    return true;
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
    searchController.dispose();
    _initSocket.stop(machine);
    _zoomNotifier.dispose();
    _selectedPlanningIdsNotifier.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool permissionCheck = userController.hasAnyPermission(
      permission: ["machine1350", "machine1900", "machine2Layer", "MachineRollPaper"],
    );

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
                                              "Tất cả",
                                              "Mã Đơn Hàng",
                                              "Tên Khách Hàng",
                                              "Khổ Cấp Giấy",
                                            ],
                                            onTypeChanged: (value) {
                                              setState(() {
                                                searchType = value;
                                                isTextFieldEnabled = value != "Tất cả";

                                                if (searchType == "Tất cả" &&
                                                    searchController.text.isNotEmpty) {
                                                  searchController.clear();
                                                  _fetchData();
                                                }
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
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 8,
                                      horizontal: 10,
                                    ),
                                    child: ValueListenableBuilder(
                                      valueListenable: _selectedPlanningIdsNotifier,
                                      builder: (context, selectedPlanningIds, _) {
                                        final bool isProduction =
                                            permissionCheck &&
                                            canExecuteAction(
                                              selectedPlanningIds:
                                                  _selectedPlanningIdsNotifier.value
                                                      .map(int.parse)
                                                      .toList(),
                                              planningList: planningList,
                                            );

                                        final bool isEdit =
                                            permissionCheck &&
                                            canEditAction(
                                              selectedPlanningIds:
                                                  _selectedPlanningIdsNotifier.value
                                                      .map(int.parse)
                                                      .toList(),
                                              planningList: planningList,
                                            );

                                        return SingleChildScrollView(
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
                                                            final int selectedPlanningId =
                                                                int.parse(
                                                                  selectedPlanningIds.first,
                                                                );

                                                            final selectedPlanning = planningList
                                                                .firstWhere(
                                                                  (p) =>
                                                                      p.planningId ==
                                                                      selectedPlanningId,
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
                                                                    planningId:
                                                                        selectedPlanning.planningId,
                                                                    runningPlan:
                                                                        selectedPlanning
                                                                            .runningPlan,
                                                                    onReport: () => loadPlanning(),
                                                                  ),
                                                            );
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
                                                            final int selectedPlanningId =
                                                                int.parse(
                                                                  selectedPlanningIds.first,
                                                                );

                                                            final selectedPlanning = planningList
                                                                .firstWhere(
                                                                  (p) =>
                                                                      p.planningId ==
                                                                      selectedPlanningId,
                                                                  orElse:
                                                                      () =>
                                                                          throw Exception(
                                                                            "Không tìm thấy kế hoạch",
                                                                          ),
                                                                );

                                                            final existingData = {
                                                              "manager":
                                                                  selectedPlanning.shiftManagement,
                                                              "shift":
                                                                  selectedPlanning.shiftProduction,
                                                            };

                                                            showDialog(
                                                              context: context,
                                                              builder:
                                                                  (_) => DialogReportProduction(
                                                                    planningId:
                                                                        selectedPlanning.planningId,
                                                                    initialData: existingData,
                                                                    onReport: () => loadPlanning(),
                                                                  ),
                                                            );
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
                                                  "Máy 1350",
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
                                                width: 155,
                                                value: filterType,
                                                items: const ["all", "gtZero", "ltZero"],
                                                onChanged:
                                                    (value) => {
                                                      setState(() {
                                                        filterType = value!;
                                                        selectedPlanningIds.clear();
                                                        loadPlanning();
                                                      }),
                                                    },
                                                itemLabelBuilder:
                                                    (value) => filterOptions[value] ?? value,
                                              ),
                                              const SizedBox(width: 10),

                                              //popup menu
                                              PopupMenuButton(
                                                icon: const Icon(
                                                  Icons.more_vert,
                                                  color: Colors.black,
                                                ),
                                                color: Colors.white,
                                                onSelected: (value) async {
                                                  if (value == "confirm") {
                                                    try {
                                                      final int selectedPlanningId = int.parse(
                                                        selectedPlanningIds.first,
                                                      );

                                                      // Tìm planning tương ứng
                                                      final selectedPlanning = planningList
                                                          .firstWhere(
                                                            (p) =>
                                                                p.planningId == selectedPlanningId,
                                                            orElse:
                                                                () =>
                                                                    throw Exception(
                                                                      "Không tìm thấy kế hoạch",
                                                                    ),
                                                          );

                                                      await ManufactureService()
                                                          .handlePutManufacturePaper(
                                                            planningId: [
                                                              selectedPlanning.planningId,
                                                            ],
                                                            action: "CONFIRM_PRODUCING",
                                                          );

                                                      loadPlanning();

                                                      if (!context.mounted) return;
                                                      showSnackBarSuccess(
                                                        context,
                                                        "Xác nhận sản xuất thành công",
                                                      );
                                                    } on ApiException catch (e) {
                                                      final errorText = switch (e.errorCode) {
                                                        "PLANNING_HAS_COMPLETED" =>
                                                          "Đơn hàng đã hoàn thành",
                                                        _ => "Có lỗi xảy ra, vui lòng thử lại",
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
                                                      showSnackBarError(
                                                        context,
                                                        "Có lỗi khi xác nhận SX: $e",
                                                      );
                                                    }
                                                  } else if (value == "request") {
                                                    await handlePlanningTask(
                                                      context: context,
                                                      selectedPlanningIds: selectedPlanningIds,
                                                      content:
                                                          "Xác nhận yêu cầu hoàn thành kế hoạch này?",
                                                      onExecute:
                                                          (ids) => ManufactureService()
                                                              .handlePutManufacturePaper(
                                                                planningId: ids,
                                                                action: "REQUEST_COMPLETE",
                                                              ),
                                                      onLoadPlanning: loadPlanning,
                                                    );
                                                  } else if (value == "scrapReport") {
                                                    if (selectedPlanningIds.isEmpty) {
                                                      showSnackBarError(
                                                        context,
                                                        "Chưa chọn dòng để báo cáo phế liệu",
                                                      );
                                                      return;
                                                    }

                                                    final int selectedPlanningId = int.parse(
                                                      selectedPlanningIds.first,
                                                    );

                                                    final selectedPlanning = planningList
                                                        .firstWhere(
                                                          (p) => p.planningId == selectedPlanningId,
                                                          orElse:
                                                              () =>
                                                                  throw Exception(
                                                                    "Không tìm thấy kế hoạch",
                                                                  ),
                                                        );

                                                    if (selectedPlanning.qtyProduced == null ||
                                                        selectedPlanning.qtyProduced! == 0) {
                                                      showSnackBarError(
                                                        context,
                                                        "Chưa có số lượng sản xuất, không thể báo cáo phế liệu",
                                                      );
                                                      return;
                                                    }

                                                    final existingData = {
                                                      "machine": selectedPlanning.chooseMachine,
                                                      "shiftManagement":
                                                          selectedPlanning.shiftManagement,
                                                      "shiftProduction":
                                                          selectedPlanning.shiftProduction,
                                                      "dayCompleted": selectedPlanning.dayCompleted,
                                                    };

                                                    showDialog(
                                                      barrierDismissible: false,
                                                      context: context,
                                                      builder:
                                                          (_) => ScrapReportDialog(
                                                            scrapReport: null,
                                                            initialData: existingData,
                                                            onSubmit: () {
                                                              loadPlanning();
                                                            },
                                                          ),
                                                    );
                                                  } else if (value == "confirmFixErr") {
                                                    await handlePlanningTask(
                                                      context: context,
                                                      selectedPlanningIds: selectedPlanningIds,
                                                      content: "Xác nhận sửa lỗi kế hoạch này?",
                                                      onExecute:
                                                          (ids) => ManufactureService()
                                                              .handlePutManufacturePaper(
                                                                planningId: [ids.first],
                                                                action: "CONFIRM_FIX_ERROR",
                                                              ),
                                                      onLoadPlanning: loadPlanning,
                                                    );
                                                  }
                                                },
                                                itemBuilder:
                                                    (BuildContext context) => [
                                                      const PopupMenuItem<String>(
                                                        value: "confirm",
                                                        child: ListTile(
                                                          leading: Icon(Symbols.done_outline),
                                                          title: Text("Xác Nhận Sản Xuất"),
                                                        ),
                                                      ),
                                                      const PopupMenuItem<String>(
                                                        value: "request",
                                                        child: ListTile(
                                                          leading: Icon(Symbols.send),
                                                          title: Text("Yêu Cầu Hoàn Thành"),
                                                        ),
                                                      ),
                                                      const PopupMenuItem<String>(
                                                        value: "scrapReport",
                                                        child: ListTile(
                                                          leading: Icon(Symbols.add),
                                                          title: Text("Báo Cáo Phế Liệu"),
                                                        ),
                                                      ),
                                                      const PopupMenuItem<String>(
                                                        value: "confirmFixErr",
                                                        child: ListTile(
                                                          leading: Icon(Symbols.construction),
                                                          title: Text("Xác Nhận Sửa Lỗi"),
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

                          final data = snapshot.data as List<PlanningPaperModel>;
                          planningList = data;

                          if (_cachedPapers == null || _cachedPapers != data) {
                            _cachedPapers = data;
                            _cachedDatasource = MachinePaperDatasource(
                              planning: data,
                              selectedPlanningIds: _selectedPlanningIdsNotifier.value,
                              showGroup: showGroup,
                              page: "production",
                              onRowTap: (PlanningPaperModel item) {
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
                                  frozenColumnsCount: 7,
                                  stackedHeaderRows: <StackedHeaderRow>[
                                    StackedHeaderRow(
                                      cells: [
                                        StackedHeaderCell(
                                          columnNames: ["qtyProduced", "runningPlanProd"],
                                          child: Obx(
                                            () => formatColumn(
                                              label: "Số Lượng",
                                              themeController: themeController,
                                            ),
                                          ),
                                        ),
                                        StackedHeaderCell(
                                          columnNames: [
                                            "bottom",
                                            "fluteE",
                                            "fluteE2",
                                            "fluteB",
                                            "fluteC",
                                            "knife",
                                            "totalLoss",
                                          ],
                                          child: formatColumn(
                                            label: "Định Mức Phế Liệu",
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
                                        setState: localSetState,
                                      ),
                                  onColumnResizeEnd:
                                      (details) => GridResizeHelper.onResizeEnd(
                                        details: details,
                                        tableKey: "queuePaper",
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

      floatingActionButton: FloatingActionButton(
        onPressed: () => loadPlanning(),
        backgroundColor: themeController.buttonColor.value,
        child: const Icon(Icons.refresh, color: Colors.white),
      ),
    );
  }
}
