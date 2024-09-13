import 'package:bikaji/model/Pagination.dart';
import 'package:bikaji/model/ProductData.dart';
import 'package:bikaji/pages/productView.dart';
import 'package:bikaji/repo/Repository.dart';
import 'package:bikaji/repo/api_provider.dart';
import 'package:bikaji/util/dialog_helper.dart';
import 'package:bikaji/util/textStyle.dart';
import 'package:bikaji/util/url_list.dart';
import 'package:bikaji/util/utility.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

class AllReviewPage extends StatefulWidget {
  final productId;
  AllReviewPage({@required this.productId});
  @override
  _AllReviewPageState createState() => _AllReviewPageState();
}

class _AllReviewPageState extends State<AllReviewPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  bool isLoading = false;
  ReviewData _reviewData;
  Pagination _pagination;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  _fetchData() async {
    try {
      final response = await ApiProvider()
          .fetchReview(widget.productId, "1");
      if (response.status == UrlConstants.SUCCESS) {
        setState(() {
          _reviewData = response.data.items;
          _pagination = response.data.links;
        });
      } else {
        DialogHelper.showErrorDialog(context, "Error", response.message,
            showTitle: true, onOkClicked: () {
          Navigator.pop(context);
          Navigator.pop(context);
        });
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
  _loadMore()async{
    if (!isLoading && _pagination.isNext) {
      setState(() {
          isLoading = true;
        });
       try {
      final response = await ApiProvider()
          .fetchReview(widget.productId, _pagination.next.toString());
      if (response.status == UrlConstants.SUCCESS) {
        setState(() {
          _reviewData = response.data.items;
          _pagination = response.data.links;
          isLoading = false;
        });
      } else {
        setState(() {
            isLoading = false;
          });
        DialogHelper.showErrorDialog(context, "Error", response.message,
            showTitle: true, onOkClicked: () {
          Navigator.pop(context);
          Navigator.pop(context);
        });
      }
    } catch (e) {
      setState(() {
            isLoading = false;
          });
      myPrint(e.toString());
      DialogHelper.showErrorDialog(context, "Error", SOMETHING_WRONG_TEXT,
          showTitle: true, onOkClicked: () {
        Navigator.pop(context);
        Navigator.pop(context);
      });
    }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(45),
        child: AppBar(
          title: Text('All Reviews', style: toolbarStyle),
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
      body: (_reviewData == null)
          ? Container(
              child: Center(
                child: CircularProgressIndicator(),
              ),
            )
          : Stack(
            children: <Widget>[
              Container(
                  color: Colors.grey.shade100,
                  child: NotificationListener<ScrollNotification>(
                    onNotification: (scrollInfo) {
                      if (scrollInfo.metrics.pixels ==
                          scrollInfo.metrics.maxScrollExtent) {
                        _loadMore();
                        //myPrint(' i am at bottom');
                      }
                      return true;
                    },
                    child: ListView(
                      children: <Widget>[
                        Container(
                            color: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                vertical: 20, horizontal: 25),
                            child: _ratingReviewWidget()),
                        SizedBox(
                          height: 10,
                        ),
                        Container(
                            color: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: _getReviewList()),
                      ],
                    ),
                  ),
                ),
                 BottomCircularLoadingWidget(
                          isLoading: isLoading,
                        ),
            ],
          ),
    );
  }

  Widget _ratingReviewWidget() {
    final average = double.parse(_reviewData.averageRating.toString()).round();
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
                  '(Based on ${_reviewData.totalReviews} reviews)',
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
                    '5★', _reviewData.fiveStarCount, _reviewData.totalReviews),
                _ratingRow(
                    '4★', _reviewData.fourStarCount, _reviewData.totalReviews),
                _ratingRow(
                    '3★', _reviewData.threeStarCount, _reviewData.totalReviews),
                _ratingRow(
                    '2★', _reviewData.twoStarCount, _reviewData.totalReviews),
                _ratingRow(
                    '1★', _reviewData.oneStarCount, _reviewData.totalReviews),
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

  Widget _getReviewList() {
    final reviewList = _reviewData.review;
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
                // Container(
                //   height: 1,
                //   color: Colors.grey.shade300,
                // ),
                // (index == 1)
                //     ? InkWell(
                //       onTap: (){
                //         Utility.pushToNext(AllReviewPage(), context);
                //       },
                //       child: Row(
                //         mainAxisAlignment: MainAxisAlignment.center,
                //         children: <Widget>[
                //           Container(
                //             margin: const EdgeInsets.only(top: 15),
                //             child: Text(
                //               'READ ALL REVIEWS ',
                //               style: TextStyle(
                //                   color: Colors.grey.shade600,
                //                   fontWeight: FontWeight.bold,
                //                   fontSize: 12),
                //             ),
                //           ),
                //           Container(
                //             margin: const EdgeInsets.only(top: 15),
                //             child: Icon(
                //               Icons.chevron_right,
                //               size: 18,
                //               color: Colors.grey.shade600,
                //             ),
                //           )
                //         ],
                //       ),
                //     )
                //     : Container()
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
}
