class UpdateCartResponse {
  String totalAmount;
  int discountAmount;
  int payingAmount;
  String offerName;
  String discountType;
  String coupon_name;
  String coupon_description;
  String payMsg;
  String paytmText;
  bool isValid;

  UpdateCartResponse(
      {this.totalAmount,
      this.discountAmount,
      this.payingAmount,
      this.offerName,
      this.coupon_name,
      this.payMsg,
      this.paytmText,
      this.isValid,
      this.coupon_description,
      this.discountType});

  UpdateCartResponse.fromJson(Map<String, dynamic> json) {
    totalAmount = json['total_amount'];
    discountAmount = json['discount_amount'];
    payingAmount = json['paying_amount'];
    offerName = json['offer_name'];
    coupon_description = json['coupon_description'];
    coupon_name = json['coupon_name'];
    discountType = json['discount_type'];
    payMsg = json["pay_msg"];
    paytmText = json["paytm_text"];
    isValid = json['isValid'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['total_amount'] = this.totalAmount;
    data['discount_amount'] = this.discountAmount;
    data['paying_amount'] = this.payingAmount;
    data['offer_name'] = this.offerName;
    data['discount_type'] = this.discountType;
    data['coupon_name'] = this.coupon_name;
    data['coupon_description'] = this.coupon_description;
    return data;
  }
}