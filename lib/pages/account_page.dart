import 'dart:convert';

import 'package:bikaji/bloc/address_bloc/AddressBloc.dart';
import 'package:bikaji/bloc/address_bloc/AddressState.dart';
import 'package:bikaji/pages/bikaji_money.dart';
import 'package:bikaji/pages/dashboard_page.dart';
import 'package:bikaji/pages/login_page.dart';
import 'package:bikaji/pages/notification_page.dart';
import 'package:bikaji/prefrence_util/Prefs.dart';
import 'package:bikaji/repo/Repository.dart';
import 'package:bikaji/repo/api_provider.dart';
import 'package:bikaji/util/constants.dart';
import 'package:bikaji/util/custom_icons.dart';
import 'package:bikaji/util/dialog_helper.dart';
import 'package:bikaji/util/utility.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'addressList_page.dart';
import 'my_account.dart';
import 'orderPage.dart';
import 'wishList_page.dart';

class AccountPage extends StatefulWidget {
  @override
  _AccountPageState createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  final _mainKey = GlobalKey();
  var name = '';
  var _image = '';
  bool isLogin ;

  @override
  void initState() {
    super.initState();
    setData();
  }

  setData() async {
    isLogin = await Prefs.isLogin;
     setState(() {
      
    });
    if (isLogin) {
      final firstName = await Prefs.firstName;
      final lastName = await Prefs.lastName;
      _image = await Prefs.imageUrl;
      myPrint("image is :" + _image);
      setState(() {
        //name = '$firstName  $lastName';
        name = firstName.isEmpty ? "Customer Name" : firstName + " " + lastName;
        //_image  = base64Decode(image);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        key: _mainKey,
        child:(isLogin==null)?Container(): (isLogin)
            ? Stack(
                children: <Widget>[
                  _getBackView,
                  _getTopView,
                ],
              )
            : LoginErrorWidget(
                title: "Please Login",
                desc:
                    "Let's Login to Explore Your Account, Address and Past Orders Information !",
                icon: Icons.info_outline,
                buttonText: "LOGIN",
                onBtnclicked: () async {
                  await Utility.pushToLogin(context);
                  setData();
                },
              ));
  }

  get _getTopView {
    var topheight = MediaQuery.of(context).size.height * 0.3;
    var bottomheight = MediaQuery.of(context).size.height * 0.7;
    //  myPrint(_mainKey.currentContext.size.height);
    return Container(
      //  margin: const EdgeInsets.only(left: 15,right: 15,bottom: 10,top: 10),
      child: ListView(
        shrinkWrap: true,
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Container(
                height: 220,
                child: Stack(
                  children: <Widget>[
                    Container(
                      margin: const EdgeInsets.only(
                          left: 15, right: 15, bottom: 10, top: 85),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.white),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            new Container(
                              margin: EdgeInsets.only(top: 40),
                              height: 110,
                              width: 110,
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: whiteGrey,
                                  image: DecorationImage(
                                      image: (_image == "")
                                          ? AssetImage(
                                              'assets/user_pic.png',
                                            )
                                          : NetworkImage(_image),
                                      fit: BoxFit.cover),
                                  border: Border.all(
                                      color: Colors.grey.shade300,
                                      style: BorderStyle.solid,
                                      width: 2)),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 8,
                        ),
                        Text(
                          name,
                          style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 16,
                              fontWeight: FontWeight.w600),
                        ),
                        // SizedBox(
                        //   height: 3,
                        // ),
                        // Text(
                        //   'city, state',
                        //   style: TextStyle(
                        //     color: Colors.grey.shade500,
                        //     fontSize: 11,
                        //   ),
                        // ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                child: _bottomView(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  get _getBottomOptions {
    return Column(
      children: <Widget>[_getOptionView('My Profile', () {})],
    );
  }

  _getOptionView(var title, Function onClick) {
    return Container(
      child: Row(
        children: <Widget>[Icon(Icons.person_outline)],
      ),
    );
  }

  get _getBackView {
    return Container(
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          Expanded(
            flex: 1,
            child: Container(
              color: Colors.grey.shade300,
            ),
          ),
          Expanded(
            flex: 3,
            child: Container(
              color: Colors.grey.shade100,
            ),
          )
        ],
      ),
    );
  }

  Widget _bottomView() {
    return new Container(
      child: new Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          InkWell(
              onTap: () {
                Utility.pushToNext(
                        MyAccountPage(
                          showAppBar: true,
                        ),
                        context)
                    .then((value) async {
                  setData();
                });
              },
              child: _singleAccount(MyFlutterApp.ic_profile, "My Account",
                  Colors.grey.shade500, Colors.grey.shade700)),
          Container(
            height: 1,
            color: Colors.grey.shade300,
          ),
          InkWell(
              onTap: () {
                Utility.pushToNext(OrderPage(), context);
              },
              child: _singleAccount(MyFlutterApp.ic_past_orders, "Past Orders",
                  Colors.grey.shade500, Colors.grey.shade700)),
          Container(
            height: 1,
            color: Colors.grey.shade300,
          ),
          InkWell(
              onTap: () {
                Utility.pushToNext(
                    BlocProvider(
                      create: (context) =>
                          AddressBloc(AddressLoadingState()),
                      child: AddressListPage(),
                    ),
                    context);
              },
              child: _singleAccount(MyFlutterApp.ic_shipping, "My Addresses",
                  Colors.grey.shade500, Colors.grey.shade700)),
          Container(
            height: 1,
            color: Colors.grey.shade300,
          ),
          InkWell(
              onTap: () {
                Utility.pushToNext(WishListPage(), context);
              },
              child: _singleAccount(MyFlutterApp.ic_fav, "Wishlist",
                  Colors.grey.shade500, Colors.grey.shade700)),
          Container(
            height: 1,
            color: Colors.grey.shade300,
          ),
          // InkWell(
          //     onTap: () {
          //       Utility.pushToNext(BikajiWallet(), context);
          //     },
          //     child: _singleAccount(MyFlutterApp.ic_wallet, "Bikaji Money",
          //         Colors.grey.shade500, Colors.grey.shade700)),
          SizedBox(
            height: 25,
          ),
          InkWell(
            onTap: () {
              DialogHelper.showLogoutDialog(context, () async {
                SharedPreferences sp = await SharedPreferences.getInstance();
                sp.setBool(Constants.isLogin, false);
                Prefs.clear();
                isRefreshed = false;
                Utility.pushToDashboard(context, 0);
                // Navigator.pushAndRemoveUntil(
                //   context,
                //   CupertinoPageRoute(builder: (context) {
                //     return LoginPage();
                //   }),
                //   ModalRoute.withName('/DashboardPage'),
                // );
              });
            },
            child: Container(
              margin: EdgeInsets.only(left: 5, right: 5),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                    color: blackGrey, borderRadius: BorderRadius.circular(2)),
                child: Padding(
                  padding: const EdgeInsets.only(top: 15.0, bottom: 15),
                  child: new Text(
                    'LOG OUT',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
          ),
          // SizedBox(
          //   height: 15,
          // ),
        ],
      ),
    );
  }

  Widget _singleAccount(var icon, var title, var color, var textColor) {
    return Container(
        padding: const EdgeInsets.all(15),
        color: Colors.white,
        child: Row(
          children: <Widget>[
            SizedBox(
              width: 10,
            ),
            Icon(
              icon,
              color: Colors.grey.shade700,
              size: (title == "My Account") ? 18 : 18,
            ),
            SizedBox(
              width: 20,
            ),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                    color: textColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w600),
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: color,
              size: 18,
            )
          ],
        )
        // ListTile(
        //   isThreeLine: false,
        //   enabled: true,
        //   leading: Icon(icon),
        //   title: new Text(
        //     title,
        //     style: TextStyle(fontSize: 13),
        //   ),
        //   trailing: Icon(Icons.chevron_right),
        // ),
        );
  }
}
