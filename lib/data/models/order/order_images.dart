class OrderImageModel {
  final int imageId;
  final String imageUrl;
  final String publicId;

  //FK
  final String orderId;

  OrderImageModel({
    required this.imageId,
    required this.imageUrl,
    required this.publicId,
    required this.orderId,
  });

  factory OrderImageModel.fromJson(Map<String, dynamic> json) {
    return OrderImageModel(
      imageId: json["imageId"] ?? 0,
      imageUrl: json["imageUrl"] ?? "",
      publicId: json["publicId"] ?? "",

      //FK
      orderId: json["orderId"] ?? "",
    );
  }
}
