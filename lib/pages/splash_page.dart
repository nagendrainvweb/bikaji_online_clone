import 'package:bikaji/pages/dashboard_page.dart';
import 'package:bikaji/pages/login_demo.dart';
import 'package:bikaji/pages/login_page.dart';
import 'package:bikaji/util/utility.dart';
import 'package:flutter/material.dart';
import 'dart:async';



class SplashPage extends StatefulWidget {
  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  var isDone = false;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // var progressButton = ProgressButton(
    //   child: (state == ButtonState.inProgress)
    //       ? Container(
    //           padding: const EdgeInsets.all(3),
    //           height: 35,
    //           width: 35,
    //           child: (isDone)
    //               ? Icon(
    //                   Icons.done,
    //                   color: Colors.white,
    //                 )
    //               : CircularProgressIndicator(
    //                   backgroundColor: Colors.white,
    //                   strokeWidth: 2,
    //                 ),
    //         )
    //       : Text(
    //           "Test",
    //           style: TextStyle(color: Colors.white),
    //         ),
    //   onPressed: () {
    //     setState(() {
    //       state = ButtonState.inProgress;
    //     });
    //     Timer(Duration(seconds: 2), () {
    //       setState(() {
    //         isDone = true;
    //       });
    //     });
    //   },
    //   buttonState: state,
    //   backgroundColor: Theme.of(context).primaryColor,
    //   progressColor: Theme.of(context).primaryColor,
    // );

    return Scaffold(
      body: Container(
        child: Stack(
          children: <Widget>[
            new Center(child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 30),
               height: 50,
               child: Container()
               //progressButton
               )
                //  RaisedButton(
                //   child: new Text('Next'),
                //   onPressed: (){
                //     Utility.pushToNext(new LoginPage(), context);
                //   },
                // ),

                ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 30),
                      child: TextButton(
                        child: Text('stop'),
                        onPressed: () {
                          // setState(() {
                          //   state = ButtonState.normal;
                          //   isDone = false;
                          // });
                        },
                      ),
                    ),SizedBox(height: 10,),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 30),
                      child: TextButton(
                        child: Text('Login'),
                        onPressed: () {
                         Utility.pushToNext(LoginPage(), context);
                        },
                      ),
                    ),
                    SizedBox(height: 10,),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
