import 'package:bikaji/model/ProductData.dart';
import 'package:bikaji/model/product.dart';
import 'package:bikaji/pages/all_review.dart';
import 'package:bikaji/pages/cart_full_page.dart';
import 'package:bikaji/pages/cart_page.dart';
import 'package:bikaji/pages/dashboard_page.dart';
import 'package:bikaji/pages/full_image.dart';
import 'package:bikaji/pages/login_page.dart';
import 'package:bikaji/pages/wishList_page.dart';
import 'package:bikaji/prefrence_util/Prefs.dart';
import 'package:bikaji/repo/Repository.dart';
import 'package:bikaji/repo/api_provider.dart';
import 'package:bikaji/util/app_helper.dart';
import 'package:bikaji/util/custom_icons.dart';
import 'package:bikaji/util/database_helper.dart';
import 'package:bikaji/util/dialog_helper.dart';
import 'package:bikaji/util/textStyle.dart';
import 'package:bikaji/util/url_list.dart';
import 'package:bikaji/util/utility.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:share/share.dart';
import 'package:smooth_star_rating_null_safety/smooth_star_rating_null_safety.dart';
import 'home.dart';

class ProductDetails extends StatefulWidget {
  final productId;
  ProductDetails({@required this.productId});
  @override
  _ProductDetailsState createState() => _ProductDetailsState();
}

