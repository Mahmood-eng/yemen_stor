import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:yemen_stor/features/menu/data/models/shop_model.dart';
import 'package:yemen_stor/features/menu/data/models/network_model.dart';
import 'menu_state.dart';

class MenuCubit extends Cubit<MenuState> {
  MenuCubit() : super(MenuInitial());

  Future<void> loadAccounts(String uid) async {
    emit(MenuLoading());
    try {
      final shopSnapshot = await FirebaseFirestore.instance
          .collection('shops')
          .where('ownerId', isEqualTo: uid)
          .get();
      
      final networkSnapshot = await FirebaseFirestore.instance
          .collection('networks')
          .where('ownerId', isEqualTo: uid)
          .get();

      final shops = shopSnapshot.docs.map((doc) => ShopModel.fromDocument(doc)).toList();
      final networks = networkSnapshot.docs.map((doc) => NetworkModel.fromDocument(doc)).toList();

      emit(MenuLoaded(shops: shops, networks: networks));
    } catch (e) {
      emit(MenuError(e.toString()));
    }
  }
}
