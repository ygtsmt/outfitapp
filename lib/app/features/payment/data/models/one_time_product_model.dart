class OneTimeProduct {
  final String productId;
  final String title;
  final String price;
  final String currency;
  final int creditAmount;
  final String packageName;
  final bool isAvailable;

  const OneTimeProduct({
    required this.productId,
    required this.title,
    required this.price,
    required this.currency,
    required this.creditAmount,
    required this.packageName,
    this.isAvailable = true,
  });

  factory OneTimeProduct.fromJson(Map<String, dynamic> json) {
    return OneTimeProduct(
      productId: json['productId'] ?? '',
      title: json['title'] ?? '',
      price: json['price'] ?? '',
      currency: json['currency'] ?? '',
      creditAmount: json['creditAmount'] ?? 0,
      packageName: json['packageName'] ?? '',
      isAvailable: json['isAvailable'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'title': title,
      'price': price,
      'currency': currency,
      'creditAmount': creditAmount,
      'packageName': packageName,
      'isAvailable': isAvailable,
    };
  }

  @override
  String toString() {
    return 'OneTimeProduct(productId: $productId, title: $title, price: $price, creditAmount: $creditAmount)';
  }
}
