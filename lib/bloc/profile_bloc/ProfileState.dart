import 'package:bikaji/model/AccountModal.dart';
import 'package:bikaji/model/BasicResponse.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';

class ProfileState extends Equatable{
  @override
  // TODO: implement props
  List<Object> get props => [];
}

class ProfileIsLoadingState extends ProfileState{

}
class ProfileLoadingSuccessState extends ProfileState{
 final AccountModel data;
  ProfileLoadingSuccessState(this.data);
    @override
  // TODO: implement props
  List<Object> get props => [data];
}
class ProfileUpadteLoadingSuccessState extends ProfileState{
  final BasicResponse response;
  ProfileUpadteLoadingSuccessState(this.response);
    @override
  List<Object> get props => [response];
}

class ProfileLoadingFailedState extends ProfileState{
  final BasicResponse response;
  ProfileLoadingFailedState(this.response);
  @override 
  List<Object> get props => [response];
}

class ProfileNotLoadedState extends ProfileState{
  final message;
  ProfileNotLoadedState({@required this.message});
}