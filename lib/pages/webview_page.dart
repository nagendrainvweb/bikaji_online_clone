import 'package:bikaji/util/app_helper.dart';
import 'package:bikaji/util/textStyle.dart';
import 'package:bikaji/util/utility.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class BrowserPage extends StatefulWidget {
  var title;
  var url;
  BrowserPage(this.title, this.url);
  @override
  _BrowserPageState createState() => _BrowserPageState();
}

class _BrowserPageState extends State<BrowserPage> with AppHelper {
  double height = 0.0;
  bool _loadingPayment = true;
  InAppWebViewController _webViewController;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    _webViewController = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: _getAppBar,
        body: Container(
          child: Stack(
            children: <Widget>[
              Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  child: InAppWebView(
                      initialUrlRequest: URLRequest(url: Uri.parse(widget.url)),
                    initialOptions: InAppWebViewGroupOptions(
                      crossPlatform: InAppWebViewOptions(
                        useShouldOverrideUrlLoading: true,
                        mediaPlaybackRequiresUserGesture: false,
                      ),
                      android: AndroidInAppWebViewOptions(),
                      ios: IOSInAppWebViewOptions()),
                    onWebViewCreated: (controller) {
                      _webViewController = controller;
                    },
                    onLoadStart:(InAppWebViewController controller, Uri page) async {
                      if (!page.toString().contains("/about-us")) {
                          Navigator.pop(context);
                        }
                    } ,
                    onLoadStop:
                        (InAppWebViewController controller, Uri page) async {
                      myPrint(page.toFilePath());
                      if (_loadingPayment) {
                        this.setState(() {
                          _loadingPayment = false;
                        });
                      } 
                    },
                  )),
              (_loadingPayment)
                  ? Center(
                      child: CircularProgressIndicator(),
                    )
                  : Center(),
            ],
          ),
        ));
  }

  get _getLoadingView {
    return Scaffold(
      appBar: _getAppBar,
      body: Container(
        child: Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }

  get _getAppBar {
    return PreferredSize(
      preferredSize: Size.fromHeight(45),
      child: AppBar(
        elevation: 0,
        backgroundColor: red,
        title: Text(widget.title, style: toolbarStyle),
        leading: IconButton(
          icon: Icon(Icons.chevron_left),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
    );
  }
}
