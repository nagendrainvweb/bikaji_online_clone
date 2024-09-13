import 'package:bikaji/util/custom_regex.dart';
import 'package:bikaji/util/utility.dart';
import 'package:flutter/material.dart';
import 'package:animator/animator.dart';
import 'package:flutter/services.dart';

import 'otp_page.dart';

class LoginDemo extends StatefulWidget {
  @override
  _LoginDemoState createState() => _LoginDemoState();
}

class _LoginDemoState extends State<LoginDemo> with TickerProviderStateMixin {
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

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initAnimation();

    Future.delayed(
        Duration(
          milliseconds: 800,
        ), () {
      setState(() {
        _showLogo = true;
      });
      _animationController.forward();
    });

    _bounceAnimation.addListener(() {
      setState(() {
        if (_bounceAnimation.isCompleted) {
          _scaleDownAnimation.forward();
        }
      });
    });

    _scaleDown.addListener(() {
      setState(() {});
    });
  }

  initAnimation() {
    _animationController =
        AnimationController(vsync: this, duration: Duration(seconds: 1));
    _scaleDownAnimation =
        AnimationController(vsync: this, duration: Duration(seconds: 1));
    _bounceAnimation = Tween(begin: 0.5, end: 1.5).animate(CurvedAnimation(
        parent: _animationController, curve: Curves.elasticOut));

    _scaleDown = Tween(begin: 1.0, end: 0.8).animate(CurvedAnimation(
        parent: _scaleDownAnimation, curve: Curves.linearToEaseOut));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage('assets/login_bg.jpg'), fit: BoxFit.cover)),
        child: SafeArea(
          top: true,
          child: new Container(
            child: Stack(
              children: <Widget>[
                // _getAppBarLeadingView,
                (_showLogo) ? _getLogo : Container(),
                 _getAlignText,
                (MediaQuery.of(context).viewInsets.bottom!=0)?Container(): (isValidNumber)?_getSendButton:Container(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  get _getSendButton {
    return  new Align(
            alignment: Alignment.bottomCenter,
            child: Container(
             // opacity: _fadeInOpacity,
              child: Row(
                children: <Widget>[
                  Expanded(
                    flex: 1,
                    child: InkWell(
                      onTap: () {
                        Utility.pushToNext(
                            Otp(
                              number: _numberController.text,
                              actualOtp: '1234',
                            ),
                            context);
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
    var secondHeight = centerOfScreen - (centerOfScreen * 70 / 100);
    var thirdHeight = centerOfScreen - (centerOfScreen * 10 / 100);

    return new Align(
      alignment: Alignment.topCenter,
      child: Container(
        child: Transform.scale(
          scale: (_bounceAnimation.isCompleted)
              ? _scaleDown.value
              : _bounceAnimation.value,
          child: AnimatedContainer(
            curve: Curves.linearToEaseOut,
            duration: Duration(
                milliseconds: (_bounceAnimation.isCompleted) ? 800 : 0),
            margin: EdgeInsets.only(
                top: _bounceAnimation.isCompleted ? secondHeight : firstHeight),
            child: Image.asset(
              'assets/bikaji_logo.png',
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
          height: 45,
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
              debugPrint(isError.toString());
            },
            style: TextStyle(
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w400,
                fontSize: 15),
            decoration: InputDecoration(
                fillColor: Colors.white,
                errorText: (!isError) ? null : null,
                contentPadding: const EdgeInsets.symmetric(vertical: 5),
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
                    child: new Icon(
                  Icons.smartphone,
                  size: 18,
                  color: Colors.grey.shade500,
                ))),
          ),
        ));
  }
}
