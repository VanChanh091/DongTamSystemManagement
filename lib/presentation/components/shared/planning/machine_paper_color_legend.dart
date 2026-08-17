import 'package:flutter/material.dart';

class MachinePaperColorLegendButton extends StatelessWidget {
  final double iconSize;
  final Color? iconColor;

  const MachinePaperColorLegendButton({super.key, this.iconSize = 20, this.iconColor});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: "Giải thích màu sắc & trạng thái",
      waitDuration: const Duration(milliseconds: 300),
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: IconButton(
          icon: Icon(
            Icons.help_outline_rounded,
            size: iconSize,
            color: iconColor ?? Colors.blue.shade700,
          ),
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => const MachinePaperColorLegendDialog(),
            );
          },
        ),
      ),
    );
  }
}

class MachinePaperColorLegendDialog extends StatelessWidget {
  const MachinePaperColorLegendDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    // Tính toán kích thước responsive theo % màn hình:
    // - Chiều rộng: Chiếm 92% màn hình, tối đa 700px trên desktop
    // - Chiều cao: Tối đa 85% chiều cao màn hình (không bao giờ lo bị tràn viền)
    final double dialogWidth = screenSize.width > 700 ? 680 : screenSize.width * 0.92;
    final double dialogMaxHeight = screenSize.height * 0.7;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      elevation: 8,
      child: Container(
        color: Colors.white,
        width: dialogWidth,
        constraints: BoxConstraints(maxHeight: dialogMaxHeight),
        padding: EdgeInsets.all(screenSize.width < 400 ? 14 : 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.palette_outlined, color: Colors.blue.shade700, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "CHÚ THÍCH MÀU SẮC & TRẠNG THÁI",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        "Quy định hiển thị màu sắc dòng và ô trong bảng Sản Xuất Giấy Tấm",
                        style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                  tooltip: "Đóng",
                ),
              ],
            ),
            const Divider(height: 24),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Section 1: Màu Nền Dòng (Ghép 2 cột)
                    _buildSectionHeader(
                      title: "1. Màu Nền Dòng",
                      icon: Icons.table_rows_outlined,
                      color: Colors.blue.shade700,
                    ),
                    const SizedBox(height: 8),

                    _buildRow(
                      _buildLegendItem(
                        colorBox: _buildColorSquare(
                          Colors.blue.withValues(alpha: 0.3),
                          borderColor: Colors.blue.shade300,
                        ),
                        title: "Xanh Dương",
                        subtitle: "Dòng đang được chọn",
                      ),
                      _buildLegendItem(
                        colorBox: _buildColorSquare(
                          Colors.teal.withValues(alpha: 0.4),
                          borderColor: Colors.teal.shade400,
                        ),
                        title: "Màu Xanh Ngọc",
                        subtitle: "Đã yêu cầu hoàn thành",
                      ),
                    ),

                    _buildRow(
                      _buildLegendItem(
                        colorBox: _buildColorSquare(
                          Colors.orange.withValues(alpha: 0.4),
                          borderColor: Colors.orange.shade400,
                        ),
                        title: "Màu Cam",
                        subtitle: "Đang sản xuất",
                      ),
                      _buildLegendItem(
                        colorBox: _buildColorSquare(
                          Colors.amberAccent.withValues(alpha: 0.3),
                          borderColor: Colors.amber.shade400,
                        ),
                        title: "Màu Vàng",
                        subtitle: "Chưa xếp lịch chạy",
                      ),
                    ),

                    _buildRow(
                      _buildLegendItem(
                        colorBox: _buildColorSquare(
                          Colors.green.withValues(alpha: 0.3),
                          borderColor: Colors.green.shade400,
                        ),
                        title: "Màu Xanh Lá",
                        subtitle: "Đã sửa lỗi khi bị QC báo lỗi",
                      ),
                      _buildLegendItem(
                        colorBox: _buildColorSquare(
                          Colors.red.shade400,
                          borderColor: Colors.red.shade700,
                          child: const Icon(Icons.flash_on, size: 14, color: Colors.white),
                        ),
                        title: "Chớp Đỏ",
                        subtitle: "Đơn hàng lỗi / Không đạt kiểm tra QC",
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Section 2: Cảnh Báo Ô & Màu Chữ
                    _buildSectionHeader(
                      title: "2. Cảnh Báo Ô & Màu Chữ",
                      icon: Icons.border_color_outlined,
                      color: Colors.orange.shade800,
                    ),
                    const SizedBox(height: 8),

                    _buildRow(
                      _buildLegendItem(
                        colorBox: _buildColorSquare(Colors.red.withValues(alpha: 0.5)),
                        title: "Tô Đỏ ô 'Đã Sản Xuất'",
                        subtitle: "Sản lượng sản xuất thực tế so với kế hoạch chạy ban đầu",
                      ),
                    ),

                    _buildLegendItem(
                      colorBox: _buildColorSquare(Colors.red.withValues(alpha: 0.5)),
                      title: "Tô Đỏ ô 'PL Thực Tế'",
                      subtitle: "Phế liệu thực tế vượt quá định mức cho phép",
                    ),

                    _buildRow(
                      _buildLegendItem(
                        colorBox: _buildDateText("15/08", Colors.orangeAccent.shade400),
                        title: "Chữ Cam ở 'Ngày Dự Kiến'",
                        subtitle: "Đến hạn giao hàng trong ngày hôm nay",
                      ),
                      _buildRow(
                        _buildLegendItem(
                          colorBox: _buildDateText("15/08", Colors.redAccent.shade400),
                          title: "Chữ Đỏ ở 'Ngày Dự Kiến'",
                          subtitle: "Đã quá hạn ngày yêu cầu giao hàng",
                        ),
                      ),
                    ),

                    // Item riêng 1 dòng
                    const SizedBox(height: 20),

                    // Section 3: Biểu Tượng Cảnh Báo
                    _buildSectionHeader(
                      title: "3. Biểu Tượng Cảnh Báo Trong Ô",
                      icon: Icons.info_outline,
                      color: Colors.purple.shade700,
                    ),
                    const SizedBox(height: 8),

                    // Text dài -> để riêng 1 dòng
                    _buildRow(
                      _buildLegendItem(
                        colorBox: const SizedBox(
                          width: 36,
                          height: 24,
                          child: Icon(Icons.warning_amber_rounded, size: 20, color: Colors.orange),
                        ),
                        title: "Biểu Tượng Cảnh Báo",
                        subtitle:
                            "Khổ giấy của đơn hàng này thay đổi so với đơn hàng liền trước đó",
                      ),
                    ),

                    _buildRow(
                      _buildLegendItem(
                        colorBox: const SizedBox(
                          width: 36,
                          height: 24,
                          child: Icon(Icons.copy_rounded, size: 18, color: Colors.redAccent),
                        ),
                        title: "Biểu Tượng Trùng Đơn",
                        subtitle: "Mã đơn hàng bị lặp lại nhiều hơn 1 lần trong danh sách",
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Helper gom hàng: Tự động nhận diện 1 cột hoặc 2 cột ---
  Widget _buildRow(Widget first, [Widget? second]) {
    if (second == null) {
      // 1 Dòng (Full Width)
      return first;
    }
    // 2 Cột (50% - 50%)
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [Expanded(child: first), const SizedBox(width: 16), Expanded(child: second)],
    );
  }

  Widget _buildSectionHeader({
    required String title,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 8),
          Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  Widget _buildLegendItem({
    required Widget colorBox,
    required String title,
    required String subtitle,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(padding: const EdgeInsets.only(top: 2), child: colorBox),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 12.5, color: Colors.grey.shade700, height: 1.25),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Tiện ích tạo ô màu
  Widget _buildColorSquare(Color bgColor, {Color? borderColor, Widget? child}) {
    return Container(
      width: 36,
      height: 24,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(4),
        border: borderColor != null ? Border.all(color: borderColor) : null,
      ),
      child: child != null ? Center(child: child) : null,
    );
  }

  // Tiện ích tạo demo Text ngày
  Widget _buildDateText(String date, Color color) {
    return SizedBox(
      width: 36,
      height: 24,
      child: Center(
        child: Text(
          date,
          style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12),
        ),
      ),
    );
  }
}
