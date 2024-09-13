import 'package:equatable/equatable.dart';

class WishlistEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class FetchWishlist extends WishlistEvent {
  FetchWishlist();
  @override
  List<Object> get props => [];

}

class AddToWishlist extends WishlistEvent {
  final userid;
  final productId;

  AddToWishlist(this.userid, this.productId);
   @override
  List<Object> get props => [userid,productId];
}

class RemovefromWishlist extends WishlistEvent {
  final userid;
  final productId;

  RemovefromWishlist(this.userid, this.productId);
   @override
  List<Object> get props => [userid,productId];
}