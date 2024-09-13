import 'package:bikaji/customWidget/termsCondition.dart';
import 'package:bikaji/model/category_content.dart';
import 'package:bikaji/pages/pdf_page.dart';
import 'package:bikaji/pages/webview_page.dart';
import 'package:bikaji/util/custom_icons.dart';
import 'package:bikaji/util/textStyle.dart';
import 'package:bikaji/util/utility.dart';
import 'package:flutter/material.dart';

class PolicyListPage extends StatefulWidget {
  var title;

  PolicyListPage(this.title) ;
  @override
  _PolicyListPageState createState() => _PolicyListPageState();
}

class _PolicyListPageState extends State<PolicyListPage> {

  final _key  = GlobalKey<ScaffoldState>();
 


  @override
  void initState() {
    super.initState();
  }

  
@override
  void dispose() {
    
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {

    var list = getList();

    return Scaffold(
      key: _key,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(45),
        child: AppBar(
          title: Text(widget.title,style:toolbarStyle),
          elevation: 0,
          backgroundColor: red,
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
        child: list,
      ),
    );
  }

  Widget getList(){

    var list;
    myPrint(widget.title);
    if(widget.title == 'Policies'){
      list = _getPoliciesList();
    }else{
      list = _getCorporatePolicies();
    }
    return list;
  }

  Widget _getCorporatePolicies(){
    var docUrl = 'http://drive.google.com/viewerng/viewer?embedded=true&url=';
    return Column(
          children: <Widget>[
            SizedBox(height: 5,),
            _buildOfferRow(MyFlutterApp.ic_terms, 'Anti Sexual Harassment Policy', (){
                //_showBottomList('https://drive.google.com/open?id=1y3XLAVrhEQGQLyzULNYyxv4IFpx07c0Z');
                 Utility.pushToNext(PDFViewPage('Anti Sexual Harassment Policy','https://www.bikaji.com/pub/media/Anti%20Sexual%20Harassment%20Policy.pdf'), context);
            }),
            SizedBox(height: 5,),
             _buildOfferRow(MyFlutterApp.ic_terms, 'Code Of Conduct For Board & SMP', (){
               //_showBottomList('https://drive.google.com/open?id=10dMofRfSJhIXR7QL4WjQeLXCOFIQZatU');
               Utility.pushToNext(PDFViewPage('Code Of Conduct For Board & SMP','https://www.bikaji.com/pub/media/Code%20of%20Conduct%20for%20Board%20&%20SMP.pdf'), context);
            }),
            SizedBox(height: 5,),
             _buildOfferRow(MyFlutterApp.ic_terms, 'CSR Policy', (){
               //_showBottomList('https://drive.google.com/open?id=10dMofRfSJhIXR7QL4WjQeLXCOFIQZatU');
               Utility.pushToNext(PDFViewPage('CSR Policy','https://www.bikaji.com/pub/media/CSR%20POLICY.pdf'), context);
            }),
            SizedBox(height: 5,),
             _buildOfferRow(MyFlutterApp.ic_terms, 'Dividend Distribution Policy', (){
              // _showBottomList('https://drive.google.com/open?id=1YSKayRzE1GsX6D8CjJTbl32s9p38sDPo');
              Utility.pushToNext(PDFViewPage('Dividend Distribution Policy','http://bikaji.com/pub/media/dividend%20distribution%20policy.pdf'), context);
            }),
            SizedBox(height: 5,),
             _buildOfferRow(MyFlutterApp.ic_terms, 'Whistle Blower Policy', (){
               //_showBottomList('https://drive.google.com/open?id=1PNmrFzj01JF8GrZCrlWlORA3Y5Y7cYHl');
               Utility.pushToNext(PDFViewPage('Whistle Blower Policy','http://bikaji.com/pub/media/Whistle%20Blower%20Policy.pdf'), context);
            }),
            SizedBox(height: 5,)
          ],
        );    
  }

  Widget _getPoliciesList(){
    return Container(
      child: Column(
          children: <Widget>[
            SizedBox(height: 5,),
             _buildOfferRow(MyFlutterApp.ic_terms, 'Cancellation/Refund', (){
              // Utility.pushToNext(BrowserPage("Cancellation/Refund",), context);
                _key.currentState.showBottomSheet((context){
                 return TermsCondition(PolicyTag.CANCELLED_REFUND);
               });
            }),
            // SizedBox(height: 5,),
            // _buildOfferRow(MyFlutterApp.ic_terms, 'Certification & Accolades', (){
               
            // }),
            SizedBox(height: 5,),
             _buildOfferRow(MyFlutterApp.ic_terms, 'Terms & Conditions', (){
               _key.currentState.showBottomSheet((context){
                 return TermsCondition(PolicyTag.TERMS);
               });
            }),
            SizedBox(height: 5,),
             _buildOfferRow(MyFlutterApp.ic_terms, 'Privacy', (){
               _key.currentState.showBottomSheet((context){
                 return TermsCondition(PolicyTag.PRIVACY);
               });
            }),
            SizedBox(height: 5,),
             _buildOfferRow(MyFlutterApp.ic_terms, 'Shipping Policy', (){
               _key.currentState.showBottomSheet((context){
                 return TermsCondition(PolicyTag.SHIPPING);
               });
            }),
            SizedBox(height: 5,)
          ],
        )
    );
  }

   Widget _buildOfferRow(var icon,var title,Function onClick) {
    return InkWell(
      onTap: onClick,
      child: new Container(
      color: Colors.white,
        padding: EdgeInsets.symmetric(horizontal: 20,vertical: 12),
          child: new Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          SizedBox(width: 5,),
          Icon(icon,color: Colors.grey.shade600,size: 20,),
          SizedBox(width: 20,),
          Expanded(
            flex: 1,
            child: Text(title,style: TextStyle(color: Colors.grey.shade600,fontWeight: FontWeight.w600,fontSize: 14),),
          ),
          Icon(Icons.chevron_right,color: Colors.grey,)
        ],
      )),
    );
  }
}

