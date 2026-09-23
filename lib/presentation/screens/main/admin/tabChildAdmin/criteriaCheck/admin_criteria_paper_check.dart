import 'package:dongtam/data/controller/theme_controller.dart';
import 'package:dongtam/data/controller/user_controller.dart';
import 'package:dongtam/data/models/admin/qcInspection/admin_inspection_paper.dart';
import 'package:dongtam/presentation/components/shared/animation/animated_button.dart';
import 'package:dongtam/service/admin/admin_service.dart';
import 'package:dongtam/utils/handleError/show_snack_bar.dart';
import 'package:dongtam/utils/helper/style_table.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

class AdminCriteriaPaperCheck extends StatefulWidget {
  const AdminCriteriaPaperCheck({super.key});

  @override
  State<AdminCriteriaPaperCheck> createState() => _AdminCriteriaPaperCheckState();
}

class _AdminCriteriaPaperCheckState extends State<AdminCriteriaPaperCheck> {
  late Future<List<AdminInspectionPaperModel>> futureCriteria;
  final userController = Get.find<UserController>();
  final themeController = Get.find<ThemeController>();

  List<AdminInspectionPaperModel> updatedCriteria = [];
  List<AdminInspectionPaperModel> draftCriteria = [];
  List<AdminInspectionPaperModel> tableData = [];
  List<int> isSelected = [];
  bool selectedAll = false;

  @override
  void initState() {
    super.initState();
    loadCriteria();
  }

