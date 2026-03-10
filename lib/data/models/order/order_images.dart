class OrderImage {
  final int imageId;
  final String imageUrl;
  final String publicId;

  //FK
  final String orderId;

  OrderImage({
    required this.imageId,
    required this.imageUrl,
    required this.publicId,
    required this.orderId,
  });

  factory OrderImage.fromJson(Map<String, dynamic> json) {
    return OrderImage(
      imageId: json['imageId'] ?? 0,
      imageUrl: json['imageUrl'] ?? "",
      publicId: json['publicId'] ?? "",

      //FK
      orderId: json['orderId'] ?? "",
    );
  }
}
