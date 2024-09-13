import 'package:bikaji/bloc/product_bloc/ProductEvent.dart';
import 'package:bikaji/bloc/product_bloc/ProductState.dart';
import 'package:bikaji/model/BasicResponse.dart';
import 'package:bikaji/repo/Repository.dart';
import 'package:bikaji/repo/api_provider.dart';
import 'package:bikaji/util/constants.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';

class ProductBloc extends Bloc<ProductEvent, ProductState> {


  ProductBloc(ProductState initialState) : super(initialState);


  @override
  ProductState get initialState => ProductLoadingState();

  @override
  Stream<ProductState> mapEventToState(ProductEvent event) async* {
    if (event is FetchProduct) {
      yield ProductLoadingState();
      try {
        BasicResponse response;
        if (event.categoryId.isEmpty) {
          response = await ApiProvider().fetchProductByType(
              event.userId, event.pageNo, event.type);
        } else {
          response = await ApiProvider().fetchProductList(
              event.userId, event.pageNo, event.categoryId);
        }

        if (response.status == Constants.success) {
          yield ProductSuccessState(response.data);
        } else {
          yield ProductFailedState(response);
        }
      } catch (e) {
        yield ProductIsNotLoadedState(message: e.toString());
      }
    } else if (event is LoadMoreProduct) {
      ProductLoadMoreLoadingState();
      try {
        BasicResponse response = await ApiProvider().fetchProductList(
            event.userId, event.pageNo, event.categoryId);
        if (response.status == Constants.success) {
          yield ProductSuccessState(response.data);
        } else {
          yield ProductFailedState(response);
        }
      } catch (e) {
        yield ProductIsNotLoadedState(message: e.toString());
      }
    } else if (event is FetchFilterProduct) {
      yield ProductLoadingState();
      try {
        final response = await ApiProvider().fetchFilteredProductList(event.userId, event.pageNo, event.categoryId, event.type, event.priceFrom, event.priceTo);
        if (response.status == Constants.success) {
          yield ProductSuccessState(response.data);
        } else {
          yield ProductSuccessState(response.data);
        }
      } catch (e) {
        yield ProductIsNotLoadedState(message: e.toString());
      }
    }
  }
}
