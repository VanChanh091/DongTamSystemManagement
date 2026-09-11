import 'package:dongtam/data/controller/theme_controller.dart';
import 'package:dongtam/data/models/admin/paperCode/paper_type_model.dart';
import 'package:dongtam/data/models/admin/paperCode/supplier_model.dart';
import 'package:dongtam/data/models/admin/paperCode/supplier_paper_code_model.dart';
import 'package:dongtam/presentation/components/shared/cardForm/building_card_form.dart';
import 'package:dongtam/presentation/components/shared/cardForm/format_key_value_card.dart';
import 'package:dongtam/presentation/components/shared/dialog_shared.dart';
import 'package:dongtam/presentation/components/shared/resizable_dialog.dart';
import 'package:dongtam/service/admin/admin_paper_code_service.dart';
import 'package:dongtam/utils/handleError/show_snack_bar.dart';
import 'package:dongtam/utils/helper/reponsive/reponsive_dialog.dart';
import 'package:dongtam/utils/validation/validation_helper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SupplierPaperCodeDialog extends StatefulWidget {
  final bool isEdit;
  final List<SupplierPaperCodeModel>? initialData;
  final VoidCallback onSuccess;

  const SupplierPaperCodeDialog({
    super.key,
    this.isEdit = false,
    this.initialData,
    required this.onSuccess,
  });

  @override
  State<SupplierPaperCodeDialog> createState() => _SupplierPaperCodeDialogState();
}

class _SupplierPaperCodeDialogState extends State<SupplierPaperCodeDialog> {
  final _service = AdminPaperCodeService();
  final themeController = Get.find<ThemeController>();

  int? editingIndex;
  String? loadError;
  bool isLoadingData = true;

  SupplierModel? selectedSupplier;
  PaperTypeModel? selectedPaperType;

  List<SupplierModel> suppliersList = [];
  List<PaperTypeModel> paperTypesList = [];
  List<SupplierPaperCodeModel> draftRows = [];

  String selectedLayerType = "LINER";
  final List<Map<String, String>> layerTypeOptions = [
    {"value": "LINER", "label": "Giấy Mặt"},
    {"value": "FLUTE", "label": "Giấy Sóng"},
  ];

  @override
  void initState() {
    super.initState();
    _fetchInitialData();
  }

  Future<void> _fetchInitialData() async {
    try {
      final results = await Future.wait([_service.getAllSuppliers(), _service.getAllPaperTypes()]);

      if (mounted) {
        setState(() {
          suppliersList = results[0] as List<SupplierModel>;
          paperTypesList = results[1] as List<PaperTypeModel>;

          // Sao chép dữ liệu truyền vào
          if (widget.initialData != null && widget.initialData!.isNotEmpty) {
            draftRows =
                widget.initialData!.map((e) {
                  return SupplierPaperCodeModel(
                    supplierPaperId: e.supplierPaperId,
                    layerType: e.layerType,
                    supplierId: e.supplierId,
                    paperTypeId: e.paperTypeId,
                    Supplier: e.Supplier,
                    PaperType: e.PaperType,
                  );
                }).toList();

            // Đổ dòng đầu tiên lên form ngay khi mở
            _loadRowToForm(0);
          } else {
            // Trường hợp Thêm Mới: Lấy giá trị đầu tiên làm mặc định
            if (suppliersList.isNotEmpty) selectedSupplier = suppliersList.first;
            if (paperTypesList.isNotEmpty) selectedPaperType = paperTypesList.first;
          }

          isLoadingData = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          loadError = e.toString();
          isLoadingData = false;
        });
      }
    }
  }

  // Đổ dữ liệu từ 1 dòng dưới bảng lên các ô nhập liệu
  void _loadRowToForm(int index) {
    if (index < 0 || index >= draftRows.length) return;
    final item = draftRows[index];

    setState(() {
      editingIndex = index;
      selectedSupplier =
          suppliersList.firstWhereOrNull((s) => s.supplierId == item.supplierId) ??
          (suppliersList.isNotEmpty ? suppliersList.first : null);

      selectedPaperType =
          paperTypesList.firstWhereOrNull((p) => p.paperTypeId == item.paperTypeId) ??
          (paperTypesList.isNotEmpty ? paperTypesList.first : null);

      selectedLayerType = item.layerType;
    });
  }

