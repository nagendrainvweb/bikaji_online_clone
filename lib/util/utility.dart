import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:bikaji/model/AddressData.dart';
import 'package:bikaji/model/OfferData.dart';
import 'package:bikaji/model/product.dart';
import 'package:bikaji/pages/dashboard_page.dart';
import 'package:bikaji/pages/login_page.dart';
import 'package:bikaji/pages/my_account.dart';
import 'package:bikaji/pages/otp_page.dart';
import 'package:bikaji/pages/wishList_page.dart';
import 'package:bikaji/prefrence_util/Prefs.dart';
import 'package:bikaji/repo/Repository.dart';
import 'package:bikaji/repo/api_provider.dart';
import 'package:bikaji/util/dialog_helper.dart';
import 'package:bikaji/util/url_list.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/io_client.dart';
import 'package:convert/convert.dart';
import 'package:crypto/crypto.dart' as crypto;

int wishListCount = 0;
int notificationCount = 0;
int minimumOrderValue = 0;
int maximumOrderValue = 0;

final Color cyanDarkColor = Color(0xff3daa8d);
final Color cyankColor = Color(0xff51d5b0);
final Color lightOrange = Color(0xfffd8201);
final Color orangeDark = Color(0xfffc6b00);
//final Color red = Color(0xffec2029);
final Color red = Colors.red;
final Color green = Color(0xff1f8d1c);
final Color blackGrey = Color(0xff3c3c3c);
final Color whiteGrey = Color(0xfff9f7f8);
final Color textGrey = Color(0xff949494);
final Color snackColor = Color(0xff333333);
final Color white = Colors.white;
final Color grey = Colors.grey.shade300;
final Color couponYellow = Color(0xfff9f0c3);
final Color couponYellowDark = Color(0xffdbcb7c);
final Color grey_dark_text_color = Color(0xff636363);
final String NO_INTERNET_CONN = "No internet connection";
final String SOMETHING_WRONG_TEXT =
    "Something went wrong, Please check your internet connection or try again";

final rupee = '₹';
bool isRefreshed = false;

myPrint(String text) {
  // print(text);
}

class Utility {
  /// Construct a color from a hex code string, of the format #RRGGBB.
  static Color hexToColor(String code) {
    return new Color(int.parse(code.substring(1, 7), radix: 16) + 0xFF000000);
  }

  static Future pushToNext(final page, BuildContext context) {
    return Navigator.push(
      context,
      CupertinoPageRoute(
          builder: (context) => page,
          settings: RouteSettings(name: '${page.runtimeType}')),
    );
  }

  static Future pushToLogin(BuildContext context) async {
    // DialogHelper.showRemoveDialog(context, "Login Required?", "Please Login for Continue Shopping?","LOGIN",()async{
    //   Navigator.pop(context);
    final map = await pushToNext(LoginPage(), context);
    if (map != null) {
      final number = map["number"];
      final otp = map["actualOtp"];
      final otpMap =
          await pushToNext(Otp(number: number, actualOtp: otp), context);
      myPrint(otpMap.toString());
      if (otpMap != null) {
        if (!otpMap["isloginDone"]) {
          final showAppBar = otpMap["showAppBar"];
          final number = otpMap['number'];
          final registerValue = await pushToNext(
              MyAccountPage(
                showAppBar: showAppBar,
                number: number,
              ),
              context);
          return registerValue ?? false;
        } else {
          return true;
        }
      } else {
        return false;
      }
    } else {
      return false;
    }
    // });
  }

  static Future replaceWith(final page, BuildContext context) {
    return Navigator.pushReplacement(
      context,
      CupertinoPageRoute(
          builder: (context) => page,
          settings: RouteSettings(name: '${page.runtimeType}')),
    );
  }

  static replaceWithSame(final oldPage, final newPage, BuildContext context) {
    return Navigator.replace(
      context,
      oldRoute: CupertinoPageRoute(
          builder: (context) => oldPage,
          settings: RouteSettings(name: '${oldPage.runtimeType}')),
      newRoute: CupertinoPageRoute(
          builder: (context) => newPage,
          settings: RouteSettings(name: '${newPage.runtimeType}')),
    );
  }

  // static pushToDashBoard(BuildContext context) {
  //   Navigator.of(context).pushNamedAndRemoveUntil(
  //       '/DashboardPage', ModalRoute.withName('/LoginPage'));
  // }
  static showCustomSnackBar(var message, GlobalKey<ScaffoldState> scaffold) {
    ScaffoldMessenger.of(scaffold.currentContext).showSnackBar(SnackBar(
      content: Text(message),
      behavior: SnackBarBehavior.floating,
    ));
  }

    ///Generate MD5 hash
  static String generateMd5(String data) {
    var content = new Utf8Encoder().convert(data);
    var md5 = crypto.md5;
    var digest = md5.convert(content);
    return hex.encode(digest.bytes);
  }

