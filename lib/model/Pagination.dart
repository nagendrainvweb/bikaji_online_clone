class Pagination{
  int self;
  int next;
  int last;
  bool isNext;
  int total;

  Pagination({this.self,this.next,this.last,this.isNext,this.total});

  factory Pagination.fromJson(Map<String,dynamic> json){
    return Pagination(
      self: json["self"],
      next: json["next"],
      last: json["last"],
      isNext: json["isNext"],
      total: json["total"]
    );
  }

    Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['self'] = this.self;
    data['next'] = this.next;
    data['last'] = this.last;
    data['isNext'] = this.isNext;
    data['total'] = this.total;
    return data;
  }
}