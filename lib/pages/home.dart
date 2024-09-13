import 'dart:convert';

import 'package:bikaji/bloc/DashboardBloc/DashboardBloc.dart';
import 'package:bikaji/bloc/DashboardBloc/DashboardEvent.dart';
import 'package:bikaji/bloc/DashboardBloc/DashboardState.dart';
import 'package:bikaji/bloc/product_bloc/ProdcutBloc.dart';
import 'package:bikaji/bloc/product_bloc/ProductState.dart';
import 'package:bikaji/model/DashboardData.dart';
import 'package:bikaji/model/product.dart';
import 'package:bikaji/pages/productDetails.dart';
import 'package:bikaji/pages/productView.dart';
import 'package:bikaji/prefrence_util/Prefs.dart';
import 'package:bikaji/repo/Repository.dart';
import 'package:bikaji/repo/api_provider.dart';
import 'package:bikaji/util/app_helper.dart';
import 'package:bikaji/util/dialog_helper.dart';
import 'package:bikaji/util/textStyle.dart';
import 'package:bikaji/util/url_list.dart';
import 'package:bikaji/util/utility.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:percent_indicator/percent_indicator.dart';

import 'custom_carousel.dart';
import 'dashboard_page.dart';

Widget setTopLine(var title, var textColor, Function onClick) {
  return new Container(
    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 0),
    child: new Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: <Widget>[
        new Text(
          title,
          style: TextStyle(
              color: textColor, fontWeight: FontWeight.w500, fontSize: 14),
        ),
        SizedBox(
          width: 8,
        ),
        SizedBox(
          width: 8,
        ),
        InkWell(
          onTap: onClick,
          child: Container(
            padding: const EdgeInsets.all(5),
            child: new Text(
              'View All  >',
              style: TextStyle(
                  color: textColor, fontWeight: FontWeight.w500, fontSize: 11),
            ),
          ),
        )
      ],
    ),
  );
}

