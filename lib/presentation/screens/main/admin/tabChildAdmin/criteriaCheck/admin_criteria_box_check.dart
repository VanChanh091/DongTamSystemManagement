import 'package:dongtam/data/controller/theme_controller.dart';
import 'package:dongtam/data/controller/user_controller.dart';
import 'package:dongtam/data/models/admin/qcInspection/admin_inspection_box.dart';
import 'package:dongtam/presentation/components/shared/animation/animated_button.dart';
import 'package:dongtam/presentation/components/shared/planning/widgets_planning.dart';
import 'package:dongtam/service/admin_service.dart';
import 'package:dongtam/utils/handleError/show_snack_bar.dart';
import 'package:dongtam/utils/helper/style_table.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

class AdminCriteriaBoxCheck extends StatefulWidget {
  const AdminCriteriaBoxCheck({super.key});

  @override
  State<AdminCriteriaBoxCheck> createState() => _AdminCriteriaBoxCheckState();
}

class _AdminCriteriaBoxCheckState extends State<AdminCriteriaBoxCheck> {
  late Future<List<AdminInspectionBoxModel>> futureCriteria;
  final userController = Get.find<UserController>();
  final themeController = Get.find<ThemeController>();

  List<AdminInspectionBoxModel> updatedCriteria = [];
  List<AdminInspectionBoxModel> draftCriteria = [];
  List<AdminInspectionBoxModel> tableData = [];
  List<int> isSelected = [];

  bool selectedAll = false;
  String machine = "Máy In";

  @override
  void initState() {
    super.initState();
    loadCriteria();
  }

  void loadCriteria() {
    setState(() {
      futureCriteria = AdminService().getAllCriteriaCheck<AdminInspectionBoxModel>(
        isPaper: false,
        machine: machine,
        fromJson: (json) => AdminInspectionBoxModel.fromJson(json),
      );
    });

    isSelected.clear();
    selectedAll = false;
  }

  void changeMachine(String selectedMachine) {
    setState(() {
      machine = selectedMachine;

      // reset toàn bộ state phụ thuộc
      tableData.clear();
      draftCriteria.clear();
      isSelected.clear();
      selectedAll = false;

      loadCriteria();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(5),
        child: Column(
          children: [
            //button
            SizedBox(
              height: 90,
              width: double.infinity,
              child: Column(
                children: [
                  //title
                  SizedBox(
                    height: 30,
                    width: double.infinity,
                    child: Center(
                      child: Obx(
                        () => Text(
                          "TIÊU CHÍ KIỂM TRA CHẤT LƯỢNG LÀM THÙNG",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 22,
                            color: themeController.currentColor.value,
                          ),
                        ),
                      ),
                    ),
                  ),

                  //button
                  SizedBox(
                    height: 60,
                    width: double.infinity,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        //left
                        const SizedBox(width: 10),
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
                          onChanged: (value) async {
                            if (value == null) return;
                            changeMachine(value);
                          },
                        ),

                        //right
                        Expanded(
                          flex: 1,
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                //add
                                AnimatedButton(
                                  onPressed: () {
                                    setState(() {
                                      final newRow = AdminInspectionBoxModel(
                                        criteriaBoxId: null,
                                        criteriaBoxCode: "",
                                        criteriaBoxName: "",
                                        variance: 0.0,
                                        machine: machine,
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
                                                  e.criteriaBoxId == null &&
                                                  e.criteriaBoxCode.trim().isNotEmpty &&
                                                  e.criteriaBoxName.trim().isNotEmpty,
                                            )
                                            .toList();

                                    // CASE UPDATE: row có id + được chọn
                                    final rowsToUpdate =
                                        tableData
                                            .where(
                                              (e) =>
                                                  e.criteriaBoxId != null &&
                                                  isSelected.contains(e.criteriaBoxId),
                                            )
                                            .toList();

                                    if (rowsToAdd.isEmpty && rowsToUpdate.isEmpty) {
                                      showSnackBarError(context, "Không có dữ liệu để lưu");
                                      return;
                                    }

                                    // ================== ADD ==================
                                    for (final e in rowsToAdd) {
                                      await AdminService().createNewCriteria(
                                        criteriaData: {
                                          "criteriaBoxCode": e.criteriaBoxCode,
                                          "criteriaBoxName": e.criteriaBoxName,
                                          "variance": e.variance,
                                          "machine": e.machine,
                                        },
                                      );
                                    }

                                    // ================== UPDATE ==================
                                    for (final e in rowsToUpdate) {
                                      await AdminService().updateCriteria(
                                        qcCriteriaId: e.criteriaBoxId!,
                                        criteriaUpdated: {
                                          "criteriaBoxCode": e.criteriaBoxCode,
                                          "criteriaBoxName": e.criteriaBoxName,
                                          "variance": e.variance,
                                          "machine": e.machine,
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

                                    if (!context.mounted) return;
                                    showSnackBarSuccess(context, "Đã lưu thay đổi thành công");
                                  },

                                  label: "Lưu Thay Đổi",
                                  icon: Symbols.save,
                                  backgroundColor: themeController.buttonColor,
                                ),
                                const SizedBox(width: 10),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            //table
            Expanded(
              child: SizedBox(
                width: double.infinity,
                child: FutureBuilder<List<AdminInspectionBoxModel>>(
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
                                (e) => AdminInspectionBoxModel(
                                  criteriaBoxId: e.criteriaBoxId,
                                  criteriaBoxCode: e.criteriaBoxCode,
                                  criteriaBoxName: e.criteriaBoxName,
                                  variance: e.variance,
                                  machine: e.machine,
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
                                          tableData
                                              .map((e) => e.criteriaBoxId)
                                              .whereType<int>()
                                              .toList();
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
                          DataColumn(label: styleText("Loại Máy")),
                        ],
                        rows: List<DataRow>.generate(tableData.length, (index) {
                          final criteria = tableData[index];

                          return DataRow(
                            key: ValueKey(criteria.criteriaBoxId ?? criteria.hashCode),
                            color:
                                criteria.criteriaBoxId == null
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
                                        criteria.criteriaBoxId != null &&
                                        isSelected.contains(criteria.criteriaBoxId),
                                    onChanged:
                                        criteria.criteriaBoxId == null
                                            ? null
                                            : (val) {
                                              setState(() {
                                                if (val == true) {
                                                  isSelected.add(criteria.criteriaBoxId!);
                                                } else {
                                                  isSelected.remove(criteria.criteriaBoxId);
                                                }
                                                selectedAll =
                                                    isSelected.length == snapshot.data!.length;
                                              });
                                            },
                                  ),
                                ),
                              ),
                              DataCell(
                                styleCellAdmin(
                                  text: criteria.criteriaBoxCode.toString(),
                                  onChanged: (value) {
                                    setState(() {
                                      criteria.criteriaBoxCode = value;
                                    });
                                  },
                                ),
                              ),
                              DataCell(
                                styleCellAdmin(
                                  text: criteria.criteriaBoxName.toString(),
                                  onChanged: (value) {
                                    setState(() {
                                      criteria.criteriaBoxName = value;
                                    });
                                  },
                                ),
                              ),
                              DataCell(
                                styleCellAdmin(
                                  text: criteria.variance.toString(),
                                  onChanged: (value) {
                                    setState(() {
                                      criteria.variance = double.tryParse(value) ?? 0.0;
                                    });
                                  },
                                ),
                              ),
                              DataCell(
                                styleCellAdmin(
                                  text: criteria.machine,
                                  onChanged: (value) {
                                    setState(() {
                                      criteria.machine = value;
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
                ),
              ),
            ),
          ],
        ),
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
}
