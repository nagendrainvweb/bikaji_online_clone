import 'package:bikaji/model/BasicResponse.dart';
import 'package:bikaji/prefrence_util/Prefs.dart';
import 'package:bikaji/repo/Repository.dart';
import 'package:bikaji/repo/api_provider.dart';
import 'package:bikaji/util/constants.dart';
import 'package:bikaji/util/utility.dart';
import 'package:flutter/cupertino.dart';
import 'package:bloc/bloc.dart';

import 'AddressEvent.dart';
import 'AddressState.dart';

class AddressBloc extends Bloc<AddressEvent,AddressState>{

  AddressBloc(AddressState initialState) : super(initialState);

  @override
  AddressState get initialState => AddressLoadingState();

  @override
  Stream<AddressState> mapEventToState(AddressEvent event)async* {
    if(event is FetchAddressEvent){
      myPrint('inside FetchAddressEvent');
     //yield  AddressLoadingState();
      try{
        final response =
          await ApiProvider().fetchAddress(event.userId);
        if(response.status == Constants.success){
         yield  AddressLoadingSuccessState(data: response.data);
        }else{
         yield  AddressLoadingFailedState(response);
        }
      }catch(e){
        myPrint(e.toString());
        yield AddressNotLoadedState(message: e.toString());
      }
    }else if(event is AddEditAddressEvent){
       yield  AddressLoadingState();
      // try{
      //  // BasicResponse response = await repository.addUpdateAddress(event.user_id,event.address_id,event.name,event.isDefault,event.type,event.number,event.email_id,event.flat_no,event.street_name,event.area,event.landmark,event.city,event.state,event.pincode);
      //   if(response.status == Constants.success){
      //     yield AddressAddEditSuccessState(response);
      //   }else{
      //    yield  AddressLoadingFailedState(response);
      //   }
      // }catch(e){
      //   yield AddressNotLoadedState(message: e.toString());
      // }
    }
  }

}