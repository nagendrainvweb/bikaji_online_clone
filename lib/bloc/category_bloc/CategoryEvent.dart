import 'package:equatable/equatable.dart';

class CategoryEvent extends Equatable{
  @override
  // TODO: implement props
  List<Object> get props => [];
}

class FetchCategory extends CategoryEvent{
  var userId;
  FetchCategory(this.userId);
}