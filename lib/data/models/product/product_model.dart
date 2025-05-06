class Product {
  String productId;
  String typeProduct;
  String productName;
  String maKhuon;
  String? productImage;

  Product({
    required this.productId,
    required this.typeProduct,
    required this.productName,
    required this.maKhuon,
    this.productImage,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      productId: json['productId'] ?? 'CUSTOM',
      typeProduct: json['typeProduct'] ?? "",
      productName: json['productName'] ?? "",
      maKhuon: json['maKhuon'] ?? "",
      productImage: json['productImage'] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'prefix': productId,
      'typeProduct': typeProduct,
      'productName': productName,
      'maKhuon': maKhuon,
      'productImage': productImage,
    };
  }
}
