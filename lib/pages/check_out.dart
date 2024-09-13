import 'dart:convert';

import 'package:bikaji/model/AddressData.dart';
import 'package:bikaji/model/OfferResponse.dart';
import 'package:bikaji/model/OrderDetailsData.dart';
import 'package:bikaji/model/product.dart';
import 'package:bikaji/pages/add_edit_address.dart';
import 'package:bikaji/pages/addressList_page.dart';
import 'package:bikaji/pages/dashboard_page.dart';
import 'package:bikaji/pages/order_confirm_details.dart';
import 'package:bikaji/pages/payment_page.dart';
import 'package:bikaji/prefrence_util/Prefs.dart';
import 'package:bikaji/repo/Repository.dart';
import 'package:bikaji/repo/api_provider.dart';
import 'package:bikaji/util/app_helper.dart';
import 'package:bikaji/util/constants.dart';
import 'package:bikaji/util/custom_icons.dart';
import 'package:bikaji/util/dialog_helper.dart';
import 'package:bikaji/util/dialog_inset_defeat.dart';
import 'package:bikaji/util/textStyle.dart';
import 'package:bikaji/util/url_list.dart';
import 'package:bikaji/util/utility.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
//import 'package:paytm/paytm.dart';

enum CheckOutTag { SHIPPING, PAYMENT, CONFIRM }
enum PaymentTag { OTHER, COD }

