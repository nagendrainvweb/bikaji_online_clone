import 'package:bikaji/model/AddressData.dart';
import 'package:bikaji/model/product.dart';

class OrderDetailsData {
  Status status;
  List<Product> product;
  Payment payment;
  AddressData billingAddress;
  AddressData shippingAddress;

  OrderDetailsData(
      {this.status,
      this.product,
      this.payment,
      this.billingAddress,
      this.shippingAddress});

  OrderDetailsData.fromJson(Map<String, dynamic> json) {
    status =
        json['status'] != null ? new Status.fromJson(json['status']) : null;
    if (json['product'] != null) {
      product = new List<Product>();
      json['product'].forEach((v) {
        product.add(new Product.fromJson(v));
      });
    }
    payment =
        json['payment'] != null ? new Payment.fromJson(json['payment']) : null;
    billingAddress = json['billing_address'] != null
        ? new AddressData.fromJson(json['billing_address'])
        : null;
    shippingAddress = json['shipping_address'] != null
        ? new AddressData.fromJson(json['shipping_address'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.status != null) {
      data['status'] = this.status.toJson();
    }
    if (this.product != null) {
      data['product'] = this.product.map((v) => v.toJson()).toList();
    }
    if (this.payment != null) {
      data['payment'] = this.payment.toJson();
    }
    if (this.billingAddress != null) {
      data['billing_address'] = this.billingAddress.toJson();
    }
    if (this.shippingAddress != null) {
      data['shipping_address'] = this.shippingAddress.toJson();
    }
    return data;
  }
}

class Status {
  String id;
  String orderId;
  String status;
  String shipping;
  String orderDate;
  String statusDate;

  Status({this.status, this.shipping, this.orderDate,this.id,this.orderId, this.statusDate});

  Status.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    orderId = json['order_id'];
    status = json['status'];
    shipping = json['shipping'];
    orderDate = json['order_date'];
    statusDate = json['status_date'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['order_id'] = this.orderId;
    data['status'] = this.status;
    data['shipping'] = this.shipping;
    data['order_date'] = this.orderDate;
    data['status_date'] = this.statusDate;
    return data;
  }
}



class Payment {
  String paymentAmount;
  String paymentMethod;

  Payment({this.paymentAmount, this.paymentMethod});

  Payment.fromJson(Map<String, dynamic> json) {
    paymentAmount = json['payment_amount'];
    paymentMethod = json['payment_method'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['payment_amount'] = this.paymentAmount;
    data['payment_method'] = this.paymentMethod;
    return data;
  }
}

