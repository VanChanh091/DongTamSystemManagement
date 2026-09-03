import 'package:dongtam/data/controller/theme_controller.dart';
import 'package:dongtam/data/controller/user_controller.dart';
import 'package:dongtam/data/models/admin/paperCode/paper_basis_weight_model.dart';
import 'package:dongtam/presentation/components/shared/animation/animated_button.dart';
import 'package:dongtam/service/admin/admin_paper_code_service.dart';
import 'package:dongtam/utils/handleError/show_snack_bar.dart';
import 'package:dongtam/utils/helper/style_table.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:material_symbols_icons/symbols.dart';

class PaperBasisWeight extends StatefulWidget {
  const PaperBasisWeight({super.key});

  @override
  State<PaperBasisWeight> createState() => _PaperBasisWeightState();
}

class _PaperBasisWeightState extends State<PaperBasisWeight> {
  late Future<List<PaperBasisWeightModel>> futureBasisWeight;

  final userController = Get.find<UserController>();
  final themeController = Get.find<ThemeController>();

  int? selectedBasisWeight;
  bool selectedAll = false;

  List<int> isSelected = [];
  List<PaperBasisWeightModel> updatedBasisWeights = [];

  List<PaperBasisWeightModel> tableData = [];
  List<PaperBasisWeightModel> draftBasisWeights = [];

  @override
  void initState() {
    super.initState();

    if (userController.hasAnyRole(roles: ["admin"])) {
      loadBasisWeight();
    } else {
      futureBasisWeight = Future.error("NO_PERMISSION");
    }
  }

  void loadBasisWeight() {
    setState(() {
      tableData.clear();
      draftBasisWeights.clear();
      futureBasisWeight = AdminPaperCodeService().getAllBasisWeights();
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
        () =>
            isAdmin
                ? FloatingActionButton(
                  onPressed: loadBasisWeight,
                  backgroundColor: themeController.buttonColor.value,
                  child: const Icon(Icons.refresh, color: Colors.white),
                )
                : const SizedBox.shrink(),
      ),
    );
  }

  Widget _buildHeaderBar(bool isAdmin) {
    return Column(
      children: [
        Text(
          "ĐỊNH LƯỢNG GIẤY",
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
                        final newRow = PaperBasisWeightModel(
                          basisWeightId: null,
                          basisWeight: 0,
                          weightCode: "",
                          isDraft: true,
                        );

                        tableData.insert(0, newRow);
                        draftBasisWeights.add(newRow);
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
                          tableData.where((e) => e.isDraft && e.basisWeightId == null).toList();

                      // CASE UPDATE: row có id + được chọn
                      final rowsToUpdate =
                          tableData
                              .where(
                                (e) =>
                                    e.basisWeightId != null && isSelected.contains(e.basisWeightId),
                              )
                              .toList();

                      // check tick checkbox
                      final hasExistingRows = tableData.any((e) => e.basisWeightId != null);

                      if (rowsToAdd.isEmpty && rowsToUpdate.isEmpty) {
                        if (hasExistingRows) {
                          showSnackBarError(context, "Chưa chọn dòng cần cập nhật");
                        } else {
                          showSnackBarError(context, "Không có dữ liệu mới để lưu");
                        }
                        return;
                      }

                      final service = AdminPaperCodeService();

                      Map<String, dynamic> toPayload(PaperBasisWeightModel item) => {
                        "basisWeight": item.basisWeight,
                        "weightCode":
                            item.weightCode?.trim().isEmpty ?? true
                                ? null
                                : item.weightCode!.trim(),
                      };

                      await Future.wait([
                        ...rowsToAdd.map(
                          (e) => service.createBasisWeight(basisWeightData: toPayload(e)),
                        ),
                        ...rowsToUpdate.map(
                          (e) => service.updateBasisWeight(
                            basisWeightId: e.basisWeightId!,
                            basisWeightData: toPayload(e),
                          ),
                        ),
                      ]);

                      setState(() {
                        tableData.clear();
                        draftBasisWeights.clear();
                        isSelected.clear();
                        selectedAll = false;
                      });

                      loadBasisWeight();

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
    return FutureBuilder<List<PaperBasisWeightModel>>(
      future: futureBasisWeight,
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
                    (e) => PaperBasisWeightModel(
                      basisWeightId: e.basisWeightId,
                      basisWeight: e.basisWeight,
                      weightCode: e.weightCode,
                      classifications: e.classifications,
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
                              tableData.map((e) => e.basisWeightId).whereType<int>().toList();
                        } else {
                          isSelected.clear();
                        }
                      });
                    },
                  ),
                ),
              ),
              DataColumn(label: styleText("Định Lượng")),
              DataColumn(label: styleText("Ký Hiệu")),
            ],
            rows: List<DataRow>.generate(tableData.length, (index) {
              final basisWeight = tableData[index];

              return DataRow(
                key: ValueKey(basisWeight.basisWeightId ?? basisWeight.hashCode),
                color:
                    basisWeight.basisWeightId == null
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
                            basisWeight.basisWeightId != null &&
                            isSelected.contains(basisWeight.basisWeightId),
                        onChanged:
                            basisWeight.basisWeightId == null
                                ? null
                                : (val) {
                                  setState(() {
                                    if (val == true) {
                                      isSelected.add(basisWeight.basisWeightId!);
                                    } else {
                                      isSelected.remove(basisWeight.basisWeightId);
                                    }
                                    selectedAll = isSelected.length == snapshot.data!.length;
                                  });
                                },
                      ),
                    ),
                  ),
                  DataCell(
                    styleCellAdmin(
                      text: basisWeight.basisWeight.toString(),
                      onChanged: (value) {
                        basisWeight.basisWeight = int.tryParse(value) ?? 0;
                      },
                    ),
                  ),
                  DataCell(
                    styleCellAdmin(
                      text: basisWeight.weightCode ?? "",
                      onChanged: (value) {
                        basisWeight.weightCode = value;
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
