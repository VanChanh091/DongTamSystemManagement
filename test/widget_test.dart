// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:dongtam/data/models/order/order_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  //order
  group("Order test method", () {
    test("acreage calculate", () {
      // bình thường
      expect(Order.acreagePaper(200, 300, 10), 60);
      // quantity = 0
      expect(Order.acreagePaper(200, 300, 0), 0);
      // length = 0
      expect(Order.acreagePaper(0, 300, 10), 0);
    });

    // test("total price paper calculate", () {
    //   // DVT đặc biệt
    //   expect(Order.totalPricePaper('Kg', 100, 50, 200), 200);
    //   expect(Order.totalPricePaper('Cái', 100, 50, 500), 500);

    //   // DVT chuẩn
    //   expect(
    //     Order.totalPricePaper('M2', 100, 50, 200),
    //     100,
    //   ); // 100*50*200/10000
    //   expect(Order.totalPricePaper('M2', 0, 50, 200), 0); // length = 0
    //   expect(Order.totalPricePaper('M2', 100, 0, 200), 0); // size = 0
    // });

    test("total price order", () {
      expect(Order.totalPriceOrder(5, 20), 100);
      expect(Order.totalPriceOrder(0, 20), 0); // quantity = 0
      expect(Order.totalPriceOrder(10, 0), 0); // price = 0
    });

    test("format currency", () {
      expect(Order.formatCurrency(1234567.89), '1,234,567.89');
      expect(Order.formatCurrency(0), '0');
      expect(Order.formatCurrency(1000), '1,000');
    });

    test("flute paper", () {
      // Đủ layers + E, B
      expect(Order.flutePaper('D', 'M1', '', 'Mat', 'E', 'B', '', ''), '5EB');
      // Chỉ có D và E
      expect(Order.flutePaper('D', '', '', '', 'E', '', '', ''), '2E');
      // Không có flute nào
      expect(Order.flutePaper('D', '', '', '', '', '', '', ''), '1');
    });
  });
}