class _ProductDetailsState extends State<ProductDetails>
    with TickerProviderStateMixin, AppHelper {
  List _kgs = ['10Kg', '20kg', '40kg', '50kg', '100kg'];
  List<DropdownMenuItem<String>> _dropDownMenuItems;
  final _scafflodKey = GlobalKey<ScaffoldState>();
  final _bottomKey = GlobalKey();
  String _currentCity = '10Kg';
  bool isDescriptionOpen = false;
  bool isSpecificationOpen = false;
  bool isReviewOpen = false;
  bool isIngredientOpen = false;
  bool isFav = false;
  int _quntity = 1;
  String cartCount = "0";
  bool isWishList = false;
  bool isInCart = false;
  bool _isLogin = false;
  AnimationController _animationController;
  Animation<double> fadeout;
  bool isScrollDone = false;
  double iconSize = 0;
  double _snackHeight = 0;
  ProductData _productData;
  int _selectedSizePosition = 0;
  int _price = 0;
  var focusNode = new FocusNode();

  // snack bar variables
  bool ishowSnackbar = false;
  var snackBarDetailsText = "ADDED TO CART";
  var snackBarActionText = "VIEW CART";
  bool isCartAction = true;
  String picodeMessage = "";
  bool isPinComplete = false;
  Color pinColor = green;
  final _pinController = TextEditingController();

  @override
  void initState() {
    _dropDownMenuItems = getDropDownItems();
    _currentCity = _dropDownMenuItems[0].value;
    super.initState();

    //_checkInternet();
    _fetchData();
    _animationController = AnimationController(
        duration: const Duration(milliseconds: 500), vsync: this);
    fadeout = Tween(begin: 0.0, end: 1.0).animate(_animationController);

    fadeout.addListener(() {
      setState(() {});
      if (fadeout.isCompleted) {
        Future.delayed(
            Duration(
              seconds: 2,
            ), () async {
          await _animationController.reverse();
          _snackHeight = 0;
        });
      }
    });

    _animationController.addListener(() {});
  }

  _fetchData() async {
    int count = await Prefs.cartCount;
    cartCount = count.toString();
    _isLogin = await Prefs.isLogin;

    // progressDialog(context, 'Please wait...');
    try {
      final response =
          await ApiProvider().fetchProductDetails(widget.productId);
      // hideProgressDialog(context);
      if (response.status == UrlConstants.SUCCESS) {
        setState(() {
          _productData = response.data;
          _price = double.parse(_productData.newPrice).toInt();
          if (_productData.qty > 0) {
            _quntity = _productData.qty;
          }
          if (!_productData.isInCart) {
            for (int i = 0; i < _productData.sizes.length; i++) {
              if (double.parse(_productData.sizes[i].newPrice).toInt() == 0) {
                _selectedSizePosition = i;
              }
            }
          } else {
            for (int i = 0; i < _productData.sizes.length; i++) {
              if (_productData.size_id == _productData.sizes[i].id) {
                _selectedSizePosition = i;
                _price = double.parse(_productData.newPrice).toInt() +
                    double.parse(_productData.sizes[i].newPrice).toInt();
              }
            }
          }
        });
      } else {
        DialogHelper.showErrorDialog(context, "Error", response.message,
            showTitle: true, onOkClicked: () {
          Navigator.pop(context);
          Navigator.pop(context);
        });
      }
    } catch (e) {
      //  hideProgressDialog(context);
      DialogHelper.showErrorDialog(context, "Error", SOMETHING_WRONG_TEXT,
          showTitle: true, onOkClicked: () {
        Navigator.pop(context);
        Navigator.pop(context);
      });
      myPrint(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scafflodKey,
      appBar: PreferredSize(
          child: AppBar(
            brightness: Brightness.light,
            elevation: 0,
            backgroundColor: Colors.white,
          ),
          preferredSize: Size.fromHeight(0)),
      body: (_productData == null)
          ? Container(
              child: Center(
                child: CircularProgressIndicator(),
              ),
            )
          : SafeArea(
              bottom: false,
              child: Stack(
                children: <Widget>[
                  Container(
                    color: Colors.grey.shade100,
                    child: Column(
                      children: <Widget>[
                        Expanded(
                          child: Stack(
                            children: <Widget>[
                              RefreshIndicator(
                                onRefresh: () async {
                                  await _fetchData();
                                  return true;
                                },
                                child: ListView(
                                  shrinkWrap: true,
                                  children: <Widget>[
                                    SizedBox(
                                      height: 40,
                                    ),
                                    new Container(
                                      child: new ProductCarousal(
                                        images: _productData.images,
                                        name: _productData.name,
                                      ),
                                    ),
                                    _productName(),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    _getProductDescrption,
                                    (_productData.ingradientDetails != null)
                                        ? SizedBox(
                                            height: 5,
                                          )
                                        : Container(),
                                    (_productData.ingradientDetails != null)
                                        ? _getIngredient
                                        : Container(),
                                    (_productData.nutritionFacts.isNotEmpty)
                                        ? SizedBox(
                                            height: 5,
                                          )
                                        : Container(),
                                    (_productData.nutritionFacts.isNotEmpty)
                                        ? _getProductSpecification
                                        : Container(),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    _getRatingReview,
                                    // _productDescription(),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Container(
                                      height: 1,
                                      color: Colors.grey.shade300,
                                    ),
                                    SimilarProductWidget(
                                      categoryId: _productData.categoryId,
                                    ),
                                    SizedBox(
                                      height: 5,
                                    )
                                  ],
                                ),
                              ),
                              _getSnackView,
                              // Align(
                              //   alignment: Alignment.bottomLeft,
                              //   child:
                              //    _showSnackBar('ADDED TO CART', 'VIEW CART', (){

                              //    }),
                              // )
                            ],
                          ),
                        ),
                        _getBottomView,
                      ],
                    ),
                  ),

                  _getTopBar,
                  //_getAddToWishListPopup,
                ],
              ),
            ),
    );
  }

  get _getAddToWishListPopup {
    var height = MediaQuery.of(context).size.height;
    var centerPosition = height / 2;
    var startPosition = height + 10.0;
    var endPosition = centerPosition;

    return Align(
      alignment: Alignment.topCenter,
      child: (!isScrollDone)
          ? AnimatedContainer(
              duration: Duration(milliseconds: 400),
              margin: EdgeInsets.only(
                  top: (isWishList) ? endPosition : startPosition),
              child: Container(
                  child: Opacity(
                      opacity: (isWishList && isScrollDone) ? 0.0 : 1.0,
                      child: Center(
                        child: Icon(Icons.favorite, size: 80, color: red),
                      ))
                  // FadeTransition(
                  //   opacity: fadeout,
                  //   child:

                  //     ),
                  ),
            )
          : Container(),
    );
  }

  get _getBottomView {
    return Container(
      key: _bottomKey,
      child: Column(
        children: <Widget>[
          Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                height: 1,
                color: Colors.grey.shade300,
              ),
              Container(
                decoration: BoxDecoration(color: red),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      flex: 1,
                      child: InkWell(
                        onTap: () async {
                          Future.delayed(Duration(milliseconds: 800), () {
                            setState(() {
                              isScrollDone = !isScrollDone;
                            });
                          });
                          bool isLogin = await Prefs.isLogin;
                          if (isLogin) {
                            _addRemoveFromWishlist();
                          } else {
                            Utility.pushToLogin(context);
                          }
                        },
                        child: Container(
                          decoration: BoxDecoration(
                              border: Border(
                                  right: BorderSide(
                                      color: Colors.white, width: 0.3))),
                          child: Padding(
                            padding: const EdgeInsets.all(15.0),
                            child: Text(
                              (_productData.isInWishlist)
                                  ? 'REMOVE FROM WISHLIST'
                                  : 'ADD TO WISHLIST',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: InkWell(
                        onTap: () async {
                          final isLogin = await Prefs.isLogin;
                          if (isLogin) {
                            _addRemoveFromCart();
                          } else {
                            Utility.pushToLogin(context);
                          }
                        },
                        child: Container(
                          color: (_productData.isInStock) ? red : textGrey,
                          child: Container(
                            padding: EdgeInsets.all((!isInCart) ? 15.0 : 10.0),
                            decoration: BoxDecoration(
                                border: Border(
                                    left: BorderSide(
                                        color: Colors.white, width: 0.3))),
                            child: (!isInCart)
                                ? Text(
                                    (_productData.isInCart)
                                        ? 'REMOVE FROM CART'
                                        : 'ADD TO CART',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600),
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Icon(
                                        MyFlutterApp.ic_cart_1,
                                        size: 24,
                                        color: Colors.white,
                                      ),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      Text(
                                        'VIEW CART',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600),
                                      )
                                    ],
                                  ),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  get _getSnackView {
    var txtStyle = TextStyle(
        fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white);
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        height: _snackHeight,
        child: FadeTransition(
          opacity: fadeout,
          child: Container(
            color: snackColor,
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 25),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Container(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Container(
                        decoration:
                            BoxDecoration(shape: BoxShape.circle, color: green),
                        padding: EdgeInsets.all(4),
                        child: Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 12,
                        ),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Text(
                        snackBarDetailsText,
                        style: txtStyle,
                      ),
                    ],
                  ),
                ),
                InkWell(
                  onTap: () {
                    if (isCartAction) {
                      Utility.pushToNext(CartMainPage(), context);
                    } else {
                      Utility.pushToNext(WishListPage(), context);
                    }
                  },
                  child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                      decoration: BoxDecoration(
                          shape: BoxShape.rectangle,
                          borderRadius: BorderRadius.circular(5),
                          color: red),
                      child: Row(
                        children: <Widget>[
                          Text(
                            snackBarActionText,
                            style: txtStyle,
                          ),
                          SizedBox(
                            width: 2,
                          ),
                          Icon(Icons.chevron_right,
                              size: 14, color: Colors.white)
                        ],
                      )),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  _addRemoveFromWishlist() async {
    progressDialog(context, "Please wait...");
    final userId = await Prefs.id;
    try {
      var response;
      if (_productData.isInWishlist) {
        response =
            await ApiProvider().removeFromWishlist(userId, _productData.id);
      } else {
        response = await ApiProvider().addToWishlist(userId, _productData.id);
      }
      hideProgressDialog(context);
      if (response.status == UrlConstants.SUCCESS) {
        _insert(
            (_productData.isInWishlist)
                ? 'REMOVED FROM WISHLIST'
                : 'ADDED TO WISHLIST',
            'VIEW WISHLIST',
            false);
      } else {
        Utility.showScaffoldSnackBar(context, response.message, null, true);
      }
    } catch (e) {
      myPrint(e.toString());
      hideProgressDialog(context);
    }
  }

  _addRemoveFromCart() async {
    progressDialog(context, "Please wait...");
    try {
      var response;
      if (_productData.isInCart) {
        response = await ApiProvider().removeFromCart(_productData.id,
            (_productData.sizes.length > 0) ? _productData.size_id : "0");
      } else {
        if (_productData.isInStock) {
          response = await ApiProvider().addToCart(
              _productData.id,
              _quntity,
              (_productData.sizes.length > 0)
                  ? _productData.sizes[_selectedSizePosition].id
                  : "");
        }
      }
      hideProgressDialog(context);
      if (response?.status == UrlConstants.SUCCESS) {
        int count = await Prefs.cartCount;
        cartCount = count.toString();
        _insert((_productData.isInCart) ? 'REMOVED FROM CART' : 'ADDED TO CART',
            'VIEW CART', true);
      } else {
        Utility.showScaffoldSnackBar(context, response.message, null, true);
      }
    } catch (e) {
      myPrint(e.toString());
      hideProgressDialog(context);
    }
  }

  void _insert(var firstText, var secondText, var isDone) async {
    setState(() {
      snackBarDetailsText = firstText;
      snackBarActionText = secondText;
      isCartAction = isDone;
      _snackHeight = 60;
      if (isDone) {
        _productData.isInCart = !_productData.isInCart;
      } else {
        _productData.isInWishlist = !_productData.isInWishlist;
      }
    });

    _animationController.forward();
  }

  _showSnackBar(var leftTitle, var rightTitle, Function onClick) {
    var txtStyle = TextStyle(
        fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white);
    var snackBar = SnackBar(
      behavior: SnackBarBehavior.floating,
      //  backgroundColor: Colors.transparent,
      content: Container(
        // padding: const EdgeInsets.all(10),
        // decoration: BoxDecoration(
        //   color: blackGrey
        // ),
        // margin: EdgeInsets.all(5),
        child: Container(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Container(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Container(
                      decoration:
                          BoxDecoration(shape: BoxShape.circle, color: green),
                      padding: EdgeInsets.all(4),
                      child: Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 12,
                      ),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Text(
                      leftTitle,
                      style: txtStyle,
                    ),
                  ],
                ),
              ),
              InkWell(
                onTap: onClick,
                child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                    decoration: BoxDecoration(
                        shape: BoxShape.rectangle,
                        borderRadius: BorderRadius.circular(5),
                        color: red),
                    child: Row(
                      children: <Widget>[
                        Text(
                          rightTitle,
                          style: txtStyle,
                        ),
                        SizedBox(
                          width: 2,
                        ),
                        Icon(Icons.chevron_right, size: 14, color: Colors.white)
                      ],
                    )),
              ),
            ],
          ),
        ),
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  get _getProductDescrption {
    return Container(
      color: Colors.white,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        isDescriptionOpen = !isDescriptionOpen;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 15, horizontal: 10),
                      child: Text('Product Description',
                          style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 12,
                              color: Colors.grey.shade800)),
                    ),
                  ),
                ),
                InkWell(
                  onTap: () {
                    setState(() {
                      isDescriptionOpen = !isDescriptionOpen;
                    });
                  },
                  child: Icon(
                      (isDescriptionOpen)
                          ? Icons.expand_less
                          : Icons.expand_more,
                      size: 18,
                      color: Colors.grey.shade800),
                )
              ],
            ),
            (isDescriptionOpen)
                ? Container(
                    height: 1,
                    color: Colors.grey.shade300,
                  )
                : Container(),
            (isDescriptionOpen)
                ? Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 15, horizontal: 10),
                    child: HtmlWidget('${_productData.desc}',
                        textStyle: desciptionTextStyle),
                    // Text('${_productData.desc}',
                    //     style: desciptionTextStyle),
                  )
                : Container(),
          ],
        ),
      ),
    );
  }

  get _getIngredient {
    return Container(
      color: Colors.white,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        isIngredientOpen = !isIngredientOpen;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 15, horizontal: 10),
                      child: Text('Ingredient',
                          style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 12,
                              color: Colors.grey.shade800)),
                    ),
                  ),
                ),
                InkWell(
                  onTap: () {
                    setState(() {
                      isIngredientOpen = !isIngredientOpen;
                    });
                  },
                  child: Icon(
                      (isIngredientOpen)
                          ? Icons.expand_less
                          : Icons.expand_more,
                      size: 18,
                      color: Colors.grey.shade800),
                )
              ],
            ),
            (isIngredientOpen)
                ? Container(
                    height: 1,
                    color: Colors.grey.shade300,
                  )
                : Container(),
            (isIngredientOpen)
                ? Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 15, horizontal: 10),
                    child: HtmlWidget('${_productData.ingradientDetails}',
                        textStyle: desciptionTextStyle),
                  )
                : Container(),
          ],
        ),
      ),
    );
  }

  get _getProductSpecification {
    return Container(
      color: Colors.white,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        isSpecificationOpen = !isSpecificationOpen;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 15, horizontal: 10),
                      child: Text('Nutrition Facts',
                          style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 12,
                              color: Colors.grey.shade800)),
                    ),
                  ),
                ),
                InkWell(
                  onTap: () {
                    setState(() {
                      isSpecificationOpen = !isSpecificationOpen;
                    });
                  },
                  child: Icon(
                      (isSpecificationOpen)
                          ? Icons.expand_less
                          : Icons.expand_more,
                      size: 18,
                      color: Colors.grey.shade800),
                )
              ],
            ),
            (isSpecificationOpen)
                ? Container(
                    height: 1,
                    color: Colors.grey.shade300,
                  )
                : Container(),
            (isSpecificationOpen)
                ? InkWell(
                    onTap: () {
                      List<Images> list = new List();
                      list.add(Images(
                          id: "1", imageUrl: _productData.nutritionFacts));
                      Utility.pushToNext(
                          ImageViewPage(
                            images: list,
                            name: _productData.name,
                          ),
                          context);
                    },
                    child: Container(
                      height: 100,
                      width: 100,
                      padding: const EdgeInsets.symmetric(
                          vertical: 15, horizontal: 10),
                      child: ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: CachedNetworkImage(
                              placeholder: (context, string) {
                                return Center(
                                  child: CircularProgressIndicator(
                                    strokeWidth: 3,
                                  ),
                                );
                              },
                              fit: BoxFit.cover,
                              imageUrl: _productData.nutritionFacts)),
                    ),
                  )
                : Container(),
          ],
        ),
      ),
    );
  }

  get _getTopBar {
    return Align(
      alignment: Alignment.topCenter,
      child: SafeArea(
        child: Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            children: <Widget>[
              IconButton(
                icon: Icon(
                  Icons.arrow_back_ios,
                  size: 18,
                  color: Colors.grey,
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    InkWell(
                      child: Icon(
                        MyFlutterApp.ic_share,
                        size: 18,
                        color: Colors.grey,
                      ),
                      onTap: () {
                        final link =
                            "${_productData.name}, ${_productData.desc}\n${_productData.product_url}";
                        Share.share(link);
                      },
                    ),
                    SizedBox(
                      width: 20,
                    ),
                    InkWell(
                      child: Container(
                        child: Stack(
                          children: <Widget>[
                            Icon(
                              MyFlutterApp.ic_cart,
                              size: 18,
                              color: Colors.grey,
                            ),
                            (cartCount != "0")
                                ? Container(
                                    margin: EdgeInsets.only(top: 8, left: 10),
                                    child: Container(
                                      width: 15,
                                      height: 15,
                                      decoration: BoxDecoration(
                                          color: green, shape: BoxShape.circle),
                                      child: Center(
                                          child: Text(
                                        cartCount,
                                        style: TextStyle(
                                            color: white,
                                            fontSize: 9,
                                            fontWeight: FontWeight.bold),
                                      )),
                                    ),
                                  )
                                : SizedBox()
                          ],
                        ),
                      ),
                      onTap: () {
                        Utility.pushToNext(CartMainPage(), context);
                      },
                    ),
                    SizedBox(
                      width: 20,
                    ),
                    InkWell(
                      child: Tooltip(
                        message: 'Added to Favourite',
                        child: Icon(
                          (isFav) ? Icons.favorite : Icons.favorite_border,
                          size: 18,
                          color: Colors.grey,
                        ),
                      ),
                      onTap: () {
                        Utility.pushToNext(WishListPage(), context);
                      },
                    ),
                    SizedBox(
                      width: 15,
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  _checkInternet() async {
    bool isInternet = await Utility.getConenctionStatus();
    if (!isInternet) {
      new DialogHelper().showNoInternetDialog(context);
    }
  }

  get _getRatingReview {
    return Container(
      color: Colors.white,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        isReviewOpen = !isReviewOpen;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 15, horizontal: 10),
                      child: Text('Rating and Review',
                          style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 12,
                              color: Colors.grey.shade800)),
                    ),
                  ),
                ),
                InkWell(
                  onTap: () {
                    setState(() {
                      isReviewOpen = !isReviewOpen;
                    });
                  },
                  child: Icon(
                      (isReviewOpen) ? Icons.expand_less : Icons.expand_more,
                      size: 18,
                      color: Colors.grey.shade800),
                )
              ],
            ),
            (isReviewOpen)
                ? Container(
                    height: 1,
                    color: Colors.grey.shade300,
                  )
                : Container(),
            (isReviewOpen)
                ? Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        (_productData.reviewData.review.length > 0)
                            ? _ratingReviewWidget()
                            : Container(),
                        SizedBox(
                          height: 20,
                        ),
                        (_isLogin)
                            ? InkWell(
                                onTap: () {
                                  _showRatingDialog(_productData.id,
                                      _productData.reviewData.my_review);
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(2),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Icon(
                                        Icons.edit,
                                        size: 13,
                                        color: textGrey,
                                      ),
                                      SizedBox(
                                        width: 3,
                                      ),
                                      Text(
                                        (_productData.reviewData.my_review ==
                                                null)
                                            ? 'Review the product'
                                            : 'Edit your Review',
                                        style: TextStyle(
                                            color: textGrey,
                                            fontSize: 12,
                                            decoration:
                                                TextDecoration.underline),
                                      )
                                    ],
                                  ),
                                ),
                              )
                            : Container(),
                        SizedBox(
                          height: 30,
                        ),
                        _getReviewList()
                      ],
                    ),
                  )
                : Container(),
          ],
        ),
      ),
    );
  }

  Widget _getReviewList() {
    final reviewList = _productData.reviewData.review;
    return Container(
      child: Column(
        children: List.generate(reviewList.length, (index) {
          return Container(
            child: Column(
              children: <Widget>[
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
                  child: _reviewRow(reviewList[index]),
                ),
                Container(
                  height: 1,
                  color: Colors.grey.shade300,
                ),
                (index == reviewList.length - 1)
                    ? InkWell(
                        onTap: () {
                          Utility.pushToNext(
                              AllReviewPage(
                                productId: _productData.id,
                              ),
                              context);
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Container(
                              margin: const EdgeInsets.only(top: 15),
                              child: Text(
                                'READ ALL REVIEWS ',
                                style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12),
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.only(top: 15),
                              child: Icon(
                                Icons.chevron_right,
                                size: 18,
                                color: Colors.grey.shade600,
                              ),
                            )
                          ],
                        ),
                      )
                    : Container()
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _reviewRow(Review review) {
    var titleStyle = TextStyle(
        color: Colors.grey.shade600, fontSize: 12, fontWeight: FontWeight.w700);
    var descStyle = TextStyle(
        color: Colors.grey.shade600, fontSize: 10, fontWeight: FontWeight.w600);
    var reviewStyle = desciptionTextStyle;
    var list = List();
    for (var i = 0; i < review.rating; i++) {
      list.add(i);
    }
    DateFormat dateFormat = DateFormat("yyyy-MM-dd");
    DateTime dateTime = dateFormat.parse(review.date);
    String formattedDate = DateFormat('dd MMM yyyy').format(dateTime);
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: list.map((value) {
              return Icon(
                Icons.star,
                size: 12,
                color: Colors.yellow.shade700,
              );
            }).toList(),
          ),
          SizedBox(
            height: 10,
          ),
          Text(
            '${review.reviewTitle}',
            style: titleStyle,
          ),
          SizedBox(
            height: 4,
          ),
          Text(
            '${review.userName} on ${formattedDate}',
            // 'Monica on May 22,2019',
            style: descStyle,
          ),
          SizedBox(
            height: 10,
          ),
          Text(
            '${review.review}',
            style: reviewStyle,
          ),
        ],
      ),
    );
  }

  Widget _productDescription() {
    return Container(
      color: Colors.white,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Container(
                    child: Text('Product Description',
                        style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                            color: Colors.grey.shade800)),
                  ),
                ),
                InkWell(
                    onTap: () {},
                    child: Icon(Icons.expand_more,
                        size: 18, color: Colors.grey.shade800))
              ],
            ),
            SizedBox(
              height: 10,
            ),
            Text(
                'A snack is a small service of food and generally eaten between meals. Snacks come in a variety of forms including packaged snack foods and other processed foods, as well as items made from fresh '),
            SizedBox(
              height: 8,
            ),
            Text('Specification :',
                style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(
              height: 3,
            ),
            Text(
                "Our Indian Snack collection offers from Traditional Indian-styled Chhole Bhature to Modern Quick-bite Grilled Sandwich. If craving for something to munch on or hunger striking on your head with less time in hand, just walk-in and enjoy our delicious Snacks. Not just Snacks, we serve something awesome like,\n.Samosa\n.Veg Sandwich\n.Paneer Pakora\n.Cheese",
                style: TextStyle(fontWeight: FontWeight.normal)),
            SizedBox(
              height: 10,
            ),
            _ratingReviewWidget(),
            SizedBox(
              height: 10,
            ),
            InkWell(
              onTap: () {
                //_showRatingDialog(_productData.id);
              },
              child: Container(
                padding: const EdgeInsets.all(2),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(
                      Icons.edit,
                      size: 15,
                      color: Colors.red.shade600,
                    ),
                    SizedBox(
                      width: 3,
                    ),
                    Text(
                      'Review this product',
                      style: TextStyle(
                          color: Colors.red.shade600,
                          decoration: TextDecoration.underline),
                    )
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 30,
            )
          ],
        ),
      ),
    );
  }

  _addReview(rating, reviewTitle, review) async {
    progressDialog(context, "Please wait...");
    try {
      final response = await ApiProvider()
          .addReview(widget.productId, rating, reviewTitle, review);
      hideProgressDialog(context);
      Utility.showCustomSnackBar(response.message, _scafflodKey);
      _fetchData();
    } catch (e) {
      myPrint(e.toString());
      hideProgressDialog(context);
      Utility.showCustomSnackBar(SOMETHING_WRONG_TEXT, _scafflodKey);
    }
  }

  _showRatingDialog(var productId, Review myReview) {
    double rating = 0.0;
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
            content: RatingDialog(
                productId: productId,
                myReview: myReview,
                onSubmitCliked: (rating, reviewTitle, review) {
                  _addReview(rating, reviewTitle, review);
                }),
          );
        });
  }

  Widget _ratingReviewWidget() {
    final reviewData = _productData.reviewData;
    final average = double.parse(reviewData.averageRating.toString()).round();
    var list = List();
    for (var i = 0; i < average; i++) {
      list.add(i);
    }
    return Container(
      child: new Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Expanded(
            flex: 1,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Text(
                      "${average}",
                      style: TextStyle(
                          fontSize: 15,
                          color: Colors.grey.shade700,
                          fontWeight: FontWeight.w600),
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    Row(
                        children: list.map((value) {
                      return Icon(
                        Icons.star,
                        size: 12,
                        color: Colors.yellow.shade700,
                      );
                    }).toList())
                  ],
                ),
                SizedBox(
                  height: 3,
                ),
                Text(
                  '(Based on ${reviewData.totalReviews} reviews)',
                  textAlign: TextAlign.start,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 10,
          ),
          Expanded(
            flex: 2,
            child: Column(
              children: <Widget>[
                _ratingRow(
                    '5★', reviewData.fiveStarCount, reviewData.totalReviews),
                _ratingRow(
                    '4★', reviewData.fourStarCount, reviewData.totalReviews),
                _ratingRow(
                    '3★', reviewData.threeStarCount, reviewData.totalReviews),
                _ratingRow(
                    '2★', reviewData.twoStarCount, reviewData.totalReviews),
                _ratingRow(
                    '1★', reviewData.oneStarCount, reviewData.totalReviews),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _ratingRow(var title, var rating, var total) {
    double progressIndicator = (rating == 0) ? 0 : (rating / total);
    return Container(
      padding: EdgeInsets.all(3),
      child: Row(
        children: <Widget>[
          Text(
            title,
            style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade700,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.3),
          ),
          Expanded(
            flex: 1,
            child: new Container(
              child: new LinearPercentIndicator(
                lineHeight: 3.0,
                percent: progressIndicator,
                backgroundColor: Colors.grey.shade200,
                progressColor: red,
              ),
            ),
          ),
          Text(
            rating.toString(),
            style: TextStyle(color: textGrey, fontSize: 10),
          ),
        ],
      ),
    );
  }

  get _getNameRating {
    var list = List();
    for (var i = 0; i < _productData.reviewData.averageRating; i++) {
      list.add(i);
    }
    // myPrint("total list is : ${list.length}");
    return Container(
      child: Row(
        children: <Widget>[
          Expanded(
            flex: 1,
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    _productData.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontWeight: FontWeight.w400,
                        color: blackGrey,
                        fontSize: 16,
                        letterSpacing: 0.1),
                  ),
                ),
                SizedBox(
                  width: 10,
                ),
                // (list.length > 0)
                //     ? Row(
                //         children: list.map((value) {
                //           return Icon(
                //             Icons.star,
                //             size: 12,
                //             color: Colors.yellow.shade700,
                //           );
                //         }).toList(),
                //       )
                //     : Container(),
              ],
            ),
          ),
          Row(
            children: <Widget>[
              Text(
                'Availability: ',
                textAlign: TextAlign.end,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Colors.grey,
                  fontSize: 11,
                ),
              ),
              Text(
                ' ${_productData.availability}',
                textAlign: TextAlign.end,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: (_productData.isInStock) ? green : red,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  get _getPriceDiscount {
    return Container(
      child: Row(
        children: <Widget>[
          Text(
            '$rupee ${_price}',
            style: TextStyle(
                fontWeight: FontWeight.w500,
                color: red,
                fontSize: 14,
                letterSpacing: 0.1),
          ),
          // SizedBox(
          //   width: 10,
          // ),
          // Text(
          //   '$rupee 105',
          //   style: TextStyle(
          //       fontWeight: FontWeight.w500,
          //       color: Colors.grey,
          //       fontSize: 13,
          //       decoration: TextDecoration.lineThrough),
          // ),
          // SizedBox(
          //   width: 10,
          // ),
          // Text(
          //   '(Save 5%)',
          //   style: TextStyle(
          //     fontWeight: FontWeight.w500,
          //     color: Colors.green,
          //     fontSize: 13,
          //   ),
          // ),
        ],
      ),
    );
  }

  get _getQuntityWithSize {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        (_productData.sizes.length > 0)
            ? Container(
                child: Row(
                  children: <Widget>[
                    Text(
                      'Size',
                      style: smallTextStyle,
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      child: Row(
                        children: <Widget>[
                          Text(
                            ':',
                            style: smallTextStyle,
                          ),
                          Expanded(
                            child: Container(
                              child: _getSizeType,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )
            : Container(),
        (_productData.sizes.length > 0)
            ? SizedBox(
                height: 10,
              )
            : Container(),
        Container(
          child: Row(
            children: <Widget>[
              Text(
                'Qty',
                style: smallTextStyle,
              ),
              SizedBox(
                width: 15,
              ),
              Expanded(
                child: Row(
                  children: <Widget>[
                    Text(
                      ':',
                      style: smallTextStyle,
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    InkWell(
                      onTap: () {
                        setState(() {
                          if (_quntity > 1) _quntity--;
                        });
                      },
                      child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.grey.shade400,
                                style: BorderStyle.solid,
                              )),
                          child: Icon(
                            Icons.remove,
                            size: 14,
                          )),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Text(
                      '$_quntity',
                      style: TextStyle(fontSize: 12),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    InkWell(
                      onTap: () {
                        setState(() {
                          _quntity++;
                        });
                      },
                      child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.grey.shade400,
                                style: BorderStyle.solid,
                              )),
                          child: Icon(
                            Icons.add,
                            size: 14,
                          )),
                    ),
                  ],
                ),
              ),
            ],
          ),
        )
      ],
    );
  }

  get _getSizeType {
    return Container(
      child: Row(
          children: List.generate(_productData.sizes.length, (index) {
        return getTypeKgs(_productData.sizes[index].size, index);
      })),
    );
  }

  getTypeKgs(String title, int index) {
    return InkWell(
      onTap: () {
        setState(() {
          _currentCity = title;
          _selectedSizePosition = index;
          myPrint(
              'new price is : ${double.parse(_productData.sizes[index].newPrice).toInt()}');
          _price = double.parse(_productData.newPrice).toInt() +
              double.parse(_productData.sizes[index].newPrice).toInt();
        });
      },
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            color: (_selectedSizePosition == index)
                ? Colors.red.shade500
                : Colors.white,
            border: Border.all(
                color: (_selectedSizePosition == index)
                    ? Colors.red.shade500
                    : Colors.red.shade200,
                width: (_selectedSizePosition == index) ? 1 : 1)),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        margin: EdgeInsets.only(left: 10),
        child: Text(
          title,
          style: (_selectedSizePosition == index)
              ? enabledTextStyle
              : disabledTextStyle,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _productName() {
    return Container(
      color: Colors.white,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: new Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            _getNameRating,
            SizedBox(
              height: 5,
            ),
            _getPriceDiscount,
            SizedBox(
              height: 12,
            ),
            _getQuntityWithSize,
            SizedBox(
              height: 12,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                _getShelfLife,
                _getExpectedDelivery,
              ],
            ),
            SizedBox(
              height: 12,
            ),
            _checkDelivery,
          ],
        ),
      ),
    );
  }

  get _checkDelivery {
    return Container(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 5, vertical: 0),
              // decoration: BoxDecoration(
              //   border: Border.all(color: Colors.grey.shade300,width: 1)
              // ),
              child: TextField(
                controller: _pinController,
                focusNode: focusNode,
                keyboardType: TextInputType.number,
                style: TextStyle(
                  fontSize: 15,
                ),
                decoration: Utility.pinCodetextUnderlineBorder(
                    isPinComplete, picodeMessage, 'Enter Pincode', pinColor),
              ),
            ),
          ),
          SizedBox(
            width: 10,
          ),
          MaterialButton(
            child: Text(
              'Check delivery',
              style: TextStyle(color: white, fontSize: 12),
            ),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
            color: red,
            onPressed: () async {
              focusNode.unfocus();
              final pinCodeRegex = RegExp(r'^[1-9][0-9]{5}$');
              if (_pinController.text.isNotEmpty) {
                progressDialog(context, "Please wait...");
                await Future.delayed(Duration(milliseconds: 500));
                hideProgressDialog(context);
                if (pinCodeRegex.hasMatch(_pinController.text)) {
                  picodeMessage = "Delivery Available";
                  isPinComplete = true;
                  pinColor = green;
                } else {
                  picodeMessage = "Delivery Not Available";
                  isPinComplete = true;
                  pinColor = red;
                }
                setState(() {});
              }
            },
          )
        ],
      ),
    );
  }

  get _getShelfLife {
    return Container(
      child: Row(
        children: <Widget>[
          Text(
            'Shelf Life :',
            style: smallTextStyle,
          ),
          SizedBox(
            width: 8,
          ),
          // HtmlWidget(_productData.selfLife,textStyle: TextStyle(color: Colors.grey[700], fontSize: 12),),
          Text(
            _productData.selfLife,
            style: TextStyle(color: Colors.grey[700], fontSize: 12),
          ),
        ],
      ),
    );
  }

  get _getExpectedDelivery {
    return Container(
      child: Row(
        children: <Widget>[
          Text(
            'Expected Delivery :',
            style: smallTextStyle,
          ),
          SizedBox(
            width: 5,
          ),
          Text(
            _productData.expectedDelivery.substring(
                0, _productData.expectedDelivery.lastIndexOf('.') + 1),
            style: TextStyle(color: Colors.grey[700], fontSize: 10),
          ),
        ],
      ),
    );
  }

  List<DropdownMenuItem<String>> getDropDownItems() {
    List<DropdownMenuItem<String>> items = List();

    for (String weight in _kgs) {
      items.add(new DropdownMenuItem(
        value: weight,
        child: Container(child: Text(weight)),
      ));
    }
    return items;
  }
}