  void loadCriteria() {
    setState(() {
      futureCriteria = AdminService().getAllCriteriaCheck<AdminInspectionPaperModel>(
        isPaper: true,
        fromJson: (json) => AdminInspectionPaperModel.fromJson(json),
      );
    });

    isSelected.clear();
    selectedAll = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: themeController.backgroundColor.value,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
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
      floatingActionButton: Obx(
        () => FloatingActionButton(
          onPressed: loadCriteria,
          backgroundColor: themeController.buttonColor.value,
          child: const Icon(Icons.refresh, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildHeaderBar() {
    return Column(
      children: [
        Text(
          "TIÊU CHÍ KIỂM TRA CHẤT LƯỢNG GIẤY TẤM",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: themeController.currentColor.value,
          ),
        ),
        const SizedBox(height: 8),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            //left
            const SizedBox(width: 10),

            //right
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                //add
                AnimatedButton(
                  onPressed: () {
                    setState(() {
                      final newRow = AdminInspectionPaperModel(
                        criteriaPaperId: null,
                        criteriaPaperCode: '',
                        criteriaPaperName: '',
                        isRequired: false,
                        variance: 0.0,
                        isDraft: true,
                      );

                      tableData.insert(0, newRow);
                      draftCriteria.add(newRow);
                    });
                  },

                  label: "Thêm Tiêu Chí",
                  icon: Icons.add,
                  backgroundColor: themeController.buttonColor,
                ),
                const SizedBox(width: 10),

                // update
                AnimatedButton(
                  onPressed: () async {
                    // CASE ADD: row mới (draft, chưa có id)
                    final rowsToAdd =
                        tableData
                            .where(
                              (e) =>
                                  e.isDraft &&
                                  e.criteriaPaperId == null &&
                                  e.criteriaPaperCode.trim().isNotEmpty &&
                                  e.criteriaPaperName.trim().isNotEmpty,
                            )
                            .toList();

                    // CASE UPDATE: row có id + được chọn
                    final rowsToUpdate =
                        tableData
                            .where(
                              (e) =>
                                  e.criteriaPaperId != null &&
                                  isSelected.contains(e.criteriaPaperId),
                            )
                            .toList();

                    if (rowsToAdd.isEmpty && rowsToUpdate.isEmpty) {
                      showSnackBarError(context, "Không có dữ liệu để lưu");
                      return;
                    }

                    // ================== ADD ==================
                    for (final e in rowsToAdd) {
                      await AdminService().createNewCriteriaCheck(
                        isPaper: true,
                        criteriaData: {
                          "criteriaPaperCode": e.criteriaPaperCode,
                          "criteriaPaperName": e.criteriaPaperName,
                          "isRequired": e.isRequired,
                          "variance": e.variance,
                        },
                      );
                    }

                    // ================== UPDATE ==================
                    for (final e in rowsToUpdate) {
                      await AdminService().updateCriteriaCheck(
                        criteriaId: e.criteriaPaperId!,
                        isPaper: true,
                        criteriaUpdated: {
                          "criteriaPaperCode": e.criteriaPaperCode,
                          "criteriaPaperName": e.criteriaPaperName,
                          "isRequired": e.isRequired,
                          "variance": e.variance,
                        },
                      );
                    }

                    setState(() {
                      tableData.clear();
                      draftCriteria.clear();
                      isSelected.clear();
                      selectedAll = false;
                    });

                    loadCriteria();

                    if (mounted) {
                      showSnackBarSuccess(context, "Đã lưu thay đổi thành công");
                    }
                  },

                  label: "Lưu Thay Đổi",
                  icon: Symbols.save,
                  backgroundColor: themeController.buttonColor,
                ),
                const SizedBox(width: 10),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTableSection() {
    return FutureBuilder<List<AdminInspectionPaperModel>>(
      future: futureCriteria,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
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

        if (snapshot.hasData && tableData.isEmpty) {
          tableData =
              snapshot.data!
                  .map(
                    (e) => AdminInspectionPaperModel(
                      criteriaPaperId: e.criteriaPaperId,
                      criteriaPaperCode: e.criteriaPaperCode,
                      criteriaPaperName: e.criteriaPaperName,
                      variance: e.variance,
                      isRequired: e.isRequired,
                      isDraft: false,
                    ),
                  )
                  .toList();
        }

        return SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: DataTable(
            columnSpacing: 25,
            headingRowColor: WidgetStatePropertyAll(themeController.currentColor.value),
            columns: [
              DataColumn(
                label: Theme(
                  data: Theme.of(context).copyWith(
                    checkboxTheme: CheckboxThemeData(
                      fillColor: WidgetStateProperty.resolveWith<Color>((states) {
                        if (states.contains(WidgetState.selected)) {
                          return Colors.red;
                        }
                        return Colors.white;
                      }),
                      checkColor: WidgetStateProperty.all<Color>(Colors.white),
                      side: const BorderSide(color: Colors.black, width: 1),
                    ),
                  ),
                  child: Checkbox(
                    value: selectedAll,
                    onChanged: (value) {
                      setState(() {
                        selectedAll = value!;
                        if (selectedAll) {
                          isSelected =
                              tableData.map((e) => e.criteriaPaperId).whereType<int>().toList();
                        } else {
                          isSelected.clear();
                        }
                      });
                    },
                  ),
                ),
              ),
              DataColumn(label: styleText("Mã Tiêu Chí")),
              DataColumn(label: styleText("Tên Tiêu Chí")),
              DataColumn(label: styleText("Sai Số Cho Phép")),
              DataColumn(label: styleText("Bắt Buộc")),
            ],
            rows: List<DataRow>.generate(tableData.length, (index) {
              final criteria = tableData[index];

              return DataRow(
                key: ValueKey(criteria.criteriaPaperId ?? criteria.hashCode),
                color:
                    criteria.criteriaPaperId == null
                        ? WidgetStateProperty.all(Colors.yellow.withValues(alpha: 0.2))
                        : null,
                cells: [
                  DataCell(
                    Theme(
                      data: Theme.of(context).copyWith(
                        checkboxTheme: CheckboxThemeData(
                          fillColor: WidgetStateProperty.resolveWith<Color>((states) {
                            if (states.contains(WidgetState.selected)) {
                              return Colors.red;
                            }
                            return Colors.white;
                          }),
                          checkColor: WidgetStateProperty.all<Color>(Colors.white),
                          side: const BorderSide(color: Colors.black, width: 1),
                        ),
                      ),
                      child: Checkbox(
                        value:
                            criteria.criteriaPaperId != null &&
                            isSelected.contains(criteria.criteriaPaperId),
                        onChanged:
                            criteria.criteriaPaperId == null
                                ? null
                                : (val) {
                                  setState(() {
                                    if (val == true) {
                                      isSelected.add(criteria.criteriaPaperId!);
                                    } else {
                                      isSelected.remove(criteria.criteriaPaperId);
                                    }
                                    selectedAll = isSelected.length == snapshot.data!.length;
                                  });
                                },
                      ),
                    ),
                  ),
                  DataCell(
                    styleCellAdmin(
                      text: criteria.criteriaPaperCode.toString(),
                      onChanged: (value) {
                        setState(() {
                          criteria.criteriaPaperCode = value;
                        });
                      },
                    ),
                  ),
                  DataCell(
                    styleCellAdmin(
                      text: criteria.criteriaPaperName.toString(),
                      onChanged: (value) {
                        setState(() {
                          criteria.criteriaPaperName = value;
                        });
                      },
                    ),
                  ),
                  DataCell(
                    styleCellAdmin(
                      text: criteria.variance.toString(),
                      onChanged: (value) {
                        setState(() {
                          criteria.variance = double.tryParse(value) ?? 0;
                        });
                      },
                    ),
                  ),
                  DataCell(
                    Checkbox(
                      value: criteria.isRequired,
                      activeColor: Colors.green,
                      checkColor: Colors.white,
                      onChanged: (val) {
                        setState(() {
                          criteria.isRequired = val ?? false;
                        });
                      },
                    ),
                  ),
                ],
              );
            }),
          ),
        );
      },
    );
  }
}
