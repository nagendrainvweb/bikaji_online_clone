import 'package:bikaji/model/BasicResponse.dart';
import 'package:bikaji/model/ProductListResponse.dart';
import 'package:bikaji/model/product.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';

class ProductState extends Equatable{
  @override
  // TODO: implement props
  List<Object> get props => [];
}

class ProductLoadingState extends ProductState{

}
class ProductLoadMoreLoadingState extends ProductState{

}
class ProductSuccessState extends ProductState{
 final ProductListResponse response;
  ProductSuccessState(this.response);
   @override
  List<Object> get props => [response];
}
class ProductFailedState extends ProductState{
  final BasicResponse response;
  ProductFailedState(this.response);
   @override
  List<Object> get props => [response];
}
class ProductIsNotLoadedState extends ProductState{
  final message;
  ProductIsNotLoadedState({@required this.message});

}
