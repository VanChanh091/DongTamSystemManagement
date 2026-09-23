import "package:dongtam/data/controller/user_controller.dart";
import "package:dongtam/data/models/admin/qcInspection/admin_inspection_box.dart";
import "package:dongtam/data/models/admin/qcInspection/admin_inspection_paper.dart";
import "package:dongtam/data/models/admin/qcInspection/inspection_ui_model.dart";
import "package:dongtam/presentation/components/shared/cardForm/building_card_form.dart";
import "package:dongtam/presentation/components/shared/cardForm/format_key_value_card.dart";
import "package:dongtam/presentation/components/shared/dialog_shared.dart";
import "package:dongtam/presentation/components/shared/resizable_dialog.dart";
import "package:dongtam/service/admin/admin_service.dart";
import "package:dongtam/service/quality_control_service.dart";
import "package:dongtam/utils/extension/extension_helper.dart";
import "package:dongtam/utils/handleError/show_snack_bar.dart";
import "package:dongtam/utils/helper/reponsive/reponsive_dialog.dart";
import "package:dongtam/utils/logger/app_logger.dart";
import "package:dongtam/utils/validation/validation_helper.dart";
import "package:flutter/material.dart";
import "package:get/get.dart";
import "package:material_symbols_icons/symbols.dart";

class DialogInspectionCheck extends StatefulWidget {
  final bool isQC;
  final bool isPaper;
  final String? machine;
  final int? planningId;
  final int? planningBoxId;
  final VoidCallback onSubmit;

  const DialogInspectionCheck({
    super.key,
    this.machine,
    this.planningId,
    this.planningBoxId,
    required this.isQC,
    required this.isPaper,
    required this.onSubmit,
  });

  @override
  State<DialogInspectionCheck> createState() => _DialogInspectionCheckState();
}

class _DialogInspectionCheckState extends State<DialogInspectionCheck> {
  final formKey = GlobalKey<FormState>();
  late Future<List<InspectionUiModel>> futureCriteria;

  final userController = Get.find<UserController>();
  late bool isAdmin;

  List<InspectionUiModel> criteriaList = [];
  Map<String, bool?> checkedCriteria = {};

  Map<String, num> checking = {};
  Map<String, bool> errProgress = {};

  Map<String, dynamic>? savedErrorData;
  bool _isDataFilled = false;

