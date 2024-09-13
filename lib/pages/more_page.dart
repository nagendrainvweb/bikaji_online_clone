import 'package:bikaji/pages/offer_page.dart';
import 'package:bikaji/pages/poliy_list.dart';
import 'package:bikaji/pages/webview_page.dart';
import 'package:bikaji/util/custom_icons.dart';
import 'package:bikaji/util/textStyle.dart';
import 'package:bikaji/util/utility.dart';
import 'package:flutter/material.dart';
import 'package:package_info/package_info.dart';

import 'bulk_order_page.dart';
import 'contactUs_page.dart';
import 'our_stores.dart';

class MorePage extends StatefulWidget {
  @override
  _MorePageState createState() => _MorePageState();
}

class _MorePageState extends State<MorePage> {
  final _key = GlobalKey<ScaffoldState>();
  String versionName = "";

  @override
  void initState() {
    super.initState();
    setVersionName();
  }

  setVersionName() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();

    String appName = packageInfo.appName;
    String packageName = packageInfo.packageName;
   versionName = packageInfo.version;
    String buildNumber = packageInfo.buildNumber;

    myPrint("$appName  $packageName  $versionName  $buildNumber");
    setState(() {
      
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey.shade100,
      child: ListView(
        children: <Widget>[
          // Divider(),
          _buildOfferRow(MyFlutterApp.ic_offers, 'Offers', () {
            Utility.pushToNext(OfferPage(), context);
          }),
          SizedBox(
            height: 4,
          ),
          _buildOfferRow(MyFlutterApp.ic_bulk_order, 'Corporate Order', () {
            Utility.pushToNext(BulkOrderPage(), context);
          }),
          SizedBox(
            height: 4,
          ),
          _buildOfferRow(MyFlutterApp.ic_cart_1, 'Our Stores', () {
            Utility.pushToNext(Stores(), context);
          }),
          SizedBox(
            height: 4,
          ),
          _buildOfferRow(MyFlutterApp.ic_help_line, 'Contact Us', () {
            Utility.pushToNext(ContactUsPage(), context);
          }),
          // SizedBox(height: 4,),
          // _buildOfferRow(MyFlutterApp.ic_faqs,"FAQ's",(){}),
          SizedBox(
            height: 4,
          ),
          _buildOfferRow(MyFlutterApp.ic_terms, "Policies", () {
            Utility.pushToNext(PolicyListPage("Policies"), context);
          }),
          SizedBox(
            height: 4,
          ),
          _buildOfferRow(MyFlutterApp.ic_terms, "Corporate Governance Policies",
              () {
            Utility.pushToNext(
                PolicyListPage("Corporate Governance Policies"), context);
          }),
          SizedBox(
            height: 4,
          ),
          _buildOfferRow(MyFlutterApp.ic_about, 'About Us', () {
            Utility.pushToNext(
                BrowserPage('About Us', 'https://bikaji.com/about-us'),
                context);
            //openWebView('http://bikaji.club/about-us');
          }, rightText: "$versionName"),

          // SizedBox(height: 4,),
          // _buildOfferRow(MyFlutterApp.ic_terms,'Terms of Use',(){}),
          // SizedBox(height: 4,),
          //_socialMediaView(),
        ],
      ),
    );
  }

  openWebView(url) {
    // Utility.pushToNext(page, context);
  }


  Widget _buildOfferRow(var icon, var title, Function onClick,
      {String rightText = ""}) {
    return InkWell(
      onTap: onClick,
      child: new Container(
          color: Colors.white,
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: new Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              SizedBox(
                width: 5,
              ),
              Icon(
                icon,
                color: Colors.grey.shade600,
                size: 20,
              ),
              SizedBox(
                width: 20,
              ),
              Expanded(
                flex: 1,
                child: Text(
                  title,
                  style: TextStyle(
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w600,
                      fontSize: 14),
                ),
              ),
              (rightText.isNotEmpty)
                  ? Row(
                      children: [
                        Text(
                          "V $rightText",
                          style: TextStyle(
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w600,
                              fontSize: 13),
                        ),
                        SizedBox(width: 10),
                      ],
                    )
                  : Container(),
              Icon(
                Icons.chevron_right,
                color: Colors.grey,
              )
            ],
          )),
    );
  }
}
