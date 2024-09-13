
import 'package:bikaji/model/BasicResponse.dart';
import 'package:bikaji/model/DashboardData.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';

class DashboardState extends Equatable{
  @override
  // TODO: implement props
  List<Object> get props => [];

}

class DashboardLoadingState extends DashboardState{}
class DashboardNotLoadedState extends DashboardState{
  final message;
  DashboardNotLoadedState({@required this.message});
   @override
  // TODO: implement props
  List<Object> get props => [this.message];
}
class DashboardSuccessState extends DashboardState{
  final  DashboardData _response;
    DashboardSuccessState(this._response);
     @override
  // TODO: implement props
  List<Object> get props => [this._response];

  get getResponse => this._response;
}
class DashboardFailedState extends DashboardState{
  final BasicResponse _response;

  DashboardFailedState(this._response);
   @override
  // TODO: implement props
  List<Object> get props => [this._response];


  get getResponse => this._response;
}
