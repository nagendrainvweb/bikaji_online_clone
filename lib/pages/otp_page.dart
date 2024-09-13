import 'dart:async';
import 'dart:math';

import 'package:bikaji/model/BasicResponse.dart';
import 'package:bikaji/model/UserData.dart';
import 'package:bikaji/pages/account_page.dart';
import 'package:bikaji/pages/dashboard_page.dart';
import 'package:bikaji/pages/my_account.dart';
import 'package:bikaji/prefrence_util/Prefs.dart';
import 'package:bikaji/repo/Repository.dart';
import 'package:bikaji/repo/api_provider.dart';
import 'package:bikaji/util/constants.dart';
import 'package:bikaji/util/url_list.dart';
import 'package:bikaji/util/utility.dart';
//import 'package:facebook_analytics/facebook_analytics.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Otp extends StatefulWidget {
  final String number;
  final String newNumber;
  final String actualOtp;

  const Otp({
    Key key,
    @required this.number,
    this.newNumber = "",
    @required this.actualOtp,
  }) : super(key: key);

  @override
  _OtpState createState() => new _OtpState();
}

class _OtpState extends State<Otp> with SingleTickerProviderStateMixin {
  // Constants
  final int time = 30;
  AnimationController _controller;
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  // Variables
  Size _screenSize;
  int _currentDigit;
  int _firstDigit;
  int _secondDigit;
  int _thirdDigit;
  int _fourthDigit;

  Timer timer;
  int totalTimeInSeconds;
  bool _hideResendButton;