class HomePage extends StatefulWidget {
  Function onRefresh;
  var cartCount;
  HomePage({@required this.onRefresh, @required this.cartCount});
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with AppHelper {
  DashboardBloc dashboardBloc;
  DashboardData _dashboardData;

  @override
  void initState() {
    super.initState();
    dashboardBloc = BlocProvider.of<DashboardBloc>(context);
    //setData();
    dashboardBloc.add(FetchDashboardEvent());
    checkUpdate();
    // fetchState();
  }

  checkUpdate() async {
    final notificationDateTime = await Prefs.notificationDateTime;
    if (notificationDateTime == 0) {
      Prefs.setNotificationDateTime(DateTime.now().millisecondsSinceEpoch);
    }
    try {
      final response = await ApiProvider().fetchUpdate();
      if (response.status == UrlConstants.SUCCESS) {
        if (response.isUpdate == 1) {
          DialogHelper.showUpdateDialog(context, response);
        }
      }
    } catch (e) {
      myPrint(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        color: Colors.white,
        child: BlocBuilder<DashboardBloc, DashboardState>(
          builder: (context, state) {
            if (state is DashboardLoadingState) {
              //  progressDialog(context, 'Please wait..');
              return Center(child: CircularProgressIndicator());
            } else if (state is DashboardSuccessState) {
              // hideProgressDialog(context);
              if (_dashboardData == null) {
                widget.onRefresh();
              }
              _dashboardData = state.getResponse;

              // widget.onRefresh();
              return HomeWidget(
                widget: widget,
                cartCount: widget.cartCount,
                dashboardData: _dashboardData,
              );
            } else if (state is DashboardFailedState) {
              myPrint(state.getResponse);
              //hideProgressDialog(context);
              return HomeErrorWidget(
                message: state.getResponse.message,
                onRetryCliked: () async {
                  await Prefs.setDashboardData("");
                  dashboardBloc.add(FetchDashboardEvent());
                },
              );
            } else if (state is DashboardNotLoadedState) {
              // hideProgressDialog(context);
              myPrint(state.message);
              return HomeErrorWidget(
                message: state.message,
                onRetryCliked: () async {
                  await Prefs.setDashboardData("");
                  dashboardBloc.add(FetchDashboardEvent());
                },
              );
            }
          },
        ));
  }
}

class HomeErrorWidget extends StatelessWidget {
  const HomeErrorWidget(
      {Key key, @required this.message, @required this.onRetryCliked})
      : super(key: key);

  final message;
  final onRetryCliked;
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 50),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Icon(
              Icons.info_outline,
              color: Colors.grey.shade700,
              size: 70,
            ),
            SizedBox(
              height: 20,
            ),
            Text(
              "Sorry, Something went wrong",
              textAlign: TextAlign.center,
              style: extraBigTextStyle,
            ),
            SizedBox(
              height: 8,
            ),
            Text(
              "Try reloading the page. We're working hard to fix problem for you as soon as possible",
              textAlign: TextAlign.center,
              style: smallTextStyle,
            ),
            SizedBox(
              height: 20,
            ),
            InkWell(
              onTap: () {
                onRetryCliked();
                //Utility.pushToDashboard(context, 0);
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5), color: blackGrey),
                child: Text(
                  'RETRY',
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
}

class HomeWidget extends StatelessWidget {
  HomeWidget(
      {Key key,
      @required this.widget,
      @required this.dashboardData,
      @required this.cartCount})
      : super(key: key);

  final HomePage widget;
  var cartCount;
  final DashboardData dashboardData;

  @override
  Widget build(BuildContext context) {
    dashboardData.banner.removeWhere((data) =>
        (data.imageUrl.contains("playstore.png") ||
            data.imageUrl.contains("istore.png")));
    return RefreshIndicator(
      onRefresh: () async {
        DashboardBloc dashboardBloc = BlocProvider.of<DashboardBloc>(context);
        dashboardBloc.add(RefreshDashboardEvent());
        await Future.delayed(Duration(seconds: 2));
        return true;
      },
      child: ListView(
        children: <Widget>[
          new Container(
            color: Colors.grey.shade200,
            height: 200,
            child: CustomCarousel(true, bannerList: dashboardData.banner),
          ),
          Container(
              child: new ListView(
            physics: ClampingScrollPhysics(),
            shrinkWrap: true,
            children: <Widget>[
              SizedBox(
                height: 8,
              ),
              (dashboardData.products[0].title == "exclusive")
                  ? LatestProduct(
                      title: 'BIKAJI EXCLUSIVE',
                      type: dashboardData.products[1].title,
                      list: dashboardData.products[1].items,
                      onRefresh: widget.onRefresh,
                    )
                  : Container(),
              SizedBox(
                height: 8,
              ),
              (dashboardData.products[2].title == "topSeller")
                  ? TopSellers(
                      'Top Seller',
                      type: dashboardData.products[2].title,
                      productList: dashboardData.products[2].items,
                      onRefresh: widget.onRefresh,
                    )
                  : Container(),
              SizedBox(
                height: 8,
              ),
              // (dashboardData.products[1].title == "newArrivals")
              //     ? NewArrival(
              //         'NEW ARRIVALS',
              //         id: "",
              //         onRefresh: widget.onRefresh,
              //         type: dashboardData.products[1].title,
              //         productList: dashboardData.products[1].items,
              //       )
              //     : Container()
              // TopSellers()
            ],
          )),
        ],
      ),
    );
  }
}

class LatestProduct extends StatefulWidget {
  Function onRefresh;
  final title;
  final type;
  List<Product> list;
  LatestProduct({this.onRefresh, this.title, this.list, this.type});
  @override
  _LatestProductState createState() => _LatestProductState();
}

class _LatestProductState extends State<LatestProduct> {
  @override
  Widget build(BuildContext context) {
    return Container(
        color: Colors.grey.shade100,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(
              height: 5,
            ),
            setTopLine(widget.title, Colors.grey.shade600, () {
              Utility.pushToNext(
                      BlocProvider(
                        create: (BuildContext context) =>
                            ProductBloc(ProductLoadingState()),
                        child: ProductView(
                          title: widget.title,
                          id: "",
                          type: widget.type,
                        ),
                      ),
                      context)
                  .then((value) {
                widget.onRefresh();
                BlocProvider.of<DashboardBloc>(context)
                    .add(RefreshDashboardEvent());
              });
              // Utility.pushToNext(ProductView(title: widget.title,id: "",type: widget.type,), context);
            }),
            Container(
              // color: lightOrange,
              height: 270,
              child: new ListView(
                scrollDirection: Axis.horizontal,
                children: List.generate(widget.list.length, (position) {
                  return _setLatestRow(widget.list[position], position);
                }),
              ),
            ),
            SizedBox(
              height: 20,
            ),
          ],
        ));
  }

