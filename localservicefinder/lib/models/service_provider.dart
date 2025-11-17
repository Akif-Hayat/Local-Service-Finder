import 'package:cloud_firestore/cloud_firestore.dart';

class ServiceProvider {
  final String id;
  final String name;
  final String category;
  final String phone;
  final String email;
  final String address;
  final double rating;
  final int reviewCount;
  final String description;
  final List<String> services;
  final bool isAvailable;
  final String imageUrl;

  ServiceProvider({
    required this.id,
    required this.name,
    required this.category,
    required this.phone,
    required this.email,
    required this.address,
    required this.rating,
    required this.reviewCount,
    required this.description,
    required this.services,
    required this.isAvailable,
    required this.imageUrl,
  });

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'category': category,
      'phone': phone,
      'email': email,
      'address': address,
      'rating': rating,
      'reviewCount': reviewCount,
      'description': description,
      'services': services,
      'isAvailable': isAvailable,
      'imageUrl': imageUrl,
    };
  }

  // Create from Map (from Firestore)
  factory ServiceProvider.fromMap(String id, Map<String, dynamic> map) {
    return ServiceProvider(
      id: id,
      name: map['name'] ?? 'Unnamed',
      category: map['category'] ?? 'General',
      phone: map['phone'] ?? '',
      email: map['email'] ?? '',
      address: map['address'] ?? '',
      rating: (map['rating'] ?? 0).toDouble(),
      reviewCount: (map['reviewCount'] ?? 0) as int,
      description: map['description'] ?? '',
      services: List<String>.from(map['services'] ?? const []),
      isAvailable: (map['isAvailable'] ?? true) as bool,
      imageUrl: map['imageUrl'] ?? '',
    );
  }

  // Create a copy with updated fields
  ServiceProvider copyWith({
    String? id,
    String? name,
    String? category,
    String? phone,
    String? email,
    String? address,
    double? rating,
    int? reviewCount,
    String? description,
    List<String>? services,
    bool? isAvailable,
    String? imageUrl,
  }) {
    return ServiceProvider(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      address: address ?? this.address,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      description: description ?? this.description,
      services: services ?? this.services,
      isAvailable: isAvailable ?? this.isAvailable,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}

class ServiceCategory {
  final String id;
  final String name;
  final String icon;
  final int providerCount;

  ServiceCategory({
    required this.id,
    required this.name,
    required this.icon,
    required this.providerCount,
  });

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'icon': icon,
      'providerCount': providerCount,
    };
  }

  // Create from Map (from Firestore)
  factory ServiceCategory.fromMap(String id, Map<String, dynamic> map) {
    return ServiceCategory(
      id: id,
      name: map['name'] ?? 'Unknown',
      icon: map['icon'] ?? '🔧',
      providerCount: (map['providerCount'] ?? 0) as int,
    );
  }

  // Create a copy with updated fields
  ServiceCategory copyWith({
    String? id,
    String? name,
    String? icon,
    int? providerCount,
  }) {
    return ServiceCategory(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      providerCount: providerCount ?? this.providerCount,
    );
  }
}

class Review {
  final String id;
  final String providerId;
  final String userName;
  final double rating;
  final String comment;
  final DateTime date;

  Review({
    required this.id,
    required this.providerId,
    required this.userName,
    required this.rating,
    required this.comment,
    required this.date,
  });

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'providerId': providerId,
      'userName': userName,
      'rating': rating,
      'comment': comment,
      'date': Timestamp.fromDate(date),
    };
  }

  // Create from Map (from Firestore)
  factory Review.fromMap(String id, Map<String, dynamic> map) {
    return Review(
      id: id,
      providerId: map['providerId'] ?? '',
      userName: map['userName'] ?? 'Anonymous',
      rating: (map['rating'] ?? 0).toDouble(),
      comment: map['comment'] ?? '',
      date: (map['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}
