import 'package:dongtam/data/controller/badges_controller.dart';
import 'package:dongtam/data/controller/userController.dart';
import 'package:dongtam/service/admin_service.dart';
import 'package:dongtam/utils/helper/animated_button.dart';
import 'package:dongtam/utils/showSnackBar/show_snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dongtam/data/models/order/order_model.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';

class AdminOrder extends StatefulWidget {
  const AdminOrder({super.key});

  @override
  State<AdminOrder> createState() => _ManageOrderState();
}

class _ManageOrderState extends State<AdminOrder> {
  List<dynamic> orders = [];
  Order? selectedOrder;

  final badgesController = Get.find<BadgesController>();
  final userController = Get.find<UserController>();
  final formatter = DateFormat('dd/MM/yyyy');

  @override
  void initState() {
    super.initState();

    if (userController.hasAnyRole(["admin", "manager"])) {
      _loadOrders();
    }
  }

  Future<void> _loadOrders() async {
    final fetchedOrders = await AdminService().getOrderByStatus();
    setState(() {
      orders = fetchedOrders;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isAccept = userController.hasAnyRole(["admin", "manager"]);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF1F5F9), Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child:
            isAccept
                ? Row(
                  children: [
                    // order list
                    Expanded(
                      flex: 1,
                      child: Container(
                        color: Color(0xFFF8FAFC),
                        child:
                            orders.isEmpty
                                ? Center(
                                  child: Text(
                                    "Không có đơn hàng cần duyệt",
                                    style: GoogleFonts.inter(fontSize: 16),
                                  ),
                                )
                                : ListView.builder(
                                  itemCount: orders.length,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  itemBuilder: (context, index) {
                                    final ordersPending = orders[index];
                                    final isSelected =
                                        selectedOrder == ordersPending;
                                    return AnimatedContainer(
                                      duration: const Duration(
                                        milliseconds: 300,
                                      ),
                                      margin: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color:
                                            isSelected
                                                ? Colors.blue.shade50
                                                : Colors.white70,
                                        border: Border.all(
                                          color:
                                              isSelected
                                                  ? Colors.blue.shade400
                                                  : Colors.grey.shade300,
                                          width: isSelected ? 1.5 : 1,
                                        ),
                                        borderRadius: BorderRadius.circular(10),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(
                                              0.1,
                                            ),
                                            blurRadius: 8,
                                            offset: const Offset(1, 2),
                                          ),
                                        ],
                                      ),
                                      child: ListTile(
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                              horizontal: 16,
                                              vertical: 8,
                                            ),
                                        title: Text(
                                          "Mã đơn: ${ordersPending.orderId}",
                                          style: GoogleFonts.inter(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                        subtitle: Text(
                                          'Sản phẩm: ${ordersPending.product.productName}',
                                          style: GoogleFonts.inter(
                                            color: Colors.black,
                                            fontSize: 14,
                                          ),
                                        ),
                                        trailing: Text(
                                          'Tổng tiền: ${Order.formatCurrency(ordersPending.totalPrice)} đ',
                                          style: GoogleFonts.inter(
                                            color: Colors.blue.shade700,
                                            fontSize: 14,
                                          ),
                                        ),
                                        selected: isSelected,
                                        onTap:
                                            () => setState(
                                              () =>
                                                  selectedOrder = ordersPending,
                                            ),
                                      ),
                                    );
                                  },
                                ),
                      ),
                    ),
                    const VerticalDivider(width: 1),

                    // order detail
                    Expanded(
                      flex: 2,
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child:
                            selectedOrder == null
                                ? Center(
                                  key: const ValueKey('no-selection'),
                                  child: Text(
                                    'Chọn một đơn hàng để xem chi tiết',
                                    style: GoogleFonts.inter(fontSize: 16),
                                  ),
                                )
                                : Padding(
                                  key: const ValueKey('detail'),
                                  padding: const EdgeInsets.all(24.0),
                                  child: Column(
                                    children: [
                                      Expanded(
                                        child: SingleChildScrollView(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              rowOrder(),
                                              const SizedBox(height: 12),
                                              if (selectedOrder!.box != null)
                                                rowBox(),
                                            ],
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 16),

                                      //approve or reject
                                      Row(
                                        children: [
                                          //approve
                                          AnimatedButton(
                                            onPressed: () async {
                                              await AdminService()
                                                  .updateStatusOrder(
                                                    selectedOrder!.orderId,
                                                    'accept',
                                                    "",
                                                  );

                                              showSnackBarSuccess(
                                                context,
                                                'Phê duyệt thành công',
                                              );
                                              await _loadOrders();

                                              //cập nhật lại badge
                                              badgesController
                                                  .fetchPendingApprovals();

                                              setState(() {
                                                selectedOrder = null;
                                              });
                                            },
                                            label: 'Duyệt',
                                            icon: Icons.check,
                                          ),
                                          const SizedBox(width: 12),

                                          //reject
                                          AnimatedButton(
                                            onPressed: () {
                                              final TextEditingController
                                              reasonController =
                                                  TextEditingController();
                                              final formKey =
                                                  GlobalKey<FormState>();

                                              showDialog(
                                                context: context,
                                                builder: (context) {
                                                  return AlertDialog(
                                                    backgroundColor:
                                                        Colors.white,
                                                    title: const Text(
                                                      'Nhập lý do từ chối',
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 18,
                                                      ),
                                                    ),
                                                    content: SizedBox(
                                                      width: 350,
                                                      height: 80,
                                                      child: Form(
                                                        key: formKey,
                                                        child: TextFormField(
                                                          controller:
                                                              reasonController,
                                                          decoration: const InputDecoration(
                                                            hintText:
                                                                'Nhập lý do...',
                                                            border:
                                                                OutlineInputBorder(),
                                                          ),
                                                          validator: (value) {
                                                            if (value == null ||
                                                                value
                                                                    .trim()
                                                                    .isEmpty) {
                                                              return 'Vui lòng nhập lý do từ chối';
                                                            }
                                                            return null;
                                                          },
                                                        ),
                                                      ),
                                                    ),
                                                    actions: [
                                                      TextButton(
                                                        onPressed:
                                                            () => Navigator.pop(
                                                              context,
                                                            ),
                                                        child: const Text(
                                                          'Hủy',
                                                          style: TextStyle(
                                                            fontSize: 16,
                                                            color: Colors.black,
                                                          ),
                                                        ),
                                                      ),
                                                      ElevatedButton(
                                                        style:
                                                            ElevatedButton.styleFrom(
                                                              backgroundColor:
                                                                  Colors
                                                                      .red
                                                                      .shade600,
                                                            ),
                                                        onPressed: () async {
                                                          if (formKey
                                                              .currentState!
                                                              .validate()) {
                                                            Navigator.pop(
                                                              context,
                                                            );

                                                            await AdminService()
                                                                .updateStatusOrder(
                                                                  selectedOrder!
                                                                      .orderId,
                                                                  'reject',
                                                                  reasonController
                                                                      .text,
                                                                );

                                                            showSnackBarSuccess(
                                                              context,
                                                              "Từ chối phê duyệt thành công",
                                                            );

                                                            await _loadOrders();

                                                            //cập nhật lại badge
                                                            badgesController
                                                                .fetchPendingApprovals();

                                                            setState(() {
                                                              selectedOrder =
                                                                  null;
                                                            });
                                                          }
                                                        },
                                                        child: const Text(
                                                          'Xác nhận',
                                                          style: TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 16,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  );
                                                },
                                              );
                                            },
                                            label: 'Từ chối',
                                            icon: Icons.close,
                                            backgroundColor:
                                                Colors.red.shade600,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                      ),
                    ),
                  ],
                )
                : Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.lock_outline,
                        color: Colors.redAccent,
                        size: 35,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "Bạn không có quyền xem chức năng này",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 26,
                          color: Colors.redAccent,
                        ),
                      ),
                    ],
                  ),
                ),
      ),
      floatingActionButton:
          isAccept
              ? FloatingActionButton(
                onPressed: () async {
                  await _loadOrders();
                  setState(() {
                    selectedOrder = null;
                  });
                },
                backgroundColor: Color(0xff78D761),
                child: const Icon(Icons.refresh, color: Colors.white),
              )
              : null,
    );
  }

  Widget _infoRow(
    String label,
    String value, {
    String? unit,
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Text(
            label,
            style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(width: 8),
          Text(
            unit != null ? '$value $unit' : value,
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w500,
              color: valueColor ?? Colors.black87,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  String formatQuantity(String typeProduct) {
    final typeProduct = selectedOrder!.product!.typeProduct;
    if (typeProduct == "Thùng/hộp") {
      return "cái";
    } else if (typeProduct == "Giấy tấm" || typeProduct == "Giấy quấn cuồn") {
      return "m²";
    }
    return "kg";
  }

  Widget rowOrder() {
    final order = selectedOrder!;

    // Danh sách các _infoRow
    final infoRows = [
      _infoRow('🧾 Mã đơn:', order.orderId),
      _infoRow('📅 Ngày nhận:', formatter.format(order.dayReceiveOrder)),
      _infoRow('🚚 Ngày giao:', formatter.format(order.dateRequestShipping)),
      _infoRow('👤 Tên khách hàng:', order.customer!.customerName),
      _infoRow('🏢 Tên công ty:', order.customer!.companyName),
      _infoRow('📦 Loại sản phẩm:', order.product!.typeProduct),
      _infoRow('🛒 Tên sản phẩm:', order.product!.productName ?? ""),
      _infoRow('📦 Quy cách thùng:', order.QC_box.toString()),
      _infoRow('🔢 Cấn lằn:', order.canLan.toString()),
      _infoRow('🔪 Dao xả:', order.daoXa.toString()),
      _infoRow('🔧 Kết cấu:', order.formatterStructureOrder),
      _infoRow(
        '✂️ Cắt (KH):',
        Order.formatCurrency(order.lengthPaperCustomer),
        unit: "cm",
      ),
      _infoRow(
        '✂️ Cắt (SX) :',
        Order.formatCurrency(order.lengthPaperManufacture),
        unit: "cm",
      ),
      _infoRow(
        '📏 Khổ (KH):',
        Order.formatCurrency(order.paperSizeCustomer),
        unit: "cm",
      ),
      _infoRow(
        '📏 Khổ (SX):',
        Order.formatCurrency(order.paperSizeManufacture),
        unit: "cm",
      ),
      _infoRow(
        '🔢 Số lượng (KH):',
        order.quantityCustomer.toString(),
        unit: formatQuantity(order.product!.typeProduct),
      ),
      _infoRow(
        '🔢 Số lượng (SX):',
        order.quantityManufacture.toString(),
        unit: formatQuantity(order.product!.typeProduct),
      ),
      _infoRow(
        '📜 Số con:',
        Order.formatCurrency(order.numberChild),
        unit: "Con",
      ),
      _infoRow('📐 Đơn vị tính:', order.dvt),
      _infoRow(
        '🌍 Diện tích:',
        Order.formatCurrency(order.acreage),
        unit: 'm²',
      ),
      _infoRow('💲 Giá:', Order.formatCurrency(order.price), unit: "VNĐ"),
      _infoRow(
        '💵 Giá tấm:',
        Order.formatCurrency(order.pricePaper),
        unit: "VNĐ",
      ),
      _infoRow(
        '💵 Chiết khấu:',
        Order.formatCurrency(order.discount ?? 0),
        unit: "VNĐ",
      ),
      _infoRow(
        '💵 Lợi nhuận:',
        Order.formatCurrency(order.profit),
        unit: "VNĐ",
      ),
      _infoRow('💡 VAT:', order.vat.toString(), unit: "%"),
      _infoRow(
        '💰 Tổng tiền:',
        Order.formatCurrency(order.totalPrice),
        unit: "VNĐ",
      ),
    ];

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '📄 Thông tin đơn hàng',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.redAccent,
                  ),
                ),
                Text(
                  'Nhân Viên: ${order.user!.fullName}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.redAccent,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: infoRows.sublist(
                      0,
                      (infoRows.length / 2).ceil(),
                    ), // nửa đầu
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: infoRows.sublist(
                      (infoRows.length / 2).ceil(),
                    ), // nửa sau
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget rowBox() {
    final box = selectedOrder!.box!;
    final productImage = selectedOrder!.product?.productImage ?? '';
    final boolFields = [
      {'label': 'Cán màng', 'value': box.canMang},
      {'label': 'Xả', 'value': box.Xa},
      {'label': 'Cắt khe', 'value': box.catKhe},
      {'label': 'Bế', 'value': box.be},
      {'label': 'Dán 1 mảnh', 'value': box.dan_1_Manh},
      {'label': 'Dán 2 mảnh', 'value': box.dan_2_Manh},
      {'label': 'Chống thấm', 'value': box.chongTham},
      {'label': 'Đóng ghim 1 mảnh', 'value': box.dongGhim1Manh},
      {'label': 'Đóng ghim 2 mảnh', 'value': box.dongGhim2Manh},
    ];

    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: Text(
                '📦 Thông tin làm thùng',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.redAccent,
                ),
              ),
            ),
            const SizedBox(height: 20),

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // LEFT SIDE - INFO
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _infoRow('🧾 In mặt trước:', box.inMatTruoc.toString()),
                        _infoRow('🧾 In mặt sau:', box.inMatSau.toString()),
                        _infoRow('📦 Đóng gói:', box.dongGoi.toString()),
                        _infoRow('🔲 Mã khuôn:', box.maKhuon.toString()),
                        _infoRow(
                          '✨ HD đặc biệt:',
                          selectedOrder!.instructSpecial.toString(),
                        ),
                        const SizedBox(height: 15),

                        const Text(
                          '🛠️ Các yêu cầu tùy chỉnh:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),

                        for (int i = 0; i < boolFields.length; i += 3) ...[
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: Row(
                              children: [
                                for (
                                  int j = i;
                                  j < i + 3 && j < boolFields.length;
                                  j++
                                )
                                  Expanded(
                                    child: Row(
                                      children: [
                                        Icon(
                                          boolFields[j]['value'] as bool
                                              ? Icons.check_circle
                                              : Icons.cancel,
                                          color:
                                              boolFields[j]['value'] as bool
                                                  ? Colors.green
                                                  : Colors.red,
                                        ),
                                        const SizedBox(width: 4),
                                        Expanded(
                                          child: Text(
                                            boolFields[j]['label'] as String,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w500,
                                              color: Colors.black87,
                                              fontSize: 16,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                const SizedBox(width: 16),

                // RIGHT SIDE - IMAGE
                Expanded(
                  flex: 1,
                  child: SizedBox(
                    height: 300,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child:
                          productImage.isNotEmpty
                              ? Image.network(
                                productImage,
                                fit: BoxFit.contain,
                                errorBuilder:
                                    (context, error, stackTrace) =>
                                        const Center(
                                          child: Text(
                                            'Lỗi ảnh',
                                            style: TextStyle(fontSize: 16),
                                          ),
                                        ),
                              )
                              : const Center(
                                child: Text(
                                  "Không có hình",
                                  style: TextStyle(fontSize: 16),
                                ),
                              ),
                    ),
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
