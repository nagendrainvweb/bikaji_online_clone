import 'package:bikaji/model/Pagination.dart';
import 'package:bikaji/model/product.dart';
import 'package:bikaji/pages/login_page.dart';
import 'package:bikaji/pages/notification_page.dart';
import 'package:bikaji/pages/productDetails.dart';
import 'package:bikaji/pages/productView.dart';
import 'package:bikaji/prefrence_util/Prefs.dart';
import 'package:bikaji/repo/Repository.dart';
import 'package:bikaji/repo/api_provider.dart';
import 'package:bikaji/util/app_helper.dart';
import 'package:bikaji/util/database_helper.dart';
import 'package:bikaji/util/dialog_helper.dart';
import 'package:bikaji/util/textStyle.dart';
import 'package:bikaji/util/url_list.dart';
import 'package:bikaji/util/utility.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class WishListPage extends StatefulWidget {
  @override
  _WishListPageState createState() => _WishListPageState();
}

class _WishListPageState extends State<WishListPage> with AppHelper {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  Pagination _pagination;
  List<Product> _wishList;
  final _refreshIndicator = GlobalKey<RefreshIndicatorState>();
  int pageNo = 1;
  bool isLoading = false;
  bool isLogin;
  @override
  void initState() {
    //_wishList = new Utility().getProductList();
    // _getWishList();
    fetchWishList(pageNo);
    super.initState();
  }

