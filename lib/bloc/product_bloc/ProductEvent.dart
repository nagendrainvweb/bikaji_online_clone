import 'package:equatable/equatable.dart';

class ProductEvent extends Equatable{
  @override
  List<Object> get props => [];
}

class FetchProduct extends ProductEvent{
  var userId;
  var pageNo;
  var categoryId;
  var type;
  FetchProduct({this.userId,this.pageNo,this.categoryId,this.type});

   @override
  List<Object> get props => [userId,pageNo,categoryId];
}

class LoadMoreProduct extends ProductEvent{
  var userId;
  var pageNo;
  var categoryId;
  var type;
  LoadMoreProduct(this.userId,this.pageNo,this.categoryId,this.type);

   @override
  List<Object> get props => [userId,pageNo,categoryId,type];
}


class FetchFilterProduct extends ProductEvent{
   var userId;
  var pageNo;
  var categoryId;
  var type;
  var priceFrom;
  var priceTo;
  FetchFilterProduct(this.userId,this.pageNo,this.categoryId,this.type,this.priceFrom,this.priceTo);

   @override
  List<Object> get props => [userId,pageNo,categoryId,type,priceFrom,priceTo];
}