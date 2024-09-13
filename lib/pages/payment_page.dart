import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:bikaji/util/constants.dart';
import 'package:bikaji/util/url_list.dart';
import 'package:bikaji/util/utility.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class PaymentPage extends StatefulWidget {
  final amount;
  final orderId;
  final userId;
  final email;
  final number;
  PaymentPage(
      {this.amount, this.orderId, this.userId, this.email, this.number});
  @override
  _PaymentPageState createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  InAppWebViewController _webViewController;
  bool _loadingPayment = true;
  String _responseStatus = STATUS_LOADING;

  @override
  void dispose() {
    _webViewController = null;
    super.dispose();
  }

  String _loadHTML() {
    return "<html> <body onload='document.f.submit();'> <form id='f' name='f' method='post' action='${UrlList.PAYMENT_URL}'>" +
        "<input type='hidden' name='orderID' value='${widget.orderId}'/>" +
        "<input  type='hidden' name='custID' value='${widget.userId}' />" +
        "<input  type='hidden' name='amount' value='${widget.amount}' />" +
        "<input type='hidden' name='custEmail' value='${widget.email}' />" +
        "<input type='hidden' name='custPhone' value='${widget.number}' />" +
        "</form> </body> </html>";
  }

  void getData() {
    _webViewController.evaluateJavascript(source: "document.body.innerText")
        //.evaluateJavascript(sou "document.body.innerText")
        .then((data) {
      //final decodedJson = jsonDecode(data);
      Navigator.pop(context, data);
    });
  }

  Widget getResponseScreen() {
    switch (_responseStatus) {
      case STATUS_SUCESSFUL:
        return PaymentSuccessfulScreen();
      case STATUS_CHECKSUM_FAILED:
        return CheckSumFailedScreen();
      case STATUS_FAILED:
        return PaymentFailedScreen();
    }
    return PaymentSuccessfulScreen();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: WillPopScope(
        onWillPop: () async {
          return false;
        },
        child: Scaffold(
          resizeToAvoidBottomInset: true,
          body: Stack(
            children: <Widget>[
              Container(
                width: MediaQuery.of(context).size.width,
                 height: MediaQuery.of(context).size.height,
                child: InAppWebView(
                  initialData: InAppWebViewInitialData(
                      data: _loadHTML(), mimeType: 'text/html'),
                  initialOptions: InAppWebViewGroupOptions(
                      crossPlatform: InAppWebViewOptions(
                        useShouldOverrideUrlLoading: true,
                        mediaPlaybackRequiresUserGesture: false,
                      ),
                      android: AndroidInAppWebViewOptions(
                          useHybridComposition: true),
                      ios: IOSInAppWebViewOptions()),
                  onWebViewCreated: (controller) {
                    _webViewController = controller;
                  },
                  onLoadStop:
                      (InAppWebViewController controller, Uri page) async {
                    //myPrint(page.toFilePath());
                    // getData();
                    // if (page.contains("/payment.php")) {
                    if (page.toString().contains("/process")) {
                      if (_loadingPayment) {
                        this.setState(() {
                          _loadingPayment = false;
                        });
                      }
                    }
                    if (page.toString().contains("/paymentReceipt.php")) {
                      getData();
                    }
                  },
                ),
              ),
              (_loadingPayment)
                  ? Center(
                      child: CircularProgressIndicator(),
                    )
                  : Center(),
              (_responseStatus != STATUS_LOADING)
                  ? Center(child: getResponseScreen())
                  : Center()
            ],
          ),
        ),
      ),
    );
  }
}

class PaymentSuccessfulScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "Great!",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 25),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                "Thank you making the payment!",
                style: TextStyle(fontSize: 30),
              ),
              SizedBox(
                height: 10,
              ),
              MaterialButton(
                  color: Colors.black,
                  child: Text(
                    "Close",
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: () {
                    Navigator.popUntil(context, ModalRoute.withName("/"));
                  })
            ],
          ),
        ),
      ),
    );
  }
}

class PaymentFailedScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "OOPS!",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 25),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                "Payment was not successful, Please try again Later!",
                style: TextStyle(fontSize: 30),
              ),
              SizedBox(
                height: 10,
              ),
              MaterialButton(
                  color: Colors.black,
                  child: Text(
                    "Close",
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: () {
                    Navigator.popUntil(context, ModalRoute.withName("/"));
                  })
            ],
          ),
        ),
      ),
    );
  }
}

class CheckSumFailedScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "Oh Snap!",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 25),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                "Problem Verifying Payment, If you balance is deducted please contact our customer support and get your payment verified!",
                style: TextStyle(fontSize: 30),
              ),
              SizedBox(
                height: 10,
              ),
              MaterialButton(
                  color: Colors.black,
                  child: Text(
                    "Close",
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: () {
                    Navigator.popUntil(context, ModalRoute.withName("/"));
                  })
            ],
          ),
        ),
      ),
    );
  }
}
