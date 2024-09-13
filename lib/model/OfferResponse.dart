class OfferResponse {
  List<Offers> offers;
   List<OffersImg> offersImg;
  int minimumVal;
  int maximumVal;

  OfferResponse({this.offers, this.minimumVal, this.maximumVal});

  OfferResponse.fromJson(Map<String, dynamic> json) {
    if (json['offers'] != null) {
      offers = new List<Offers>();
      json['offers'].forEach((v) {
        offers.add(new Offers.fromJson(v,isOffer: true));
      });
    }
    if (json['offers_img'] != null) {
      offersImg = new List<OffersImg>();
      json['offers_img'].forEach((v) {
        offersImg.add(new OffersImg.fromJson(v));
      });
    }
    minimumVal = json['minimum_val'];
    maximumVal = json['maximum_val'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.offers != null) {
      data['offers'] = this.offers.map((v) => v.toJson()).toList();
    }
     if (this.offersImg != null) {
      data['offers_img'] = this.offersImg.map((v) => v.toJson()).toList();
    }
    data['minimum_val'] = this.minimumVal;
    data['maximum_val'] = this.maximumVal;
    return data;
  }
}

class Offers {
  String id;
  String name;
  String fromDate;
  String toDate;
  String discountType;
  String discountAmount;
  String fromAmount;
  String toAmount;
  String discount;
  String usesPerCustomer;
  String cname;
  String description;
  bool isOffer;

  Offers(
      {this.id,
      this.name,
      this.fromDate,
      this.toDate,
      this.discountType,
      this.discountAmount,
      this.fromAmount,
      this.toAmount,
      this.discount,
      this.isOffer,
      this.cname,
      this.description,
      this.usesPerCustomer});

  Offers.fromJson(Map<String, dynamic> json,{bool isOffer}) {
    id = json['id'];
    name = json['name'];
    fromDate = json['from_date'];
    toDate = json['to_date'];
    discountType = json['discount_type'];
    discountAmount = json['discount_amount'].toString();
    fromAmount = json['from_amount'].toString();
    toAmount = json['to_amount'].toString();
    usesPerCustomer = json['uses_per_customer'];
    discount = json['discount'].toString();
    cname= json['cname'];
    description = json['description'];
    this.isOffer = isOffer;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['from_date'] = this.fromDate;
    data['to_date'] = this.toDate;
    data['discount_type'] = this.discountType;
    data['discount_amount'] = this.discountAmount;
    data['from_amount'] = this.fromAmount;
    data['to_amount'] = this.toAmount;
    data['uses_per_customer'] = this.usesPerCustomer;
    data['discount'] = this.discount;
    data['cname'] = this.cname;
    data['description'] = this.description;
    data['isOffer'] = this.isOffer;
    return data;
  }
}

class OffersImg {
  String bannerUrl;

  OffersImg({this.bannerUrl});

  OffersImg.fromJson(Map<String, dynamic> json) {
    bannerUrl = json['bannerUrl'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['bannerUrl'] = this.bannerUrl;
    return data;
  }
}