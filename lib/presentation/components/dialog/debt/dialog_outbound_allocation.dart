import "package:dongtam/data/models/order/order_model.dart";
import "package:dongtam/data/models/warehouse/outbound/outbound_history_model.dart";
import "package:dongtam/data/models/warehouse/payment/payment_allocation_model.dart";
import "package:dongtam/service/debt_service.dart";
import "package:dongtam/utils/helper/reponsive/reponsive_dialog.dart";
import "package:flutter/material.dart";
import "package:intl/intl.dart";
import "package:material_symbols_icons/symbols.dart";

class DialogOutboundAllocation extends StatefulWidget {
  final OutboundHistoryModel outbound;

  const DialogOutboundAllocation({super.key, required this.outbound});

  @override
  State<DialogOutboundAllocation> createState() => _DialogOutboundAllocationHistoryState();
}

class _DialogOutboundAllocationHistoryState extends State<DialogOutboundAllocation> {
  late Future<List<PaymentAllocationModel>> _futureAllocations;

  @override
  void initState() {
    super.initState();
    _futureAllocations = DebtService().getPaymentAllocationHistory(
      outboundId: widget.outbound.outboundId,
    );
  }

  @override
  Widget build(BuildContext context) {
    final customerName = widget.outbound.customerNameDisplay;

    final totalPayment = widget.outbound.totalPricePayment;
    final paidAmount = widget.outbound.paidAmount ?? 0;
    final remainingAmount = widget.outbound.remainingAmount ?? 0;
    final hasDebt = remainingAmount > 0;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      elevation: 10,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: ResponsiveSize.getWidth(context, ResponsiveType.medium).clamp(580, 680),
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ==================== HEADER ====================
            Container(
              padding: const EdgeInsets.fromLTRB(24, 20, 16, 16),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.grey.shade100, width: 1.5)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.blue.shade600, Colors.blue.shade800],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: const Icon(Symbols.receipt_long, color: Colors.white, size: 22),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Lịch Sử Cấn Trừ Công Nợ",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Text(
                              "PXK: ",
                              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE0F2FE),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: const Color(0xFFBAE6FD)),
                              ),
                              child: Text(
                                widget.outbound.outboundSlipCode,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12.5,
                                  color: Color(0xFF0369A1),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded),
                    color: Colors.grey.shade600,
                    splashRadius: 20,
                  ),
                ],
              ),
            ),

            // ==================== BODY ====================
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Thông tin khách hàng & ngày xuất
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Row(
                        children: [
                          Icon(Symbols.storefront, size: 18, color: Colors.blueGrey.shade600),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              customerName,
                              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            width: 1,
                            height: 16,
                            color: Colors.grey.shade300,
                            margin: const EdgeInsets.symmetric(horizontal: 12),
                          ),
                          Icon(Symbols.calendar_today, size: 16, color: Colors.blueGrey.shade600),
                          const SizedBox(width: 6),
                          Text(
                            DateFormat("dd/MM/yyyy").format(widget.outbound.dateOutbound),
                            style: TextStyle(
                              color: Colors.blueGrey.shade700,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // 3 THẺ TÀI CHÍNH (METRIC CARDS)
                    Row(
                      children: [
                        Expanded(
                          child: _buildMetricCard(
                            title: "Tổng Tiền Phiếu",
                            value: "${OrderModel.formatCurrency(totalPayment)} đ",
                            bgColor: const Color(0xFFF8FAFC),
                            borderColor: const Color(0xFFE2E8F0),
                            textColor: const Color(0xFF1E293B),
                            icon: Symbols.payments,
                            iconColor: const Color(0xFF64748B),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildMetricCard(
                            title: "Đã Cấn Trừ",
                            value: "${OrderModel.formatCurrency(paidAmount)} đ",
                            bgColor: const Color(0xFFF0FDF4),
                            borderColor: const Color(0xFFBBF7D0),
                            textColor: const Color(0xFF15803D),
                            icon: Symbols.check_circle,
                            iconColor: const Color(0xFF16A34A),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildMetricCard(
                            title: "Còn Nợ Lại",
                            value: "${OrderModel.formatCurrency(remainingAmount)} đ",
                            bgColor: hasDebt ? const Color(0xFFFEF2F2) : const Color(0xFFF8FAFC),
                            borderColor:
                                hasDebt ? const Color(0xFFFECACA) : const Color(0xFFE2E8F0),
                            textColor: hasDebt ? const Color(0xFFDC2626) : const Color(0xFF64748B),
                            icon: hasDebt ? Symbols.warning : Symbols.task_alt,
                            iconColor: hasDebt ? const Color(0xFFDC2626) : const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 22),

                    // TIÊU ĐỀ BẢNG LỊCH SỬ
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Lịch Sử Các Đợt Trừ Tiền",
                          style: TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        _buildStatusBadge(widget.outbound.status),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // DANH SÁCH GIAO DỊCH
                    FutureBuilder<List<PaymentAllocationModel>>(
                      future: _futureAllocations,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return Container(
                            height: 160,
                            alignment: Alignment.center,
                            child: const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 28,
                                  height: 28,
                                  child: CircularProgressIndicator(strokeWidth: 2.5),
                                ),
                                SizedBox(height: 12),
                                Text(
                                  "Đang tải dữ liệu...",
                                  style: TextStyle(color: Colors.grey, fontSize: 13),
                                ),
                              ],
                            ),
                          );
                        }

                        if (snapshot.hasError) {
                          return Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFEF2F2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.error_outline, color: Color(0xFFDC2626)),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    "Không thể tải lịch sử cấn trừ. Vui lòng thử lại sau.",
                                    style: TextStyle(color: Colors.red.shade700, fontSize: 13),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        final list = snapshot.data ?? [];
                        if (list.isEmpty) {
                          return Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 16),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: const Color(0xFFE2E8F0)),
                            ),
                            child: Column(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.04),
                                        blurRadius: 8,
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    Symbols.savings,
                                    size: 36,
                                    color: Colors.grey.shade400,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                const Text(
                                  "Chưa có lịch sử cấn trừ cho phiếu này",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: Color(0xFF334155),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "Khi kế toán import trừ nợ hoặc duyệt cấn trừ, các đợt trừ sẽ xuất hiện ở đây.",
                                  style: TextStyle(color: Colors.grey.shade500, fontSize: 12.5),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          );
                        }

                        return Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Column(
                              children: [
                                // ==================== Header bảng ====================
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                  color: const Color(0xFFF1F5F9),
                                  child: const Row(
                                    children: [
                                      // 1. Cột Đợt (Tăng lên 52px để số thứ tự thoáng hơn)
                                      SizedBox(
                                        width: 52,
                                        child: Text(
                                          "ĐỢT",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 11.5,
                                            color: Color(0xFF475569),
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 12), // Khoảng đệm tách rời Đợt và Thời gian
                                      // 2. Cột Thời gian (Cố định 140px, vừa vặn chuẩn dd/MM/yyyy HH:mm)
                                      SizedBox(
                                        width: 140,
                                        child: Text(
                                          "THỜI GIAN",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 11.5,
                                            color: Color(0xFF475569),
                                          ),
                                        ),
                                      ),

                                      // 3. Cột Nguồn cấn trừ (Cố định 130px, vừa vặn cho các Badge)
                                      SizedBox(
                                        width: 130,
                                        child: Text(
                                          "NGUỒN CẤN TRỪ",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 11.5,
                                            color: Color(0xFF475569),
                                          ),
                                        ),
                                      ),

                                      // 4. Cột Số tiền (Expanded để tự co giãn và dạt gọn sang phải)
                                      Expanded(
                                        child: Text(
                                          "SỐ TIỀN TRỪ",
                                          textAlign: TextAlign.right,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 11.5,
                                            color: Color(0xFF475569),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // Rows
                                ListView.separated(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: list.length,
                                  separatorBuilder:
                                      (_, _) => Divider(
                                        height: 1,
                                        thickness: 1,
                                        color: Colors.grey.shade100,
                                      ),
                                  // ==================== Rows ====================
                                  itemBuilder: (context, index) {
                                    final item = list[index];
                                    final dateStr =
                                        item.createdAt != null
                                            ? DateFormat("dd/MM/yyyy HH:mm").format(item.createdAt!)
                                            : "—";

                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 12,
                                      ),
                                      child: Row(
                                        children: [
                                          // 1. Value Đợt
                                          SizedBox(
                                            width: 52,
                                            child: Align(
                                              alignment: Alignment.centerLeft,
                                              child: Container(
                                                width: 24,
                                                height: 24,
                                                alignment: Alignment.center,
                                                decoration: BoxDecoration(
                                                  color: const Color(0xFFE2E8F0),
                                                  borderRadius: BorderRadius.circular(12),
                                                ),
                                                child: Text(
                                                  "${index + 1}",
                                                  style: const TextStyle(
                                                    fontSize: 11.5,
                                                    fontWeight: FontWeight.bold,
                                                    color: Color(0xFF334155),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 12), // Khoảng đệm khớp với Header
                                          // 2. Value Thời gian
                                          SizedBox(
                                            width: 140,
                                            child: Text(
                                              dateStr,
                                              style: const TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w500,
                                                color: Color(0xFF1E293B),
                                              ),
                                            ),
                                          ),

                                          // 3. Value Nguồn cấn trừ
                                          SizedBox(
                                            width: 130,
                                            child: Align(
                                              alignment: Alignment.centerLeft,
                                              child: _buildMethodBadge(item.paymentMethod),
                                            ),
                                          ),

                                          // 4. Value Số tiền trừ
                                          Expanded(
                                            child: Text(
                                              "- ${OrderModel.formatCurrency(item.amountAllocation)} đ",
                                              textAlign: TextAlign.right,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFF16A34A),
                                                fontSize: 13.5,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),

            // ==================== FOOTER ====================
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              decoration: BoxDecoration(
                color: const Color(0xFFFAFAFA),
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
                border: Border(top: BorderSide(color: Colors.grey.shade200)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 11),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      side: BorderSide(color: Colors.grey.shade300),
                      backgroundColor: Colors.white,
                    ),
                    child: const Text(
                      "Đóng",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF334155),
                        fontSize: 14,
                      ),
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

  Widget _buildMetricCard({
    required String title,
    required String value,
    required Color bgColor,
    required Color borderColor,
    required Color textColor,
    required IconData icon,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 11.5,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Icon(icon, size: 16, color: iconColor),
            ],
          ),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: textColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMethodBadge(String method) {
    Color bg;
    Color fg;
    String label;
    IconData icon;

    if (method == "IMPORT") {
      bg = const Color(0xFFF3E8FF);
      fg = const Color(0xFF7E22CE);
      label = "Import Excel";
      icon = Symbols.file_present;
    } else if (method == "MANUAL") {
      bg = const Color(0xFFFEF3C7);
      fg = const Color(0xFFB45309);
      label = "Thao Tác Tay";
      icon = Symbols.edit_note;
    } else {
      bg = const Color(0xFFE0F2FE);
      fg = const Color(0xFF0369A1);
      label = method;
      icon = Symbols.receipt;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(6)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: fg),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: fg)),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bg;
    Color fg;
    String label;

    switch (status) {
      case "paid":
        bg = const Color(0xFFDCFCE7);
        fg = const Color(0xFF166534);
        label = "Đã Thanh Toán Hết";
        break;
      case "partial":
        bg = const Color(0xFFFEF9C3);
        fg = const Color(0xFF854D0E);
        label = "Thanh Toán Một Phần";
        break;
      default:
        bg = const Color(0xFFFEE2E2);
        fg = const Color(0xFF991B1B);
        label = "Chưa Thanh Toán";
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3.5),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(label, style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: fg)),
    );
  }
}
