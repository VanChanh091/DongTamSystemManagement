import 'package:dongtam/data/controller/theme_controller.dart';
import 'package:dongtam/data/controller/user_controller.dart';
import 'package:dongtam/data/models/employee/employee_basic_info.dart';
import 'package:dongtam/presentation/components/dialog/add/dialog_add_employee.dart';
import 'package:dongtam/presentation/components/dialog/export/dialog_export_employee.dart';
import 'package:dongtam/presentation/components/headerTable/header_table_employee.dart';
import 'package:dongtam/presentation/components/shared/left_button_search.dart';
import 'package:dongtam/presentation/components/shared/slider_zoom.dart';
import 'package:dongtam/presentation/sources/employee_data_source.dart';
import 'package:dongtam/service/employee_service.dart';
import 'package:dongtam/utils/handleError/show_snack_bar.dart';
import 'package:dongtam/presentation/components/shared/animation/animated_button.dart';
import 'package:dongtam/presentation/components/shared/dialog_shared.dart';
import 'package:dongtam/presentation/components/shared/grid_resize_helper.dart';
import 'package:dongtam/presentation/components/shared/pagination_controls.dart';
import 'package:dongtam/utils/helper/skeleton/skeleton_loading.dart';
import 'package:dongtam/utils/logger/app_logger.dart';
import 'package:dongtam/utils/storage/sharedPreferences/column_width_table.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class Employee extends StatefulWidget {
  const Employee({super.key});

  @override
  State<Employee> createState() => _EmployeeState();
}

class _EmployeeState extends State<Employee> {
  late Future<Map<String, dynamic>> futureEmployee;
  late List<GridColumn> columns;

  //controller
  final userController = Get.find<UserController>();
  final themeController = Get.find<ThemeController>();

  //search
  String searchType = "Tất cả";
  final Map<String, String> searchFieldMap = {
    "Tên Nhân Viên": "fullName",
    "Số Điện Thoại": "phoneNumber",
    "Mã Nhân Viên": "employeeCode",
    "Tình Trạng": "status",
  };

  final _zoomNotifier = ValueNotifier<double>(1.0);
  final _selectedEmployeeIdNotifier = ValueNotifier<int?>(null);
  Map<String, double> columnWidths = {}; //map header table

  //datasource and cache
  List<EmployeeBasicInfoModel>? _cachedEmployees;
  late EmployeeDataSource _cachedDatasource;

  //text controller
  final searchController = TextEditingController();
  final headerScrollController = ScrollController();

  //flag
  late bool isHR;
  bool selectedAll = false;
  bool isTextFieldEnabled = false;
  bool isSearching = false; //dùng để phân trang cho tìm kiếm

  //paging
  int currentPage = 1;
  int pageSize = 35;
  int pageSizeSearch = 30;

  @override
  void initState() {
    super.initState();
    loadEmployee();

    isHR = userController.hasPermission(permission: "HR");

    columns = buildEmployeeColumn(themeController: themeController);
    ColumnWidthTable.loadWidths(tableKey: 'employee', columns: columns).then((w) {
      setState(() {
        columnWidths = w;
      });
    });
  }

  void _fetchData() {
    final String keyword = searchController.text.trim().toLowerCase();
    final String selectedField = searchFieldMap[searchType] ?? "";

    // Điều kiện để xác định có thực hiện search hay load mặc định
    final bool shouldSearch = isSearching && searchType != "Tất cả";

    futureEmployee = ensureMinLoading(
      EmployeeService().getEmployees(
        page: currentPage,
        pageSize: pageSize,
        field: shouldSearch ? selectedField : null,
        keyword: shouldSearch ? keyword : null,
      ),
    );

    _selectedEmployeeIdNotifier.value = null;
  }

  void loadEmployee() {
    setState(() => _fetchData());
  }

  void searchEmployee() {
    String keyword = searchController.text.trim().toLowerCase();
    AppLogger.i("searchEmployee: searchType=$searchType, keyword='$keyword'");

    if (isTextFieldEnabled && keyword.isEmpty) {
      AppLogger.w("searchEmployee: search bị bỏ qua vì keyword trống");
      return;
    }

    setState(() {
      currentPage = 1;
      isSearching = (searchType != "Tất cả");
      _fetchData();
    });
  }