  fetchWishList(var pageNo) async {
    isLogin = await Prefs.isLogin;
     setState(() {
      
    });
    if(isLogin){
          try {
      final response =
          await ApiProvider().fetchWishList(pageNo);
      if (response.status == UrlConstants.SUCCESS) {
        setState(() {
          _pagination = response.data.pagination;
          _wishList = response.data.wishlist;
          pageNo = _pagination.next;
        });
      } else {
        DialogHelper.showErrorDialog(context, "Error", response.message,
            onOkClicked: () {
          Navigator.pop(context);
        });
      }
    } catch (e) {
      myPrint(e.toString());
      Utility.showSnackBar(_scaffoldKey,
          onRetryCliked: () => fetchWishList(pageNo));
    }
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
            'Wishlist',
            style: toolbarStyle,
          ),
          backgroundColor: red,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.chevron_left),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
      ),
      body: Container(
        child:(isLogin==null)?Container():(isLogin)? (_wishList == null)
            ? Center(child: CircularProgressIndicator())
            : (_wishList.length > 0)
                ? Stack(
                    children: <Widget>[
                      AnimatedContainer(
                        duration: Duration(milliseconds: 500),
                        color: Colors.grey.shade100,
                        child: NotificationListener<ScrollNotification>(
                          onNotification: (scrollInfo) {
                            if (scrollInfo.metrics.pixels ==
                                scrollInfo.metrics.maxScrollExtent) {
                              if (_pagination.isNext && !isLoading)
                                fetchWishList(pageNo);
                            }
                            return true;
                          },
                          child: RefreshIndicator(
                            key: _refreshIndicator,
                            onRefresh: () async {
                              pageNo = 1;
                              await fetchWishList(pageNo);
                              return true;
                            },
                            child: GridView.builder(
                              itemCount: _wishList.length,
                              gridDelegate:
                                  new SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2, childAspectRatio: 0.8),
                              itemBuilder: (context, index) {
                                return _buildRow(index);
                              },
                            ),
                          ),
                        ),
                      ),
                      BottomCircularLoadingWidget(
                        isLoading: isLoading,
                      ),
                    ],
                  )
                : _getNoDataView:LoginErrorWidget(
                 title: "Please Login",
                 desc: "Let's Login to see your wishlist !",
                 icon: Icons.info_outline,
                 buttonText: "LOGIN",
                 onBtnclicked: ()async{
                  await Utility.pushToLogin(context);
                  fetchWishList(pageNo);
                 }, 
                ),
      ),
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
              Image.asset('assets/heart.png'),
              SizedBox(
                height: 20,
              ),
              Text(
                "It's quite empty here !",
                style: normalTextStyle,
              ),
              SizedBox(
                height: 8,
              ),
              Text(
                "You haven't saved any product to wishlist !",
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

  _buildRow(var index) {
    return InkWell(
      onTap: () {
        Utility.pushToNext(
            ProductDetails(
              productId: _wishList[index].id,
            ),
            context);
      },
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade200, width: 1),
          color: Colors.white,
        ),
        //margin: EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 5),
        child: Container(
            child: Stack(
          children: <Widget>[
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  new SizedBox(
                    width: 100,
                    height: 100,
                    child: (_wishList[index].images.length > 0)
                        ? CachedNetworkImage(
                            imageUrl: _wishList[index].images[0].imageUrl,
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
                            fit: BoxFit.contain,
                          )
                        : Image.asset('assets/no_image.png'),
                  ),
                  new SizedBox(
                    height: 10,
                  ),
                  new Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        new Text(
                          //  _wishList[index][DatabaseHelper.columnName],
                          _wishList[index].name,
                          style: TextStyle(
                              color: Colors.grey.shade700,
                              fontSize: 12,
                              fontWeight: FontWeight.w500),
                        ),
                        new SizedBox(
                          height: 2,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            new Text(
                              // '₹${_wishList[index][DatabaseHelper.columnPrice]}',
                              '₹${_wishList[index].newPrice}',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: red,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700),
                            ),
                            // SizedBox(
                            //   width: 5,
                            // ),
                            // new Text(
                            //   // '₹${_wishList[index][DatabaseHelper.columnAcutalPrice]}',
                            //   '₹205',
                            //   textAlign: TextAlign.center,
                            //   style: TextStyle(
                            //       color: Colors.grey.shade500,
                            //       fontSize: 11,
                            //       decoration: TextDecoration.lineThrough,
                            //       fontWeight: FontWeight.w600),
                            // ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  (_wishList[index].isInStock??false)?
                   Utility.customRoundedWidget('MOVE TO BAG', red,
                    onClick: (){
                      _showMoveToBagBottomSheet(index);
                    }
                    )
                    :Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: Text('OUT OF STOCK',style: smallTextStyle,)),
                ],
              ),
            ),
            _getRemoveIcon(index),
          ],
        )),
      ),
    );
  }

  _showMoveToBagBottomSheet(var index) {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return MoveToBag(
            product: _wishList[index],
            onDoneClick: (int quntity, Sizes size) async {
              Navigator.pop(context);
              _moveFromWishlistToCart(_wishList[index].id, size?.id, quntity,index);
              // bool value = await Utility.addToCart(
              //     context, _scaffoldKey, _wishList[index].id, quntity, size.id, false);
              // if (value) {
              //   int cartCount = await Prefs.cartCount;
              //   Prefs.setCartCount(cartCount++);

              //  // widget.onRefresh();
              // }
              // setState(() {});

              myPrint('quntity : $quntity');
            },
          );
        });
  }

  _moveFromWishlistToCart(var productId, var sizeId, int quntity,var index) async {
    progressDialog(context, "Please wait...");
    final userid = await Prefs.id;
    try {
      final response = await ApiProvider()
          .addToCart(productId, quntity, sizeId??"");
      if (response.status == UrlConstants.SUCCESS) {
        myPrint('Added to cart');
        final removeResponse = await ApiProvider()
            .removeFromWishlist(userid, productId);
        hideProgressDialog(context);
        if(removeResponse.status == UrlConstants.SUCCESS ){
          myPrint('remove from wishlist');
          // int cartCount = await Prefs.cartCount;
          //  Prefs.setCartCount(cartCount++);
           setState(() {
            _wishList.removeAt(index);
           });
          Utility.showCustomSnackBar("Product Added To Cart", _scaffoldKey);
        }else{
          Utility.showCustomSnackBar(SOMETHING_WRONG_TEXT, _scaffoldKey);
        }
      } else {
        hideProgressDialog(context);
        Utility.showCustomSnackBar(response.message, _scaffoldKey);
      }
    } catch (e) {
      hideProgressDialog(context);
      myPrint(e.toString());
      Utility.showCustomSnackBar(SOMETHING_WRONG_TEXT, _scaffoldKey);
    }
  }

  _getRemoveIcon(var index) {
    return Align(
      alignment: Alignment.topRight,
      child: IconButton(
        icon: Icon(
          Icons.cancel,
          size: 16,
          color: Colors.grey.shade400,
        ),
        onPressed: () {
          // setState(() {
          //   _wishList.removeAt(index);
          // });
          DialogHelper.showRemoveDialog(context, _wishList[index].name,
              'Remove product from wishlist ?', 'REMOVE', () async {
            myPrint('clicked');
            Navigator.pop(context);
            final isSucess = await Utility.removeProductFromWishList(
                context, _scaffoldKey, _wishList[index].id, false);
            setState(() {
              if (isSucess) {
                _wishList.removeAt(index);
              }
            });
          });
        },
      ),
    );
  }
}

