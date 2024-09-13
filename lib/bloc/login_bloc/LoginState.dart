import 'package:bikaji/model/BasicResponse.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';

class LoginState extends Equatable{
  @override
  // TODO: implement props
  List<Object> get props => [];

}

class LoginNotClickedState extends LoginState{}
class LoginLoadingState extends LoginState{}
class LoginResponseDoneState extends LoginState{}
class LoginNotLoadedState extends LoginState{
  final message;
  LoginNotLoadedState({@required this.message});
}
class LoginFailedState extends LoginState{
  final BasicResponse _response;

  LoginFailedState(this._response);

  get getResponse => this._response;
}
class LoginSuccessState extends LoginState{
 final BasicResponse _response;

  LoginSuccessState(this._response);

  get getResponse => this._response;

}