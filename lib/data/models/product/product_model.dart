class ProductModel {
  String productId;
  String typeProduct;
  String? productName;
  String? maKhuon;
  String? productImage;
  int? layerCount;
  String? wave;

  ProductModel({
    required this.productId,
    required this.typeProduct,
    this.productName,
    this.maKhuon,
    this.productImage,
    this.layerCount,
    this.wave,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      productId: json["productId"] ?? "CUSTOM",
      typeProduct: json["typeProduct"] ?? "",
      productName: json["productName"] ?? "",
      maKhuon: json["maKhuon"] ?? "",
      productImage: json["productImage"] ?? "",
      layerCount: json["layerCount"] ?? 0,
      wave: json["wave"] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "prefix": productId,
      "typeProduct": typeProduct,
      "productName": productName,
      "maKhuon": maKhuon,
      "productImage": productImage,
      "layerCount": layerCount,
      "wave": wave,
    };
  }
}
