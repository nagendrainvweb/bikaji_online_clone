import 'package:bikaji/util/dialog_helper.dart';
import 'package:bikaji/util/textStyle.dart';
import 'package:bikaji/util/utility.dart';
import 'package:flutter/material.dart';

class BikajiWallet extends StatefulWidget {
  @override
  _BikajiWalletState createState() => _BikajiWalletState();
}

class _BikajiWalletState extends State<BikajiWallet> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _checkConnection();
  }
   _checkConnection() async{
    bool isInternet = await Utility.getConenctionStatus();
    if(!isInternet){
      DialogHelper().showNoInternetDialog(context);
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(45),
        child: AppBar(
          backgroundColor: red,
          title: Text('Bikaji Wallet',style: toolbarStyle,),
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.chevron_left),
            onPressed: (){
              Navigator.pop(context);
            },
          ),
        ),
      ),
      body: Container(
        color: Colors.grey.shade100,
        child: Container(
           margin: const EdgeInsets.symmetric(horizontal: 10,vertical: 10),
          child: Column(
            children: <Widget>[
              Card(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 30),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Text('BIKAJI MONEY',style: TextStyle(color: Colors.grey.shade700,fontSize: 14),),
                      SizedBox(height: 10,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Image.asset('assets/coins.png',width: 20,),
                          SizedBox(width: 15,),
                          Text('$rupee 970.56',style:TextStyle(color: Colors.green.shade700,fontSize: 32,fontWeight: FontWeight.w600)) 
                        ],
                      )
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Card(
                  child: ListView(
                    children: List.generate(5, (index){
                      return rowOrderItem(index);
                    }),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
  rowOrderItem(int index){
    return 
     Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[

         (index==0)? Container(
            padding: const EdgeInsets.symmetric(vertical: 12,horizontal: 15),
            child: Text('ACTIVITY',style:TextStyle(color:Colors.grey.shade600,fontSize:11),textAlign: TextAlign.start,),
          ):Container(),
          (index==0)? Container(height: 1,color: Colors.grey.shade200,):Container(),
          Container(
              padding: const EdgeInsets.symmetric(vertical: 15,horizontal: 20),
            child: Row(
              children: <Widget>[
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Text('•',style: TextStyle(color:red,fontSize: 20,fontWeight: FontWeight.bold),),
                  ],
                ),
                SizedBox(width: 13,),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                         RichText(
                  text: TextSpan(
                      text: 'Order Id : ',
                      style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade500,
                          fontWeight: FontWeight.w600),
                      children: <TextSpan>[
                        TextSpan(
                            text: '#12345678',
                           
                            style: TextStyle(  fontSize: 13,color: Colors.grey.shade600))
                      ]),
                ),
                      SizedBox(height: 5,),
                      Text('24 MAY',style: TextStyle(fontSize: 10,color: Colors.grey[600]),),
                    ],
                  ),
                ),
                SizedBox(width: 10,),
                 Text('-   $rupee 97.56',style: TextStyle(color:red,fontWeight: FontWeight.w500),),
              ],
            ),
          ),
          Container(height: 1,color: Colors.grey.shade200,)
        ],
      ),
    );
  }
}