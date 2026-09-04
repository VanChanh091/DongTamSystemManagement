import 'dart:ui';
import 'package:dongtam/data/models/order/model_helper/paper_classification_item.dart';
import 'package:flutter/material.dart';

class PaperPickerDialog extends StatefulWidget {
  final String title;
  final bool isFluteOnly;
  final List<PaperClassificationItem> allPapers;
  final Function(PaperClassificationItem)? onSelect;

  const PaperPickerDialog({
    super.key,
    required this.title,
    required this.isFluteOnly,
    required this.allPapers,
    this.onSelect,
  });

  /// Hàm static giúp mở dialog nhanh từ bất kỳ đâu
  static Future<PaperClassificationItem?> show({
    required BuildContext context,
    required String title,
    required bool isFluteOnly,
    required List<PaperClassificationItem> allPapers,
    Function(PaperClassificationItem)? onSelect,
  }) {
    return showDialog<PaperClassificationItem>(
      context: context,
      builder:
          (ctx) => PaperPickerDialog(
            title: title,
            isFluteOnly: isFluteOnly,
            allPapers: allPapers,
            onSelect: onSelect,
          ),
    );
  }

  @override
  State<PaperPickerDialog> createState() => _PaperPickerDialogState();
}

class _PaperPickerDialogState extends State<PaperPickerDialog> {
  late final TextEditingController _searchInputCtrl;
  String _selectedSupplier = "Tất cả";
  String _searchText = "";

