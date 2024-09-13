import 'package:bikaji/model/NotificationData.dart';
import 'package:bikaji/prefrence_util/Prefs.dart';
import 'package:bikaji/repo/api_provider.dart';
import 'package:bikaji/util/textStyle.dart';
import 'package:bikaji/util/url_list.dart';
import 'package:bikaji/util/utility.dart';
import 'package:flutter/material.dart';

class NotificationDetailPage extends StatefulWidget {
  final NotificationData data;
  NotificationDetailPage({@required this.data});
  @override
  _NotificationDetailPageState createState() => _NotificationDetailPageState();
}

class _NotificationDetailPageState extends State<NotificationDetailPage> {
  @override
  void initState() {
    initlize();
    super.initState();
  }

  void _readNotification(NotificationData data) async {
    try {
      final response = await ApiProvider().readNotifications(data.id);
      if (response.status == UrlConstants.SUCCESS) {
       if(!widget.data.isRead){
          int notificationCount = await Prefs.notificationCount;
          Prefs.setNotificationCount((notificationCount-1));
        }
      } else {
        myPrint(response.message);
      }
    } catch (e) {
      myPrint(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(45),
        child: AppBar(
          elevation: 0,
          backgroundColor: Colors.red.shade500,
          leading: IconButton(
            icon: Icon(Icons.chevron_left),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          title: Text(
            'Details',
            style: toolbarStyle,
          ),
        ),
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(widget.data.title, textScaleFactor: 1.2),
            SizedBox(height: 7),
            Text(widget.data.date,
                textScaleFactor: 0.8,
                style: TextStyle(color: grey_dark_text_color)),
            SizedBox(height: 10),
            Text(widget.data.content,
                textScaleFactor: 1,
                style: TextStyle(color: grey_dark_text_color)),
          ],
        ),
      ),
    );
  }

  void initlize() async {
    final id = await Prefs.id;
    if (!widget.data.read_users.contains(id)) {
      _readNotification(widget.data);
    }
  }
}
