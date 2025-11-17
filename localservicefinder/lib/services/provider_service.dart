import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/service_provider.dart';
import 'firestore_init_service.dart';

class ProviderService {
  static FirebaseFirestore get _db {
    try {
      return FirebaseFirestore.instance;
    } catch (e) {
      throw Exception('Firestore is not available: $e');
    }
  }

  static Future<List<ServiceCategory>> fetchCategories() async {
    try {
      final snapshot = await _db.collection('categories').get();
      if (snapshot.docs.isEmpty) {
        // Initialize Firestore if empty
        await FirestoreInitService.initializeFirestore();
        // Fetch again after initialization
        final newSnapshot = await _db.collection('categories').get();
        if (newSnapshot.docs.isEmpty) return [];
        return newSnapshot.docs.map((d) {
          final data = d.data();
          return ServiceCategory.fromMap(d.id, data);
        }).toList();
      }
      return snapshot.docs.map((d) {
        final data = d.data();
        return ServiceCategory.fromMap(d.id, data);
      }).toList();
    } catch (e) {
      throw Exception('Failed to fetch categories: $e');
    }
  }

  static Future<List<ServiceProvider>> fetchProviders({String? category}) async {
    try {
      Query q = _db.collection('providers');
      if (category != null) {
        q = q.where('category', isEqualTo: category);
      }
      final snapshot = await q.get();
      if (snapshot.docs.isEmpty) {
        // Initialize Firestore if empty
        await FirestoreInitService.initializeFirestore();
        // Fetch again after initialization
        Query newQ = _db.collection('providers');
        if (category != null) {
          newQ = newQ.where('category', isEqualTo: category);
        }
        final newSnapshot = await newQ.get();
        if (newSnapshot.docs.isEmpty) return [];
        return newSnapshot.docs.map((d) {
          final data = d.data() as Map<String, dynamic>;
          return ServiceProvider.fromMap(d.id, data);
        }).toList();
      }
      return snapshot.docs.map((d) {
        final data = d.data() as Map<String, dynamic>;
        return ServiceProvider.fromMap(d.id, data);
      }).toList();
    } catch (e) {
      throw Exception('Failed to fetch providers: $e');
    }
  }

  static Future<List<Review>> fetchReviews(String providerId) async {
    try {
      // Add timeout to prevent long loading
      final snapshot = await _db
          .collection('providers')
          .doc(providerId)
          .collection('reviews')
          .orderBy('date', descending: true)
          .get()
          .timeout(const Duration(seconds: 10));
      
      return snapshot.docs.map((d) {
        final data = d.data() as Map<String, dynamic>;
        return Review.fromMap(d.id, data);
      }).toList();
    } catch (e) {
      throw Exception('Failed to fetch reviews: $e');
    }
  }

  // Add a review to Firestore
  static Future<void> addReview(Review review) async {
    try {
      await _db
          .collection('providers')
          .doc(review.providerId)
          .collection('reviews')
          .add(review.toMap());
      
      // Update provider rating and review count
      await _updateProviderRating(review.providerId);
    } catch (e) {
      throw Exception('Failed to add review: $e');
    }
  }

  // Update provider rating based on all reviews
  static Future<void> _updateProviderRating(String providerId) async {
    try {
      final reviewsSnapshot = await _db
          .collection('providers')
          .doc(providerId)
          .collection('reviews')
          .get();
      
      if (reviewsSnapshot.docs.isEmpty) return;
      
      double totalRating = 0;
      for (var doc in reviewsSnapshot.docs) {
        final data = doc.data();
        totalRating += (data['rating'] ?? 0).toDouble();
      }
      
      final averageRating = totalRating / reviewsSnapshot.docs.length;
      final reviewCount = reviewsSnapshot.docs.length;
      
      await _db.collection('providers').doc(providerId).update({
        'rating': averageRating,
        'reviewCount': reviewCount,
      });
    } catch (e) {
      throw Exception('Failed to update provider rating: $e');
    }
  }
}


