import 'package:dongtam/data/models/customer/customer_model.dart';
import 'package:dongtam/data/models/order/order_model.dart';
import 'package:dongtam/presentation/components/shared/dialog_shared.dart';
import 'package:dongtam/service/customer_service.dart';
import 'package:dongtam/service/debt_service.dart';
import 'package:dongtam/utils/extension/extension_helper.dart';
import 'package:dongtam/utils/handleError/api_exception.dart';
import 'package:dongtam/utils/handleError/show_snack_bar.dart';
import 'package:dongtam/presentation/components/shared/auto_complete_field.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:material_symbols_icons/symbols.dart';

enum PaymentMode { importFile, manualPayment, writeOffDebt }

class DialogPaymentDebt extends StatefulWidget {
  final String? customerId;
  final PaymentMode initialMode;
  final VoidCallback onPaymentSuccess;

  const DialogPaymentDebt({
    super.key,
    this.customerId,
    this.initialMode = PaymentMode.importFile,
    required this.onPaymentSuccess,
  });

  @override
  State<DialogPaymentDebt> createState() => _DialogPaymentDebtState();
}

class _DialogPaymentDebtState extends State<DialogPaymentDebt> {
  final _formKey = GlobalKey<FormState>();
  late PaymentMode _mode;
  late TextEditingController _customerIdController;
  final _amountController = TextEditingController();
  final _outboundCodesController = TextEditingController();
  final _slipCodeController = TextEditingController();

