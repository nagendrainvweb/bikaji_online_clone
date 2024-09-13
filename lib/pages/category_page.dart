import 'dart:convert';

import 'package:bikaji/bloc/product_bloc/ProdcutBloc.dart';
import 'package:bikaji/bloc/product_bloc/ProductState.dart';
import 'package:bikaji/model/CategoryData.dart';
import 'package:bikaji/model/product.dart';
import 'package:bikaji/pages/home.dart';
import 'package:bikaji/pages/productView.dart';
import 'package:bikaji/pages/subCategory_page.dart';
import 'package:bikaji/prefrence_util/Prefs.dart';
import 'package:bikaji/repo/Repository.dart';
import 'package:bikaji/repo/api_provider.dart';
import 'package:bikaji/util/constants.dart';
import 'package:bikaji/util/dialog_helper.dart';
import 'package:bikaji/util/utility.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CategoryPage extends StatefulWidget {
  final categoryId;
  CategoryPage({@required this.categoryId});
  @override
  _CategoryPageState createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  List<CategoryData> categoryList = null;
  final _refreshIndicator = GlobalKey<RefreshIndicatorState>();
  bool isFailed = false;

  @override
  void initState() {
    super.initState();
    //_fetchCategory();
    if (widget.categoryId == null) {
      _setData();
    } else {
      setSubCategoryData();
    }
  }

  setSubCategoryData() async {
    try {
      final response = await ApiProvider()
          .fetchSubCategoryList(widget.categoryId);
      if (response.status == Constants.success) {
        setState(() {
          categoryList = response.data;
          isFailed = false;
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

  _setData() async {
    final categoryData = await Prefs.categoryData;
    if (categoryData.isEmpty) {
      _fetchCategory();
    } else {
      try {
        final listResponse = json.decode(categoryData);
        List<CategoryData> list = List();
        for (var map in listResponse) {
          final catgeory = CategoryData.fromJson(map);
          list.add(catgeory);
        }
        setState(() {
          categoryList = list;
        });
        if (!isRefreshed) {
          Future.delayed(Duration(milliseconds: 200),
              () => _refreshIndicator.currentState.show());
        }
      } catch (e) {
        myPrint(e.toString());
        _fetchCategory();
      }
    }
  }

  _fetchCategory() async {
    final userid = await Prefs.id;
    final token = await Prefs.token;
    myPrint('$userid  $token');
    try {
      final response = await ApiProvider()
          .fetchCategoryList(userid);
      if (response.status == Constants.success) {
        setState(() {
          isFailed = false;
          categoryList = response.data;
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

  @override
  Widget build(BuildContext context) {
    //_productList = new Utility().getExclusiveList();
    return Container(
      padding: EdgeInsets.fromLTRB(5, 5, 5, 5),
      child: (isFailed)
          ? HomeErrorWidget(
              message: SOMETHING_WRONG_TEXT,
              onRetryCliked: () async {
                if (widget.categoryId == null) {
                  _fetchCategory();
                } else {
                  setSubCategoryData();
                }
              })
          : (categoryList == null)
              ? Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                  key: _refreshIndicator,
                  onRefresh: () async {
                    if (widget.categoryId == null) {
                      await _fetchCategory();
                    } else {
                      await setSubCategoryData();
                    }
                  },
                  child: new GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2, childAspectRatio: 1.3),
                    itemCount: categoryList.length,
                    itemBuilder: (context, index) {
                      return Container(
                        margin: EdgeInsets.only(
                            left: 3, right: 3, top: 3, bottom: 3),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            color: Colors.white24),
                        child: InkWell(
                          onTap: () async {
                            if (!categoryList[index].hasSubcats) {
                              Utility.pushToNext(
                                  BlocProvider(
                                    create: (BuildContext context) =>
                                        ProductBloc(ProductLoadingState()),
                                    child: ProductView(
                                      title: categoryList[index].title,
                                      id: categoryList[index].id,
                                    ),
                                  ),
                                  context);
                            } else {
                              Utility.pushToNext(
                                  SubCategoryPage(
                                      categoryId: categoryList[index].id,
                                      title: categoryList[index].title),
                                  context);
                            }
                          },
                          child: Stack(
                            children: <Widget>[
                              Container(
                                width: double.maxFinite,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(5),
                                  child: (categoryList[index].imageUrl == "")?
                                   Image.asset("assets/no_image.png",
                                      fit: BoxFit.cover):
                                      CachedNetworkImage(
                              imageUrl: categoryList[index].imageUrl,
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
                                      ,
                                ),
                              ),
                              Container(
                                height: double.infinity,
                                decoration: BoxDecoration(
                                    // color: Colors.black54,
                                    //  gradient: new LinearGradient(
                                    //    begin: FractionalOffset.bottomCenter,
                                    //    end: FractionalOffset.topCenter,
                                    //    colors: [
                                    //      const Color(0xff232526),
                                    //      const Color(0x002c3e50),
                                    //    ]
                                    //  ),
                                    borderRadius: BorderRadius.circular(5)),
                                child: Column(
                                  mainAxisSize: MainAxisSize.max,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Container(
                                      width: double.infinity,
                                      margin: EdgeInsets.only(top: 15),
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        children: <Widget>[
                                          new Container(
                                            child: new Text(
                                              categoryList[index].title,
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 15,
                                                  letterSpacing: 0.5,
                                                  fontWeight: FontWeight.w700),
                                            ),
                                          ),
                                          SizedBox(
                                            height: 5,
                                          ),
                                          new Container(
                                            child: new Text(
                                              categoryList[index].itemCount,
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 10,
                                                  //letterSpacing: 0.5,
                                                  fontWeight: FontWeight.w500),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
