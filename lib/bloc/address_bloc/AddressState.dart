import 'package:bikaji/model/AddressData.dart';
import 'package:bikaji/model/BasicResponse.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';

class AddressState extends Equatable{
  @override
  // TODO: implement props
  List<Object> get props => [];
}

class AddressLoadingState extends AddressState{

}

class AddressLoadingSuccessState extends AddressState{
  final List<AddressData> data;
  AddressLoadingSuccessState({@required this.data});
  @override 
  List<Object> get props => [data];
}

class AddressAddEditSuccessState extends AddressState{
 final BasicResponse response;
  AddressAddEditSuccessState(this.response);
  @override 
  List<Object> get props => [response];
}

class AddressLoadingFailedState extends AddressState{
 final BasicResponse response;
  AddressLoadingFailedState(this.response);

  @override 
  List<Object> get props => [];
}

class AddressNotLoadedState extends AddressState{
  final message;
  AddressNotLoadedState({@required this.message});
}