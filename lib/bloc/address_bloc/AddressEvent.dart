import 'package:equatable/equatable.dart';

class AddressEvent extends Equatable{
  @override
  List<Object> get props => [];
}

class FetchAddressEvent extends AddressEvent{
  final userId;
  FetchAddressEvent(this.userId);
  @override 
  List<Object> get props => [userId];
}

class AddEditAddressEvent extends AddressEvent{
  final user_id;
  final address_id;
  final name;
  final isDefault;
  final type;
  final number;
  final email_id;
  final flat_no;
  final street_name;
  final area;
  final landmark;
  final city;
  final state;
  final pincode;

  AddEditAddressEvent({this.user_id,this.address_id,this.name,this.isDefault,this.type,this.number,this.email_id,this.flat_no,this.street_name,this.area,this.landmark,this.city,this.state,this.pincode});

  @override 
  List<Object> get props => [user_id,address_id,name,isDefault,type,number,email_id,flat_no,street_name,area,landmark,city,state,pincode];
}