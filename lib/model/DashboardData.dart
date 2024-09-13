import 'package:bikaji/model/product.dart';

class DashboardData {
  int inCartcount;
  List<BannerData> banner;
  List<Products> products;

  DashboardData({this.inCartcount, this.banner, this.products});

  DashboardData.fromJson(Map<String, dynamic> json) {
    inCartcount = json['inCartcount'];
    if (json['banner'] != null) {
      banner = new List<BannerData>();
      json['banner'].forEach((v) {
        banner.add(new BannerData.fromJson(v));
      });
    }
    if (json['products'] != null) {
      products = new List<Products>();
      json['products'].forEach((v) {
        products.add(new Products.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['inCartcount'] = this.inCartcount;
    if (this.banner != null) {
      data['banner'] = this.banner.map((v) => v.toJson()).toList();
    }
    if (this.products != null) {
      data['products'] = this.products.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class BannerData {
  int id;
  String imageUrl;
  String type;
  String productId;

  BannerData({this.id, this.imageUrl, this.type, this.productId});

  BannerData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    imageUrl = json['imageUrl'];
    type = json['type'];
    productId = json['product_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['imageUrl'] = this.imageUrl;
    data['type'] = this.type;
    data['product_id'] = this.productId;
    return data;
  }
}

class Products {
  String title;
  List<Product> items;

  Products({this.title, this.items});

  Products.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    if (json['items'] != null) {
      items = new List<Product>();
      json['items'].forEach((v) {
        items.add(new Product.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['title'] = this.title;
    if (this.items != null) {
      data['items'] = this.items.map((v) => v.toJson()).toList();
    }
    return data;
  }
}



