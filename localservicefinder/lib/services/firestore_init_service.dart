import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show debugPrint;
import '../models/service_provider.dart';
import '../data/mock_data.dart';

class FirestoreInitService {
  static FirebaseFirestore? get _db {
    try {
      return FirebaseFirestore.instance;
    } catch (_) {
      return null;
    }
  }

  // Initialize Firestore with default data if collections are empty
  static Future<void> initializeFirestore() async {
    if (_db == null) return;

    try {
      // Initialize categories if empty
      final categoriesSnapshot = await _db!.collection('categories').get();
      if (categoriesSnapshot.docs.isEmpty) {
        await _initializeCategories();
      }

      // Initialize providers if empty
      final providersSnapshot = await _db!.collection('providers').get();
      if (providersSnapshot.docs.isEmpty) {
        await _initializeProviders();
      }

      // Update category provider counts
      await _updateCategoryCounts();
    } catch (e) {
      // Silently handle errors - Firestore might not be configured
      debugPrint('Firestore initialization error: $e');
    }
  }

  // Initialize categories from mock data
  static Future<void> _initializeCategories() async {
    if (_db == null) return;

    final categories = MockData.getCategories();
    final batch = _db!.batch();

    for (var category in categories) {
      // Use category name as document ID for easier querying
      final docRef = _db!.collection('categories').doc(category.name);
      batch.set(docRef, category.toMap());
    }

    await batch.commit();
  }

  // Initialize providers from mock data
  static Future<void> _initializeProviders() async {
    if (_db == null) return;

    final providers = MockData.getProviders();
    final batch = _db!.batch();
    final providerIdMap = <String, String>{}; // Map old ID to new Firestore ID

    for (var provider in providers) {
      final docRef = _db!.collection('providers').doc();
      providerIdMap[provider.id] = docRef.id;
      batch.set(docRef, provider.toMap());
    }

    await batch.commit();

    // Initialize reviews for each provider using new Firestore IDs
    for (var entry in providerIdMap.entries) {
      await _initializeReviews(entry.value);
    }
  }

  // Initialize reviews for a provider
  static Future<void> _initializeReviews(String providerId) async {
    if (_db == null) return;

    final reviews = MockData.getReviews(providerId);
    final batch = _db!.batch();

    for (var review in reviews) {
      final docRef = _db!
          .collection('providers')
          .doc(providerId)
          .collection('reviews')
          .doc();
      batch.set(docRef, review.toMap());
    }

    await batch.commit();
  }

  // Update provider counts for each category
  static Future<void> _updateCategoryCounts() async {
    if (_db == null) return;

    try {
      // Get all categories
      final categoriesSnapshot = await _db!.collection('categories').get();
      
      // Get all providers grouped by category
      final providersSnapshot = await _db!.collection('providers').get();
      final categoryCounts = <String, int>{};

      for (var doc in providersSnapshot.docs) {
        final data = doc.data();
        final category = data['category'] as String? ?? 'Unknown';
        categoryCounts[category] = (categoryCounts[category] ?? 0) + 1;
      }

      // Update each category with the correct count
      final batch = _db!.batch();
      for (var categoryDoc in categoriesSnapshot.docs) {
        final categoryName = categoryDoc.data()['name'] as String? ?? '';
        final count = categoryCounts[categoryName] ?? 0;
        batch.update(categoryDoc.reference, {'providerCount': count});
      }

      await batch.commit();
    } catch (e) {
      // Ignore errors
      debugPrint('Error updating category counts: $e');
    }
  }

  // Update category count when provider is added/removed
  static Future<void> updateCategoryCount(String categoryName) async {
    if (_db == null) return;

    try {
      // Count providers in this category
      final snapshot = await _db!
          .collection('providers')
          .where('category', isEqualTo: categoryName)
          .get();

      final count = snapshot.docs.length;

      // Find and update the category document
      final categoriesSnapshot = await _db!
          .collection('categories')
          .where('name', isEqualTo: categoryName)
          .get();

      if (categoriesSnapshot.docs.isNotEmpty) {
        await categoriesSnapshot.docs.first.reference
            .update({'providerCount': count});
      }
    } catch (e) {
      // Ignore errors
      debugPrint('Error updating category count: $e');
    }
  }
}


