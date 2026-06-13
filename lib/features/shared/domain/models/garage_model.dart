class GarageModel {
  final String id;
  final String name;
  final String? ownerName;
  final String phone;
  final String wilaya;
  final String specialty;
  final double rating;
  final bool isTowing;
  final double? latitude;
  final double? longitude;
  final int discountPercent;
  final bool isActive;
  final DateTime createdAt;
  final double? distanceKm; // PostGIS-computed distance from user

  GarageModel({
    required this.id,
    required this.name,
    this.ownerName,
    required this.phone,
    required this.wilaya,
    required this.specialty,
    this.rating = 4.5,
    this.isTowing = false,
    this.latitude,
    this.longitude,
    this.discountPercent = 15,
    this.isActive = true,
    required this.createdAt,
    this.distanceKm,
  });

  factory GarageModel.fromJson(Map<String, dynamic> json) {
    return GarageModel(
      id: json['id'],
      name: json['name'],
      ownerName: json['owner_name'],
      phone: json['phone'],
      wilaya: json['wilaya'],
      specialty: json['specialty'],
      rating: (json['rating'] as num?)?.toDouble() ?? 4.5,
      isTowing: json['is_towing'] ?? false,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      discountPercent: json['discount_percent'] ?? 15,
      isActive: json['is_active'] ?? true,
      createdAt: DateTime.parse(json['created_at']),
      distanceKm: (json['distance_km'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'owner_name': ownerName,
      'phone': phone,
      'wilaya': wilaya,
      'specialty': specialty,
      'rating': rating,
      'is_towing': isTowing,
      'latitude': latitude,
      'longitude': longitude,
      'discount_percent': discountPercent,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'distance_km': distanceKm,
    };
  }
}
