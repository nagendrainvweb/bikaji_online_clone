import 'package:bikaji/bloc/login_bloc/LoginEvent.dart';
import 'package:bikaji/bloc/login_bloc/LoginState.dart';
import 'package:bikaji/model/BasicResponse.dart';
import 'package:bikaji/repo/Repository.dart';
import 'package:bikaji/repo/api_provider.dart';
import 'package:bikaji/util/constants.dart';
import 'package:bloc/bloc.dart';

class LoginBloc extends  Bloc<LoginEvent,LoginState>{
  LoginBloc(LoginState initialState) : super(initialState);


  @override
  // TODO: implement initialState
  LoginState get initialState => LoginNotClickedState();

  @override
  Stream<LoginState> mapEventToState(LoginEvent event)async* {
    
    if(event is FetchLoginEvent){
      yield LoginLoadingState();
      try{
        BasicResponse response = await ApiProvider().fetchUserlogin(event.number);
        if(response.status == Constants.success)
        yield LoginSuccessState(response);
        else
        yield  LoginFailedState(response);
      }catch(e){
        yield LoginNotLoadedState(message: e.toString());
      }
    }
  }

}