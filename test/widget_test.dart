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

    test("total price paper calculate", () {
      expect(Order.totalPricePaper(dvt: 'M2', length: 100, size: 50, price: 200), 100);
      expect(Order.totalPricePaper(dvt: 'Tấm', length: 200, size: 100, price: 500), 1000);
      expect(
        Order.totalPricePaper(
          dvt: 'Tấm Bao Khổ',
          length: 100,
          size: 200,
          price: 9999,
          pricePaper: 888,
        ),
        888,
      );
      expect(Order.totalPricePaper(dvt: 'Kg', length: 100, size: 200, price: 777), 777);
      expect(Order.totalPricePaper(dvt: 'Tấm Bao Khổ', length: 100, size: 100, price: 999), 0);
    });

    test('total price order', () {
      expect(Order.totalPriceOrder(5, 20), 100); // 5 * 20
      expect(Order.totalPriceOrder(0, 20), 0); // quantity = 0
      expect(Order.totalPriceOrder(10, 0), 0); // price = 0
      expect(Order.totalPriceOrder(-3, 50), -150); // quantity âm
      expect(Order.totalPriceOrder(1, 12.5), 12.5); // price thập phân
    });

    test('totalPriceAfterVAT', () {
      expect(Order.totalPriceAfterVAT(totalPrice: 100, vat: 0), equals(100)); // không VAT
      expect(Order.totalPriceAfterVAT(totalPrice: 100, vat: 10), closeTo(110, 0.0001)); // +10%
      expect(Order.totalPriceAfterVAT(totalPrice: 250, vat: 8), closeTo(270, 0.0001)); // +8%
      expect(
        Order.totalPriceAfterVAT(totalPrice: 1234.56, vat: 5),
        closeTo(1296.288, 0.0001),
      ); // kiểm sai số double
    });

    test("format currency", () {
      expect(Order.formatCurrency(1234567.89), '1,234,567.89');
      expect(Order.formatCurrency(0), '0');
      expect(Order.formatCurrency(1000), '1,000');
    });

    test("flute paper", () {
      // Đủ layers + E, B
      expect(
        Order.flutePaper(
          day: 'N150',
          matE: 'N150',
          matB: 'N150',
          matC: '',
          matE2: "N150",
          songE: "EN150",
          songB: "BMA140",
          songC: '',
          songE2: "EMA120",
        ),
        '7EEB',
      );
      // Chỉ có D và E
      expect(
        Order.flutePaper(
          day: 'D',
          matE: '',
          matB: '',
          matC: '',
          matE2: '',
          songE: 'E',
          songB: '',
          songC: '',
          songE2: '',
        ),
        '2E',
      );
      // Không có flute nào
      expect(
        Order.flutePaper(
          day: 'D',
          matE: '',
          matB: '',
          matC: '',
          matE2: '',
          songE: '',
          songB: '',
          songC: '',
          songE2: '',
        ),
        '1',
      );
    });
  });
}
