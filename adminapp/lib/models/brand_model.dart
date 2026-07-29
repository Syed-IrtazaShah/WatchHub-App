// lib/models/brand_model.dart
class Brand {
  final int? id;
  final String brandName;
  final String brandImgUrl;

  Brand({
    this.id,
    required this.brandName,
    required this.brandImgUrl,
  });

  factory Brand.fromJson(Map<String, dynamic> json) {
    return Brand(
      id: json['id'] as int?,
      brandName: json['brand_name'] ?? '',
      brandImgUrl: json['brand_img_url'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'brand_name': brandName,
      'brand_img_url': brandImgUrl,
    };
  }
}