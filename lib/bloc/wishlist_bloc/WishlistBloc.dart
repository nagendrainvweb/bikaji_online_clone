import 'package:bikaji/bloc/wishlist_bloc/WishlistEvent.dart';
import 'package:bikaji/bloc/wishlist_bloc/WishlistState.dart';
import 'package:bikaji/model/BasicResponse.dart';
import 'package:bikaji/repo/Repository.dart';
import 'package:bikaji/repo/api_provider.dart';
import 'package:bikaji/util/constants.dart';
import 'package:bloc/bloc.dart';

class WishlistBloc extends Bloc<WishlistEvent, WishlistState> {
  WishlistBloc(WishlistState initialState) : super(initialState);


  @override
  WishlistState get initialState => WishlistNoAction();

  @override
  Stream<WishlistState> mapEventToState(WishlistEvent event) async* {
    if (event is AddToWishlist ) {
      yield WishlistAddingInProcess();
      try {
        BasicResponse response = await ApiProvider().addToWishlist(event.userid, event.productId);
        if (response.status == Constants.success) {
          yield WishlistProcessSuccess(response);
        } else {
          yield WishlistProcessFailed(response);
        }
      } catch (e) {
        yield WishlistProcessNotDone(message: e.toString());
      }
    }else if(event is RemovefromWishlist){
       yield WishlistAddingInProcess();
      try {
        BasicResponse response = await ApiProvider().removeFromWishlist(event.userid, event.productId);
        if (response.status == Constants.success) {
          yield WishlistProcessSuccess(response);
        } else {
          yield WishlistProcessFailed(response);
        }
      } catch (e) {
        yield WishlistProcessNotDone(message: e.toString());
      }
    }else if(event is FetchWishlist){
      yield WishlistLoading();
      try{
        BasicResponse response = await ApiProvider().fetchWishList(1);
        if(response.status == Constants.success){
          yield WishlistSuccess(response.data);
        }else{
          yield WishlistFailed(response);
        }
      }catch(e){
        yield WishlistIsNotLoaded(messagge: e.toString());
      }
    }
  }
}