class SimilarProductWidget extends StatefulWidget {
  final categoryId;

  const SimilarProductWidget({Key key, this.categoryId}) : super(key: key);

  @override
  _SimilarProductWidgetState createState() => _SimilarProductWidgetState();
}

class _SimilarProductWidgetState extends State<SimilarProductWidget> {
  List<Product> _productList;
  @override
  void initState() {
    _fetchData();
    super.initState();
  }

  _fetchData() async {
    final userid = await Prefs.id;
    try {
      final response =
          await ApiProvider().fetchProductList(userid, "1", widget.categoryId);
      if (response.status == UrlConstants.SUCCESS) {
        setState(() {
          _productList = response.data.productlist;
        });
      }
    } catch (e) {
      myPrint(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return (_productList != null)
        ? (_productList.length > 0)
            ? Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    NewArrival(
                      'SIMILAR PRODUCTS',
                      onRefresh: () {},
                      productList: _productList,
                      type: widget.categoryId,
                      id: widget.categoryId,
                    ),
                    //TopSellers('Similar Products'),
                  ],
                ),
              )
            : Container()
        : Container();
  }
}

class ProductCarousal extends StatefulWidget {
  final List<Images> images;
  final name;
  ProductCarousal({@required this.images, @required this.name});
  @override
  _ProductCarousalState createState() => _ProductCarousalState();
}

