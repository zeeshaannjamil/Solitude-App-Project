// lib/services/firestore_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Creates or updates the current user's profile.
  Future<void> createUserProfile({
    required String fullName,
    required String email,
  }) async {
    final User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw Exception("No authenticated user found.");
    }

    await _firestore.collection('users').doc(user.uid).set({
      'uid': user.uid,
      'fullName': fullName,
      'email': email,
      'photoUrl': '',
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'isPremium': false,
    }, SetOptions(merge: true));
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> getCurrentUserProfile() async {
    final User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw Exception("No authenticated user found.");
    }

    return await _firestore
        .collection('users')
        .doc(user.uid)
        .get();
  }

  Future<void> updateProfile({
    String? fullName,
    String? photoUrl,
  }) async {
    final User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw Exception("No authenticated user found.");
    }

    final Map<String, dynamic> data = {
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (fullName != null) data['fullName'] = fullName;
    if (photoUrl != null) data['photoUrl'] = photoUrl;

    await _firestore.collection('users').doc(user.uid).update(data);
  }

  Future<void> deleteCurrentUserProfile() async {
    final User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw Exception("No authenticated user found.");
    }

    await _firestore.collection('users').doc(user.uid).delete();
  }
}
