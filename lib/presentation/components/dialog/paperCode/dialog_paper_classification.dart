import "package:dongtam/data/controller/theme_controller.dart";
import "package:dongtam/data/models/admin/paperCode/paper_basis_weight_model.dart";
import "package:dongtam/data/models/admin/paperCode/paper_classification_model.dart";
import "package:dongtam/data/models/admin/paperCode/supplier_paper_code_model.dart";
import "package:dongtam/data/models/order/order_model.dart";
import "package:dongtam/presentation/components/shared/cardForm/building_card_form.dart";
import "package:dongtam/presentation/components/shared/cardForm/format_key_value_card.dart";
import "package:dongtam/presentation/components/shared/dialog_shared.dart";
import "package:dongtam/presentation/components/shared/resizable_dialog.dart";
import "package:dongtam/service/admin/admin_paper_code_service.dart";
import "package:dongtam/utils/handleError/show_snack_bar.dart";
import "package:dongtam/utils/helper/reponsive/reponsive_dialog.dart";
import "package:dongtam/utils/validation/validation_helper.dart";
import "package:flutter/material.dart";
import "package:get/get.dart";

class PaperClassificationDialog extends StatefulWidget {
  final bool isEdit;
  final List<PaperClassificationModel>? initialData;
  final VoidCallback onSuccess;

  const PaperClassificationDialog({
    super.key,
    this.isEdit = false,
    this.initialData,
    required this.onSuccess,
  });

  @override
  State<PaperClassificationDialog> createState() => _PaperClassificationDialogState();
}

class _PaperClassificationDialogState extends State<PaperClassificationDialog> {
  final _service = AdminPaperCodeService();
  final themeController = Get.find<ThemeController>();

  int? editingIndex;
  String? loadError;
  bool isLoadingData = true;

  SupplierPaperCodeModel? selectedSupplierPaper;
  PaperBasisWeightModel? selectedBasisWeight;

  final TextEditingController burstRatioController = TextEditingController();
  final TextEditingController burstStrengthController = TextEditingController();
  final TextEditingController ringCrushController = TextEditingController();
  final TextEditingController pricePaperController = TextEditingController();

  List<SupplierPaperCodeModel> supplierPaperList = [];
  List<PaperBasisWeightModel> basisWeightList = [];
  List<PaperClassificationModel> draftRows = [];

  @override
  void initState() {
    super.initState();
    _fetchInitialData();
  }

  @override
  void dispose() {
    burstRatioController.dispose();
    burstStrengthController.dispose();
    ringCrushController.dispose();
    pricePaperController.dispose();
    super.dispose();
  }

