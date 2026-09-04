import 'package:dongtam/data/models/order/model_helper/paper_classification_item.dart';
import 'package:dongtam/data/models/order/model_helper/paper_structure_result.dart';
import 'package:dongtam/utils/helper/orderHelper/paper_picker_dialog.dart';
import 'package:flutter/material.dart';

class PaperStructureHelper extends StatefulWidget {
  final List<PaperClassificationItem> allPapers;
  final Map<String, String?>? initialData;

  const PaperStructureHelper({super.key, required this.allPapers, this.initialData});

  @override
  State<PaperStructureHelper> createState() => _PaperStructureHelperState();
}

class _PaperStructureHelperState extends State<PaperStructureHelper> {
  late String currentWave;
  late int currentLayerCount;
  final Map<int, PaperClassificationItem?> chosenSlots = {};

  @override
  void initState() {
    super.initState();
    _initFromExistingData();
  }

  // --- HÀM TỰ ĐỘNG BÓC TÁCH DỮ LIỆU CŨ KHI SỬA ĐƠN ---
  void _initFromExistingData() {
    final data = widget.initialData;

    // Nếu tạo mới hoàn toàn (chưa có dữ liệu gì)
    if (data == null || data.values.every((v) => v == null || v.trim().isEmpty)) {
      currentWave = "E";
      currentLayerCount = 2;
      return;
    }

    bool hasField(String key) => data[key] != null && data[key]!.trim().isNotEmpty;

    final hasE = hasField("songE");
    final hasB = hasField("songB");
    final hasC = hasField("songC");
    final hasE2 = hasField("songE2");

    // Tự suy luận loại sóng chính xác 100%
    final detected =
        hasE2
            ? (hasB ? "EBE" : (hasC ? "ECE" : "EE"))
            : [if (hasE) "E", if (hasB) "B", if (hasC) "C"].join();

    currentWave = waveConfigs.containsKey(detected) ? detected : "BC";

    // Tự đếm số lớp đang có dữ liệu
    int filledLayers = 0;
    for (final val in data.values) {
      if (val != null && val.trim().isNotEmpty) filledLayers++;
    }

    final allowed = waveConfigs[currentWave]?["layers"] as List<int>? ?? [4, 5];
    currentLayerCount =
        allowed.contains(filledLayers)
            ? filledLayers
            : (waveConfigs[currentWave]!["defaultLayer"] as int);

    // Khớp giấy vào từng tầng tương ứng
    final activeSlots = _generateSlots(currentWave, currentLayerCount);
    for (int i = 0; i < activeSlots.length; i++) {
      final fieldKey = activeSlots[i]["field"] as String;
      final rawCode = data[fieldKey];
      if (rawCode != null && rawCode.trim().isNotEmpty) {
        chosenSlots[i] = _findMatchingPaper(rawCode);
      }
    }
  }

  // Hàm tìm cuộn giấy trong allPapers (tự bóc tách prefix E, B, C nếu có)
  PaperClassificationItem? _findMatchingPaper(String rawCode) {
    final clean = rawCode.trim().toUpperCase();

    // Tìm khớp trực tiếp
    for (final p in widget.allPapers) {
      if (p.paperCode.toUpperCase() == clean) return p;
    }

    // Tìm sau khi gỡ bỏ tiền tố E2, B, C, E
    for (final prefix in ["E2", "B", "C", "E"]) {
      if (clean.startsWith(prefix) && clean.length > prefix.length) {
        final stripped = clean.substring(prefix.length);
        for (final p in widget.allPapers) {
          if (p.paperCode.toUpperCase() == stripped) return p;
        }
      }
    }

    return PaperClassificationItem(
      classificationId: 0,
      paperCode: clean,
      layerType: "NONE",
      supplierName: "Hiện tại",
    );
  }

  final waveConfigs = {
    // Sóng đơn: 2 & 3 lớp
    "E": {
      "layers": [2, 3],
      "defaultLayer": 2,
    },
    "B": {
      "layers": [2, 3],
      "defaultLayer": 2,
    },
    "C": {
      "layers": [2, 3],
      "defaultLayer": 2,
    },

    // Sóng đôi: 4 & 5 lớp
    "EE": {
      "layers": [4, 5],
      "defaultLayer": 4,
    },
    "EB": {
      "layers": [4, 5],
      "defaultLayer": 4,
    },
    "EC": {
      "layers": [4, 5],
      "defaultLayer": 4,
    },
    "BC": {
      "layers": [4, 5],
      "defaultLayer": 4,
    },

    // Sóng ba: 6 & 7 lớp
    "EBE": {
      "layers": [6, 7],
      "defaultLayer": 6,
    },
    "EBC": {
      "layers": [6, 7],
      "defaultLayer": 6,
    },
    "ECE": {
      "layers": [6, 7],
      "defaultLayer": 6,
    },
  };

  // Sinh slot theo loại sóng và số lớp
  List<Map<String, dynamic>> _generateSlots(String wave, int layers) {
    const waveFlutes = {
      "E": ["E"],
      "B": ["B"],
      "C": ["C"],
      "BC": ["B", "C"],
      "EB": ["E", "B"],
      "EC": ["E", "C"],
      "EE": ["E", "E2"],
      "EBE": ["E", "B", "E2"],
      "ECE": ["E", "C", "E2"],
      "EBC": ["E", "B", "C"],
    };

    final flutes = waveFlutes[wave] ?? [wave];
    final slots = <Map<String, dynamic>>[
      {"name": "Đáy", "isFlute": false, "prefix": "", "field": "day"},
    ];

    for (final f in flutes) {
      // 1. Lớp Sóng
      slots.add({"name": "Sóng $f", "isFlute": true, "prefix": f, "field": "song$f"});

      // 2. Lớp Mặt tương ứng (nếu chưa đủ số lớp)
      if (slots.length < layers) {
        slots.add({"name": "Mặt $f", "isFlute": false, "prefix": "", "field": "mat$f"});
      }
    }

    return slots;
  }