  PlatformFile? _selectedFile;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _mode = widget.initialMode;
    _customerIdController = TextEditingController(text: widget.customerId ?? '');
  }

  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx', 'xls', 'csv'],
      );

      if (result != null && result.files.isNotEmpty) {
        setState(() {
          _selectedFile = result.files.single;
        });
      }
    } catch (e) {
      if (mounted) {
        showSnackBarError(context, "Lỗi khi chọn file!");
      }
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  Future<void> _submit() async {
    switch (_mode) {
      case PaymentMode.importFile:
        await _submitImportFile();
        break;
      case PaymentMode.manualPayment:
        await _submitManualPayment();
        break;
      case PaymentMode.writeOffDebt:
        await _submitWriteOffDebt();
        break;
    }
  }

  /// Hàm dùng chung để xử lý Loading, Try-Catch và Thông báo
  Future<void> _executeTask({
    required Future<bool> Function() task,
    required String successMessage,
    required String errorMessage,
  }) async {
    setState(() => _isLoading = true);

    try {
      final success = await task();

      if (mounted) {
        if (success) {
          Navigator.of(context).pop();
          widget.onPaymentSuccess();
          showSnackBarSuccess(context, successMessage);
        } else {
          showSnackBarError(context, errorMessage);
        }
      }
    } on ApiException catch (e) {
      final errorText = switch (e.errorCode) {
        "OUTBOUND_NOT_FOUND" => e.message!,
        "EMPTY_FILE" => e.message!,
        "INVALID_EXCEL_ROW" => e.message!,
        _ => "Có lỗi xảy ra, vui lòng thử lại",
      };

      if (mounted) {
        // Navigator.pop(context); // đóng dialog loading
        showSnackBarError(context, errorText);
      }
    } catch (e) {
      if (mounted) showSnackBarError(context, errorMessage);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _submitImportFile() async {
    if (_selectedFile?.path == null) {
      showSnackBarError(context, "Vui lòng chọn file trước khi tải lên!");
      return;
    }

    final confirm = await showConfirmDialog(
      context: context,
      title: "Xác nhận tải file thanh toán",
      content: "Xác nhận tải file được chọn để cập nhật thanh toán?",
      confirmText: "Tải lên",
    );
    if (!confirm) return;

    await _executeTask(
      task: () => DebtService().importAmountPayment(_selectedFile!.path!),
      successMessage: "Tải file thanh toán thành công!",
      errorMessage: "Có lỗi xảy ra khi tải file thanh toán!",
    );
  }

  Future<void> _submitManualPayment() async {
    if (!_formKey.currentState!.validate()) return;

    final amountText = _amountController.text.trim().replaceAll(',', '');
    final amount = double.tryParse(amountText);
    final custId = _customerIdController.text.trim();

    if (amount == null || amount <= 0) {
      showSnackBarError(context, "Số tiền thanh toán không hợp lệ!");
      return;
    }

    final outboundSlipCodes =
        _outboundCodesController.text
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();

    final formattedAmount = OrderModel.formatCurrency(amount);
    final confirm = await showConfirmDialog(
      context: context,
      title: "Xác nhận thanh toán công nợ",
      content: "Xác nhận thanh toán $formattedAmount cho khách hàng $custId không?",
      confirmText: "Xác nhận",
    );
    if (!confirm) return;

    await _executeTask(
      task:
          () => DebtService().paymentDebtByCustomerId(
            customerId: custId,
            amount: amount,
            outboundSlipCodes: outboundSlipCodes,
          ),
      successMessage: "Thanh toán công nợ thành công!",
      errorMessage: "Có lỗi xảy ra khi thanh toán!",
    );
  }

  Future<void> _submitWriteOffDebt() async {
    if (!_formKey.currentState!.validate()) return;

    final slipCode = 'XKBH${_slipCodeController.trimmed}';

    final confirm = await showConfirmDialog(
      context: context,
      title: "Xác nhận xóa nợ",
      content: "Xác nhận xóa nợ cho phiếu xuất kho $slipCode không?",
      confirmText: "Xác nhận",
    );
    if (!confirm) return;

    await _executeTask(
      task: () => DebtService().writeOffDebt(outboundSlipCode: slipCode.toUpperCase()),
      successMessage: "Xóa công nợ thành công!",
      errorMessage: "Có lỗi xảy ra khi xóa nợ!",
    );
  }

  @override
  void dispose() {
    _customerIdController.dispose();
    _amountController.dispose();
    _outboundCodesController.dispose();
    _slipCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: const [
          Icon(Symbols.payment, color: Colors.green, size: 25),
          SizedBox(width: 8),
          Text("Thanh Toán Công Nợ", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
        ],
      ),
      content: Form(
        key: _formKey,
        child: SizedBox(
          width: 440,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Segmented Tab Bar
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    _buildTabButton(
                      mode: PaymentMode.importFile,
                      title: "Tải File",
                      icon: Symbols.file_upload,
                      activeColor: Colors.green,
                    ),
                    _buildTabButton(
                      mode: PaymentMode.manualPayment,
                      title: "Thủ Công",
                      icon: Symbols.auto_fix_high,
                      activeColor: Colors.green,
                    ),
                    _buildTabButton(
                      mode: PaymentMode.writeOffDebt,
                      title: "Xóa Nợ",
                      icon: Symbols.delete,
                      activeColor: Colors.redAccent,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // Nội dung tương ứng theo Tab mode
              AnimatedSize(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  switchInCurve: Curves.easeOut,
                  switchOutCurve: Curves.easeIn,
                  transitionBuilder: (Widget child, Animation<double> animation) {
                    return FadeTransition(
                      opacity: animation,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0.03, 0),
                          end: Offset.zero,
                        ).animate(animation),
                        child: child,
                      ),
                    );
                  },
                  child: _buildTabContent(),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text(
            "Hủy",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black54),
          ),
        ),
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          child: ElevatedButton(
            onPressed: _isLoading ? null : _submit,
            style: ElevatedButton.styleFrom(
              backgroundColor: _mode == PaymentMode.writeOffDebt ? Colors.redAccent : Colors.green,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child:
                _isLoading
                    ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                    : AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: Text(
                        _mode == PaymentMode.importFile
                            ? "Tải file Lên"
                            : _mode == PaymentMode.writeOffDebt
                            ? "Xóa Công Nợ"
                            : "Xác Nhận",
                        key: ValueKey(_mode),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
          ),
        ),
      ],
    );
  }

  // Hàm trả về giao diện nội dung tương ứng theo Tab mode
  Widget _buildTabContent() {
    switch (_mode) {
      case PaymentMode.importFile:
        return Column(
          key: const ValueKey(PaymentMode.importFile),
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.green.shade700, size: 20),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      "Chọn file Excel (.xlsx, .xls) hoặc CSV chứa danh sách thanh toán để tải lên.",
                      style: TextStyle(fontSize: 13, color: Colors.black87),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            InkWell(
              onTap: _isLoading ? null : _pickFile,
              borderRadius: BorderRadius.circular(12),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                decoration: BoxDecoration(
                  color:
                      _selectedFile == null
                          ? Colors.green.shade50.withValues(alpha: 0.5)
                          : Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _selectedFile == null ? Colors.green.shade400 : Colors.grey.shade300,
                    width: _selectedFile == null ? 1.5 : 1,
                  ),
                ),
                child:
                    _selectedFile == null
                        ? Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Symbols.cloud_upload, color: Colors.green.shade700, size: 36),
                            const SizedBox(height: 8),
                            const Text(
                              "Nhấn để chọn file thanh toán",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        )
                        : Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.green.shade100,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Symbols.table_chart, color: Colors.green, size: 24),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _selectedFile!.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                      color: Colors.black87,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    _formatFileSize(_selectedFile!.size),
                                    style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close, color: Colors.redAccent, size: 20),
                              onPressed: () => setState(() => _selectedFile = null),
                            ),
                          ],
                        ),
              ),
            ),
          ],
        );

      case PaymentMode.manualPayment:
        return Column(
          key: const ValueKey(PaymentMode.manualPayment),
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AutoCompleteField<CustomerModel>(
              controller: _customerIdController,
              labelText: "Mã Khách Hàng",
              icon: Symbols.badge,
              iconColor: Colors.green,
              suggestionsCallback: (pattern) async {
                final result = await CustomerService().getCustomers(
                  field: "customerId",
                  keyword: pattern,
                );
                if (result["customers"] != null && result["customers"] is List<CustomerModel>) {
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
            const SizedBox(height: 14),

            TextFormField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                TextInputFormatter.withFunction((oldValue, newValue) {
                  if (newValue.text.isEmpty) return newValue;

                  // Lấy chuỗi chỉ gồm chữ số
                  final digitsOnly = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
                  if (digitsOnly.isEmpty) return newValue.copyWith(text: '');

                  // Parse sang kiểu num
                  final parsed = num.tryParse(digitsOnly);
                  if (parsed == null) return oldValue;

                  final formatted = OrderModel.formatCurrency(parsed);

                  return TextEditingValue(
                    text: formatted,
                    selection: TextSelection.collapsed(offset: formatted.length),
                  );
                }),
              ],
              decoration: InputDecoration(
                labelText: "Số tiền thanh toán (VNĐ)",
                labelStyle: const TextStyle(fontSize: 15),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                prefixIcon: const Icon(Icons.attach_money, color: Colors.green),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return "Vui lòng nhập số tiền thanh toán";
                }
                final parsed = double.tryParse(value.trim().replaceAll(',', ''));
                if (parsed == null || parsed <= 0) {
                  return "Số tiền phải lớn hơn 0";
                }
                return null;
              },
            ),
            const SizedBox(height: 14),

            TextFormField(
              controller: _outboundCodesController,
              decoration: InputDecoration(
                labelText: "Mã phiếu xuất kho (tùy chọn)",
                hintText: "VD: OB001, OB002",
                labelStyle: const TextStyle(fontSize: 15),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                prefixIcon: const Icon(Icons.receipt_long, color: Colors.green),
              ),
            ),
          ],
        );

      case PaymentMode.writeOffDebt:
        return Column(
          key: const ValueKey(PaymentMode.writeOffDebt),
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: _slipCodeController,
              decoration: InputDecoration(
                labelText: "Nhập mã phiếu xuất kho",
                prefixText: "XKBH",
                labelStyle: const TextStyle(fontSize: 15),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                prefixIcon: const Icon(Icons.confirmation_number_outlined, color: Colors.redAccent),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return "Vui lòng nhập mã PXK";
                }
                return null;
              },
            ),
          ],
        );
    }
  }

  // Widget con để rút gọn code nút tab
  Widget _buildTabButton({
    required PaymentMode mode,
    required String title,
    required IconData icon,
    required Color activeColor,
  }) {
    final bool isSelected = _mode == mode;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _mode = mode),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 9),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            boxShadow:
                isSelected
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
              Icon(icon, size: 18, color: isSelected ? activeColor : Colors.black54),
              const SizedBox(width: 4),
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: isSelected ? activeColor : Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
