import 'package:bikaji/model/OfferResponse.dart';
import 'package:bikaji/pages/home.dart';
import 'package:bikaji/repo/Repository.dart';
import 'package:bikaji/repo/api_provider.dart';
import 'package:bikaji/util/custom_icons.dart';
import 'package:bikaji/util/dialog_helper.dart';
import 'package:bikaji/util/url_list.dart';
import 'package:bikaji/util/utility.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CouponPage extends StatefulWidget {
  @override
  _CouponPageState createState() => _CouponPageState();
}

class _CouponPageState extends State<CouponPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _couponController = TextEditingController();
  var focusNode = new FocusNode();
  List<Offers> _offerlist;
  bool isError = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: 500), () {
      FocusScope.of(context).requestFocus(focusNode);
    });
    _setData();
  }

  _setData() async {
    setState(() {
      isError = false;
    });
    try {
      final response =
          await ApiProvider().fetchCoupons();
      if (response.status == UrlConstants.SUCCESS) {
        setState(() {
          _offerlist = response.data;
          isError = false;
        });
      } else {
        setState(() {
          isError = true;
        });
        DialogHelper.showErrorDialog(context, "Error", response.message,
            showTitle: true, onOkClicked: () {
              Navigator.pop(context);
              Navigator.pop(context);
            });
      }
    } catch (e) {
      myPrint(e.toString());
      setState(() {
        isError = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(45),
        child: AppBar(
          elevation: 0,
          backgroundColor: white,
          leading: IconButton(
            icon: Icon(
              Icons.chevron_left,
              color: red,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
      ),
      body: Container(
        color: Colors.grey.shade100,
        child: (isError)
            ? HomeErrorWidget(
                message: "",
                onRetryCliked: () {
                  _setData();
                })
            : (_offerlist != null)
                ? Column(children: <Widget>[
                    // _getTextFeild,
                    // SizedBox(
                    //   height: 10,
                    // ),
                    _getCouponList
                  ])
                : Center(child: CircularProgressIndicator()),
      ),
    );
  }

  get _getTextFeild {
    return Container(
      color: white,
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Container(
                child: Container(
              child: TextField(
                  controller: _couponController,
                  focusNode: focusNode,
                  keyboardType: TextInputType.text,
                  textCapitalization: TextCapitalization.characters,
                  textAlign: TextAlign.start,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.symmetric(vertical: 2),
                    hintText: 'Enter coupon code',
                    hintStyle:
                        TextStyle(color: Colors.grey.shade800, fontSize: 13),
                    border: InputBorder.none,
                  )),
            )),
          ),
          InkWell(
            onTap: () {
              if (_couponController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text('Please enter coupon code'),
                ));
              } else {
                Navigator.pop(context);
              }
            },
            child: Text(
              'APPLY',
              style: TextStyle(color: red, fontSize: 12),
            ),
          )
        ],
      ),
    );
  }

  get _getCouponList {
    return Expanded(
      child: Container(
        color: white,
        padding: EdgeInsets.only(left: 20, right: 5),
        child: ListView.builder(
          itemCount: _offerlist.length,
          itemBuilder: (context, index) {
            return Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  (index == 0)
                      ? Container(
                          padding: EdgeInsets.symmetric(vertical: 20),
                          child: Text('Available Coupons',
                              style: TextStyle(
                                  fontSize: 17, fontWeight: FontWeight.w600)),
                        )
                      : Container(),
                  _getCouponRow(_offerlist[index]),
                  Container(
                    height: 2,
                    color: Colors.grey[100],
                  )
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  _getCouponRow(Offers offerData) {
    var code = offerData.name;
    var discountAmount =
        double.parse(offerData.discountAmount).toStringAsFixed(0);
    var fromAmount = (offerData.fromAmount != "")
        ? 'above $rupee${offerData.fromAmount}'
        : "";
    var toAmount =
        (offerData.toAmount != "") ? ' to - $rupee${offerData.toAmount}' : "";
    var percentange = (offerData.discountType == "by_percent") ? "%" : "";
    var title =
        "${discountAmount}$percentange OFF on order $fromAmount $toAmount";
    var desc =
        "Offer only Applicable from ${offerData.fromDate} ${offerData.toDate} ";
    var perUser =
        "Offer is Valid only ${offerData.usesPerCustomer} times per user ";
    return Column(
      children: <Widget>[
        Container(
          padding: EdgeInsets.only(top: 10, bottom: 10, right: 5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    _getCouponCode(code),
                    _getApplyBtn(code),
                  ],
                ),
              ),
              _getShortDesc(title),
              _getLongDesc(desc),
              _getLongDesc(perUser),
              // _getViewDetails,
            ],
          ),
        ),
      ],
    );
  }

  get _getViewDetails {
    return InkWell(
      onTap: () {
        showModalBottomSheet(
            context: context,
            builder: (context) {
              return OfferDetails(onClick: () {
                Clipboard.setData(new ClipboardData(text: "BIKAJI50"));
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text('Coupon Copied!'),
                  behavior: SnackBarBehavior.floating,
                ));
              });
            });
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 7),
        child: Text(
          'View Details',
          style: TextStyle(
              color: Colors.blue[700],
              fontWeight: FontWeight.w600,
              fontSize: 12),
        ),
      ),
    );
  }

  _getShortDesc(String title) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 5),
      child: Text(
        title,
        style: TextStyle(color: blackGrey, fontWeight: FontWeight.w500),
      ),
    );
  }

  _getLongDesc(String desc) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 1),
      child: Text(
        desc,
        style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
      ),
    );
  }

  _getCouponCode(String code) {
    return Container(
      child: DottedBorder(
        color: couponYellowDark,
        dashPattern: [8, 4],
        strokeWidth: 1,
        child: Container(
            padding: EdgeInsets.symmetric(horizontal: 5, vertical: 2),
            color: couponYellow,
            child: Text(
              code,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            )),
      ),
    );
  }

  _getApplyBtn(String code) {
    return TextButton(
      child: Text('APPLY',
          style:
              TextStyle(color: red, fontSize: 13, fontWeight: FontWeight.w600)),
      onPressed: () {
        Navigator.pop(context, code);
      },
    );
  }
}

