import 'package:equatable/equatable.dart';
import 'package:yemen_stor/features/menu/domain/entities/shop.dart';
import 'package:yemen_stor/features/menu/domain/entities/network.dart';

abstract class MenuState extends Equatable {
  const MenuState();

  @override
  List<Object?> get props => [];
}

class MenuInitial extends MenuState {}

class MenuLoading extends MenuState {}

class MenuLoaded extends MenuState {
  final List<Shop> shops;
  final List<Network> networks;

  const MenuLoaded({required this.shops, required this.networks});

  @override
  List<Object?> get props => [shops, networks];
}

class MenuError extends MenuState {
  final String message;
  const MenuError(this.message);

  @override
  List<Object?> get props => [message];
}
