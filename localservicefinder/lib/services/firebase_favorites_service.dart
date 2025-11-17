import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseFavoritesService {
  static CollectionReference<Map<String, dynamic>> _favoritesCollection(String uid) =>
      FirebaseFirestore.instance.collection('users').doc(uid).collection('favorites');

  static Future<Set<String>> loadFavorites() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return <String>{};
    final snap = await _favoritesCollection(user.uid).get();
    return snap.docs.map((d) => d.id).toSet();
  }

  static Future<void> addFavorite(String providerId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    await _favoritesCollection(user.uid).doc(providerId).set({'createdAt': FieldValue.serverTimestamp()});
  }

  static Future<void> removeFavorite(String providerId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    await _favoritesCollection(user.uid).doc(providerId).delete();
  }
}


