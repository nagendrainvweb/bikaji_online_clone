import 'package:bikaji/model/product.dart';

class CartData{
  var gift_warp_charges;
  var delivery_charges;
  var wallet_balance;
  var amount;
  var paid_amount;
  List<Product> productList;

  CartData({this.gift_warp_charges,this.delivery_charges,this.wallet_balance,this.amount,this.paid_amount,this.productList});

  factory CartData.fromJson(Map<String,dynamic> json){

      List array = json["product"];
      List<Product> productList = [];

      for(var i=0;i<array.length;i++){
        productList.add(array[i]);
      }
    return CartData(
      gift_warp_charges: json["gift_warp_charges"],
      delivery_charges: json["delivery_charges"],
      wallet_balance: json["wallet_balance"],
      amount: json["amount"],
      paid_amount: json["paid_amount"],
      productList: productList,
    );
  }

  
}