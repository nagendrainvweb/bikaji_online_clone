class AccountModel{
  var id;
  var name;
  var profile_pic;
  var email_id;
  var mobileNumber;
  var dob;
  var city;
  var state;
  AccountModel({this.id,this.name,this.profile_pic,this.email_id,this.mobileNumber,this.dob,this.city,this.state});

  factory AccountModel.fromJson(Map<String,dynamic> json){
    return AccountModel(
      id: json["id"],
      name: json["name"],
      profile_pic: json["profile_pic"],
      email_id: json["email_id"],
      mobileNumber: json["mobileNumber"],
      dob: json["dob"],
      city: json["city"],
      state: json["state"]
    );
  }
}