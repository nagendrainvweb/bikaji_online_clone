import 'package:bikaji/util/utility.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

class IntroPage extends StatefulWidget {
  @override
  _IntroPageState createState() => _IntroPageState();
}

class _IntroPageState extends State<IntroPage> {
  var list = [0, 1, 2];
  var currentPosition = 0;
  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    /*24 is for notification bar on Android*/
    final double itemHeight = (size.height - kToolbarHeight - 24) / 2;
    final double itemWidth = size.width / 2;
    return Scaffold(
      body: Container(
        child: Stack(
          children: <Widget>[
            CarouselSlider(
              options: CarouselOptions(
                  enlargeCenterPage: true,
                  viewportFraction: 1.0,
                  aspectRatio: (itemWidth / itemHeight),
                  initialPage: 0,
                  autoPlayCurve: Curves.easeIn,
                  onPageChanged: (index, reason) {
                    setState(() {
                      currentPosition = index;
                    });
                  }),
              items: list.map((i) {
                return Builder(
                  builder: (BuildContext context) {
                    return Container(
                        width: MediaQuery.of(context).size.width,
                        //decoration: BoxDecoration(color: Colors.amber),
                        child: Center(
                            child: Text(
                          'text $i',
                          style: TextStyle(fontSize: 16.0),
                        )));
                  },
                );
              }).toList(),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: list
                      .map((i) => Container(
                            margin: const EdgeInsets.fromLTRB(5, 5, 5, 20),
                            height: 8,
                            width: 8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: (i == currentPosition) ? red : grey,
                            ),
                          ))
                      .toList()),
            )
          ],
        ),
      ),
    );
  }
}
