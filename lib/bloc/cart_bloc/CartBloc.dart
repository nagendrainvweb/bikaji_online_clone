import 'package:bikaji/model/BasicResponse.dart';
import 'package:bikaji/model/CartData.dart';
import 'package:bikaji/repo/Repository.dart';
import 'package:bikaji/repo/api_provider.dart';
import 'package:bikaji/util/constants.dart';
import 'package:bloc/bloc.dart';

import 'CartState.dart';
class CartBloc extends Bloc<CartEvent, CartState> {
  CartBloc(CartState initialState) : super(initialState);

  @override
  CartState get initialState => CartIsLoadingState();

  @override
  Stream<CartState> mapEventToState(CartEvent event) async* {
    if (event is FetchCartEvent) {
      yield CartIsLoadingState();
      // try {
      //   BasicResponse response = await repository.fetchCartDetails(event.userid);
      //   if (response.status == Constants.success) {
      //     CartData cartData = response.data;
      //     yield CartLoadingSuccessState(cartData);
      //   } else {
      //     yield CartLoadingFailedState(response);
      //   }
      // } catch (e) {
      //   yield CartIsNotLoadedState(message: e.toString());
      // }
    } else if (event is RemoveCartEvent) {
     yield CartProcessLoadingState();
      try {
        BasicResponse response =
            await ApiProvider().removeFromCart(event.userid, event.productId);
        if (response.status == Constants.success) {
         yield  CartProcessSuccessState(response);
        } else {
         yield  CartProcessFailedState(response);
        }
      } catch (e) {
        yield CartProcessIsNotdoneState(message: e.toString());
      }
    } else if (event is MoveFromCartToWishlistEvent) {
     yield CartProcessLoadingState();
      try {
        BasicResponse response =
            await ApiProvider().moveFromCartToWishlist(event.userid, event.productId);
        if (response.status == Constants.success) {
         yield  CartProcessSuccessState(response);
        } else {
          yield CartProcessFailedState(response);
        }
      } catch (e) {
        yield CartProcessIsNotdoneState(message: e.toString());
      }
    }
  }
}
