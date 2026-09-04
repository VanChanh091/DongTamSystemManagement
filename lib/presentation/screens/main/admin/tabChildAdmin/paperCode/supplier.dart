import 'package:dongtam/data/controller/theme_controller.dart';
import 'package:dongtam/data/controller/user_controller.dart';
import 'package:dongtam/data/models/admin/paperCode/supplier_model.dart';
import 'package:dongtam/presentation/components/shared/animation/animated_button.dart';
import 'package:dongtam/presentation/components/shared/dialog_shared.dart';
import 'package:dongtam/service/admin/admin_paper_code_service.dart';
import 'package:dongtam/utils/handleError/show_snack_bar.dart';
import 'package:dongtam/utils/helper/style_table.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:material_symbols_icons/symbols.dart';

class Supplier extends StatefulWidget {
  const Supplier({super.key});

  @override
  State<Supplier> createState() => _SupplierState();
}

class _SupplierState extends State<Supplier> {
  late Future<List<SupplierModel>> futureSupplier;

  final userController = Get.find<UserController>();
  final themeController = Get.find<ThemeController>();

  int? selectedSupplier;
  bool selectedAll = false;

  List<int> isSelected = [];
  List<SupplierModel> updatedSuppliers = [];

  List<SupplierModel> tableData = [];
  List<SupplierModel> draftSuppliers = [];

  @override
  void initState() {
    super.initState();

    if (userController.hasAnyRole(roles: ["admin"])) {
      loadSupplier();
    } else {
      futureSupplier = Future.error("NO_PERMISSION");
    }
  }

  void loadSupplier() {
    setState(() {
      tableData.clear();
      draftSuppliers.clear();
      futureSupplier = AdminPaperCodeService().getAllSuppliers();
    });

    isSelected.clear();
    selectedAll = false;
  }

