import 'package:bikaji/model/BasicResponse.dart';
import 'package:bikaji/model/CategoryData.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';

class CategoryState extends Equatable{
  @override
  // TODO: implement props
  List<Object> get props => [];
}

class CategoryLoading extends CategoryState{}
class CategoryNotLoaded extends CategoryState{
  final message;
  CategoryNotLoaded({@required this.message});
}

class CategorySuccess extends CategoryState{
 final List<CategoryData> _list;
  CategorySuccess(this._list);

  get getList => this._list;
}

class CategoryFailed extends CategoryState{
 final BasicResponse _response;
  CategoryFailed(this._response);
  get getResponse => this._response;
}