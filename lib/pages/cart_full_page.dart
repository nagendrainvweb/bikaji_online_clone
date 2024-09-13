import 'package:bikaji/pages/cart_page.dart';
import 'package:bikaji/util/textStyle.dart';
import 'package:bikaji/util/utility.dart';
import 'package:flutter/material.dart';

class CartMainPage extends StatefulWidget {
  @override
  _CartMainPageState createState() => _CartMainPageState();
}

class _CartMainPageState extends State<CartMainPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(45),
        child: AppBar(
          //centerTitle: true,
          title: Text('My Bag',style: toolbarStyle,),
          backgroundColor: red,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.chevron_left),
            onPressed: (){
              Navigator.pop(context);
            },
          ),
        ),
        
      ),
      body: CartPage(onRefresh: (){
        
      },),
    );
  }
}