import 'dart:async';
import 'dart:io';

import 'package:bikaji/model/ProductData.dart';
import 'package:bikaji/pages/dashboard_page.dart';
import 'package:bikaji/pages/introPage.dart';
import 'package:bikaji/pages/login_demo.dart';
import 'package:bikaji/pages/login_page.dart';
import 'package:bikaji/pages/productDetails.dart';
import 'package:bikaji/pages/splash_page.dart';
import 'package:bikaji/repo/api_provider.dart';
import 'package:bikaji/util/app_helper.dart';
import 'package:bikaji/util/constants.dart';
import 'package:bikaji/util/utility.dart';
// import 'package:firebase_analytics/firebase_analytics.dart';
// import 'package:firebase_analytics/observer.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uni_links/uni_links.dart';
import 'package:flutter/services.dart';

/// Create a [AndroidNotificationChannel] for heads up notifications
const AndroidNotificationChannel channel = AndroidNotificationChannel(
  'high_importance_channel', // id
  'High Importance Notifications', 
  description:
  'This channel is used for important notifications.', // description
  importance: Importance.high,
);

/// Initialize the [FlutterLocalNotificationsPlugin] package.
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
   await Firebase.initializeApp();
   FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

     /// Create an Android Notification Channel.
  ///
  /// We use this channel in the `AndroidManifest.xml` file to override the
  /// default FCM channel to enable heads up notifications.
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  /// Update the iOS foreground notification presentation options to allow
  /// heads up notifications.
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );


  SharedPreferences sp = await SharedPreferences.getInstance();
  bool isLogin = sp.getBool(Constants.isLogin) ?? false;
  runApp(
      Bikaji(isLogin));
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp();
  print("Handling a background message: ${message.messageId}");
}

class Bikaji extends StatefulWidget {
  var isLogin;
  Bikaji(this.isLogin);
  @override
  _BikajiState createState() => _BikajiState();
}

class _BikajiState extends State<Bikaji> {
  final routies = {
    '/SplashPage': (BuildContext context) => SplashPage(),
    '/LoginPage': (BuildContext context) => LoginPage(),
    '/DashboardPage': (BuildContext context) => DashBoardPage(),
  };

  @override
  Widget build(BuildContext context) {
    FirebaseAnalytics analytics = FirebaseAnalytics.instance;
    return MaterialApp(
      title: 'Bikaji',
      theme: ThemeData(
        fontFamily: 'Roboto',
        primarySwatch: Colors.red,
        primaryColor: Colors.red.shade400,
        accentColor: Colors.red.shade300,

        //  pageTransitionsTheme: PageTransitionsTheme(builders: {TargetPlatform.android: CupertinoPageTransitionsBuilder(),}),
      ),
      navigatorObservers: [
        FirebaseAnalyticsObserver(analytics: analytics),
      ],
      debugShowCheckedModeBanner: false,
      home: DashBoardPage(),
      //(widget.isLogin) ? DashBoardPage() : LoginPage(),
      routes: routies,
    );
  }
}
