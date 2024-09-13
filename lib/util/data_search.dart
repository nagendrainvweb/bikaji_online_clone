import 'package:bikaji/model/SearchData.dart';
import 'package:bikaji/model/product.dart';
import 'package:bikaji/pages/productDetails.dart';
import 'package:bikaji/pages/productView.dart';
import 'package:bikaji/repo/Repository.dart';
import 'package:bikaji/repo/api_provider.dart';
import 'package:bikaji/util/url_list.dart';
import 'package:bikaji/util/utility.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class DataSearch extends SearchDelegate {
  final cities = [
    'Bhujia',
    'Asli Bikaneri',
    'Namkeen',
    'Papad',
    'Snacks',
    'Sweets',
    'New Arrivals',
    'Khokha Bhujia',
    'Makkanmalai',
    'Sidha Bhujia',
    'Super 3',
    'Tana tan',
  ];

  final suggestedCities = [
    'Bhujia',
    'Cookies',
    'Namkeen',
  ];

  @override
  ThemeData appBarTheme(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    assert(theme != null);
    return theme.copyWith(
      primaryColor: Colors.white,
      primaryIconTheme: theme.primaryIconTheme.copyWith(color: Colors.grey),
      primaryColorBrightness: Brightness.light,
      primaryTextTheme: theme.textTheme,
    );
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    // TODO: actions for app bar
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = "";
        },
      )
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    // TODO: leading icon on left
    return IconButton(
      icon: AnimatedIcon(
        icon: AnimatedIcons.menu_arrow,
        progress: transitionAnimation,
      ),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return Container();
  }

  Future<List<SearchData>> fetchSearchData(String query) async {
    try {
      final response = await ApiProvider().fetchSearchData(query);
      if (response.status == UrlConstants.SUCCESS) {
        return response.data;
      } else {
        return null;
      }
    } catch (e) {
      myPrint(e.toString());
      return null;
    }
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.length < 3) {
      return Container();
    }
    return FutureBuilder(
      future: fetchSearchData(query),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final List<SearchData> list = snapshot.data;
          return ListView.builder(
            itemCount: list.length,
            itemBuilder: (context, index) {
              return Container(
                padding: EdgeInsets.symmetric(vertical: 4),
                child: Column(
                  children: [
                    ListTile(
                      //contentPadding: EdgeInsets.symmetric(horizontal: 5),
                      leading: SizedBox(
                        height: 45,
                              width: 45,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            child: CachedNetworkImage(
                              height: 45,
                              width: 45,
                              imageUrl: Uri.encodeFull(list[index].images[0].imageUrl),
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
                              errorWidget: (context, value, data) => SizedBox(
                                width: 50,
                                child: Center(
                                  child: Image.asset("assets/no_image.png"),
                                ),
                              ),
                              fit: BoxFit.cover,
                            ),
                            // decoration: BoxDecoration(
                            //   image: DecorationImage(
                            //       image: AssetImage(
                            //         AssetsName.category2,
                            //       ),
                            //       fit: BoxFit.cover),
                            // ),
                          ),
                        ),
                      ),
                      trailing: Icon(Icons.launch,color: Colors.grey.shade400,),
                      title: new RichText(
                        text: TextSpan(
                            text: list[index].name.substring(0, query.length),
                            style: TextStyle(
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.w500),
                            children: [
                              TextSpan(
                                text: list[index].name.substring(query.length),
                                style: TextStyle(color: Colors.grey.shade600),
                              )
                            ]),
                      ),
                      onTap: () {
                        query = list[index].name;
                        showResults(context);
                        close(context, null);
                        Utility.pushToNext(
                            ProductDetails(
                              productId: list[index].id,
                            ),
                            context);
                      },
                    ),
                    Container(height:1,color: grey),
                  ],
                ),
              );
            },
          );
        } else {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
    //final suggestionList = query.isEmpty ? suggestedCities :cities.where((p)=> p.toLowerCase().startsWith(query.toLowerCase())).toList();
    // return ListView.builder(
    //   itemCount: suggestionList.length,
    //   itemBuilder: (context, index) {
    //     return ListTile(
    //       leading: Icon((query.isEmpty)?Icons.history:Icons.search),
    //       title: new RichText(
    //         text: TextSpan(
    //           text: suggestionList[index].substring(0,query.length),
    //           style: TextStyle(color: red,fontWeight: FontWeight.w500),
    //           children: [
    //             TextSpan(
    //               text: suggestionList[index].substring(query.length),
    //               style: TextStyle(color: Colors.grey),
    //             )
    //           ]
    //         ),
    //       ),
    //       onTap: (){
    //         query = suggestionList[index];
    //        //showResults(context);
    //        Utility.pushToNext(ProductDetails(), context);
    //       },
    //     );
    //   },
    // );
  }

  _getFilterList() {
    List<String> list = new List();
    for (var item in cities) {
      myPrint('added ${item.startsWith(query)}');
      if (item.toLowerCase().startsWith(query)) {
        myPrint('added');
        list.add(item);
      }
    }
    return list;
  }
}