  // current timestamp
  static int getTimeStamp() {
    return DateTime.now().millisecondsSinceEpoch;
  }

  static showMoveToBagBottomSheet(BuildContext context,
      {@required Product product, @required Function onDoneClick}) async {
    bool isLogin = await Prefs.isLogin;
    if (isLogin) {
      showModalBottomSheet(
          context: context,
          builder: (context) {
            return MoveToBag(
                product: product,
                onDoneClick:onDoneClick);
          });
    } else {
      DialogHelper.showRemoveDialog(context, "Login Required?",
          "Please Login for Continue Shopping?", "LOGIN", () async {
        Navigator.pop(context);
        pushToLogin(context);
      });
    }
  }

  static getIoClient() {
    bool trustSelfSigned = true;
    HttpClient httpClient = new HttpClient()
      ..badCertificateCallback =
          ((X509Certificate cert, String host, int port) => trustSelfSigned);
    IOClient ioClient = IOClient(httpClient);
    return ioClient;
  }

  static pushToDashboard(BuildContext context, var position) {
    Navigator.of(context).pushAndRemoveUntil(
      CupertinoPageRoute(
          builder: (BuildContext context) => DashBoardPage(
                position: position,
              )),
      ModalRoute.withName('/LoginPage'),
    );
  }

  static Future<bool> performWishList(BuildContext context, var scaffold,
      var productId, var isInWishlist, var fromDashboard) async {
    final isLogin = await Prefs.isLogin;
    if (isLogin) {
      if (isInWishlist) {
        final value = await Utility.removeProductFromWishList(
            context, scaffold, productId, fromDashboard);
        return value;
      } else {
        final value = await Utility.addroductToWishList(
            context, scaffold, productId, fromDashboard);
        return value;
      }
    } else {
      DialogHelper.showRemoveDialog(context, "Login Required?",
          "Please Login for Continue Shopping?", "LOGIN", () async {
        Navigator.pop(context);
        pushToLogin(context);
      });
    }
  }

  static String removeAllHtmlTags(String htmlText) {
    RegExp exp = RegExp(r"<[^>]*>", multiLine: true, caseSensitive: true);
    return htmlText.replaceAll(exp, '');
  }

  static Future<bool> addToCart(BuildContext context, var scaffold,
      var productId, var qty, var size, var fromDashboard) async {
    Utility.progressDialog(context, "Please wait...");
    try {
      final response =
          await ApiProvider().addToCart(productId, qty, size ?? "");
      Navigator.pop(context);
      if (response.status == UrlConstants.SUCCESS) {
        Utility.showScaffoldSnackBar(
            context, 'Added Sucessfully', scaffold, fromDashboard);
        return true;
      } else {
        Utility.showScaffoldSnackBar(
            context, response.message, scaffold, fromDashboard);
        return false;
      }
    } catch (e) {
      myPrint(e.toString());
      Navigator.pop(context);
      Utility.showScaffoldSnackBar(
          context, SOMETHING_WRONG_TEXT, scaffold, fromDashboard);
      return false;
    }
  }

  static Future<bool> addroductToWishList(BuildContext context, var scaffold,
      var productId, var fromDashboard) async {
    Utility.progressDialog(context, "Please wait...");
    final userId = await Prefs.id;
    try {
      final response = await ApiProvider().addToWishlist(userId, productId);
      Navigator.pop(context);
      if (response.status == UrlConstants.SUCCESS) {
        Utility.showScaffoldSnackBar(
            context, 'Added Sucessfully', scaffold, fromDashboard);
        return true;
      } else {
        Utility.showScaffoldSnackBar(
            context, response.message, scaffold, fromDashboard);
        return false;
      }
    } catch (e) {
      myPrint(e.toString());
      Navigator.pop(context);
      Utility.showScaffoldSnackBar(
          context, SOMETHING_WRONG_TEXT, scaffold, fromDashboard);
      return false;
    }
  }