  _getLatestTitle(var position) {
    return Container(
      padding: const EdgeInsets.all(15),
      margin: const EdgeInsets.only(left: 18),
      child: Text(
        'BIKAJI EXCLUSIVE',
        style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 14,
            fontWeight: FontWeight.w500),
      ),
    );
  }

  Widget _setLatestRow(Product product, var position) {
    var halfWeight = MediaQuery.of(context).size.width - 100;
    return InkWell(
      onTap: () {
        Utility.pushToNext(
                ProductDetails(
                  productId: product.id,
                ),
                context)
            .then((value) {
          widget.onRefresh();
          BlocProvider.of<DashboardBloc>(context).add(RefreshDashboardEvent());
        });
      },
      child: new Container(
        width: 280,
        margin: EdgeInsets.only(left: (position != 0) ? 3 : 20),
        //  color: (position % 2 == 0) ? lightOrange : orangeDark,
        child: Card(
          child: Container(
            padding: const EdgeInsets.all(8),
            child: Stack(
              children: <Widget>[
                Container(
                  child: new Container(
                    child: _getExclusiveProduct(product),
                  ),
                ),
                new Stack(
                  children: <Widget>[
                    Align(
                      alignment: Alignment.topRight,
                      child: new Container(
                        margin: EdgeInsets.only(top: 6.0, right: 6),
                        child: InkWell(
                          onTap: () async {
                            myPrint('fav cliked..');
                            bool value = await Utility.performWishList(
                                context,
                                Scaffold.of(context).context,
                                product.id,
                                product.isInWishlist,
                                true);
                            setState(() {
                              if (value??false) {
                                product.isInWishlist = !product.isInWishlist;
                              }
                            });
                          },
                          child: Icon(
                            Icons.favorite,
                            color: (product.isInWishlist)
                                ? Colors.red
                                : Colors.grey.shade400,
                            size: 18,
                          ),
                        ),
                      ),
                    ),
                    // Align(
                    //   alignment: Alignment.topLeft,
                    //   child: new Container(
                    //       color: Colors.green.shade700,
                    //       margin: EdgeInsets.only(top: 8.0),
                    //       child: new Container(
                    //         padding: EdgeInsets.all(4),
                    //         child: new Text(
                    //           '5% OFF',
                    //           style:
                    //               TextStyle(color: Colors.white, fontSize: 8),
                    //         ),
                    //       )),
                    // ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  _getExclusiveProduct(Product product) {
    return Container(
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          _getImage(product),
          Expanded(
            child: _getBottomDetails(product),
          )
        ],
      ),
    );
  }

  Widget setItemCount(Product product) {
    return new Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        //border: Border.all(color: red,width: 0.2,style: BorderStyle.solid)
      ),
      child: Container(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            InkWell(
              onTap: () {
                // if (product.qty > 1) {
                //   setState(() {
                //     // product.qty--;
                //   });
                // } else {
                //   setState(() {
                //     widget.cartCount--;
                //     product.isInCart = !product.isInCart;
                //   });
                //   widget.onRefresh();
                // }
              },
              child: ClipRRect(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    bottomLeft: Radius.circular(20)),
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                  color: red,
                  child: new Text(
                    ' ━ ',
                    style: TextStyle(color: Colors.white, fontSize: 8),
                  ),
                ),
              ),
            ),
            Container(
                padding: EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                color: Colors.white,
                child: new Text(
                  product.qty.toString(),
                  style: TextStyle(fontSize: 9, fontWeight: FontWeight.w500),
                )),
            InkWell(
              onTap: () {
                setState(() {
                  // product.qty++;
                });
              },
              child: ClipRRect(
                  borderRadius: BorderRadius.only(
                      topRight: Radius.circular(20),
                      bottomRight: Radius.circular(20)),
                  child: Container(
                      padding: EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                      color: red,
                      child: new Text(' ✚ ',
                          style: TextStyle(color: Colors.white, fontSize: 8)))),
            ),
          ],
        ),
      ),
    );
  }

  _getBottomDetails(Product product) {
    return Container(
      padding: const EdgeInsets.only(top: 8, left: 8, right: 8, bottom: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SizedBox(
                    height: 8,
                  ),
                  _getTitle(product.name),
                  SizedBox(
                    height: 12,
                  ),
                  Expanded(
                    child: Text(
                      '${product.desc}',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey.shade500,
                          height: 1.2,
                          fontWeight: FontWeight.w400),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            width: 6,
          ),
          new Column(
            children: <Widget>[
              SizedBox(
                height: 8,
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    '₹${product.newPrice}',
                    style: TextStyle(
                        fontSize: 12, color: red, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              SizedBox(
                height: 22,
              ),
              Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  (!product.isInStock)
                      ? Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5),
                          child: Text(
                            'OUT OF STOCK',
                            style: smallTextStyle,
                          ))
                      : Utility.customRoundedWidget(
                          'ADD TO CART',
                          red,
                          onClick: () {
                            Utility.showMoveToBagBottomSheet(context,
                                product: product,
                                onDoneClick: (int quntity, Sizes size) async {
                              Navigator.pop(context);
                              bool value = await Utility.addToCart(context,
                                  null, product.id, quntity, size?.id, true);
                              if (value) {
                                // int cartCount = await Prefs.cartCount;
                                // cartCount++;
                                // Prefs.setCartCount(cartCount);
                                widget.onRefresh();
                              }
                            });
                          },
                        ),
                ],
              )
            ],
          )
        ],
      ),
    );
  }

  _getTitle(var title) {
    return Container(
      child: Text(
        title,
        style:
            TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.w500),
      ),
    );
  }

  _getImage(Product product) {
    return ClipRRect(
        borderRadius: new BorderRadius.circular(3.0),
        child: Container(
         // color: Colors.deepOrange,
          //width: double.infinity,
          // decoration: BoxDecoration(
          // //  color: Colors.deepOrange
          //   //image: DecorationImage(image: AssetImage('assets/banner_3.jpg',),fit: BoxFit.cover)
          // ),
          child: (product.images.length > 0)
              ? CachedNetworkImage(
                  height: 150,
                  width: double.infinity,
                  imageUrl: product.images[0].imageUrl,
                  placeholder: (context, data) {
                    return Container(
                      height: 150,
                      child: new Center(
                        child: new CircularProgressIndicator(),
                      ),
                    );
                  },
                  fit: BoxFit.cover
                )
              : Image.asset(
                  'assets/no_image.png',
                  fit: BoxFit.cover,
                  height: 150,
                  // width: double.infinity,
                ),
        ));
  }
}

