/// Product model for inventory management
class ProductModel {
  final String id;
  final String barcode;
  final String name;
  final String? description;
  final double price;
  final String category;
  final int stockQuantity;
  final String? imageUrl;
  final String storeId;
  final DateTime createdAt;
  final DateTime updatedAt;

  ProductModel({
    required this.id,
    required this.barcode,
    required this.name,
    this.description,
    required this.price,
    required this.category,
    this.stockQuantity = 0,
    this.imageUrl,
    required this.storeId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] as String,
      barcode: json['barcode'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      price: (json['price'] as num).toDouble(),
      category: json['category'] as String,
      stockQuantity:
          (json['stock_quantity'] ?? json['stockQuantity']) as int? ?? 0,
      imageUrl: (json['image_url'] ?? json['imageUrl']) as String?,
      storeId: (json['store_id'] ?? json['storeId']) as String,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'barcode': barcode,
      'name': name,
      'description': description,
      'price': price,
      'category': category,
      'stockQuantity': stockQuantity,
      'imageUrl': imageUrl,
      'storeId': storeId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  String get formattedPrice => '\$${price.toStringAsFixed(2)}';

  String get sku => 'SKU${id.substring(0, 6).toUpperCase()}';

  bool get isLowStock => stockQuantity < 10;

  bool get isOutOfStock => stockQuantity == 0;

  ProductModel copyWith({
    String? id,
    String? barcode,
    String? name,
    String? description,
    double? price,
    String? category,
    int? stockQuantity,
    String? imageUrl,
    String? storeId,
  }) {
    return ProductModel(
      id: id ?? this.id,
      barcode: barcode ?? this.barcode,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      category: category ?? this.category,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      imageUrl: imageUrl ?? this.imageUrl,
      storeId: storeId ?? this.storeId,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}
