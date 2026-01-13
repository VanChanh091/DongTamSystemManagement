import 'package:dongtam/data/controller/theme_controller.dart';
import 'package:dongtam/data/controller/user_controller.dart';
import 'package:dongtam/data/models/admin/admin_flute_ratio_model.dart';
import 'package:dongtam/service/admin/admin_service.dart';
import 'package:dongtam/presentation/components/shared/animated_button.dart';
import 'package:dongtam/utils/helper/style_table.dart';
import 'package:dongtam/utils/handleError/show_snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

class AdminFluteRatio extends StatefulWidget {
  const AdminFluteRatio({super.key});

  @override
  State<AdminFluteRatio> createState() => _AdminFluteRatioState();
}

class _AdminFluteRatioState extends State<AdminFluteRatio> {
  late Future<List<AdminFluteRatioModel>> futureFluteRatio;
  final userController = Get.find<UserController>();
  final themeController = Get.find<ThemeController>();

  List<AdminFluteRatioModel> updatedFluteRatio = [];
  List<AdminFluteRatioModel> draftFluteRatio = [];
  List<AdminFluteRatioModel> tableData = [];
  List<int> isSelected = [];
  int? selectedFluteRatioId;
  bool selectedAll = false;

  @override
  void initState() {
    super.initState();

    if (userController.hasAnyRole(roles: ["admin"])) {
      loadFluteRatio();
    } else {
      futureFluteRatio = Future.error("NO_PERMISSION");
    }
  }

  void loadFluteRatio() {
    setState(() {
      futureFluteRatio = AdminService().getAllFluteRatio();
    });

    isSelected.clear();
  }