class CheckoutPage extends StatefulWidget {
  final List<Product> cartList;
  final double payingAmount;
  final double totalAmount;
  final double discountAmount;
  final double discount;
  final Offers offers;
  final String offer_type;
  final String paytmText;
  CheckoutPage(
      {@required this.cartList,
      @required this.payingAmount,
      @required this.totalAmount,
      @required this.discountAmount,
      @required this.discount,
      @required this.offer_type,
      @required this.offers,
      this.paytmText});
  @override
  _CheckoutPageState createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> with AppHelper {
  CheckOutTag _tag = CheckOutTag.SHIPPING;
  PaymentTag _paymentTag = PaymentTag.OTHER;
  bool isBiilAndShipSame = true;
  bool isShippingAddressSelcted = false;
  final _scaffoldKey = new GlobalKey<ScaffoldState>();
  List<AddressData> _addressList;
  AddressData billingAddress;
  AddressData shippingAddress;
  OrderDetailsData _orderDetailsData;
  String _responseStatus = STATUS_LOADING;

  @override
  initState() {
    super.initState();
    setData();
  }

  setData() async {
    Future.delayed(Duration(milliseconds: 800), () {
      _fetchAddress();
    });
    // final response = await Prefs.addressResponse;
    // if (response.isNotEmpty) {
    //   _addressList = await Utility.getAddressData();
    //   if ((_addressList != null)) {
    //     for (var address in _addressList) {
    //       if (address.isDefault) {
    //         billingAddress = address;
    //       }
    //     }
    //   }
    //   if (isBiilAndShipSame) {
    //     shippingAddress = billingAddress;
    //   }
    //   setState(() {});
    // } else {
    //   _fetchAddress();
    // }
  }

  _fetchAddress() async {
    //progressDialog(context, "Please wait...");
    final userId = await Prefs.id;
    try {
      final response = await ApiProvider().fetchAddress(userId);
      // hideProgressDialog(context);
      if (response.status == Constants.success) {
        setState(() {
          _addressList = response.data;
          if ((_addressList != null)) {
            for (var address in _addressList) {
              if (address.isDefault) {
                billingAddress = address;
              }
            }

            if (billingAddress == null && _addressList.length > 0) {
              billingAddress = _addressList[0];
            }
          }
          if (isBiilAndShipSame) {
            shippingAddress = billingAddress;
          }
        });
      } else {
        Utility.showCustomSnackBar(SOMETHING_WRONG_TEXT, _scaffoldKey);
      }
    } catch (e) {
      // hideProgressDialog(context);
      myPrint(e.toString());
      DialogHelper.showErrorDialog(context, "Error", SOMETHING_WRONG_TEXT,
          showTitle: true, onOkClicked: () {
        Navigator.pop(context);
        Navigator.pop(context);
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
          title: Text(
            'Checkout',
            style: toolbarStyle,
          ),
          elevation: 0.0,
          bottomOpacity: 0.0,
          backgroundColor: Colors.red,
          leading: (_tag == CheckOutTag.SHIPPING || _tag == CheckOutTag.PAYMENT)
              ? IconButton(
                  icon: Icon(Icons.chevron_left),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                )
              : Container(),
        ),
      ),
      body: Container(
        color: Colors.grey.shade100,
        child: Stack(
          children: <Widget>[
            Container(
              height: 50,
              color: Colors.red,
            ),
            _topFrame,
          ],
        ),
      ),
    );
  }

  get _topFrame {
    return Container(
      child: Column(
        children: <Widget>[
          _gettopTabBar,
          Expanded(
            child: ListView(
              children: <Widget>[
                _getView,
              ],
            ),
          ),
          (_addressList != null)
              ? (_addressList.length > 0)
                  ? InkWell(
                      onTap: () {
                        if (_tag == CheckOutTag.CONFIRM) {
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                                builder: (BuildContext context) =>
                                    DashBoardPage()),
                            ModalRoute.withName('/'),
                          );
                        } else if (_tag == CheckOutTag.SHIPPING) {
                          setState(() {
                            _tag = CheckOutTag.PAYMENT;
                          });
                        } else {
                          _placeOrder();
                        }
                      },
                      child: Container(
                        color: green,
                        width: double.infinity,
                        padding: const EdgeInsets.all(15),
                        child: Text(
                          (_tag == CheckOutTag.SHIPPING ||
                                  _tag == CheckOutTag.PAYMENT)
                              ? (_tag == CheckOutTag.SHIPPING)
                                  ? 'NEXT'
                                  : (widget.payingAmount > 0)
                                      ? 'PAY NOW : ${widget.payingAmount.toStringAsFixed(2)}'
                                      : 'ORDER NOW'
                              : 'CONTINUE SHOPPING',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Colors.white,
                              //fontSize: 14,
                              fontWeight: FontWeight.normal),
                        ),
                      ),
                    )
                  : Container()
              : Container()
        ],
      ),
    );
  }

  _pay(var orderId, var orderIdActual, var amount, String coupon_code) async {
    // get user data from prefrence
    final userid = await Prefs.id;
    final email = await Prefs.email;
    final number = await Prefs.mobileNumber;
    final data = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => PaymentPage(
                  amount: amount,
                  orderId: orderIdActual,
                  userId: userid,
                  email: email,
                  number: number,
                )));
    if (data != null) {
      myPrint("data is " + data);
      final responseJson = jsonDecode(data);
      myPrint(responseJson.toString());
      final checkSumResult = responseJson["status"];
      final paytmResponse = responseJson['data'];
      if (paytmResponse["STATUS"] == "TXN_SUCCESS") {
        if (checkSumResult == 1) {
          _responseStatus = STATUS_SUCESSFUL;
          // update your order using update order api
          final transactionId = paytmResponse['TXNID'];
          final transactionAmount = paytmResponse["TXNAMOUNT"];
          _updateOrderPayment(orderId, transactionId, Constants.PAYMENT_SUCESS,
              transactionAmount, coupon_code);
        } else {
          _responseStatus = STATUS_CHECKSUM_FAILED;
          final transactionId = paytmResponse['TXNID'];
          final transactionAmount = paytmResponse["TXNAMOUNT"];
          _updateOrderPayment(orderId, transactionId ?? "",
              Constants.PAYMMENT_FAIED, transactionAmount, coupon_code);
        }
      } else if (paytmResponse["STATUS"] == "TXN_FAILURE") {
        _responseStatus = STATUS_FAILED;
        final transactionId = paytmResponse['TXNID'];
        final transactionAmount = paytmResponse["TXNAMOUNT"];
        _updateOrderPayment(orderId, transactionId, Constants.PAYMMENT_FAIED,
            transactionAmount, coupon_code);
      }
    }
  }

  _showPaymentErrorDialog(var title, var desc, var size, var firstButtonTitle,
      var secondbuttonTitle,
      {Function onFirstButtonCliked, Function onSecondButtonCliked}) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              content: Container(
                height: size,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(Icons.error, color: red, size: 80),
                    SizedBox(height: 20),
                    Text(title,
                        textAlign: TextAlign.center, style: extraBigTextStyle),
                    SizedBox(height: 5),
                    Text(
                      desc,
                      textAlign: TextAlign.center,
                      style: smallTextStyle,
                    ),
                    SizedBox(height: 25),
                    MaterialButton(
                        onPressed: () {
                          onFirstButtonCliked();
                        },
                        textColor: white,
                        color: grey_dark_text_color,
                        child: Text(firstButtonTitle)),
                    SizedBox(height: 10),
                    TextButton(
                        onPressed: () {
                          onSecondButtonCliked();
                        },
                        child: Text(secondbuttonTitle,style:TextStyle(
                          color: red
                        ))),
                  ],
                ),
              ),
            ));
  }

  _updateOrderPaymentFree(
      var order_id, var payment_amount, String coupon_code) async {
    progressDialog(context, "Please wait...");
    try {
      final response = await ApiProvider()
          .updatePaymentFree(order_id, payment_amount, coupon_code);
      hideProgressDialog(context);
      if (response.status == UrlConstants.SUCCESS) {
        _orderDetailsData = response.data;
        Prefs.setCartCount(0);
        setState(() {
          _tag = CheckOutTag.CONFIRM;
          _responseStatus = STATUS_SUCESSFUL;
        });
      } else {
        // show dialog of error message where user can retry and complain to customer about error
        _showPaymentErrorDialog(
            "Transaction of $rupee $payment_amount has been intrrupted by something!",
            "Please click retry button or contact to Bikaji online helpline number.",
            0.00,
            'Retry',
            'Back to Dashboard', onFirstButtonCliked: () {
          // call update payment details api
          Navigator.pop(context);
          _updateOrderPaymentFree(order_id, payment_amount, coupon_code);
        }, onSecondButtonCliked: () {
          Navigator.pop(context);
          Utility.pushToDashboard(context, 0);
        });
      }
    } catch (e) {
      myPrint(e.toString());
      hideProgressDialog(context);
      _showPaymentErrorDialog(
          "Transaction of $rupee $payment_amount has been intrrupted by something!",
          "Please click retry button or contact to Bikaji online helpline number.",
          0.00,
          'Retry',
          'Back to Dashboard', onFirstButtonCliked: () {
        // call update payment details api
        Navigator.pop(context);
        _updateOrderPaymentFree(order_id, payment_amount, coupon_code);
      }, onSecondButtonCliked: () {
        Navigator.pop(context);
        Utility.pushToDashboard(context, 0);
      });
    }
  }

  _updateOrderPayment(var order_id, var transaction_id, var paymentStatus,
      var payment_amount, String coupon_code) async {
    progressDialog(context, "Please wait...");
    try {
      final response = await ApiProvider().updatePayment(
          order_id, transaction_id, paymentStatus, payment_amount, coupon_code);
      hideProgressDialog(context);
      if (response.status == UrlConstants.SUCCESS) {
        if (paymentStatus == Constants.PAYMENT_SUCESS) {
          _orderDetailsData = response.data;
          Prefs.setCartCount(0);
          setState(() {
            _tag = CheckOutTag.CONFIRM;
          });
        }
      } else {
        if (paymentStatus == Constants.PAYMENT_SUCESS) {
          // show dialog of error message where user can retry and complain to customer about error
          _showPaymentErrorDialog(
              "Transaction of $rupee $payment_amount has been intrrupted by something!",
              "Please click retry button if money has been deducted from bank then contact to Bikaji online helpline number.",
              350.00,
              'Retry',
              'Back to Dashboard', onFirstButtonCliked: () {
            // call update payment details api
            Navigator.pop(context);
            _updateOrderPayment(order_id, transaction_id, paymentStatus,
                payment_amount, coupon_code);
          }, onSecondButtonCliked: () {
            Navigator.pop(context);
            Utility.pushToDashboard(context, 0);
          });
        }
      }
    } catch (e) {
      myPrint(e.toString());
      hideProgressDialog(context);
      if (paymentStatus == Constants.PAYMENT_SUCESS) {
        // show dialog of error message
        _showPaymentErrorDialog(
            "Transaction of $rupee $payment_amount has been intrrupted by something!",
            "Please click retry button if money has been deducted from bank then contact to Bikaji online helpline number.",
            350.00,
            'Retry',
            'Back to Dashboard', onFirstButtonCliked: () {
          // call update payment details api
          Navigator.pop(context);
          _updateOrderPayment(order_id, transaction_id, paymentStatus,
              payment_amount, coupon_code);
        }, onSecondButtonCliked: () {
          Navigator.pop(context);
          Utility.pushToDashboard(context, 0);
        });
      }
    }
  }

  _placeOrder() async {
    progressDialog(context, "Please wait...");
    // final code = (widget.offers != null)?widget.offers.name:"";
    try {
      final response = await ApiProvider().placeOrder(
          billingAddress.addressId,
          shippingAddress.addressId,
          widget.offers?.name ?? "",
          widget.offer_type,
          widget.discountAmount.toStringAsFixed(2));
      hideProgressDialog(context);
      if (response.status == UrlConstants.SUCCESS) {
        final data = response.data;
        final amount =
            double.parse(data["amount"]).toDouble().toStringAsFixed(2);
        final order_id = data["order_id"];
        final order_id_actual = data["order_id_actual"];
        final zero_order = data["zero_order"];
        myPrint('amount is : ${amount}');
        if (zero_order) {
          // call zero order apiasf
          _updateOrderPaymentFree(order_id, amount, widget.offers?.name ?? "");
        } else {
          _pay(
            order_id,
            order_id_actual,
            amount,
            widget.offers?.name ?? "",
          );
        }
      } else {
        ApiProvider().sendMail("place order", "${response.message}");
        DialogHelper.showErrorDialog(context, "Error", response.message,
            showTitle: true, onOkClicked: () {
          Navigator.pop(context);
        });
      }
    } catch (e) {
      myPrint(e.toString());
      hideProgressDialog(context);
      ApiProvider().sendMail("place order", "${e.toString()}");
      DialogHelper.showErrorDialog(context, "Error", SOMETHING_WRONG_TEXT,
          showTitle: true, onOkClicked: () {
        Navigator.pop(context);
      });
      // _updateOrderPayment(orderId, transactionId, Constants.PAYMENT_SUCESS,
      //         transactionAmount);
    }
  }

  get _gettopTabBar {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10),
      child: Card(
        child: Container(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              _getTab(
                  'ADDRESS', MyFlutterApp.ic_shipping, CheckOutTag.SHIPPING),
              _getTab('PAYMENT', MyFlutterApp.ic_payment, CheckOutTag.PAYMENT),
              _getTab(
                  'CONFIRM', MyFlutterApp.checkmark_cicle, CheckOutTag.CONFIRM),
            ],
          ),
        ),
      ),
    );
  }

  get _getView {
    var view;
    switch (_tag) {
      case CheckOutTag.SHIPPING:
        view = _getAddressView;
        break;
      case CheckOutTag.PAYMENT:
        view = _getPaymentView;
        break;
      case CheckOutTag.CONFIRM:
        view = OrderConfirmDetails(
          status: _responseStatus,
          isDetails: true,
          orderData: _orderDetailsData,
        );
        break;
      default:
        view = _getAddressView;
    }
    return view;
  }

  get _getPaymentView {
    return PaySummeryWidget(
      billingAddress: billingAddress,
      cartlist: widget.cartList,
      shippingAddress: shippingAddress,
      payingAmount: widget.payingAmount,
      discount: widget.discount,
      totalAmount: widget.totalAmount,
      discountAmount: widget.discountAmount,
      paytmText: widget.paytmText,
      offer: widget.offers,
    );
  }

  get _getAddressView {
    return (_addressList != null)
        ? (_addressList.length > 0)
            ? Container(
                child: Column(
                  children: <Widget>[
                    _addressRow('BILLING ADDRESS', billingAddress),
                    SizedBox(
                      height: 5,
                    ),
                    (isShippingAddressSelcted)
                        ? _addressRow('SHIPPING ADDRESS', shippingAddress)
                        : Container(),
                    // SizedBox(
                    //   height: 20,
                    // ),
                    (!isShippingAddressSelcted)
                        ? (isBiilAndShipSame)
                            ? Container()
                            : _getChangeAddbtn('Add / Select Shipping Address',
                                () {
                                _showAddressList(ADDRESSTAG.SHIPPING);
                              })
                        : Container(),
                    // SizedBox(
                    //   height: 20,
                    // ),
                    //_getChangeAddbtn('Add New Address'),
                    (isBiilAndShipSame)
                        ? InkWell(
                            onTap: () {
                              setState(() {
                                isBiilAndShipSame = !isBiilAndShipSame;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.only(left: 20, top: 10),
                              child: Row(
                                children: <Widget>[
                                  InkWell(
                                    onTap: () {
                                      setState(() {
                                        isBiilAndShipSame = !isBiilAndShipSame;
                                      });
                                    },
                                    child: Container(
                                      padding: EdgeInsets.all(1),
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(2),
                                          border: Border.all(
                                              color: Colors.grey, width: 1)),
                                      child: Icon(
                                        Icons.check,
                                        color: Colors.red,
                                        size: 12,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  InkWell(
                                      onTap: () {
                                        setState(() {
                                          isBiilAndShipSame =
                                              !isBiilAndShipSame;
                                        });
                                      },
                                      child: Text(
                                        'Billing and Shipping addresses both are same',
                                        style: smallTextStyle,
                                      ))
                                ],
                              ),
                            ),
                          )
                        : Container(),
                  ],
                ),
              )
            : Column(
                children: <Widget>[
                  SizedBox(height: 80),
                  NoAddressWidget(
                    onAddCliked: () {
                      _addressList = null;
                      Utility.pushToNext(
                              AddEditAddress(
                                addressData: null,
                              ),
                              context)
                          .then((value) async {
                        _fetchAddress();
                      });
                    },
                  ),
                ],
              )
        : Column(
            children: <Widget>[
              SizedBox(height: (MediaQuery.of(context).size.height / 2) - 120),
              Container(
                  child: Center(
                child: CircularProgressIndicator(),
              )),
            ],
          );
  }

  _showAddressList(ADDRESSTAG tag) {
    var selectedValue = -1;
    _scaffoldKey.currentState.showBottomSheet((context) {
      return SelectAddress(
        selectedValue: selectedValue,
        addressList: _addressList,
        onAddressClick: (index) {
          Navigator.pop(context);
          setState(() {
            if (tag == ADDRESSTAG.BILLING) {
              myPrint('inside else ${_addressList[index].toJson()}');
              billingAddress = _addressList[index];
            } else {
              shippingAddress = _addressList[index];
              isShippingAddressSelcted = true;
            }
            //
          });
        },
        onAddClick: () {
          Navigator.pop(context);
          Utility.pushToNext(AddEditAddress(), context).then((value) {
            _fetchAddress();
          });
        },
      );
    });
    // showModalBottomSheet(
    //     context: context,

    //     builder: (context) {
    //       return SelectAddress(selectedValue: selectedValue,onAddressClick: (){

    //       },);
    //     });
  }

  _getChangeAddbtn(var title, Function onClick) {
    return InkWell(
      onTap: onClick,
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
        child: Row(
          children: <Widget>[
            Icon(
              Icons.add_circle,
              size: 20,
              color: Colors.red.shade400,
            ),
            SizedBox(
              width: 10,
            ),
            Text(
              title,
              style: TextStyle(
                  color: Colors.grey.shade700,
                  fontSize: 14,
                  fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _addressRow(var title, AddressData addressData) {
    var addressStyle = TextStyle(
        color: Colors.grey.shade600, fontSize: 12, letterSpacing: 0.3);
    return (addressData != null)
        ? Container(
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SizedBox(
                  height: 30,
                ),
                Container(
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 5),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: Text(title,
                              style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700)),
                        ),
                        InkWell(
                          onTap: () {
                            _showAddressList((title == "BILLING ADDRESS")
                                ? ADDRESSTAG.BILLING
                                : ADDRESSTAG.SHIPPING);
                          },
                          child: Container(
                            padding: EdgeInsets.only(bottom: 2),
                            decoration: BoxDecoration(
                                border: Border(
                                    bottom: BorderSide(
                                        color: textGrey, width: 0.8))),
                            child: Text('Change',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: textGrey,
                                  fontSize: 11,
                                )),
                          ),
                        ),
                        SizedBox(
                          width: 20,
                        ),
                        InkWell(
                          onTap: () {
                            Utility.pushToNext(
                                    AddEditAddress(
                                      addressData: addressData,
                                    ),
                                    context)
                                .then((value) {
                              _fetchAddress();
                            });
                          },
                          child: Container(
                            padding: EdgeInsets.only(bottom: 2),
                            decoration: BoxDecoration(
                                border: Border(
                                    bottom: BorderSide(
                                        color: textGrey, width: 0.8))),
                            child: Text('Edit',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: textGrey,
                                  fontSize: 11,
                                )),
                          ),
                        )
                      ],
                    )),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 18),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Expanded(
                        flex: 3,
                        child: Container(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              SizedBox(
                                height: 2,
                              ),
                              Row(
                                children: <Widget>[
                                  Text(
                                    '${addressData.firstName} ${addressData.lastName}',
                                    style: TextStyle(
                                        color: Colors.grey.shade700,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700),
                                  ),
                                ],
                              ),
                              (addressData.isDefault)
                                  ? Text(
                                      'default',
                                      style: TextStyle(
                                          fontStyle: FontStyle.italic,
                                          fontSize: 11,
                                          color: red),
                                    )
                                  : Container(),
                              SizedBox(
                                height: 13,
                              ),
                              Text(
                                '${addressData.number}',
                                style: addressStyle,
                              ),
                              SizedBox(
                                height: 5,
                              ),
                              Text(
                                '${addressData.flatNo}, ${addressData.streetName},${addressData.landmark},${addressData.city}-${addressData.pincode}',
                                style: addressStyle,
                              ),
                              // SizedBox(
                              //   height: 5,
                              // ),
                              // Text(
                              //   '${addressData.landmark},${addressData.city}-${addressData.pincode}',
                              //   style: addressStyle,
                              // ),
                              // SizedBox(
                              //   height: 5,
                              // ),
                              // Text('Rajasthan-334006',style: addressStyle,),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      (addressData.type.isNotEmpty)
                          ? Expanded(
                              flex: 1,
                              child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 5),
                                  decoration: BoxDecoration(
                                      border: Border.all(
                                          color: textGrey,
                                          style: BorderStyle.solid,
                                          width: 0.7),
                                      borderRadius: BorderRadius.circular(4)),
                                  child: Text(
                                    addressData.type,
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: red,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    textAlign: TextAlign.center,
                                  )),
                            )
                          : Container(),
                      SizedBox(
                        width: 10,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )
        : Container();
  }

  _getTab(var title, var icon, var tag) {
    return InkWell(
      onTap: () {
        // setState(() {
        //   _tag = tag;
        // });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
        child: Column(
          children: <Widget>[
            Icon(
              icon,
              color: (_tag == tag) ? Colors.red.shade400 : Colors.grey.shade500,
              size: 24,
            ),
            SizedBox(
              height: 12,
            ),
            Text(
              title,
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: (_tag == tag)
                      ? Colors.red.shade400
                      : Colors.grey.shade500),
            )
          ],
        ),
      ),
    );
  }
}

class PaySummeryWidget extends StatelessWidget {
  const PaySummeryWidget(
      {Key key,
      @required this.billingAddress,
      @required this.shippingAddress,
      @required this.cartlist,
      @required this.payingAmount,
      @required this.totalAmount,
      @required this.discount,
      @required this.discountAmount,
      @required this.offer,
      this.paytmText})
      : super(key: key);

  final AddressData billingAddress;
  final AddressData shippingAddress;
  final List<Product> cartlist;
  final payingAmount, totalAmount;
  final discount;
  final discountAmount;
  final offer;
  final paytmText;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: <Widget>[
          SizedBox(
            height: 10,
          ),
          _getRadioRow(paytmText, PaymentTag.OTHER),
          SizedBox(
            height: 10,
          ),
          // _getRadioRow('Cash on Delivery', PaymentTag.COD),
          _getPaymentDetails,
          SizedBox(
            height: 5,
          ),
          _getShippingDetails('BILLING ADDRESS', billingAddress),
          SizedBox(
            height: 10,
          ),
          _getShippingDetails('SHIPPING ADDRESS', shippingAddress),
        ],
      ),
    );
  }

  get _getPaymentDetails {
    myPrint("discount is $discount");
    var discountText = "";
    if (offer != null) {
      // if (offer.discountType == "by_percent") {
      //   discountText = ' (${(discount).toStringAsFixed(0)}% OFF)';
      // } else {
      //   //discountText = ' ($discountAmount) OFF';
      //   discountText = "(${offer.cname})";
      // }
      discountText = (offer.name.isNotEmpty) ? '(${offer.name})' : "";
      //discountText = "(${offer.name})";
    }

    return Container(
      color: Colors.white,
      child: Column(
        children: <Widget>[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                RichText(
                  text: TextSpan(
                    text: 'PAYMENT SUMMARY',
                    style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                        fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: 1,
            color: Colors.grey.shade300,
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
            child: Column(
              children: <Widget>[
                SizedBox(
                  height: 8,
                ),
                _buildDetailsRow('Total Value', '$rupee ${totalAmount}',
                    Colors.grey.shade700, FontWeight.normal),
                SizedBox(
                  height: 14,
                ),
                _buildDetailsRow('Delivery Charges (Free)', '$rupee 0',
                    Colors.grey.shade700, FontWeight.normal),
                SizedBox(
                  height: 14,
                ),
                _buildDetailsRow(
                    'Discount $discountText',
                    '- ₹${discountAmount.toStringAsFixed(2)}',
                    Colors.grey.shade700,
                    FontWeight.normal),
                SizedBox(
                  height: 14,
                ),
                // _buildDetailsRow('Wallet', '$rupee 97', Colors.grey.shade700,
                //     FontWeight.normal),
                // SizedBox(
                //   height: 14,
                // ),
                _buildDetailsRow(
                    'Amount paid',
                    '$rupee ${payingAmount.toStringAsFixed(2)}',
                    Colors.red.shade400,
                    FontWeight.w600),
                SizedBox(
                  height: 14,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  _buildDetailsRow(var title, var value, var color, var weight) {
    var style = TextStyle(
        color: color, fontSize: 14, fontWeight: weight, letterSpacing: 0.2);
    return Container(
      //padding:const EdgeInsets.only(right: 30),
      child: Row(
        children: <Widget>[
          Expanded(
            flex: 6,
            child: new Text(
              title,
              style: style,
            ),
          ),
          new Text(
            value,
            style: style,
            //),
          ),
        ],
      ),
    );
  }

  _getRadioRow(var title, PaymentTag tag) {
    return InkWell(
      onTap: () {
        // setState(() {
        //   _paymentTag = tag;
        // });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 14),
        color: Colors.white,
        child: Row(
          children: <Widget>[
            Icon(
              Icons.radio_button_checked,
              size: 18,
              color: red,
            ),
            SizedBox(
              width: 10,
            ),
            Expanded(child: Text(title, style: normalTextStyle)),
          ],
        ),
      ),
    );
  }

  _getShippingDetails(var title, AddressData addressData) {
    var addressStyle = TextStyle(
        color: Colors.grey.shade700, fontSize: 12, letterSpacing: 0.3);
    return Container(
      color: Colors.white,
      child: Column(
        children: <Widget>[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                RichText(
                  text: TextSpan(
                    text: title,
                    style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                        fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: 1,
            color: Colors.grey.shade300,
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Text(
                      '${addressData.firstName} ${addressData.lastName}',
                      style: TextStyle(
                          color: red,
                          fontSize: 13,
                          fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
                SizedBox(
                  height: 15,
                ),
                Text(
                  '${addressData.number}',
                  style: addressStyle,
                ),
                SizedBox(
                  height: 5,
                ),
                Text(
                  '${addressData.flatNo}, ${addressData.streetName}',
                  style: addressStyle,
                ),
                SizedBox(
                  height: 5,
                ),
                Text(
                  '${addressData.landmark},${addressData.city}-${addressData.pincode}',
                  style: addressStyle,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class SelectAddress extends StatefulWidget {
  var selectedValue;
  Function onAddressClick;
  final Function onAddClick;
  final List<AddressData> addressList;

  SelectAddress(
      {this.selectedValue,
      this.onAddressClick,
      this.addressList,
      this.onAddClick});

  @override
  _SelectAddressState createState() => _SelectAddressState();
}

class _SelectAddressState extends State<SelectAddress> {
  var selectedValue = 1;
  var groupValue = -1;
  @override
  Widget build(BuildContext context) {
    return Container(
        child: Column(
      children: <Widget>[
        Expanded(
          child: ListView.builder(
            itemCount: widget.addressList.length,
            itemBuilder: (context, index) {
              return _getAddressSelectRow(index);
            },
          ),
        ),
        InkWell(
          onTap: () {
            widget.onAddClick();
          },
          child: Container(
            color: blackGrey,
            width: double.infinity,
            padding: const EdgeInsets.all(15),
            child: Text(
              'ADD NEW ADDRESS',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600),
            ),
          ),
        )
      ],
    )
        //  _getAddressSelectRow(index, selectedValue),
        );
  }

  _getAddressSelectRow(var index) {
    AddressData addressData = widget.addressList[index];
    var addressStyle = TextStyle(
        color: Colors.grey.shade700, fontSize: 11, letterSpacing: 0.3);
    return Column(
      children: <Widget>[
        InkWell(
          onTap: () {
            setState(() {
              groupValue = index;
            });
            widget.onAddressClick(index);
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 18),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Radio(
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  value: index,
                  groupValue: groupValue,
                  onChanged: (value) {
                    setState(() {
                      groupValue = value;
                    });
                    widget.onAddressClick(index);
                  },
                ),
                SizedBox(
                  width: 10,
                ),
                Expanded(
                  flex: 3,
                  child: Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        SizedBox(
                          height: 2,
                        ),
                        Row(
                          children: <Widget>[
                            Text(
                              '${addressData.firstName} ${addressData.lastName}',
                              style: TextStyle(
                                  color: red,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                          '${addressData.number}',
                          style: addressStyle,
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Text(
                          '${addressData.flatNo}, ${addressData.streetName}',
                          style: addressStyle,
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Text(
                          '${addressData.landmark}, ${addressData.city} - ${addressData.pincode}',
                          style: addressStyle,
                        ),
                        // SizedBox(
                        //   height: 5,
                        // ),
                        // Text('Rajasthan-334006',style: addressStyle,),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  width: 10,
                ),
                (addressData.type.isNotEmpty)
                    ? Expanded(
                        flex: 1,
                        child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 5),
                            decoration: BoxDecoration(
                                border: Border.all(
                                    color: textGrey,
                                    style: BorderStyle.solid,
                                    width: 0.7),
                                borderRadius: BorderRadius.circular(4)),
                            child: Text(
                              '${addressData.type}',
                              style: TextStyle(
                                fontSize: 11,
                                color: red,
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.center,
                            )),
                      )
                    : Container(),
                SizedBox(
                  width: 10,
                )
              ],
            ),
          ),
        ),
        Container(
          height: 0.5,
          color: Colors.grey.shade300,
        )
      ],
    );
  }
}

enum ADDRESSTAG { BILLING, SHIPPING }
