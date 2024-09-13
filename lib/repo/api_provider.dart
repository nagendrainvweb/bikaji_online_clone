import 'dart:io';

import 'package:bikaji/model/AccountModal.dart';
import 'package:bikaji/model/AddressData.dart';
import 'package:bikaji/model/BasicResponse.dart';
import 'package:bikaji/model/CategoryData.dart';
import 'package:bikaji/model/DashboardData.dart';
import 'package:bikaji/model/NotificationData.dart';
import 'package:bikaji/model/OfferData.dart';
import 'package:bikaji/model/OfferResponse.dart';
import 'package:bikaji/model/OrderData.dart';
import 'package:bikaji/model/OrderDetailsData.dart';
import 'package:bikaji/model/PastOrderData.dart';
import 'package:bikaji/model/PincodeResponse.dart';
import 'package:bikaji/model/ProductData.dart';
import 'package:bikaji/model/ProductListResponse.dart';
import 'package:bikaji/model/ReviewListResponse.dart';
import 'package:bikaji/model/SearchData.dart';
import 'package:bikaji/model/StateData.dart';
import 'package:bikaji/model/UserData.dart';
import 'package:bikaji/model/product.dart';
import 'package:bikaji/model/updateCartResponse.dart';
import 'package:bikaji/model/wishlist_response.dart';
import 'package:bikaji/prefrence_util/Prefs.dart';
import 'package:bikaji/util/api_exception.dart';
import 'package:bikaji/util/constants.dart';
import 'package:bikaji/util/url_list.dart';
import 'package:bikaji/util/utility.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:http/io_client.dart';
import 'package:intl/intl.dart';

class ApiProvider {
  Future<BasicResponse<String>> sendOtp(mobile, otp) async {
    final device = (Platform.isAndroid) ? Constants.ANDROID : Constants.IOS;
    final appversion = Constants.appversion;
    final time = Utility.getTimeStamp();
    final checksum = "${time}sendOtpMD5${mobile}${otp}";
    final headers = {Constants.CHECKSUM: checksum};
    final postJson = {
    };
    try {
      final request =
          await http.post(Uri.parse(UrlList.SEND_OTP), body: postJson, headers: headers);
      final jsonResponse = json.decode(request.body);
      myPrint("otp response : ${request.body.toString()}");
      return BasicResponse.fromJson(json: jsonResponse, data: "");
    } on SocketException catch (e) {
      throw ApiException(NO_INTERNET_CONN);
    } on Exception catch (e) {
      sendMail(UrlList.SEND_OTP, SOMETHING_WRONG_TEXT);
      throw ApiException(SOMETHING_WRONG_TEXT);
    }
  }

  Future<BasicResponse<String>> fetchUpdate() async {
    final device = (Platform.isAndroid) ? Constants.ANDROID : Constants.IOS;
    final appversion = Constants.appversion;
    final postJson = {"appVersion": '$appversion', "device": '$device'};
    try {
      final request = await http.post(Uri.parse(UrlList.CHECK_UPDATE), body: postJson);
      myPrint(request.toString());
      final jsonResponse = json.decode(request.body);
      return BasicResponse.fromJson(json: jsonResponse, data: "");
    } on SocketException catch (e) {
      throw ApiException(NO_INTERNET_CONN);
    } on Exception catch (e) {
      sendMail(UrlList.CHECK_UPDATE, SOMETHING_WRONG_TEXT);
      throw ApiException(e.toString());
    }
  }

  /*  Fetch Token api */
  Future<BasicResponse<String>> fetchToken(String number) async {
    final device = (Platform.isAndroid) ? Constants.ANDROID : Constants.IOS;
    final appversion = Constants.appversion;
    Map<String, String> headers = {"Content-type": "application/json"};
    final postJson =
        '{"mobileNumber": $number, "appVersion": $appversion, "device": $device}';
    try {
      final request = await http.post(Uri.parse("url"), headers: headers, body: postJson);
      if (request.statusCode == 200) {
        final jsonResponse = json.decode(request.body);
        return BasicResponse.fromJson(json: jsonResponse, data: "");
      }
    } on SocketException catch (e) {
      throw ApiException(NO_INTERNET_CONN);
    } on Exception catch (e) {
      sendMail(UrlList.CHECK_UPDATE, SOMETHING_WRONG_TEXT);
      throw ApiException(e.toString());
    }
  }

