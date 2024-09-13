import 'package:bikaji/bloc/product_bloc/ProdcutBloc.dart';
import 'package:bikaji/bloc/product_bloc/ProductEvent.dart';
import 'package:bikaji/bloc/product_bloc/ProductState.dart';
import 'package:bikaji/model/Pagination.dart';
import 'package:bikaji/model/ProductListResponse.dart';
import 'package:bikaji/model/product.dart';
import 'package:bikaji/pages/cart_full_page.dart';
import 'package:bikaji/pages/productDetails.dart';
import 'package:bikaji/pages/wishList_page.dart';
import 'package:bikaji/prefrence_util/Prefs.dart';
import 'package:bikaji/repo/Repository.dart';
import 'package:bikaji/repo/api_provider.dart';
import 'package:bikaji/util/custom_icons.dart';
import 'package:bikaji/util/data_search.dart';
import 'package:bikaji/util/dialog_helper.dart';
import 'package:bikaji/util/textStyle.dart';
import 'package:bikaji/util/url_list.dart';
import 'package:bikaji/util/utility.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart';
import 'package:shimmer/shimmer.dart';

class ProductView extends StatefulWidget {
  final title;
  final id;
  final type;
  ProductView({this.title, this.id, this.type});
  @override
  _ProductViewState createState() => _ProductViewState();
}

class _ProductViewState extends State<ProductView> implements FilterClick {
  List<Product> productList = new List();
  AnimationController _appbarController;
  AnimationController _filterController;
  String _selectedSort = 'Popular';
  String _selectedFilterType = '';
  double _selectedFilterPriceValue = 0.1;
  bool _isFilterApplied = false;
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  bool isLoading = false;
  String cartCount = "0";
  List<Product> _productList;
  Pagination _pagination;
  // bool isNext = true;
  // int pageNo = 1;

  ProductBloc productBloc;

  @override
  void initState() {
    // productList = Utility().getProductList();
    super.initState();
    checkInternet();
    _setData();
  }

  _setData() async {
    final userId = await Prefs.id;
     productBloc = BlocProvider.of<ProductBloc>(context);
    productBloc.add(FetchProduct(
        userId: userId, categoryId: widget.id, pageNo: 1, type: widget.type));
        
    var count = await Prefs.cartCount;
    setState(() {
      cartCount = count.toString();
    });
  }

