import 'dart:io';

import 'package:bikaji/model/OrderDetailsData.dart';
import 'package:bikaji/model/product.dart';
import 'package:bikaji/pages/cart_full_page.dart';
import 'package:bikaji/pages/order_confirm_details.dart';
import 'package:bikaji/repo/Repository.dart';
import 'package:bikaji/repo/api_provider.dart';
import 'package:bikaji/util/app_helper.dart';
import 'package:bikaji/util/constants.dart';
import 'package:bikaji/util/dialog_helper.dart';
import 'package:bikaji/util/textStyle.dart';
import 'package:bikaji/util/url_list.dart';
import 'package:bikaji/util/utility.dart';
import 'package:flutter/material.dart';

class OrderDetails extends StatefulWidget {
  final orderId;
  final orderNo;
  OrderDetails({@required this.orderId,this.orderNo});
  @override
  _OrderDetailsState createState() => _OrderDetailsState();
}

class _OrderDetailsState extends State<OrderDetails> with AppHelper{

  OrderDetailsData _orderData;
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  void initState() {
    super.initState();
    _getData();
  }
  _getData()async{
    try{
      final response = await ApiProvider().fetchOrderDetails(widget.orderId);
      if(response.status == UrlConstants.SUCCESS){
        setState(() {
          _orderData = response.data;
        });
      }else{
        Utility.showSnackBar(_scaffoldKey,onRetryCliked: (){
          _getData();
        });
      }
    }catch(e){
      myPrint(e.toString());
      DialogHelper.showErrorDialog(context, "Error", SOMETHING_WRONG_TEXT,showTitle: true,onOkClicked: (){
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
            backgroundColor: red,
            elevation: 0,
            title: Text('Order Details', style: toolbarStyle),
            leading: IconButton(
              icon: Icon(Icons.chevron_left),
              onPressed: (){
                Navigator.pop(context);
              },
            ),
          )),
      body:(_orderData != null)?Container(
          color: Colors.grey.shade100,
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  children: <Widget>[
                    OrderConfirmDetails(isDetails: false,orderData: _orderData,orderNo:widget.orderNo),
                  ],
                ),
              ),
            (_orderData.status.status == "complete")?  _getReorderButton:Container()
            ],
          )):Center(child: CircularProgressIndicator(),),
    );
  }

    get _getReorderButton {
    return InkWell(
        onTap: () {
          List<Product> list = _orderData.product;
           progressDialog(context, "Please wait..");
          _performReorder(list);
        },
        // shape: RoundedRectangleBorder(
        //   borderRadius: BorderRadius.circular(25),
        // ),
        child: Container(
          width: double.infinity,
           padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
        color: green,
          child: Text(
            'REORDER',
            textAlign: TextAlign.center,
            style: TextStyle(color:Colors.white),
          ),
        ));
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

  
}
