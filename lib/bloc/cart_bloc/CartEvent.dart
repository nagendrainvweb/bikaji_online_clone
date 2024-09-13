import 'package:equatable/equatable.dart';

class CartEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class FetchCartEvent extends CartEvent {
  final userid;
  FetchCartEvent(this.userid);

  @override
  List<Object> get props => [userid];
}

class RemoveCartEvent extends CartEvent {
  final userid;
  final productId;

  RemoveCartEvent(this.userid, this.productId);
  @override
  List<Object> get props => [userid, productId];
}

class MoveFromCartToWishlistEvent extends CartEvent {
  final userid;
  final productId;

  MoveFromCartToWishlistEvent(this.userid, this.productId);
  @override
  List<Object> get props => [userid, productId];
}