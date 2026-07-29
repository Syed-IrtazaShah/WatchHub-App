class AddressModel {
  int? id; // Optional ID for existing records
  String type;
  String fullName;
  String phone;
  String address;
  String city;
  String zipCode;

  AddressModel({
    this.id,
    required this.type,
    required this.fullName,
    required this.phone,
    required this.address,
    required this.city,
    required this.zipCode,
  });

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      id: json['id'] as int?,
      type: json['address_type']?.toString() ?? json['type']?.toString() ?? '',
      fullName: json['full_name']?.toString() ?? json['fullName']?.toString() ?? '',
      phone: json['phone_number']?.toString() ?? json['phone']?.toString() ?? '',
      address: json['address_details']?.toString() ?? json['address']?.toString() ?? '',
      city: json['city']?.toString() ?? '',
      zipCode: json['zip_code']?.toString() ?? json['zipCode']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'type': type,
      'full_name': fullName,
      'phone': phone,
      'address': address,
      'city': city,
      'zip_code': zipCode,
    };
  }
}
