import 'dart:convert';

import 'package:bikaji/model/OfferData.dart';
import 'package:bikaji/model/OfferResponse.dart';
import 'package:bikaji/pages/home.dart';
import 'package:bikaji/prefrence_util/Prefs.dart';
import 'package:bikaji/repo/Repository.dart';
import 'package:bikaji/repo/api_provider.dart';
import 'package:bikaji/util/custom_icons.dart';
import 'package:bikaji/util/textStyle.dart';
import 'package:bikaji/util/utility.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share/share.dart';

import 'coupon_page.dart';

class OfferPage extends StatefulWidget {
  @override
  _OfferPageState createState() => _OfferPageState();
}

class _OfferPageState extends State<OfferPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  List<Offers> _offerList;
  List<OffersImg> _offerImgList;
  bool isError = false;

  @override
  void initState() {
    _setData();
    super.initState();
  }

  _setData() async {
    //_fetchOffers();
    var offerResponse = await Prefs.offerResponse;
    if (offerResponse.isEmpty) {
      _fetchOffers();
    } else {
      final offerJson = json.decode(offerResponse);
      final offer = OfferResponse.fromJson(offerJson['data']);
      setState(() {
        _offerList = offer.offers;
        _offerImgList = offer.offersImg;
      });
    }
  }

  _fetchOffers() async {
    setState(() {
      isError = false;
    });
    try {
      final response =
          await ApiProvider().fetchOffers();
      setState(() {
        _offerList = response.data.offers;
        _offerImgList = response.data.offersImg;
        isError = false;
      });
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
          backgroundColor: Colors.red.shade500,
          leading: IconButton(
            icon: Icon(Icons.chevron_left),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          title: Text(
            'Offers',
            style: toolbarStyle,
          ),
        ),
      ),
      body: Container(
        child: (isError)
            ? HomeErrorWidget(
                message: "",
                onRetryCliked: () {
                  _fetchOffers();
                })
            : (_offerImgList != null)
                ? Container(
                    child: ListView.builder(
                      itemCount: _offerImgList.length,
                      itemBuilder: (BuildContext context, int index) {
                        return Container(
                          child: Column(
                            children: <Widget>[
                              Container(
                                margin: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 5),
                                child: _getOfferImage(_offerImgList[index]),
                                // _getCouponRow(_offerList[index]),
                              ),
                              Container(
                                height: 1,
                                color: Colors.grey[200],
                              )
                            ],
                          ),
                        );
                      },
                    ),
                  )
                : Center(child: CircularProgressIndicator()),
      ),
    );
  }

  _getOfferImage(OffersImg offersImg){
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: CachedNetworkImage(imageUrl: offersImg.bannerUrl,fit: BoxFit.cover,),
    );
  }

  _getCouponRow(Offers offerData) {
    var code = offerData.name;
    var discountAmount = double.parse(offerData.discountAmount).toStringAsFixed(0);
    var fromAmount = (offerData.fromAmount != null)?'$rupee${offerData.fromAmount}':"0";
    var toAmount = (offerData.toAmount != 'null')?' - $rupee${offerData.toAmount}':"";
    var percentange = (offerData.discountType == "by_percent")?"%":"";
    var title = "${discountAmount}$percentange OFF on order above  $fromAmount $toAmount";
    var desc = "Offer only Applicable from ${offerData.fromDate} to ${offerData.toDate} ";

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
                    // _getApplyBtn,
                  ],
                ),
              ),
              _getShortDesc(title),
              SizedBox(
                height: 3,
              ),
              Container(
                child: Row(
                  children: <Widget>[
                    Text(
                      'T&C : ',
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(
                      width: 2,
                    ),
                    _getLongDesc(desc),
                  ],
                ),
              )

              // _getViewDetails(offerData),
            ],
          ),
        ),
      ],
    );
  }

  _getViewDetails(var offerData) {
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

  _getShortDesc(var title) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 6),
      child: Text(
        title,
        style: TextStyle(
            color: Colors.grey.shade700,
            fontWeight: FontWeight.w500,
            fontSize: 13),
      ),
    );
  }

  _getLongDesc(var desc) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 1),
        child: Text(
         desc,
          style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
        ),
      ),
    );
  }

  _getCouponCode(var code) {
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

  get _getApplyBtn {
    return TextButton(
      child: Text('APPLY',
          style:
              TextStyle(color: red, fontSize: 13, fontWeight: FontWeight.w600)),
      onPressed: () {
        Navigator.pop(context);
      },
    );
  }

  // _getOfferRow(int index) {
  //   return Container(
  //     child: Card(
  //       child: Container(
  //         padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
  //         child: Column(
  //           children: <Widget>[
  //             Container(
  //               child: Row(
  //                 children: <Widget>[
  //                   Expanded(
  //                     child: Text('10% off on orders above $rupee 500'),
  //                   ),
  //                   InkWell(
  //                     onTap: (){
  //                       Clipboard.setData(new ClipboardData(text: "BIKAJI500"));
  //                       var snackBar = SnackBar(
  //                         behavior: SnackBarBehavior.floating,
  //                         content: Text('Copied to clipboard'),
  //                       );
  //                       _scaffoldKey.currentState.showSnackBar(snackBar);

  //                     },
  //                     child: Container(
  //                       color: red,
  //                       padding: const EdgeInsets.symmetric(
  //                           horizontal: 15, vertical: 5),
  //                       child: Text(
  //                         'BIKAJI500',
  //                         style: TextStyle(
  //                             color: Colors.white,
  //                             fontSize: 10,
  //                             fontWeight: FontWeight.w600),
  //                       ),
  //                     ),
  //                   )
  //                 ],
  //               ),
  //             ),
  //             SizedBox(
  //               height: 10,
  //             ),
  //             Container(
  //               height: 1,
  //               color: Colors.grey.shade300,
  //             ),
  //             SizedBox(
  //               height: 10,
  //             ),
  //             Row(
  //               children: <Widget>[
  //                 Expanded(
  //                     child: Text(
  //                   "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book.",
  //                   style:extraSmallTextStyle,
  //                 )),
  //                 SizedBox(
  //                   height: 30,
  //                 ),
  //                 InkWell(
  //                   child: Row(
  //                     mainAxisAlignment: MainAxisAlignment.end,
  //                     children: <Widget>[
  //                       Icon(
  //                         MyFlutterApp.ic_share,
  //                         size: 12,
  //                       ),
  //                     ],
  //                   ),
  //                   onTap: () {
  //                     Share.share('check out my website https://example.com');
  //                   },
  //                 )
  //               ],
  //             )
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }
}
