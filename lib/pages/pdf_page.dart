import 'package:bikaji/util/textStyle.dart';
import 'package:bikaji/util/utility.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class PDFViewPage extends StatefulWidget {
  final title;
  final url;
  PDFViewPage(this.title,this.url);
  @override
  _PDFViewPageState createState() => _PDFViewPageState();
}

class _PDFViewPageState extends State<PDFViewPage> {

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
   return Scaffold(
        appBar: _getAppBar,
        body: Container(
          child: Stack(
            children: <Widget>[
              Container(
                child:(isLoading)?_getLoadingView:Container(
                  child: SfPdfViewer.network(widget.url),
                ),
              )
            ],
          ),
        ));
  }

    get _getLoadingView {
    return  Container(
        child: Center(
          child: CircularProgressIndicator(),
        ),
    
    );
  }

  get _getAppBar {
    return PreferredSize(
      preferredSize: Size.fromHeight(45),
      child: AppBar(
        elevation: 0,
        backgroundColor: red,
        title: Text(widget.title, style: toolbarStyle),
        leading: IconButton(
          icon: Icon(Icons.chevron_left),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
    );
  }
}