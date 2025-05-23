import 'package:dongtam/presentation/components/dialog/dialog_planning_order.dart';
import 'package:dongtam/service/planning_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class WaitingForPlaning extends StatefulWidget {
  @override
  WaitingForPlaningState createState() => WaitingForPlaningState();
}

class WaitingForPlaningState extends State<WaitingForPlaning> {
  List<dynamic> plannedOrders = [];
  final formatter = DateFormat('dd/MM/yyyy');

  @override
  void initState() {
    super.initState();
    fetchPlannedOrders();
  }

  Future<void> fetchPlannedOrders() async {
    final fetchedOrders = await PlanningService().getOrderByStatus();
    setState(() {
      plannedOrders = fetchedOrders;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GridView.builder(
          itemCount: plannedOrders.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3, // 3 cột
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 2.8,
          ),
          itemBuilder: (context, index) {
            final orderAccept = plannedOrders[index];
            return Card(
              color: Colors.yellow.shade200,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Mã đơn hàng: ${orderAccept.orderId}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(height: 4),

                          Text(
                            'Tên công ty: ${orderAccept.customer.companyName}',
                            style: TextStyle(fontSize: 14),
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 4),

                          Text(
                            'Ngày nhận: ${formatter.format(orderAccept.dayReceiveOrder)} - Ngày giao: ${formatter.format(orderAccept.dateRequestShipping)}',
                            style: TextStyle(fontSize: 14),
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 4),

                          Text(
                            'Tên sản phẩm: ${orderAccept.product.productName}',
                            style: TextStyle(fontSize: 14),
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 4),

                          Text(
                            'Doanh số: ${orderAccept.totalPrice}',
                            style: TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder:
                                (_) => PLanningDialog(
                                  order: orderAccept,
                                  onPlanningOrder: fetchPlannedOrders,
                                ),
                          );
                        },
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 12,
                          ),
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          minimumSize: Size(0, 30),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          'Xem',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
