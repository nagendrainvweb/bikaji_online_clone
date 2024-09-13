class AddressData {
  String addressId;
  String firstName;
  String lastName;
  bool isDefault;
  String type;
  String emailId;
  String number;
  String flatNo;
  String streetName;
  String area;
  String landmark;
  String city;
  String state_id;
  String state;
  String pincode;

  AddressData(
      {this.addressId,
      this.firstName,
      this.lastName,
      this.isDefault,
      this.type,
      this.emailId,
      this.number,
      this.flatNo,
      this.streetName,
      this.area,
      this.landmark,
      this.city,
      this.state_id,
      this.state,
      this.pincode});

  AddressData.fromJson(Map<String, dynamic> json) {
    addressId = json['address_id '];
    firstName = json['first_name'];
    lastName = json['last_name'];
    isDefault = json['isDefault'];
    type = json['type'];
    emailId = json['email_id'];
    number = json['number'];
    state_id = json['state_id'];
    final address =
        streetName = json['street_name'].toString();
    final list =(address.contains(";"))?address.split(";"): address.split("\n");
    
    if (list.length > 2) {
      flatNo = list[0];
      streetName = list[1];
     // area = list[2];
      landmark = list[2];
    } else {
      flatNo = json['flat_no'].toString().replaceAll("\n", " ");
       streetName = "";
       area = "";
       landmark = "";
    }
    city = json['city'];
    state = json['state'];
    pincode = json['pincode'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['address_id'] = this.addressId;
    data['first_name'] = this.firstName;
    data['last_name'] = this.lastName;
    data['isDefault'] = this.isDefault.toString();
    data['type'] = this.type;
    data['email_id'] = this.emailId;
    data['number'] = this.number;
    data['flat_no'] = this.flatNo;
    data['state_id'] = this.state_id;
    data['street_name'] = this.streetName;
   // data['area'] = this.area;
    data['landmark'] = this.landmark;
    data['city'] = this.city;
    data['state'] = this.state;
    data['pincode'] = this.pincode;
    return data;
  }
}
