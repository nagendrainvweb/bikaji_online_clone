import 'dart:io';

import 'package:bikaji/model/PastOrderData.dart';
import 'package:bikaji/model/product.dart';
import 'package:bikaji/pages/cart_full_page.dart';
import 'package:bikaji/repo/Repository.dart';
import 'package:bikaji/repo/api_provider.dart';
import 'package:bikaji/util/app_helper.dart';
import 'package:bikaji/util/constants.dart';
import 'package:bikaji/util/dialog_helper.dart';
import 'package:bikaji/util/textStyle.dart';
import 'package:bikaji/util/url_list.dart';
import 'package:bikaji/util/utility.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'order_details.dart';

class OrderPage extends StatefulWidget {
  @override
  _OrderPageState createState() => _OrderPageState();
}

enum OrderTag { PAST, UPCOMING }

class _OrderPageState extends State<OrderPage>
    with AppHelper, TickerProviderStateMixin {
  OrderTag _tag = OrderTag.PAST;
  TabController _tabController;
  List<PastOrderData> _orderList;
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  bool isError = false;

  @override
  void initState() {
    _tabController = TabController(vsync: this, length: 2);
    _tabController.addListener(() {
      setState(() {
        if (_tabController.index == 0) {
          _tag = OrderTag.PAST;
        } else {
          _tag = OrderTag.UPCOMING;
        }
      });
    });

    super.initState();
    _checkConnection();
    _fetchData();
  }

  _fetchData() async {
    try {
      final response =
          await ApiProvider().fetchPastOrders();
      if (response.status == UrlConstants.SUCCESS) {
        setState(() {
          _orderList = response.data;
          isError = false;
        });
      } else {
        setState(() {
          isError = true;
        });

        // Utility.showSnackBar(_scaffoldKey, onRetryCliked: () {
        //   _fetchData();
        // });
      }
    } catch (e) {
      myPrint(e.toString());
      DialogHelper.showErrorDialog(context, "Error", SOMETHING_WRONG_TEXT,
          showTitle: true, onOkClicked: () {
        Navigator.pop(context);
        Navigator.pop(context);
      });
    }
  }

  _checkConnection() async {
    bool isInternet = await Utility.getConenctionStatus();
    if (!isInternet) DialogHelper().showNoInternetDialog(context);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(45),
        child: AppBar(
          backgroundColor: Colors.red.shade500,
          elevation: 0,
          title: Text(
            'Orders',
            style: toolbarStyle,
          ),
          leading: IconButton(
            icon: Icon(Icons.chevron_left),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ),
      ),
      body: (!isError)
          ? (_orderList != null)
              ? (_orderList.length > 0)
                  ? Container(
                      color: Colors.grey.shade100,
                      child: Column(
                        children: <Widget>[
                          Expanded(
                            child: _orderView,
                          )
                        ],
                      ),
                    )
                  // if list is empty then show no data view
                  : _getNoDataView
              : Center(child: CircularProgressIndicator())
          : _getNoDataView,
    );
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
              Image.asset(
                'assets/empty_bag.png',
              ),
              SizedBox(
                height: 20,
              ),
              Text(
                "It's quite empty here !",
                style: extraBigTextStyle,
              ),
              SizedBox(
                height: 8,
              ),
              Text(
                "You haven't order any product !",
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

  get _orderView {
    return Container(
      child: OrderList(
        orderList: _orderList,
      ),
    );
  }

  get _getTopBar {
    return Container(
      color: Colors.white,
      child: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              Expanded(
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _tag = OrderTag.PAST;
                      _tabController.animateTo(0);
                    });
                  },
                  child: Column(
                    children: <Widget>[
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Text(
                          'PAST ORDERS',
                          style: TextStyle(
                              color: Colors.grey.shade800, fontSize: 12),
                        ),
                      ),
                      AnimatedContainer(
                        duration: Duration(milliseconds: 200),
                        width:
                            (_tag == OrderTag.PAST || _tabController.index == 0)
                                ? 120
                                : 0,
                        height: 2,
                        color: Colors.red.shade400,
                      )
                    ],
                  ),
                ),
              ),
              Expanded(
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _tag = OrderTag.UPCOMING;
                      _tabController.animateTo(1);
                    });
                  },
                  child: Column(
                    children: <Widget>[
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Text(
                          'UPCOMING ORDERS',
                          style: TextStyle(
                              color: Colors.grey.shade800, fontSize: 12),
                        ),
                      ),
                      AnimatedContainer(
                        duration: Duration(milliseconds: 200),
                        width: (_tag == OrderTag.UPCOMING ||
                                _tabController.index == 1)
                            ? 120
                            : 0,
                        height: 2,
                        color: Colors.red.shade400,
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class OrderList extends StatefulWidget {
  final List<PastOrderData> orderList;

  OrderList({@required this.orderList});

  @override
  _OrderListState createState() => _OrderListState();
}

class _OrderListState extends State<OrderList> with AppHelper {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: ListView.builder(
        itemCount: widget.orderList.length,
        itemBuilder: (context, index) {
          return _orderRow(index, context);
        },
      ),
    );
  }

  _performReorder(List<Product> productList) async {
    try {
      if (productList.isNotEmpty) {
        final product = productList.last;

        final response = await ApiProvider()
            .addToCart(product.id, product.qty, product.size_id);
        if (response.status == Constants.success) {
          productList.removeLast();
          if (productList.isNotEmpty) {
            _performReorder(productList);
          } else {
            hideProgressDialog(context);
            Utility.pushToNext(CartMainPage(), context);
          }
        } else {
          hideProgressDialog(context);
          DialogHelper.showErrorDialog(context, "Error", response.message);
        }
      }
    } on SocketException catch (e) {
      hideProgressDialog(context);
      DialogHelper.showErrorDialog(context, "Error", "No Internet Connection");
    } on Exception catch (e) {
      myPrint(e.toString());
      hideProgressDialog(context);
      DialogHelper.showErrorDialog(context, "Error", SOMETHING_WRONG_TEXT);
    }
  }

  _orderRow(int index, var context) {
    final data = widget.orderList[index];
    DateFormat dateFormat = DateFormat("dd/MM/yyyy hh:mm:ss");
    DateTime dateTime = dateFormat.parse(data.orderDate);
    DateTime statusDateTime = dateFormat.parse(data.statusDate);
    String formattedOrderDate = DateFormat('dd MMM yyyy').format(dateTime);
    String formattedStatusDate =
        DateFormat('dd MMM yyyy').format(statusDateTime);
    return InkWell(
      onTap: () {
        Utility.pushToNext(
            OrderDetails(
              orderId: data.id,
              orderNo: data.orderId,
            ),
            context);
      },
      child: Container(
        child: Column(
          children: <Widget>[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 24),
              color: Colors.white,
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          RichText(
                            text: TextSpan(
                                text: 'Order ',
                                style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey.shade500,
                                    fontWeight: FontWeight.w700),
                                children: <TextSpan>[
                                  TextSpan(
                                      text: '#${data.orderId}',
                                      style: TextStyle(
                                          color: Colors.grey.shade700))
                                ]),
                          ),
                          SizedBox(
                            height: 8,
                          ),
                          Text(
                            '${formattedOrderDate}',
                            style:
                                TextStyle(fontSize: 9, color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            '${formattedStatusDate}',
                            style: TextStyle(
                                fontSize: 10, color: Colors.grey[600]),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Text(
                            '${data.status}',
                            style: TextStyle(
                                fontSize: 11,
                                color: Colors.green,
                                fontStyle: FontStyle.italic),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            'View Order >',
                            style: TextStyle(
                                fontSize: 12,
                                color: Colors.red[400],
                                fontWeight: FontWeight.bold),
                          ),
                        (data.status == "complete")?  _getReorderButton(data):Container()
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
            Container(
              height: 1,
              color: Colors.grey.shade200,
            )
          ],
        ),
      ),
    );
  }

   _getReorderButton(PastOrderData data) {
    return Column(
      children: [
        SizedBox(
          height: 12,
        ),
        InkWell(
            onTap: () {
             _getOrderDetails(data);
            },
            child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25),
                  color: green,
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 6),
                child: Text('REORDER',
                    style: TextStyle(fontSize: 10, color: Colors.white)))),
      ],
    );
  }

  _getOrderDetails(PastOrderData data)async{
    try{
      progressDialog(context, "Please wait...");
      final response = await ApiProvider().fetchOrderDetails(data.id);
      hideProgressDialog(context);
      if(response.status == Constants.success){
        final list = response.data.product;
        _performReorder(list);
      }else{
          DialogHelper.showErrorDialog(context, "Error", response.message);
      }
    }on SocketException catch(e){
      hideProgressDialog(context);
      DialogHelper.showErrorDialog(context, "Error", "No internet connection");
    }on Exception catch(e){
      hideProgressDialog(context);
       DialogHelper.showErrorDialog(context, "Error", SOMETHING_WRONG_TEXT);
    }
    

  }
}
