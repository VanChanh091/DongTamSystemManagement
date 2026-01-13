import 'package:dongtam/data/controller/theme_controller.dart';
import 'package:dongtam/data/controller/user_controller.dart';
import 'package:dongtam/data/models/admin/qc_criteria_model.dart';
import 'package:dongtam/service/admin/admin_criteria_service.dart';
import 'package:dongtam/presentation/components/shared/animated_button.dart';
import 'package:dongtam/utils/helper/style_table.dart';
import 'package:dongtam/utils/handleError/show_snack_bar.dart';
import 'package:dongtam/utils/logger/app_logger.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

class AdminCriteria extends StatefulWidget {
  const AdminCriteria({super.key});

  @override
  State<AdminCriteria> createState() => _AdminVehicleState();
}

class _AdminVehicleState extends State<AdminCriteria> {
  late Future<List<QcCriteriaModel>> futureCriteria;
  final userController = Get.find<UserController>();
  final themeController = Get.find<ThemeController>();

  List<QcCriteriaModel> updatedCriteria = [];
  List<QcCriteriaModel> draftCriteria = [];
  List<QcCriteriaModel> tableData = [];
  List<int> isSelected = [];
  int? selectedVehicleId;
  bool selectedAll = false;

  final Map<String, String> typeFieldMap = {"Giấy Tấm": "paper", "Thùng": "box"};
  String type = "Giấy Tấm";

  String get currentProcessType => typeFieldMap[type]!;

  @override
  void initState() {
    super.initState();

    loadCriteria();
  }

  void loadCriteria() {
    setState(() {
      futureCriteria = AdminCriteriaService().getAllQcCriteria(type: currentProcessType);
    });

    isSelected.clear();
    selectedAll = false;
  }

