import 'package:dongtam/data/models/admin/qcInspection/admin_inspection_paper.dart';
import 'package:dongtam/presentation/components/shared/cardForm/building_card_form.dart';
import 'package:dongtam/presentation/components/shared/cardForm/format_key_value_card.dart';
import 'package:dongtam/service/admin_service.dart';
import 'package:dongtam/utils/helper/reponsive/reponsive_dialog.dart';
import 'package:dongtam/utils/validation/validation_helper.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

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
  Map<String, bool?> checkedCriteria = {};

  Map<String, num> checking = {};
  Map<String, bool> errProgress = {};

  final numberPalletController = TextEditingController();
  final machineSpeedController = TextEditingController();
  final moistureController = TextEditingController();
  final steamPressureController = TextEditingController();
  final preheaterTempController = TextEditingController();
  final fctValueController = TextEditingController();
  final patValueController = TextEditingController();

  @override
  void initState() {
    super.initState();
    futureCriteria = AdminService().getAllCriteriaCheck(
      isPaper: widget.isPaper,
      fromJson: (json) => AdminInspectionPaperModel.fromJson(json),
    );
  }

  // check REQUIRED criteria
  bool get isAllChecked {
    if (criteriaList.isEmpty) return false;
    return criteriaList
        .where((e) => e.isRequired == true)
        .every((e) => checkedCriteria[e.criteriaPaperCode] != null);
  }

  void submit() {}

  @override
  void dispose() {
    super.dispose();
    numberPalletController.dispose();
    machineSpeedController.dispose();
    moistureController.dispose();
    steamPressureController.dispose();
    preheaterTempController.dispose();
    fctValueController.dispose();
    patValueController.dispose();
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

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text("Không có tiêu chí nào"));
        }

        criteriaList = snapshot.data!;

        // Khởi tạo trạng thái ban đầu (Đồng bộ dùng criteriaPaperCode làm Key)
        for (var item in criteriaList) {
          checkedCriteria.putIfAbsent(item.criteriaPaperCode, () => null);
        }

        // TÁCH DATA THÀNH 2 NỬA DỌC (Trái và Phải)
        int halfLength = (criteriaList.length / 2).ceil();
        List<AdminInspectionPaperModel> leftList = criteriaList.take(halfLength).toList();
        List<AdminInspectionPaperModel> rightList = criteriaList.skip(halfLength).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(bottom: 16, left: 4),
              child: Text(
                "Tiêu chí đánh giá lỗi",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87),
              ),
            ),

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: buildMinimalTable(leftList)),
                const SizedBox(width: 18),
                Expanded(
                  child:
                      rightList.isNotEmpty ? buildMinimalTable(rightList) : const SizedBox.shrink(),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        );
      },
    );
  }

  // Hàm helper để render từng bảng độc lập
  Widget buildMinimalTable(List<AdminInspectionPaperModel> list) {
    // Kiểm tra xem tất cả item trong nửa bảng này đã được tick Chọn hết chưa
    bool isAllSelected =
        list.isNotEmpty && list.every((item) => checkedCriteria[item.criteriaPaperCode] == true);

    return Table(
      columnWidths: const {
        0: FixedColumnWidth(95), // Đủ chỗ cho cụm 2 nút tròn ✓ và ✕
        1: FlexColumnWidth(3), // Tên tiêu chí
        2: FlexColumnWidth(1.2), // Sai số
      },
      border: TableBorder(
        horizontalInside: BorderSide(color: Colors.grey.shade300, width: 1),
        bottom: BorderSide(color: Colors.grey.shade300, width: 1),
      ),
      children: [
        // HEADER BẢNG
        TableRow(
          decoration: BoxDecoration(
            color: Color.fromARGB(255, 250, 235, 148),
            border: Border(bottom: BorderSide(color: Colors.grey.shade300, width: 1.5)),
          ),
          children: [
            TableCell(
              verticalAlignment: TableCellVerticalAlignment.middle,
              child: Container(
                height: 40,
                padding: const EdgeInsets.only(left: 10),
                alignment: Alignment.centerLeft,
                child: InkWell(
                  onTap: () {
                    setState(() {
                      final newStatus = isAllSelected ? null : true;
                      for (var item in list) {
                        checkedCriteria[item.criteriaPaperCode] = newStatus;
                      }
                    });
                  },
                  child: Row(
                    children: [
                      Icon(
                        isAllSelected ? Icons.check_circle : Icons.check_circle_outline,
                        size: 17,
                        color: isAllSelected ? Colors.green : Colors.grey.shade600,
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        "Hết",
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            TableCell(
              verticalAlignment: TableCellVerticalAlignment.middle,
              child: Container(
                height: 40,
                alignment: Alignment.centerLeft,
                child: const Text(
                  "TIÊU CHÍ KIỂM TRA",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, letterSpacing: 0.5),
                ),
              ),
            ),
            TableCell(
              verticalAlignment: TableCellVerticalAlignment.middle,
              child: Container(
                height: 40,
                padding: const EdgeInsets.only(right: 12),
                alignment: Alignment.centerRight,
                child: const Text(
                  "SAI SỐ CHO PHÉP",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, letterSpacing: 0.5),
                ),
              ),
            ),
          ],
        ),

        // CÁC DÒNG TIÊU CHÍ CHI TIẾT
        ...list.map((item) {
          final currentRes = checkedCriteria[item.criteriaPaperCode];
          final isPass = currentRes == true; // Trạng thái dấu Check (✓)
          final isFail = currentRes == false; // Trạng thái dấu X (✕)

          // Đổi màu nền nhẹ nhàng theo trạng thái true / false
          Color rowBgColor = Colors.white;
          if (isPass) rowBgColor = Colors.green.shade50.withValues(alpha: 0.25);
          if (isFail) rowBgColor = Colors.red.shade50.withValues(alpha: 0.35);

          return TableRow(
            decoration: BoxDecoration(color: rowBgColor),
            children: [
              // 1. CỤM NÚT TRÒN (✓) VÀ (✕) SONG SONG
              TableCell(
                child: Container(
                  height: 46,
                  padding: const EdgeInsets.only(left: 6),
                  child: Row(
                    children: [
                      // Nút Dấu Check (✓) -> Gán true
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          setState(() {
                            checkedCriteria[item.criteriaPaperCode] = isPass ? null : true;
                          });
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 120),
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: isPass ? Colors.green : Colors.transparent,
                              border: Border.all(
                                color: isPass ? Colors.green : Colors.grey.shade400,
                                width: 1.5,
                              ),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.check,
                              size: 13,
                              color: isPass ? Colors.white : Colors.grey.shade400,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 3),

                      // Nút Dấu X (✕) -> Gán false
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          setState(() {
                            checkedCriteria[item.criteriaPaperCode] = isFail ? null : false;
                          });
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 120),
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: isFail ? Colors.red : Colors.transparent,
                              border: Border.all(
                                color: isFail ? Colors.red : Colors.grey.shade400,
                                width: 1.5,
                              ),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.close,
                              size: 13,
                              color: isFail ? Colors.white : Colors.grey.shade400,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 2. TÊN TIÊU CHÍ QC
              TableCell(
                child: InkWell(
                  onTap: () {
                    setState(() {
                      checkedCriteria[item.criteriaPaperCode] = isPass ? null : true;
                    });
                  },
                  child: Container(
                    height: 44,
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.only(right: 8),
                    child: RichText(
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      text: TextSpan(
                        text: item.criteriaPaperName,
                        style: TextStyle(
                          fontSize: 16,
                          color:
                              isFail
                                  ? Colors.red.shade800
                                  : (isPass ? Colors.green.shade800 : Colors.black87),
                          fontWeight: (isPass || isFail) ? FontWeight.bold : FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // 3. SAI SỐ CHO PHÉP (Fix lỗi Null Safety triệt để bằng cách check kĩ item.variance)
              TableCell(
                child: Container(
                  height: 44,
                  padding: const EdgeInsets.only(right: 8),
                  alignment: Alignment.centerRight,
                  child: Text(
                    item.variance > 0 ? "±${item.variance} mm" : "—",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: (isPass || isFail) ? FontWeight.bold : FontWeight.w500,
                      color:
                          item.variance > 0
                              ? (isFail
                                  ? Colors.red.shade800
                                  : (isPass ? Colors.green.shade800 : Colors.black54))
                              : Colors.grey.shade400,
                    ),
                  ),
                ),
              ),
            ],
          );
        }),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> inspectionRows = [
      {
        "leftKey": "Số Pallet",
        "leftValue": ValidationHelper.qcInspectionInput(
          label: "Số Pallet",
          controller: numberPalletController,
          icon: Symbols.package,
        ),
        "middleKey": "Tốc Độ Máy",
        "middleValue": ValidationHelper.qcInspectionInput(
          label: "Tốc Độ Máy",
          controller: machineSpeedController,
          icon: Symbols.speed,
        ),
        "rightKey": "Áp Suất Hơi",
        "rightValue": ValidationHelper.qcInspectionInput(
          label: "Áp Suất Hơi",
          controller: steamPressureController,
          icon: Symbols.thermostat,
        ),
      },

      {
        "leftKey": "Độ Ẩm",
        "leftValue": ValidationHelper.qcInspectionInput(
          label: "Độ Ẩm",
          controller: moistureController,
          icon: Symbols.water_drop,
        ),
        "middleKey": "Nhiệt Độ",
        "middleValue": ValidationHelper.qcInspectionInput(
          label: "Nhiệt Độ Đầu Sóng",
          controller: preheaterTempController,
          icon: Symbols.thermostat_auto,
        ),
        "rightKey": "",
        "rightValue": const SizedBox.shrink(),
      },

      {
        "leftKey": "FCT Nén Ngang",
        "leftValue": ValidationHelper.qcInspectionInput(
          label: "FCT Nén Ngang",
          controller: fctValueController,
          icon: Symbols.speed,
        ),
        "middleKey": "PAT Bám Keo",
        "middleValue": ValidationHelper.qcInspectionInput(
          label: "PAT Bám Keo",
          controller: patValueController,
          icon: Symbols.speed,
        ),
        "rightKey": "",
        "rightValue": const SizedBox.shrink(),
      },
    ];

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
        width: ResponsiveSize.getWidth(context, ResponsiveType.xLarge),
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Form(
            key: formKey,
            child: Column(
              children: [
                //criteria list
                buildQcContent(),

                //input user
                buildingCard(
                  title: "📃 Thông Tin Kiểm Tra",
                  children: formatKeyValueRows(
                    rows: inspectionRows,
                    labelWidth: 120,
                    columnCount: 4,
                    centerAlign: true,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),

      //button
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
            "Xác Nhận",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Colors.white),
          ),
        ),
      ],
    );
  }
}