  // Xử lý thêm mới hoặc cập nhật dòng
  void _addOrUpdateDraftRow() {
    if (selectedSupplier == null) {
      showSnackBarError(context, "Vui lòng chọn Nhà cung cấp");
      return;
    }
    if (selectedPaperType == null) {
      showSnackBarError(context, "Vui lòng chọn Loại giấy");
      return;
    }

    final newRow = SupplierPaperCodeModel(
      supplierPaperId: editingIndex != null ? draftRows[editingIndex!].supplierPaperId : 0,
      layerType: selectedLayerType,
      supplierId: selectedSupplier!.supplierId ?? 0,
      paperTypeId: selectedPaperType!.paperTypeId ?? 0,
      Supplier: selectedSupplier,
      PaperType: selectedPaperType,
    );

    setState(() {
      if (editingIndex != null) {
        draftRows[editingIndex!] = newRow;
        editingIndex = null; // Hoàn tất chỉnh sửa
      } else {
        draftRows.add(newRow);
      }
    });
  }

  void _cancelEditing() {
    setState(() {
      editingIndex = null;
    });
  }

  void _removeDraftRow(int index) {
    setState(() {
      if (editingIndex == index) {
        editingIndex = null;
      } else if (editingIndex != null && editingIndex! > index) {
        editingIndex = editingIndex! - 1;
      }
      draftRows.removeAt(index);
    });
  }

