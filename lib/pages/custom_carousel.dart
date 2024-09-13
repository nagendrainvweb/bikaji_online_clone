import 'package:bikaji/model/DashboardData.dart';
import 'package:bikaji/prefrence_util/Prefs.dart';
import 'package:bikaji/util/utility.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

class CustomCarousel extends StatefulWidget {
  bool autoScroll;
  List<BannerData> bannerList;
  CustomCarousel(this.autoScroll, {@required this.bannerList});
  @override
  _CustomCarouselState createState() => _CustomCarouselState();
}

class _CustomCarouselState extends State<CustomCarousel> {
  int currentPosition = 0;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    final double itemHeight = (size.height - kToolbarHeight - 24);
    final double itemWidth = size.width;
    return Container(
      color: Colors.white,
      child: Stack(
        children: <Widget>[
          Container(
            width: MediaQuery.of(context).size.width,
            height: double.infinity,
            child: CarouselSlider(
              options: CarouselOptions(
                  autoPlay: widget.autoScroll,
                  enlargeCenterPage: true,
                  enableInfiniteScroll: widget.autoScroll,
                  viewportFraction: 0.9,
                  aspectRatio: (itemWidth / itemHeight),
                  initialPage: 0,
                  enlargeStrategy: CenterPageEnlargeStrategy.height,
                  autoPlayCurve: Curves.easeIn,
                  onPageChanged: (index, reason) {
                    setState(() {
                      currentPosition = index;
                    });
                  }),

              //autoPlayCurve: Curves.fastLinearToSlowEaseIn,
              items: List.generate(
                widget.bannerList.length,
                (position) {
                  return InkWell(
                    onTap: () async {
                      final token = await Prefs.token;
                      final id = await Prefs.id;
                      myPrint("$token +" "+$id");
                      //myPrint(imageList.length);
                    },
                    child: Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5.0)),
                      child: ClipRRect(
                        borderRadius: new BorderRadius.circular(5.0),
                        child: Container(
                            width: double.infinity,
                            height: double.infinity,
                           
                            child: CachedNetworkImage(
                              imageUrl: widget.bannerList[position].imageUrl,
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
                            // new Image.asset(
                            //     widget.bannerList[position].imageUrl,
                            //   fit: BoxFit.cover,
                            // ),
                            ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: new Container(
              color: Colors.transparent,
              child: new Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(widget.bannerList.length, (position) {
                    return Container(
                      height: 20,
                      padding: EdgeInsets.all(4),
                      margin: EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: (currentPosition == position
                            ? Colors.grey.shade500
                            : Colors.grey.shade200),
                      ),
                    );
                    // return Text('•',
                    //     style: TextStyle(
                    //         fontSize: (currentPosition == position) ? 40 : 40,
                    //         color: (currentPosition == position
                    //             ? Colors.grey.shade500
                    //             : Colors.grey.shade200)));
                  })),
            ),
          )
        ],
      ),
    );
  }
}
