import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:bikaji/model/BasicResponse.dart';
import 'package:bikaji/pages/otp_page.dart';
import 'package:bikaji/pages/otp_verification.dart';
import 'package:bikaji/prefrence_util/Prefs.dart';
import 'package:bikaji/repo/Repository.dart';
import 'package:bikaji/repo/api_provider.dart';
import 'package:bikaji/util/custom_regex.dart';
import 'package:bikaji/util/dialog_helper.dart';
import 'package:bikaji/util/url_list.dart';
import 'package:bikaji/util/utility.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

import 'dashboard_page.dart';

class LoginPage extends StatefulWidget {

  
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with TickerProviderStateMixin {
  final _scaffoldkey = GlobalKey<ScaffoldState>();
  AnimationController _animationController;
  AnimationController _scaleDownAnimation;
  Animation _bounceAnimation;
  Animation _scaleDown;
  var _animatonDuration = 0;
  var _showLogo = false;
  final textKey = GlobalKey();
  double scale;

  final _numberController = TextEditingController();
  var _focusNode = new FocusNode();
  bool isError = false;
  var logoMargin = 0.0;
  var hasFocus = false;
  var isValidNumber = false;
  var sendingOtp = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initAnimation();
    initNotification();

    Future.delayed(
        Duration(
          milliseconds: 1500,
        ), () {
      setState(() {
        _showLogo = true;
      });
      _animationController.forward();
    });

    _bounceAnimation.addListener(() {
      setState(() {
        if (_bounceAnimation.isCompleted) {
          Future.delayed(Duration(milliseconds: 500), () {
            _scaleDownAnimation.forward();
          });
        }
      });
    });

    _scaleDown.addListener(() {
      setState(() {});
    });

    checkUpdate();
  }

  checkUpdate() async {
    try {
      final response =
          await ApiProvider().fetchUpdate();
      if (response.status == UrlConstants.SUCCESS) {
        if (response.isUpdate == 1) {
          DialogHelper.showUpdateDialog(context,response);
        }
      }
    } catch (e) {
      myPrint(e.toString());
    }
  }

  initNotification() async {
    final _firebaseMessaging = FirebaseMessaging.instance;
    if (Platform.isIOS) _firebaseMessaging.requestPermission();

    final token = await _firebaseMessaging.getToken();
    myPrint("token  is $token");
    Prefs.setFCMToken(token);
  }

