import 'package:bikaji/model/Pagination.dart';
import 'package:bikaji/model/product.dart';

class WishListResponse{

  Pagination pagination;
  List<Product> wishlist;

  WishListResponse({this.pagination,this.wishlist});

  factory WishListResponse.fromJson(Map<String,dynamic> json){
    Pagination pagination = Pagination.fromJson(json["links"]);
    List itemsArray = json["items"];
    List<Product> wishlist = [];

    for(var i=0;i<itemsArray.length;i++){
      wishlist.add(Product.fromJson(itemsArray[i]));
    }

    return WishListResponse(
      pagination: pagination,
      wishlist: wishlist,
    );

  }
}