class _ProductCarousalState extends State<ProductCarousal> {
  int currentPosition = 0;
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          (widget.images.length > 0)
              ? Container(
                  height: 220,
                  width: MediaQuery.of(context).size.width,
                  child: CarouselSlider(
                    options: CarouselOptions(
                        autoPlay: false,
                        enableInfiniteScroll: true,
                        viewportFraction: 1.0,
                        //aspectRatio: (itemWidth / itemHeight),
                        initialPage: 0,
                        autoPlayCurve: Curves.easeIn,
                        onPageChanged: (index, reason) {
                          setState(() {
                            currentPosition = index;
                          });
                        }),
                    // autoPlay: false,
                    // autoPlayInterval: Duration(seconds: 4),
                    // enableInfiniteScroll: true,
                    // viewportFraction: 1.0,
                    items: List.generate(
                      widget.images.length,
                      (position) {
                        return InkWell(
                          onTap: () {
                            Utility.pushToNext(
                                ImageViewPage(
                                  images: widget.images,
                                  name: widget.name,
                                ),
                                context);
                          },
                          child: Container(
                            //color: Colors.red,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20,),
                              child: CachedNetworkImage(
                                height:double.maxFinite,
                               // width: double.maxFinite,
                                imageUrl: widget.images[position].imageUrl,
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
                                fit: BoxFit.fitHeight,
                              )),
                        );
                      },
                    ),
                    // onPageChanged: (position) {
                    //   setState(() {
                    //     currentPosition = position;
                    //   });
                    // },
                  ),
                )
              : Container(
                  height: 180,
                  child: Image.asset('assets/no_image.png', fit: BoxFit.cover),
                ),
          Container(
            color: Colors.transparent,
            child: new Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: List.generate(
                    (widget.images.length > 0) ? widget.images.length : 1,
                    (position) {
                  return Container(
                    margin: const EdgeInsets.only(left: 2),
                    child: Text('•',
                        style: TextStyle(
                            fontSize: (currentPosition == position) ? 30 : 30,
                            fontWeight: FontWeight.bold,
                            color: (currentPosition == position
                                ? Colors.grey
                                : Colors.grey.shade300))),
                  );
                })),
          ),
        ],
      ),
    );
  }
}

