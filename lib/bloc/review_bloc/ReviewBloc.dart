import 'package:bikaji/bloc/review_bloc/ReviewEvent.dart';
import 'package:bikaji/bloc/review_bloc/ReviewState.dart';
import 'package:bikaji/model/BasicResponse.dart';
import 'package:bikaji/repo/Repository.dart';
import 'package:bikaji/repo/api_provider.dart';
import 'package:bikaji/util/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:bloc/bloc.dart';

class ReviewBloc extends Bloc<ReviewEvent,ReviewState>{


  ReviewBloc(ReviewState initialState) : super(initialState);

  @override
  ReviewState get initialState => ReviewLoadingState();

  @override
  Stream<ReviewState> mapEventToState(ReviewEvent event)async* {
  }

}