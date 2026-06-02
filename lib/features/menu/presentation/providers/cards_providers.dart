import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/cards_data_source.dart';
import '../../data/repositories/cards_repository_impl.dart';
import '../../domain/entities/card_entity.dart';
import '../../domain/usecases/get_card_stats_usecase.dart';

// Firebase instances
final firebaseFirestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

// Data Source
final cardsDataSourceProvider = Provider<CardsDataSource>((ref) {
  return CardsDataSource(
    ref.watch(firebaseFirestoreProvider),
    ref.watch(firebaseAuthProvider),
  );
});

// Repository
final cardsRepositoryProvider = Provider<CardsRepositoryImpl>((ref) {
  return CardsRepositoryImpl(ref.watch(cardsDataSourceProvider));
});

// Use Cases
final getCardStatsUseCaseProvider = Provider<GetCardStatsUseCase>((ref) {
  return GetCardStatsUseCase(ref.watch(cardsRepositoryProvider));
});

final addCardCategoryUseCaseProvider = Provider<AddCardCategoryUseCase>((ref) {
  return AddCardCategoryUseCase(ref.watch(cardsRepositoryProvider));
});

// Stream Provider for UI
final cardStatsStreamProvider = StreamProvider<List<CardEntity>>((ref) {
  return ref.watch(getCardStatsUseCaseProvider).call();
});

// Stream Provider for Network Info
final myNetworkInfoStreamProvider = StreamProvider<Map<String, dynamic>?>((ref) {
  final auth = ref.watch(firebaseAuthProvider);
  final firestore = ref.watch(firebaseFirestoreProvider);
  final uid = auth.currentUser?.uid;

  if (uid == null) {
    return Stream.value(null);
  }

  return firestore
      .collection('networks')
      .where('ownerId', isEqualTo: uid)
      .limit(1)
      .snapshots()
      .map((snapshot) {
    if (snapshot.docs.isEmpty) return null;
    final data = snapshot.docs.first.data();
    data['id'] = snapshot.docs.first.id;
    return data;
  });
});
