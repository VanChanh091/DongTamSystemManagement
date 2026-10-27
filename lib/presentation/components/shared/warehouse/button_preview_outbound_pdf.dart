import "package:dongtam/data/controller/theme_controller.dart";
import "package:dongtam/data/controller/user_controller.dart";
import "package:dongtam/data/models/warehouse/outbound/outbound_history_model.dart";
import "package:dongtam/presentation/components/dialog/warehouse/dialog_preview_outbound_pdf.dart";
import "package:dongtam/presentation/components/shared/animation/animated_button.dart";
import "package:flutter/material.dart";
import "package:get/get.dart";
import "package:material_symbols_icons/symbols.dart";

class ButtonPreviewOutboundPdf extends StatelessWidget {
  final OutboundHistoryModel? selectedOutbound;
  final int? selectedOutboundId;

  const ButtonPreviewOutboundPdf({
    super.key,
    required this.selectedOutbound,
    required this.selectedOutboundId,
  });

  @override
  Widget build(BuildContext context) {
    final userController = Get.find<UserController>();
    final themeController = Get.find<ThemeController>();

    final bool canAction = userController.hasAnyPermission(permission: ["accountant", "sale"]);

    // Chỉ sáng và cho phép click khi CẢ 2 điều kiện đều thỏa mãn: có ID và có data model
    final bool isEnabled = selectedOutboundId != null && selectedOutbound != null;

    return PopupMenuButton<String>(
      color: Colors.white,
      position: PopupMenuPosition.under,
      enabled: isEnabled,
      offset: const Offset(-6, 6), // Căn thẳng hàng ngay dưới nút, không bị lệch
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 4,
      onSelected: (value) {
        if (!isEnabled) return;
        final bool hasMoney = (value == "hasMoney");
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => DialogPreviewOutboundPdf(outbound: selectedOutbound!, hasMoney: hasMoney),
        );
      },
      itemBuilder:
          (context) => [
            PopupMenuItem<String>(
              value: "hasMoney",
              enabled: canAction,
              child: ListTile(
                leading: const Icon(Symbols.attach_money, color: Colors.green),
                title: Text(
                  "Có Tiền",
                  style: TextStyle(color: canAction ? Colors.black87 : Colors.grey),
                ),
                subtitle:
                    !canAction
                        ? const Text("Chỉ dành cho kế toán / sale", style: TextStyle(fontSize: 10))
                        : null,
              ),
            ),
            const PopupMenuItem<String>(
              value: "noMoney",
              child: ListTile(
                leading: Icon(Symbols.money_off, color: Colors.blue),
                title: Text("Không Có Tiền"),
              ),
            ),
          ],
      child: IgnorePointer(
        child: AnimatedButton(
          onPressed: isEnabled ? () {} : null,
          label: "Xem và Xuất Phiếu",
          icon: Symbols.receipt_long,
          backgroundColor: isEnabled ? themeController.buttonColor : Colors.grey.shade300,
          foregroundColor: isEnabled ? Colors.white : Colors.grey.shade500,
        ),
      ),
    );
  }
}
