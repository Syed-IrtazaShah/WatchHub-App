class WatchModel {
  final int id;
  final String name;
  final String image;
  final num price;
  final int stock;
  final String description;
  final int? brandId;
  final String? type;
  final String? category;
  final String? color;
  final String? material;
  final String? gender;

  WatchModel({
    required this.id,
    required this.name,
    required this.image,
    required this.price,
    required this.stock,
    required this.description,
    this.brandId,
    this.type,
    this.category,
    this.color,
    this.material,
    this.gender,
  });

  factory WatchModel.fromJson(Map<String, dynamic> json) {
    try {
      return WatchModel(
        id: json["id"] is int ? json["id"] : int.tryParse(json["id"]?.toString() ?? '0') ?? 0,
        name: json['prod_name']?.toString() ?? '',
        image: json['prod_img']?.toString() ?? '',
        price: json['prod_price'] is num ? json['prod_price'] : num.tryParse(json['prod_price']?.toString() ?? '0') ?? 0,
        stock: json['prod_stock'] is int ? json['prod_stock'] : int.tryParse(json['prod_stock']?.toString() ?? '0') ?? 0,
        description: json['prod_description']?.toString() ?? 'No description available',
        brandId: json['prod_brand'] is int ? json['prod_brand'] : int.tryParse(json['prod_brand']?.toString() ?? ''),
        type: json['prod_type']?.toString() ?? json['type']?.toString(),
        category: json['prod_category']?.toString() ?? json['category']?.toString(),
        color: json['prod_color']?.toString() ?? json['color']?.toString(),
        material: json['prod_material']?.toString() ?? json['material']?.toString(),
        gender: json['prod_gender']?.toString() ?? json['gender']?.toString(),
      );
    } catch (e) {
      print('Error parsing WatchModel from JSON: $e');
      print('JSON data: $json');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'prod_name': name,
      'prod_img': image,
      'prod_price': price,
      'prod_stock': stock,
      'prod_description': description,
      'prod_brand': brandId,
      'prod_type': type,
      'prod_category': category,
      'prod_color': color,
      'prod_material': material,
      'prod_gender': gender,
    };
  }

  WatchModel copyWith({
    int? id,
    String? name,
    String? image,
    num? price,
    int? stock,
    String? description,
    int? brandId,
    String? type,
    String? category,
    String? color,
    String? material,
    String? gender,
  }) {
    return WatchModel(
      id: id ?? this.id,
      name: name ?? this.name,
      image: image ?? this.image,
      price: price ?? this.price,
      stock: stock ?? this.stock,
      description: description ?? this.description,
      brandId: brandId ?? this.brandId,
      type: type ?? this.type,
      category: category ?? this.category,
      color: color ?? this.color,
      material: material ?? this.material,
      gender: gender ?? this.gender,
    );
  }
}