  void _updateZoom(double newZoom) {
    _zoomNotifier.value = newZoom.clamp(0.5, 1.5);
  }

  @override
  void dispose() {
    super.dispose();
    searchController.dispose();
    _zoomNotifier.dispose();
    _selectedEmployeeIdNotifier.dispose();
    headerScrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: themeController.backgroundColor.value, // Nền xám nhạt giúp bảng nổi bật
      body: Listener(
        onPointerSignal:
            (pointerSignal) => handleScrollZoom(
              pointerSignal: pointerSignal,
              currentZoom: _zoomNotifier.value,
              onZoomChanged: _updateZoom,
            ),
        //container contain button and table
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

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // title & buttons
                  Container(padding: const EdgeInsets.all(12), child: _buildHeaderBar()),

                  //table & pagination
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: _buildTableSection(),
                    ),
                  ),
                ],
              ),
            ),

            //slider zoom
            ValueListenableBuilder<double>(
              valueListenable: _zoomNotifier,
              builder: (context, zoom, _) {
                return SliderZoom(
                  zoomLevel: zoom,
                  onZoomChanged: _updateZoom,
                  // initialMargin: Offset(142, 90),
                  initialMargin: Offset(73, 152),
                  buttonColor: themeController.buttonColor.value,
                );
              },
            ),
          ],
        ),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () => loadEmployee(),
        backgroundColor: themeController.buttonColor.value,
        child: const Icon(Icons.refresh, color: Colors.white),
      ),
    );
  }

  Widget _buildHeaderBar() {
    return Column(
      children: [
        //title
        Text(
          "DANH SÁCH NHÂN VIÊN",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: themeController.currentColor.value,
          ),
        ),
        const SizedBox(height: 8),

        //button
        LayoutBuilder(
          builder: (context, constraints) {
            return Scrollbar(
              controller: headerScrollController,
              child: SingleChildScrollView(
                controller: headerScrollController,
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.only(bottom: 5),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minWidth: constraints.maxWidth),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      //left button
                      LeftButtonSearch(
                        selectedType: searchType,
                        types: const [
                          'Tất cả',
                          "Tên Nhân Viên",
                          "Số Điện Thoại",
                          "Mã Nhân Viên",
                          "Tình Trạng",
                        ],
                        onTypeChanged: (value) {
                          setState(() {
                            searchType = value;
                            isTextFieldEnabled = value != 'Tất cả';

                            if (searchType == "Tất cả" && searchController.text.isNotEmpty) {
                              searchController.clear();
                              currentPage = 1;
                              _fetchData();
                            }
                          });
                        },
                        controller: searchController,
                        textFieldEnabled: isTextFieldEnabled,
                        buttonColor: themeController.buttonColor,

                        onSearch: () => searchEmployee(),
                      ),
                      const SizedBox(width: 20),

                      //right button
                      if (isHR)
                        ValueListenableBuilder(
                          valueListenable: _selectedEmployeeIdNotifier,
                          builder: (context, selectedEmployeeId, _) {
                            final bool hasSelection = selectedEmployeeId != null;

                            return Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                //export excel
                                AnimatedButton(
                                  onPressed: () async {
                                    showDialog(
                                      context: context,
                                      builder:
                                          (_) => DialogExportEmployee(
                                            onEmployee: () => loadEmployee(),
                                          ),
                                    );
                                  },
                                  label: "Xuất Excel",
                                  icon: Symbols.file_download,
                                  backgroundColor: themeController.buttonColor,
                                ),
                                const SizedBox(width: 10),

                                //add
                                AnimatedButton(
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder:
                                          (_) => EmployeeDialog(
                                            employee: null,
                                            onEmployeeAddOrUpdate: () => loadEmployee(),
                                          ),
                                    );
                                  },
                                  label: "Thêm mới",
                                  icon: Icons.add,
                                  backgroundColor: themeController.buttonColor,
                                ),
                                const SizedBox(width: 10),

                                // update
                                AnimatedButton(
                                  onPressed:
                                      hasSelection
                                          ? () => _handleEditEmployee(selectedEmployeeId!)
                                          : null,
                                  label: "Sửa",
                                  icon: Symbols.construction,
                                  backgroundColor: themeController.buttonColor,
                                ),
                                const SizedBox(width: 10),

                                //delete employee
                                AnimatedButton(
                                  onPressed:
                                      hasSelection
                                          ? () async {
                                            await showDeleteConfirmHelper(
                                              context: context,
                                              title: "⚠️ Xác nhận xoá",
                                              content: "Bạn có chắc chắn muốn xoá nhân viên này?",
                                              onDelete: () async {
                                                await EmployeeService().deleteEmployee(
                                                  employeeId: selectedEmployeeId!,
                                                );
                                              },
                                              onSuccess: () {
                                                setState(() => selectedEmployeeId = null);
                                                loadEmployee();
                                              },
                                            );
                                          }
                                          : null,
                                  label: "Xóa",
                                  icon: Icons.delete,
                                  backgroundColor: const Color(0xffEA4346),
                                ),
                              ],
                            );
                          },
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildTableSection() {
    return FutureBuilder(
      future: futureEmployee,
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
        } else if (!snapshot.hasData || snapshot.data!['employees'].isEmpty) {
          return Container(
            color: themeController.backgroundColor.value,
            child: Center(
              child: Text(
                "Không có nhân viên nào",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
              ),
            ),
          );
        }

        final data = snapshot.data!;
        final employees = data['employees'] as List<EmployeeBasicInfoModel>;
        final currentPg = data['currentPage'];
        final totalPgs = data['totalPages'];

        if (_cachedEmployees == null || _cachedEmployees != employees) {
          _cachedEmployees = employees;
          _cachedDatasource = EmployeeDataSource(
            employee: employees,
            selectedEmployeeId: _selectedEmployeeIdNotifier.value,
            currentPage: currentPage,
            pageSize: pageSize,
          );
        }

        return Column(
          children: [
            //table
            Expanded(
              child: StatefulBuilder(
                builder: (context, localSetState) {
                  return SfDataGridTheme(
                    data: SfDataGridThemeData(selectionColor: Colors.blue.withValues(alpha: 0.3)),
                    child: SfDataGrid(
                      source: _cachedDatasource,
                      isScrollbarAlwaysShown: true,
                      columnWidthMode: ColumnWidthMode.auto,
                      selectionMode: SelectionMode.single,
                      headerRowHeight: 45,
                      rowHeight: 40,
                      columns: ColumnWidthTable.applySavedWidths(
                        columns: columns,
                        widths: columnWidths,
                      ),

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
                            tableKey: 'employee',
                            columnWidths: columnWidths,
                            setState: setState,
                          ),

                      onSelectionChanged: (addedRows, removedRows) {
                        if (addedRows.isNotEmpty) {
                          final selectedRow = addedRows.first;
                          final employeeId =
                              selectedRow
                                  .getCells()
                                  .firstWhere((cell) => cell.columnName == 'employeeId')
                                  .value;

                          _selectedEmployeeIdNotifier.value = employeeId;
                        } else {
                          _selectedEmployeeIdNotifier.value = null;
                        }
                      },
                    ),
                  );
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
                  loadEmployee();
                });
              },
              onNext: () {
                setState(() {
                  currentPage++;
                  loadEmployee();
                });
              },
              onJumpToPage: (page) {
                setState(() {
                  currentPage = page;
                  loadEmployee();
                });
              },
            ),
          ],
        );
      },
    );
  }

  // ==================== ACTION HANDLERS ====================

  Future<void> _handleEditEmployee(int employeeId) async {
    try {
      final employeeData = await futureEmployee;
      final List<EmployeeBasicInfoModel> employeeList =
          (employeeData['employees'] as List? ?? []).cast<EmployeeBasicInfoModel>();
      final selectedEmployees = employeeList.firstWhere(
        (employee) => employee.employeeId == employeeId,
        orElse: () => throw Exception("Không tìm thấy nhân viên"),
      );

      if (mounted) {
        showDialog(
          context: context,
          builder:
              (_) => EmployeeDialog(
                employee: selectedEmployees,
                onEmployeeAddOrUpdate: () => loadEmployee(),
              ),
        );
      }
    } catch (e, s) {
      if (mounted) {
        AppLogger.e("Error in getEmployees: $e", stackTrace: s);
        showSnackBarError(context, 'Có lỗi xảy ra, vui lòng thử lại sau');
      }
    }
  }
}
