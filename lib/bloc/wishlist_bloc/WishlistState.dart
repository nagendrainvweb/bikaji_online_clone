import 'package:bikaji/model/BasicResponse.dart';
import 'package:bikaji/model/wishlist_response.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';

class WishlistState extends Equatable {
  @override
  // TODO: implement props
  List<Object> get props => [];
}

class WishlistLoading extends WishlistState {}

class WishlistSuccess extends WishlistState {
 final WishListResponse _response;
  WishlistSuccess(this._response);
  get getWishlist => this._response;
}

class WishlistFailed extends WishlistState {
 final BasicResponse response;
  WishlistFailed(this.response);
  get getError => this.response;
}

class WishlistIsNotLoaded extends WishlistState {
  final messagge;
  WishlistIsNotLoaded({@required this.messagge});
}


// state for adding/Removing to wishlist
class WishlistNoAction extends WishlistState {}

class WishlistAddingInProcess extends WishlistState {}

class WishlistRemovingInProcess extends WishlistState {}

class WishlistProcessSuccess extends WishlistState {
  final BasicResponse _response;
  WishlistProcessSuccess(this._response);
  get getResponse => this._response;
}

class WishlistProcessFailed extends WishlistState {
  BasicResponse _response;
  WishlistProcessFailed(this._response);
  get getResponse => this._response;
}

class WishlistProcessNotDone extends WishlistState {
  final message;
  WishlistProcessNotDone({@required this.message});
}
