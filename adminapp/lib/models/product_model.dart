class Product {
  final int id;
  final String prodName;
  final String prodImg;
  final int prodBrandId;
  final String prodBrandName;
  final double prodPrice;
  final int prodStock;
  final String prodDescription;

  Product({
    required this.id,
    required this.prodName,
    required this.prodImg,
    required this.prodBrandId,
    required this.prodBrandName,
    required this.prodPrice,
    required this.prodStock,
    required this.prodDescription,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    final brandObj = json['tbl_brand'] is Map<String, dynamic> ? json['tbl_brand'] as Map<String, dynamic> : null;
    return Product(
      id: json['id'] is int ? json['id'] as int : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      prodName: json['prod_name']?.toString() ?? '',
      prodImg: json['prod_img']?.toString() ?? '',
      prodBrandId: brandObj != null ? (brandObj['id'] is int ? brandObj['id'] as int : int.tryParse(brandObj['id']?.toString() ?? '0') ?? 0) : 0,
      prodBrandName: brandObj != null ? (brandObj['brand_name']?.toString() ?? 'No Brand') : 'No Brand',
      prodPrice: (json['prod_price'] as num?)?.toDouble() ?? double.tryParse(json['prod_price']?.toString() ?? '0') ?? 0.0,
      prodStock: (json['prod_stock'] as num?)?.toInt() ?? int.tryParse(json['prod_stock']?.toString() ?? '0') ?? 0,
      prodDescription: json['prod_description']?.toString() ?? '',
    );
  }
}
