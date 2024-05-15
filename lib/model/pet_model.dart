class PetModel {
  final String name;
  final String breed;
  final int age;
  final String description;
  final String image;
  final bool isAdopted;
  final String shelterId;

  PetModel({
    required this.name,
    required this.breed,
    required this.age,
    required this.description,
    required this.image,
    required this.isAdopted,
    required this.shelterId,
  });

  factory PetModel.fromJson(Map<String, dynamic> json) {
    return PetModel(
      name: json['name'] ?? '',
      breed: json['breed'] ?? '',
      age: json['age'] ?? 0,
      description: json['description'] ?? '',
      image: json['image'] ?? '',
      isAdopted: json['isAdopted'] ?? false,
      shelterId: json['shelterId'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'breed': breed,
      'age': age,
      'description': description,
      'image': image,
      'isAdopted': isAdopted,
      'shelterId': shelterId,
    };
  }
}