  final _moistureController = TextEditingController();
  final _steamPressureController = TextEditingController();
  final _preheaterTempController = TextEditingController();
  final _fctValueController = TextEditingController();
  final _patValueController = TextEditingController();
  final _noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    isAdmin = userController.hasAnyRole(roles: ["admin"]);
    futureCriteria = _fetchCriteriaData();
  }

  Future<List<InspectionUiModel>> _fetchCriteriaData() async {
    if (!widget.isQC) {
      try {
        savedErrorData = await QualityControlService().getQcInspectionErr<Map<String, dynamic>>(
          isPaper: widget.isPaper ? "paper" : "box",
          planningId: widget.planningId ?? 0,
          planningBoxId: widget.planningBoxId ?? 0,
          machine: widget.machine ?? "",
          fromJson: (json) => json,
        );
        if (savedErrorData != null) {
          if (savedErrorData!["note"] != null) {
            _noteController.text = savedErrorData!["note"].toString();
          }
          if (widget.isPaper) {
            if (savedErrorData!["moisture"] != null) {
              _moistureController.text = savedErrorData!["moisture"].toString();
            }
            if (savedErrorData!["steamPressure"] != null) {
              _steamPressureController.text = savedErrorData!["steamPressure"].toString();
            }
            if (savedErrorData!["preheaterTemp"] != null) {
              _preheaterTempController.text = savedErrorData!["preheaterTemp"].toString();
            }
            if (savedErrorData!["fctValue"] != null) {
              _fctValueController.text = savedErrorData!["fctValue"].toString();
            }
            if (savedErrorData!["patValue"] != null) {
              _patValueController.text = savedErrorData!["patValue"].toString();
            }
          }
        }
      } catch (e, s) {
        // Nếu lỗi hoặc không có data cũ, cứ cho qua để tải tiếp danh sách tiêu chí bên dưới
        AppLogger.e("Lỗi khi lấy dữ liệu lỗi cũ", error: e, stackTrace: s);
        savedErrorData = null;
      }
    }

    if (widget.isPaper) {
      final List<AdminInspectionPaperModel> data = await AdminService().getAllCriteriaCheck(
        isPaper: true,
        fromJson: (json) => AdminInspectionPaperModel.fromJson(json),
      );

      return data
          .map(
            (e) => InspectionUiModel(
              criteriaCode: e.criteriaPaperCode,
              criteriaName: e.criteriaPaperName,
              variance: e.variance,
              isRequired: e.isRequired,
            ),
          )
          .toList();
    } else {
      final List<AdminInspectionBoxModel> data = await AdminService().getAllCriteriaCheck(
        isPaper: false,
        machine: widget.machine,
        fromJson: (json) => AdminInspectionBoxModel.fromJson(json),
      );

      return data
          .map(
            (e) => InspectionUiModel(
              criteriaCode: e.criteriaBoxCode,
              criteriaName: e.criteriaBoxName,
              variance: e.variance,
              isRequired: false,
              machine: e.machine,
            ),
          )
          .toList();
    }
  }

  // check REQUIRED criteria
  bool get isAllChecked {
    if (criteriaList.isEmpty) return false;

    if (widget.isPaper) {
      return criteriaList
          .where((e) => e.isRequired == true)
          .every((e) => checkedCriteria[e.criteriaCode] != null);
    } else {
      return criteriaList.every((e) => checkedCriteria[e.criteriaCode] != null);
    }
  }

  void submit() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    // Show loading
    if (!mounted) return;
    showLoadingDialog(context);
    await Future.delayed(const Duration(seconds: 1));

    try {
      Map<String, bool> errProgressData = {};
      checkedCriteria.forEach((key, value) {
        errProgressData[key] = value ?? true; //true là pass, false là fail, null là chưa check
      });

      Map<String, num> checkingData = {};
      if (widget.isPaper) {
        checkingData = {
          "moisture": double.tryParse(_moistureController.text) ?? 0.0,
          "steamPressure": double.tryParse(_steamPressureController.text) ?? 0.0,
          "preheaterTemp": double.tryParse(_preheaterTempController.text) ?? 0.0,
          "fctValue": double.tryParse(_fctValueController.text) ?? 0.0,
          "patValue": double.tryParse(_patValueController.text) ?? 0.0,
        };
      }

      bool success = await QualityControlService().checkingInspection(
        isPaper: widget.isPaper ? "paper" : "box",
        machine: widget.machine ?? "",
        errProgress: errProgressData,
        checking: widget.isPaper ? checkingData : null,
        planningId: widget.isPaper ? widget.planningId : null,
        planningBoxId: !widget.isPaper ? widget.planningBoxId : null,
        note: _noteController.superClean,
      );

      if (success) {
        if (!mounted) return;
        Navigator.pop(context); // đóng dialog loading

        // Thông báo thành công
        showSnackBarSuccess(context, "Báo cáo thành công");
        widget.onSubmit();

        if (!mounted) return;
        Navigator.of(context).pop(); //đóng dialog QC
      }
    } catch (e, s) {
      if (!mounted) return;
      AppLogger.e("Lỗi khi đánh giá tiến trình sản xuất", error: e, stackTrace: s);
      showSnackBarError(context, "Lỗi: Không thể lưu dữ liệu");
    }
  }

  @override
  void dispose() {
    super.dispose();
    _moistureController.dispose();
    _steamPressureController.dispose();
    _preheaterTempController.dispose();
    _fctValueController.dispose();
    _patValueController.dispose();
    _noteController.dispose();
  }

  // ===== CONTENT =====
  Widget buildQcContent() {
    return FutureBuilder<List<InspectionUiModel>>(
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

        if (!_isDataFilled) {
          if (savedErrorData != null) {
            final savedCheckList = savedErrorData!["checkList"];
            if (savedCheckList is Map) {
              savedCheckList.forEach((key, value) {
                checkedCriteria[key] = value as bool?;
              });
            }
          } else {
            // Nếu đơn hàng sạch, chưa có lỗi cũ -> Khởi tạo Map trống như ban đầu
            for (var item in criteriaList) {
              checkedCriteria.putIfAbsent(item.criteriaCode, () => null);
            }
          }
          _isDataFilled = true; // Khóa lại
        }

        // Khởi tạo trạng thái ban đầu (Đồng bộ dùng criteriaCode làm Key)
        for (var item in criteriaList) {
          checkedCriteria.putIfAbsent(item.criteriaCode, () => null);
        }

        // TÁCH DATA THÀNH 2 NỬA DỌC (Trái và Phải)
        int halfLength = (criteriaList.length / 2).ceil();
        List<InspectionUiModel> leftList = criteriaList.take(halfLength).toList();
        List<InspectionUiModel> rightList = criteriaList.skip(halfLength).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(bottom: 16, left: 4),
              child: Text(
                "Tiêu chí đánh giá lỗi: ${widget.machine}",
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
  Widget buildMinimalTable(List<InspectionUiModel> list) {
    // Kiểm tra xem tất cả item trong nửa bảng này đã được tick Chọn hết chưa
    bool isAllSelected =
        list.isNotEmpty && list.every((item) => checkedCriteria[item.criteriaCode] == true);

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
                child:
                    isAdmin
                        ? InkWell(
                          onTap: () {
                            setState(() {
                              final newStatus = isAllSelected ? null : true;
                              for (var item in list) {
                                checkedCriteria[item.criteriaCode] = newStatus;
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
                        )
                        : const Text(
                          "ĐẠT / LỖI",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            letterSpacing: 0.5,
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
                  "SAI SỐ",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, letterSpacing: 0.5),
                ),
              ),
            ),
          ],
        ),

        // CÁC DÒNG TIÊU CHÍ CHI TIẾT
        ...list.map((item) {
          final currentRes = checkedCriteria[item.criteriaCode];
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
                            checkedCriteria[item.criteriaCode] = isPass ? null : true;
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
                            checkedCriteria[item.criteriaCode] = isFail ? null : false;
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
                      checkedCriteria[item.criteriaCode] = isPass ? null : true;
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
                        text: item.criteriaName,
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

              // 3. SAI SỐ CHO PHÉP
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
    final isQC = widget.isQC;
    final bool isReadOnly = !isQC;

    final List<Map<String, dynamic>> inspectionRows = [
      if (widget.isPaper) ...[
        {
          "leftKey": "Độ Ẩm",
          "leftValue": ValidationHelper.qcInspectionInput(
            label: "Độ Ẩm",
            controller: _moistureController,
            icon: Symbols.water_drop,
            readOnly: isReadOnly,
          ),
          "middleKey": "Nhiệt Độ",
          "middleValue": ValidationHelper.qcInspectionInput(
            label: "Nhiệt Độ Đầu Sóng",
            controller: _preheaterTempController,
            icon: Symbols.thermostat_auto,
            readOnly: isReadOnly,
          ),
          "rightKey": "Áp Suất Hơi",
          "rightValue": ValidationHelper.qcInspectionInput(
            label: "Áp Suất Hơi",
            controller: _steamPressureController,
            icon: Symbols.thermostat,
            readOnly: isReadOnly,
          ),
        },

        {
          "leftKey": "FCT Nén Ngang",
          "leftValue": ValidationHelper.qcInspectionInput(
            label: "FCT Nén Ngang",
            controller: _fctValueController,
            icon: Symbols.speed,
            readOnly: isReadOnly,
          ),
          "middleKey": "PAT Bám Keo",
          "middleValue": ValidationHelper.qcInspectionInput(
            label: "PAT Bám Keo",
            controller: _patValueController,
            icon: Symbols.speed,
            readOnly: isReadOnly,
          ),
          "rightKey": "",
          "rightValue": const SizedBox.shrink(),
        },
      ],

      {
        "leftKey": "Ghi Chú",
        "leftValue": ValidationHelper.qcInspectionInput(
          label: "Ghi Chú",
          controller: _noteController,
          icon: Symbols.note,
          isNumeric: false,
          readOnly: isReadOnly,
        ),
      },
    ];

    return ResizableDialog(
      initialWidth: ResponsiveSize.getWidth(context, ResponsiveType.large),
      minWidth: 900,
      maxWidth: 1500,
      minHeight: 410,

      //title
      title: Center(
        child: Text(
          isQC ? "Kiểm tra chất lượng sản xuất" : "Báo cáo lỗi sản xuất",
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
      ),

      //button
      actions: buildDialogActions(
        context: context,
        onConfirm: isQC && isAllChecked ? submit : null,
        cancelText: isQC ? "Hủy" : "Đóng",
        customConfirmButton: isQC ? null : const SizedBox.shrink(),
        middleActions: [
          if (!isQC)
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff78D761),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Text(
                "Sửa lỗi",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                  color: Colors.white,
                ),
              ),
            ),

          if (isQC)
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff78D761),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Text(
                "Gửi thông báo",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),

      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Form(
          key: formKey,
          child: IgnorePointer(
            ignoring: !widget.isQC,
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
    );
  }
}
