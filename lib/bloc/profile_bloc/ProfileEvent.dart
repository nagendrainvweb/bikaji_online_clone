import 'package:equatable/equatable.dart';

class ProfileEvent extends Equatable{
  @override
  List<Object> get props => [];

}

class FetchProfileEvent extends ProfileEvent{
  final userId;
  FetchProfileEvent(this.userId);

  @override
  List<Object> get props => [userId];
}

class UpdateProfiledetailsEvent extends ProfileEvent{
  final userId;
  final name;
  final image;
  final email;
  final dob;

  UpdateProfiledetailsEvent(this.userId,this.name,this.image,this.email,this.dob);
  @override 
  List<Object> get props => [userId,name,image,email,dob];
}