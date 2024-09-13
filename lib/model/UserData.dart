class User {
  String accessToken;
  String id;
  String firstName;
  String lastName;
  String dob;
  String mobileNumber;
  String emailId;
  String profile_pic;

  User(
      {this.accessToken,
      this.id,
      this.firstName,
      this.lastName,
      this.dob,
      this.mobileNumber,
      this.profile_pic,
      this.emailId});

  User.fromJson(Map<String, dynamic> json) {
    accessToken = json['access_token'];
    id = json['id'];
    firstName = json['first_name'];
    lastName = json['last_name'];
    dob = json['dob'];
    mobileNumber = json['mobile_number'];
    profile_pic = json['profile_pic'];
    emailId = json['email_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['access_token'] = this.accessToken;
    data['id'] = this.id;
    data['first_name'] = this.firstName;
    data['last_name'] = this.lastName;
    data['dob'] = this.dob;
    data['mobile_number'] = this.mobileNumber;
    data['profile_pic'] = this.profile_pic;
    data['email_id'] = this.emailId;
    return data;
  }
}