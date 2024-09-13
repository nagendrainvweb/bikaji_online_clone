import 'package:bikaji/model/BasicResponse.dart';
import 'package:bikaji/model/ProductData.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';

class ReviewState extends Equatable{
  @override
  List<Object> get props => [];
}

class ReviewLoadingState extends ReviewState{}
class ReviewLoadMoreLoadingState extends ReviewState{}
class ReviewNotLoadedState extends ReviewState{
  final message;
  ReviewNotLoadedState({@required this.message});
}
class ReviewLoadingSucessState extends ReviewState{
  final List<Review> list;
  ReviewLoadingSucessState(this.list);
   @override
  List<Object> get props => [list];

  get getList => this.list;

}
class ReviewLoadingFailedState extends ReviewState{
  final BasicResponse response;
  ReviewLoadingFailedState(this.response);
   @override
  List<Object> get props => [response];

  get getResponse => this.response;
}