class OfferDetails extends StatefulWidget {
  Function onClick;

  OfferDetails({this.onClick});
  @override
  _OfferDetailsState createState() => _OfferDetailsState();
}

class _OfferDetailsState extends State<OfferDetails> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          IconButton(
            icon: Icon(Icons.expand_more, color: red),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          _getContent,
        ],
      ),
    );
  }

  get _getContent {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _getShortDesc,
          _getLongDesc,
          SizedBox(
            height: 20,
          ),
          _getconditions("Maximum instant discount of ${rupee}100."),
          _getconditions("Applicable only on select items."),
          _getconditions("Applicable maximum 3 times a day."),
          _getconditions("Other T&C's may apply."),
          SizedBox(
            height: 30,
          ),
          _getcouponBtn,
          SizedBox(
            height: 10,
          )
        ],
      ),
    );
  }

  get _getcouponBtn {
    return InkWell(
      onTap: widget.onClick,
      child: DottedBorder(
        radius: Radius.circular(10),
        color: green,
        dashPattern: [4, 2],
        strokeWidth: 1,
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: 10),
          child: Column(
            children: <Widget>[
              Text('BIKAJI50',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: green,
                      fontSize: 17,
                      fontWeight: FontWeight.w500,
                      wordSpacing: 2)),
              SizedBox(
                height: 3,
              ),
              Text('TAP TO COPY',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: green, fontSize: 12, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ),
    );
  }

  _getconditions(var text) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: <Widget>[
          Icon(
            MyFlutterApp.check,
            color: green,
            size: 15,
          ),
          SizedBox(
            width: 10,
          ),
          Text(
            text,
            style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700),
          ),
        ],
      ),
    );
  }

  get _getShortDesc {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 5),
      child: Text(
        '20% OFF up to $rupee 50',
        style: TextStyle(
            color: blackGrey, fontWeight: FontWeight.w500, fontSize: 17),
      ),
    );
  }

  get _getLongDesc {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 1),
      child: Text(
        'On orders of $rupee 99 and above. Valid once per user every month.',
        style: TextStyle(color: Colors.grey.shade600, fontSize: 15),
      ),
    );
  }
}