  @override
  void initState() {
    super.initState();
    _searchInputCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _searchInputCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final basePapers =
        widget.isFluteOnly
            ? widget.allPapers.where((p) => p.layerType == 'FLUTE').toList()
            : widget.allPapers.toList();

    final suppliers = ["Tất cả", ...basePapers.map((p) => p.supplierName).toSet()];

    final filteredList =
        basePapers.where((p) {
          final matchSup = _selectedSupplier == "Tất cả" || p.supplierName == _selectedSupplier;
          final matchCode =
              _searchText.isEmpty ||
              p.paperCode.toLowerCase().contains(_searchText.toLowerCase()) ||
              p.supplierName.toLowerCase().contains(_searchText.toLowerCase());
          return matchSup && matchCode;
        }).toList();

    final linerPapers = filteredList.where((p) => p.layerType != 'FLUTE').toList();
    final flutePapers = filteredList.where((p) => p.layerType == 'FLUTE').toList();

    return Dialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Container(
        width: 900,
        height: 700,
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- HEADER ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Chọn giấy cho: ${widget.title}",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1E293B),
                  ),
                ),
                IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
              ],
            ),
            const SizedBox(height: 12),

            // --- THANH TÌM KIẾM ---
            Container(
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  const Icon(Icons.search_rounded, color: Color(0xFF94A3B8), size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _searchInputCtrl,
                      onChanged: (val) => setState(() => _searchText = val),
                      style: const TextStyle(fontSize: 13, color: Color(0xFF1E293B)),
                      decoration: const InputDecoration(
                        hintText: "Tìm nhanh theo mã giấy hoặc nhà cung cấp...",
                        border: InputBorder.none,
                        isDense: true,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // --- PILL TAB CHỌN NCC ---
            SizedBox(
              height: 32,
              child: ScrollConfiguration(
                behavior: ScrollConfiguration.of(context).copyWith(
                  dragDevices: {
                    PointerDeviceKind.touch,
                    PointerDeviceKind.mouse,
                    PointerDeviceKind.trackpad,
                  },
                ),
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: suppliers.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final sup = suppliers[index];
                    final isSelected = _selectedSupplier == sup;
                    final count =
                        sup == "Tất cả"
                            ? basePapers.length
                            : basePapers.where((p) => p.supplierName == sup).length;

                    return InkWell(
                      onTap: () => setState(() => _selectedSupplier = sup),
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFF2563EB) : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isSelected ? const Color(0xFF2563EB) : const Color(0xFFE2E8F0),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              sup,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                color: isSelected ? Colors.white : const Color(0xFF475569),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                              decoration: BoxDecoration(
                                color:
                                    isSelected
                                        ? Colors.white.withValues(alpha: 0.25)
                                        : const Color(0xFFE2E8F0),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                "$count",
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: isSelected ? Colors.white : const Color(0xFF64748B),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 14),

            // --- DANH SÁCH MÃ GIẤY CHIA 2 NHÓM: MẶT & SÓNG ---
            Expanded(
              child: ScrollConfiguration(
                behavior: ScrollConfiguration.of(context).copyWith(
                  dragDevices: {
                    PointerDeviceKind.touch,
                    PointerDeviceKind.mouse,
                    PointerDeviceKind.trackpad,
                  },
                ),
                child:
                    filteredList.isEmpty
                        ? const Center(
                          child: Text(
                            "Không tìm thấy mã giấy phù hợp",
                            style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                          ),
                        )
                        : CustomScrollView(
                          physics: const BouncingScrollPhysics(),
                          slivers: [
                            // 1. GIẤY MẶT
                            if (linerPapers.isNotEmpty) ...[
                              SliverToBoxAdapter(
                                child: _buildSectionHeader(
                                  title: "GIẤY MẶT",
                                  count: linerPapers.length,
                                  icon: Icons.layers_outlined,
                                  color: const Color(0xFF15803D),
                                  bgColor: const Color(0xFFDCFCE7),
                                ),
                              ),
                              SliverGrid(
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 4,
                                  crossAxisSpacing: 12,
                                  mainAxisSpacing: 12,
                                  childAspectRatio: 2.8,
                                ),
                                delegate: SliverChildBuilderDelegate(
                                  (context, index) => _buildCardItem(linerPapers[index]),
                                  childCount: linerPapers.length,
                                ),
                              ),
                            ],

                            // 2. GIẤY SÓNG
                            if (flutePapers.isNotEmpty) ...[
                              SliverToBoxAdapter(
                                child: _buildSectionHeader(
                                  title: "GIẤY SÓNG",
                                  count: flutePapers.length,
                                  icon: Icons.waves_rounded,
                                  color: const Color(0xFFB45309),
                                  bgColor: const Color(0xFFFEF3C7),
                                ),
                              ),
                              SliverGrid(
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 4,
                                  crossAxisSpacing: 12,
                                  mainAxisSpacing: 12,
                                  childAspectRatio: 2.8,
                                ),
                                delegate: SliverChildBuilderDelegate(
                                  (context, index) => _buildCardItem(flutePapers[index]),
                                  childCount: flutePapers.length,
                                ),
                              ),
                            ],
                          ],
                        ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget con vẽ Card giấy
  Widget _buildCardItem(PaperClassificationItem item) {
    final isFlute = item.layerType == 'FLUTE';
    return InkWell(
      onTap: () {
        if (widget.onSelect != null) {
          widget.onSelect!(item);
        }
        Navigator.pop(context, item);
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 3,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  item.paperCode,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1E293B),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                  decoration: BoxDecoration(
                    color: isFlute ? const Color(0xFFFEF3C7) : const Color(0xFFDCFCE7),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    isFlute ? "SÓNG" : "MẶT",
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: isFlute ? const Color(0xFFB45309) : const Color(0xFF15803D),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 3),
            Row(
              children: [
                const Icon(Icons.store_outlined, size: 12, color: Color(0xFF94A3B8)),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    item.supplierName,
                    style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Widget con vẽ tiêu đề ngăn cách nhóm
  Widget _buildSectionHeader({
    required String title,
    required int count,
    required IconData icon,
    required Color color,
    required Color bgColor,
  }) {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 10),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(title, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: color)),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
            decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(6)),
            child: Text(
              "$count",
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color),
            ),
          ),
          const SizedBox(width: 10),
          const Expanded(child: Divider(color: Color(0xFFE2E8F0), thickness: 0.8)),
        ],
      ),
    );
  }
}
