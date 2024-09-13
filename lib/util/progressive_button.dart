import 'package:flutter/material.dart';

import 'package:flutter/material.dart';

class ProgresseButton extends StatefulWidget {
  @override
  _ProgresseButtonState createState() => _ProgresseButtonState();
}

class _ProgresseButtonState extends State<ProgresseButton> with TickerProviderStateMixin{

  int state = 0;
  bool _isPressed= false;
  Animation _animation;
  double width  = double.infinity;
  GlobalKey globalKey = GlobalKey();
  @override
  Widget build(BuildContext context) {
    return PhysicalModel(
      color: Colors.blue,
      elevation: _isPressed?6.0:4.0,
        borderRadius: BorderRadius.circular(25),
        child: Container(
          key: globalKey,
          height: 48,
          width: width,
          padding: const EdgeInsets.symmetric(horizontal: 30,vertical: 15),
          child: MaterialButton(
            color: Colors.blue,
            child: Text('Login',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16,color: Colors.white,)),
            onPressed: (){},
            onHighlightChanged: (isPressed){
              setState(() {
                _isPressed = isPressed;
                if(state == 0){
                  _animateButton();
                }
              });
            },
          ),
        ),
    );
      
  }
  void _animateButton(){

    double initalWidth =  globalKey.currentContext.size.width;
    print(initalWidth);
    var controller =   AnimationController(duration: Duration(milliseconds: 300),vsync: this);
    _animation  = Tween(begin: 0.0,end:1.0).animate(controller);
    _animation.addListener((){
      setState(() {
          width =  initalWidth - ((initalWidth - 48.0) * _animation.value);
          print(width);
      });
      controller.forward();
    });
  }
}