  static showScaffoldSnackBar(
      BuildContext context, var message, var scaffold, var fromDashboard) {
    if (fromDashboard)
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ));
    else
      Utility.showCustomSnackBar(message, scaffold);
  }

  static Future<List<AddressData>> getAddressData() async {
    final response = await Prefs.addressResponse;
    final jsonResponse = json.decode(response);
    var items = List<AddressData>();
    if (jsonResponse != null) {
      jsonResponse.forEach((v) {
        items.add(new AddressData.fromJson(v));
      });
    }
    return items;
  }

  static Future<bool> removeProductFromWishList(BuildContext context,
      var scaffold, var productId, var fromDashboard) async {
    Utility.progressDialog(context, "Please wait...");
    final userId = await Prefs.id;
    try {
      final response =
          await ApiProvider().removeFromWishlist(userId, productId);
      Navigator.pop(context);
      if (response.status == UrlConstants.SUCCESS) {
        Utility.showScaffoldSnackBar(
            context, 'Removed Sucessfully', scaffold, fromDashboard);
        return true;
      } else {
        Utility.showScaffoldSnackBar(
            context, response.message, scaffold, fromDashboard);
        return false;
      }
    } catch (e) {
      myPrint(e.toString());
      Navigator.pop(context);
      Utility.showScaffoldSnackBar(
          context, SOMETHING_WRONG_TEXT, scaffold, fromDashboard);
      //Utility.showSnackBar(scaffoldKey,onRetryCliked: null);
      return false;
    }
  }

  static progressDialog(BuildContext context, var message) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return new AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(5.0))),
              content: new WillPopScope(
                  onWillPop: () async {
                    return false;
                  },
                  child: new Container(
                    color: Colors.white,
                    child: new Row(
                      mainAxisSize: MainAxisSize.max,
                      children: <Widget>[
                        // new SizedBox(height: 10,
                        new CircularProgressIndicator(),
                        //),

                        new Padding(
                          padding: const EdgeInsets.only(left: 20.0),
                          child: new Text(
                            message,
                            style: TextStyle(
                                fontSize: 14, color: Colors.grey[700]),
                          ),
                        )
                      ],
                    ),
                  )));
        });
  }

  static showSnackBar(scaffoldKey, {onRetryCliked}) {
    scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Text(
            'Something went wrong, Please check your internet connection or try again'),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 3),
        action: SnackBarAction(
          label: 'RETRY',
          onPressed: onRetryCliked,
        )));
  }

  static Future<bool> getConenctionStatus() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        return true;
      }
    } on SocketException catch (e) {
      myPrint(e.toString());
    }
    return false;
  }

  static Widget customRoundedWidget(var text, var color,
      {@required Function onClick}) {
    return new RawMaterialButton(
      constraints: BoxConstraints(),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      padding: EdgeInsets.only(top: 9, left: 15, bottom: 9, right: 15),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      elevation: 0,
      fillColor: red,
      // decoration:
      //     BoxDecoration(borderRadius: BorderRadius.circular(20), color: color),
      child: new Text(text,
          style: TextStyle(
              color: Colors.white, fontSize: 9, fontWeight: FontWeight.w600)),
      onPressed: () {
        onClick();
      },
    );
  }

  static pinCodetextUnderlineBorder(
      var error, var errorMsg, var title, var color) {
    var decoration = InputDecoration(
      errorText: (error) ? errorMsg : null,
      errorStyle: TextStyle(color: color, fontSize: 10),
      labelText: title,
      border: UnderlineInputBorder(
          borderSide: BorderSide(color: textGrey, width: 0.5)),
      enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: textGrey, width: 0.5)),
      focusedBorder:
          UnderlineInputBorder(borderSide: BorderSide(color: red, width: 0.5)),
      focusedErrorBorder:
          UnderlineInputBorder(borderSide: BorderSide(color: red, width: 0.7)),
      contentPadding: EdgeInsets.only(top: 10, bottom: 2, left: 0, right: 0),
      labelStyle: TextStyle(fontSize: 13, color: Colors.grey.shade700),
    );
    return decoration;
  }

  static textUnderlineBorder(var error, var errorMsg, var title) {
    var decoration = InputDecoration(
      errorText: (error) ? errorMsg : null,
      errorStyle: TextStyle(color: red, fontSize: 10),
      labelText: title,
      border: UnderlineInputBorder(
          borderSide: BorderSide(color: textGrey, width: 0.5)),
      enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: textGrey, width: 0.5)),
      focusedBorder:
          UnderlineInputBorder(borderSide: BorderSide(color: red, width: 0.5)),
      focusedErrorBorder:
          UnderlineInputBorder(borderSide: BorderSide(color: red, width: 0.7)),
      contentPadding: EdgeInsets.only(top: 10, bottom: 2, left: 0, right: 0),
      labelStyle: TextStyle(fontSize: 13, color: Colors.grey.shade700),
    );
    return decoration;
  }

  static Widget offerWidget(var title) {
    return Align(
      alignment: Alignment.topLeft,
      child: new Container(
          color: Colors.green.shade700,
          margin: EdgeInsets.only(top: 5.0),
          child: new Container(
            padding: EdgeInsets.symmetric(horizontal: 5, vertical: 3),
            child: new Text(
              title,
              style: TextStyle(color: Colors.white, fontSize: 8),
            ),
          )),
    );
  }

  static Widget networkErrorWidget() {
    return new Container(
        padding: const EdgeInsets.all(10.0),
        child: new Center(
          child: new Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'Can\'t Connect to Server. Please Check Your Internet Connection Or Try After Sometime.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ));
  }

  static String format(double n) {
    return n.toStringAsFixed(n.truncateToDouble() == n ? 2 : 2);
  }
}
