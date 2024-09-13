import 'package:bikaji/util/custom_icons.dart';
import 'package:flutter/material.dart';


List<BottomNavigationData> navigationList = [
  BottomNavigationData('Home',Icons.home),
  BottomNavigationData('Category',MyFlutterApp.ic_categories),
  BottomNavigationData('Profile',MyFlutterApp.ic_profile),
  BottomNavigationData('Cart',MyFlutterApp.ic_cart_1),
  BottomNavigationData('More',Icons.more_vert),
];
class BottomNavigationData{

  String title;
  IconData icon;


  BottomNavigationData(this.title,this.icon);

}