import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:bikaji/bloc/DashboardBloc/DashboardBloc.dart';
import 'package:bikaji/bloc/DashboardBloc/DashboardState.dart';
import 'package:bikaji/model/NotificationData.dart';
import 'package:bikaji/model/bottom_navigation.dart';
import 'package:bikaji/pages/home.dart';
import 'package:bikaji/pages/introPage.dart';
import 'package:bikaji/pages/productDetails.dart';
import 'package:bikaji/pages/wishList_page.dart';
import 'package:bikaji/prefrence_util/Prefs.dart';
import 'package:bikaji/repo/Repository.dart';
import 'package:bikaji/repo/api_provider.dart';
import 'package:bikaji/util/app_helper.dart';
import 'package:bikaji/util/constants.dart';
import 'package:bikaji/util/custom_icons.dart';
import 'package:bikaji/util/data_search.dart';
import 'package:bikaji/util/dialog_helper.dart';
import 'package:bikaji/util/url_list.dart';
import 'package:bikaji/util/utility.dart';
//import 'package:facebook_analytics/facebook_analytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:uni_links/uni_links.dart';

import 'account_page.dart';
import 'cart_page.dart';
import 'category_page.dart';
import 'more_page.dart';
import 'notification_page.dart';
import 'offer_page.dart';

enum UniLinksType { string, uri }

class DashBoardPage extends StatefulWidget {
  int position;

  DashBoardPage({this.position = 0});
  @override
  _DashBoardPageState createState() => _DashBoardPageState();
}

class _DashBoardPageState extends State<DashBoardPage> with AppHelper {
  int currentPosition = 0;
  String _currentTab;
  DateTime currentBackPressTime;
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  int cartCount = 0;
  int _notificationCount = 0;

  String _latestLink = 'Unknown';
  Uri _latestUri;

  StreamSubscription _sub;

  TabController _tabController;
  UniLinksType _type = UniLinksType.string;

  @override
  void initState() {
    _setData();
    super.initState();
    currentPosition = widget.position;
    _currentTab = navigationList[currentPosition].title;
    initNotification();
    initPlatformState();
    _registerFCMToken();
    fetchState();
    //checkUpdate();
  }