  void changeProcessType(String selectedType) {
    AppLogger.i("changeProcessType | from=$type -> to=$selectedType");

    setState(() {
      type = selectedType;

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
                  SizedBox(
                    height: 30,
                    width: double.infinity,
                    child: Center(
                      child: Obx(
                        () => Text(
                          "TIÊU CHÍ ĐÁNH GIÁ GIẤY TẤM/THÙNG",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 22,
                            color: themeController.currentColor.value,
                          ),
                        ),
                      ),
                    ),
                  ),

                  SizedBox(
                    height: 60,
                    width: double.infinity,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        //left
                        const SizedBox(width: 10),
                        SizedBox(
                          width: 130,
                          child: DropdownButtonFormField<String>(
                            value: type,
                            items:
                                ["Giấy Tấm", "Thùng"].map((String value) {
                                  return DropdownMenuItem<String>(value: value, child: Text(value));
                                }).toList(),
                            onChanged: (value) {
                              if (value != null) {
                                changeProcessType(value);
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
                                      final newRow = QcCriteriaModel(
                                        qcCriteriaId: null,
                                        processType: currentProcessType,
                                        criteriaCode: '',
                                        criteriaName: '',
                                        isRequired: false,
                                        isDraft: true,
                                      );

                                      tableData.insert(0, newRow);
                                      draftCriteria.add(newRow);
                                    });
                                  },

                                  label: "Thêm dòng",
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
                                                  e.qcCriteriaId == null &&
                                                  e.criteriaCode.trim().isNotEmpty &&
                                                  e.criteriaName.trim().isNotEmpty,
                                            )
                                            .toList();

                                    // CASE UPDATE: row có id + được chọn
                                    final rowsToUpdate =
                                        tableData
                                            .where(
                                              (e) =>
                                                  e.qcCriteriaId != null &&
                                                  isSelected.contains(e.qcCriteriaId),
                                            )
                                            .toList();

                                    if (rowsToAdd.isEmpty && rowsToUpdate.isEmpty) {
                                      showSnackBarError(context, "Không có dữ liệu để lưu");
                                      return;
                                    }

                                    // ================== ADD ==================
                                    for (final e in rowsToAdd) {
                                      await AdminCriteriaService().createNewCriteria(
                                        criteriaData: {
                                          "processType": currentProcessType,
                                          "criteriaCode": e.criteriaCode,
                                          "criteriaName": e.criteriaName,
                                          "isRequired": e.isRequired,
                                        },
                                      );
                                    }

                                    // ================== UPDATE ==================
                                    for (final e in rowsToUpdate) {
                                      await AdminCriteriaService().updateCriteria(
                                        qcCriteriaId: e.qcCriteriaId!,
                                        criteriaUpdated: {
                                          "processType": currentProcessType,
                                          "criteriaCode": e.criteriaCode,
                                          "criteriaName": e.criteriaName,
                                          "isRequired": e.isRequired,
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

                                //delete customers
                                AnimatedButton(
                                  onPressed:
                                      isSelected.isNotEmpty
                                          ? () {
                                            showDialog(
                                              context: context,
                                              builder: (context) {
                                                bool isDeleting = false;

                                                return StatefulBuilder(
                                                  builder: (context, setStateDialog) {
                                                    return AlertDialog(
                                                      backgroundColor: Colors.white,
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius: BorderRadius.circular(16),
                                                      ),
                                                      title: const Row(
                                                        children: [
                                                          Icon(
                                                            Icons.warning_amber_rounded,
                                                            color: Colors.red,
                                                            size: 30,
                                                          ),
                                                          SizedBox(width: 8),
                                                          Text(
                                                            "Xác nhận xoá",
                                                            style: TextStyle(
                                                              fontWeight: FontWeight.bold,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      content:
                                                          isDeleting
                                                              ? const Row(
                                                                children: [
                                                                  CircularProgressIndicator(
                                                                    strokeWidth: 2,
                                                                  ),
                                                                  SizedBox(width: 12),
                                                                  Text("Đang xoá..."),
                                                                ],
                                                              )
                                                              : const Text(
                                                                'Bạn có chắc chắn muốn xoá?',
                                                                style: TextStyle(fontSize: 16),
                                                              ),
                                                      actions:
                                                          isDeleting
                                                              ? []
                                                              : [
                                                                TextButton(
                                                                  onPressed:
                                                                      () => Navigator.pop(context),
                                                                  child: const Text(
                                                                    "Huỷ",
                                                                    style: TextStyle(
                                                                      fontSize: 16,
                                                                      fontWeight: FontWeight.bold,
                                                                      color: Colors.black54,
                                                                    ),
                                                                  ),
                                                                ),
                                                                ElevatedButton(
                                                                  style: ElevatedButton.styleFrom(
                                                                    backgroundColor: const Color(
                                                                      0xffEA4346,
                                                                    ),
                                                                    foregroundColor: Colors.white,
                                                                    shape: RoundedRectangleBorder(
                                                                      borderRadius:
                                                                          BorderRadius.circular(8),
                                                                    ),
                                                                  ),
                                                                  onPressed: () async {
                                                                    setStateDialog(() {
                                                                      isDeleting = true;
                                                                    });

                                                                    for (int id in isSelected) {
                                                                      await AdminCriteriaService()
                                                                          .deleteCriteria(
                                                                            qcCriteriaId: id,
                                                                          );
                                                                    }

                                                                    await Future.delayed(
                                                                      const Duration(seconds: 1),
                                                                    );

                                                                    if (!context.mounted) {
                                                                      return;
                                                                    }

                                                                    setState(() {
                                                                      isSelected.clear();
                                                                      tableData.clear();
                                                                    });

                                                                    loadCriteria();

                                                                    Navigator.pop(context);

                                                                    // Optional: Show success toast
                                                                    showSnackBarSuccess(
                                                                      context,
                                                                      'Xoá thành công',
                                                                    );
                                                                  },
                                                                  child: const Text(
                                                                    "Xoá",
                                                                    style: TextStyle(
                                                                      fontSize: 16,
                                                                      fontWeight: FontWeight.bold,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                    );
                                                  },
                                                );
                                              },
                                            );
                                          }
                                          : null,
                                  label: "Xóa",
                                  icon: Icons.delete,
                                  backgroundColor: const Color(0xffEA4346),
                                ),
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
                child: FutureBuilder<List<QcCriteriaModel>>(
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
                                (e) => QcCriteriaModel(
                                  qcCriteriaId: e.qcCriteriaId,
                                  processType: e.processType,
                                  criteriaCode: e.criteriaCode,
                                  criteriaName: e.criteriaName,
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
                                          tableData
                                              .map((e) => e.qcCriteriaId)
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
                          DataColumn(label: styleText("Bắt Buộc")),
                        ],
                        rows: List<DataRow>.generate(tableData.length, (index) {
                          final vehicle = tableData[index];
                          return DataRow(
                            key: ValueKey(vehicle.qcCriteriaId ?? vehicle.hashCode),
                            color:
                                vehicle.qcCriteriaId == null
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
                                        vehicle.qcCriteriaId != null &&
                                        isSelected.contains(vehicle.qcCriteriaId),
                                    onChanged:
                                        vehicle.qcCriteriaId == null
                                            ? null
                                            : (val) {
                                              setState(() {
                                                if (val == true) {
                                                  isSelected.add(vehicle.qcCriteriaId!);
                                                } else {
                                                  isSelected.remove(vehicle.qcCriteriaId);
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
                                  text: vehicle.criteriaCode.toString(),
                                  onChanged: (value) {
                                    setState(() {
                                      vehicle.criteriaCode = value;
                                    });
                                  },
                                ),
                              ),
                              DataCell(
                                styleCellAdmin(
                                  text: vehicle.criteriaName.toString(),
                                  onChanged: (value) {
                                    setState(() {
                                      vehicle.criteriaName = value;
                                    });
                                  },
                                ),
                              ),
                              DataCell(
                                Checkbox(
                                  value: vehicle.isRequired,
                                  activeColor: Colors.green,
                                  checkColor: Colors.white,
                                  onChanged: (val) {
                                    setState(() {
                                      vehicle.isRequired = val ?? false;
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
