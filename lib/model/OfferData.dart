class OfferData{
  var id;
  var title;
  var desc;
  var code;
  var expiry_date;

  OfferData({this.id,this.title,this.desc,this.code,this.expiry_date});

  factory OfferData.fromJson(Map<String,dynamic> json){
    return OfferData(
      id: json["id"],
      title: json["title"],
      desc: json["desc"],
      code: json['code'],
      expiry_date: json["expiry_date"]
    );
  }

}