  Future<void> _submit() async {
    if (draftRows.isEmpty) {
      showSnackBarError(context, "Vui lòng thêm ít nhất một dòng dữ liệu vào bảng");
      return;
    }

    showLoadingDialog(context, message: "Đang lưu dữ liệu...");

    try {
      final payload = draftRows.map((e) => e.toJson()).toList();

      bool success = false;
      if (widget.isEdit) {
        success = await _service.updateSupplierPaperCode(supplierPaperCodeData: payload);
      } else {
        success = await _service.createSupplierPaperCode(supplierPaperCodeData: payload);
      }

      if (mounted) Navigator.pop(context);

      if (success) {
        if (mounted) {
          showSnackBarSuccess(
            context,
            widget.isEdit ? "Cập nhật dữ liệu thành công" : "Thêm mới dữ liệu thành công",
          );
          widget.onSuccess();
          Navigator.pop(context);
        }
      } else {
        if (mounted) {
          showSnackBarError(context, "Không thể lưu dữ liệu, vui lòng kiểm tra lại");
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        showSnackBarError(context, "Lỗi: ${e.toString()}");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> supplierPaperInfoRows = [
      {
        "leftKey": "Nhà cung cấp",
        "leftValue": ValidationHelper.dropdownForTypes<SupplierModel>(
          items: suppliersList,
          type: selectedSupplier,
          itemLabelBuilder: (s) => "${s.supplierName} (${s.supplierCode})",
          onChanged: (val) => setState(() => selectedSupplier = val),
        ),
      },
      {
        "leftKey": "Loại Giấy",
        "leftValue": ValidationHelper.dropdownForTypes<PaperTypeModel>(
          items: paperTypesList,
          type: selectedPaperType,
          itemLabelBuilder: (p) => "${p.paperName} (${p.paperCode})",
          onChanged: (val) => setState(() => selectedPaperType = val),
        ),
      },
      {
        "leftKey": "Loại Lớp Giấy",
        "leftValue": ValidationHelper.dropdownForTypes<String>(
          items: layerTypeOptions.map((opt) => opt["value"]!).toList(),
          type: selectedLayerType,
          itemLabelBuilder: (val) {
            final found = layerTypeOptions.firstWhere(
              (opt) => opt["value"] == val,
              orElse: () => {"label": val},
            );
            return found["label"] ?? val;
          },
          onChanged: (val) {
            if (val != null) {
              setState(() => selectedLayerType = val);
            }
          },
        ),
      },
    ];

    return ResizableDialog(
      initialWidth: ResponsiveSize.getWidth(context, ResponsiveType.medium),
      // minWidth: 650,
      // maxWidth: 1000,
      // minHeight: 500,
      title: Center(
        child: Text(
          widget.isEdit ? "Cập nhật Phân Loại Giấy" : "Thêm mới Phân Loại Giấy",
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
      ),

      actions: buildDialogActions(
        context: context,
        onConfirm: _submit,
        confirmText: widget.isEdit ? "Cập nhật" : "Lưu tất cả",
      ),

      child:
          isLoadingData
              ? const Center(child: CircularProgressIndicator())
              : loadError != null
              ? Center(child: Text("Lỗi tải dữ liệu: $loadError"))
              : Column(
                children: [
                  // ----------------- FORM -----------------
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        buildingCard(
                          title: "Thông Tin Cấu Hình",
                          children: formatKeyValueRows(
                            rows: supplierPaperInfoRows,
                            columnCount: 1,
                            labelWidth: 150,
                            centerAlign: true,
                          ),
                        ),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            if (editingIndex != null) ...[
                              TextButton(
                                onPressed: _cancelEditing,
                                child: const Text(
                                  "Hủy sửa dòng",
                                  style: TextStyle(color: Colors.black),
                                ),
                              ),
                              const SizedBox(width: 8),
                            ],
                            ElevatedButton.icon(
                              onPressed: _addOrUpdateDraftRow,
                              icon: Icon(
                                editingIndex != null ? Icons.check : Icons.add,
                                color: Colors.white,
                                size: 18,
                              ),
                              label: Text(
                                editingIndex != null ? "Cập Nhật Dòng" : "Thêm Vào Bảng",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    editingIndex != null
                                        ? Colors.orange.shade800
                                        : Colors.blue.shade700,
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // ----------------- TABLE -----------------
                  Expanded(child: _buildDraftTableSection()),
                ],
              ),
    );
  }

  Widget _buildDraftTableSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            color: Colors.grey.shade100,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "📋 DANH SÁCH DỮ LIỆU ĐÃ NHẬP",
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                if (draftRows.isNotEmpty)
                  TextButton.icon(
                    onPressed:
                        () => setState(() {
                          draftRows.clear();
                          editingIndex = null;
                        }),
                    icon: const Icon(Icons.delete_sweep, size: 18, color: Colors.red),
                    label: const Text(
                      "Xóa tất cả",
                      style: TextStyle(color: Colors.red, fontSize: 13),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child:
                draftRows.isEmpty
                    ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.inbox_outlined, size: 36, color: Colors.grey),
                          SizedBox(height: 6),
                          Text(
                            "Chưa có dữ liệu. Hãy chọn ở trên và bấm nút thêm vào bảng",
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 13,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    )
                    : LayoutBuilder(
                      builder: (context, constraints) {
                        return SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: ConstrainedBox(
                              constraints: BoxConstraints(minWidth: constraints.maxWidth),
                              child: DataTable(
                                headingRowHeight: 34,
                                dataRowMinHeight: 34,
                                dataRowMaxHeight: 38,
                                columnSpacing: 18,
                                headingRowColor: WidgetStateProperty.all(
                                  themeController.currentColor.value.withValues(alpha: 0.1),
                                ),

                                columns: buildDataColumns([
                                  "STT",
                                  "Mã NCC",
                                  "Tên NCC",
                                  "Loại Giấy",
                                  "Tên Giấy",
                                  "Mã Giấy",
                                  "Thao tác",
                                ]),

                                rows: List.generate(draftRows.length, (index) {
                                  final item = draftRows[index];
                                  final supplier =
                                      item.Supplier ??
                                      suppliersList.firstWhereOrNull(
                                        (s) => s.supplierId == item.supplierId,
                                      );
                                  final paperType =
                                      item.PaperType ??
                                      paperTypesList.firstWhereOrNull(
                                        (p) => p.paperTypeId == item.paperTypeId,
                                      );

                                  final layerLabel =
                                      item.layerType == "LINER" ? "Giấy Mặt" : "Giấy Sóng";

                                  final isEditing = editingIndex == index;

                                  return DataRow(
                                    selected: isEditing,
                                    onSelectChanged: (selected) {
                                      if (selected != null) {
                                        _loadRowToForm(index);
                                      }
                                    },
                                    color: WidgetStateProperty.resolveWith<Color?>((states) {
                                      if (isEditing) {
                                        return Colors.orange.withValues(alpha: 0.15);
                                      }
                                      return null;
                                    }),
                                    cells: [
                                      ...buildTextCells([
                                        index + 1,
                                        supplier?.supplierCode,
                                        supplier?.supplierName,
                                        layerLabel,
                                        paperType?.paperName,
                                        paperType?.paperCode,
                                      ]),
                                      DataCell(
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            IconButton(
                                              icon: const Icon(
                                                Icons.delete,
                                                color: Colors.redAccent,
                                                size: 18,
                                              ),
                                              onPressed: () => _removeDraftRow(index),
                                              tooltip: "Xóa dòng này",
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  );
                                }),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }

  List<DataColumn> buildDataColumns(List<String> titles) {
    return titles
        .map(
          (title) =>
              DataColumn(label: Text(title, style: const TextStyle(fontWeight: FontWeight.bold))),
        )
        .toList();
  }

  List<DataCell> buildTextCells(List<dynamic> values) {
    return values.map((val) {
      final text = (val == null || val.toString().trim().isEmpty) ? "-" : val.toString();
      return DataCell(
        Text(
          text,
          style: TextStyle(fontSize: 14),
          softWrap: false,
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
      );
    }).toList();
  }
}
