import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AdminOrder extends StatefulWidget {
  const AdminOrder({super.key});

  @override
  State<AdminOrder> createState() => _ManageOrderState();
}

class Order {
  final String id;
  final String customer;
  final String date;
  final double total;

  Order({
    required this.id,
    required this.customer,
    required this.date,
    required this.total,
  });
}

class _ManageOrderState extends State<AdminOrder> {
  List<Order> orders = [
    Order(
      id: 'DH001',
      customer: 'Nguyễn Văn A',
      date: '28/04/2025',
      total: 120000,
    ),
    Order(
      id: 'DH002',
      customer: 'Trần Thị B',
      date: '29/04/2025',
      total: 550000,
    ),
    Order(id: 'DH003', customer: 'Lê Văn C', date: '29/04/2025', total: 235000),
    Order(
      id: 'DH004',
      customer: 'Phạm Thị D',
      date: '30/04/2025',
      total: 780000,
    ),
    Order(
      id: 'DH005',
      customer: 'Hoàng Văn E',
      date: '30/04/2025',
      total: 95000,
    ),
    Order(
      id: 'DH006',
      customer: 'Hoàng Văn E',
      date: '30/04/2025',
      total: 95000,
    ),
    Order(
      id: 'DH007',
      customer: 'Hoàng Văn E',
      date: '30/04/2025',
      total: 95000,
    ),
    Order(
      id: 'DH008',
      customer: 'Hoàng Văn E',
      date: '30/04/2025',
      total: 95000,
    ),
    Order(
      id: 'DH009',
      customer: 'Hoàng Văn E',
      date: '30/04/2025',
      total: 95000,
    ),
  ];

  Order? selectedOrder;

  void _refreshOrders() {
    setState(() {
      // Giả sử làm mới dữ liệu đơn hàng ở đây
      orders = [
        Order(
          id: 'DH001',
          customer: 'Nguyễn Văn A',
          date: '28/04/2025',
          total: 120000,
        ),
        Order(
          id: 'DH002',
          customer: 'Trần Thị B',
          date: '29/04/2025',
          total: 550000,
        ),
        Order(
          id: 'DH003',
          customer: 'Lê Văn C',
          date: '29/04/2025',
          total: 235000,
        ),
        Order(
          id: 'DH004',
          customer: 'Phạm Thị D',
          date: '30/04/2025',
          total: 780000,
        ),
        Order(
          id: 'DH005',
          customer: 'Hoàng Văn E',
          date: '30/04/2025',
          total: 95000,
        ),
      ]; // Ví dụ làm mới, bạn có thể thay đổi để lấy từ API hoặc nguồn dữ liệu khác
    });
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
                    final order = orders[index];
                    final isSelected = selectedOrder == order;
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
                          order.id,
                          style: GoogleFonts.inter(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          order.customer,
                          style: GoogleFonts.inter(),
                        ),
                        trailing: Text(
                          '${order.total.toStringAsFixed(0)} đ',
                          style: GoogleFonts.inter(color: Colors.blue.shade700),
                        ),
                        selected: isSelected,
                        onTap: () => setState(() => selectedOrder = order),
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
                            crossAxisAlignment: CrossAxisAlignment.start,
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
                              _infoRow('🧾 Mã đơn:', selectedOrder!.id),
                              _infoRow(
                                '👤 Khách hàng:',
                                selectedOrder!.customer,
                              ),
                              _infoRow('📅 Ngày đặt:', selectedOrder!.date),
                              _infoRow(
                                '💵 Tổng tiền:',
                                '${selectedOrder!.total.toStringAsFixed(0)} đ',
                                valueColor: Colors.blue,
                              ),
                              const Spacer(),
                              Row(
                                children: [
                                  ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red.shade600,
                                    ),
                                    onPressed: () {
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
                                  const SizedBox(width: 12),
                                  ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green.shade600,
                                    ),
                                    onPressed: () {
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
        onPressed: _refreshOrders,
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
