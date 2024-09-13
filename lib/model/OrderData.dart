class PendingOrderData{
  var id;
  var order_date;
  var current_state;
  var status_date;

  PendingOrderData({this.id,this.order_date,this.current_state,this.status_date});

  factory PendingOrderData.fromJson(Map<String,dynamic> map){
    return PendingOrderData(
      id: map['id'],
      order_date: map['order_date'],
      current_state: map['current_state'],
      status_date: map['status_date']
    );
  }

}