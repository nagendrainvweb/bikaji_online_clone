import 'dart:convert';

import 'package:bikaji/model/OfferResponse.dart';
import 'package:bikaji/model/product.dart';
import 'package:bikaji/pages/check_out.dart';
import 'package:bikaji/pages/home.dart';
import 'package:bikaji/pages/notification_page.dart';
import 'package:bikaji/pages/productDetails.dart';
import 'package:bikaji/prefrence_util/Prefs.dart';
import 'package:bikaji/repo/api_provider.dart';
import 'package:bikaji/util/app_helper.dart';
import 'package:bikaji/util/constants.dart';
import 'package:bikaji/util/custom_icons.dart';
import 'package:bikaji/util/dialog_helper.dart';
import 'package:bikaji/util/textStyle.dart';
import 'package:bikaji/util/url_list.dart';
import 'package:bikaji/util/utility.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'coupon_page.dart';

class CartPage extends StatefulWidget {
  Function onRefresh;
  CartPage({this.onRefresh});
  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> with AppHelper {
  var isChecked = false;
  var isGiftwarp = false;
  int totalAmount = 0;
  final _couponController = TextEditingController();
  double discountAmount = 0.00;
  double payingAmount = 0.00;
  double discount = 0.00;
  List<Product> cartList;
  bool isFailed = false;
  Offers _apppliedCoupon;
  List<Offers> _offerList;
  bool isLogin;

  @override
  void initState() {
    setData();
    super.initState();
  }

  setData() async {
    isLogin = await Prefs.isLogin;
    setState(() {});
    if (isLogin) {
      getCartList();
      _setOfferList();
    }
  }

  _setOfferList() async {
    var offerResponse = await Prefs.offerResponse;
    final offerJson = json.decode(offerResponse);
    final offer = OfferResponse.fromJson(offerJson['data']);
    setState(() {
      _offerList = offer.offers;
      _offerList.sort((a, b) {
        int aFrom = int.parse(a.fromAmount.toString());
        int bFrom = int.parse(b.fromAmount.toString());
        return bFrom.compareTo(aFrom);
      });
    });
  }

  getCartList() async {
    discountAmount = 0;
    totalAmount = 0;
    try {
      final resposne = await ApiProvider().fetchCartDetails();
      if (resposne.status == UrlConstants.SUCCESS) {
        setState(() {
          isFailed = false;
          cartList = resposne.data;
          //cartList[0].isInStock = false;
          Prefs.setCartCount(cartList.length);
          widget.onRefresh();
          for (var product in cartList) {
            if (product.isInStock) {
              totalAmount = totalAmount + product.amount;
            }
          }
          if (cartList.length > 0) {
            _calculateDiscount();
          }
          // _setDiscountAmount();
        });
      } else {
        setState(() {
          isFailed = true;
        });
      }
    } catch (e) {
      myPrint(e.toString());
      setState(() {
        isFailed = true;
      });
    }
  }

  _calculateDiscount() async {
    progressDialog(context, "Calculating Discount...");
    String offer_title = (_apppliedCoupon != null)
        ? (!_apppliedCoupon.isOffer)
            ? _apppliedCoupon.cname
            : ""
        : "";
    try {
      final response = await ApiProvider()
          .updateCart(cartList, offer_title, totalAmount.toString());
      hideProgressDialog(context);
      if (response.status == UrlConstants.SUCCESS) {
        setState(() {
          totalAmount = int.parse(response.data.totalAmount);
          discountAmount = response.data.discountAmount.toDouble();
          discountAmount = (discountAmount >= totalAmount)
              ? totalAmount.toDouble()
              : discountAmount;
          discount = ((response.data.discountAmount.toDouble() /
              double.parse(response.data.totalAmount)));
          _apppliedCoupon = Offers(
              name: response.data.offerName,
              discountType: response.data.discountType,
              cname: response.data.coupon_name,
              description: response.data.coupon_description,
              isOffer: offer_title.isEmpty);
          payingAmount = double.parse(response.data.payingAmount.toString());
        });
      } else {
        Utility.showScaffoldSnackBar(context, SOMETHING_WRONG_TEXT, null, true);
      }
    } catch (e) {
      myPrint(e.toString());
      hideProgressDialog(context);
    }
  }

  _updateCartData() async {
    progressDialog(context, "Please wait...");
    String offer_title = (_apppliedCoupon != null)
        ? (!_apppliedCoupon.isOffer)
            ? _apppliedCoupon.cname
            : ""
        : "";
    try {
      final response = await ApiProvider()
          .updateCart(cartList, offer_title, totalAmount.toString());
      hideProgressDialog(context);
      if (response.status == UrlConstants.SUCCESS) {
        setState(() {
          totalAmount = int.parse(response.data.totalAmount);
          discountAmount = response.data.discountAmount.toDouble();
          discountAmount = (discountAmount >= totalAmount)
              ? totalAmount.toDouble()
              : discountAmount;
          discount = ((response.data.discountAmount.toDouble() /
              double.parse(response.data.totalAmount)));
          _apppliedCoupon = Offers(
              name: response.data.offerName,
              discountType: response.data.discountType,
              cname: response.data.coupon_name,
              description: response.data.coupon_description,
              isOffer: offer_title.isEmpty);
          payingAmount = double.parse(response.data.payingAmount.toString());
        });
        final type = (_apppliedCoupon != null)
            ? (_apppliedCoupon.isOffer)
                ? Constants.OFFER
                : Constants.COUPON
            : "";
        // if (response.data.payingAmount.toInt() < minimumOrderValue) {
        //   Utility.showScaffoldSnackBar(
        //       context,
        //       'Minimum order value should be greater then $rupee $minimumOrderValue',
        //       null,
        //       true);
        // }
        // if (response.data.payingAmount.toInt() > maximumOrderValue) {
        //   Utility.showScaffoldSnackBar(
        //       context,
        //       'Maximum order value should not be greater then $rupee $maximumOrderValue',
        //       null,
        //       true);
        // }

        if (response.data.isValid) {
          //  myPrint(_apppliedCoupon.toJson());
          final value = await Utility.pushToNext(
              CheckoutPage(
                cartList: cartList,
                payingAmount: payingAmount,
                totalAmount: double.parse(response.data.totalAmount),
                discountAmount: discountAmount,
                paytmText: response.data.paytmText,
                discount: ((response.data.discountAmount.toDouble() /
                            double.parse(response.data.totalAmount)) *
                        100)
                    .roundToDouble(),
                offer_type: type,
                offers: _apppliedCoupon,
              ),
              context);
          getCartList();
        } else {
          Utility.showScaffoldSnackBar(
              context, '${response.data.payMsg}', null, true);
        }
      } else {
        Utility.showScaffoldSnackBar(context, SOMETHING_WRONG_TEXT, null, true);
      }
    } catch (e) {
      myPrint(e.toString());
      hideProgressDialog(context);
    }
  }

  _setDiscountAmount() {
    totalAmount = 0;
    for (var product in cartList) {
      if (product.isInStock) {
        totalAmount = totalAmount + product.amount;
      }
    }
    for (var offer in _offerList) {
      int fromAmount = int.parse(offer.fromAmount.toString());
      int toAmount = (offer.toAmount != 'null')
          ? int.parse(offer.toAmount.toString())
          : maximumOrderValue;
      double discountOfferValue = double.parse(offer.discountAmount);
      // myPrint('discount: $discountOfferValue');
      if (totalAmount > fromAmount && totalAmount < toAmount) {
        discount = (offer.discountType == 'by_percent')
            ? (discountOfferValue / 100)
            : 0.00;
        setState(() {
          discountAmount = (totalAmount) * discount;
          payingAmount = totalAmount - discountAmount;
          if (payingAmount < 0) {
            payingAmount = 0;
          }
          _apppliedCoupon = offer;
        });

        //myPrint('discount: $discount, discountAmount:$discountAmount');
        return;
      }
    }
  }

  _verifyCouponCode() async {
    progressDialog(context, "Please wait...");
    try {
      final code = _couponController.text;
      final response =
          await ApiProvider().verifyCoupons(code, totalAmount.toString());
      hideProgressDialog(context);
      _couponController.text = "";
      if (response.status == UrlConstants.SUCCESS) {
        setState(() {
          _apppliedCoupon = response.data;
          if (totalAmount > minimumOrderValue) {
            discount = double.parse(_apppliedCoupon.discount);
            discountAmount = double.parse(_apppliedCoupon.discountAmount);
            if (discountAmount > totalAmount) {
              discountAmount = totalAmount.toDouble();
            } else {
              payingAmount = totalAmount - discountAmount;
            }
          }
        });
        if ((_apppliedCoupon.cname != null ||
                _apppliedCoupon.cname.isNotEmpty) &&
            (_apppliedCoupon.description != null ||
                _apppliedCoupon.description.isNotEmpty)) {
          DialogHelper.showErrorDialog(
              context, _apppliedCoupon.cname, _apppliedCoupon.description,
              showTitle: true, onOkClicked: () {
            Navigator.pop(context);
          });
        }
        _calculateDiscount();
      } else {
        setState(() {
          _apppliedCoupon = null;

          _calculateDiscount();
          //_setDiscountAmount();
        });
        Utility.showScaffoldSnackBar(context, response.message, null, true);
      }
    } catch (e) {
      myPrint(e.toString());
      setState(() {
        _apppliedCoupon = null;
      });
      hideProgressDialog(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        color: Colors.grey.shade100,
        child: (isLogin == null)
            ? Container()
            : (isLogin)
                ? (isFailed)
                    ? HomeErrorWidget(
                        message: SOMETHING_WRONG_TEXT,
                        onRetryCliked: () {
                          getCartList();
                        })
                    : (cartList != null)
                        ? (cartList.length > 0)
                            ? _getCartView
                            : _getEmptyView
                        : Center(child: CircularProgressIndicator())
                : LoginErrorWidget(
                    title: "Please Login",
                    desc: "Let's Login to Explore Your Shopping Cart !",
                    icon: Icons.info_outline,
                    buttonText: "LOGIN",
                    onBtnclicked: () async {
                      await Utility.pushToLogin(context);
                      setData();
                    },
                  ));
  }

  get _getEmptyView {
    return Container(
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Image.asset(
              'assets/empty_bag.png',
              height: 250,
            ),
            SizedBox(
              height: 15,
            ),
            Text('Your cart is empty',
                style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: 18,
                    fontWeight: FontWeight.w600)),
            SizedBox(
              height: 10,
            ),
            Text(
              "You have no items in your shopping cart.\nLets's go buy something!",
              style: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  height: 1.2),
              textAlign: TextAlign.center,
            ),
            SizedBox(
              height: 24,
            ),
            InkWell(
              onTap: () {
                Utility.pushToDashboard(context, 0);
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 18, vertical: 12),
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
    );
  }

  get _getCartView {
    return Column(
      children: <Widget>[
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async {
              await getCartList();
              return true;
            },
            child: ListView(
              children: <Widget>[
                Column(
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    _buildTopCount(),
                    SizedBox(
                      height: 8,
                    ),
                    _buildProductList(),
                    _getOptionText,
                    SizedBox(
                      height: 2,
                    ),
                    _getOtions,
                    _getCouponAppliedText,
                    //_getOffers,

                    // SizedBox(height: 2,),
                    // _getGiftView,
                    SizedBox(
                      height: 8,
                    ),
                    _buildOptions(),
                  ],
                )
              ],
            ),
          ),
        ),
        InkWell(
          onTap: () async {
            _updateCartData();
          },
          child: Container(
            color: green,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            child: Row(
              children: <Widget>[
                Container(
                  child: Text(
                    "₹ ${(payingAmount).toStringAsFixed(2)}",
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
                Expanded(
                    child: Container(
                  child: Text(
                    "PROCEED TO CHECKOUT",
                    textAlign: TextAlign.end,
                    style: TextStyle(color: Colors.white),
                  ),
                )),
                SizedBox(
                  width: 10,
                ),
                Container(
                  child: Icon(
                    Icons.arrow_forward,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  get _getCouponAppliedText {
    return (_apppliedCoupon != null)
        ? (!_apppliedCoupon.isOffer)
            ? Container(
                color: white,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: <Widget>[
                    Icon(Icons.check_circle_outline, color: green, size: 16),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Coupon Applied Sucessfully',
                        style: TextStyle(color: green, fontSize: 13),
                      ),
                    ),
                    MaterialButton(
                        padding: const EdgeInsets.symmetric(
                            vertical: 0, horizontal: 10),
                        child: Text(
                          'Remove',
                          style: TextStyle(
                              color: red,
                              fontSize: 12,
                              decoration: TextDecoration.underline),
                        ),
                        onPressed: () {
                          setState(() {
                            _apppliedCoupon = null;
                            _couponController.text = "";
                            //_setDiscountAmount();
                          });
                          _calculateDiscount();
                        })
                  ],
                ),
              )
            : Container()
        : Container();
  }

  get _getOffers {
    return InkWell(
      onTap: () async {
        final code = await Utility.pushToNext(CouponPage(), context);
        if (code != null) {
          _couponController.text = code;
          _verifyCouponCode();
        }
      },
      child: Container(
        color: white,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
        child: Row(
          children: <Widget>[
            Icon(
              MyFlutterApp.ic_offers,
              size: 20,
              color: red,
            ),
            SizedBox(
              width: 15,
            ),
            Expanded(
                child: Text(
              'APPLY COUPON CODE',
              style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade700,
                  fontWeight: FontWeight.w600),
            )),
            Icon(
              Icons.chevron_right,
              color: red,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  get _getOptionText {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
      child: Text(
        'Options : ',
        style: normalTextStyle,
      ),
    );
  }

  get _getGiftView {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
      color: Colors.white,
      child: Row(
        children: <Widget>[
          Expanded(
            child: Row(
              children: <Widget>[
                Icon(MyFlutterApp.ic_gift_wrap, color: red),
                SizedBox(
                  width: 10,
                ),
                Text(
                  'Gift Warp (₹25)',
                  style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 13,
                      fontWeight: FontWeight.w500),
                )
              ],
            ),
          ),
          InkWell(
            onTap: () {
              setState(() {
                isGiftwarp = !isGiftwarp;
              });
              if (isGiftwarp) {}
            },
            child: Text(
              (isGiftwarp) ? 'REMOVE' : 'ADD',
              style: TextStyle(
                  color: red,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  decoration: TextDecoration.underline),
            ),
          ),
          SizedBox(
            width: 20,
          ),
        ],
      ),
    );
  }

  get _getOtions {
    return new Container(
      color: Colors.grey.shade200,
      height: 50,
      child: Row(
        children: <Widget>[
          SizedBox(
            width: 20,
          ),
          Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Center(
                  child: Icon(
                Icons.local_offer,
                size: 16,
                color: Colors.grey.shade500,
              )),
            ],
          ),
          SizedBox(
            width: 10,
          ),
          Expanded(
              flex: 2,
              child: Container(
                child: TextField(
                    controller: _couponController,
                    textAlign: TextAlign.start,
                    decoration: InputDecoration(
                      hintText: 'ENTER COUPON CODE',
                      hintStyle:
                          TextStyle(color: Colors.grey.shade500, fontSize: 13),
                      border: InputBorder.none,
                    )),
              )),
          Expanded(
            flex: 1,
            child: InkWell(
              onTap: () {
                FocusScope.of(context).unfocus();
                _verifyCouponCode();
              },
              child: Container(
                height: double.maxFinite,
                color: blackGrey,
                width: 150,
                child: Center(
                  child: Text(
                    'APPLY',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  _buildOptions() {
    var discountText = "";
    if (_apppliedCoupon != null) {
      // if (_apppliedCoupon.discountType == "by_percent") {
      //   discountText = ' (${(discount * 100).toStringAsFixed(0)}% OFF)';
      // } else {
      discountText =
          (_apppliedCoupon.name.isNotEmpty) ? '(${_apppliedCoupon.name})' : "";
      // discountText =(_apppliedCoupon.cname.isNotEmpty)? "(${_apppliedCoupon.cname})":"";
      // }
    }
    // payingAmount = totalAmount - discountAmount;
    if (payingAmount < 0) {
      payingAmount = 0;
    }
    return new Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: new Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          SizedBox(
            height: 10,
          ),
          _buildDetailsRow(
              'Total Value', '₹${totalAmount}.00', Colors.grey.shade600, false),
          SizedBox(
            height: 14,
          ),
          _buildDetailsRow(
              'Shipping Charges (Free)', '₹0', Colors.grey.shade600, false),
          SizedBox(
            height: 14,
          ),
          _buildDetailsRow(
              'Discount $discountText',
              '- ₹${discountAmount.toStringAsFixed(2)}',
              Colors.grey.shade600,
              true),
          SizedBox(height: 5),
          Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                '( click refresh button to see Discount )',
                style: TextStyle(color: grey_dark_text_color, fontSize: 10),
              )),
          // Row(
          //   children: <Widget>[
          //     SizedBox(
          //       width: 20,
          //     ),
          //     Checkbox(
          //       materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          //       value: isChecked,
          //       onChanged: (value) {
          //         setState(() {
          //           isChecked = !isChecked;
          //         });
          //       },
          //     ),
          //     Expanded(
          //       child:
          //           _buildDetailsRow('Use wallet', '₹45', Colors.grey.shade600),
          //     )
          //   ],
          // ),
          SizedBox(
            height: 12,
          ),
          _buildDetailsRow('Amount Payable',
              '₹${payingAmount.toStringAsFixed(2)}', red, false),
          SizedBox(
            height: 5,
          ),
        ],
      ),
    );
  }

  _buildDetailsRow(String title, var value, var color, bool isDiscount) {
    var style = TextStyle(
        color: color,
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.2);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      //  : const EdgeInsets.only(right: 30),
      child: Row(
        children: <Widget>[
          Expanded(
            flex: 6,
            child: Row(
              children: <Widget>[
                Flexible(
                  child: Text(
                    title,
                    style: style,
                  ),
                ),
                SizedBox(width: 2),
                (isDiscount)
                    ? Row(
                        children: <Widget>[
                          SizedBox(width: 8),
                          InkWell(
                            onTap: () {
                              _calculateDiscount();
                            },
                            child: Container(
                              padding: EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: red, width: 1)),
                              child: Icon(
                                Icons.refresh,
                                size: 12,
                                color: red,
                              ),
                            ),
                          ),
                          SizedBox(width: 5),
                        ],
                      )
                    : SizedBox(width: 20),
              ],
            ),
          ),

          Text(
            value,
            style: style,
          ),

          //IconButton(icon: Icon(Icons.refresh), onPressed: (){

          //  })
        ],
      ),
    );
  }

  _buildProductList() {
    return ListView.builder(
      physics: ClampingScrollPhysics(),
      // itemCount: cartList?.length,
      itemCount: cartList?.length,
      shrinkWrap: true,
      itemBuilder: (context, index) {
        return Column(
          children: <Widget>[
            // SizedBox(
            //   height: 5,
            // ),
            InkWell(
              onTap: () async {
                var value = await Utility.pushToNext(
                    ProductDetails(
                      productId: cartList[index].id,
                    ),
                    context);
                getCartList();
              },
              child: _productRow(index),
            )
          ],
        );
      },
    );
  }

  _productRow(int index) {
    var total = int.parse('${cartList[index].newPrice}') *
        int.parse('${cartList[index].qty}');
    var selectedSize = "";
    var size_id = cartList[index].size_id.toString();
    for (Sizes size in cartList[index].sizes) {
      if (size.id == size_id) {
        selectedSize = "(${size.size})";
        // cartList[index].size_id = int.parse(size.id);
      }
    }
    //cartList[index].isInStock = false;
    //var total = '120';
    return Container(
      child: Stack(
        children: <Widget>[
          Column(
            children: <Widget>[
              new Container(
                color: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: new Row(
                  children: <Widget>[
                    new SizedBox(
                        width: 55,
                        child: Stack(
                          children: <Widget>[
                            (cartList[index].images.length > 0)
                                ? CachedNetworkImage(
                                    imageUrl:
                                        cartList[index].images[0].imageUrl,
                                    placeholder: (context, data) {
                                      return Container(
                                        child: new Center(
                                          child: SizedBox(
                                            height: 20,
                                            width: 20,
                                            child:
                                                new CircularProgressIndicator(
                                              strokeWidth: 2,
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                    fit: BoxFit.cover,
                                  )
                                : Image.asset('assets/no_image.png'),
                            // (cartList[index].isInStock)?Container():
                            //   Container(
                            //     width: 100,
                            //     height: 70,
                            //     color: Colors.white70,
                            //     child: Column(
                            //       mainAxisAlignment: MainAxisAlignment.center,
                            //       crossAxisAlignment: CrossAxisAlignment.center,
                            //       mainAxisSize: MainAxisSize.max,
                            //       children: <Widget>[
                            //         Text('OUT OF STOCK',textAlign: TextAlign.center ,style:TextStyle(color: red,fontSize: 15,fontWeight: FontWeight.w600)),
                            //       ],
                            //     ),
                            //   )
                          ],
                        )

                        //Image.asset('assets/Tana-Tan.png'),
                        ),
                    SizedBox(
                      width: 20,
                    ),
                    Expanded(
                      flex: 1,
                      child: new Container(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Row(
                              children: <Widget>[
                                Text(
                                  cartList[index].name,
                                  style: bigTextStyle,
                                ),
                              ],
                            ),
                            (cartList[index].sizes.length > 0)
                                ? SizedBox(
                                    height: 2,
                                  )
                                : Container(),
                            Text(
                              '${selectedSize}',
                              style: smallTextStyle,
                            ),
                            SizedBox(
                              height: 7,
                            ),
                            Container(
                              child: Row(
                                children: <Widget>[
                                  InkWell(
                                    onTap: () {
                                      if (cartList[index].qty != 1 &&
                                          cartList[index].isInStock) {
                                        setState(() {
                                          cartList[index].qty--;
                                          totalAmount = totalAmount -
                                              cartList[index].amount;
                                          cartList[index].amount =
                                              cartList[index].newPrice *
                                                  cartList[index].qty;
                                          totalAmount = totalAmount +
                                              cartList[index].amount;
                                          //_setDiscountAmount();
                                        });
                                        _calculateDiscount();
                                        // _updateCartData();
                                      }
                                    },
                                    child: Container(
                                        padding: const EdgeInsets.all(7),
                                        decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: Colors.grey.shade500,
                                            )),
                                        child: Icon(Icons.remove,
                                            size: 13,
                                            color: Colors.grey.shade500)
                                        // Text(
                                        //   '−',
                                        //   style: TextStyle(
                                        //       color: Colors.grey.shade500,
                                        //       fontWeight: FontWeight.bold),
                                        // ),
                                        ),
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Text(
                                    '${cartList[index].qty}',
                                    style: TextStyle(
                                        fontSize: 15,
                                        color: Colors.grey.shade600,
                                        fontWeight: FontWeight.w500),
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  InkWell(
                                    onTap: () {
                                      if (cartList[index].isInStock) {
                                        setState(() {
                                          cartList[index].qty =
                                              cartList[index].qty + 1;
                                          totalAmount = totalAmount -
                                              cartList[index].amount;
                                          cartList[index].amount =
                                              cartList[index].newPrice *
                                                  cartList[index].qty;

                                          totalAmount = totalAmount +
                                              cartList[index].amount;
                                        });
                                        _calculateDiscount();
                                        // _updateCartData();
                                      }
                                    },
                                    child: Container(
                                        padding: const EdgeInsets.all(7),
                                        decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: Colors.grey.shade500,
                                            )),
                                        child: Icon(Icons.add,
                                            size: 13,
                                            color: Colors.grey.shade500)
                                        // Text(
                                        //   '+',
                                        //   style: TextStyle(
                                        //       color: Colors.grey.shade500,
                                        //       fontWeight: FontWeight.bold),
                                        // ),
                                        ),
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Text(
                                    'X',
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade600,
                                        fontWeight: FontWeight.w500),
                                  ),
                                  SizedBox(
                                    width: 5,
                                  ),
                                  Text(
                                    '₹${cartList[index].newPrice}',
                                    style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey.shade600,
                                        fontWeight: FontWeight.w500),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                  text: (cartList[index].isInStock)
                                      ? '₹$total'
                                      : "OUT OF STOCK",
                                  style: TextStyle(
                                      fontSize:
                                          (cartList[index].isInStock) ? 15 : 11,
                                      //color: Colors.grey.shade700,
                                      color: (cartList[index].isInStock)
                                          ? Colors.grey.shade700
                                          : Colors.grey.shade500,
                                      fontWeight: FontWeight.w700)),
                              // TextSpan(
                              //     text: '  10% off',
                              //     style:
                              //         TextStyle(color: Colors.black, fontSize: 12))
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 3,
                        ),
                        Text(
                          ' ',
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w500),
                        )
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                color: Colors.grey.shade200,
                child: new Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      flex: 1,
                      child: InkWell(
                        onTap: () {
                          DialogHelper.showRemoveDialog(
                              context,
                              cartList[index].name,
                              'Remove product from cart ?',
                              'REMOVE', () async {
                            Navigator.pop(context);
                            await _removeFromCartlist(index);
                            if (cartList.length > 0) {
                              _calculateDiscount();
                            }
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                              border: Border(
                                  right: BorderSide(
                                      color: Colors.white, width: 0.7))),
                          padding: const EdgeInsets.all(12.0),
                          child: new Text(
                            'REMOVE',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey.shade700),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: InkWell(
                        onTap: () {
                          DialogHelper.showRemoveDialog(
                              context,
                              'Bikaji Bhujia',
                              'Remove product from cart ?',
                              'REMOVE', () async {
                            Navigator.pop(context);
                            await _moveFromCartToWishlist(index);
                            if (cartList.length > 0) {
                              _calculateDiscount();
                            }
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                              border: Border(
                                  left: BorderSide(
                                      color: Colors.white, width: 0.7))),
                          padding: const EdgeInsets.all(12.0),
                          child: new Text(
                            'MOVE TO WISHLIST',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey.shade700),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
          // Container(
          //   padding: const EdgeInsets.symmetric(vertical: 5),
          //   child: Utility.offerWidget('5% OFF') ,
          // )
          //,
        ],
      ),
    );
  }

  _moveFromCartToWishlist(int index) async {
    final product = cartList[index];
    progressDialog(context, "Please wait...");
    try {
      final response = await ApiProvider()
          .moveFromCartToWishlist(product.id, product.size_id);
      hideProgressDialog(context);
      if (response.status == UrlConstants.SUCCESS) {
        setState(() {
          cartList.removeAt(index);
          //_setDiscountAmount();
        });
        _setDiscountAmount();
        Prefs.setCartCount(cartList.length);
        widget.onRefresh();
      } else {
        Utility.showScaffoldSnackBar(context, response.message, null, true);
      }
    } catch (e) {
      myPrint(e.toString());
      hideProgressDialog(context);
    }
  }

  _removeFromCartlist(int index) async {
    final product = cartList[index];
    progressDialog(context, "Please wait...");
    try {
      final response =
          await ApiProvider().removeFromCart(product.id, product.size_id);
      hideProgressDialog(context);
      if (response.status == UrlConstants.SUCCESS) {
        setState(() {
          cartList.removeAt(index);
        });
        Prefs.setCartCount(cartList.length);
        widget.onRefresh();
      } else {
        Utility.showScaffoldSnackBar(context, response.message, null, true);
      }
    } catch (e) {
      myPrint(e.toString());
      hideProgressDialog(context);
    }
  }

  _buildTopCount() {
    var style = TextStyle(
        fontSize: 15, fontWeight: FontWeight.bold, color: Colors.red.shade700);
    return new Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(25, 20, 20, 20),
      child: new Row(
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          new Expanded(
            flex: 1,
            child: new Text(
              'Your Items (${cartList.length})',
              style: TextStyle(
                  color: Colors.grey.shade700,
                  fontWeight: FontWeight.w700,
                  fontSize: 15),
            ),
          ),
          new Expanded(
              flex: 1,
              child: new Text(
                '₹${totalAmount}',
                style: style,
                textAlign: TextAlign.right,
              )),
        ],
      ),
    );
  }
}
