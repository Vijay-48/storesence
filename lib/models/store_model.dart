/// Store model representing a retail store
class StoreModel {
  final String id;
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final double distance; // in km
  final bool isOpen;
  final String? imageUrl;
  final String? category;
  final double carryBagPrice;
  final bool carryBagEnabled;

  StoreModel({
    required this.id,
    required this.name,
    required this.address,
    this.latitude = 0.0,
    this.longitude = 0.0,
    this.distance = 0.0,
    this.isOpen = true,
    this.imageUrl,
    this.category,
    this.carryBagPrice = 0.50,
    this.carryBagEnabled = true,
  });

  factory StoreModel.fromJson(Map<String, dynamic> json) {
    return StoreModel(
      id: json['id'] as String,
      name: json['name'] as String,
      address: json['address'] as String,
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      distance: (json['distance'] as num?)?.toDouble() ?? 0.0,
      isOpen: (json['is_open'] ?? json['isOpen']) as bool? ?? true,
      imageUrl: (json['image_url'] ?? json['imageUrl']) as String?,
      category: json['category'] as String?,
      carryBagPrice:
          (json['carry_bag_price'] ?? json['carryBagPrice'] as num?)
              ?.toDouble() ??
          0.50,
      carryBagEnabled:
          (json['carry_bag_enabled'] ?? json['carryBagEnabled']) as bool? ??
          true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'distance': distance,
      'isOpen': isOpen,
      'imageUrl': imageUrl,
      'category': category,
      'carryBagPrice': carryBagPrice,
      'carryBagEnabled': carryBagEnabled,
    };
  }

  String get formattedDistance {
    if (distance < 1) {
      return '${(distance * 1000).toInt()} m away';
    }
    return '${distance.toStringAsFixed(1)} km away';
  }

  StoreModel copyWith({
    String? id,
    String? name,
    String? address,
    double? latitude,
    double? longitude,
    double? distance,
    bool? isOpen,
    String? imageUrl,
    String? category,
    double? carryBagPrice,
    bool? carryBagEnabled,
  }) {
    return StoreModel(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      distance: distance ?? this.distance,
      isOpen: isOpen ?? this.isOpen,
      imageUrl: imageUrl ?? this.imageUrl,
      category: category ?? this.category,
      carryBagPrice: carryBagPrice ?? this.carryBagPrice,
      carryBagEnabled: carryBagEnabled ?? this.carryBagEnabled,
    );
  }
}