  /*  Login Page api */
  Future<BasicResponse<User>> fetchUserlogin(String number) async {
    final device = (Platform.isAndroid) ? Constants.ANDROID : Constants.IOS;
    final appversion = Constants.appversion;
    final fcm_token = await Prefs.fcmToken;
    final time = Utility.getTimeStamp();
    final checksum = "${time}loginMD5${number}";
    final headers = {Constants.CHECKSUM: checksum};
    final postJson = {
    };
    myPrint(postJson.toString());
    try {
      final request =
          await http.post(Uri.parse(UrlList.USER_LOGIN), body: postJson, headers: headers);
      myPrint(request.body.toString());
      if (request.statusCode == 200) {
        final jsonResponse = json.decode(request.body);
        var data = jsonResponse['data'];
        if (data != null) {
          data = User.fromJson(data);
        }

        return BasicResponse.fromJson(json: jsonResponse, data: data);
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<BasicResponse<String>> registerToken() async {
    final device = (Platform.isAndroid) ? Constants.ANDROID : Constants.IOS;
    final user_id = await Prefs.id;
    final appversion = Constants.appversion;
    final fcm_token = await Prefs.fcmToken;
    final time = Utility.getTimeStamp();
    final checksum = "${time}updateFcmTokenMD5${fcm_token}";
    final headers = {Constants.CHECKSUM: checksum};
    final postJson = {
    };
    myPrint(postJson.toString());
    try {
      final request = await http.post(Uri.parse(UrlList.REGISTER_TOKEN),
          body: postJson, headers: headers);
      myPrint(request.body.toString());
      final jsonResponse = json.decode(request.body);
      return BasicResponse.fromJson(json: jsonResponse, data: "");
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  /*  Register Page api */
  Future<BasicResponse<User>> registerUser(firstName, lastName, mobileNumber,
      dob, email, password, imagebase64) async {
    final device = (Platform.isAndroid) ? Constants.ANDROID : Constants.IOS;
    final appversion = Constants.appversion;
    final fcm_token = await Prefs.fcmToken;
    final time = Utility.getTimeStamp();
    final checksum =
        "${time}registrationMD5${firstName}${lastName}${mobileNumber}${dob}${email}${password}${imagebase64}";
    final headers = {Constants.CHECKSUM: checksum};

    final postJson = {
    };
    myPrint(postJson.toString());
    myPrint(UrlList.USER_REGISTRATION);
    try {
      final request = await http.post(Uri.parse(UrlList.USER_REGISTRATION),
          body: postJson, headers: headers);
      myPrint(request.body);
      if (request.statusCode == 200) {
        final jsonResponse = json.decode(request.body);
        myPrint(jsonResponse.toString());
        if (jsonResponse[UrlConstants.STATUS] != UrlConstants.SUCCESS) {
          sendMail(UrlList.USER_REGISTRATION,
              " Parameter: ${postJson.toString()}</br>${jsonResponse[UrlConstants.MESSAGE]}");
        }
        var data = jsonResponse['data'];
        if (data != null) {
          data = User.fromJson(data);
        }
        return BasicResponse.fromJson(json: jsonResponse, data: data);
      }
    } catch (e) {
      return throw Exception(e.toString());
    }
  }

  Future<BasicResponse<OfferResponse>> fetchOffers() async {
    final userid = await Prefs.id;
    final token = await Prefs.token;
    final device = (Platform.isAndroid) ? Constants.ANDROID : Constants.IOS;
    final appversion = Constants.appversion;
    final time = Utility.getTimeStamp();
    final checksum = "${time}getOffersMD5${userid}";
    final headers = {Constants.AUTH: "$token", Constants.CHECKSUM: checksum};
    final postJson = {
    };
    try {
      final request = await http.post(Uri.parse(UrlList.FETCH_OFFERS),
          body: postJson, headers: headers);
      final response = json.decode(request.body);
      var data = response[UrlConstants.DATA];
      Prefs.setOfferResponse(request.body);
      if (data != null) {
        data = OfferResponse.fromJson(data);
        minimumOrderValue = data.minimumVal;
        maximumOrderValue = data.maximumVal;
      }
      return BasicResponse.fromJson(json: response, data: data);
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<BasicResponse<Offers>> verifyCoupons(
      String couponCode, String amount) async {
    final userid = await Prefs.id;
    final token = await Prefs.token;
    final device = (Platform.isAndroid) ? Constants.ANDROID : Constants.IOS;
    final appversion = Constants.appversion;
    final time = Utility.getTimeStamp();
    final checksum = Utility.generateMd5(
        "${time}verifyCouponMD5${userid}${couponCode}${amount}");
    Map<String, String> headers = {
      Constants.AUTH: "$token",
      Constants.CHECKSUM: "$checksum"
    };
    final postJson = {
    };
    myPrint(postJson.toString());
    try {
      final request = await http.post(Uri.parse(UrlList.VERIFY_COUPON_CODE),
          body: postJson, headers: headers);
      final response = json.decode(request.body);
      myPrint(request.body);
      var data = response[UrlConstants.DATA];
      if (data != null) {
        data = Offers.fromJson(data, isOffer: false);
      }
      return BasicResponse.fromJson(json: response, data: data);
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<BasicResponse<UpdateCartResponse>> updateCart(
      List<Product> cartList, String coupon_title, String total_amount) async {
    final userid = await Prefs.id;
    final token = await Prefs.token;
    final device = (Platform.isAndroid) ? Constants.ANDROID : Constants.IOS;
    final appversion = Constants.appversion;
    final time = Utility.getTimeStamp();
    final checksum = Utility.generateMd5("${time}updateCartMD5${userid}");
    Map<String, String> headers = {
      Constants.AUTH: "$token",
      "Content-Type": "application/json",
      Constants.CHECKSUM: "$checksum"
    };

    Map<String, dynamic> body = new Map<String, dynamic>();
    body['user_id'] = '$userid';
    body['coupon_code'] = '$coupon_title';
    body['total_amount'] = '$total_amount';
    body['app_version'] = '$appversion';
    body['device'] = '$device';
    body['time'] = '$time';
    List data = new List();
    for (var product in cartList) {
      data.add(product.toCartJson());
    }
    body['data'] = data;
    final postBody = json.encode(body);
    myPrint(json.encode(body.toString()));
    // calling api
    try {
      final request = await http.post(Uri.parse(UrlList.UPDATE_CART),
          body: postBody, headers: headers);
      myPrint(request.body.toString());
      final jsonRequest = json.decode(request.body);
      var data;
      if (jsonRequest[UrlConstants.STATUS] == UrlConstants.SUCCESS) {
        data = UpdateCartResponse.fromJson(jsonRequest[UrlConstants.DATA]);
      }
      return BasicResponse.fromJson(json: jsonRequest, data: data);
    } catch (e) {
      throw Exception(e);
    }
  }

  // Place order
  Future<BasicResponse<Map<String, dynamic>>> placeOrder(
      String billing_address_id,
      String shipping_address_id,
      String coupon_code,
      String offer_type,
      String discount_amount) async {
    final userid = await Prefs.id;
    final token = await Prefs.token;
    final device = (Platform.isAndroid) ? Constants.ANDROID : Constants.IOS;
    final appversion = Constants.appversion;
    final time = Utility.getTimeStamp();
    final checksum = Utility.generateMd5(
        "${time}placeOrderMD5${userid}${billing_address_id}${shipping_address_id}${coupon_code}${discount_amount}");
    Map<String, String> headers = {
      Constants.AUTH: "$token",
      Constants.CHECKSUM: "$checksum"
    };

    final postJson = {
    };
    myPrint(postJson.toString());
    myPrint(token.toString());
    try {
      final request = await http.post(Uri.parse(UrlList.PLACE_ORDER),
          body: postJson, headers: headers);
      myPrint(request.body);
      final response = json.decode(request.body);
      var data = response[UrlConstants.DATA];
      return BasicResponse.fromJson(json: response, data: data);
    } on SocketException catch (e) {
      throw ApiException(NO_INTERNET_CONN);
    } on Exception catch (e) {
      throw ApiException(e.toString());
    }
  }

  // Update Free Order status of order
  Future<BasicResponse<OrderDetailsData>> updatePaymentFree(
      String order_id, String payment_amount, String coupon_code) async {
    final userid = await Prefs.id;
    final token = await Prefs.token;
    final device = (Platform.isAndroid) ? Constants.ANDROID : Constants.IOS;
    final appversion = Constants.appversion;
    final time = Utility.getTimeStamp();
    final checksum = Utility.generateMd5(
        "${time}updatePaymentFreeMD5${userid}${order_id}${payment_amount}${coupon_code}");
    Map<String, String> headers = {
      Constants.AUTH: "$token",
      Constants.CHECKSUM: "$checksum"
    };
    final postJson = {
    };
    myPrint(postJson.toString());
    try {
      final request = await http.post(Uri.parse(UrlList.UPDATE_PAYMENT_FREE),
          body: postJson, headers: headers);
      myPrint(request.body.toString());
      final response = json.decode(request.body);

      var data = response[UrlConstants.DATA];
      if (data != null) {
        data = OrderDetailsData.fromJson(data);
      }
      return BasicResponse.fromJson(json: response, data: data);
    } catch (e) {
      throw Exception(e);
    }
  }

  // Update Payment status of order
  Future<BasicResponse<OrderDetailsData>> updatePayment(
      String order_id,
      String transaction_id,
      String paymentStatus,
      String payment_amount,
      String coupon_code) async {
    final userid = await Prefs.id;
    final token = await Prefs.token;
    final device = (Platform.isAndroid) ? Constants.ANDROID : Constants.IOS;
    final appversion = Constants.appversion;
    final time = Utility.getTimeStamp();
    final checksum = Utility.generateMd5(
        "${time}updatePaymentMD5${userid}${order_id}${transaction_id}${paymentStatus}${payment_amount}${coupon_code}");
    Map<String, String> headers = {
      Constants.AUTH: "$token",
      Constants.CHECKSUM: "$checksum"
    };
    myPrint(headers.toString());
    final postJson = {
    };
    myPrint(postJson.toString());
    try {
      final request = await http.post(Uri.parse(UrlList.UPDATE_PAYMENT),
          body: postJson, headers: headers);
      myPrint(request.body.toString());
      final response = json.decode(request.body);

      var data = response[UrlConstants.DATA];
      if (data != null) {
        data = OrderDetailsData.fromJson(data);
      }
      return BasicResponse.fromJson(json: response, data: data);
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<BasicResponse<List<NotificationData>>> fetchNotifications() async {
    final userid = await Prefs.id;
    final token = await Prefs.token;
    final device = (Platform.isAndroid) ? Constants.ANDROID : Constants.IOS;
    final appversion = Constants.appversion;
    final notificationDateTime = await Prefs.notificationDateTime;
    final dateTime = DateTime.fromMillisecondsSinceEpoch(notificationDateTime);
    final date = DateFormat('dd-MM-yyyy').format(dateTime);
    //final date = "21-06-2020";
    final time = Utility.getTimeStamp();
    final checksum = "${time}notificationMD5${userid}${date}";
    final headers = {Constants.AUTH: "$token", Constants.CHECKSUM: checksum};
    final postJson = {
    };
    myPrint(postJson.toString());
    try {
      final request = await http.post(Uri.parse(UrlList.FETCH_NOTIFICATIONS),
          body: postJson, headers: headers);

      final response = json.decode(request.body);
      //final response = json.decode(sampleData); // remove this line
      var data = response[UrlConstants.DATA];
      List<NotificationData> notificationList = List();
      int notificationCount = 0;
      if (data != null) {
        for (var e in data) {
          final data = NotificationData.fromJson(e);
          data.isRead = data.read_users.contains(userid);
          if (!data.isRead) {
            notificationCount++;
          }
          notificationList.add(data);
        }
      }
      Prefs.setNotificationCount(notificationCount);
      return BasicResponse.fromJson(json: response, data: notificationList);
    } catch (e) {
      myPrint("error in api provider");
      throw Exception(e);
    }
  }

  Future<BasicResponse<String>> deleteNotifications(
      String notificationIds) async {
    final userid = await Prefs.id;
    final token = await Prefs.token;
    final device = (Platform.isAndroid) ? Constants.ANDROID : Constants.IOS;
    final appversion = Constants.appversion;
    //final date = "21-06-2020";
    final time = Utility.getTimeStamp();
    final checksum = "${time}deleteNotificationsMD5${userid}${notificationIds}";
    final headers = {Constants.AUTH: "$token", Constants.CHECKSUM: checksum};
    final postJson = {
    };
    myPrint(postJson.toString());
    try {
      final request = await http.post(Uri.parse(UrlList.DELETE_NOTIFICATIONS),
          body: postJson, headers: headers);
      myPrint(request.body);
      final response = json.decode(request.body);
      // var data = response[UrlConstants.DATA];
      // List<NotificationData> notificationList = List();
      // if (data != null) {
      //   for(var e in data){
      //     notificationList.add(NotificationData.fromJson(e));
      //   }
      // }
      return BasicResponse.fromJson(json: response, data: "");
    } catch (e) {
      myPrint("error in api provider");
      throw Exception(e);
    }
  }

  Future<BasicResponse<String>> readNotifications(
      String notificationIds) async {
    final userid = await Prefs.id;
    final token = await Prefs.token;
    final device = (Platform.isAndroid) ? Constants.ANDROID : Constants.IOS;
    final appversion = Constants.appversion;
    //final date = "21-06-2020";
    final time = Utility.getTimeStamp();
    final checksum = "${time}readNotificationsMD5${userid}${notificationIds}";
    final headers = {Constants.AUTH: "$token", Constants.CHECKSUM: checksum};
    final postJson = {
    };
    myPrint(postJson.toString());
    try {
      final request = await http.post(Uri.parse(UrlList.READ_NOTIFICATIONS),
          body: postJson, headers: headers);
      final response = json.decode(request.body);
      // var data = response[UrlConstants.DATA];
      // List<NotificationData> notificationList = List();
      // if (data != null) {
      //   for(var e in data){
      //     notificationList.add(NotificationData.fromJson(e));
      //   }
      // }
      return BasicResponse.fromJson(json: response, data: "");
    } catch (e) {
      myPrint("error in api provider");
      throw Exception(e);
    }
  }

  Future<BasicResponse<List<StateData>>> fetchStateList() async {
    final userid = await Prefs.id;
    final token = await Prefs.token;
    final device = (Platform.isAndroid) ? Constants.ANDROID : Constants.IOS;
    final appversion = Constants.appversion;
    Map<String, String> headers = {Constants.AUTH: "$token"};
    final postJson = {
    };
    try {
      final request = await http.post(Uri.parse(UrlList.FETCH_STATE_LIST),
          body: postJson, headers: headers);
      final response = json.decode(request.body);

      List data = response[UrlConstants.DATA];
      // myPrint(data.toString());
      List<StateData> stateList = new List();
      if (data != null) {
        Prefs.setStateList(json.encode(data));
        for (var item in data) {
          stateList.add(StateData.fromJson(item));
        }
      }
      return BasicResponse.fromJson(json: response, data: stateList);
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<BasicResponse<String>> sendMail(String url, String error) async {
    //final userid = await Prefs.id;
    //final token = await Prefs.token;
    final device = (Platform.isAndroid) ? Constants.ANDROID : Constants.IOS;
    final appversion = Constants.appversion;
    final email = "nagendra@inventifweb.com";
    final mobile_no = await Prefs.mobileNumber;
    final subject = "Bikaji Error From $device";
    String message =
        "$url $error \n\n Mobile number : ${(mobile_no.isNotEmpty) ? mobile_no : ""}";
    //Map<String, String> headers = {Constants.AUTH: "$token"};
    final postJson = {
    };
    try {
      final request = await http.post(
        Uri.parse(UrlList.SEND_MAIL),
        body: postJson,
      );
      final response = json.decode(request.body);
      myPrint(response.toString());
      return BasicResponse.fromJson(json: response, data: "");
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<BasicResponse<List<Offers>>> fetchCoupons() async {
    final userid = await Prefs.id;
    final token = await Prefs.token;
    final device = (Platform.isAndroid) ? Constants.ANDROID : Constants.IOS;
    final appversion = Constants.appversion;
    final time = Utility.getTimeStamp();
    final checksum = "${time}getCouponMD5${userid}";
    final headers = {Constants.AUTH: "$token", Constants.CHECKSUM: checksum};
    final postJson = {
    };
    try {
      final request = await http.post(Uri.parse(UrlList.FETCH_COUPONS),
          body: postJson, headers: headers);
      final response = json.decode(request.body);
      var data = response[UrlConstants.DATA];
      List<Offers> offerList = new List();
      if (data != null) {
        // data = OfferResponse.fromJson(data);
        List list = data['offers'];
        offerList =
            list.map((e) => Offers.fromJson(e, isOffer: false)).toList();
      }
      return BasicResponse.fromJson(json: response, data: offerList);
    } catch (e) {
      throw Exception(e);
    }
  }

  /*  Dashboard Page api */
  Future<BasicResponse<DashboardData>> fetchDashboard() async {
    final token = await Prefs.token;
    final user_id = await Prefs.id;
    final device = (Platform.isAndroid) ? Constants.ANDROID : Constants.IOS;
    final appversion = Constants.appversion;
    final time = Utility.getTimeStamp();
    final checksum = "${time}getDashboardDataMD5${user_id}";
    final headers = {Constants.AUTH: "$token", Constants.CHECKSUM: checksum};
    final postJson = {
    };
    myPrint(headers.toString());
    myPrint(postJson.toString());
    try {
      final request = await http.post(Uri.parse(UrlList.FETCH_DASHBOARD),
          headers: headers, body: postJson);
      // final request = await http.post(UrlList.FETCH_DASHBOARD,
      //     headers: headers, body: postJson);
      myPrint(request.body);
      final jsonResponse = json.decode(request.body);
      // myPrint(jsonResponse.toString());
      var data = jsonResponse[UrlConstants.DATA];
      if (data != null) {
        Prefs.setDashboardData(json.encode(data));
        isRefreshed = true;
        data = DashboardData.fromJson(jsonResponse[UrlConstants.DATA]);
        Prefs.setCartCount(data.inCartcount);
        return BasicResponse.fromJson(json: jsonResponse, data: data);
      } else {
        throw Exception(jsonResponse["message"]);
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  /*  Wishlist Page api */
  Future<BasicResponse<String>> addToWishlist(
      String userid, String productId) async {
    final token = await Prefs.token;
    final device = (Platform.isAndroid) ? Constants.ANDROID : Constants.IOS;
    final appversion = Constants.appversion;
    final time = Utility.getTimeStamp();
    final checksum = "${time}addWishListMD5${userid}${productId}";
    final headers = {Constants.AUTH: "$token", Constants.CHECKSUM: checksum};
    final postJson = {
    };
    myPrint(postJson.toString());
    try {
      final request = await http.post(Uri.parse(UrlList.ADD_WISHLIST),
          headers: headers, body: postJson);
      if (request.statusCode == 200) {
        final jsonResponse = json.decode(request.body);
        return BasicResponse.fromJson(json: jsonResponse, data: "");
      } else {
        return throw Exception('status code : ${request.statusCode}');
      }
    } catch (e) {
      return throw Exception(e);
    }
  }

  Future<PincodeResponse> fetchPincode(String pincode) async {
    try {
      final request = await http.get(Uri.parse(UrlList.FETCH_PINCODE + pincode));
      final jsonResponse = json.decode(request.body);
      myPrint(jsonResponse.toString());
      if (jsonResponse.length > 0) {
        final pincodeResponse = PincodeResponse.fromJson(jsonResponse[0]);
        return pincodeResponse;
      } else {
        return null;
      }
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<BasicResponse<List<CategoryData>>> fetchSubCategoryList(
      String categoryId) async {
    final token = await Prefs.token;
    final userid = await Prefs.id;
    final device = (Platform.isAndroid) ? Constants.ANDROID : Constants.IOS;
    final appversion = Constants.appversion;
    final time = Utility.getTimeStamp();
    final checksum = "${time}subCategoryListMD5${userid}";
    final headers = {Constants.AUTH: "$token", Constants.CHECKSUM: checksum};
    final postJson = {
    };
    myPrint('postjson  $postJson');
    try {
      final request = await http.post(Uri.parse(UrlList.FETCH_SUB_CATEGORY),
          headers: headers, body: postJson);
      if (request.statusCode == 200) {
        final jsonResponse = json.decode(request.body);
        //myPrint(jsonResponse);
        List<CategoryData> categoryList = [];
        if (jsonResponse[UrlConstants.STATUS] == UrlConstants.SUCCESS) {
          List array = jsonResponse[UrlConstants.DATA];
          if (array != null) {
            // add category object in list using loop
            for (var i = 0; i < array.length; i++) {
              categoryList.add(CategoryData.fromJson(array[i]));
            }
          }
        }

        return BasicResponse.fromJson(json: jsonResponse, data: categoryList);
      }
    } catch (e) {
      throw Exception(e);
    }

    return throw Exception("Something went wrong");
  }

  Future<BasicResponse<String>> sendCorporateInquiry(String name, String email,
      String mobileNo, String company, String city) async {
    try {
      final userid = await Prefs.id;
      final token = await Prefs.token;
      final device = (Platform.isAndroid) ? Constants.ANDROID : Constants.IOS;
      final appversion = Constants.appversion;
      final time = Utility.getTimeStamp();
      final checksum =
          "${time}orderEnquiryMD5${name}${email}${mobileNo}${company}${city}";
      final headers = {Constants.AUTH: "$token", Constants.CHECKSUM: checksum};
      final postJson = {
      };
      final request = await http.post(Uri.parse(UrlList.CORPORATE_ORDER_ENQUIRY),
          body: postJson, headers: headers);
      final jsonResponse = json.decode(request.body);
      return BasicResponse.fromJson(json: jsonResponse, data: "");
    } catch (e) {
      throw Exception(e);
    }
  }

  /*  Category Page api */
  Future<BasicResponse<List<CategoryData>>> fetchCategoryList(
      String userid) async {
    final token = await Prefs.token;
    final device = (Platform.isAndroid) ? Constants.ANDROID : Constants.IOS;
    final appversion = Constants.appversion;
    final time = Utility.getTimeStamp();
    final checksum = "${time}getCategoryListMD5${userid}";
    final headers = {Constants.AUTH: "$token", Constants.CHECKSUM: checksum};
    final postJson = {
    };
    myPrint('postjson  $postJson');
    try {
      final request = await http.post(Uri.parse(UrlList.FETCH_CATEGORY),
          headers: headers, body: postJson);
      myPrint(request.body.toString());
      if (request.statusCode == 200) {
        final jsonResponse = json.decode(request.body);
        //myPrint(jsonResponse);
        List<CategoryData> categoryList = [];
        if (jsonResponse[UrlConstants.STATUS] == UrlConstants.SUCCESS) {
          List array = jsonResponse[UrlConstants.DATA];
          Prefs.setCategoryData(json.encode(array));

          if (array != null) {
            // add category object in list using loop
            for (var i = 0; i < array.length; i++) {
              categoryList.add(CategoryData.fromJson(array[i]));
            }
          }
        }

        return BasicResponse.fromJson(json: jsonResponse, data: categoryList);
      }
    } catch (e) {
      throw Exception(e);
    }

    return throw Exception("Something went wrong");
  }

  Future<BasicResponse<ProductData>> fetchProductDetails(var productId) async {
    final userid = await Prefs.id;
    final token = await Prefs.token;
    final device = (Platform.isAndroid) ? Constants.ANDROID : Constants.IOS;
    final appversion = Constants.appversion;
    final time = Utility.getTimeStamp();
    final checksum = "${time}getProductDetailMD5${userid}${productId}";
    final headers = {Constants.AUTH: "$token", Constants.CHECKSUM: checksum};
    final postJson = {
    };
    myPrint(postJson.toString());
    try {
      final request = await http.post(Uri.parse(UrlList.FETCH_PRODUCT_DETAILS),
          headers: headers, body: postJson);
      myPrint(request.body);
      if (request.statusCode == 200) {
        final jsonResponse = json.decode(request.body);

        var data = jsonResponse["data"];
        if (data != null) {
          data = ProductData.fromJson(jsonResponse["data"]);
        }
        return BasicResponse.fromJson(json: jsonResponse, data: data);
      } else {
        throw Exception('Request Code :${request.statusCode} found');
      }
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<BasicResponse<ReviewListResponse>> fetchReview(
      var productId, var pageNo) async {
    final userid = await Prefs.id;
    final token = await Prefs.token;
    final device = (Platform.isAndroid) ? Constants.ANDROID : Constants.IOS;
    final appversion = Constants.appversion;
    final time = Utility.getTimeStamp();
    final checksum = "${time}getReviewMD5${userid}${productId}";
    final headers = {Constants.AUTH: "$token", Constants.CHECKSUM: checksum};
    final postJson = {
    };
    myPrint(postJson.toString());
    try {
      final request = await http.post(Uri.parse(UrlList.FETCH_REVIEW),
          headers: headers, body: postJson);
      if (request.statusCode == 200) {
        final jsonResponse = json.decode(request.body);

        var data = jsonResponse["data"];
        if (data != null) {
          data = ReviewListResponse.fromJson(jsonResponse["data"]);
        }
        return BasicResponse.fromJson(json: jsonResponse, data: data);
      } else {
        throw Exception('Request Code :${request.statusCode} found');
      }
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<BasicResponse<String>> addReview(
      var productId, var rating, var reviewTitle, var review) async {
    final userid = await Prefs.id;
    final token = await Prefs.token;
    final firstName = await Prefs.firstName;
    final lastName = await Prefs.lastName;
    final device = (Platform.isAndroid) ? Constants.ANDROID : Constants.IOS;
    final appversion = Constants.appversion;
    final time = Utility.getTimeStamp();
    final checksum =
        "${time}addReviewMD5${userid}${productId}${rating}${reviewTitle}${review}";
    final headers = {Constants.AUTH: "$token", Constants.CHECKSUM: checksum};
    final postJson = {
    };
    myPrint(postJson.toString());

    try {
      final request =
          await http.post(Uri.parse(UrlList.ADD_REVIEW), headers: headers, body: postJson);
      if (request.statusCode == 200) {
        myPrint(request.body.toString());
        final jsonResponse = json.decode(request.body);
        return BasicResponse.fromJson(json: jsonResponse, data: '');
      } else {
        throw Exception('Request Code :${request.statusCode} found');
      }
    } catch (e) {
      throw Exception(e);
    }
  }

  /*  Wishlist Page api */
  Future<BasicResponse<WishListResponse>> fetchWishList(var pageNo) async {
    final userid = await Prefs.id;
    final token = await Prefs.token;
    final device = (Platform.isAndroid) ? Constants.ANDROID : Constants.IOS;
    final appversion = Constants.appversion;
    final time = Utility.getTimeStamp();
    final checksum = "${time}getWishListMD5${userid}";
    final headers = {Constants.AUTH: "$token", Constants.CHECKSUM: checksum};
    final postJson = {
    };

    try {
      final request = await http.post(Uri.parse(UrlList.FETCH_WISHLIST),
          headers: headers, body: postJson);
      if (request.statusCode == 200) {
        //myPrint(request.body.toString());
        final jsonResponse = json.decode(request.body);

        var data = jsonResponse["data"];
        if (data != null) {
          data = WishListResponse.fromJson(jsonResponse["data"]);
        }
        return BasicResponse.fromJson(json: jsonResponse, data: data);
      } else {
        throw Exception('Request Code :${request.statusCode} found');
      }
    } catch (e) {
      throw Exception(e);
    }
  }

  /*  Cart Page api */
  Future<BasicResponse<String>> addToCart(
      String productId, var qty, var sizeId) async {
    final token = await Prefs.token;
    final userid = await Prefs.id;
    final device = (Platform.isAndroid) ? Constants.ANDROID : Constants.IOS;
    final appversion = Constants.appversion;
    final time = Utility.getTimeStamp();
    final checksum = Utility.generateMd5(
        "${time}addToCartMD5${userid}${productId}${qty}${sizeId}");
    Map<String, String> headers = {
      Constants.AUTH: "$token",
      Constants.CHECKSUM: "$checksum"
    };
    final postJson = {
    };
    myPrint(headers.toString());
    myPrint(postJson.toString());
    myPrint("url is ${UrlList.ADD_TO_CART}");
    try {
      final request = await http.post(Uri.parse(UrlList.ADD_TO_CART),
          headers: headers, body: postJson);
      myPrint(request.body);
      if (request.statusCode == 200) {
        final jsonResponse = json.decode(request.body);
        Prefs.setCartCount(jsonResponse['cart_count']);
        return BasicResponse.fromJson(json: jsonResponse, data: "");
      } else {
        return throw Exception('status code : ${request.statusCode}');
      }
    } catch (e) {
      return throw Exception(e);
    }
  }

  /*  Search Page api */
  Future<BasicResponse<String>> removeFromWishlist(
      String userid, String productId) async {
    final token = await Prefs.token;
    final device = (Platform.isAndroid) ? Constants.ANDROID : Constants.IOS;
    final appversion = Constants.appversion;
    final time = Utility.getTimeStamp();
    final checksum = "${time}deleteWishListMD5${userid}${productId}";
    final headers = {Constants.AUTH: "$token", Constants.CHECKSUM: checksum};
    final postJson = {
    };
    myPrint(postJson.toString());
    try {
      final request = await http.post(Uri.parse(UrlList.DELETE_WISHLIST),
          headers: headers, body: postJson);
      if (request.statusCode == 200) {
        final jsonResponse = json.decode(request.body);
        return BasicResponse.fromJson(json: jsonResponse, data: "");
      } else {
        return throw Exception('status code : ${request.statusCode}');
      }
    } catch (e) {
      return throw Exception(e);
    }
  }

  /*  Product Page api */
  Future<BasicResponse<ProductListResponse>> fetchProductList(
      String userid, var pageNo, var categoryid) async {
    final token = await Prefs.token;
    final device = (Platform.isAndroid) ? Constants.ANDROID : Constants.IOS;
    final appversion = Constants.appversion;
    final time = Utility.getTimeStamp();
    final checksum = "${time}productListMD5${userid}${categoryid}";
    final headers = {Constants.AUTH: "$token", Constants.CHECKSUM: checksum};
    final postJson = {
    };
    myPrint(postJson.toString());
    try {
      final request = await http.post(Uri.parse(UrlList.FETCH_PRODUCTS),
          headers: headers, body: postJson);
      final jsonResponse = json.decode(request.body);
      //  myPrint(jsonResponse.toString());
      var data = jsonResponse[UrlConstants.DATA];
      if (data != null) {
        data = ProductListResponse.fromJson(jsonResponse["data"]);
      }
      return BasicResponse.fromJson(json: jsonResponse, data: data);
    } catch (e) {
      return throw Exception(e.toString());
    }
  }

  Future<BasicResponse<ProductListResponse>> fetchProductByType(
      String userid, var pageNo, var type) async {
    final token = await Prefs.token;
    final device = (Platform.isAndroid) ? Constants.ANDROID : Constants.IOS;
    final appversion = Constants.appversion;
    final time = Utility.getTimeStamp();
    final checksum = "${time}getDashboardDetailsMD5${userid}${type}";
    final headers = {Constants.AUTH: "$token", Constants.CHECKSUM: checksum};
    final postJson = {
    };
    myPrint(postJson.toString());
    try {
      final request = await http.post(Uri.parse(UrlList.FETCH_PRODUCTS_BY_TYPE),
          headers: headers, body: postJson);
      final jsonResponse = json.decode(request.body);
      //  myPrint(jsonResponse.toString());
      var data = jsonResponse[UrlConstants.DATA];
      if (data != null) {
        data = ProductListResponse.fromJson(jsonResponse["data"]);
      }
      return BasicResponse.fromJson(json: jsonResponse, data: data);
    } catch (e) {
      return throw Exception(e.toString());
    }
  }

  /*  Product Page api */
  Future<BasicResponse<ProductListResponse>> fetchFilteredProductList(
      String userid,
      var pageNo,
      var category_id,
      var type,
      var price1,
      var price2) async {
    final token = await Prefs.token;
    final device = (Platform.isAndroid) ? Constants.ANDROID : Constants.IOS;
    final appversion = Constants.appversion;
    final time = Utility.getTimeStamp();
    final checksum =
        "${time}filterProductListMD5${userid}${category_id}${type}${price1}${price2}";
    final headers = {Constants.AUTH: "$token", Constants.CHECKSUM: checksum};
    final postJson = {
    };
    myPrint(postJson.toString());
    try {
      final request = await http.post(Uri.parse(UrlList.FETCH_FILTER_LIST),
          headers: headers, body: postJson);
      final jsonResponse = json.decode(request.body);
      var data = jsonResponse[UrlConstants.DATA];
      if (data != null) {
        data = ProductListResponse.fromJson(jsonResponse["data"]);
      }
      return BasicResponse.fromJson(json: jsonResponse, data: data);
    } catch (e) {
      return throw Exception(e);
    }
  }

  /*  Profile Page api */
  Future<BasicResponse<User>> fetchProfileDetails(String userid) async {
    final token = await Prefs.token;
    final device = (Platform.isAndroid) ? Constants.ANDROID : Constants.IOS;
    final appversion = Constants.appversion;
    final time = Utility.getTimeStamp();
    final checksum = "${time}profileDetailsMD5${userid}";
    final headers = {Constants.AUTH: "$token", Constants.CHECKSUM: checksum};
    final postJson = {
    };
    myPrint(postJson.toString());
    final request = await http.post(Uri.parse(UrlList.FETCH_USER_DETAILS),
        headers: headers, body: postJson);
    myPrint(request.body);
    if (request.statusCode == 200) {
      final jsonResponse = json.decode(request.body);
      var data = jsonResponse["data"];
      if (data != null) {
        data = User.fromJson(data);
        Prefs.setId(data.id);
        Prefs.setFirstName(data.firstName);
        Prefs.setLastName(data.lastName);
        Prefs.setEmail(data.emailId);
        Prefs.setMobileNumber(data.mobileNumber);
        Prefs.setDob(data.dob);
        Prefs.setImageUrl(data.profile_pic);
      }
      return BasicResponse.fromJson(json: jsonResponse, data: data);
    }
    return throw Exception();
  }

  /*  Profile Page api */
  Future<BasicResponse<String>> updateProfileDetails(firstName, lastName,
      mobileNumber, dob, email, password, imagebase64) async {
    final device = (Platform.isAndroid) ? Constants.ANDROID : Constants.IOS;
    final appversion = Constants.appversion;
    final user_id = await Prefs.id;
    final token = await Prefs.token;
    final time = Utility.getTimeStamp();
    final checksum =
        "${time}updateProfileDetailsMD5${user_id}${firstName}${lastName}${mobileNumber}${dob}${email}${password}${imagebase64}";
    final headers = {Constants.AUTH: "$token", Constants.CHECKSUM: checksum};

    final postJson = {
    };
    myPrint(postJson.toString());
    try {
      final request = await http.post(Uri.parse(UrlList.UPDATE_USER_DETAILS),
          body: postJson, headers: headers);
      if (request.statusCode == 200) {
        final jsonResponse = json.decode(request.body);
        myPrint(jsonResponse.toString());

        return BasicResponse.fromJson(json: jsonResponse, data: "");
      } else {
        return throw Exception('status code: ${request.statusCode}');
      }
    } catch (e) {
      return throw Exception(e.toString());
    }
  }

  /*  Address Page api */
  Future<BasicResponse<List<AddressData>>> fetchAddress(String userid) async {
    final token = await Prefs.token;
    final device = (Platform.isAndroid) ? Constants.ANDROID : Constants.IOS;
    final appversion = Constants.appversion;
    final time = Utility.getTimeStamp();
    final checksum = "${time}addressesMD5${userid}";
    final headers = {Constants.AUTH: "$token", Constants.CHECKSUM: checksum};
    final postJson = {
    };
    try {
      final request = await http.post(Uri.parse(UrlList.FETCH_ADDRESSES),
          headers: headers, body: postJson);
      if (request.statusCode == 200) {
        final jsonResponse = json.decode(request.body);
        var data = jsonResponse["data"];
        var items = List<AddressData>();
        if (data != null) {
          Prefs.setAddressResponse(json.encode(data));
          data.forEach((v) {
            final data = new AddressData.fromJson(v);
            if (data.state != null && data.pincode != null) {
              items.add(new AddressData.fromJson(v));
            }
          });
        }
        return BasicResponse.fromJson(json: jsonResponse, data: items);
      } else {
        return throw Exception("STATUS CODE : ${request.statusCode}");
      }
    } catch (e) {
      return throw Exception(e);
    }
  }

  /*  Address Page api */
  Future<BasicResponse<String>> deleteAddress(var addressId) async {
    final userid = await Prefs.id;
    final token = await Prefs.token;
    final device = (Platform.isAndroid) ? Constants.ANDROID : Constants.IOS;
    final appversion = Constants.appversion;
    final time = Utility.getTimeStamp();
    final checksum = "${time}deleteAddressesMD5${userid}${addressId}";
    final headers = {Constants.AUTH: "$token", Constants.CHECKSUM: checksum};
    final postJson = {
    };
    myPrint(postJson.toString());
    try {
      final request = await http.post(Uri.parse(UrlList.DELETE_ADDRESS),
          headers: headers, body: postJson);
      myPrint(request.body.toString());
      if (request.statusCode == 200) {
        final jsonResponse = json.decode(request.body);
        return BasicResponse.fromJson(json: jsonResponse, data: "");
      } else {
        throw Exception("STATUS CODE: ${request.statusCode}");
      }
    } catch (e) {
      myPrint(e.toString());
      throw Exception(e);
    }
  }

  /*  Address Page api */
  Future<BasicResponse<String>> addUpdateAddress(
      AddressData addressData) async {
    final userid = await Prefs.id;
    final token = await Prefs.token;
    final device = (Platform.isAndroid) ? Constants.ANDROID : Constants.IOS;
    final appversion = Constants.appversion;
    final time = Utility.getTimeStamp();
    final checksum =
        "${time}addEditAddressesMD5${userid}${addressData.addressId}";
    final headers = {Constants.AUTH: "$token", Constants.CHECKSUM: checksum};
    var postJson = addressData.toJson();
    postJson['user_id'] = '$userid';
    postJson['appVersion'] = '$appversion';
    postJson['device'] = '$device';
    postJson[Constants.TIME] = "$time";
    myPrint(postJson.toString());
    // final postJson =
    //     {"user_id": $userid,"address_id":$address_id,"name":$name,"isDetault":$isDetault,"type":$type,"number":$number,"email_id":$email_id,"flat_no":$flat_no,"street_name":$street_name,"area":$area,"landmark":$landmark,"city":$city,"state":$state,"pincode":$pincode,"appVersion": $appversion, "device": $device};
    try {
      final request = await http.post(Uri.parse(UrlList.ADD_EDIT_ADDRESS),
          headers: headers, body: postJson);
      myPrint(request.body.toString());
      if (request.statusCode == 200) {
        final jsonResponse = json.decode(request.body);
        return BasicResponse.fromJson(json: jsonResponse, data: "");
      } else {
        return throw Exception('STATUS CODE : ${request.statusCode}');
      }
    } catch (e) {
      myPrint(e.toString());
      return throw Exception(e);
    }
  }

  /*  Search Page api */
  Future<BasicResponse<List<SearchData>>> fetchSearchData(
      var searchText) async {
    final token = await Prefs.token;
    final userid = await Prefs.id;
    final device = (Platform.isAndroid) ? Constants.ANDROID : Constants.IOS;
    final appversion = Constants.appversion;
    final time = Utility.getTimeStamp();
    final checksum =
        "${time}getSearchData${userid}${searchText}";
    final headers = {Constants.AUTH: "$token", Constants.CHECKSUM: checksum};
    final postJson = {
    };
    final request = await http.post(Uri.parse(UrlList.FETCH_SEARCH_DATA),
        headers: headers, body: postJson);
    if (request.statusCode == 200) {
      final jsonResponse = json.decode(request.body);
      List array = jsonResponse["data"];
      List<SearchData> productList = [];
      if (array != null) {
        for (var i = 0; i < array.length; i++) {
          productList.add(SearchData.fromJson(array[i]));
        }
      }
      return BasicResponse.fromJson(json: jsonResponse, data: productList);
    }
    return throw Exception();
  }

  Future<BasicResponse<OrderDetailsData>> fetchOrderDetails(var orderId) async {
    final token = await Prefs.token;
    final userid = await Prefs.id;
    final device = (Platform.isAndroid) ? Constants.ANDROID : Constants.IOS;
    final appversion = Constants.appversion;
    final time = Utility.getTimeStamp();
    final checksum =
        "${time}orderDetails${userid}${orderId}";
    final headers = {Constants.AUTH: "$token", Constants.CHECKSUM: checksum};
    final postJson = {
    };
    myPrint(postJson.toString());
    try {
      final request = await http.post(Uri.parse(UrlList.FETCH_ORDER_DETAILS),
          headers: headers, body: postJson);
      myPrint(request.body);
      if (request.statusCode == 200) {
        final jsonResponse = json.decode(request.body);
        var data = jsonResponse["data"];

        if (data != null) {
          data = OrderDetailsData.fromJson(data);
        }
        return BasicResponse.fromJson(json: jsonResponse, data: data);
      } else {
        return throw Exception("Status code : ${request.statusCode}");
      }
    } catch (e) {
      return throw Exception(e);
    }
  }

  Future<BasicResponse<List<PastOrderData>>> fetchPastOrders() async {
    final token = await Prefs.token;
    final userid = await Prefs.id;
    final device = (Platform.isAndroid) ? Constants.ANDROID : Constants.IOS;
    final appversion = Constants.appversion;
    final time = Utility.getTimeStamp();
    final checksum =
        "${time}pastOrder${userid}";
    final headers = {Constants.AUTH: "$token", Constants.CHECKSUM: checksum};
    final postJson = {
    };
    myPrint(postJson.toString());
    try {
      final request = await http.post(Uri.parse(UrlList.FETCH_PAST_ORDERS),
          headers: headers, body: postJson);
      if (request.statusCode == 200) {
        final jsonResponse = json.decode(request.body);
        List array = jsonResponse["data"];
        List<PastOrderData> orderList = [];
        if (array != null) {
          for (var i = 0; i < array.length; i++) {
            orderList.add(PastOrderData.fromJson(array[i]));
          }
        }
        return BasicResponse.fromJson(json: jsonResponse, data: orderList);
      } else {
        return throw Exception("Status code : ${request.statusCode}");
      }
    } catch (e) {
      return throw Exception(e);
    }
  }

  /*  Cart page api */
  Future<BasicResponse<List<Product>>> fetchCartDetails() async {
    final token = await Prefs.token;
    final userId = await Prefs.id;
    final device = (Platform.isAndroid) ? Constants.ANDROID : Constants.IOS;
    final appversion = Constants.appversion;
    final time = Utility.getTimeStamp();
    final checksum = Utility.generateMd5("${time}getCartDataMD5${userId}");
    Map<String, String> headers = {
    };
    final postJson = {

    };
    myPrint(headers.toString());
    try {
      final request = await http.post(Uri.parse(UrlList.FETCH_CART_DATA),
          headers: headers, body: postJson);
      myPrint(request.body);
      if (request.statusCode == 200) {
        final jsonResponse = json.decode(request.body);
        final data = jsonResponse[UrlConstants.DATA];
        List<Product> productlist = [];
        if (data != null) {
          List itemsArray = data['product'];
          for (var i = 0; i < itemsArray.length; i++) {
            productlist.add(Product.fromJson(itemsArray[i]));
          }
        }
        return BasicResponse.fromJson(json: jsonResponse, data: productlist);
      } else {
        throw Exception("STATUS CODE: ${request.statusCode}");
      }
    } catch (e) {
      myPrint(e.toString());
      throw Exception(e);
    }
  }

  /*  Cart page api */
  Future<BasicResponse<String>> removeFromCart(
      var productId, var sizeId) async {
    final token = await Prefs.token;
    final userid = await Prefs.id;
    final device = (Platform.isAndroid) ? Constants.ANDROID : Constants.IOS;
    final appversion = Constants.appversion;
    final time = Utility.getTimeStamp();
    final checksum =
        "${time}removeFromCartMD5${userid}${productId}${sizeId}";
    final headers = {Constants.AUTH: "$token", Constants.CHECKSUM: checksum};
    final postJson = {
    };
    myPrint(postJson.toString());
    final request = await http.post(Uri.parse(UrlList.REMOVE_FROM_CART),
        headers: headers, body: postJson);
    try {
      final jsonResponse = json.decode(request.body);
      myPrint(request.body.toString());
      Prefs.setCartCount(jsonResponse['cart_count']);
      return BasicResponse.fromJson(json: jsonResponse, data: "");
    } catch (e) {
      return throw Exception(e);
    }
  }

  Future<BasicResponse<String>> moveFromCartToWishlist(
      var productId, var sizeId) async {
    final token = await Prefs.token;
    final userid = await Prefs.id;
    final device = (Platform.isAndroid) ? Constants.ANDROID : Constants.IOS;
    final appversion = Constants.appversion;
    final time = Utility.getTimeStamp();
    final checksum =
        "${time}moveCartToWishlist${userid}${productId}${sizeId}";
    final headers = {Constants.AUTH: "$token", Constants.CHECKSUM: checksum};
    final postJson = {
    };
    final request = await http.post(Uri.parse(UrlList.MOVE_FROM_CART_TO_WISHLIST),
        headers: headers, body: postJson);
    try {
      final jsonResponse = json.decode(request.body);
      return BasicResponse.fromJson(json: jsonResponse, data: "");
    } catch (e) {
      return throw Exception(e);
    }
  }

  Future<BasicResponse<String>> fetchPolicies(var name) async {
    final token = await Prefs.token;
    final userid = await Prefs.id;
    final device = (Platform.isAndroid) ? Constants.ANDROID : Constants.IOS;
    final appversion = Constants.appversion;
    Map<String, String> headers = {Constants.AUTH: "$token"};
    final postJson = {
    };
    final request = await http.post(Uri.parse(UrlList.FETCH_POLICIES),
        headers: headers, body: postJson);
    try {
      final jsonResponse = json.decode(request.body);
      return BasicResponse.fromJson(json: jsonResponse, data: "");
    } catch (e) {
      return throw Exception(e);
    }
  }

  Future<BasicResponse<String>> sendQuery(name, email, number, desc) async {
    final token = await Prefs.token;
    final userid = await Prefs.id;
    final device = (Platform.isAndroid) ? Constants.ANDROID : Constants.IOS;
    final appversion = Constants.appversion;
    Map<String, String> headers = {Constants.AUTH: "$token"};
    final postJson = {
    };
    myPrint(postJson.toString());
    final request = await http.post(Uri.parse(UrlList.SEND_ABOUT_US_QUERY),
        headers: headers, body: postJson);
    myPrint(request.body);
    try {
      final jsonResponse = json.decode(request.body);
      return BasicResponse.fromJson(json: jsonResponse, data: "");
    } catch (e) {
      return throw Exception(e);
    }
  }
}
