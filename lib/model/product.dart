
import 'package:bikaji/util/utility.dart';

class Product {
  String id;
  String name;
  String desc;
  String category;
  String category_id;
  bool isOffer;
  int offer;
  String oldPrice;
  int newPrice;
  bool isInCart;
  bool isInStock;
  bool isInWishlist;
  int size_id;
  var qty;
  List<Images> images;
  List<Sizes> sizes;
  int amount;
  int orderBy;

  Product(
      {this.id,
      this.name,
      this.desc,
      this.category,
      this.category_id,
      this.isOffer,
      this.offer,
      this.oldPrice,
      this.newPrice,
      this.isInCart,
      this.isInStock,
      this.isInWishlist,
      this.qty,
      this.size_id,
      this.amount,
      this.images,
      this.orderBy,
      this.sizes});

  Product.fromJson(Map<String, dynamic> json,{int order}) {
    id = json['id'];
    name = json['name'];
    desc = (json['desc']==null)?"":Utility.removeAllHtmlTags(json['desc']);
    category = json['category'];
    category_id = json['category_id'];
    isOffer = json['isOffer'];
    offer = json['offer'];
    oldPrice = json['old_price'];
    newPrice = double.parse(json['new_price'].toString()).toInt();
    isInCart = json['isInCart'];
    isInStock = json['isInStock'];
    isInWishlist = json['isInWishlist'];
    qty = json['qty'];
    size_id = json['size_id'];
    amount = json['amount'];
    orderBy = order;
    if (json['images'] != null) {
      images = new List<Images>();
      json['images'].forEach((v) {
        images.add(new Images.fromJson(v));
      });
    }
    if (json['sizes'] != null) {
      sizes = new List<Sizes>();
      json['sizes'].forEach((v) {
        sizes.add(new Sizes.fromJson(v));
      });
      sizes.sort((a,b){
        double aPrice  = double.parse(a.newPrice.toString());
        double bPrice  = double.parse(b.newPrice.toString());
        return aPrice.compareTo(bPrice);
      });
    }
  }

  Map<String,dynamic> toCartJson(){
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['product_id'] = this.id;
    data['qty'] = this.qty;
    data['category_id'] = this.category_id;
    data['size'] = this.size_id;
    data['amount'] = this.amount;
    return data;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['desc'] = this.desc;
    data['category'] = this.category;
    data['isOffer'] = this.isOffer;
    data['offer'] = this.offer;
    data['old_price'] = this.oldPrice;
    data['size_id'] = this.size_id;
    data['new_price'] = this.newPrice;
    data['isInCart'] = this.isInCart;
    data['isInStock'] = this.isInStock;
    data['isInWishlist'] = this.isInWishlist;
    data['qty'] = this.qty;
    data['amount'] = this.amount;
    if (this.images != null) {
      data['images'] = this.images.map((v) => v.toJson()).toList();
    }
    if (this.sizes != null) {
      data['sizes'] = this.sizes.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Images {
  String id;
  String imageUrl;

  Images({this.id, this.imageUrl});

  Images.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    imageUrl = json['image_url'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['image_url'] = this.imageUrl;
    return data;
  }
}

class Sizes {
  String id;
  String size;
  String oldPrice;
  String newPrice;

  Sizes({this.id, this.size, this.oldPrice, this.newPrice});

  Sizes.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    size = json['size'];
    oldPrice = json['old_price'];
    newPrice = json['new_price'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['size'] = this.size;
    data['old_price'] = this.oldPrice;
    data['new_price'] = this.newPrice;
    return data;
  }
}






 