  @override
  Widget build(BuildContext context) {
    final bool isAccept = userController.hasAnyRole(roles: ["admin"]);

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
                          "ĐỘ CAO SÓNG",
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
                    child:
                        isAccept
                            ? Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                //left
                                const SizedBox(),

                                //right
                                Container(
                                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                                  child: Row(
                                    children: [
                                      //add
                                      AnimatedButton(
                                        onPressed: () {
                                          setState(() {
                                            final newRow = AdminFluteRatioModel(
                                              fluteRatioId: null,
                                              fluteName: '',
                                              ratio: 0,
                                              isDraft: true,
                                            );

                                            tableData.insert(0, newRow);
                                            draftFluteRatio.add(newRow);
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
                                                        e.fluteRatioId == null &&
                                                        e.fluteName.trim().isNotEmpty &&
                                                        e.ratio > 0,
                                                  )
                                                  .toList();

                                          // CASE UPDATE: row có id + được chọn
                                          final rowsToUpdate =
                                              tableData
                                                  .where(
                                                    (e) =>
                                                        e.fluteRatioId != null &&
                                                        isSelected.contains(e.fluteRatioId),
                                                  )
                                                  .toList();

                                          // check tick checkbox
                                          final hasUpdateRow = tableData.any(
                                            (e) => e.fluteRatioId != null,
                                          );

                                          if (rowsToAdd.isEmpty &&
                                              hasUpdateRow &&
                                              rowsToUpdate.isEmpty) {
                                            showSnackBarError(
                                              context,
                                              "Chưa chọn dòng cần cập nhật",
                                            );
                                            return;
                                          }

                                          // ================== ADD ==================
                                          for (final e in rowsToAdd) {
                                            await AdminService().addFluteRatio(
                                              fluteRatioData: {
                                                "fluteName": e.fluteName,
                                                "ratio": e.ratio,
                                              },
                                            );
                                          }

                                          // ================== UPDATE ==================
                                          for (final e in rowsToUpdate) {
                                            await AdminService().updateFluteRatio(
                                              fluteRatioId: e.fluteRatioId!,
                                              fluteRatioUpdate: {
                                                "fluteName": e.fluteName,
                                                "ratio": e.ratio,
                                              },
                                            );
                                          }

                                          setState(() {
                                            tableData.clear();
                                            draftFluteRatio.clear();
                                            isSelected.clear();
                                            selectedAll = false;
                                          });

                                          loadFluteRatio();

                                          if (!context.mounted) return;
                                          showSnackBarSuccess(
                                            context,
                                            "Đã lưu thay đổi thành công",
                                          );
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
                                                              borderRadius: BorderRadius.circular(
                                                                16,
                                                              ),
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
                                                                      style: TextStyle(
                                                                        fontSize: 16,
                                                                      ),
                                                                    ),
                                                            actions:
                                                                isDeleting
                                                                    ? []
                                                                    : [
                                                                      TextButton(
                                                                        onPressed:
                                                                            () => Navigator.pop(
                                                                              context,
                                                                            ),
                                                                        child: const Text(
                                                                          "Huỷ",
                                                                          style: TextStyle(
                                                                            fontSize: 16,
                                                                            fontWeight:
                                                                                FontWeight.bold,
                                                                            color: Colors.black54,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      ElevatedButton(
                                                                        style: ElevatedButton.styleFrom(
                                                                          backgroundColor:
                                                                              const Color(
                                                                                0xffEA4346,
                                                                              ),
                                                                          foregroundColor:
                                                                              Colors.white,
                                                                          shape: RoundedRectangleBorder(
                                                                            borderRadius:
                                                                                BorderRadius.circular(
                                                                                  8,
                                                                                ),
                                                                          ),
                                                                        ),
                                                                        onPressed: () async {
                                                                          setStateDialog(() {
                                                                            isDeleting = true;
                                                                          });

                                                                          for (int id
                                                                              in isSelected) {
                                                                            await AdminService()
                                                                                .deleteFluteRatio(
                                                                                  fluteRatioId: id,
                                                                                );
                                                                          }

                                                                          await Future.delayed(
                                                                            const Duration(
                                                                              seconds: 1,
                                                                            ),
                                                                          );

                                                                          if (!context.mounted) {
                                                                            return;
                                                                          }

                                                                          setState(() {
                                                                            isSelected.clear();
                                                                            tableData.clear();
                                                                          });

                                                                          loadFluteRatio();

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
                                                                            fontWeight:
                                                                                FontWeight.bold,
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
                              ],
                            )
                            : const SizedBox.shrink(),
                  ),
                ],
              ),
            ),

            //table
            Expanded(
              child: SizedBox(
                width: double.infinity,
                child: FutureBuilder<List<AdminFluteRatioModel>>(
                  future: futureFluteRatio,
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
                          "Không có đơn hàng nào",
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
                        ),
                      );
                    }

                    if (snapshot.hasData && tableData.isEmpty) {
                      tableData =
                          snapshot.data!
                              .map(
                                (e) => AdminFluteRatioModel(
                                  fluteRatioId: e.fluteRatioId,
                                  fluteName: e.fluteName,
                                  ratio: e.ratio,
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
                                              .map((e) => e.fluteRatioId)
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
                          DataColumn(label: styleText("Tên Sóng")),
                          DataColumn(label: styleText("Độ Cao Sóng")),
                        ],
                        rows: List<DataRow>.generate(tableData.length, (index) {
                          final fluteRatio = tableData[index];
                          return DataRow(
                            key: ValueKey(fluteRatio.fluteRatioId ?? fluteRatio.hashCode),
                            color:
                                fluteRatio.fluteRatioId == null
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
                                        fluteRatio.fluteRatioId != null &&
                                        isSelected.contains(fluteRatio.fluteRatioId),

                                    onChanged:
                                        fluteRatio.fluteRatioId == null
                                            ? null
                                            : (val) {
                                              setState(() {
                                                if (val == true) {
                                                  isSelected.add(fluteRatio.fluteRatioId!);
                                                } else {
                                                  isSelected.remove(fluteRatio.fluteRatioId);
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
                                  text: fluteRatio.fluteName.toString(),
                                  onChanged: (value) {
                                    setState(() {
                                      fluteRatio.fluteName = value;
                                    });
                                  },
                                ),
                              ),
                              DataCell(
                                styleCellAdmin(
                                  text: fluteRatio.ratio.toString(),
                                  onChanged: (value) {
                                    setState(() {
                                      fluteRatio.ratio = double.tryParse(value) ?? 0;
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
        () =>
            isAccept
                ? FloatingActionButton(
                  onPressed: loadFluteRatio,
                  backgroundColor: themeController.buttonColor.value,
                  child: const Icon(Icons.refresh, color: Colors.white),
                )
                : const SizedBox.shrink(),
      ),
    );
  }
}
