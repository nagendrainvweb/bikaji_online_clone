import 'package:flutter/material.dart';

abstract class AppHelper {
  var isLoading = false;

  progressDialog(BuildContext context, var message) {
    isLoading = true;
    showDialog(
        context: context,
        //barrierDismissible: false,
        builder: (context) {
          return new AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(5.0))),
              content: new WillPopScope(
                  onWillPop: () async {
                    return false;
                  },
                  child: new Container(
                    color: Colors.white,
                    child: new Row(
                      mainAxisSize: MainAxisSize.max,
                      children: <Widget>[
                        // new SizedBox(height: 10,
                        new CircularProgressIndicator(),
                        //),

                        new Padding(
                          padding: const EdgeInsets.only(left: 20.0),
                          child: new Text(
                            message,
                            style: TextStyle(
                                fontSize: 14, color: Colors.grey[700]),
                          ),
                        )
                      ],
                    ),
                  )));
        });
  }

  hideProgressDialog(BuildContext context) {
    if (isLoading) {
      Navigator.pop(context);
      isLoading = false;
    }
  }
}
