import 'package:dongtam/data/models/planning/planning_paper_model.dart';
import 'package:dongtam/service/manufacture_service.dart';
import 'package:dongtam/utils/helper/reponsive/reponsive_dialog.dart';
import 'package:dongtam/utils/handleError/show_snack_bar.dart';
import 'package:flutter/material.dart';

class DialogAddReportWaste extends StatefulWidget {
  final List<PlanningPaper> planning;
  final VoidCallback onUpdatePlanning;

  const DialogAddReportWaste({super.key, required this.planning, required this.onUpdatePlanning});

  @override
  State<DialogAddReportWaste> createState() => _DialogAddReportWasteState();
}

class _DialogAddReportWasteState extends State<DialogAddReportWaste> {
  final formKey = GlobalKey<FormState>();
  late List<int> planningIds = [];

  final lengthManuController = TextEditingController();

  @override
  void initState() {
    super.initState();
    planningIds = widget.planning.map((p) => p.planningId).toList();
  }

  void submit() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    try {
      await ManufactureService().reportWasteNormPaper(
        planningId: planningIds,
        qtyWasteNorm: double.parse(lengthManuController.text),
        action: 'REPORT_WASTE_NORM',
      );

      if (mounted) {
        showSnackBarSuccess(context, 'Báo cáo phế liệu cho các đơn hàng thành công');

        widget.onUpdatePlanning();
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        showSnackBarError(context, 'Lỗi: Không thể lưu dữ liệu');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(
      builder: (context, state) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          content: SizedBox(
            width: ResponsiveSize.getWidth(context, ResponsiveType.small),
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      "Báo Cáo Phế Liệu",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                    ),
                    const SizedBox(height: 10),

                    // Danh sách Order đã chọn
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(10),
                      margin: const EdgeInsets.only(bottom: 15),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade400),
                      ),
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Đơn hàng cần báo cáo:",
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            const SizedBox(height: 5),

                            ...widget.planning.map(
                              (p) => Padding(
                                padding: const EdgeInsets.symmetric(vertical: 2.0),
                                child: Row(
                                  children: [
                                    const Text("- Mã đơn hàng: ", style: TextStyle(fontSize: 16)),
                                    Text(
                                      p.orderId,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: Colors.red,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 15),

                            //input
                            TextFormField(
                              controller: lengthManuController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: "Nhập số lượng phế liệu",
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(10)),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Vui lòng nhập số lượng phế liệu';
                                }
                                if (double.tryParse(value) == null) {
                                  return 'Vui lòng nhập một số hợp lệ';
                                }
                                if (double.parse(value) < 0) {
                                  return 'Số lượng phế liệu không được âm';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 8),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          actionsPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                "Hủy",
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black54),
              ),
            ),
            ElevatedButton(
              onPressed: submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text(
                "Xác Nhận",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }
}
