class PastOrderData {
  String id;
  String orderId;
  String status;
  String orderDate;
  String statusDate;

  PastOrderData(
      {this.id, this.orderId, this.status, this.orderDate, this.statusDate});

  PastOrderData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    orderId = json['order_id'];
    status = json['status'];
    orderDate = json['order_date'];
    statusDate = json['status_date'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['order_id'] = this.orderId;
    data['status'] = this.status;
    data['order_date'] = this.orderDate;
    data['status_date'] = this.statusDate;
    return data;
  }
}