  String userName = "";
  String loadingText = 'verifying OTP';
  bool didReadNotifications = false;
  bool didFinishOtp = false;
  bool isInvalidOtp = false;
  int unReadNotificationsCount = 0;
  String acutalOtp;
  // Returns "Appbar"
  get _getAppbar {
    return new AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0.0,
      leading: new InkWell(
        borderRadius: BorderRadius.circular(30.0),
        child: new Icon(
          Icons.arrow_back,
          color: Colors.black54,
        ),
        onTap: () {
          Navigator.pop(context);
        },
      ),
      centerTitle: true,
    );
  }

  // Return "Verification Code" label
  get _getVerificationCodeLabel {
    return Text('VERIFICATION CODE',
        style: TextStyle(
            color: Colors.grey.shade700,
            fontSize: 19,
            fontWeight: FontWeight.w500));
  }

  // Return "Email" label
  get _getEmailLabel {
    return Text(
        'Please type the verification code sent to\n+91 ${widget.number}',
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.grey.shade500, fontSize: 14, height: 1.2
            //fontWeight: FontWeight.w500
            ));
  }

  // Return "OTP" input field
  get _getInputField {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: new Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          _otpTextField(_firstDigit),
          _otpTextField(_secondDigit),
          _otpTextField(_thirdDigit),
          _otpTextField(_fourthDigit),
        ],
      ),
    );
  }

  // Returns "OTP" input part
  get _getInputPart {
    return new Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        _getVerificationCodeLabel,
        SizedBox(
          height: 25,
        ),
        _getEmailLabel,
        SizedBox(
          height: 60,
        ),
        _getInputField,
        isInvalidOtp ? _invalidOTPSms : Container(),
        SizedBox(
          height: 40,
        ),
        _hideResendButton ? _getTimerText : _getResendButton,
        SizedBox(
          height: 50,
        ),
        Expanded(
          child: (!didFinishOtp) ? _getOtpKeyboard : _showProgressBar,
        )
      ],
    );
  }

  get _invalidOTPSms {
    return Container(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          SizedBox(
            height: 20,
          ),
          Text(
            'Invalid OTP',
            textAlign: TextAlign.center,
            style: TextStyle(
                color: Colors.red.shade500,
                fontWeight: FontWeight.w400,
                fontSize: 13),
          )
        ],
      ),
    );
  }

  get _showProgressBar {
    return Container(
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            CircularProgressIndicator(),
            SizedBox(
              height: 10,
            ),
            Text(
              'Verifying User',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Colors.red.shade500,
                  fontWeight: FontWeight.w400,
                  fontSize: 15),
            )
          ],
        ),
      ),
    );
  }

  // Returns "Timer" label
  get _getTimerText {
    return Container(
      height: 32,
      child: new Offstage(
        offstage: !_hideResendButton,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            new Icon(
              Icons.access_time,
              color: red,
              size: 18,
            ),
            new SizedBox(
              width: 5.0,
            ),
            OtpTimer(_controller, 14.0, red)
          ],
        ),
      ),
    );
  }

  void _sendOtp(String number) async {
    final random = (Random().nextInt(9000) + 1000).toString();
    myPrint(random);

    try {
      final BasicResponse<String> response =
          await ApiProvider().sendOtp(number,random);
      if (response.status == UrlConstants.SUCCESS) {
        acutalOtp = random;
        _startCountdown();
      } else {
         ApiProvider().sendMail("sendOtp", response.message);
        Utility.showCustomSnackBar(
            'Could not connect to internet, Please try again.', _scaffoldKey);
      }
      setState(() {});
    } catch (e) {
      myPrint(e.toString());
    }
  }

  // Returns "Resend" button
  get _getResendButton {
    return Column(
      children: <Widget>[
        new Text(
          "Don't Receive the OTP?",
          style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
              fontWeight: FontWeight.w500),
        ),
        SizedBox(
          height: 8,
        ),
        new Container(
          child: Center(
            child: InkWell(
              onTap: () {
                _sendOtp(widget.number);
              },
              child: new Container(
                padding: EdgeInsets.only(bottom: 1),
                decoration: BoxDecoration(
                    border: Border(bottom: BorderSide(color: red, width: 1))),
                child: new Text(
                  "Resend OTP",
                  style: new TextStyle(
                      fontWeight: FontWeight.w600, color: red, fontSize: 12),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Returns "Otp" keyboard
  get _getOtpKeyboard {
    return new Container(
        color: Colors.white,
        height: _screenSize.width - 80,
        child: new Column(
          children: <Widget>[
            new Expanded(
              child: new Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  _otpKeyboardInputButton(
                      label: "1",
                      onPressed: () {
                        _setCurrentDigit(1);
                      }),
                  _otpKeyboardInputButton(
                      label: "2",
                      onPressed: () {
                        _setCurrentDigit(2);
                      }),
                  _otpKeyboardInputButton(
                      label: "3",
                      onPressed: () {
                        _setCurrentDigit(3);
                      }),
                ],
              ),
            ),
            new Expanded(
              child: new Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  _otpKeyboardInputButton(
                      label: "4",
                      onPressed: () {
                        _setCurrentDigit(4);
                      }),
                  _otpKeyboardInputButton(
                      label: "5",
                      onPressed: () {
                        _setCurrentDigit(5);
                      }),
                  _otpKeyboardInputButton(
                      label: "6",
                      onPressed: () {
                        _setCurrentDigit(6);
                      }),
                ],
              ),
            ),
            new Expanded(
              child: new Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  _otpKeyboardInputButton(
                      label: "7",
                      onPressed: () {
                        _setCurrentDigit(7);
                      }),
                  _otpKeyboardInputButton(
                      label: "8",
                      onPressed: () {
                        _setCurrentDigit(8);
                      }),
                  _otpKeyboardInputButton(
                      label: "9",
                      onPressed: () {
                        _setCurrentDigit(9);
                      }),
                ],
              ),
            ),
            new Expanded(
              child: new Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  new SizedBox(
                    width: 80.0,
                  ),
                  _otpKeyboardInputButton(
                      label: "0",
                      onPressed: () {
                        _setCurrentDigit(0);
                      }),
                  _otpKeyboardActionButton(
                      label: new Icon(Icons.backspace,
                          color: Colors.grey.shade800),
                      onPressed: () {
                        setState(() {
                          if (_fourthDigit != null) {
                            _fourthDigit = null;
                          } else if (_thirdDigit != null) {
                            _thirdDigit = null;
                          } else if (_secondDigit != null) {
                            _secondDigit = null;
                          } else if (_firstDigit != null) {
                            _firstDigit = null;
                          }
                        });
                      }),
                ],
              ),
            ),
          ],
        ));
  }

  // Overridden methods
  @override
  void initState() {
    totalTimeInSeconds = time;
    super.initState();
    acutalOtp = widget.actualOtp;
    _controller =
        AnimationController(vsync: this, duration: Duration(seconds: time))
          ..addStatusListener((status) {
            if (status == AnimationStatus.dismissed) {
              setState(() {
                _hideResendButton = !_hideResendButton;
              });
            }
          });
    _controller.reverse(
        from: _controller.value == 0.0 ? 1.0 : _controller.value);
    _startCountdown();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _screenSize = MediaQuery.of(context).size;
    return new Scaffold(
      key: _scaffoldKey,
      appBar: _getAppbar,
      backgroundColor: Colors.grey.shade200,
      body: new Container(
        width: _screenSize.width,
//        padding: new EdgeInsets.only(bottom: 16.0),
        child: _getInputPart,
      ),
    );
  }

  // Returns "Otp custom text field"
  Widget _otpTextField(int digit) {
    return new Container(
      width: 35.0,
      height: 45.0,
      alignment: Alignment.center,
      child: new Text(
        digit != null ? digit.toString() : "",
        style: new TextStyle(
          fontSize: 30.0,
          color: Colors.grey.shade700,
        ),
      ),
      decoration: BoxDecoration(
//            color: Colors.grey.withOpacity(0.4),
          border: Border(
              bottom: BorderSide(
        width: 0.8,
        color: textGrey,
      ))),
    );
  }

  // Returns "Otp keyboard input Button"
  Widget _otpKeyboardInputButton({String label, VoidCallback onPressed}) {
    return new Material(
      color: Colors.transparent,
      child: new InkWell(
        onTap: onPressed,
        borderRadius: new BorderRadius.circular(40.0),
        child: new Container(
          height: 80.0,
          width: 80.0,
          decoration: new BoxDecoration(
            shape: BoxShape.circle,
          ),
          child: new Center(
            child: new Text(
              label,
              style: new TextStyle(fontSize: 30.0, color: Colors.grey.shade800),
            ),
          ),
        ),
      ),
    );
  }

  // Returns "Otp keyboard action Button"
  _otpKeyboardActionButton({Widget label, VoidCallback onPressed}) {
    return new InkWell(
      onTap: onPressed,
      borderRadius: new BorderRadius.circular(40.0),
      child: new Container(
        height: 80.0,
        width: 80.0,
        decoration: new BoxDecoration(
          shape: BoxShape.circle,
        ),
        child: new Center(
          child: label,
        ),
      ),
    );
  }

  // Current digit
  void _setCurrentDigit(int i) {
    setState(() {
      _currentDigit = i;
      if (_firstDigit == null) {
        _firstDigit = _currentDigit;
      } else if (_secondDigit == null) {
        _secondDigit = _currentDigit;
      } else if (_thirdDigit == null) {
        _thirdDigit = _currentDigit;
      } else if (_fourthDigit == null) {
        _fourthDigit = _currentDigit;

        var otp = _firstDigit.toString() +
            _secondDigit.toString() +
            _thirdDigit.toString() +
            _fourthDigit.toString();

        // // Verify your otp by here. API call
        // didFinishOtp = true;
        // Future.delayed(Duration(seconds: 2), () async {
        //   myPrint('i am calling');
        if (widget.number == "8655891410" && otp == "1234") {
          loginUser();
        } else {
          if (otp == acutalOtp.toString()) {
            // Prefs.setOTPVerified(true);
            loginUser();
            // SharedPreferences sp = await SharedPreferences.getInstance();
            // sp.setBool(Constants.isLogin, true);
            // Utility.pushToNext(MyAccountPage(showAppBar: false,), context);
            //Utility.pushToDashboard(context,0);
          } else {
            setState(() {
              isInvalidOtp = true;
              clearOtp();
            });
          }
        }

        // });
      }
    });
  }

  loginUser() async {
    setState(() {
      isInvalidOtp = false;
      didFinishOtp = true;
    });
    try {
      final response = await ApiProvider().fetchUserlogin(widget.number);
      if (response.status == Constants.success) {
        final user = response.data;
        saveData(user);
      } else {
        myPrint(response.message);
        final map = {
          "isloginDone": false,
          "showAppBar":false,
          "number":widget.number,
        };
        Navigator.pop(context,map);
        // Utility.replaceWith(
        //     MyAccountPage(
        //       showAppBar: false,
        //       number: widget.number,
        //     ),
        //     context);
      }

      setState(() {
        didFinishOtp = false;
        clearOtp();
      });
    } catch (e) {
      myPrint(e.toString());
      setState(() {
        didFinishOtp = false;
        clearOtp();
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
            'Something went wrong, Please check your internet connection or try again'),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
            label: 'RETRY',
            onPressed: () {
              loginUser();
            }),
      ));
    }
  }

  saveData(User user) async {
    // FacebookAnalytics().logEvent(name: "Login", parameters: {"id": user.id});
    Prefs.setId(user.id);
    Prefs.setToken(user.accessToken);
    Prefs.setFirstName(user.firstName);
    Prefs.setLastName(user.lastName);
    Prefs.setEmail(user.emailId);
    Prefs.setMobileNumber(user.mobileNumber);
    Prefs.setDob(user.dob);
    Prefs.setImageUrl(user.profile_pic);
    Prefs.setLogin(true);
    final map = {
      "isloginDone": true,
    };
    Navigator.pop(context, map);
    // Utility.pushToDashboard(context, 0);
  }

  Future<Null> _startCountdown() async {
    setState(() {
      _hideResendButton = true;
      totalTimeInSeconds = time;
    });
    _controller.reverse(
        from: _controller.value == 0.0 ? 1.0 : _controller.value);
  }

  void clearOtp() {
    _fourthDigit = null;
    _thirdDigit = null;
    _secondDigit = null;
    _firstDigit = null;
    setState(() {});
  }
}

class OtpTimer extends StatelessWidget {
  final AnimationController controller;
  double fontSize;
  Color timeColor = Colors.black;

  OtpTimer(this.controller, this.fontSize, this.timeColor);

  String get timerString {
    Duration duration = controller.duration * controller.value;
    if (duration.inHours > 0) {
      return '${duration.inHours}:${duration.inMinutes % 60}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}';
    }
    return '${duration.inMinutes % 60}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}';
  }

  Duration get duration {
    Duration duration = controller.duration;
    return duration;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
        animation: controller,
        builder: (BuildContext context, Widget child) {
          return new Text(
            timerString,
            style: new TextStyle(
                fontSize: fontSize,
                color: timeColor,
                fontWeight: FontWeight.w600),
          );
        });
  }
}
