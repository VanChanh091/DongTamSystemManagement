import 'package:dongtam/service/admin_Service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dongtam/data/models/order/order_model.dart';
import 'package:intl/intl.dart';

class AdminOrder extends StatefulWidget {
  const AdminOrder({super.key});

  @override
  State<AdminOrder> createState() => _ManageOrderState();
}

class _ManageOrderState extends State<AdminOrder> {
  List<dynamic> orders = [];
  Order? selectedOrder;
  final formatter = DateFormat('dd/MM/yyyy');

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    final fetchedOrders = await AdminService().getOrderByStatus();
    print(fetchedOrders);
    setState(() {
      orders = fetchedOrders;
    });
  }

  Widget rowOrder() {
    final order = selectedOrder!;
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '📄 Thông tin đơn hàng',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 12),
            _infoRow('🧾 Mã đơn:', order.orderId),
            _infoRow('🧾 Ngày nhận:', formatter.format(order.dayReceiveOrder)),
            _infoRow(
              '👤 Ngày giao:',
              formatter.format(order.dateRequestShipping),
            ),
            _infoRow('👤 Tên khách hàng:', order.customer!.customerName),
            _infoRow('🧾 Tên công ty:', order.customer!.cskh),
            _infoRow('👤 Loại sản phẩm:', order.product!.typeProduct),
            _infoRow('🧾 Tên sản phẩm:', order.product!.productName),
            _infoRow('👤 Quy cách thùng:', order.QC_box.toString()),
            _infoRow('🧾 Cấn lằn:', order.canLan.toString()),
            _infoRow('👤 Dao xả:', order.daoXa.toString()),
            _infoRow('🧾 Kết cấu đặt hàng:', order.formatterStructureOrder),
            _infoRow('👤 Cắt:', Order.formatCurrency(order.lengthPaper)),
            _infoRow('🧾 Khổ:', Order.formatCurrency(order.paperSize)),
            _infoRow('👤 Số lượng:', order.quantity.toString()),
            _infoRow('🧾 Đơn vị tính:', order.dvt),
            _infoRow('👤 Diện tích:', Order.formatCurrency(order.acreage)),
            _infoRow('🧾 Giá:', Order.formatCurrency(order.price)),
            _infoRow('👤 Giá tấm:', Order.formatCurrency(order.pricePaper)),
            _infoRow('🧾 VAT:', order.vat.toString()),
            _infoRow('👤 Tổng tiền:', Order.formatCurrency(order.totalPrice)),
          ],
        ),
      ),
    );
  }

  Widget rowBox() {
    final box = selectedOrder!.box!;
    final boolFields = [
      {'label': 'Cấn màng', 'value': box.canMang},
      {'label': 'Xả', 'value': box.Xa},
      {'label': 'Cắt khe', 'value': box.catKhe},
      {'label': 'Bế', 'value': box.be},
      {'label': 'Dán 1 mảnh', 'value': box.dan_1_Manh},
      {'label': 'Dán 2 mảnh', 'value': box.dan_2_Manh},
      {'label': 'Đóng ghim 1 mảnh', 'value': box.dongGhim1Manh},
      {'label': 'Đóng ghim 2 mảnh', 'value': box.dongGhim2Manh},
      {'label': 'Chống thấm', 'value': box.chongTham},
    ];

    return Card(
      elevation: 3,
      color: Colors.white,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Text(
                  '📦 Thông tin thùng',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.blueAccent,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            for (int i = 0; i < boolFields.length; i += 3) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  for (int j = i; j < i + 3 && j < boolFields.length; j++)
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
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              boolFields[j]['label'] as String,
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                                color: Colors.black87,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
            ],

            const SizedBox(height: 10),
            _infoRow('In mặt trước:', box.inMatTruoc.toString()),
            _infoRow('In mặt sau:', box.inMatSau.toString()),
            _infoRow('Đóng gói:', box.dongGoi.toString()),
            _infoRow('Mã khuôn:', box.maKhuon.toString()),
            _infoRow('HD đặc biệt:', selectedOrder!.instructSpecial.toString()),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF1F5F9), Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Row(
          children: [
            // order list
            Expanded(
              flex: 1,
              child: Container(
                color: Color(0xFFF8FAFC),
                child: ListView.builder(
                  itemCount: orders.length,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  itemBuilder: (context, index) {
                    final ordersPending = orders[index];
                    final isSelected = selectedOrder == ordersPending;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color:
                            isSelected ? Colors.blue.shade50 : Colors.white70,
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
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(1, 2),
                          ),
                        ],
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        title: Text(
                          "ID: ${ordersPending.orderId}",
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
                            () => setState(() => selectedOrder = ordersPending),
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
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '📋 Chi tiết đơn hàng',
                                        style: GoogleFonts.inter(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF0F172A),
                                        ),
                                      ),
                                      const SizedBox(height: 16),

                                      rowOrder(),
                                      const SizedBox(height: 12),
                                      rowBox(),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green.shade600,
                                    ),
                                    onPressed: () {
                                      AdminService().updateStatusOrder(
                                        selectedOrder!.orderId,
                                        'reject',
                                      );
                                      _showSnackBar(
                                        context,
                                        'Phê duyệt thành công',
                                      );
                                    },
                                    icon: const Icon(
                                      Icons.check,
                                      color: Colors.white,
                                    ),
                                    label: Text(
                                      'Duyệt',
                                      style: GoogleFonts.inter(
                                        color: Colors.white,
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red.shade600,
                                    ),
                                    onPressed: () {
                                      AdminService().updateStatusOrder(
                                        selectedOrder!.orderId,
                                        'accept',
                                      );
                                      _showSnackBar(
                                        context,
                                        'Từ chối phê duyệt thành công',
                                      );
                                    },
                                    icon: const Icon(
                                      Icons.close,
                                      color: Colors.white,
                                    ),
                                    label: Text(
                                      'Từ chối',
                                      style: GoogleFonts.inter(
                                        color: Colors.white,
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            _loadOrders();
          });
        },
        backgroundColor: Colors.blue.shade700,
        child: const Icon(Icons.refresh, color: Colors.white),
      ),
    );
  }

  Widget _infoRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Text(label, style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
          const SizedBox(width: 8),
          Text(
            value,
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w500,
              color: valueColor ?? Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}

// Hàm hiển thị SnackBar
void _showSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message, style: GoogleFonts.inter(color: Colors.white)),
      backgroundColor: Colors.blue.shade600,
      duration: const Duration(seconds: 2),
    ),
  );
}
