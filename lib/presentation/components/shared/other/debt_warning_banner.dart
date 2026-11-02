import "package:dongtam/data/models/customer/customer_payment_model.dart";
import "package:dongtam/data/models/order/order_model.dart";
import "package:flutter/material.dart";
import "package:google_fonts/google_fonts.dart";

class DebtWarningBanner extends StatelessWidget {
  final CustomerPaymentModel? payment;
  final bool isForAdmin;
  final EdgeInsetsGeometry margin;

  const DebtWarningBanner({
    super.key,
    required this.payment,
    this.isForAdmin = false,
    this.margin = const EdgeInsets.only(bottom: 14),
  });

  @override
  Widget build(BuildContext context) {
    if (payment == null) {
      return const SizedBox.shrink();
    }

    final debtCurrent = payment!.debtCurrent ?? 0;
    final debtLimit = payment!.debtLimit ?? 0;

    if (debtCurrent <= debtLimit) {
      return const SizedBox.shrink();
    }

    final isShowText = isForAdmin ? "⚠️ Cần duyệt với quyền Vượt Hạn Mức hoặc OTP Telegram!" : "";
    final String descText =
        "Nợ hiện tại: ${OrderModel.formatCurrency(debtCurrent)} đ  |  Hạn mức: ${OrderModel.formatCurrency(debtLimit)} đ. $isShowText";

    return _buildContainer(
      bgColor: const Color(0xFFFEF2F2),
      borderColor: const Color(0xFFF87171),
      textColor: const Color(0xFF991B1B),
      icon: Icons.warning_amber_rounded,
      title: "CẢNH BÁO: Vượt hạn mức công nợ",
      desc: descText,
    );
  }

  Widget _buildContainer({
    required Color bgColor,
    required Color borderColor,
    required Color textColor,
    required IconData icon,
    required String title,
    required String desc,
  }) {
    return Container(
      width: double.infinity,
      margin: margin,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderColor, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: textColor, size: 26),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  desc,
                  style: GoogleFonts.inter(
                    fontSize: 13.5,
                    color: textColor.withValues(alpha: 0.9),
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
