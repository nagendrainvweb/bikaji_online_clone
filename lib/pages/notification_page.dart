import 'package:bikaji/model/NotificationData.dart';
import 'package:bikaji/pages/login_page.dart';
import 'package:bikaji/pages/notification_details.dart';
import 'package:bikaji/prefrence_util/Prefs.dart';
import 'package:bikaji/repo/Repository.dart';
import 'package:bikaji/repo/api_provider.dart';
import 'package:bikaji/util/app_helper.dart';
import 'package:bikaji/util/custom_icons.dart';
import 'package:bikaji/util/dialog_helper.dart';
import 'package:bikaji/util/textStyle.dart';
import 'package:bikaji/util/url_list.dart';
import 'package:bikaji/util/utility.dart';
import 'package:flutter/material.dart';

class NotificationPage extends StatefulWidget {
  @override
  _NotificationPageState createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> with AppHelper {
  bool isLoading = true;
  bool isLogin ;
  List<NotificationData> _notificationList;
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(45),
        child: AppBar(
          elevation: 0,
          backgroundColor: red,
          leading: IconButton(
            icon: Icon(Icons.chevron_left),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          title: Text('Notification', style: toolbarStyle),
        ),
      ),
      body: Container(
          color: Colors.grey.shade200,
          child:(isLogin==null)?Container():(isLogin)? (isLoading)
              ? Center(child: CircularProgressIndicator())
              : (_notificationList != null && _notificationList.length > 0)
                  ? ListView.builder(
                      itemCount: _notificationList.length,
                      itemBuilder: (context, index) {
                        return _notificationRow(
                            _notificationList[index], index);
                      },
                    )
                  : _getNoDataView:LoginErrorWidget(
                    title: "Please Login",
                    desc: "Let's login to see all notification !",
                    buttonText: "LOGIN",
                    icon: Icons.info_outline,
                    onBtnclicked: ()async{
                    await Utility.pushToLogin(context);
                     _setData();
                    },
                  )),
    );
  }

  @override
  void initState() {
    super.initState();
    _setData();
    //_checkInternet();
  }

  _setData() async {
    isLogin = await Prefs.isLogin;
    setState(() {
      
    });
    if (isLogin) {
      setState(() {
        isLoading = true;
      });
      try {
        final response = await ApiProvider().fetchNotifications();
        isLoading = false;
        if (response.status == UrlConstants.SUCCESS) {
          _notificationList = response.data;
        }
        setState(() {});
      } catch (e) {
        setState(() {
          isLoading = false;
        });
        myPrint(e.toString());
      }
    }
  }

  _checkInternet() async {
    bool isInternet = await Utility.getConenctionStatus();
    if (!isInternet) {
      DialogHelper().showNoInternetDialog(context);
    }
  }

  get _getNoDataView {
    return Container(
      color: Colors.white,
      child: Center(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(MyFlutterApp.ic_notification,
                  size: 60, color: Colors.grey.shade500),
              SizedBox(
                height: 30,
              ),
              Text(
                "It's quite empty here !",
                style: normalTextStyle,
              ),
              SizedBox(
                height: 8,
              ),
              Text(
                "You don't have any notification!",
                style: smallTextStyle,
              ),
              SizedBox(
                height: 20,
              ),
              InkWell(
                onTap: () {
                  Utility.pushToDashboard(context, 0);
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5), color: blackGrey),
                  child: Text(
                    'BROWSE PRODUCT',
                    style: TextStyle(
                        fontSize: 11,
                        color: Colors.white,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget stackBehindDismiss() {
    return Container(
      alignment: Alignment.centerRight,
      padding: EdgeInsets.only(right: 20.0),
      color: Colors.grey,
      child: Icon(
        Icons.delete,
        color: Colors.white,
      ),
    );
  }

  void _deleteNotification(NotificationData data, int index) async {
    myPrint(data.toJson().toString());
    progressDialog(context, "Please wait...");
    try {
      final response = await ApiProvider().deleteNotifications(data.id);
      hideProgressDialog(context);
      if (response.status == UrlConstants.SUCCESS) {
        if(!_notificationList[index].isRead){
          int notificationCount = await Prefs.notificationCount;
          Prefs.setNotificationCount((notificationCount-1));
        }
        setState(() {
          _notificationList.removeAt(index);
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(response.message),
          behavior: SnackBarBehavior.floating,
        ));
      } else {
        DialogHelper.showErrorDialog(context, "Error", response.message,
            showTitle: true);
      }
    } catch (e) {
      myPrint(e.toString());
      hideProgressDialog(context);
      setState(() {});
      DialogHelper.showErrorDialog(context, "Error", SOMETHING_WRONG_TEXT,
          showTitle: true);
    }
  }

  Widget _notificationRow(NotificationData data, int index) {
    return Dismissible(
      key: UniqueKey(),
      background: stackBehindDismiss(),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        _deleteNotification(data, index);
        // Scaffold
        //     .of(context)
        //     .showSnackBar(SnackBar(content: Text("Notification dismissed")));
      },
      //  margin: const EdgeInsets.symmetric(horizontal: 5,vertical: 0),
      child: InkWell(
        onTap: () async {
          await Utility.pushToNext(NotificationDetailPage(data: data), context);
          _setData();
        },
        child: Container(
          //padding: EdgeInsets.only(),
          color: (!data.isRead) ? Colors.grey.shade200 : Colors.white,
          child: Column(
            children: <Widget>[
              Container(
                padding:
                    EdgeInsets.only(top: 14, bottom: 14, left: 5, right: 10),
                child: Row(
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.fromLTRB(10, 5, 5, 10),
                      child: CircleAvatar(
                        backgroundColor: Colors.redAccent,
                        child: Container(
                          padding: EdgeInsets.all(10),
                          child: Text(data.title.substring(0, 1).toUpperCase(),
                              textScaleFactor: 1.2,
                              style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      flex: 1,
                      child: Container(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Row(
                              children: <Widget>[
                                Expanded(
                                  child: Text(data.title,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: grey_dark_text_color)),
                                ),

                                //  SizedBox(width: 10,),
                                //  Text('3 days ago',style: TextStyle(fontSize: 10,color: Colors.grey.shade600),)
                              ],
                            ),
                            SizedBox(
                              height: 8,
                            ),
                            Text(
                              data.content,
                              style:
                                  TextStyle(color: Colors.grey, fontSize: 14),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(
                              height: 8,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  data.date,
                                  style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey.shade600),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
              // New Container

              Container(
                height: 1,
                color: Colors.grey.shade300,
              )
            ],
          ),
        ),
      ),
    );
  }
}

class LoginErrorWidget extends StatelessWidget {
  const LoginErrorWidget({
    Key key, this.title, this.desc, this.buttonText, this.onBtnclicked, this.icon,
  }) : super(key: key);

  final title;
  final desc;
  final buttonText;
  final onBtnclicked;
  final icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Center(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(icon,
                  size: 70, color: Colors.grey.shade700),
              SizedBox(
                height: 30,
              ),
              Text(
               "Login Required !",
                style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: 18,
                    fontWeight: FontWeight.w600)
              ),
              SizedBox(
                height: 8,
              ),
              Text(
                desc,
               style: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  height: 1.2),
              textAlign: TextAlign.center,
              ),
              SizedBox(
                height: 20,
              ),
              InkWell(
                onTap: () {
                  onBtnclicked();
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5), color: blackGrey),
                  child: Text(
                    buttonText,
                    style: TextStyle(
                        fontSize: 11,
                        color: Colors.white,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
