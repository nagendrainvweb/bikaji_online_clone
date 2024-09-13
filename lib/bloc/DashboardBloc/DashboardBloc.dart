import 'dart:convert';

import 'package:bikaji/model/BasicResponse.dart';
import 'package:bikaji/model/DashboardData.dart';
import 'package:bikaji/prefrence_util/Prefs.dart';
import 'package:bikaji/repo/Repository.dart';
import 'package:bikaji/repo/api_provider.dart';
import 'package:bikaji/util/constants.dart';
import 'package:bikaji/util/utility.dart';
import 'package:flutter/cupertino.dart';
import 'package:bloc/bloc.dart';

import 'DashboardEvent.dart';
import 'DashboardState.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  
  DashboardBloc() : super(DashboardLoadingState());

  @override
  Stream<DashboardState> mapEventToState(DashboardEvent event) async* {
    if (event is FetchDashboardEvent) {
      print('inside FetchDashboardEvent');
      yield DashboardLoadingState();
      final id = await Prefs.id;
      final isLogin = await Prefs.isLogin;
      if (isLogin) {
        ApiProvider().fetchProfileDetails(id);
      }
      ApiProvider().fetchOffers();
      //repository.fetchAddress(id);
      try {
        final response = await Prefs.dashboardData;
        if (response.isNotEmpty && isRefreshed) {
          final data = json.decode(response);
          final dashboardData = DashboardData.fromJson(data);
          //final cartCount  = await Prefs.cartCount;
          yield DashboardSuccessState(dashboardData);
        } else {
          BasicResponse response = await ApiProvider().fetchDashboard();
          if (response.status == Constants.success)
            yield DashboardSuccessState(response.data);
          else
            yield DashboardFailedState(response);
        }
      } catch (e) {
        yield DashboardNotLoadedState(message: e.toString());
      }
    } else if (event is RefreshDashboardEvent) {
      try {
        BasicResponse response = await ApiProvider().fetchDashboard();
        final id = await Prefs.id;
        final isLogin = await Prefs.isLogin;
        if (isLogin) {
          ApiProvider().fetchProfileDetails(id);
        }
        ApiProvider().fetchOffers();
        if (response.status == Constants.success)
          yield DashboardSuccessState(response.data);
        else
          yield DashboardFailedState(response);
      } catch (e) {
        yield DashboardNotLoadedState(message: e.toString());
      }
    }
  }
}
