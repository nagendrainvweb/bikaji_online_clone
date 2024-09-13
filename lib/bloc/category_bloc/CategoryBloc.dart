import 'package:bikaji/bloc/category_bloc/CategoryState.dart';
import 'package:bikaji/model/BasicResponse.dart';
import 'package:bikaji/repo/Repository.dart';
import 'package:bikaji/repo/api_provider.dart';
import 'package:bikaji/util/constants.dart';
import 'package:bloc/bloc.dart';

import 'CategoryEvent.dart';

class CategoryBloc extends Bloc<CategoryEvent,CategoryState>{
  CategoryBloc(CategoryState initialState) : super(initialState);


  @override
  // TODO: implement initialState
  CategoryState get initialState => CategoryLoading();

  @override
  Stream<CategoryState> mapEventToState(CategoryEvent event) async* {
    if(event is FetchCategory){
      yield CategoryLoading();
      try{
         BasicResponse response = await ApiProvider().fetchCategoryList(event.userId);
         if(response.status == Constants.success){
          yield CategorySuccess(response.data);
         }else{
          yield CategoryFailed(response);
         }
      }catch(e){
        yield CategoryNotLoaded(message: e.toString());
      }
    }
  }

}