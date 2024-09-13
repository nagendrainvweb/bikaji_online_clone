import 'package:equatable/equatable.dart';

class LoginEvent extends Equatable{
  @override
  // TODO: implement props
  List<Object> get props => [];

}

class FetchLoginEvent extends LoginEvent{
  var number;
  FetchLoginEvent(this.number);

  @override
  // TODO: implement props
  List<Object> get props => [number];
}