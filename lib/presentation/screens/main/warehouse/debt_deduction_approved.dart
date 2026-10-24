import "package:dongtam/data/controller/badges_controller.dart";
import "package:dongtam/data/controller/theme_controller.dart";
import "package:dongtam/data/models/order/order_model.dart";
import "package:dongtam/data/models/warehouse/debt_deduction_request_model.dart";
import "package:dongtam/presentation/components/shared/animation/animated_button.dart";
import "package:dongtam/presentation/components/shared/dialog_shared.dart";
import "package:dongtam/service/debt_service.dart";
import "package:dongtam/utils/handleError/show_snack_bar.dart";
import "package:dongtam/utils/helper/skeleton/skeleton_loading.dart";
import "package:flutter/material.dart";
import "package:get/get.dart";
import "package:google_fonts/google_fonts.dart";
import "package:intl/intl.dart";
import "package:material_symbols_icons/symbols.dart";

class DebtDeductionApproved extends StatefulWidget {
  const DebtDeductionApproved({super.key});

  @override
  State<DebtDeductionApproved> createState() => _DebtDeductionApprovedState();
}

class _DebtDeductionApprovedState extends State<DebtDeductionApproved> {
  List<DebtDeductionRequestModel> requests = [];
  DebtDeductionRequestModel? selectedRequest;
  bool isLoading = false;

  final themeController = Get.find<ThemeController>();
  BadgesController? badgesController;
  final formatter = DateFormat("dd/MM/yyyy");

