import 'package:dongtam/data/controller/theme_controller.dart';
import 'package:dongtam/data/controller/user_controller.dart';
import 'package:dongtam/data/models/admin/paperCode/paper_type_model.dart';
import 'package:dongtam/presentation/components/shared/animation/animated_button.dart';
import 'package:dongtam/service/admin/admin_paper_code_service.dart';
import 'package:dongtam/utils/handleError/show_snack_bar.dart';
import 'package:dongtam/utils/helper/style_table.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:material_symbols_icons/symbols.dart';

class PaperType extends StatefulWidget {
  const PaperType({super.key});

  @override
  State<PaperType> createState() => _PaperTypeState();
}

class _PaperTypeState extends State<PaperType> {
  late Future<List<PaperTypeModel>> futurePaperType;

  final userController = Get.find<UserController>();
  final themeController = Get.find<ThemeController>();

  late bool isAdmin;
  int? selectedPaperType;
  bool selectedAll = false;

  List<int> isSelected = [];
  List<PaperTypeModel> updatedPaperTypes = [];

  List<PaperTypeModel> tableData = [];
  List<PaperTypeModel> draftPaperTypes = [];

  @override
  void initState() {
    super.initState();
    isAdmin = userController.hasAnyRole(roles: ["admin"]);

    loadPaperType();
  }

  void loadPaperType() {
    setState(() {
      tableData.clear();
      draftPaperTypes.clear();
      futurePaperType = AdminPaperCodeService().getAllPaperTypes();
    });

    isSelected.clear();
    selectedAll = false;
  }

  @override
  Widget build(BuildContext context) {
    final bool isAdmin = userController.hasAnyRole(roles: ["admin"]);

    return Scaffold(
      backgroundColor: themeController.backgroundColor.value,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // title & buttons
          Container(padding: const EdgeInsets.all(12), child: _buildHeaderBar(isAdmin)),

          // table & pagination
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
          onPressed: loadPaperType,
          backgroundColor: themeController.buttonColor.value,
          child: const Icon(Icons.refresh, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildHeaderBar(bool isAdmin) {
    return Column(
      children: [
        Text(
          "KÝ HIỆU LOẠI GIẤY",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: themeController.currentColor.value,
          ),
        ),
        const SizedBox(height: 8),

        if (isAdmin)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // left
              const SizedBox(),

              // right
              Row(
                children: [
                  // add
                  AnimatedButton(
                    onPressed: () {
                      setState(() {
                        final newRow = PaperTypeModel(
                          paperTypeId: null,
                          paperName: "",
                          paperCode: "",
                          isDraft: true,
                        );

                        tableData.insert(0, newRow);
                        draftPaperTypes.add(newRow);
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
                                    e.paperTypeId == null &&
                                    e.paperName.trim().isNotEmpty &&
                                    e.paperCode.trim().isNotEmpty,
                              )
                              .toList();

                      // CASE UPDATE: row có id + được chọn
                      final rowsToUpdate =
                          tableData
                              .where(
                                (e) => e.paperTypeId != null && isSelected.contains(e.paperTypeId),
                              )
                              .toList();

                      // check tick checkbox
                      final hasUpdateRow = tableData.any((e) => e.paperTypeId != null);

                      if (rowsToAdd.isEmpty && hasUpdateRow && rowsToUpdate.isEmpty) {
                        showSnackBarError(context, "Chưa chọn dòng cần cập nhật");
                        return;
                      }

                      final service = AdminPaperCodeService();

                      Map<String, dynamic> toPayload(PaperTypeModel item) => {
                        "paperName": item.paperName,
                        "paperCode": item.paperCode,
                      };

                      await Future.wait([
                        ...rowsToAdd.map(
                          (e) => service.createPaperType(paperTypeData: toPayload(e)),
                        ),
                        ...rowsToUpdate.map(
                          (e) => service.updatePaperType(
                            paperTypeId: e.paperTypeId!,
                            paperTypeData: toPayload(e),
                          ),
                        ),
                      ]);

                      setState(() {
                        tableData.clear();
                        draftPaperTypes.clear();
                        isSelected.clear();
                        selectedAll = false;
                      });

                      loadPaperType();

                      if (mounted) {
                        showSnackBarSuccess(context, "Đã lưu thay đổi thành công");
                      }
                    },

                    label: "Lưu Thay Đổi",
                    icon: Symbols.save,
                    backgroundColor: themeController.buttonColor,
                  ),

                  const SizedBox(width: 8),
                ],
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildTableSection() {
    return FutureBuilder<List<PaperTypeModel>>(
      future: futurePaperType,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
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
              "Không có dữ liệu",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
            ),
          );
        }

        if (snapshot.hasData && tableData.isEmpty) {
          tableData =
              snapshot.data!
                  .map(
                    (e) => PaperTypeModel(
                      paperTypeId: e.paperTypeId,
                      paperName: e.paperName,
                      paperCode: e.paperCode,
                      supplierPapers: e.supplierPapers,
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
                              tableData.map((e) => e.paperTypeId).whereType<int>().toList();
                        } else {
                          isSelected.clear();
                        }
                      });
                    },
                  ),
                ),
              ),
              DataColumn(label: styleText("Tên Loại Giấy")),
              DataColumn(label: styleText("Mã Loại Giấy")),
            ],
            rows: List<DataRow>.generate(tableData.length, (index) {
              final paperType = tableData[index];

              return DataRow(
                key: ValueKey(paperType.paperTypeId ?? paperType.hashCode),
                color:
                    paperType.paperTypeId == null
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
                            paperType.paperTypeId != null &&
                            isSelected.contains(paperType.paperTypeId),
                        onChanged:
                            paperType.paperTypeId == null
                                ? null
                                : (val) {
                                  setState(() {
                                    if (val == true) {
                                      isSelected.add(paperType.paperTypeId!);
                                    } else {
                                      isSelected.remove(paperType.paperTypeId);
                                    }
                                    selectedAll = isSelected.length == snapshot.data!.length;
                                  });
                                },
                      ),
                    ),
                  ),
                  DataCell(
                    styleCellAdmin(
                      text: paperType.paperName,
                      onChanged: (value) {
                        paperType.paperName = value;
                      },
                    ),
                  ),
                  DataCell(
                    styleCellAdmin(
                      text: paperType.paperCode,
                      onChanged: (value) {
                        paperType.paperCode = value;
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
