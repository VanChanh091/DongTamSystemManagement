import "package:dongtam/data/models/customer/customer_model.dart";
import "package:dongtam/presentation/components/shared/dialog_shared.dart";
import "package:dongtam/service/customer_service.dart";
import "package:dongtam/service/debt_service.dart";
import "package:dongtam/utils/handleError/show_snack_bar.dart";
import "package:dongtam/presentation/components/shared/auto_complete_field.dart";
import "package:flutter/material.dart";
import "package:intl/intl.dart";
import "package:material_symbols_icons/symbols.dart";

enum ClosingDebtMode { auto, manual }

class DialogClosingDebt extends StatefulWidget {
  final String? customerId;
  final VoidCallback onClosingSuccess;

  const DialogClosingDebt({super.key, this.customerId, required this.onClosingSuccess});

  @override
  State<DialogClosingDebt> createState() => _DialogClosingDebtState();
}

class _DialogClosingDebtState extends State<DialogClosingDebt> {
  final _formKey = GlobalKey<FormState>();

  late ClosingDebtMode _mode;
  late TextEditingController _customerIdController;
  DateTime _selectedDate = DateTime.now();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _mode =
        (widget.customerId != null && widget.customerId!.isNotEmpty)
            ? ClosingDebtMode.manual
            : ClosingDebtMode.auto;
    _customerIdController = TextEditingController(text: widget.customerId ?? "");
  }

  @override
  void dispose() {
    _customerIdController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_mode == ClosingDebtMode.manual) {
      if (!_formKey.currentState!.validate()) return;
    }

    final formattedDate = DateFormat("dd/MM/yyyy").format(_selectedDate);
    final targetCustId = _customerIdController.text.trim();

    final confirm = await showConfirmDialog(
      context: context,
      title: "Xác nhận chốt công nợ",
      content: "Xác nhận chọn ngày $formattedDate để chốt công nợ?",
      confirmText: "Xác nhận",
    );

    if (!confirm) return;
    setState(() => _isLoading = true);

    try {
      final success = await DebtService().handleClosingDebt(
        targetDate: _selectedDate,
        isAuto: _mode == ClosingDebtMode.auto,
        customerId: _mode == ClosingDebtMode.manual ? targetCustId : null,
      );

      if (success && mounted) {
        Navigator.of(context).pop();
        widget.onClosingSuccess();
        showSnackBarSuccess(context, "Chốt công nợ thành công!");
      }
    } catch (e) {
      if (mounted) {
        showSnackBarError(context, "Có lỗi xảy ra khi chốt công nợ!");
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),

      title: Row(
        children: const [
          Icon(Symbols.attach_money, color: Colors.blue, size: 25),
          SizedBox(width: 5),
          Text("Chốt Công Nợ", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
        ],
      ),

      content: Form(
        key: _formKey,
        child: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Segmented Tab Selector
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _mode = ClosingDebtMode.auto),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color:
                                _mode == ClosingDebtMode.auto ? Colors.white : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow:
                                _mode == ClosingDebtMode.auto
                                    ? [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.05),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ]
                                    : [],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Symbols.auto_mode,
                                size: 20,
                                color: _mode == ClosingDebtMode.auto ? Colors.blue : Colors.black54,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                "Tự Động",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color:
                                      _mode == ClosingDebtMode.auto ? Colors.blue : Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _mode = ClosingDebtMode.manual),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color:
                                _mode == ClosingDebtMode.manual ? Colors.white : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow:
                                _mode == ClosingDebtMode.manual
                                    ? [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.05),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ]
                                    : [],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Symbols.auto_fix_high,
                                size: 20,
                                color:
                                    _mode == ClosingDebtMode.manual ? Colors.blue : Colors.black54,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                "Thủ Công",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color:
                                      _mode == ClosingDebtMode.manual
                                          ? Colors.blue
                                          : Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // Chuyển đổi giữa 2 tab
              AnimatedCrossFade(
                firstChild: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue.shade700, size: 20),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Text(
                          "Hệ thống sẽ tự động chốt công nợ cho tất cả khách hàng đến ngày được chọn.",
                          style: TextStyle(fontSize: 13, color: Colors.black87),
                        ),
                      ),
                    ],
                  ),
                ),

                secondChild: Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: AutoCompleteField<CustomerModel>(
                    controller: _customerIdController,
                    labelText: "Mã Khách Hàng",
                    icon: Symbols.badge,
                    iconColor: Colors.blue,
                    suggestionsCallback: (pattern) async {
                      final result = await CustomerService().getCustomers(
                        field: "customerId",
                        keyword: pattern,
                      );
                      if (result["customers"] != null &&
                          result["customers"] is List<CustomerModel>) {
                        return result["customers"] as List<CustomerModel>;
                      }

                      return [];
                    },
                    displayStringForItem: (customer) => customer.customerId,
                    itemBuilder: (context, customer) {
                      return Material(
                        color: Colors.transparent,
                        child: ListTile(
                          title: Text(customer.customerId),
                          subtitle: Text(customer.customerName),
                        ),
                      );
                    },
                    onSelected: (customer) {
                      _customerIdController.text = customer.customerId;
                    },
                  ),
                ),
                crossFadeState:
                    _mode == ClosingDebtMode.auto
                        ? CrossFadeState.showFirst
                        : CrossFadeState.showSecond,
                duration: const Duration(milliseconds: 200),
              ),

              const SizedBox(height: 16),

              // Date Picker
              InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime(2025),
                    lastDate: DateTime.now(),
                    builder: (context, child) {
                      return Theme(
                        data: Theme.of(context).copyWith(
                          dialogTheme: const DialogThemeData(backgroundColor: Colors.white),
                          colorScheme: const ColorScheme.light(
                            primary: Colors.blue,
                            onPrimary: Colors.white,
                            surface: Colors.white,
                            onSurface: Colors.black87,
                          ),
                        ),
                        child: child!,
                      );
                    },
                  );
                  if (picked != null) {
                    setState(() => _selectedDate = picked);
                  }
                },
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: "Ngày chốt công nợ",
                    labelStyle: const TextStyle(fontSize: 15),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    prefixIcon: const Icon(Icons.calendar_today, color: Colors.blue),
                  ),
                  child: Text(
                    DateFormat("dd/MM/yyyy").format(_selectedDate),
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),

      actions: buildDialogActions(context: context, isLoading: _isLoading, onConfirm: _submit),
    );
  }
}