  @override
  Widget build(BuildContext context) {
    final activeSlots = _generateSlots(currentWave, currentLayerCount);
    final availableLayers = waveConfigs[currentWave]!["layers"] as List<int>;

    List<String> previewParts = [];
    bool isFull = true;
    for (int i = 0; i < activeSlots.length; i++) {
      final paper = chosenSlots[i];
      final prefix = activeSlots[i]["prefix"] as String;
      if (paper != null) {
        previewParts.add("$prefix${paper.paperCode}");
      } else {
        previewParts.add("---");
        isFull = false;
      }
    }
    final previewResult = previewParts.join("/");

    return Dialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 750,
        height: 750,
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.layers_rounded, color: Color(0xFF2563EB), size: 22),
                    ),
                    const SizedBox(width: 12),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Thiết Lập Kết Cấu Giấy",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        Text(
                          "Chọn loại sóng trước, sau đó bấm chọn giấy cho từng loại sóng/mặt",
                          style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                        ),
                      ],
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Color(0xFF64748B)),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Loại sóng & Quy cách
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        "Loại sóng:",
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF475569),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Wrap(
                        spacing: 8,
                        children:
                            waveConfigs.keys.map((wave) {
                              final isSelected = currentWave == wave;
                              return ChoiceChip(
                                label: Text(wave),
                                selected: isSelected,
                                selectedColor: const Color(0xFF2563EB),
                                checkmarkColor: Colors.white,
                                labelStyle: TextStyle(
                                  color: isSelected ? Colors.white : const Color(0xFF334155),
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                  fontSize: 12,
                                ),
                                onSelected: (_) {
                                  setState(() {
                                    currentWave = wave;
                                    currentLayerCount = waveConfigs[wave]!["defaultLayer"] as int;

                                    // CHỈ XÓA CÁC TẦNG TRÊN, GIỮ NGUYÊN ĐÁY
                                    chosenSlots.removeWhere((slotIndex, _) => slotIndex != 0);
                                  });
                                },
                              );
                            }).toList(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Text(
                        "Số lớp:",
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF475569),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Wrap(
                        spacing: 8,
                        children:
                            availableLayers.map((layer) {
                              final isSelected = currentLayerCount == layer;
                              return ChoiceChip(
                                label: Text("$layer Lớp"),
                                selected: isSelected,
                                selectedColor: const Color(0xFF2563EB),
                                checkmarkColor: Colors.white,
                                labelStyle: TextStyle(
                                  color: isSelected ? Colors.white : const Color(0xFF334155),
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                  fontSize: 12,
                                ),
                                onSelected: (_) {
                                  setState(() {
                                    currentLayerCount = layer;
                                    chosenSlots.removeWhere((key, _) => key >= layer);
                                  });
                                },
                              );
                            }).toList(),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Danh sách nhập giấy cho từng slot
            Expanded(
              child: ListView.separated(
                physics: const BouncingScrollPhysics(),
                itemCount: activeSlots.length,
                separatorBuilder: (_, _) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final slot = activeSlots[index];
                  final paper = chosenSlots[index];
                  final isFlute = slot["isFlute"] as bool;

                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: paper != null ? const Color(0xFF93C5FD) : const Color(0xFFE2E8F0),
                      ),
                    ),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 130,
                          child: Row(
                            children: [
                              Icon(
                                isFlute ? Icons.waves_rounded : Icons.horizontal_rule_rounded,
                                size: 16,
                                color: isFlute ? const Color(0xFFD97706) : const Color(0xFF2563EB),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                slot["name"],
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color: Color(0xFF1E293B),
                                ),
                              ),
                            ],
                          ),
                        ),

                        Expanded(
                          child:
                              paper == null
                                  ? const Text(
                                    "Chưa chọn loại giấy",
                                    style: TextStyle(
                                      color: Color(0xFF94A3B8),
                                      fontSize: 13,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  )
                                  : Text(
                                    "${paper.paperCode}  (${paper.supplierName})",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                      color: Color(0xFF1E293B),
                                    ),
                                  ),
                        ),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                paper == null ? const Color(0xFFEFF6FF) : const Color(0xFFF1F5F9),
                            foregroundColor:
                                paper == null ? const Color(0xFF2563EB) : const Color(0xFF475569),
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          icon: Icon(
                            paper == null ? Icons.add_rounded : Icons.edit_rounded,
                            size: 14,
                          ),
                          label: Text(
                            paper == null ? "Chọn giấy" : "Đổi",
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                          ),
                          onPressed: () {
                            PaperPickerDialog.show(
                              context: context,
                              title: slot["name"],
                              isFluteOnly: isFlute,
                              allPapers: widget.allPapers,
                              onSelect: (selectedPaper) {
                                setState(() {
                                  chosenSlots[index] = selectedPaper;
                                });
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),

            // Preview kết quả và nút áp dụng
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFBFDBFE)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "KẾT CẤU TỰ SINH:",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2563EB),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          previewResult,
                          style: const TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1E3A8A),
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      "Hủy",
                      style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed:
                        isFull
                            ? () {
                              final data = {
                                for (int i = 0; i < activeSlots.length; i++)
                                  activeSlots[i]["field"] as String: chosenSlots[i]?.paperCode,
                              };

                              Navigator.pop(
                                context,
                                PaperStructureResult.fromMap(previewResult, data),
                              );
                            }
                            : null,
                    child: const Text(
                      "Áp dụng vào đơn",
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
