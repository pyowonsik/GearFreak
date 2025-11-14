/// 상품 엔티티
class Product {
  final String id;
  final String title;
  final int price;
  final String location;
  final DateTime createdAt;
  final int favoriteCount;
  final String? imageUrl;
  final String category;

  const Product({
    required this.id,
    required this.title,
    required this.price,
    required this.location,
    required this.createdAt,
    this.favoriteCount = 0,
    this.imageUrl,
    required this.category,
  });

  Product copyWith({
    String? id,
    String? title,
    int? price,
    String? location,
    DateTime? createdAt,
    int? favoriteCount,
    String? imageUrl,
    String? category,
  }) {
    return Product(
      id: id ?? this.id,
      title: title ?? this.title,
      price: price ?? this.price,
      location: location ?? this.location,
      createdAt: createdAt ?? this.createdAt,
      favoriteCount: favoriteCount ?? this.favoriteCount,
      imageUrl: imageUrl ?? this.imageUrl,
      category: category ?? this.category,
    );
  }
}

/// 카테고리 엔티티
class Category {
  final String id;
  final String name;
  final String icon;

  const Category({
    required this.id,
    required this.name,
    required this.icon,
  });
}

