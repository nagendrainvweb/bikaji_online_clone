import 'package:flutter/material.dart';

class OtpVerification extends StatefulWidget {
  @override
  _OtpVerificationState createState() => _OtpVerificationState();
}

class _OtpVerificationState extends State<OtpVerification> {

  final firstController  = TextEditingController();
  final secondController  = TextEditingController();
  final thirdController  = TextEditingController();
  final fourthController  = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.red,
        child: SafeArea(
          child: Container(
            color: Colors.grey.shade200,
            child: Column(
              children: <Widget>[
                _topBackBtn(),
                Expanded(
                  child: _middleView(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  _topBackBtn(){
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          IconButton(
            icon: Icon(Icons.arrow_back_ios,size: 18,),
            onPressed: (){

            },
          )
        ],
      ),
    );
  }
  _middleView(){
    return Container(
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text('VERIFICATION CODE',
            style:TextStyle(
              color: Colors.grey.shade700,
              fontSize: 18,
              fontWeight: FontWeight.w500
            )),
            SizedBox(height: 10,),
             Text('Please type the verification code sent to\n+91 778541234',
             textAlign: TextAlign.center,
            style:TextStyle(
              color: Colors.grey.shade500,
              height:2,
              fontSize: 14,
              //fontWeight: FontWeight.w500
            )),
            SizedBox(height: 40,),
            // PinEntryTextField(
            //   onSubmit: (String pin){
                
            //   },
            // )
          ],
        ),
      ),
    );
  }
  _otpfillView(){
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 50),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          _textFeildView(firstController),
          _textFeildView(firstController),
          _textFeildView(firstController),
          _textFeildView(firstController),
        ],
      ),
    );
  }
  _textFeildView(var controller){
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: Colors.grey.shade300
      ),
      child: Center(
        child: TextField(
          controller: controller,
         // maxLength: 1,
          //textAlign: TextAlign.center,
          decoration: InputDecoration(
            border: OutlineInputBorder(

            )
          ),
        ),
      ),
    );
  }
}