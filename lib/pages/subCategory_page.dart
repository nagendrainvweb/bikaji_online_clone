import 'package:bikaji/pages/category_page.dart';
import 'package:bikaji/util/textStyle.dart';
import 'package:bikaji/util/utility.dart';
import 'package:flutter/material.dart';

class SubCategoryPage extends StatefulWidget {
  final categoryId;
  final title;
  SubCategoryPage({@required this.categoryId,@required this.title});
  @override
  _SubCategoryPageState createState() => _SubCategoryPageState();
}

class _SubCategoryPageState extends State<SubCategoryPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(45),
        child: AppBar(
         title: Text(widget.title,style: toolbarStyle,), 
         backgroundColor: red,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.chevron_left),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
      ),
      body: Container(
       child: CategoryPage(categoryId: widget.categoryId), 
      ),
    );
  }
}