class RatingDialog extends StatefulWidget {
  final productId;
  final onSubmitCliked;
  final Review myReview;
  RatingDialog(
      {@required this.productId,
      @required this.onSubmitCliked,
      @required this.myReview});
  @override
  _RatingDialogState createState() => _RatingDialogState();
}

class _RatingDialogState extends State<RatingDialog> {
  final titleController = TextEditingController();
  final reviewController = TextEditingController();

  bool isTitleError = false;
  bool isReviewError = false;

  double rating = 1;

  @override
  void initState() {
    super.initState();
    if (widget.myReview != null) {
      setState(() {
        titleController.text = widget.myReview.reviewTitle;
        reviewController.text = widget.myReview.review;
        rating = widget.myReview.rating.toDouble();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Container(
      width: double.maxFinite,
      child: ListView(
        shrinkWrap: true,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SmoothStarRating(
                  allowHalfRating: false,
                  onRatingChanged: (v) {
                    myPrint(v.toString());
                    setState(() {
                      rating = v;
                    });
                  },
                  starCount: 5,
                  rating: rating,
                  size: 25.0,
                  color: red,
                  borderColor: red,
                  spacing: 0.0),
            ],
          ),
          SizedBox(
            height: 20,
          ),
          Container(
            child: TextField(
              controller: titleController,
              maxLines: 1,
              style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
              decoration: InputDecoration(
                  hintText: "Write Summary",
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                  errorText: (isTitleError) ? "Please enter summary" : null,
                  border: OutlineInputBorder(
                      gapPadding: 1.0,
                      borderSide: BorderSide(
                          color: Colors.grey.shade400,
                          width: 1,
                          style: BorderStyle.solid))),
            ),
          ),
          SizedBox(
            height: 8,
          ),
          Container(
            child: TextField(
              controller: reviewController,
              maxLines: 4,
              style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
              decoration: InputDecoration(
                  hintText: 'Write a Review',
                  errorText: (isReviewError) ? "Please enter review" : null,
                  border: OutlineInputBorder(
                      gapPadding: 1.0,
                      borderSide: BorderSide(
                          color: Colors.grey.shade400,
                          width: 1,
                          style: BorderStyle.solid))),
            ),
          ),
          SizedBox(
            height: 20,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              MaterialButton(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5)),
                color: blackGrey,
                child: Text('Submit', style: TextStyle(color: Colors.white)),
                onPressed: () {
                  setState(() {
                    isTitleError = titleController.text.isEmpty;
                    isReviewError = reviewController.text.isEmpty;
                  });
                  if (!isTitleError && !isReviewError) {
                    Navigator.pop(context);
                    final reviewTitle = titleController.text;
                    final review = reviewController.text;
                    final ratings = rating.toInt();
                    widget.onSubmitCliked(ratings, reviewTitle, review);
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
