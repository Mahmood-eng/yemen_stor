import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/card_model.dart';

class CardsDataSource {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  CardsDataSource(this._firestore, this._auth);

  Stream<List<CardModel>> getCardStatsStream() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value([]);

    return _firestore
        .collection('users')
        .doc(user.uid)
        .collection('card_stats')
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isEmpty) {
        // Return some empty defaults if nothing exists
        return [];
      }
      return snapshot.docs.map((doc) => CardModel.fromJson(doc.data())).toList();
    });
  }

  Future<void> addOrUpdateCategory(CardModel card) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('يجب تسجيل الدخول');

    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('card_stats')
        .doc(card.category) // use category as document id
        .set(card.toJson(), SetOptions(merge: true));
  }
}
