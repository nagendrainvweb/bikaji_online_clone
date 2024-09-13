import 'dart:io';

import 'package:bikaji/model/AddressData.dart';
import 'package:bikaji/model/OrderDetailsData.dart';
import 'package:bikaji/model/product.dart';
import 'package:bikaji/pages/cart_full_page.dart';
import 'package:bikaji/pages/cart_page.dart';
import 'package:bikaji/pages/track_view.dart';
import 'package:bikaji/repo/api_provider.dart';
import 'package:bikaji/util/app_helper.dart';
import 'package:bikaji/util/constants.dart';
import 'package:bikaji/util/dialog_helper.dart';
import 'package:bikaji/util/utility.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'order_details.dart';

class OrderConfirmDetails extends StatefulWidget {
  var isDetails;
  final orderNo;
  final status;
  final OrderDetailsData orderData;

  OrderConfirmDetails(
      {this.isDetails, this.status, @required this.orderData, this.orderNo});
  @override
  _OrderConfirmDetailsState createState() => _OrderConfirmDetailsState();
}

class _OrderConfirmDetailsState extends State<OrderConfirmDetails>
    with AppHelper {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Container(
            child: new Column(
              children: <Widget>[
                SizedBox(
                  height: 3,
                ),
                (widget.isDetails) ? _getTopView : Container(),
                (widget.isDetails)
                    ? SizedBox(
                        height: 5,
                      )
                    : Container(),
                (!widget.isDetails)
                    ? TrackView(
                        status: widget.orderData.status,
                      )
                    : Container(),
                (!widget.isDetails)
                    ? SizedBox(
                        height: 5,
                      )
                    : Container(),
                // _getReOrderButton,
                _getOrderDetails,
                SizedBox(
                  height: 5,
                ),
                _getPaymentDetails,
                SizedBox(
                  height: 5,
                ),
                _getShippingDetails(
                    'BILLING ADDRESS', widget.orderData.billingAddress),
                SizedBox(
                  height: 10,
                ),
                _getShippingDetails(
                    'SHIPPING ADDRESS', widget.orderData.shippingAddress),
              ],
            ),
          ),
        ],
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
                  '${addressData.flatNo}, ${addressData.streetName}, ${addressData.landmark}',
                  style: addressStyle,
                ),
                SizedBox(
                  height: 5,
                ),
                Text(
                  '${addressData.city}-${addressData.pincode}',
                  style: addressStyle,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  get _getPaymentDetails {
    OrderDetailsData data = widget.orderData;
    var totalAmount = 0;
    for (var product in data.product) {
      totalAmount = totalAmount + product.amount;
    }
    var payAmount = double.parse(data.payment.paymentAmount);
    var discountAmount = totalAmount - payAmount;
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
                _buildDetailsRow('Total Value', '$rupee$totalAmount',
                    Colors.grey.shade700, FontWeight.normal),
                SizedBox(
                  height: 14,
                ),
                _buildDetailsRow('Delivery Charges (FREE)', '$rupee 0',
                    Colors.grey.shade700, FontWeight.normal),
                SizedBox(
                  height: 14,
                ),
                _buildDetailsRow(
                    'Discount',
                    '- $rupee${discountAmount.toStringAsFixed(2)}',
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
                    '$rupee${payAmount.toStringAsFixed(2)}',
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
            flex: 5,
            child: new Text(
              title,
              style: style,
            ),
          ),
          Text(
            value,
            style: style,
          ),
        ],
      ),
    );
  }

  get _getTopView {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: <Widget>[
          SizedBox(
            height: 20,
          ),
          _getMessage(
              (widget.status == STATUS_SUCESSFUL)
                  ? Icons.check_circle
                  : Icons.error_outline,
              (widget.status == STATUS_SUCESSFUL)
                  ? 'Order Successfully placed!'
                  : "Transaction Failed!",
              (widget.status == STATUS_SUCESSFUL) ? Colors.green : red),
          SizedBox(
            height: 10,
          ),
          Text(
            (widget.status == STATUS_SUCESSFUL)
                ? 'We will send an email to confirm your order details.'
                : "Your order has been failed. Please try again.",
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 11,
            ),
          ),
          SizedBox(
            height: 20,
          ),
          (widget.status == STATUS_SUCESSFUL) ? _trackBtn : Container(),
          SizedBox(
            height: (widget.status == STATUS_SUCESSFUL) ? 15 : 0,
          ),
        ],
      ),
    );
  }

  get _trackBtn {
    return InkWell(
      onTap: () {
        Utility.pushToNext(
            OrderDetails(
              orderId: widget.orderData.status.id,
            ),
            context);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        color: Colors.red.shade400,
        child: Text(
          'TRACK ORDER',
          style: TextStyle(color: Colors.white, fontSize: 11),
        ),
      ),
    );
  }

  get _getOrderDetails {
    OrderDetailsData data = widget.orderData;
    var payAmount = double.parse(data.payment.paymentAmount).toStringAsFixed(2);
    // var totalAmount = 0;
    // for (var product in data.product) {
    //   totalAmount = totalAmount + product.amount;
    // }

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
                      text: 'ORDER ID ',
                      style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                          fontWeight: FontWeight.w700),
                      children: <TextSpan>[
                        TextSpan(
                            text: '  #${widget.orderData.status?.orderId}',
                            style: TextStyle(color: Colors.grey.shade700))
                      ]),
                ),
                Text(
                  '${rupee}${payAmount}',
                  style: TextStyle(
                      fontSize: 14,
                      color: Colors.red.shade400,
                      fontWeight: FontWeight.w600),
                )
              ],
            ),
          ),
          Container(
            height: 1,
            color: Colors.grey.shade300,
          ),
          ListView(
            shrinkWrap: true,
            physics: ClampingScrollPhysics(),
            children: List.generate(data.product.length, (index) {
              return _productRow(index);
            }),
          ),
          
        ],
      ),
    );
  }

  get _getReorderButton {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          MaterialButton(
              onPressed: () {
                List<Product> list = widget.orderData.product;
                 progressDialog(context, "Please wait..");
                _performReorder(list);
              },
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
              color: green,
              textColor: Colors.white,
              
              child: Row(
                children: [
                  Text(
                    'REORDER',
                    style: TextStyle(fontSize: 13),
                  ),
                  // SizedBox(width:8),
                  // Icon(Icons.chevron_right,color:Colors.white),
                ],
              )),
        ],
      ),
    );
  }

  _performReorder(List<Product> productList) async {
    try {
      if (productList.isNotEmpty) {
        final product = productList.last;
       
        final response = await ApiProvider()
            .addToCart(product.id, product.qty, product.size_id);
        if(response.status == Constants.success){
          productList.removeLast();
          if(productList.isNotEmpty){
            _performReorder(productList);
          }else{
            hideProgressDialog(context);
            Utility.pushToNext(CartMainPage(), context);
          }
         
        }else{
          hideProgressDialog(context);
         DialogHelper.showErrorDialog(context, "Error", response.message);
        }
      }
    }on SocketException catch (e) {
      hideProgressDialog(context);
      DialogHelper.showErrorDialog(context, "Error", "No Internet Connection");
    }on Exception catch(e){
      myPrint(e.toString());
      hideProgressDialog(context);
      DialogHelper.showErrorDialog(context, "Error", SOMETHING_WRONG_TEXT);
    }
  }

  _productRow(int index) {
    List<Product> list = widget.orderData.product;
    var total =
        int.parse('${list[index].newPrice}') * int.parse('${list[index].qty}');
    var selectedSize = "";
    var price = list[index].newPrice;
    for (Sizes size in list[index].sizes) {
      if (price ==
          (list[index].newPrice + double.parse(size.newPrice)).toInt()) {
        selectedSize = '(${size.size})';
        list[index].size_id = int.parse(size.id);
      }
    }
    return Container(
      child: Stack(
        children: <Widget>[
          Column(
            children: <Widget>[
              new Container(
                color: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                child: new Row(
                  children: <Widget>[
                    new SizedBox(
                      width: 55,
                      child: (list[index].images.length > 0)
                          ? CachedNetworkImage(
                              imageUrl: list[index].images[0].imageUrl,
                              placeholder: (context, data) {
                                return Container(
                                  child: new Center(
                                    child: SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: new CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    ),
                                  ),
                                );
                              },
                              fit: BoxFit.cover,
                            )
                          : Image.asset('assets/no_image.png'),
                    ),
                    SizedBox(
                      width: 20,
                    ),
                    Expanded(
                      flex: 1,
                      child: new Container(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              list[index].name,
                              style: TextStyle(
                                  color: Colors.grey.shade700,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500),
                            ),
                            (list[index].sizes.length > 0)
                                ? SizedBox(
                                    height: 3,
                                  )
                                : Container(),
                            Text(
                              '$selectedSize',
                              style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500),
                            ),
                            SizedBox(
                              height: 8,
                            ),
                            Container(
                              child: Row(
                                children: <Widget>[
                                  Text(
                                    '${list[index].qty}',
                                    style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey.shade600,
                                        fontWeight: FontWeight.w500),
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
                                    width: 10,
                                  ),
                                  Text(
                                    '₹${list[index].newPrice}',
                                    style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey.shade600,
                                        fontWeight: FontWeight.w500),
                                  ),
                                  SizedBox(
                                    width: 8,
                                  ),
                                  // Text(
                                  //   '₹$total',
                                  //   style: TextStyle(
                                  //       fontSize: 13,
                                  //       color: Colors.grey.shade500,
                                  //       fontWeight: FontWeight.w500,
                                  //       decoration: TextDecoration.lineThrough),
                                  // ),
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
                                  text: '₹$total',
                                  style: TextStyle(
                                      fontSize: 15,
                                      color: Colors.grey.shade700,
                                      fontWeight: FontWeight.w600)),
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
                height: 1,
                color: Colors.grey.shade300,
              )
            ],
          ),
          // Container(
          //     padding: EdgeInsets.only(top: 2),
          //     child: Utility.offerWidget('5% OFF')),
        ],
      ),
    );
  }

  _getMessage(var icon, var text, var color) {
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(
            icon,
            color: color,
          ),
          SizedBox(
            width: 10,
          ),
          Text(
            text,
            style: TextStyle(
                color: color, fontSize: 18, fontWeight: FontWeight.w600),
          )
        ],
      ),
    );
  }
}