  Future<void> _fetchInitialData() async {
    try {
      final results = await Future.wait([
        _service.getAllSupplierPaperCodes(),
        _service.getAllBasisWeights(),
      ]);

      if (mounted) {
        setState(() {
          supplierPaperList = results[0] as List<SupplierPaperCodeModel>;
          basisWeightList = results[1] as List<PaperBasisWeightModel>;

          // Sao chép dữ liệu truyền vào nếu có
          if (widget.initialData != null && widget.initialData!.isNotEmpty) {
            draftRows =
                widget.initialData!.map((e) {
                  return PaperClassificationModel(
                    classificationId: e.classificationId,
                    paperCode: e.paperCode,
                    weightCategory: e.weightCategory,
                    burstRatio: e.burstRatio,
                    burstStrength: e.burstStrength,
                    ringCrush: e.ringCrush,
                    pricePaper: e.pricePaper,
                    supplierPaperId: e.supplierPaperId,
                    basisWeightId: e.basisWeightId,
                    supplierPaper: e.supplierPaper,
                    basisWeight: e.basisWeight,
                  );
                }).toList();

            // Đổ dòng đầu tiên lên form ngay khi mở
            _loadRowToForm(0);
          } else {
            // Trường hợp Thêm Mới: Lấy giá trị đầu tiên làm mặc định
            if (supplierPaperList.isNotEmpty) selectedSupplierPaper = supplierPaperList.first;
            if (basisWeightList.isNotEmpty) selectedBasisWeight = basisWeightList.first;
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

  void _loadRowToForm(int index) {
    if (index < 0 || index >= draftRows.length) return;
    final item = draftRows[index];

    setState(() {
      editingIndex = index;
      selectedSupplierPaper =
          supplierPaperList.firstWhereOrNull((s) => s.supplierPaperId == item.supplierPaperId) ??
          (supplierPaperList.isNotEmpty ? supplierPaperList.first : null);

      selectedBasisWeight =
          basisWeightList.firstWhereOrNull((b) => b.basisWeightId == item.basisWeightId) ??
          (basisWeightList.isNotEmpty ? basisWeightList.first : null);

      burstRatioController.text = item.burstRatio != null ? item.burstRatio.toString() : "";
      burstStrengthController.text =
          item.burstStrength != null ? item.burstStrength.toString() : "";
      ringCrushController.text = item.ringCrush != null ? item.ringCrush.toString() : "";
      pricePaperController.text = item.pricePaper != null ? item.pricePaper.toString() : "";
    });
  }

  void _clearInputs() {
    burstRatioController.clear();
    burstStrengthController.clear();
    ringCrushController.clear();
    pricePaperController.clear();
  }

  void _addOrUpdateDraftRow() {
    if (selectedSupplierPaper == null) {
      showSnackBarError(context, "Vui lòng chọn Cấu hình Giấy NCC");
      return;
    }
    if (selectedBasisWeight == null) {
      showSnackBarError(context, "Vui lòng chọn Định lượng");
      return;
    }

    final double? burstRatio = double.tryParse(burstRatioController.text.trim());
    final double? burstStrength = double.tryParse(burstStrengthController.text.trim());
    final double? ringCrush = double.tryParse(ringCrushController.text.trim());
    final double? pricePaper = double.tryParse(pricePaperController.text.trim());

    final newRow = PaperClassificationModel(
      classificationId: editingIndex != null ? draftRows[editingIndex!].classificationId : 0,
      paperCode: editingIndex != null ? draftRows[editingIndex!].paperCode : "",
      weightCategory: editingIndex != null ? draftRows[editingIndex!].weightCategory : "",
      supplierPaperId: selectedSupplierPaper!.supplierPaperId,
      basisWeightId: selectedBasisWeight!.basisWeightId ?? 0,
      burstRatio: burstRatio,
      burstStrength: burstStrength,
      ringCrush: ringCrush,
      pricePaper: pricePaper,
      supplierPaper: selectedSupplierPaper,
      basisWeight: selectedBasisWeight,
    );

    setState(() {
      if (editingIndex != null) {
        draftRows[editingIndex!] = newRow;
        editingIndex = null;
      } else {
        draftRows.add(newRow);
      }
      _clearInputs();
    });
  }

  void _cancelEditing() {
    setState(() {
      editingIndex = null;
      _clearInputs();
    });
  }

  void _removeDraftRow(int index) {
    setState(() {
      if (editingIndex == index) {
        editingIndex = null;
        _clearInputs();
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
        success = await _service.updatePaperClassification(paperClassificationData: payload);
      } else {
        success = await _service.createPaperClassification(paperClassificationData: payload);
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
    final List<Map<String, dynamic>> classificationInfoRows = [
      {
        "leftKey": "Cấu hình Giấy NCC",
        "leftValue": ValidationHelper.dropdownForTypes<SupplierPaperCodeModel>(
          items: supplierPaperList,
          type: selectedSupplierPaper,
          itemLabelBuilder: (s) {
            final supplierName = s.Supplier?.supplierName ?? "NCC ${s.supplierId}";
            final supplierCode = s.Supplier?.supplierCode ?? "";
            final paperName = s.PaperType?.paperName ?? "Loại giấy";
            final paperCode = s.PaperType?.paperCode ?? "";
            return "$supplierName ($supplierCode) - $paperName ($paperCode)";
          },
          onChanged: (val) => setState(() => selectedSupplierPaper = val),
        ),
        "rightKey": "Định Lượng",
        "rightValue": ValidationHelper.dropdownForTypes<PaperBasisWeightModel>(
          items: basisWeightList,
          type: selectedBasisWeight,
          itemLabelBuilder: (b) => "${b.basisWeight} gsm",
          onChanged: (val) => setState(() => selectedBasisWeight = val),
        ),
      },
      {
        "leftKey": "Tỉ Lệ Độ Bục",
        "leftValue": ValidationHelper.paperClassificationInput(
          label: "Tỉ Lệ Độ Bục",
          icon: Icons.numbers,
          controller: burstRatioController,
        ),
        "rightKey": "Độ Bục",
        "rightValue": ValidationHelper.paperClassificationInput(
          label: "Độ Bục",
          icon: Icons.numbers,
          controller: burstStrengthController,
        ),
      },
      {
        "leftKey": "Độ Nén Vòng",
        "leftValue": ValidationHelper.paperClassificationInput(
          label: "Độ Nén Vòng",
          icon: Icons.numbers,
          controller: ringCrushController,
        ),
        "rightKey": "Giá Giấy",
        "rightValue": ValidationHelper.paperClassificationInput(
          label: "Giá Giấy",
          icon: Icons.numbers,
          controller: pricePaperController,
        ),
      },
    ];

    return ResizableDialog(
      initialWidth: ResponsiveSize.getWidth(context, ResponsiveType.large),
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
                          title: "Thông Tin Phân Loại Giấy",
                          children: formatKeyValueRows(
                            rows: classificationInfoRows,
                            columnCount: 2,
                            labelWidth: 130,
                            centerAlign: true,
                          ),
                        ),
                        const SizedBox(height: 8),
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
                const Text(
                  "📋 DANH SÁCH DỮ LIỆU ĐÃ NHẬP",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                if (draftRows.isNotEmpty)
                  TextButton.icon(
                    onPressed:
                        () => setState(() {
                          draftRows.clear();
                          editingIndex = null;
                          _clearInputs();
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
                                  "Mã NCC",
                                  "Tên NCC",
                                  "Tên Giấy",
                                  "Mã Giấy",
                                  "Định Lượng",
                                  "Tỉ Lệ Độ Bục",
                                  "Độ Bục",
                                  "Độ Nén Vòng",
                                  "Giá Giấy",
                                  "Thao tác",
                                ]),
                                rows: List.generate(draftRows.length, (index) {
                                  final item = draftRows[index];
                                  final supplierPaper =
                                      item.supplierPaper ??
                                      supplierPaperList.firstWhereOrNull(
                                        (s) => s.supplierPaperId == item.supplierPaperId,
                                      );
                                  final basisWeight =
                                      item.basisWeight ??
                                      basisWeightList.firstWhereOrNull(
                                        (b) => b.basisWeightId == item.basisWeightId,
                                      );

                                  final supplier = supplierPaper?.Supplier;
                                  final paperType = supplierPaper?.PaperType;

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
                                        supplier?.supplierCode,
                                        supplier?.supplierName,
                                        paperType?.paperName,
                                        paperType?.paperCode,
                                        basisWeight != null
                                            ? "${basisWeight.basisWeight} gsm"
                                            : "-",
                                        item.burstRatio ?? "-",
                                        item.burstStrength ?? "-",
                                        item.ringCrush ?? "-",
                                        item.pricePaper != null
                                            ? OrderModel.formatCurrency(item.pricePaper!)
                                            : "-",
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
          style: const TextStyle(fontSize: 14),
          softWrap: false,
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
      );
    }).toList();
  }
}
