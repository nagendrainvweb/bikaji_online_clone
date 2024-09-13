import 'package:equatable/equatable.dart';

class DashboardEvent extends Equatable{
  @override
  // TODO: implement props
  List<Object> get props => [];

}

class FetchDashboardEvent extends DashboardEvent{
  FetchDashboardEvent();

  @override
  // TODO: implement props
  List<Object> get props => [];
}

class RefreshDashboardEvent extends DashboardEvent{

  @override
  // TODO: implement props
  List<Object> get props => [];
}



class BottomSheetClickEvent extends DashboardEvent{
  final id;
  BottomSheetClickEvent({this.id});
}