  initAnimation() {
    _animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 500));
    _scaleDownAnimation =
        AnimationController(vsync: this, duration: Duration(milliseconds: 300));
    _bounceAnimation = Tween(begin: 1.0, end: 1.0).animate(CurvedAnimation(
        parent: _animationController, curve: Curves.elasticOut));
    // Tween(begin: 0.5, end: 1.5).animate(CurvedAnimation(
    //     parent: _animationController, curve: Curves.elasticOut));

    _scaleDown = Tween(begin: 1.0, end: 0.8).animate(
        CurvedAnimation(parent: _scaleDownAnimation, curve: Curves.linear));
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scaleDownAnimation.dispose();
    super.dispose();
  }

  var disposeController = () => {};

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
                    image: AssetImage('assets/login_bg.jpg'), fit: BoxFit.cover),
      ),
      child: Scaffold(
        key: _scaffoldkey,
        backgroundColor: Colors.transparent,
        body: GestureDetector(
          onTap: () {
            FocusScope.of(context).requestFocus(new FocusNode());
          },
          child: Container(
            // decoration: BoxDecoration(
            //     image: DecorationImage(
            //         image: AssetImage('assets/login_bg.jpg'), fit: BoxFit.cover)),
            child: SafeArea(
              top: true,
              bottom: false,
              child: SafeArea(
                top: true,
                bottom: false,
                child: Stack(
                  children: <Widget>[
                    Align(
                     alignment: Alignment.topLeft,
                     child: IconButton(icon: Icon(Icons.arrow_back_ios,color: white,), onPressed: (){
                       Navigator.pop(context);
                     }),
                    ),
                    // _getAppBarLeadingView,
                    // (_showLogo) ?
                    _getLogo,
                    //: Container(),
                    _getAlignText,
                    // (isValidNumber)?_getSendButton:Container()
                    (MediaQuery.of(context).viewInsets.bottom != 0)
                        ? Container()
                        : (isValidNumber) ? _getSendButton : Container(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  get _getSendButton {
    return new Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        // opacity: _fadeInOpacity,
        child: (sendingOtp)
            ? Container(
                padding: EdgeInsets.all(20),
                child: CircularProgressIndicator(
                  backgroundColor: red,
                ))
            : Row(
                children: <Widget>[
                  Expanded(
                    flex: 1,
                    child: InkWell(
                      onTap: () async {
                        if (isValidNumber) {
                          final _firebaseMessaging = FirebaseMessaging.instance;
                          if (Platform.isIOS)
                            _firebaseMessaging.requestPermission();

                          final token = await _firebaseMessaging.getToken();
                          myPrint("token  is $token");
                          Prefs.setFCMToken(token);
                          _sendOtp(_numberController.text);
                        }
                      },
                      child: new Container(
                        color: red,
                        padding: const EdgeInsets.all(18),
                        child: Text(
                          'SEND OTP',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  get _getLogo {
    var screenHeight = MediaQuery.of(context).size.height;
    var centerOfScreen = screenHeight / 2;
    var firstHeight = centerOfScreen - (centerOfScreen * 30 / 100);
    var secondHeight = centerOfScreen - (centerOfScreen * 75 / 100);
    var thirdHeight = centerOfScreen - (centerOfScreen * 10 / 100);

    return new Align(
      alignment: Alignment.topCenter,
      child: Container(
        child: Transform.scale(
          scale: (_bounceAnimation.isCompleted)
              ? _scaleDown.value
              : _bounceAnimation.value,
          child: AnimatedContainer(
            curve: Curves.linear,
            duration: Duration(
                milliseconds: (_bounceAnimation.isCompleted) ? 800 : 0),
            margin: EdgeInsets.only(
                top: _bounceAnimation.isCompleted ? secondHeight : firstHeight),
            child: Image.asset(
              'assets/bikaji_logo.png',
              fit: BoxFit.cover,
              width: 200,
            ),
          ),
        ),
      ),
    );
  }

  get _getAlignText {
    var screenHeight = MediaQuery.of(context).size.height;
    var centerOfScreen = screenHeight / 2;
    var firstHeight = screenHeight + 10;
    var secondHeight = centerOfScreen - (centerOfScreen * 20 / 100);
    var thirdHeight = centerOfScreen - (centerOfScreen * 20 / 100);

    return new Align(
      alignment: Alignment.topCenter,
      child: AnimatedContainer(
        curve: Curves.linear,
        duration:
            Duration(milliseconds: (_bounceAnimation.isCompleted) ? 800 : 0),
        margin: EdgeInsets.only(
          top: (_bounceAnimation.isCompleted) ? secondHeight : firstHeight,
        ),
        child: Stack(
          children: <Widget>[
            _getTextFeild,
          ],
        ),
      ),
    );
  }

  get _getTextFeild {
    return new Container(
        key: textKey,
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Container(
          height: 50,
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(7)),
          child: new TextField(
            inputFormatters: [
              LengthLimitingTextInputFormatter(10),
            ],
            focusNode: _focusNode,
            controller: _numberController,
            keyboardType: TextInputType.number,
            onChanged: (value) {
              var isValid = RegExp(CustomRegex.mobile_regex).hasMatch(value);
              setState(() {
                isValidNumber = isValid;
              });
              if (isValid) FocusScope.of(context).requestFocus(new FocusNode());
            },
            style: TextStyle(
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w400,
                fontSize: 18),
            decoration: InputDecoration(
                fillColor: Colors.white,
                errorText: (!isError) ? null : null,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5),
                  borderSide: const BorderSide(color: Colors.white, width: 1.0),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.white, width: 1.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.white, width: 1.0),
                ),
                disabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.white, width: 1.0),
                ),
                hintText: 'Enter Number',
                prefixIcon: Container(
                    child:
                        // Column(
                        //   crossAxisAlignment: CrossAxisAlignment.center,
                        //   mainAxisAlignment: MainAxisAlignment.center,
                        //   children: <Widget>[
                        //     Text('+91',textScaleFactor: 1.2,style: TextStyle(fontWeight: FontWeight.bold,color: textGrey),),
                        //   ],
                        // )
                  Icon(
                  Icons.phone_android_outlined,
                  size: 22,
                  color: Colors.grey.shade500,
                ))),
          ),
        ));
  }

  void _sendOtp(String number) async {
    final random = (Random().nextInt(9000) + 1000).toString();
    setState(() {
      sendingOtp = true;
    });

    try {
      final BasicResponse<String> response =
          await ApiProvider()
              .sendOtp(number, random);
      sendingOtp = false;
      myPrint('otp is: ${random}');
      if (response.status == UrlConstants.SUCCESS) {
        final map ={
          "number":_numberController.text,
          "actualOtp":random,
        };
        Navigator.pop(context,map);
        // Utility.replaceWithSame(
        //   widget.oldPage,
        //     Otp(
        //       number: _numberController.text,
        //       actualOtp: random,
        //     ),
        //     context);
      } else {
        ApiProvider().sendMail("sendOtp", response.message);
        Utility.showCustomSnackBar(
            'Could not connect to internet, Please try again.', _scaffoldkey);
      }
      setState(() {});
    } catch (e) {
      myPrint(e.toString());
      Utility.showSnackBar(_scaffoldkey, onRetryCliked: () => _sendOtp(number));
      setState(() {
        sendingOtp = false;
      });
    }
  }
}