class TopSellers extends StatefulWidget {
  String title;
  List<Product> productList;
  Function onRefresh;
  final type;
  TopSellers(this.title,
      {this.onRefresh, @required this.productList, @required this.type});
  @override
  _TopSellersState createState() => _TopSellersState();
}

class _TopSellersState extends State<TopSellers> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey.shade100,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // setTopLine(widget.title, Colors.white),
          Container(
            color: Colors.grey.shade100,
            child: setTopLine('BEST SELLERS', Colors.grey.shade600, () {
              Utility.pushToNext(
                      BlocProvider(
                        create: (BuildContext context) =>
                            ProductBloc(ProductLoadingState()),
                        child: ProductView(
                          title: widget.title,
                          id: "",
                          type: widget.type,
                        ),
                      ),
                      context)
                  .then((value) {
                widget.onRefresh();
                BlocProvider.of<DashboardBloc>(context)
                    .add(RefreshDashboardEvent());
              });
            }),
          ),

          SizedBox(
            height: 5,
          ),
          _setTopSellingProducts(),
        ],
      ),
    );
  }

  get _getLatestTitle {
    return Container(
      // margin: const EdgeInsets.only(left: 20),
      padding: const EdgeInsets.all(15),
      child: Text(
        'TOP SELLERS',
        style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 14,
            fontWeight: FontWeight.w500),
      ),
    );
  }

  Widget _setTopSellingProducts() {
    return Container(
        //color: Colors.grey.shade100,
        margin: const EdgeInsets.symmetric(horizontal: 10),
        child: Container(
          child: new Column(
            children: List.generate(
                // (widget.productList.length > 5)
                //     ? widget.productList.length - 5:
                widget.productList.length, (position) {
              return InkWell(
                onTap: () {
                  Utility.pushToNext(
                          ProductDetails(
                            productId: widget.productList[position].id,
                          ),
                          context)
                      .then((value) {
                    widget.onRefresh();
                    BlocProvider.of<DashboardBloc>(context)
                        .add(RefreshDashboardEvent());
                  });
                },
                child: _getProductView(position),
              );
            }),
          ),
        ));
  }

  _getProductView(int position) {
    final product = widget.productList[position];
    return Container(
      child: Column(
        children: <Widget>[
          Container(
            padding:
                const EdgeInsets.only(top: 15, bottom: 15, left: 10, right: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: (product.images.length > 0)
                      ? CachedNetworkImage(
                          imageUrl: product.images[0].imageUrl,
                          width: 80,
                          height: 80,
                          placeholder: (context, data) {
                            return Container(
                              width: 70,
                              child: new Center(
                                child: SizedBox(
                                  width: 30,
                                  height: 30,
                                  child: new CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                              ),
                            );
                          },
                          fit: BoxFit.cover,
                        )
                      : Image.asset(
                          'assets/no_image.png',
                          width: 70,
                          height: 70,
                        ),
                ),
                SizedBox(
                  width: 15,
                ),
                Expanded(
                  child: Center(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.max,
                      children: <Widget>[
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                          product.name,
                          style: TextStyle(
                              fontSize: 13, color: Colors.grey.shade800),
                        ),
                        SizedBox(
                          height: 4,
                        ),
                        Row(
                          children: <Widget>[
                            Text(
                              "₹" + '${product.newPrice}',
                              style: TextStyle(
                                  fontSize: 12,
                                  color: red,
                                  fontWeight: FontWeight.w600),
                            ),
                            // SizedBox(
                            //   width: 5,
                            // ),
                            // Text(
                            //   "₹" + '${product.newPrice}',
                            //   style: TextStyle(
                            //       fontSize: 11,
                            //       color: Colors.grey.shade500,
                            //       fontWeight: FontWeight.w600,
                            //       decoration: TextDecoration.lineThrough),
                            // ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  width: 10,
                ),
                Container(
                  margin: const EdgeInsets.only(top: 10),
                  child: Row(
                    children: <Widget>[
                      InkWell(
                        child: Icon(
                          Icons.favorite,
                          color: (product.isInWishlist)
                              ? red
                              : Colors.grey.shade400,
                          size: 15,
                        ),
                        onTap: () async {
                          bool value = await Utility.performWishList(
                              context,
                              Scaffold.of(context).context,
                              product.id,
                              product.isInWishlist,
                              true);
                          setState(() {
                            if (value??false) {
                              product.isInWishlist = !product.isInWishlist;
                            }
                          });
                        },
                      ),
                      SizedBox(
                        width: 15,
                      ),
                      Container(
                        width: 90,
                        child: Center(
                          child: (!product.isInStock)
                              ? Container(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 5),
                                  child: Text(
                                    'OUT OF STOCK',
                                    style: smallTextStyle,
                                  ))
                              : Utility.customRoundedWidget('ADD TO CART', red,
                                  onClick: () {
                                  Utility.showMoveToBagBottomSheet(context,
                                      product: product, onDoneClick:
                                          (int quntity, Sizes size) async {
                                    Navigator.pop(context);
                                    bool value = await Utility.addToCart(
                                        context,
                                        null,
                                        product.id,
                                        quntity,
                                        size?.id,
                                        true);
                                    if (value) {
                                      // int cartCount = await Prefs.cartCount;
                                      // cartCount++;
                                      // Prefs.setCartCount(cartCount);
                                      widget.onRefresh();
                                    }
                                  });
                                }),
                        ),
                      ),
                      // Utility.customRoundedWidget("ADD TO CART", red)
                    ],
                  ),
                )
              ],
            ),
          ),
          (position != widget.productList.length - 1)
              ? Container(
                  height: 1,
                  color: Colors.grey.shade200,
                )
              : Container()
        ],
      ),
    );
  }

  Widget setItemCount(Product product) {
    return new Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        //border: Border.all(color: red,width: 0.2,style: BorderStyle.solid)
      ),
      child: Container(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            InkWell(
              onTap: () {
                // if (product.qty > 1) {
                //   setState(() {
                //     //product.qty--;
                //   });
                // } else {
                //   setState(() {
                //     product.isInCart = !product.isInCart;
                //     cartCount--;
                //   });
                //   widget.onRefresh();
                // }
              },
              child: ClipRRect(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    bottomLeft: Radius.circular(20)),
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                  color: red,
                  child: new Text(
                    ' ━ ',
                    style: TextStyle(color: Colors.white, fontSize: 8),
                  ),
                ),
              ),
            ),
            Container(
                padding: EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                color: Colors.white,
                child: new Text(
                  product.qty.toString(),
                  style: TextStyle(fontSize: 9, fontWeight: FontWeight.w500),
                )),
            InkWell(
              onTap: () {
                setState(() {
                  // product.qty++;
                });
              },
              child: ClipRRect(
                  borderRadius: BorderRadius.only(
                      topRight: Radius.circular(20),
                      bottomRight: Radius.circular(20)),
                  child: Container(
                      padding: EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                      color: red,
                      child: new Text(' ✚ ',
                          style: TextStyle(color: Colors.white, fontSize: 8)))),
            ),
          ],
        ),
      ),
    );
  }
}

