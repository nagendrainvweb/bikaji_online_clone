import 'package:bikaji/model/BasicResponse.dart';
import 'package:bikaji/model/CartData.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';

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

class CartState extends Equatable {
  @override
  List<Object> get props => [];
}
// cart process state
class CartProcessLoadingState extends CartState{}
class CartProcessSuccessState extends CartState {
  final BasicResponse response;
  CartProcessSuccessState(this.response);
  @override
  List<Object> get props => [this.response];
}
class CartProcessFailedState extends CartState {
  final BasicResponse response;
  CartProcessFailedState(this.response);
  @override
  List<Object> get props => [this.response];
}
class CartProcessIsNotdoneState extends CartState{
  final message;
  CartProcessIsNotdoneState({@required this.message});
}
//end of cart process state


// cart loading state
class CartIsLoadingState extends CartState {}



class CartLoadingSuccessState extends CartState {
  final CartData data;
  CartLoadingSuccessState(this.data);
  @override
  List<Object> get props => [this.data];
}

class CartLoadingFailedState extends CartState {
  final BasicResponse response;
  CartLoadingFailedState(this.response);
  @override
  List<Object> get props => [this.response];
}

class CartIsNotLoadedState extends CartState {
  final message;
  CartIsNotLoadedState({@required this.message});
}
