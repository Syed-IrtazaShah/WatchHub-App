class OrderModel {
  final int id;
  final int prodId;
  final int totalItem;
  final double totalAmount;
  final String status;
  final int addressId;
  final String orderDate;
  final String? productName;
  final String? productImage;

  OrderModel({
    required this.id,
    required this.prodId,
    required this.totalItem,
    required this.totalAmount,
    required this.status,
    required this.addressId,
    required this.orderDate,
    this.productName,
    this.productImage,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'] ?? json['order_id'] ?? 0,
      prodId: json['prod_id'] ?? json['product_id'] ?? 0,
      totalItem: json['total_item'] ?? json['total_items'] ?? 0,
      totalAmount: (json['total_amount'] is int) ? (json['total_amount'] as int).toDouble() :
                   (json['total_amount'] is double) ? json['total_amount'] as double :
                   (json['amount'] is int) ? (json['amount'] as int).toDouble() :
                   (json['amount'] is double) ? json['amount'] as double : 0.0,
      status: json['status'] ?? 'pending',
      addressId: json['address_id'] ?? json['address'] ?? 0,
      orderDate: json['created_at'] ?? json['order_date'] ?? json['updated_at'] ?? DateTime.now().toIso8601String(),
      productName: json['product_name'],
      productImage: json['product_image'] ?? json['image_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'prod_id': prodId,
      'total_item': totalItem,
      'total_amount': totalAmount,
      'status': status,
      'address_id': addressId,
      'order_date': orderDate,
    };
  }
}