  @override
  dispose() {
    if (_sub != null) _sub.cancel();
    super.dispose();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  initPlatformState() async {
    if (_type == UniLinksType.string) {
      await initPlatformStateForStringUniLinks();
    } else {
      await initPlatformStateForUriUniLinks();
    }
  }

  /// An implementation using a [String] link
  initPlatformStateForStringUniLinks() async {
    // Attach a listener to the links stream
    _sub = getLinksStream().listen((String link) {
      if (!mounted) return;
      setState(() {
        _latestLink = link ?? 'Unknown';
        _latestUri = null;
        try {
          if (link != null) _latestUri = Uri.parse(link);
        } on FormatException {}
      });
    }, onError: (err) {
      if (!mounted) return;
      setState(() {
        _latestLink = 'Failed to get latest link: $err.';
        _latestUri = null;
      });
    });

    // Attach a second listener to the stream
    getLinksStream().listen((String link) {
      if (link != null) {
        final list = link.split("/");
        final productName =
            list[3].replaceAll(".html", "").replaceAll("-", " ");

        _sendToProductPage(productName);
      }
    }, onError: (err) {
      print('got err: $err');
    });

    // Get the latest link
    String initialLink;
    Uri initialUri;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      initialLink = await getInitialLink();
      print('initial link: $initialLink');
      if (initialLink != null) {
        initialUri = Uri.parse(initialLink);
        final list = initialLink.split("/");
        final productName =
            list[3].replaceAll(".html", "").replaceAll("-", " ");
        _sendToProductPage(productName);
      }
    } on PlatformException {
      initialLink = 'Failed to get initial link.';
      initialUri = null;
    } on FormatException {
      initialLink = 'Failed to parse the initial link as Uri.';
      initialUri = null;
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _latestLink = initialLink;
      _latestUri = initialUri;
    });
  }

  _sendToProductPage(String productName) async {
    progressDialog(context, "please wait...");
    try {
      final response = await ApiProvider().fetchSearchData(productName);
      hideProgressDialog(context);
      if (response.status == Constants.success) {
        if (response.data.isNotEmpty) {
          final searchData = response.data[0];
          Utility.pushToNext(
              ProductDetails(
                productId: searchData.id,
              ),
              context);
        }
      }
    } catch (e) {
      hideProgressDialog(context);
      myPrint(e.toString());
    }
  }

  /// An implementation using the [Uri] convenience helpers
  initPlatformStateForUriUniLinks() async {
    // Attach a listener to the Uri links stream
    _sub = getUriLinksStream().listen((Uri uri) {
      if (!mounted) return;
      setState(() {
        _latestUri = uri;
        _latestLink = uri?.toString() ?? 'Unknown';
      });
    }, onError: (err) {
      if (!mounted) return;
      setState(() {
        _latestUri = null;
        _latestLink = 'Failed to get latest link: $err.';
      });
    });

    // Attach a second listener to the stream
    getUriLinksStream().listen((Uri uri) {
      print('got uri: ${uri?.path} ${uri?.queryParametersAll}');
    }, onError: (err) {
      print('got err: $err');
    });

    // Get the latest Uri
    Uri initialUri;
    String initialLink;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      initialUri = await getInitialUri();
      print('initial uri: ${initialUri?.path}'
          ' ${initialUri?.queryParametersAll}');
      initialLink = initialUri?.toString();
    } on PlatformException {
      initialUri = null;
      initialLink = 'Failed to get initial uri.';
    } on FormatException {
      initialUri = null;
      initialLink = 'Bad parse the initial link as Uri.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _latestUri = initialUri;
      _latestLink = initialLink;
    });
  }

  fetchState() async {
    try {
      final response = await ApiProvider().fetchStateList();
      final isLogin = await Prefs.isLogin;
      if (isLogin) {
        _notificationCount = 0;
        final notificationResponse = await ApiProvider().fetchNotifications();
        for (NotificationData data in notificationResponse.data) {
          if (!data.isRead) {
            _notificationCount++;
          }
        }

        setState(() {});
      }
    } catch (e) {
      myPrint("${e.toString()}");
    }
  }

  _registerFCMToken() async {
    try {
      final response = await ApiProvider().registerToken();
    } catch (e) {
      myPrint(e.toString());
    }
  }

  checkUpdate() async {
    try {
      final response = await ApiProvider().fetchUpdate();
      if (response.status == UrlConstants.SUCCESS) {
        if (response.isUpdate == 1) {
          DialogHelper.showUpdateDialog(context, response);
        }
      }
    } catch (e) {
      myPrint(e.toString());
    }
  }

  _setData() async {
    final data = await Prefs.cartCount;
    setState(() {
      cartCount = data;
    });
  }

  Future<bool> onWillPop() {
    DateTime now = DateTime.now();
    if (currentPosition != 0) {
      setState(() {
        currentPosition = 0;
        // _currentTab = navigationList[position].title;
      });
      return Future.value(false);
    } else {
      if (currentBackPressTime == null ||
          now.difference(currentBackPressTime) > Duration(seconds: 2)) {
        currentBackPressTime = now;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          // behavior: SnackBarBehavior.floating,
          content: Text(
            'BACK AGAIN TO EXIT',
            style: TextStyle(
                color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
          ),
        ));
        return Future.value(false);
      }
    }
    return Future.value(true);
  }

  initNotification() async {
    if (Platform.isIOS) {
      NotificationSettings settings =
          await _firebaseMessaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );
      myPrint('User granted permission: ${settings.authorizationStatus}');
    }

    //_firebaseMessaging.requestNotificationPermissions();

    _firebaseMessaging.getToken().then((token) {
      myPrint(token);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((event) {
      print("onMessageOpenedApp: $event");
      Utility.pushToNext(NotificationPage(), context);
    });

    FirebaseMessaging.instance
        .getInitialMessage()
        .then((RemoteMessage message) {
      if (message != null) {
         Utility.pushToNext(NotificationPage(), context);
      }
    });

    // subscribe to topic
    //_firebaseMessaging.subscribeToTopic('alerts');
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Got a message whilst in the foreground!');
      print('Message data: ${message.data}');

      // if (message.notification != null) {
      Utility.pushToNext(NotificationPage(), context);
      print('Message also contained a notification: ${message.notification}');
      //  }
    });

    // _firebaseMessaging.configure(
    //     onMessage: (Map<String, dynamic> message) async {
    //   myPrint("onMessage: $message");
    //   // _showItemDialog(message);
    // },
    //     // onBackgroundMessage:myBackgroundMessageHandler,
    //     onLaunch: (Map<String, dynamic> message) async {
    //   myPrint("onLaunch: $message");
    //   // _navigateToItemDetail(message);
    // }, onResume: (Map<String, dynamic> message) async {
    //   myPrint("onResume: $message");
    //   // _navigateToItemDetail(message);
    // });
  }

  Future<dynamic> myBackgroundMessageHandler(Map<String, dynamic> message) {
    if (message.containsKey('data')) {
      // Handle data message
      final dynamic data = message['data'];
    }

    if (message.containsKey('notification')) {
      // Handle notification message
      final dynamic notification = message['notification'];
    }

    return Future<void>.value();
    // Or do other work.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(45),
        child: new AppBar(
          elevation: 0.0,
          backgroundColor: Colors.red.shade500,
          centerTitle: true,
          title: Text(
            _getTitle(),
            style: TextStyle(fontSize: 16),
          ),
          leading: IconButton(
            icon: Container(
              child: Stack(
                children: <Widget>[
                  Icon(
                    MyFlutterApp.ic_notification,
                    color: Colors.white,
                    size: 20,
                  ),
                  (_notificationCount != 0)
                      ? Container(
                          margin: EdgeInsets.only(top: 8, left: 10),
                          child: Container(
                            width: 15,
                            height: 15,
                            decoration: BoxDecoration(
                                color: green, shape: BoxShape.circle),
                            child: Center(
                                child: Text(
                              "$_notificationCount",
                              style: TextStyle(
                                  color: white,
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold),
                            )),
                          ),
                        )
                      : SizedBox()
                  // Container(
                  //   width: 8,
                  //   height: 8,
                  //   decoration:
                  //       BoxDecoration(color: green, shape: BoxShape.circle),
                  // )
                ],
              ),
            ),
            onPressed: () async {
              // FacebookAnalytics().logEvent(name: "Notification",parameters: {"id":"10"});
              await Utility.pushToNext(NotificationPage(), context);
              _notificationCount = await Prefs.notificationCount;
              setState(() {});
              // DialogHelper.showUpdateDialog(context);
            },
          ),
          //: Container(),
          actions: <Widget>[
            (currentPosition == 0)
                ? IconButton(
                    icon: Icon(
                      MyFlutterApp.ic_search,
                      color: Colors.white,
                      size: 18,
                    ),
                    onPressed: () {
                      showSearch(context: context, delegate: DataSearch());
                    },
                  )
                : Container(),
            (currentPosition == 0)
                ? IconButton(
                    icon: Icon(
                      MyFlutterApp.ic_offers,
                      color: Colors.white,
                      size: 18,
                    ),
                    onPressed: () {
                      Utility.pushToNext(OfferPage(), context);
                    },
                  )
                : Container(),
            IconButton(
              icon: Icon(
                MyFlutterApp.ic_fav,
                color: Colors.white,
                size: 18,
              ),
              onPressed: () {
                Utility.pushToNext(WishListPage(), context).then((value) async {
                  int cart = await Prefs.cartCount;
                  setState(() {
                    cartCount = cart;
                  });
                });
              },
            )
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
          onTap: (position) {
            setState(() {
              currentPosition = position;
              // _currentTab = navigationList[position].title;
            });
          },
          //elevation: 6,
          type: BottomNavigationBarType.fixed,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          // selectedFontSize: 10,
          // unselectedFontSize: 8,
          currentIndex: (currentPosition > 4) ? 0 : currentPosition,
          // showSelectedLabels: true,
          selectedItemColor: Colors.red.shade500,
          unselectedItemColor: Colors.grey,
          items: _getBottomNavigationBar()),
      body: WillPopScope(
        onWillPop: onWillPop,
        child: new Container(
          color: Colors.grey.shade200,
          child: Stack(
            children: <Widget>[
              _setPage(),
              // Align(
              //   alignment: Alignment.bottomCenter,
              //   child: Container(
              //     height: 2.0,
              //     color: Colors.black12,
              //   ),
              // )
            ],
          ),
        ),
      ),
    );
  }

  _getTitle() {
    var title = '';
    switch (currentPosition) {
      case 0:
        title = '';
        break;
      case 1:
        title = 'Category';
        break;
      case 2:
        title = 'My Profile';
        break;
      case 3:
        title = 'My Bag';
        break;
      case 4:
        title = 'More';
        break;
      default:
    }
    return title;
  }

  Widget _setPage() {
    switch (currentPosition) {
      case 0:
        return BlocProvider(
          create: (BuildContext context) =>
              DashboardBloc(),
          child: HomePage(
            onRefresh: () async {
              myPrint('onrefresh of dashboard is called');
              cartCount = await Prefs.cartCount;
              setState(() {});
            },
            cartCount: cartCount,
          ),
        );
        break;
      case 1:
        return CategoryPage(
          categoryId: null,
        );
        break;
      case 2:
        return AccountPage();
        break;
      case 3:
        return CartPage(onRefresh: () async {
          cartCount = await Prefs.cartCount;
          setState(() {});
        });
        break;
      case 4:
        return MorePage();
        break;
      case 5:
        return NotificationPage();
        break;
      default:
    }
  }

  onChangePage(position) {
    setState(() {
      currentPosition = position;
    });
  }

  List<BottomNavigationBarItem> _getBottomNavigationBar() {
    List<BottomNavigationBarItem> items = [];
    for (var i = 0; i < navigationList.length; i++) {
      var item = BottomNavigationBarItem(
        label: "",
        icon: (navigationList[i].title == 'Cart')
            ? new Container(
                child: Stack(
                  children: <Widget>[
                    Center(
                        child: Icon(
                      navigationList[i].icon,
                      size: 20,
                    )),
                    (cartCount != 0)
                        ? Align(
                            alignment: Alignment.topCenter,
                            child: new Container(
                              margin: EdgeInsets.only(left: 30),
                              decoration: BoxDecoration(
                                  color: Colors.redAccent,
                                  borderRadius: BorderRadius.circular(60)),
                              child: new Container(
                                padding: EdgeInsets.only(
                                    top: 3, bottom: 3, left: 5, right: 5),
                                child: new Text(
                                  '$cartCount',
                                  style: TextStyle(
                                      fontSize: 8,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white),
                                ),
                              ),
                            ),
                          )
                        : SizedBox()
                  ],
                ),
              )
            : (navigationList[i].title == 'Home')
                ? Container(
                    child: Center(
                        child: Image.asset(
                      'assets/bikaji_logo.png',
                      fit: BoxFit.fitWidth,
                      height: 24,
                    )),
                  )
                : Icon(
                    navigationList[i].icon,
                    size: 20,
                  ),
      );
      items.add(item);
    }
    return items;
  }
}
