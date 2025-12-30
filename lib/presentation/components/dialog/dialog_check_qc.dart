import 'package:dongtam/data/models/admin/qc_criteria_model.dart';
import 'package:dongtam/data/models/qualityControl/qc_sample_submit_model.dart';
import 'package:dongtam/service/admin/admin_criteria_service.dart';
import 'package:dongtam/service/quality_control_service.dart';
import 'package:dongtam/utils/handleError/api_exception.dart';
import 'package:dongtam/utils/handleError/show_snack_bar.dart';
import 'package:dongtam/utils/helper/confirm_dialog.dart';
import 'package:dongtam/utils/helper/reponsive_size.dart';
import 'package:dongtam/utils/logger/app_logger.dart';
import 'package:flutter/material.dart';

class DialogCheckQC extends StatefulWidget {
  final int? planningId, planningBoxId;
  final VoidCallback onQcSessionAddOrUpdate;
  final String type;

  const DialogCheckQC({
    super.key,
    this.planningId,
    this.planningBoxId,
    required this.onQcSessionAddOrUpdate,
    required this.type,
  });

  @override
  State<DialogCheckQC> createState() => _DialogCheckQcPaperState();
}

class _DialogCheckQcPaperState extends State<DialogCheckQC> {
  late Future<List<QcCriteriaModel>> futureCriteria;

  final formKey = GlobalKey<FormState>();
  final TextEditingController qtyController = TextEditingController();

  List<QcCriteriaModel> criteriaList = [];
  Map<int, Map<String, bool>> samples = {};
  String? inboundQtyError;

  @override
  void initState() {
    super.initState();

    futureCriteria = AdminCriteriaService().getAllQcCriteria(type: widget.type);
  }

  // check REQUIRED criteria
  bool get isAllChecked {
    if (samples.isEmpty) return false;

    return samples.values.every((sample) {
      return criteriaList.where((c) => c.isRequired).every((c) => sample[c.criteriaCode] == true);
    });
  }

  bool isRowAllChecked(Map<String, bool> checklist) {
    return criteriaList.every((c) => checklist[c.criteriaCode] == true);
  }

  void submit() async {
    if (!formKey.currentState!.validate()) {
      AppLogger.w("Form không hợp lệ, dừng submit");
      return;
    }

    try {
      AppLogger.i("Thêm phiên kiểm tra mới cho ${widget.type == 'paper' ? "giấy" : "thùng"}");

      final submitSamples =
          samples.entries.map((entry) {
            return QcSampleSubmitModel(sampleIndex: entry.key, checklist: entry.value);
          }).toList();

      await QualityControlService().submitQC(
        inboundQty: int.parse(qtyController.text),
        processType: widget.type,
        planningId: widget.planningId,
        planningBoxId: widget.planningBoxId,
        totalSample: submitSamples.length,
        samples: submitSamples,
      );

      // clear lỗi
      setState(() => inboundQtyError = null);

      // Show loading
      if (!mounted) return;
      showLoadingDialog(context);
      await Future.delayed(const Duration(seconds: 1));

      if (!mounted) return;
      Navigator.pop(context); // đóng dialog loading

      // Thông báo thành công
      showSnackBarSuccess(context, "Báo cáo thành công");

      widget.onQcSessionAddOrUpdate();

      if (!mounted) return;
      Navigator.of(context).pop(); //đóng dialog QC
    } on ApiException catch (e) {
      setState(() {
        inboundQtyError = switch (e.errorCode) {
          'INBOUND_EXCEED_PRODUCED' => 'Số lượng nhập kho vượt quá số lượng sản xuất',
          _ => null,
        };
      });
    } catch (e, s) {
      if (!mounted) return;
      AppLogger.e("Lỗi khi thêm phiên QC", error: e, stackTrace: s);
      showSnackBarError(context, 'Lỗi: Không thể lưu dữ liệu');
    }
  }

  // ===== CONTENT =====
  Widget buildQcContent() {
    return FutureBuilder<List<QcCriteriaModel>>(
      future: futureCriteria,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(20),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return const Center(child: Text("Lỗi tải tiêu chí QC"));
        }

        criteriaList = snapshot.data!;

        if (samples.isEmpty) {
          // init 3 samples dựa trên criteria từ API
          samples = {
            for (int i = 1; i <= 3; i++) i: {for (final c in criteriaList) c.criteriaCode: false},
          };
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [buildQcTable(), const SizedBox(height: 24), buildQtyInput()],
        );
      },
    );
  }

  // ===== TABLE QC =====
  Widget buildQcTable() {
    return Table(
      border: TableBorder.all(color: Colors.grey.shade400),
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      children: [
        /// HEADER
        TableRow(
          decoration: BoxDecoration(color: Colors.grey.shade200),
          children: [
            const Padding(
              padding: EdgeInsets.all(10),
              child: Text(
                "Các Tiêu Chí",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            ...criteriaList.map(
              (c) => Padding(
                padding: const EdgeInsets.all(10),
                child: Text(
                  c.criteriaName,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ),
          ],
        ),

        /// BODY
        ...samples.entries.map((entry) {
          final sampleIndex = entry.key;
          final checklist = entry.value;

          return TableRow(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Mẫu $sampleIndex",
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(width: 6),
                    Checkbox(
                      value: isRowAllChecked(checklist),
                      activeColor: Colors.green,
                      checkColor: Colors.white,
                      onChanged: (val) {
                        setState(() {
                          for (final c in criteriaList) {
                            checklist[c.criteriaCode] = val ?? false;
                          }
                        });
                      },
                    ),
                  ],
                ),
              ),

              ...criteriaList.map(
                (c) => Center(
                  child: Checkbox(
                    activeColor: Colors.green,
                    checkColor: Colors.white,
                    value: checklist[c.criteriaCode],
                    onChanged: (val) {
                      setState(() {
                        checklist[c.criteriaCode] = val ?? false;
                      });
                    },
                  ),
                ),
              ),
            ],
          );
        }),
      ],
    );
  }

  // ===== QTY INPUT =====
  Widget buildQtyInput() {
    final enabled = isAllChecked;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text("SL Nhập Kho:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(width: 16),
        Expanded(
          child: TextFormField(
            controller: qtyController,
            enabled: enabled,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: "Nhập số lượng",
              filled: true,
              fillColor: enabled ? Colors.white : Colors.grey.shade200,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              errorText: inboundQtyError,
            ),
            validator: (value) {
              if (!enabled) return null;
              if (value == null || value.isEmpty) {
                return "Vui lòng nhập số lượng";
              }

              final qty = int.tryParse(value);
              if (qty == null) {
                return "Chỉ chấp nhận số nguyên";
              }

              if (qty <= 0) {
                return "Số lượng phải lớn hơn 0";
              }
              return null;
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      title: const Center(
        child: Text(
          "Kiểm tra chất lượng giấy",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
      ),
      content: SizedBox(
        width: ResponsiveSize.getWidth(context, ResponsiveType.large),
        child: SingleChildScrollView(child: Form(key: formKey, child: buildQcContent())),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(
            "Hủy",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black54),
          ),
        ),
        ElevatedButton(
          onPressed: isAllChecked ? submit : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: const Text(
            "Nhập kho",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Colors.white),
          ),
        ),
      ],
    );
  }
}
