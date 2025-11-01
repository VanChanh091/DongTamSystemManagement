import 'package:dongtam/data/controller/theme_controller.dart';
import 'package:dongtam/data/controller/user_controller.dart';
import 'package:dongtam/data/models/admin/admin_waste_box_model.dart';
import 'package:dongtam/service/admin_service.dart';
import 'package:dongtam/utils/helper/animated_button.dart';
import 'package:dongtam/utils/helper/style_table.dart';
import 'package:dongtam/utils/handleError/show_snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

class AdminWasteBox extends StatefulWidget {
  const AdminWasteBox({super.key});

  @override
  State<AdminWasteBox> createState() => _AdminWasteBoxState();
}

class _AdminWasteBoxState extends State<AdminWasteBox> {
  late Future<List<AdminWasteBoxModel>> futureAdminWasteNorm;
  final userController = Get.find<UserController>();
  final themeController = Get.find<ThemeController>();
  int? selectedWasteNorm;
  List<int> isSelected = [];
  List<AdminWasteBoxModel> updatedWasteNorms = [];
  bool selectedAll = false;

  @override
  void initState() {
    super.initState();

    if (userController.hasAnyRole(roles: ["admin"])) {
      loadWasteBox();
    } else {
      futureAdminWasteNorm = Future.error("NO_PERMISSION");
    }
  }

  void loadWasteBox() {
    setState(() {
      futureAdminWasteNorm = AdminService().getAllWasteBox();
    });
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
                          "ĐỊNH MỨC PHẾ LIỆU THÙNG",
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
                                      // update
                                      AnimatedButton(
                                        onPressed: () async {
                                          if (isSelected.isEmpty) {
                                            showSnackBarError(
                                              context,
                                              "Chưa chọn thông tin cần cập nhật",
                                            );
                                            return;
                                          }

                                          final dataToUpdate =
                                              updatedWasteNorms
                                                  .where(
                                                    (item) => isSelected.contains(item.wasteBoxId),
                                                  )
                                                  .toList();

                                          for (final item in dataToUpdate) {
                                            // print(
                                            //   '⏫ Updating wasteNormId: ${item.wasteBoxId}',
                                            // );

                                            await AdminService().updateWasteBoxById(
                                              wasteNormId: item.wasteBoxId,
                                              wasteNormUpdate: {
                                                "colorNumberOnProduct": item.colorNumberOnProduct,
                                                "paperNumberOnProduct": item.paperNumberOnProduct,
                                                "totalLossOnTotalQty": item.totalLossOnTotalQty,
                                                "machineName": item.machineName,
                                              },
                                            );
                                          }

                                          if (!context.mounted) return;

                                          loadWasteBox();

                                          showSnackBarSuccess(context, 'Đã cập nhật thành công');
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
                                                                                .deleteWasteBoxById(
                                                                                  wasteNormId: id,
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
                                                                            futureAdminWasteNorm =
                                                                                AdminService()
                                                                                    .getAllWasteBox();
                                                                          });

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
                child: FutureBuilder<List<AdminWasteBoxModel>>(
                  future: futureAdminWasteNorm,
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

                    final data = snapshot.data!;
                    updatedWasteNorms = data;

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
                                      isSelected = data.map((e) => e.wasteBoxId).toList();
                                    } else {
                                      isSelected.clear();
                                    }
                                  });
                                },
                              ),
                            ),
                          ),
                          DataColumn(label: styleText("Số Màu Lên Bài")),
                          DataColumn(label: styleText("Số Tờ Lên Bài")),
                          DataColumn(label: styleText("Hao Phí Trên Tổng SL")),
                          DataColumn(label: styleText("Loại Máy")),
                        ],
                        rows: List<DataRow>.generate(data.length, (index) {
                          final wasteNorm = data[index];
                          return DataRow(
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
                                    value: isSelected.contains(wasteNorm.wasteBoxId),
                                    onChanged: (val) {
                                      setState(() {
                                        if (val == true) {
                                          isSelected.add(wasteNorm.wasteBoxId);
                                        } else {
                                          isSelected.remove(wasteNorm.wasteBoxId);
                                        }

                                        selectedAll = isSelected.length == data.length;
                                      });
                                    },
                                  ),
                                ),
                              ),
                              DataCell(
                                styleCellAdmin(
                                  text: wasteNorm.colorNumberOnProduct.toString(),
                                  onChanged: (value) {
                                    setState(() {
                                      wasteNorm.colorNumberOnProduct = int.tryParse(value) ?? 0;
                                    });
                                  },
                                ),
                              ),
                              DataCell(
                                styleCellAdmin(
                                  text: wasteNorm.paperNumberOnProduct.toString(),
                                  onChanged: (value) {
                                    setState(() {
                                      wasteNorm.paperNumberOnProduct = int.tryParse(value) ?? 0;
                                    });
                                  },
                                ),
                              ),
                              DataCell(
                                styleCellAdmin(
                                  text: '${wasteNorm.totalLossOnTotalQty.toString()}%',
                                  onChanged: (value) {
                                    setState(() {
                                      wasteNorm.totalLossOnTotalQty = double.tryParse(value) ?? 0;
                                    });
                                  },
                                ),
                              ),
                              DataCell(
                                styleCellAdmin(
                                  text: wasteNorm.machineName.toString(),
                                  onChanged: null,
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
                  onPressed: loadWasteBox,
                  backgroundColor: themeController.buttonColor.value,
                  child: const Icon(Icons.refresh, color: Colors.white),
                )
                : SizedBox.shrink(),
      ),
    );
  }
}
