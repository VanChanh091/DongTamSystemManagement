import 'package:dongtam/data/controller/theme_controller.dart';
import 'package:dongtam/data/controller/user_controller.dart';
import 'package:dongtam/data/models/admin/paperCode/paper_classification_model.dart';
import 'package:dongtam/presentation/components/dialog/paperCode/dialog_paper_classification.dart';
import 'package:dongtam/presentation/components/headerTable/paperCode/header_paper_classification.dart';
import 'package:dongtam/presentation/components/shared/animation/animated_button.dart';
import 'package:dongtam/presentation/components/shared/pagination_controls.dart';
import 'package:dongtam/presentation/sources/admin/paperCode/paper_classification_data_source.dart';
import 'package:dongtam/service/admin/admin_paper_code_service.dart';
import 'package:dongtam/utils/handleError/show_snack_bar.dart';
import 'package:dongtam/utils/helper/grid_resize_helper.dart';
import 'package:dongtam/utils/helper/skeleton/skeleton_loading.dart';
import 'package:dongtam/utils/storage/sharedPreferences/column_width_table.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class PaperClassification extends StatefulWidget {
  const PaperClassification({super.key});

  @override
  State<PaperClassification> createState() => _PaperClassificationState();
}

class _PaperClassificationState extends State<PaperClassification> {
  late Future<Map<String, dynamic>> futureClassification;
  PaperClassificationDataSource? classificationDatasource;
  late List<GridColumn> columns;

  //controller
  final dataGridController = DataGridController();
  final userController = Get.find<UserController>();
  final themeController = Get.find<ThemeController>();

  List<int> selectedIds = [];
  List<PaperClassificationModel> currentClassifications = [];
  Map<String, double> columnWidths = {}; //map header table

  //flag
  bool _isSelectionChange = false;

  // Paging
  int currentPage = 1;
  int pageSize = 35;

  @override
  void initState() {
    super.initState();
    loadPaperClassification();

    columns = buildPaperClassificationColumn(themeController: themeController);
    ColumnWidthTable.loadWidths(tableKey: 'paperClassification', columns: columns).then((w) {
      setState(() {
        columnWidths = w;
      });
    });
  }

  void loadPaperClassification() {
    classificationDatasource = null;
    dataGridController.selectedRows = [];

    setState(() {
      futureClassification = ensureMinLoading(
        AdminPaperCodeService().getAllPaperClassifications(page: currentPage, pageSize: pageSize),
      );
      selectedIds.clear();
      currentClassifications.clear();
    });
  }

  void _updateSelectedIdsFromRows(List<DataGridRow> rows) {
    selectedIds =
        rows.map((row) {
          final cell = row.getCells().firstWhere(
            (c) => c.columnName == 'classificationId',
            orElse: () => const DataGridCell(columnName: 'classificationId', value: 0),
          );
          return cell.value as int;
        }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: themeController.backgroundColor.value,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // title & buttons
          Container(padding: const EdgeInsets.all(12), child: _buildHeaderBar()),

          //table & pagination
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: _buildTableSection(),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => loadPaperClassification(),
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
          "BẢNG PHÂN LOẠI GIẤY THEO CẤP ĐỘ",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: themeController.currentColor.value,
          ),
        ),
        const SizedBox(height: 8),

        //button
        Row(
          children: [
            //left button
            Expanded(flex: 2, child: const SizedBox()),

            //right button
            Expanded(
              flex: 3,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Button Thêm
                  AnimatedButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder:
                            (context) => PaperClassificationDialog(
                              isEdit: false,
                              onSuccess: () => loadPaperClassification(),
                            ),
                      );
                    },
                    label: "Thêm Mới",
                    icon: Icons.add,
                    backgroundColor: themeController.buttonColor,
                  ),
                  const SizedBox(width: 10),

                  // Button Cập nhật
                  AnimatedButton(
                    onPressed: () {
                      if (selectedIds.isEmpty) {
                        showSnackBarError(context, "Vui lòng chọn ít nhất 1 dòng để cập nhật");
                        return;
                      }

                      List<PaperClassificationModel> selectedData = [];
                      if (selectedIds.isNotEmpty && currentClassifications.isNotEmpty) {
                        selectedData =
                            currentClassifications
                                .where((e) => selectedIds.contains(e.classificationId))
                                .toList();
                      }

                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder:
                            (context) => PaperClassificationDialog(
                              isEdit: true,
                              initialData: selectedData,
                              onSuccess: () => loadPaperClassification(),
                            ),
                      );
                    },
                    label: "Cập Nhật",
                    icon: Icons.edit,
                    backgroundColor: themeController.buttonColor,
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTableSection() {
    return FutureBuilder(
      future: futureClassification,
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
              "Không có dữ liệu nào",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
            ),
          );
        }

        final data = snapshot.data!;

        final classifications = data['classifications'] as List<PaperClassificationModel>;
        final currentPg = data['currentPage'] as int;
        final totalPgs = data['totalPages'] as int;

        currentClassifications = classifications;

        classificationDatasource = PaperClassificationDataSource(
          classifications: classifications,
          currentPage: currentPage,
          pageSize: pageSize,
        );

        return Column(
          children: [
            Expanded(
              child: StatefulBuilder(
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
                      source: classificationDatasource!,
                      isScrollbarAlwaysShown: true,
                      columnWidthMode: ColumnWidthMode.fill,
                      selectionMode: SelectionMode.multiple,
                      headerRowHeight: 47,
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
                            setState: setState,
                          ),
                      onColumnResizeEnd:
                          (details) => GridResizeHelper.onResizeEnd(
                            details: details,
                            tableKey: 'paperClassification',
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
                          final allRows = classificationDatasource!.rows;
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
                              dataGridController.selectedRows = List.from(rangeSelection);
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
              ),
            ),

            const SizedBox(height: 8),
            PaginationControls(
              currentPage: currentPg,
              totalPages: totalPgs,
              onPrevious:
                  () => setState(() {
                    currentPage--;
                    loadPaperClassification();
                  }),
              onNext:
                  () => setState(() {
                    currentPage++;
                    loadPaperClassification();
                  }),
              onJumpToPage:
                  (page) => setState(() {
                    currentPage = page;
                    loadPaperClassification();
                  }),
            ),
          ],
        );
      },
    );
  }
}