class NewArrival extends StatefulWidget {
  final String title;
  final Function onRefresh;
  final List<Product> productList;
  final type;
  final id;
  NewArrival(this.title,
      {this.id,
      this.onRefresh,
      @required this.productList,
      @required this.type});
  @override
  _NewArrivalState createState() => _NewArrivalState();
}

class _NewArrivalState extends State<NewArrival> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    final double itemHeight = (size.height - kToolbarHeight - 24) / 2;
    final double itemWidth = size.width / 2;
    return Container(
      child: _getNewArrival(widget.productList),
    );
  }

  Widget _getNewArrival(List<Product> productList) {
    return Container(
      color: Colors.grey.shade100,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          SizedBox(
            height: 5,
          ),
          setTopLine(widget.title, Colors.grey.shade600, () {
            //myPrint(widget.title);
            Utility.pushToNext(
                    BlocProvider(
                      create: (BuildContext context) =>
                          ProductBloc(ProductLoadingState()),
                      child: ProductView(
                        title: widget.title,
                        id: widget.id,
                        type: widget.type,
                      ),
                    ),
                    context)
                .then((value) {
              if (!widget.title.contains("SIMILAR")) {
                widget.onRefresh();
                BlocProvider.of<DashboardBloc>(context)
                    .add(RefreshDashboardEvent());
              }
            });
          }),
          SizedBox(
            height: 5,
          ),
          Container(
              height: 230,
              child: Container(
                child: new ListView(
                  shrinkWrap: true,
                  scrollDirection: Axis.horizontal,
                  children: List.generate(productList.length, (position) {
                    return InkWell(
                      onTap: () {
                        Utility.pushToNext(
                                ProductDetails(
                                  productId: productList[position].id,
                                ),
                                context)
                            .then((value) {
                          widget.onRefresh();
                          BlocProvider.of<DashboardBloc>(context)
                              .add(RefreshDashboardEvent());
                        });
                      },
                      child: _setView(productList[position], position),
                    );
                  }),
                ),
              )),
          SizedBox(
            height: 10,
          ),
        ],
      ),
    );
  }

  _setView(Product product, int position) {
    return Container(
      margin: EdgeInsets.only(
        left: (position == 0) ? 20 : 2,
      ),
      child: Card(
        child: Container(
          width: 170,
          // padding: const EdgeInsets.all(),
          child: Column(
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  InkWell(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8, top: 8),
                      child: Icon(
                        Icons.favorite,
                        color:
                            (product.isInWishlist) ? red : Colors.grey.shade300,
                        size: 16,
                      ),
                    ),
                    onTap: () async {
                      bool value = await Utility.performWishList(
                          context,
                          Scaffold.of(context).context,
                          product.id,
                          product.isInWishlist,
                          true);
                      setState(() {
                        if (value??false) {
                          product.isInWishlist = !product.isInWishlist;
                        }
                      });
                    },
                  )
                ],
              ),
              Container(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    Container(
                      //  height: 80,
                      child: Stack(
                        // fit: StackFit.expand,
                        children: <Widget>[
                          (product.images.length > 0)
                              ? CachedNetworkImage(
                                  imageUrl: product.images[0].imageUrl,
                                  //width: 80,
                                  height: 90,

                                  placeholder: (context, data) {
                                    return Container(
                                      width: 80,
                                      height: 90,
                                      child: new Center(
                                        child: SizedBox(
                                          width: 30,
                                          height: 30,
                                          child: new CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                  fit: BoxFit.contain,
                                )
                              : Image.asset('assets/no_image.png',
                                  width: 80, height: 90),
                        ],
                      ),
                    ),
                    new SizedBox(
                      height: 15,
                    ),
                    new Container(
                      child: Column(
                        //   crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          new Text(
                            widget.productList[position].name,
                            maxLines: 1,
                            style: TextStyle(
                              color: Colors.grey.shade700,
                              fontSize: 13,
                            ),
                          ),
                          new SizedBox(
                            height: 3,
                          ),
                          new Text(
                            '₹ ${widget.productList[position].newPrice}',
                            //textAlign: TextAlign.start,
                            style: TextStyle(
                                color: red,
                                fontSize: 12,
                                fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 13,
                    ),
                    (!product.isInStock)
                        ? Container(
                            padding: const EdgeInsets.symmetric(horizontal: 5),
                            child: Text(
                              'OUT OF STOCK',
                              style: smallTextStyle,
                            ))
                        : Utility.customRoundedWidget('ADD TO CART', red,
                            onClick: () {
                            Utility.showMoveToBagBottomSheet(context,
                                product: product,
                                onDoneClick: (int quntity, Sizes size) async {
                              Navigator.pop(context);
                              bool value = await Utility.addToCart(context,
                                  null, product.id, quntity, size?.id, true);
                              if (value) {
                                // int cartCount = await Prefs.cartCount;
                                // cartCount++;
                                // Prefs.setCartCount(cartCount);
                                widget.onRefresh();
                              }
                            });
                          }),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _setNewArricals(Product product) {
    return new Container(
      height: 100,
      decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade200, width: 1)),
      padding: EdgeInsets.only(top: 0, bottom: 0, left: 15, right: 0),
      child: Stack(
        children: <Widget>[
          new Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              new SizedBox(
                width: 5,
              ),
              // flex: 1,
              // Container(
              //     margin: EdgeInsets.only(left: 3, right: 8),
              //     child: SizedBox(
              //         width: 60,
              //          child: new Image.asset(product.image))),
              new SizedBox(
                width: 5,
              ),
              new Expanded(
                flex: 1,
                child: new Container(
                    child: new Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    new Text(
                      product.name,
                      style: TextStyle(fontSize: 12),
                    ),
                    new SizedBox(height: 4),
                    new Text(
                      '₹ ${product.newPrice}',
                      style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.w500,
                          fontSize: 11),
                    ),
                    new SizedBox(
                      height: 10,
                    ),
                    Container(
                        child: new InkWell(
                      onTap: () {
                        setState(() {
                          product.isInCart = true;
                        });
                      },
                      child: (!product.isInStock)
                          ? Container(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 5),
                              child: Text(
                                'OUT OF STOCK',
                                style: smallTextStyle,
                              ))
                          : Utility.customRoundedWidget('ADD TO CART', red,
                              onClick: () {
                              Utility.showMoveToBagBottomSheet(context,
                                  product: product,
                                  onDoneClick: (int quntity, Sizes size) async {
                                Navigator.pop(context);
                                bool value = await Utility.addToCart(context,
                                    null, product.id, quntity, size?.id, true);
                                if (value) {
                                  // int cartCount = await Prefs.cartCount;
                                  // cartCount++;
                                  // Prefs.setCartCount(cartCount);
                                  widget.onRefresh();
                                }
                              });
                            }),
                    ))
                  ],
                )),
              )
            ],
          ),
          new Align(
            alignment: Alignment.topRight,
            child: Container(
                padding: const EdgeInsets.all(12),
                child: InkWell(
                  onTap: () async {
                    myPrint('fav cliked..');
                    bool value = await Utility.performWishList(
                        context,
                        Scaffold.of(context).context,
                        product.id,
                        product.isInWishlist,
                        true);
                    setState(() {
                      if (value??false) {
                        product.isInWishlist = !product.isInWishlist;
                      }
                    });
                  },
                  child: Icon(
                    Icons.favorite,
                    color: (product.isInWishlist) ? red : Colors.grey,
                    size: 14,
                  ),
                )),
          ),
          // (product.hasOffer)
          //     ? Container(
          //         padding: const EdgeInsets.all(1),
          //         child: Utility.offerWidget('5% OFF'))
          //     : new Container()
        ],
      ),
    );
  }

  Widget _setItemCount(Product product) {
    return new Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        //border: Border.all(color: red,width: 0.2,style: BorderStyle.solid)
      ),
      child: Container(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            InkWell(
              onTap: () {
                // if (product.qty > 1) {
                //   setState(() {
                //     // product.qty--;
                //   });
                // } else {
                //   setState(() {
                //     product.isInCart = !product.isInCart;
                //   });
                //   cartCount--;
                //   widget.onRefresh();
                // }
              },
              child: ClipRRect(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    bottomLeft: Radius.circular(20)),
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                  color: red,
                  child: new Text(
                    ' ━ ',
                    style: TextStyle(color: Colors.white, fontSize: 8),
                  ),
                ),
              ),
            ),
            Container(
                padding: EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                color: Colors.white,
                child: new Text(
                  product.qty.toString(),
                  style: TextStyle(fontSize: 9, fontWeight: FontWeight.w500),
                )),
            InkWell(
              onTap: () {
                setState(() {
                  //product.qty++;
                });
              },
              child: ClipRRect(
                  borderRadius: BorderRadius.only(
                      topRight: Radius.circular(20),
                      bottomRight: Radius.circular(20)),
                  child: Container(
                      padding: EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                      color: red,
                      child: new Text(' ✚ ',
                          style: TextStyle(color: Colors.white, fontSize: 8)))),
            ),
          ],
        ),
      ),
    );
  }
}
