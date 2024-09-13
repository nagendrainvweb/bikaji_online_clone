import 'package:bikaji/util/textStyle.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:bikaji/model/product.dart';

class ImageViewPage extends StatefulWidget {
  final List<Images> images;
  final name;
  ImageViewPage({@required this.images, @required this.name});
  @override
  _ImageViewPageState createState() => _ImageViewPageState();
}

class _ImageViewPageState extends State<ImageViewPage> {
  int currentPosition = 0;
  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    /*24 is for notification bar on Android*/
    final double itemHeight = (size.height - kToolbarHeight - 24) / 2;
    final double itemWidth = size.width / 2;
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(45),
        child: AppBar(
          elevation: 0,
          backgroundColor: Colors.red,
          title: Text(
            '${widget.name}',
            style: toolbarStyle,
          ),
          leading: IconButton(
              icon: Icon(Icons.chevron_left),
              onPressed: () {
                Navigator.pop(context);
              }),
        ),
      ),
      body: Stack(
        children: <Widget>[
          Container(
              child: (widget.images.length > 1)
                  ? Container(
                      height: double.infinity,
                      child: CarouselSlider(
                        options: CarouselOptions(
                            autoPlay: false,
                            enlargeCenterPage: true,
                            enableInfiniteScroll: false,
                            viewportFraction: 1.0,
                            aspectRatio: (itemWidth / itemHeight),
                            initialPage: 0,
                            autoPlayCurve: Curves.easeIn,
                            onPageChanged: (index, reason) {
                              setState(() {
                                currentPosition = index;
                              });
                            }),
                        items: widget.images.map((image) {
                          return Builder(
                            builder: (BuildContext context) {
                              return Container(
                                  width: MediaQuery.of(context).size.width,
                                  child: PhotoView(
                                    backgroundDecoration:
                                        BoxDecoration(color: Colors.white),
                                    imageProvider: NetworkImage(image.imageUrl),
                                    initialScale:
                                        PhotoViewComputedScale.contained * 0.8,
                                  ));
                            },
                          );
                        }).toList(),
                      ),
                    )
                  : PhotoView(
                      backgroundDecoration: BoxDecoration(color: Colors.white),
                      imageProvider: NetworkImage(widget.images[0].imageUrl),
                      initialScale: PhotoViewComputedScale.contained * 1,
                    )),
          (widget.images.length > 1)
              ? Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    color: Colors.transparent,
                    child: new Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: List.generate(
                            (widget.images.length > 0)
                                ? widget.images.length
                                : 1, (position) {
                          return Container(
                            margin: const EdgeInsets.only(left: 2),
                            child: Text('•',
                                style: TextStyle(
                                    fontSize:
                                        (currentPosition == position) ? 35 : 35,
                                    fontWeight: FontWeight.bold,
                                    color: (currentPosition == position
                                        ? Colors.grey
                                        : Colors.grey.shade300))),
                          );
                        })),
                  ),
                )
              : Container(),
        ],
      ),
    );
  }
}