  final TextEditingController searchController = TextEditingController();
  final TextEditingController reasonController = TextEditingController();
  final TextEditingController otpController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (Get.isRegistered<BadgesController>()) {
      badgesController = Get.find<BadgesController>();
    }
    _loadRequests();
  }

  Future<void> _loadRequests() async {
    setState(() => isLoading = true);

    try {
      final res = await ensureMinLoading(
        DebtService().getDebtDeductionRequests(
          page: 1,
          pageSize: 100,
          status: ["pending"],
        ),
      );

      final rawList = (res["debtDeductions"] as List? ?? []);
      setState(() {
        requests = rawList.cast<DebtDeductionRequestModel>();
        isLoading = false;
        if (selectedRequest != null) {
          final found = requests.where((r) => r.requestId == selectedRequest!.requestId);
          selectedRequest = found.isNotEmpty ? found.first : null;
        }
      });
    } catch (e) {
      setState(() => isLoading = false);
      if (mounted) showSnackBarError(context, "Lỗi tải danh sách yêu cầu: $e");
    }
  }

  Map<String, List<DebtDeductionRequestModel>> _groupRequestsByCustomer(
    List<DebtDeductionRequestModel> list,
  ) {
    final query = searchController.text.trim().toLowerCase();
    final filtered = query.isEmpty
        ? list
        : list.where((r) {
            final name = (r.Customer?.customerName ?? "").toLowerCase();
            final id = r.customerId.toLowerCase();
            final reqId = r.requestId.toString();
            return name.contains(query) || id.contains(query) || reqId.contains(query);
          }).toList();

    final Map<String, List<DebtDeductionRequestModel>> grouped = {};
    for (var r in filtered) {
      final groupKey = r.Customer?.customerName ?? r.customerId;
      grouped.putIfAbsent(groupKey, () => []);
      grouped[groupKey]!.add(r);
    }
    return grouped;
  }

  Future<void> _sendOtpCode() async {
    if (selectedRequest == null) return;

    try {
      final success = await DebtService().requestOrVerifyUrgentOtp(
        requestId: selectedRequest!.requestId,
      );
      if (!mounted) return;
      if (success) {
        showSnackBarSuccess(context, "Đã gửi mã OTP về Telegram của Quản lý!");
      } else {
        showSnackBarError(context, "Không thể gửi OTP về Telegram");
      }
    } catch (e) {
      if (!mounted) return;
      showSnackBarError(context, "Lỗi gửi mã OTP: $e");
    }
  }

  Future<void> _processApprove() async {
    if (selectedRequest == null) return;

    final confirm = await showConfirmDialog(
      context: context,
      title: "Xác nhận phê duyệt",
      content:
          "Bạn có chắc muốn phê duyệt yêu cầu cấn trừ công nợ #${selectedRequest!.requestId} "
          "của khách hàng ${selectedRequest!.Customer?.customerName ?? selectedRequest!.customerId} "
          "với số tiền ${NumberFormat("#,###", "vi_VN").format(selectedRequest!.amountRequested)} đ?",
      confirmText: "Phê Duyệt",
    );

    if (!confirm) return;

    try {
      final success = await DebtService().updateDebtDeductionStatus(
        requestId: selectedRequest!.requestId,
        status: "approved",
      );
      if (!mounted) return;
      if (success) {
        showSnackBarSuccess(context, "Phê duyệt yêu cầu cấn trừ nợ thành công");
        await _loadRequests();
        setState(() => selectedRequest = null);
      } else {
        showSnackBarError(context, "Phê duyệt không thành công");
      }
    } catch (e) {
      if (!mounted) return;
      showSnackBarError(context, "Lỗi phê duyệt: $e");
    }
  }

  void _showOtpApprovalDialog() {
    if (selectedRequest == null) return;
    final formKey = GlobalKey<FormState>();
    otpController.clear();

    showDialog(
      context: context,
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (sbContext, setDialogState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              title: const Row(
                children: [
                  Icon(Icons.security, color: Colors.indigo),
                  SizedBox(width: 8),
                  Text(
                    "Duyệt yêu cầu qua mã OTP",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ],
              ),
              content: SizedBox(
                width: 380,
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Mã yêu cầu: #${selectedRequest!.requestId}\n"
                        "Khách hàng: ${selectedRequest!.Customer?.customerName ?? selectedRequest!.customerId}\n"
                        "Số tiền: ${NumberFormat("#,###", "vi_VN").format(selectedRequest!.amountRequested)} đ\n\n"
                        "Nhập mã OTP đã được gửi về Telegram Quản lý để duyệt:",
                        style: const TextStyle(fontSize: 14, color: Colors.black87),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: otpController,
                        keyboardType: TextInputType.number,
                        maxLength: 6,
                        decoration: const InputDecoration(
                          labelText: "Mã OTP",
                          hintText: "Nhập mã OTP (VD: 1234)",
                          prefixIcon: Icon(Icons.key),
                          border: OutlineInputBorder(),
                          counterText: "",
                        ),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) return "Vui lòng nhập mã OTP";
                          if (int.tryParse(val.trim()) == null) return "Mã OTP phải là số";
                          return null;
                        },
                      ),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton.icon(
                          onPressed: () async {
                            await _sendOtpCode();
                          },
                          icon: const Icon(Icons.send_rounded, size: 16, color: Color(0xFF0088CC)),
                          label: const Text(
                            "Gửi lại mã OTP qua Telegram",
                            style: TextStyle(color: Color(0xFF0088CC)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF475569),
                    side: const BorderSide(color: Color(0xFFCBD5E1)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  ),
                  onPressed: () => Navigator.pop(dialogCtx),
                  child: const Text("Hủy", style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo.shade600,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () async {
                    if (formKey.currentState!.validate()) {
                      final otp = int.parse(otpController.text.trim());
                      Navigator.pop(dialogCtx);
                      try {
                        final success = await DebtService().requestOrVerifyUrgentOtp(
                          requestId: selectedRequest!.requestId,
                          otp: otp,
                        );
                        if (!mounted) return;
                        if (success) {
                          showSnackBarSuccess(context, "Xác nhận duyệt yêu cầu thành công!");
                          await _loadRequests();
                          setState(() => selectedRequest = null);
                        } else {
                          showSnackBarError(context, "Xác thực OTP không thành công hoặc sai mã");
                        }
                      } catch (e) {
                        if (!mounted) return;
                        showSnackBarError(context, "Lỗi xác thực: $e");
                      }
                    }
                  },
                  child: const Text("Xác nhận duyệt", style: TextStyle(color: Colors.white, fontSize: 16)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showRejectDialog() {
    if (selectedRequest == null) return;
    final formKey = GlobalKey<FormState>();
    reasonController.clear();

    showDialog(
      context: context,
      builder: (dialogCtx) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: const Text(
            "Nhập lý do từ chối",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          content: SizedBox(
            width: 380,
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Yêu cầu: #${selectedRequest!.requestId} - Khách hàng: ${selectedRequest!.Customer?.customerName ?? selectedRequest!.customerId}\n"
                    "Số tiền: ${NumberFormat("#,###", "vi_VN").format(selectedRequest!.amountRequested)} đ\n\n"
                    "Vui lòng nhập lý do từ chối yêu cầu:",
                    style: const TextStyle(fontSize: 14, color: Colors.black87),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: reasonController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      hintText: "Nhập lý do từ chối...",
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "Vui lòng nhập lý do từ chối";
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF475569),
                side: const BorderSide(color: Color(0xFFCBD5E1)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              ),
              onPressed: () => Navigator.pop(dialogCtx),
              child: const Text("Hủy", style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade600,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  final reason = reasonController.text.trim();
                  Navigator.pop(dialogCtx);
                  try {
                    final success = await DebtService().updateDebtDeductionStatus(
                      requestId: selectedRequest!.requestId,
                      status: "rejected",
                      rejectReason: reason,
                    );
                    if (!mounted) return;
                    if (success) {
                      showSnackBarSuccess(context, "Từ chối phê duyệt thành công");
                      await _loadRequests();
                      setState(() => selectedRequest = null);
                    } else {
                      showSnackBarError(context, "Từ chối phê duyệt thất bại");
                    }
                  } catch (e) {
                    if (!mounted) return;
                    showSnackBarError(context, "Lỗi từ chối: $e");
                  }
                }
              },
              child: const Text("Xác nhận", style: TextStyle(color: Colors.white, fontSize: 16)),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    searchController.dispose();
    reasonController.dispose();
    otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final groupedRequests = _groupRequestsByCustomer(requests);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          color: themeController.backgroundColor.value,
          gradient: const LinearGradient(
            colors: [Color(0xFFF1F5F9), Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            bool isSmallScreen = constraints.maxWidth < 1100;

            return Row(
              children: [
                // CỘT TRÁI: Danh sách yêu cầu chờ duyệt
                Expanded(
                  flex: isSmallScreen ? 2 : 1,
                  child: Container(
                    color: const Color(0xFFF8FAFC),
                    child: Column(
                      children: [
                        // Ô tìm kiếm nhanh
                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: TextField(
                            controller: searchController,
                            onChanged: (_) => setState(() {}),
                            decoration: InputDecoration(
                              hintText: "Tìm theo tên, mã khách, mã yêu cầu...",
                              prefixIcon: const Icon(Icons.search, size: 20),
                              suffixIcon: searchController.text.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(Icons.clear, size: 18),
                                      onPressed: () {
                                        searchController.clear();
                                        setState(() {});
                                      },
                                    )
                                  : null,
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(color: Colors.grey.shade300),
                              ),
                            ),
                          ),
                        ),

                        // Danh sách nhóm theo khách hàng
                        Expanded(
                          child: isLoading
                              ? buildShimmerSkeletonTable(context: context)
                              : groupedRequests.isEmpty
                                  ? Center(
                                      child: Text(
                                        "Không có yêu cầu nào chờ duyệt",
                                        style: GoogleFonts.inter(
                                          fontSize: 15,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                    )
                                  : ListView(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                      children: groupedRequests.entries.map((entry) {
                                        final customerGroup = entry.key;
                                        final itemsInGroup = entry.value;

                                        return Container(
                                          margin: const EdgeInsets.symmetric(vertical: 5),
                                          decoration: BoxDecoration(
                                            color: Colors.white.withValues(alpha: 0.95),
                                            borderRadius: BorderRadius.circular(14),
                                            border: Border.all(color: Colors.grey.shade300, width: 1),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withValues(alpha: 0.05),
                                                blurRadius: 6,
                                                offset: const Offset(0, 3),
                                              ),
                                            ],
                                          ),
                                          child: Theme(
                                            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                                            child: Material(
                                              color: Colors.transparent,
                                              child: ExpansionTile(
                                                initiallyExpanded: true,
                                                tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                                                childrenPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                title: Row(
                                                  children: [
                                                    const Icon(Symbols.account_balance_wallet, color: Colors.blueGrey, size: 20),
                                                    const SizedBox(width: 8),
                                                    Expanded(
                                                      child: Text(
                                                        "$customerGroup • ${itemsInGroup.length} yêu cầu",
                                                        style: GoogleFonts.inter(
                                                          fontWeight: FontWeight.w600,
                                                          fontSize: 15,
                                                          color: Colors.blueGrey.shade800,
                                                        ),
                                                        overflow: TextOverflow.ellipsis,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                children: itemsInGroup.map((item) {
                                                  final isSelected = selectedRequest?.requestId == item.requestId;

                                                  return AnimatedContainer(
                                                    duration: const Duration(milliseconds: 250),
                                                    margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                                                    decoration: BoxDecoration(
                                                      color: isSelected ? Colors.blue.shade50 : Colors.white,
                                                      borderRadius: BorderRadius.circular(12),
                                                      border: Border.all(
                                                        color: isSelected ? Colors.blue.shade400 : Colors.grey.shade300,
                                                        width: isSelected ? 1.5 : 1,
                                                      ),
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color: Colors.black.withValues(alpha: 0.06),
                                                          blurRadius: 6,
                                                          offset: const Offset(0, 2),
                                                        ),
                                                      ],
                                                    ),
                                                    child: Material(
                                                      color: Colors.transparent,
                                                      child: ListTile(
                                                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                                        title: Row(
                                                          mainAxisSize: MainAxisSize.min,
                                                          children: [
                                                            Flexible(
                                                              child: Text(
                                                                "Yêu cầu: #${item.requestId}",
                                                                style: GoogleFonts.inter(
                                                                  fontWeight: FontWeight.w600,
                                                                  fontSize: 14,
                                                                ),
                                                            ),
                                                          ),
                                                          if (item.isUrgent) ...[
                                                            const SizedBox(width: 6),
                                                            Container(
                                                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                              decoration: BoxDecoration(
                                                                color: Colors.red.shade100,
                                                                borderRadius: BorderRadius.circular(4),
                                                              ),
                                                              child: Text(
                                                                "Khẩn cấp",
                                                                style: TextStyle(
                                                                  color: Colors.red.shade800,
                                                                  fontSize: 11,
                                                                  fontWeight: FontWeight.bold,
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ],
                                                      ),
                                                      subtitle: Padding(
                                                        padding: const EdgeInsets.only(top: 4),
                                                        child: Text(
                                                          "Người yêu cầu: ${item.requestedBy} • ${item.paymentMethod}",
                                                          style: GoogleFonts.inter(color: Colors.grey.shade700, fontSize: 13),
                                                        ),
                                                      ),
                                                      trailing: Text(
                                                        "${OrderModel.formatCurrency(item.amountRequested)} đ",
                                                        style: GoogleFonts.inter(
                                                          color: Colors.blue.shade700,
                                                          fontSize: 14,
                                                          fontWeight: FontWeight.bold,
                                                        ),
                                                      ),
                                                      selected: isSelected,
                                                      onTap: () => setState(() => selectedRequest = item),
                                                    ),
                                                  ),
                                                );
                                              }).toList(),
                                            ),
                                          ),
                                        ),
                                        );
                                      }).toList(),
                                    ),
                        ),
                      ],
                    ),
                  ),
                ),
                const VerticalDivider(width: 1),

                // CỘT PHẢI: Chi tiết & Nút duyệt
                Expanded(
                  flex: isSmallScreen ? 3 : 2,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: selectedRequest == null
                        ? Center(
                            key: const ValueKey("no-selection"),
                            child: Text(
                              "Chọn một yêu cầu cấn trừ để xem chi tiết",
                              style: GoogleFonts.inter(fontSize: 16, color: Colors.grey.shade700),
                            ),
                          )
                        : Padding(
                            key: ValueKey("detail-${selectedRequest!.requestId}"),
                            padding: const EdgeInsets.all(24.0),
                            child: Column(
                              children: [
                                Expanded(
                                  child: SingleChildScrollView(
                                    child: _buildDetailCard(selectedRequest!),
                                  ),
                                ),
                                const SizedBox(height: 16),

                                // Cụm nút duyệt chuẩn admin_order
                                Wrap(
                                  spacing: 10,
                                  runSpacing: 10,
                                  children: [
                                    // Phê duyệt
                                    AnimatedButton(
                                      onPressed: _processApprove,
                                      label: "Duyệt Đơn",
                                      icon: Icons.check,
                                      backgroundColor: const Color(0xFF2E7D32),
                                    ),

                                    // Duyệt OTP
                                    AnimatedButton(
                                      onPressed: _showOtpApprovalDialog,
                                      label: "Duyệt OTP",
                                      icon: Icons.security,
                                      backgroundColor: Colors.indigo.shade600,
                                    ),

                                    // Từ chối
                                    AnimatedButton(
                                      onPressed: _showRejectDialog,
                                      label: "Từ chối",
                                      icon: Icons.close,
                                      backgroundColor: Colors.red.shade600,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await _loadRequests();
          setState(() => selectedRequest = null);
        },
        backgroundColor: themeController.buttonColor.value,
        child: const Icon(Icons.refresh, color: Colors.white),
      ),
    );
  }

  Widget _infoRow(
    String label,
    String value, {
    Color? valueColor,
    FontWeight? valueFontWeight,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.inter(
                fontWeight: valueFontWeight ?? FontWeight.w500,
                color: valueColor ?? Colors.black87,
                fontSize: 16,
              ),
              softWrap: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailCard(DebtDeductionRequestModel req) {
    final leftRows = [
      _infoRow("🧾 Mã yêu cầu:", "#${req.requestId}"),
      _infoRow("👤 Khách hàng:", req.Customer?.customerName ?? req.customerId),
      _infoRow("🏢 Tên công ty:", req.Customer?.companyName ?? "-", valueColor: Colors.blueGrey),
      _infoRow("📅 Ngày tạo:", req.createdAt != null ? formatter.format(req.createdAt!) : "-"),
    ];

    final rightRows = [
      _infoRow(
        "💵 Số tiền cấn trừ:",
        "${NumberFormat("#,###", "vi_VN").format(req.amountRequested)} đ",
        valueColor: Colors.redAccent,
        valueFontWeight: FontWeight.bold,
      ),
      _infoRow("💳 Hình thức:", req.paymentMethod),
      _infoRow("🙋 Người yêu cầu:", req.requestedBy),
      _infoRow(
        "🚨 Mức độ:",
        req.isUrgent ? "Khẩn cấp (qua OTP Telegram)" : "Bình thường",
        valueColor: req.isUrgent ? Colors.red : Colors.green,
        valueFontWeight: req.isUrgent ? FontWeight.bold : FontWeight.normal,
      ),
    ];

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: Text(
                "📄 Thông tin yêu cầu cấn trừ công nợ",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueGrey,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: leftRows,
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: rightRows,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