  checkInternet() async {
    bool isInternet = await Utility.getConenctionStatus();
    if (!isInternet) {
      new DialogHelper().showNoInternetDialog(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: (widget.title == 'Search')
          ? null
          : PreferredSize(
              preferredSize: Size.fromHeight(45),
              child: AppBar(
                elevation: 0,
                backgroundColor: Colors.red.shade500,
                title: Text(
                  widget.title,
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
                leading: IconButton(
                  icon: Icon(Icons.chevron_left),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                actions: <Widget>[
                  IconButton(
                    icon: Icon(
                      MyFlutterApp.ic_search,
                      color: Colors.white,
                      size: 18,
                    ),
                    onPressed: () {
                      showSearch(context: context, delegate: DataSearch());
                    },
                  ),
                  IconButton(
                    icon: Container(
                      child: Stack(
                        children: <Widget>[
                          Icon(
                            MyFlutterApp.ic_cart,
                            size: 18,
                            color: Colors.white,
                          ),
                        (cartCount!="0")?  Container(
                            margin: EdgeInsets.only(top:8,left:10),
                            child: Container(
                              width: 15,
                              height: 15,
                              decoration: BoxDecoration(
                                  color: green, shape: BoxShape.circle),
                              child: Center(
                                  child: Text(
                                cartCount,
                                style: TextStyle(color: white, fontSize: 9,fontWeight: FontWeight.bold),
                              )),
                            ),
                          ):SizedBox()
                        ],
                      ),
                    ),
                    onPressed: () {
                      Utility.pushToNext(CartMainPage(), context);
                    },
                  ),
                  IconButton(
                    icon: Icon(
                      MyFlutterApp.ic_fav,
                      color: Colors.white,
                      size: 18,
                    ),
                    onPressed: () {
                      Utility.pushToNext(WishListPage(), context);
                    },
                  ),
                ],
              ),
            ),
      body: BlocBuilder<ProductBloc, ProductState>(
        builder: (context, state) {
          if (state is ProductLoadingState) {
            return ProgressWidget();
          } else if (state is ProductIsNotLoadedState) {
            return ErrorWidget(
              message: state.message,
            );
          } else if (state is ProductSuccessState) {
            if (_pagination == null && state.response != null) {
              _pagination = state.response.pagination;
              _productList = state.response.productlist;
            }
            return Container(
              child: Column(
                children: <Widget>[
                  Expanded(
                      child: (state.response != null)
                          ? Stack(
                              children: <Widget>[
                                NotificationListener<ScrollNotification>(
                                  onNotification: (scrollInfo) {
                                    if (scrollInfo.metrics.pixels ==
                                        scrollInfo.metrics.maxScrollExtent) {
                                      _loadMore();
                                      //print(' i am at bottom');
                                    }
                                    return true;
                                  },
                                  child: (_productList.length > 0)
                                      ? GridView.builder(
                                          addRepaintBoundaries: true,
                                          gridDelegate:
                                              new SliverGridDelegateWithFixedCrossAxisCount(
                                                  crossAxisCount: 2,
                                                  childAspectRatio: 0.8),
                                          itemCount: _productList.length,
                                          itemBuilder: (context, index) {
                                            return Container(
                                              child: InkWell(
                                                onTap: () {
                                                  Utility.pushToNext(
                                                      ProductDetails(
                                                        productId:
                                                            _productList[index]
                                                                .id,
                                                      ),
                                                      context);
                                                },
                                                child: _setTopSellingProducts(
                                                    index, _productList),
                                              ),
                                            );
                                          },
                                        )
                                      : ErrorWidget(
                                          message: "No Product Found",
                                        ),
                                ),
                                BottomCircularLoadingWidget(
                                  isLoading: isLoading,
                                ),
                              ],
                            )
                          : ErrorWidget(
                              message: "No Product Found",
                            )),
                  _getFilterSortView,
                ],
              ),
            );
          } else {
            return ErrorWidget(
              message: "No Product Found",
            );
          }
        },
      ),
    );
  }

  _loadMore() async {
    //print(_pagination.toJson());
    if (!isLoading && _pagination.isNext) {
      try {
        setState(() {
          isLoading = true;
        });
        final userid = await Prefs.id;
        final pageNo = _pagination.next;
        final categoryId = widget.id;
        final type = widget.type;
        var response;
        if (categoryId.isEmpty) {
          response = await ApiProvider()
              .fetchProductByType(userid, pageNo, type);
        } else {
          if (_isFilterApplied) {
            final fromValue = _selectedFilterPriceValue * 1000;
            response = await ApiProvider()
                .fetchFilteredProductList(
                    userid, pageNo, widget.id, "", "0", fromValue.toInt());
          } else {
            response = await ApiProvider()
                .fetchProductList(userid, pageNo, categoryId);
          }
        }

        if (response.status == UrlConstants.SUCCESS) {
          setState(() {
            //print("pagination is ${response.data.pagination.toJson()}");
            _pagination = response.data.pagination;
            _productList.addAll(response.data.productlist);
            isLoading = false;
          });
        } else {
          setState(() {
            isLoading = false;
          });
          Utility.showSnackBar(_scaffoldKey, onRetryCliked: () => _loadMore());
        }
      } catch (e) {
        print(e.toString());
        setState(() {
          isLoading = false;
        });
        Utility.showSnackBar(_scaffoldKey, onRetryCliked: () => _loadMore());
      }
    }
  }

  get _getFilterSortView {
    return AnimatedContainer(
        //height: !isScrolling ? 50.0 : 0.0,
        duration: Duration(milliseconds: 50),
        curve: Curves.easeIn,
        child:
            // !isScrolling ?
            Column(
          children: <Widget>[
            Container(
              height: 2,
              color: Colors.black12,
            ),
            Container(
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        _showSortBottom();
                      },
                      child: Container(
                        decoration: BoxDecoration(
                            border: Border(
                                right: BorderSide(
                                    color: Colors.grey.shade200, width: 0.5))),
                        padding: const EdgeInsets.all(15),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Icon(
                              Icons.sort,
                              color: Colors.grey.shade500,
                              size: 18,
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Text('SORT',
                                style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600))
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Column(
                  //   mainAxisSize: MainAxisSize.max,
                  //   children: <Widget>[
                  //     Container(
                  //       height: 30,
                  //       width: 1,
                  //       color: Colors.grey.shade400,
                  //     ),
                  //   ],
                  // ),
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        _showFilterBottom();
                      },
                      child: Container(
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                            border: Border(
                                left: BorderSide(
                                    color: Colors.grey.shade200, width: 0.5))),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Icon(
                              Icons.filter_list,
                              color: Colors.grey.shade500,
                              size: 18,
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Text(
                              'FILTER',
                              style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600),
                            )
                          ],
                        ),
                      ),
                    ),
                  )
                ],
              ),
            )
          ],
        )
        //:Container(),
        );
  }

  _showFilterBottom() {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return FilterView(
            selectedFilterType: _selectedFilterType,
            value: _selectedFilterPriceValue,
            onFilterClearClick: () async {
              if (_isFilterApplied) {
                _selectedFilterPriceValue = null;
                _selectedFilterType = '';
                _isFilterApplied = false;
                _productList = null;
                _pagination = null;
                final userid = await Prefs.id;
                productBloc.add(FetchProduct(
                    userId: userid,
                    categoryId: widget.id,
                    pageNo: 1,
                    type: widget.type));
              }
            },
            onFilterTypeClick: (value, type) async {
              _selectedFilterPriceValue = value;
              _selectedFilterType = type;
              _productList = null;
              _pagination = null;
              _isFilterApplied = true;
              final userid = await Prefs.id;
              final fromValue = value * 1000;
              productBloc.add(FetchFilterProduct(
                  userid, "1", widget.id, "", "0", fromValue.toInt()));
            },
          );
        });
  }

  // _fetchFilterproductList()async{
  //   final userid  = await Prefs.id;
  //   final pageNo = (_pagination==null)?"1":_pagination.next;
  //   try{
  //    final response = await Repository(appApiProvider: ApiProvider()).fetchFilteredProductList(userid, pageNo, widget.id, "", "0", _selectedFilterPriceValue.toInt());
  //   }catch(e){
  //     print(e.toString());
  //   }
  // }

  @override
  void onFilterTypeClick(title) {
    // TODO: implement onFilterTypeClick
  }

  _showSortBottom() {
    var _sortList = [
      'Popular',
      'Name',
      'Price-High to Low',
      'Price-Low to High',
      // 'Bestseller',
      // 'Most Viewed',
      // 'New',
      // 'Discounted/Offer'
    ];
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return Container(
            height: 210,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                  Container(
              // padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Row(
            children: <Widget>[
              Expanded(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  child: Text(
                    'SORT BY',
                    textAlign: TextAlign.start,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                  ),
                ),
              ),
              IconButton(
                  icon: Icon(Icons.close, color: Colors.grey.shade700),
                  onPressed: () {
                    Navigator.pop(context);
                  })
            ],
          )),
                Container(
                  height: 1,
                  color: Colors.grey.shade300,
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: _sortList.length,
                    itemBuilder: (context, index) {
                      return InkWell(
                        onTap: () {
                          setState(() {
                            _selectedSort = _sortList[index];
                          });
                          Navigator.pop(context);
                          _productList.sort((a, b) {
                            if(index == 0){
                               return a.orderBy
                                  .compareTo(b.orderBy);
                            }
                            if (index == 1) {
                              return a.name
                                  .toLowerCase()
                                  .compareTo(b.name.toLowerCase());
                            }
                            if (index == 2) {
                              return b.newPrice.compareTo(a.newPrice);
                            }
                            if (index == 3) {
                              return a.newPrice.compareTo(b.newPrice);
                            }
                            setState(() {});
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 30, vertical: 12),
                          child: Row(
                            children: <Widget>[
                              Expanded(
                                child: Text(
                                  _sortList[index],
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: (_sortList[index] == _selectedSort)
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                      color: Colors.grey.shade700),
                                ),
                              ),
                             (_sortList[index] == _selectedSort)? Icon(Icons.check,color:red,size: 16):Container(),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                )
              ],
            ),
          );
        });
  }

  Widget _setTopSellingProducts(var position, var productList) {
    //print(productList[position]);
    return Container(
      //   width: 100,
      decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade200, width: 1)),
      child: Container(
          child: Stack(
        children: <Widget>[
          Container(
              padding: const EdgeInsets.all(12),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: new Container(
                      width: double.maxFinite,
                      height: double.maxFinite,
                      child: (productList[position].images.length > 0)
                          ? CachedNetworkImage(
                              imageUrl: productList[position].images[0].imageUrl,
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
                            )
                          : Image.asset('assets/no_image.png'),
                      //new Image.network(productList[position].images[0].imageUrl),
                    ),
                  ),
                  new SizedBox(
                    height: 5,
                  ),
                  new Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        new Text(
                          productList[position].name,
                          maxLines: 2,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Colors.grey.shade700,
                              fontSize: 13,
                              fontWeight: FontWeight.w500),
                        ),
                        new SizedBox(
                          height: 2,
                        ),
                        new Text(
                          '₹ ${productList[position].newPrice}',
                          // textAlign: TextAlign.center,
                          style: TextStyle(
                              color: red,
                              fontSize: 12,
                              fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 14,
                  ),
                  (productList[position].isInStock ?? false)
                      ? Utility.customRoundedWidget('ADD TO CART', red,
                          onClick: () {
                          Utility.showMoveToBagBottomSheet(context,
                              product: productList[position],
                              onDoneClick: (int quntity, Sizes size) async {
                            Navigator.pop(context);
                            bool value = await Utility.addToCart(
                                context,
                                _scaffoldKey,
                                productList[position].id,
                                quntity,
                                size?.id,
                                false);
                            if (value) {
                               int count = await Prefs.cartCount;
                               setState(() {
                                 cartCount = count.toString();
                               });
                              // Prefs.setCartCount(cartCount++);
                              //widget.onRefresh();
                            }
                          });
                        })
                      : Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5),
                          child: Text(
                            'OUT OF STOCK',
                            style: smallTextStyle,
                          )),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.topRight,
            child: InkWell(
              onTap: () async {
                final product = productList[position];
                bool value = await Utility.performWishList(
                    context,
                    _scaffoldKey,
                    productList[position].id,
                    productList[position].isInWishlist,
                    false);
                setState(() {
                  if (value??false) {
                    product.isInWishlist = !product.isInWishlist;
                  }
                });
              },
              child: Container(
                padding: EdgeInsets.all(20),
                child: new Icon(
                  Icons.favorite,
                  color: (!productList[position].isInWishlist)
                      ? Colors.grey.shade400
                      : Colors.red,
                  size: 15,
                ),
              ),
            ),
          )
        ],
      )),
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
                // if (int.parse(product.qty) > 1) {
                //   setState(() {
                //    // int.parse(product.qty)--;
                //   });
                // } else {
                //   setState(() {
                //     product.isInCart = !product.isInCart;
                //     cartCount--;
                //   });
                // }
              },
              child: ClipRRect(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    bottomLeft: Radius.circular(20)),
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 6, horizontal: 10),
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
                  //   product.qty++;
                });
              },
              child: ClipRRect(
                  borderRadius: BorderRadius.only(
                      topRight: Radius.circular(20),
                      bottomRight: Radius.circular(20)),
                  child: Container(
                      padding:
                          EdgeInsets.symmetric(vertical: 6, horizontal: 10),
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

class BottomCircularLoadingWidget extends StatelessWidget {
  const BottomCircularLoadingWidget({
    this.isLoading,
    Key key,
  }) : super(key: key);
  final isLoading;

  @override
  Widget build(BuildContext context) {
    return (isLoading ?? false)
        ? Align(
            alignment: Alignment.bottomCenter,
            child: FloatingActionButton(
              backgroundColor: Colors.white,
              onPressed: () {},
              child: Container(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                ),
              ),
            ),
          )
        : Container();
  }
}

class ProgressWidget extends StatelessWidget {
  const ProgressWidget({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}

class ErrorWidget extends StatelessWidget {
  const ErrorWidget({Key key, this.message}) : super(key: key);

  final message;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Text(message),
        ),
      ),
    );
  }
}

