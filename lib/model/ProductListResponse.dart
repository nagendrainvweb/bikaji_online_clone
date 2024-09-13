import 'package:bikaji/model/product.dart';

import 'Pagination.dart';

class ProductListResponse{
   Pagination pagination;
  List<Product> productlist;

  ProductListResponse({this.pagination,this.productlist});

  factory ProductListResponse.fromJson(Map<String,dynamic> json){
    Pagination pagination = Pagination.fromJson(json["links"]);
    List itemsArray = json["items"];
    List<Product> productlist = [];

    for(var i=0;i<itemsArray.length;i++){
      productlist.add(Product.fromJson(itemsArray[i],order: i));
    }

    return ProductListResponse(
      pagination: pagination,
      productlist: productlist,
    );

  }
}