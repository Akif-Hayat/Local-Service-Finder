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
}