class FilterView extends StatefulWidget {
  String selectedFilterType;
  var value;
  Function onFilterTypeClick;
  Function onFilterClearClick;

  FilterView(
      {this.selectedFilterType,
      this.value,
      this.onFilterTypeClick,
      this.onFilterClearClick});
  @override
  _FilterViewState createState() => _FilterViewState();
}

class _FilterViewState extends State<FilterView> {
  var _value = 0.1;
  var _secondValue = 0.1;
  var _typeList = ['MASALA', 'ROASTED', 'SALTED'];

  @override
  void initState() {
    super.initState();
    if (widget.value != null) {
      _value = widget.value;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 250,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
              // padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Row(
            children: <Widget>[
              Expanded(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  child: Text(
                    'FILTER BY',
                    textAlign: TextAlign.start,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                  ),
                ),
              ),
              IconButton(
                  icon: Icon(Icons.close, color: Colors.grey.shade700),
                  onPressed: () {
                    Navigator.pop(context);
                  })
            ],
          )),
          Container(
            height: 1,
            color: Colors.grey.shade300,
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 18),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Price',
                    style: smallTextStyle,
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Slider(
                    value: _value,
                    activeColor: Colors.red,
                    inactiveColor: Colors.grey.withOpacity(0.3),
                    onChanged: (value) {
                      setState(() {
                        _value = value;
                      });
                    },
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        '$rupee ${(_value * 1000).toStringAsFixed(0)}',
                        style: smallTextStyle,
                      ),
                      Text(
                        '$rupee 1000',
                        style: smallTextStyle,
                      )
                    ],
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  // Text('Type', style: smallTextStyle),
                  // SizedBox(
                  //   height: 10,
                  // ),
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.spaceAround,
                  //   children: <Widget>[
                  //     Expanded(
                  //       child: _getTypeView(_typeList[0]),
                  //     ),
                  //     SizedBox(
                  //       width: 10,
                  //     ),
                  //     Expanded(
                  //       child: _getTypeView(_typeList[1]),
                  //     ),
                  //     SizedBox(
                  //       width: 10,
                  //     ),
                  //     Expanded(
                  //       child: _getTypeView(_typeList[2]),
                  //     ),
                  //   ],
                  // )
                ],
              ),
            ),
          ),
          // Container(
          //   height: 1,
          //   color: Colors.grey.shade300,
          // ),
          Container(
            child: Row(
              children: <Widget>[
                Expanded(
                    child: InkWell(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    decoration: BoxDecoration(
                        border:
                            Border.all(color: Colors.grey[200], width: 1.0)),
                    child: Text(
                      'Close',
                      textAlign: TextAlign.center,
                      style:
                          TextStyle(fontSize: 12, color: Colors.grey.shade700),
                    ),
                  ),
                )),
                Expanded(
                    child: InkWell(
                  onTap: () {
                    Navigator.pop(context);
                    widget.onFilterClearClick();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    decoration: BoxDecoration(
                        border:
                            Border.all(color: Colors.grey[200], width: 1.0)),
                    child: Text(
                      'Reset',
                      textAlign: TextAlign.center,
                      style:
                          TextStyle(fontSize: 12, color: Colors.grey.shade700),
                    ),
                  ),
                )),
                Expanded(
                    child: InkWell(
                  onTap: () {
                    Navigator.pop(context);
                    widget.onFilterTypeClick(_value, widget.selectedFilterType);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    decoration: BoxDecoration(
                        border:
                            Border.all(color: Colors.grey[200], width: 1.0)),
                    child: Text(
                      'Apply',
                      textAlign: TextAlign.center,
                      style:
                          TextStyle(fontSize: 12, color: Colors.grey.shade700),
                    ),
                  ),
                )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  _getTypeView(String title) {
    return InkWell(
      onTap: () {
        setState(() {
          widget.selectedFilterType = title;
        });
      },
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            color: (widget.selectedFilterType == title)
                ? Colors.red.shade500
                : Colors.white,
            border: Border.all(
                color: (widget.selectedFilterType == title)
                    ? Colors.red.shade500
                    : Colors.red.shade200,
                width: (widget.selectedFilterType == title) ? 1.1 : 1)),
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
        child: Text(
          title,
          style: (widget.selectedFilterType == title)
              ? enabledTextStyle
              : disabledTextStyle,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

abstract class FilterClick {
  void onFilterTypeClick(title);
}
