import 'package:bikaji/bloc/past_order_bloc/PastOrderEvent.dart';
import 'package:bikaji/bloc/past_order_bloc/PastOrderState.dart';
import 'package:bloc/bloc.dart';

class PastOrderBloc extends Bloc<PastOrderEvent,PastOrderState>{
  PastOrderBloc(PastOrderState initialState) : super(initialState);

  @override
  // TODO: implement initialState
  PastOrderState get initialState => throw UnimplementedError();

  @override
  Stream<PastOrderState> mapEventToState(PastOrderEvent event) async* {
    
  }

}