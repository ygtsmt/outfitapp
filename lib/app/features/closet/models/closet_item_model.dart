import 'package:cloud_firestore/cloud_firestore.dart';

class ClosetItem {
  final String id; // Firestore doc ID
  final String imageUrl; // Kıyafetin fotoğrafı (Firebase Storage URL)
  final String?
      category; // Ana kategori: top, bottom, shoes, outerwear, accessory
  final String?
      subcategory; // Alt kategori: t-shirt, jeans, sneakers, hoodie, skirt...
  final String? color; // Renk: black, white, beige, gray, red, blue, green...
  final String?
      pattern; // Desen: plain, striped, floral, logo, checkered, graphic...
  final String? season; // Mevsim: summer, winter, spring, autumn, all
  final String? material; // Kumaş: cotton, denim, leather, wool, polyester...
  final String? brand; // Marka: Zara, H&M, Nike, Adidas...
  final DateTime createdAt; // Kayıt tarihi

  ClosetItem({
    required this.id,
    required this.imageUrl,
    required this.createdAt,
    this.category,
    this.subcategory,
    this.color,
    this.pattern,
    this.season,
    this.material,
    this.brand,
  });

  // Map'ten model oluşturma (Firestore'dan gelirken)
  factory ClosetItem.fromMap(Map<String, dynamic> map) {
    // ID yoksa unique bir ID oluştur
    String id = map['id'] as String? ??
        DateTime.now().millisecondsSinceEpoch.toString();

    // createdAt yoksa şimdiki zamanı kullan
    DateTime createdAt;
    if (map['createdAt'] == null) {
      createdAt = DateTime.now();
    } else if (map['createdAt'] is Timestamp) {
      createdAt = (map['createdAt'] as Timestamp).toDate();
    } else if (map['createdAt'] is String) {
      createdAt = DateTime.parse(map['createdAt'] as String);
    } else {
      createdAt = DateTime.now();
    }

    return ClosetItem(
      id: id,
      imageUrl: map['imageUrl'] as String? ?? '',
      category: map['category'] as String?,
      subcategory: map['subcategory'] as String?,
      color: map['color'] as String?,
      pattern: map['pattern'] as String?,
      season: map['season'] as String?,
      material: map['material'] as String?,
      brand: map['brand'] as String?,
      createdAt: createdAt,
    );
  }

  // Model'den map'e dönüştürme (Firestore'a yazarken)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'imageUrl': imageUrl,
      'category': category,
      'subcategory': subcategory,
      'color': color,
      'pattern': pattern,
      'season': season,
      'material': material,
      'brand': brand,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  // JSON'dan model oluşturma (API'den gelirken)
  factory ClosetItem.fromJson(Map<String, dynamic> json) {
    return ClosetItem(
      id: json['id'] as String,
      imageUrl: json['imageUrl'] as String,
      category: json['category'] as String?,
      subcategory: json['subcategory'] as String?,
      color: json['color'] as String?,
      pattern: json['pattern'] as String?,
      season: json['season'] as String?,
      material: json['material'] as String?,
      brand: json['brand'] as String?,
      createdAt: json['createdAt'] is String
          ? DateTime.parse(json['createdAt'] as String)
          : (json['createdAt'] as Timestamp).toDate(),
    );
  }

  // Model'den JSON'a dönüştürme
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'imageUrl': imageUrl,
      'category': category,
      'subcategory': subcategory,
      'color': color,
      'pattern': pattern,
      'season': season,
      'material': material,
      'brand': brand,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  ClosetItem copyWith({
    String? id,
    String? imageUrl,
    String? category,
    String? subcategory,
    String? color,
    String? pattern,
    String? season,
    String? material,
    String? brand,
    DateTime? createdAt,
  }) {
    return ClosetItem(
      id: id ?? this.id,
      imageUrl: imageUrl ?? this.imageUrl,
      category: category ?? this.category,
      subcategory: subcategory ?? this.subcategory,
      color: color ?? this.color,
      pattern: pattern ?? this.pattern,
      season: season ?? this.season,
      material: material ?? this.material,
      brand: brand ?? this.brand,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // Subcategory'den category'yi otomatik belirleme helper method
  static String? getCategoryFromSubcategory(String? subcategory) {
    if (subcategory == null) return null;

    final subcategoryLower = subcategory.toLowerCase();

    // Top kategorisi
    const topSubcategories = [
      't-shirt',
      'shirt',
      'blouse',
      'sweater',
      'tank top',
      'hoodie',
      'top',
      'tee',
    ];
    if (topSubcategories.contains(subcategoryLower)) {
      return 'top';
    }

    // Bottom kategorisi
    const bottomSubcategories = [
      'jeans',
      'jean',
      'trousers',
      'pants',
      'skirt',
      'shorts',
      'leggings',
      'bottom',
    ];
    if (bottomSubcategories.contains(subcategoryLower)) {
      return 'bottom';
    }

    // Shoes kategorisi
    const shoesSubcategories = [
      'sneakers',
      'sneaker',
      'boots',
      'boot',
      'sandals',
      'sandal',
      'heels',
      'heel',
      'flats',
      'flat',
      'slippers',
      'slipper',
      'shoes',
      'shoe',
    ];
    if (shoesSubcategories.contains(subcategoryLower)) {
      return 'shoes';
    }

    // Outerwear kategorisi
    const outerwearSubcategories = [
      'jacket',
      'coat',
      'blazer',
      'cardigan',
      'vest',
      'outerwear',
    ];
    if (outerwearSubcategories.contains(subcategoryLower)) {
      return 'outerwear';
    }

    // Accessory kategorisi
    const accessorySubcategories = [
      'bag',
      'hat',
      'scarf',
      'belt',
      'watch',
      'jewelry',
      'jewellery',
      'accessory',
      'accessories',
    ];
    if (accessorySubcategories.contains(subcategoryLower)) {
      return 'accessory';
    }

    return null;
  }

  // Category'yi subcategory'den otomatik belirle (eğer yoksa)
  ClosetItem withAutoCategory() {
    if (category == null && subcategory != null) {
      final autoCategory = getCategoryFromSubcategory(subcategory);
      return copyWith(category: autoCategory);
    }
    return this;
  }
}
