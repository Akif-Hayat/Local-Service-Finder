import '../models/service_provider.dart';

class MockData {
  static List<ServiceCategory> getCategories() {
    return [
      ServiceCategory(id: '1', name: 'Plumbing', icon: '🔧', providerCount: 12),
      ServiceCategory(id: '2', name: 'Electrical', icon: '⚡', providerCount: 8),
      ServiceCategory(id: '3', name: 'Cleaning', icon: '🧹', providerCount: 15),
      ServiceCategory(id: '4', name: 'HVAC', icon: '❄️', providerCount: 6),
      ServiceCategory(id: '5', name: 'Painting', icon: '🎨', providerCount: 10),
      ServiceCategory(id: '6', name: 'Carpentry', icon: '🔨', providerCount: 7),
      ServiceCategory(id: '7', name: 'Landscaping', icon: '🌱', providerCount: 9),
      ServiceCategory(id: '8', name: 'Appliance Repair', icon: '🔌', providerCount: 5),
    ];
  }

  static List<ServiceProvider> getProviders() {
    return [
      ServiceProvider(
        id: '1',
        name: 'John\'s Plumbing',
        category: 'Plumbing',
        phone: '+1-555-0123',
        email: 'john@plumbing.com',
        address: '123 Main St, City',
        rating: 4.8,
        reviewCount: 45,
        description: 'Professional plumbing services with 10+ years experience',
        services: ['Pipe Repair', 'Drain Cleaning', 'Water Heater', 'Toilet Repair'],
        isAvailable: true,
        imageUrl: 'https://via.placeholder.com/150',
      ),
      ServiceProvider(
        id: '2',
        name: 'Electric Pro',
        category: 'Electrical',
        phone: '+1-555-0124',
        email: 'info@electricpro.com',
        address: '456 Oak Ave, City',
        rating: 4.6,
        reviewCount: 32,
        description: 'Licensed electricians for all your electrical needs',
        services: ['Wiring', 'Outlet Installation', 'Circuit Breaker', 'Lighting'],
        isAvailable: true,
        imageUrl: 'https://via.placeholder.com/150',
      ),
      ServiceProvider(
        id: '3',
        name: 'Clean & Shine',
        category: 'Cleaning',
        phone: '+1-555-0125',
        email: 'clean@shine.com',
        address: '789 Pine St, City',
        rating: 4.9,
        reviewCount: 67,
        description: 'Residential and commercial cleaning services',
        services: ['House Cleaning', 'Office Cleaning', 'Deep Clean', 'Window Cleaning'],
        isAvailable: true,
        imageUrl: 'https://via.placeholder.com/150',
      ),
      ServiceProvider(
        id: '4',
        name: 'Cool Air HVAC',
        category: 'HVAC',
        phone: '+1-555-0126',
        email: 'service@coolair.com',
        address: '321 Elm St, City',
        rating: 4.7,
        reviewCount: 28,
        description: 'Heating and cooling solutions for your home',
        services: ['AC Repair', 'Heating', 'Duct Cleaning', 'Installation'],
        isAvailable: false,
        imageUrl: 'https://via.placeholder.com/150',
      ),
      ServiceProvider(
        id: '5',
        name: 'Perfect Paint',
        category: 'Painting',
        phone: '+1-555-0127',
        email: 'paint@perfect.com',
        address: '654 Maple Dr, City',
        rating: 4.5,
        reviewCount: 41,
        description: 'Interior and exterior painting services',
        services: ['Interior Paint', 'Exterior Paint', 'Color Consultation', 'Wallpaper'],
        isAvailable: true,
        imageUrl: 'https://via.placeholder.com/150',
      ),
      ServiceProvider(
        id: '6',
        name: 'Wood Works',
        category: 'Carpentry',
        phone: '+1-555-0128',
        email: 'wood@works.com',
        address: '987 Cedar Ln, City',
        rating: 4.8,
        reviewCount: 23,
        description: 'Custom carpentry and woodworking services',
        services: ['Custom Furniture', 'Cabinets', 'Shelving', 'Repairs'],
        isAvailable: true,
        imageUrl: 'https://via.placeholder.com/150',
      ),
    ];
  }

  static List<Review> getReviews(String providerId) {
    return [
      Review(
        id: '1',
        providerId: providerId,
        userName: 'Sarah M.',
        rating: 5.0,
        comment: 'Excellent service! Very professional and punctual.',
        date: DateTime.now().subtract(const Duration(days: 2)),
      ),
      Review(
        id: '2',
        providerId: providerId,
        userName: 'Mike R.',
        rating: 4.0,
        comment: 'Good work, but took longer than expected.',
        date: DateTime.now().subtract(const Duration(days: 5)),
      ),
      Review(
        id: '3',
        providerId: providerId,
        userName: 'Lisa K.',
        rating: 5.0,
        comment: 'Highly recommended! Will use again.',
        date: DateTime.now().subtract(const Duration(days: 7)),
      ),
    ];
  }
}
