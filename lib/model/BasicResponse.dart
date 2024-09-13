import 'package:bikaji/util/url_list.dart';

class BasicResponse<T> {
  var timestamp;
  var status;
  var code;
  var message;
  var isUpdate;
  int cartCount;
  bool isForce;
  String pageContent;
  String pageName;
  String c;
  T data;

  BasicResponse(
      {this.timestamp,
      this.status,
      this.code,
      this.message,
      this.data,
      this.isForce,
      this.isUpdate,
      this.pageName,
      this.c,
      this.pageContent,
      this.cartCount});

  factory BasicResponse.fromJson({Map<String, dynamic> json, var data}) {
    return BasicResponse(
      timestamp: json[UrlConstants.TIMESTAMP],
      status: json[UrlConstants.STATUS],
      code: json[UrlConstants.CODE],
      message: json[UrlConstants.MESSAGE],
      cartCount: json['cart_count'],
      isUpdate: json['isUpdate'],
      pageContent: json["page_content"],
      pageName: json["page_name"],
      isForce: json["isForce"],
      c:json["c"],
      data: data,
    );
  }
}
