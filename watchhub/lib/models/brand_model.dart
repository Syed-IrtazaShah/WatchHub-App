class BrandModel {
  final dynamic id;
  final String name;
  final String imageUrl;

  BrandModel({
    required this.id,
    required this.name,
    required this.imageUrl,
  });

  factory BrandModel.fromJson(Map<String, dynamic> json) {
    return BrandModel(
      id: json['id'],
      name: json['brand_name'] ?? '',
      imageUrl: json['brand_img_url'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'brand_name': name,
      'brand_img_url': imageUrl,
    };
  }
}
