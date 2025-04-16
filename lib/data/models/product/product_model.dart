class Product {
  String productId;
  String typeProduct;
  String productName;
  String maKhuon;

  Product({
    required this.productId,
    required this.typeProduct,
    required this.productName,
    required this.maKhuon,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      productId: json['productId'] ?? 'CUSTOM',
      typeProduct: json['typeProduct'] ?? "",
      productName: json['productName'] ?? "",
      maKhuon: json['maKhuon'] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'prefix': productId,
      'typeProduct': typeProduct,
      'productName': productName,
      'maKhuon': maKhuon,
    };
  }
}
