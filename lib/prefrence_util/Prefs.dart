import 'package:bikaji/prefrence_util/PreferencesHelper.dart';
import 'package:bikaji/util/constants.dart';

class Prefs {
  static Future setLogin(bool value) =>
      PreferencesHelper.setBool(Constants.isLogin, value);

  static Future<bool> get isLogin =>
      PreferencesHelper.getBool(Constants.isLogin);

  static Future setOTPVerified(bool value) =>
      PreferencesHelper.setBool(Constants.isOtpVerirified, value);

  static Future<bool> get isOTPVerified =>
      PreferencesHelper.getBool(Constants.isOtpVerirified);

  static Future setId(String value) =>
      PreferencesHelper.setString(Constants.id, value);

  static Future<String> get id => PreferencesHelper.getString(Constants.id);

  static Future setFirstName(String value) =>
      PreferencesHelper.setString(Constants.firstName, value);

  static Future<String> get firstName =>
      PreferencesHelper.getString(Constants.firstName);

  static Future setToken(String value) =>
      PreferencesHelper.setString(Constants.TOKEN, value);

  static Future<String> get token =>
      PreferencesHelper.getString(Constants.TOKEN);

  static Future setLastName(String value) =>
      PreferencesHelper.setString(Constants.lastName, value);

  static Future<String> get lastName =>
      PreferencesHelper.getString(Constants.lastName);

  static Future setEmail(String value) =>
      PreferencesHelper.setString(Constants.email, value);

  static Future<String> get email =>
      PreferencesHelper.getString(Constants.email);
  static Future setImageUrl(String value) =>
      PreferencesHelper.setString(Constants.imageUrl, value);

  static Future<String> get imageUrl =>
      PreferencesHelper.getString(Constants.imageUrl);
  static Future setMobileNumber(String value) =>
      PreferencesHelper.setString(Constants.mobile_no, value);

  static Future<String> get mobileNumber =>
      PreferencesHelper.getString(Constants.mobile_no);

  static Future setDob(String value) =>
      PreferencesHelper.setString(Constants.dob, value);

  static Future<String> get dob => PreferencesHelper.getString(Constants.dob);

  static Future setCity(String value) =>
      PreferencesHelper.setString(Constants.city, value);

  static Future<String> get city => PreferencesHelper.getString(Constants.city);

  static Future setState(String value) =>
      PreferencesHelper.setString(Constants.state, value);

  static Future<String> get state =>
      PreferencesHelper.getString(Constants.state);

  static Future setFCMToken(String value) =>
      PreferencesHelper.setString(Constants.fcmToken, value);

  static Future<String> get fcmToken =>
      PreferencesHelper.getString(Constants.fcmToken);

  static Future setCartCount(int value) =>
      PreferencesHelper.setInt(Constants.cartCount, value);

  static Future<int> get cartCount =>
      PreferencesHelper.getInt(Constants.cartCount);

  // prefs functions for local responses

  static Future setDashboardData(String value) =>
      PreferencesHelper.setString(Constants.dashboardData, value);

  static Future<String> get dashboardData =>
      PreferencesHelper.getString(Constants.dashboardData);

  static Future setCategoryData(String value) =>
      PreferencesHelper.setString(Constants.categoryData, value);

  static Future<String> get categoryData =>
      PreferencesHelper.getString(Constants.categoryData);

  static Future setCartData(String value) =>
      PreferencesHelper.setString(Constants.cartData, value);

  static Future<String> get cartData =>
      PreferencesHelper.getString(Constants.cartData);

  static Future setWishlistData(String value) =>
      PreferencesHelper.setString(Constants.wishlistData, value);

  static Future<String> get wishlistData =>
      PreferencesHelper.getString(Constants.wishlistData);

  static Future setAddressResponse(String value) =>
      PreferencesHelper.setString(Constants.addressResponse, value);

  static Future<String> get addressResponse =>
      PreferencesHelper.getString(Constants.addressResponse);

  static Future setOfferResponse(String value) =>
      PreferencesHelper.setString(Constants.offerResponse, value);

  static Future<String> get offerResponse =>
      PreferencesHelper.getString(Constants.offerResponse);

    static Future setStateList(String value) =>
      PreferencesHelper.setString(Constants.stateList, value);

  static Future<String> get stateList =>
      PreferencesHelper.getString(Constants.stateList);

  static Future setNotificationDateTime(int value) =>
      PreferencesHelper.setInt(Constants.NOTIFICATION_DATE, value);

  static Future<int> get notificationDateTime =>
      PreferencesHelper.getInt(Constants.NOTIFICATION_DATE);

  static Future setNotificationCount(int value) =>
      PreferencesHelper.setInt(Constants.NOTIFICATION_COUNT, value);

  static Future<int> get notificationCount =>
      PreferencesHelper.getInt(Constants.NOTIFICATION_COUNT);

  static Future<void>   clear() async {
    await Future.wait(<Future>[
      setLogin(false),
      setId(''),
      setFirstName(''),
      setLastName(''),
      setEmail(''),
      setMobileNumber(''),
      setDob(''),
      setImageUrl(''),
      setCity(''),
      setState(''),
      setAddressResponse(''),
      setCartCount(0),
      setNotificationCount(0),
      setNotificationDateTime(0)
    ]);
  }
}
