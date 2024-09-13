class CategoryData{
  var id;
  var title;
  var itemCount;
  var imageUrl;
  var hasSubcats;

  CategoryData({this.id,this.title,this.itemCount,this.imageUrl,this.hasSubcats});

  factory CategoryData.fromJson(Map<String,dynamic> json){
    return CategoryData(
      id: json["id"],
      title: json['title'],
      itemCount: json['itemCount'],
      imageUrl: json['imageUrl'],
      hasSubcats: json['hasSubcats']
    );
  }

    Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['title'] = this.title;
    data['itemCount'] = this.itemCount;
    data['imageUrl'] = this.imageUrl;
    data['hasSubcats'] = this.hasSubcats;
    return data;
  }
}