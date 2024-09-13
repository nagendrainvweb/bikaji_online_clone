import 'package:equatable/equatable.dart';

class PastOrderState extends Equatable{
  @override
  // TODO: implement props
  List<Object> get props => [];
}

class PastOrderLoadingState extends PastOrderState{}
class PastOrderLoadedState extends PastOrderState{}
class PastOrderLoadingFailed extends PastOrderState{}
class PastOrderNotLoaded extends PastOrderState{}