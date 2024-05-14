class ShelterModel {
  final String name;
  final String address;
  final String phone;
  final String email;
  final String website;
  final String description;
  final String image;
  final String uid;
  final String latitude;
  final String longitude;

  ShelterModel({
    required this.name,
    required this.address,
    required this.phone,
    required this.email,
    required this.website,
    required this.description,
    required this.image,
    required this.uid,
    required this.latitude,
    required this.longitude,
  });

  factory ShelterModel.fromJson(Map<String, dynamic> json) {
    return ShelterModel(
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      phone: json['phone'] ?? '',
      email: json['email'] ?? '',
      website: json['website'] ?? '',
      description: json['description'] ?? '',
      image: json['image'] ?? '',
      uid: json['uid'] ?? '',
      latitude: json['latitude'] ?? '',
      longitude: json['longitude'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'address': address,
      'phone': phone,
      'email': email,
      'website': website,
      'description': description,
      'image': image,
      'uid': uid,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}