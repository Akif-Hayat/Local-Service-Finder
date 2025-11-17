import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show debugPrint;
import '../models/service_provider.dart';
import 'firestore_init_service.dart';

class AdminService {
  static FirebaseFirestore get _db {
    try {
      return FirebaseFirestore.instance;
    } catch (e) {
      throw Exception('Firestore is not available: $e');
    }
  }

  // Get all service providers
  static Future<List<ServiceProvider>> getAllProviders() async {
    try {
      final snapshot = await _db.collection('providers').get();
      if (snapshot.docs.isEmpty) {
        // Initialize Firestore if empty
        await FirestoreInitService.initializeFirestore();
        // Fetch again after initialization
        final newSnapshot = await _db.collection('providers').get();
        if (newSnapshot.docs.isEmpty) return [];
        return newSnapshot.docs.map((doc) {
          final data = doc.data();
          return ServiceProvider.fromMap(doc.id, data as Map<String, dynamic>);
        }).toList();
      }
      
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return ServiceProvider.fromMap(doc.id, data as Map<String, dynamic>);
      }).toList();
    } catch (e) {
      throw Exception('Failed to fetch providers: $e');
    }
  }

  // Add a new service provider
  static Future<String> addProvider(ServiceProvider provider) async {
    try {
      final docRef = await _db.collection('providers').add(provider.toMap());
      
      // Update category count
      await _updateCategoryCount(provider.category);
      
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to add provider: $e');
    }
  }

  // Update category provider count
  static Future<void> _updateCategoryCount(String categoryName) async {
    try {
      final snapshot = await _db
          .collection('providers')
          .where('category', isEqualTo: categoryName)
          .get();
      
      final count = snapshot.docs.length;
      
      final categorySnapshot = await _db
          .collection('categories')
          .where('name', isEqualTo: categoryName)
          .get();
      
      if (categorySnapshot.docs.isNotEmpty) {
        await categorySnapshot.docs.first.reference
            .update({'providerCount': count});
      }
    } catch (e) {
      throw Exception('Failed to update category count: $e');
    }
  }

  // Update an existing service provider
  static Future<void> updateProvider(ServiceProvider provider) async {
    try {
      // Get old category to update counts if category changed
      final oldDoc = await _db.collection('providers').doc(provider.id).get();
      final oldCategory = oldDoc.data()?['category'] as String?;
      
      await _db.collection('providers').doc(provider.id).update(provider.toMap());
      
      // Update category counts if category changed
      if (oldCategory != null && oldCategory != provider.category) {
        await _updateCategoryCount(oldCategory);
        await _updateCategoryCount(provider.category);
      }
    } catch (e) {
      throw Exception('Failed to update provider: $e');
    }
  }

  // Delete a service provider
  static Future<void> deleteProvider(String providerId) async {
    try {
      // Get provider category before deleting
      final providerDoc = await _db.collection('providers').doc(providerId).get();
      final categoryName = providerDoc.data()?['category'] as String?;
      
      // Delete the provider document
      await _db.collection('providers').doc(providerId).delete();
      
      // Update category count
      if (categoryName != null) {
        await _updateCategoryCount(categoryName);
      }
      
      // Delete associated reviews
      try {
        final reviewsSnapshot = await _db
            .collection('providers')
            .doc(providerId)
            .collection('reviews')
            .get();
        
        final batch = _db.batch();
        for (var doc in reviewsSnapshot.docs) {
          batch.delete(doc.reference);
        }
        await batch.commit();
      } catch (e) {
        // Log but don't fail if reviews deletion fails
        debugPrint('Warning: Failed to delete reviews: $e');
      }
    } catch (e) {
      throw Exception('Failed to delete provider: $e');
    }
  }

  // Get all categories
  static Future<List<ServiceCategory>> getAllCategories() async {
    try {
      final snapshot = await _db.collection('categories').get();
      if (snapshot.docs.isEmpty) {
        // Initialize Firestore if empty
        await FirestoreInitService.initializeFirestore();
        // Fetch again after initialization
        final newSnapshot = await _db.collection('categories').get();
        if (newSnapshot.docs.isEmpty) return [];
        return newSnapshot.docs.map((doc) {
          final data = doc.data();
          return ServiceCategory.fromMap(doc.id, data);
        }).toList();
      }
      
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return ServiceCategory.fromMap(doc.id, data);
      }).toList();
    } catch (e) {
      throw Exception('Failed to fetch categories: $e');
    }
  }

  // Add a new category
  static Future<String> addCategory(ServiceCategory category) async {
    try {
      final docRef = await _db.collection('categories').add(category.toMap());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to add category: $e');
    }
  }

  // Update a category
  static Future<void> updateCategory(ServiceCategory category) async {
    try {
      await _db.collection('categories').doc(category.id).update(category.toMap());
    } catch (e) {
      throw Exception('Failed to update category: $e');
    }
  }

  // Delete a category
  static Future<void> deleteCategory(String categoryId) async {
    try {
      await _db.collection('categories').doc(categoryId).delete();
    } catch (e) {
      throw Exception('Failed to delete category: $e');
    }
  }

  // Get statistics
  static Future<Map<String, dynamic>> getStatistics() async {
    try {
      final providersSnapshot = await _db.collection('providers').get();
      final categoriesSnapshot = await _db.collection('categories').get();
      
      final providers = providersSnapshot.docs.length;
      final availableProviders = providersSnapshot.docs
          .where((doc) => (doc.data()['isAvailable'] ?? true) as bool)
          .length;
      
      return {
        'totalProviders': providers,
        'totalCategories': categoriesSnapshot.docs.length,
        'availableProviders': availableProviders,
      };
    } catch (e) {
      throw Exception('Failed to fetch statistics: $e');
    }
  }
}