class MoveToBag extends StatefulWidget {
  Function onDoneClick;
  final Product product;
  MoveToBag({@required this.onDoneClick, @required this.product});
  @override
  _MoveToBagState createState() => _MoveToBagState();
}

class _MoveToBagState extends State<MoveToBag> {
  var quntity = 1;
  //List _kgs = ['10Kg', '20kg', '40kg', '50kg', '100kg'];
  var _currentCity = '';
  Sizes _sizes;
  @override
  void initState() {
    super.initState();
    setState(() {
      for(var size in widget.product.sizes){
        if(double.parse(size.newPrice).toInt() == 0 ){
          _currentCity = size.size;
       _sizes = size;
        }
      }
      
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            child: Column(
              children: <Widget>[
              (widget.product.sizes.length >0)?  _getSizeView():Container(),
                _getQuntityView(),
              ],
            ),
          ),
          InkWell(
            onTap: () {
              //cartCount++;
              widget.onDoneClick(quntity, _sizes);
            },
            child: Container(
              padding: const EdgeInsets.all(14),
              color: green,
              width: double.infinity,
              child: Text(
                'DONE',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 11,
                    color: Colors.white,
                    fontWeight: FontWeight.w700),
              ),
            ),
          )
        ],
      ),
    );
  }

  _getQuntityView() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 30),
      child: Row(
        children: <Widget>[
          Text(
            'SELECT QUANTITY',
            style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Colors.grey.shade700),
          ),
          SizedBox(
            width: 30,
          ),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300, width: 1),
            ),
            child: Row(
              children: <Widget>[
                InkWell(
                  onTap: () {
                    setState(() {
                      if (quntity > 1) {
                        quntity--;
                      }
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8,vertical: 5),
                    child: Icon(Icons.remove,size: 14,)
                    // Text(
                    //   '   -   ',
                    //   style: extraSmallTextStyle,
                    // ),
                  ),
                ),
                Container(
                  color: Colors.grey.shade300,
                  padding: const EdgeInsets.all(5),
                  child: Text(
                    '   $quntity   ',
                    style: smallTextStyle,
                  ),
                ),
                InkWell(
                  onTap: () {
                    setState(() {
                      quntity++;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8,vertical: 5),
                   child: Icon(Icons.add,size: 13,)
                    // Text(
                    //   '   +   ',
                    //   style: extraSmallTextStyle,
                    // ),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  _getSizeView() {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: double.infinity,
            color: Colors.grey.shade100,
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 30),
            child: Text(
              'SELECT SIZE',
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey.shade700),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 30),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Container(
                    child: _getSizeType,
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: 1,
            color: Colors.grey.shade200,
          )
        ],
      ),
    );
  }

  get _getSizeType {
    final sizes = widget.product.sizes;
    return Container(
      child:(sizes.length>0)? Row(
          children: List.generate(sizes.length, (index) {
        return getTypeKgs(sizes[index]);
      })):
     getBlankSize() ,
    );
  }
  getBlankSize(){
    return Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            color: Colors.white,
            border: Border.all(
                color:  Colors.red.shade200,
                width:  1)),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        margin: EdgeInsets.only(right: 10),
        child: Text(
          "Size not available",
          style: disabledTextStyle,
          textAlign: TextAlign.center,
        ),
      );
  }

  getTypeKgs(Sizes size) {
    return InkWell(
      onTap: () {
        setState(() {
          _currentCity = size.size;
          _sizes = size;
        });
      },
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            color: (_currentCity == size.size)
                ? Colors.red.shade500
                : Colors.white,
            border: Border.all(
                color: (_currentCity == size.size)
                    ? Colors.red.shade500
                    : Colors.red.shade200,
                width: (_currentCity == size.size) ? 1 : 1)),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        margin: EdgeInsets.only(right: 10),
        child: Text(
          size.size,
          style: (_currentCity == size.size)
              ? enabledTextStyle
              : disabledTextStyle,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
