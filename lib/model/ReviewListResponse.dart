import 'package:bikaji/model/Pagination.dart';
import 'package:bikaji/model/ProductData.dart';

class ReviewListResponse {
  Pagination links;
  ReviewData items;

  ReviewListResponse({this.links, this.items});

  ReviewListResponse.fromJson(Map<String, dynamic> json) {
    links = json['links'] != null ? new Pagination.fromJson(json['links']) : null;
    items = json['items'] != null ? new ReviewData.fromJson(json['items']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.links != null) {
      data['links'] = this.links.toJson();
    }
    if (this.items != null) {
      data['items'] = this.items.toJson();
    }
    return data;
  }
}
