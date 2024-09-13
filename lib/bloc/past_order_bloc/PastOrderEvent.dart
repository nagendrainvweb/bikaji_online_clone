import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';

class PastOrderEvent extends Equatable{
  @override
  List<Object> get props => [];
}

class FetchPastOrderEvent extends PastOrderEvent{
  final id;
  FetchPastOrderEvent({@required this.id});

   @override
  List<Object> get props => [this.id];
}