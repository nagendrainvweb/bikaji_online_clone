import 'package:bikaji/bloc/profile_bloc/ProfileEvent.dart';
import 'package:bikaji/bloc/profile_bloc/ProfileState.dart';
import 'package:bikaji/model/BasicResponse.dart';
import 'package:bikaji/repo/api_provider.dart';
import 'package:bikaji/util/constants.dart';
import 'package:bloc/bloc.dart';
class ProfileBloc extends Bloc<ProfileEvent,ProfileState> {

  ProfileBloc(ProfileState initialState) : super(initialState);


  @override
  // TODO: implement initialState
  ProfileState get initialState => ProfileIsLoadingState();

  @override
  Stream<ProfileState> mapEventToState(ProfileEvent event)async* {
    if(event is FetchProfileEvent){
     yield ProfileIsLoadingState();
      try{
        BasicResponse response = await ApiProvider().fetchProfileDetails(event.userId);
        if(response.status == Constants.success){
         yield ProfileLoadingSuccessState(response.data);
        }else{
         yield ProfileLoadingFailedState(response);
        }
      }catch(e){
       yield ProfileNotLoadedState(message: e.toString());
      }
    }else if(event is UpdateProfiledetailsEvent){
      yield ProfileIsLoadingState();
      try{
        // BasicResponse response = await api.updateProfileDetails(
        //        firstName,
        //       lastName: lastName,
        //       email: email,
        //       password: '',
        //       mobileNumber: number,
        //       dob: dob,
        //       imagebase64: imageBase64);
        // if(response.status == Constants.success){
        //  yield ProfileUpadteLoadingSuccessState(response);
        // }else{
        //  yield ProfileLoadingFailedState(response);
        // }
      }catch(e){
       yield ProfileNotLoadedState(message: e.toString());
      }
    }
  }
}