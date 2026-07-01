import 'package:dongtam/data/models/admin/qcInspection/admin_inspection_paper.dart';
import 'package:dongtam/service/admin_service.dart';
import 'package:dongtam/utils/helper/reponsive/reponsive_dialog.dart';
import 'package:flutter/material.dart';

class DialogInspectionCheck extends StatefulWidget {
  final String? machine;
  final bool isPaper;
  final int planningId;
  final VoidCallback onSubmit;

  const DialogInspectionCheck({
    super.key,
    required this.onSubmit,
    required this.isPaper,
    required this.planningId,
    this.machine,
  });

  @override
  State<DialogInspectionCheck> createState() => _DialogInspectionCheckState();
}

class _DialogInspectionCheckState extends State<DialogInspectionCheck> {
  final formKey = GlobalKey<FormState>();
  late Future<List<AdminInspectionPaperModel>> futureCriteria;

  List<AdminInspectionPaperModel> criteriaList = [];
  Map<String, num> checking = {};
  Map<String, bool> errProgress = {};

  @override
  void initState() {
    super.initState();
    futureCriteria = AdminService().getAllCriteriaCheck(
      isPaper: widget.isPaper,
      fromJson: (json) => AdminInspectionPaperModel.fromJson(json),
    );
  }

  // check REQUIRED criteria
  // bool get isAllChecked {
  //   if (samples.isEmpty) return false;

  //   return samples.values.every((sample) {
  //     return criteriaList
  //         .where((c) => c.isRequired)
  //         .every((c) => sample[c.criteriaPaperCode] == true);
  //   });
  // }

  void submit() {}

  @override
  void dispose() {
    super.dispose();
  }

  // ===== CONTENT =====
  Widget buildQcContent() {
    return FutureBuilder<List<AdminInspectionPaperModel>>(
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

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          // children: [buildQcTable(), const SizedBox(height: 24), buildQtyInput()],
        );
      },
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
        // ElevatedButton(
        //   onPressed: isAllChecked ? submit : null,
        //   style: ElevatedButton.styleFrom(
        //     backgroundColor: Colors.red,
        //     padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        //     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        //   ),
        //   child: const Text(
        //     "Xác Nhận",
        //     style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Colors.white),
        //   ),
        // ),
      ],
    );
  }
}