  @override
  Widget build(BuildContext context) {
    final bool isAdmin = userController.hasAnyRole(roles: ["admin"]);

    return Scaffold(
      backgroundColor: themeController.backgroundColor.value, // Nền xám nhạt giúp bảng nổi bật
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // title & buttons
          Container(padding: const EdgeInsets.all(12), child: _buildHeaderBar(isAdmin)),

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
        () =>
            isAdmin
                ? FloatingActionButton(
                  onPressed: loadSupplier,
                  backgroundColor: themeController.buttonColor.value,
                  child: const Icon(Icons.refresh, color: Colors.white),
                )
                : SizedBox.shrink(),
      ),
    );
  }

  Widget _buildHeaderBar(bool isAdmin) {
    return Column(
      children: [
        Text(
          "DANH SÁCH NHÀ CUNG CẤP",
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
              //left
              const SizedBox(),

              //right
              Row(
                children: [
                  //add
                  AnimatedButton(
                    onPressed: () {
                      setState(() {
                        final newRow = SupplierModel(
                          supplierId: null,
                          supplierName: "",
                          supplierCode: "",
                          transferCode: "",
                          grade: 0,
                          isActive: true,
                          isDraft: true,
                        );

                        tableData.insert(0, newRow);
                        draftSuppliers.add(newRow);
                      });
                    },

                    label: "Thêm dòng",
                    icon: Icons.add,
                    backgroundColor: themeController.buttonColor,
                  ),
                  const SizedBox(width: 10),

                  //update
                  AnimatedButton(
                    onPressed: () async {
                      // CASE ADD: row mới (draft, chưa có id)
                      final rowsToAdd =
                          tableData
                              .where(
                                (e) =>
                                    e.isDraft &&
                                    e.supplierId == null &&
                                    e.supplierName.trim().isNotEmpty &&
                                    e.supplierCode.trim().isNotEmpty &&
                                    e.transferCode.trim().isNotEmpty &&
                                    e.isActive == true,
                              )
                              .toList();

                      // CASE UPDATE: row có id + được chọn
                      final rowsToUpdate =
                          tableData
                              .where(
                                (e) => e.supplierId != null && isSelected.contains(e.supplierId),
                              )
                              .toList();

                      // check tick checkbox
                      final hasUpdateRow = tableData.any((e) => e.supplierId != null);

                      if (rowsToAdd.isEmpty && hasUpdateRow && rowsToUpdate.isEmpty) {
                        showSnackBarError(context, "Chưa chọn dòng cần cập nhật");
                        return;
                      }

                      final service = AdminPaperCodeService();

                      Map<String, dynamic> toPayload(dynamic item) => {
                        "supplierName": item.supplierName,
                        "supplierCode": item.supplierCode,
                        "transferCode": item.transferCode,
                        "grade": item.grade,
                      };

                      await Future.wait([
                        ...rowsToAdd.map((e) => service.createSupplier(supplierData: toPayload(e))),
                        ...rowsToUpdate.map(
                          (e) => service.handleUpdateSupplier(
                            supplierId: e.supplierId!,
                            supplierUpdate: toPayload(e),
                            action: "UPDATE_SUPPLIER",
                          ),
                        ),
                      ]);

                      setState(() {
                        tableData.clear();
                        draftSuppliers.clear();
                        isSelected.clear();
                        selectedAll = false;
                      });

                      loadSupplier();

                      if (mounted) {
                        showSnackBarSuccess(context, "Đã lưu thay đổi thành công");
                      }
                    },

                    label: "Lưu Thay Đổi",
                    icon: Symbols.save,
                    backgroundColor: themeController.buttonColor,
                  ),
                  const SizedBox(width: 8),

                  AnimatedButton(
                    onPressed: () async {
                      if (isSelected.isEmpty) {
                        showSnackBarError(context, "Chưa chọn nhà cung cấp để thay đổi trạng thái");
                        return;
                      }

                      if (isSelected.length > 1) {
                        showSnackBarError(
                          context,
                          "Chỉ được chọn 1 nhà cung cấp để thay đổi trạng thái",
                        );
                        return;
                      }

                      final confirm = await showConfirmDialog(
                        context: context,
                        title: "Thay đổi trạng thái nhà cung cấp",
                        content: "Xác nhận thay đổi trạng thái của nhà cung cấp đã chọn không?",
                        confirmText: "Xác nhận",
                      );

                      if (confirm) {
                        await AdminPaperCodeService().handleUpdateSupplier(
                          supplierId: isSelected.first,
                          action: "TOGGLE_ACTIVE",
                        );

                        if (mounted) {
                          showSnackBarSuccess(context, "Đã thay đổi trạng thái thành công");
                          loadSupplier();
                        }
                      }
                    },
                    label: "Đổi Trạng Thái",
                    icon: Icons.change_circle,
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
    return FutureBuilder<List<SupplierModel>>(
      future: futureSupplier,
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
                    (e) => SupplierModel(
                      supplierId: e.supplierId,
                      supplierName: e.supplierName,
                      supplierCode: e.supplierCode,
                      transferCode: e.transferCode,
                      grade: e.grade,
                      isActive: e.isActive,
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
                          isSelected = tableData.map((e) => e.supplierId).whereType<int>().toList();
                        } else {
                          isSelected.clear();
                        }
                      });
                    },
                  ),
                ),
              ),
              DataColumn(label: styleText("Tên Nhà Cung Cấp")),
              DataColumn(label: styleText("Mã Nhà Cung Cấp")),
              DataColumn(label: styleText("Mã Chuyển Đổi")),
              DataColumn(label: styleText("Cấp Độ")),
              DataColumn(label: styleText("Trạng Thái")),
            ],
            rows: List<DataRow>.generate(tableData.length, (index) {
              final supplier = tableData[index];

              return DataRow(
                key: ValueKey(supplier.supplierId ?? supplier.hashCode),
                color:
                    supplier.supplierId == null
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
                            supplier.supplierId != null && isSelected.contains(supplier.supplierId),
                        onChanged:
                            supplier.supplierId == null
                                ? null
                                : (val) {
                                  setState(() {
                                    if (val == true) {
                                      isSelected.add(supplier.supplierId!);
                                    } else {
                                      isSelected.remove(supplier.supplierId);
                                    }
                                    selectedAll = isSelected.length == snapshot.data!.length;
                                  });
                                },
                      ),
                    ),
                  ),
                  DataCell(
                    styleCellAdmin(
                      text: supplier.supplierName,
                      onChanged: (value) {
                        supplier.supplierName = value;
                      },
                    ),
                  ),
                  DataCell(
                    styleCellAdmin(
                      text: supplier.supplierCode,
                      onChanged: (value) {
                        supplier.supplierCode = value;
                      },
                    ),
                  ),
                  DataCell(
                    styleCellAdmin(
                      text: supplier.transferCode,
                      onChanged: (value) {
                        supplier.transferCode = value;
                      },
                    ),
                  ),
                  DataCell(
                    styleCellAdmin(
                      text: supplier.grade.toString(),
                      onChanged: (value) {
                        supplier.grade = int.tryParse(value) ?? 0;
                      },
                    ),
                  ),
                  DataCell(
                    styleCellAdmin(
                      text: (supplier.isActive ?? true) ? "Hoạt động" : "Ngưng hoạt động",
                      onChanged: (value) {
                        supplier.isActive = value.toLowerCase() == "hoạt động";
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
