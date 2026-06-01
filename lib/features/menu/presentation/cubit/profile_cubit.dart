import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;

part 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit() : super(ProfileInitial());

  final _usersCollection = FirebaseFirestore.instance.collection('users');

  Future<void> loadCurrentPhotoUrl() async {
    final uid = fb_auth.FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    emit(ProfileLoading());
    try {
      final doc = await _usersCollection.doc(uid).get();
      final data = doc.data();
      final url = data?['photoUrl'] as String? ?? '';
      emit(ProfileLoaded(url: url));
    } catch (e) {
      emit(ProfileError(message: e.toString()));
    }
  }

  Future<void> updatePhotoUrl(String url) async {
    final uid = fb_auth.FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    emit(ProfileUpdating());
    try {
      await _usersCollection.doc(uid).update({'photoUrl': url});
      emit(ProfileLoaded(url: url));
    } catch (e) {
      emit(ProfileError(message: e.toString()));
    }
  }
}
