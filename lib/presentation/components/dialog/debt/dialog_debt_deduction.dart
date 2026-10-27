import "package:dongtam/data/controller/theme_controller.dart";
import "package:dongtam/data/models/customer/customer_model.dart";
import "package:dongtam/data/models/order/order_model.dart";
import "package:dongtam/data/models/warehouse/debt_deduction_request_model.dart";
import "package:dongtam/presentation/components/shared/auto_complete_field.dart";
import "package:dongtam/presentation/components/shared/base_validate_input.dart";
import "package:dongtam/presentation/components/shared/dialog_shared.dart";
import "package:dongtam/service/customer_service.dart";
import "package:dongtam/service/debt_service.dart";
import "package:dongtam/utils/handleError/api_exception.dart";
import "package:dongtam/utils/handleError/show_snack_bar.dart";
import "package:dongtam/utils/helper/helper_model.dart";
import "package:dongtam/utils/logger/app_logger.dart";
import "package:dongtam/utils/validation/validation_helper.dart";
import "package:flutter/material.dart";
import "package:get/get.dart";
import "package:material_symbols_icons/symbols.dart";

class DialogDebtDeduction extends StatefulWidget {
  final DebtDeductionRequestModel? debtDeduction;
  final VoidCallback onSuccess;

  const DialogDebtDeduction({super.key, this.debtDeduction, required this.onSuccess});

  @override
  State<DialogDebtDeduction> createState() => _DialogDebtDeductionState();
}

class _DialogDebtDeductionState extends State<DialogDebtDeduction> {
  final _formKey = GlobalKey<FormState>();
  final themeController = Get.find<ThemeController>();
  final _customerIdController = TextEditingController();
  final _amountController = TextEditingController();

  String paymentMethod = "Chuyển khoản";
  final List<String> paymentMethodList = ["Chuyển khoản", "Tiền mặt"];
  Map<String, String> convertPaymentMethod = {"Chuyển khoản": "bank_transfer", "Tiền mặt": "cash"};

  bool _isLoading = false;
  bool get isEdit => widget.debtDeduction != null;

  @override
  void initState() {
    super.initState();
    if (widget.debtDeduction != null) {
      final item = widget.debtDeduction!;
      _customerIdController.text = item.customerId;
      _amountController.text = OrderModel.formatCurrency(item.amountRequested);

      // Convert payment method từ backend về frontend (nếu BE trả về bank_transfer/cash)
      final feEntry =
          convertPaymentMethod.entries.where((e) => e.value == item.paymentMethod).firstOrNull;
      if (feEntry != null) {
        paymentMethod = feEntry.key;
      } else if (convertPaymentMethod.containsKey(item.paymentMethod)) {
        paymentMethod = item.paymentMethod;
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
    _customerIdController.dispose();
    _amountController.dispose();
  }

  Future<void> _submit() async {
    if (_customerIdController.text.trim().isEmpty) {
      showSnackBarError(context, "Vui lòng chọn hoặc nhập mã khách hàng");
      return;
    }
    if (!_formKey.currentState!.validate()) return;

    final customerId = _customerIdController.text.trim();
    final amount = toDouble(_amountController.text);

    setState(() => _isLoading = true);

    final methodToSend = convertPaymentMethod[paymentMethod] ?? paymentMethod;

    // Show loading
    if (!mounted) return;
    showLoadingDialog(context, message: "Đang tạo yêu cầu...");
    await Future.delayed(const Duration(seconds: 1));

    try {
      bool success = false;
      if (isEdit) {
        success = await DebtService().updateDebtDeduction(
          requestId: widget.debtDeduction!.requestId,
          amountRequested: amount,
          paymentMethod: methodToSend,
        );
      } else {
        success = await DebtService().createDebtDeduction(
          customerId: customerId,
          amountRequested: amount,
          paymentMethod: methodToSend,
        );
      }

      if (success && mounted) {
        Navigator.pop(context); // đóng dialog loading

        showSnackBarSuccess(
          context,
          isEdit ? "Cập nhật yêu cầu thành công!" : "Tạo yêu cầu cấn trừ nợ thành công!",
        );

        widget.onSuccess();
        Navigator.of(context).pop(); // đóng dialog chính
      }
    } on ApiException catch (e) {
      final errorText = switch (e.errorCode) {
        "CANNOT_UPDATE_OTHERS_REQUEST" => e.message!,
        _ => "Có lỗi xảy ra, vui lòng thử lại",
      };

      if (mounted) {
        Navigator.pop(context); // đóng dialog loading
        showSnackBarError(context, errorText);
      }
    } catch (e, s) {
      AppLogger.e("Lỗi thao tác yêu cầu cấn trừ nợ", error: e, stackTrace: s);
      if (mounted) {
        Navigator.pop(context); // đóng dialog loading
        showSnackBarError(context, "Có lỗi xảy ra: $e");
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      title: Row(
        children: [
          Icon(
            isEdit ? Symbols.edit_document : Symbols.add_circle,
            color: themeController.currentColor.value,
          ),
          const SizedBox(width: 8),
          Text(
            isEdit ? "Sửa Yêu Cầu Cấn Trừ Nợ" : "Tạo Yêu Cầu Cấn Trừ Nợ",
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
        ],
      ),
      content: SizedBox(
        width: 400,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Mã khách hàng
              if (isEdit)
                TextFormField(
                  controller: _customerIdController,
                  enabled: false,
                  decoration: InputDecoration(
                    labelText: "Mã Khách Hàng",
                    labelStyle: TextStyle(fontWeight: FontWeight.bold),
                    prefixIcon: Icon(Symbols.badge, color: Colors.grey),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    filled: true,
                    fillColor: Color(0xFFF1F5F9),
                  ),
                )
              else
                AutoCompleteField<CustomerModel>(
                  controller: _customerIdController,
                  labelText: "Mã Khách Hàng",
                  icon: Symbols.badge,
                  iconColor: themeController.currentColor.value,
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
              const SizedBox(height: 16),

              // Số tiền yêu cầu
              BaseValidateInput(
                label: "Số Tiền Yêu Cầu (VNĐ)",
                controller: _amountController,
                icon: Icons.payments,
                iconColor: themeController.currentColor.value,
                isNumberOnly: true,
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return "Vui lòng nhập số tiền";
                  }
                  final numVal = toDouble(val);
                  if (numVal <= 0) {
                    return "Số tiền yêu cầu phải lớn hơn 0";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Kiểu thanh toán
              ValidationHelper.dropdownForTypes(
                type: paymentMethod,
                items: paymentMethodList,
                onChanged: (value) {
                  setState(() {
                    paymentMethod = value!;
                  });
                },
              ),
            ],
          ),
        ),
      ),

      actions: buildDialogActions(
        context: context,
        confirmColor: themeController.currentColor.value,
        onConfirm: _isLoading ? null : _submit,
      ),
    );
  }
}
