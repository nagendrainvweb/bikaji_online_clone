import 'package:bikaji/repo/Repository.dart';
import 'package:bikaji/repo/api_provider.dart';
import 'package:bikaji/util/app_helper.dart';
import 'package:bikaji/util/custom_icons.dart';
import 'package:bikaji/util/custom_regex.dart';
import 'package:bikaji/util/textStyle.dart';
import 'package:bikaji/util/url_list.dart';
import 'package:bikaji/util/utility.dart';
import 'package:flutter/material.dart';

class BulkOrderPage extends StatefulWidget {
  @override
  _BulkOrderPageState createState() => _BulkOrderPageState();
}

class _BulkOrderPageState extends State<BulkOrderPage> with AppHelper{

  final _scaffoldKey = GlobalKey<ScaffoldState>();
  // create textfeild controllers
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _mobileController = TextEditingController();
  final _companyController = TextEditingController();
  final _cityController = TextEditingController();

  // textfeild error variable
  bool _isNameError = false;
  bool _isEmailError = false;
  bool _isMobileError = false;
  bool _isCompanyError = false;
  bool _isCityError = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(45),
        child: AppBar(
          title: Text('Corporate Order',style: toolbarStyle,),
           backgroundColor: Colors.red.shade500,
           elevation: 0,
           leading: IconButton(
             icon: Icon(Icons.chevron_left),
             onPressed: (){
               Navigator.pop(context);
             },
           ),
        ),
      ),
      body: ListView(
        children: <Widget>[
          _getTopBanner,
          _getFormFeild,
        ],
      ),
    );
  }

  get _getFormFeild {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      child: ListView(
        shrinkWrap: true,
        physics: ClampingScrollPhysics(),
        children: <Widget>[
          _textFeild('Name', MyFlutterApp.ic_profile,TextInputType.text,_nameController,_isNameError,"Please enter name"),
          _textFeild('Email Id', MyFlutterApp.ic_mail,TextInputType.emailAddress,_emailController,_isEmailError,"Please enter valid Email"),
          _textFeild('Mobile Number', Icons.smartphone,TextInputType.number,_mobileController,_isMobileError,"Please enter valid Number"),
          _textFeild('Company', MyFlutterApp.ic_city,TextInputType.text,_companyController,_isCompanyError,"Please enter company name"),
          _textFeild('City', MyFlutterApp.ic_city,TextInputType.text,_cityController,_isCityError,"Please enter city name"),
         // SizedBox(height: 20,)
          _getSubmitBtn,
        ],
      ),
    );
  }

  get _getSubmitBtn{
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 30),
      child: InkWell(
        onTap: (){
         final isOk =  _validate();
         myPrint("isOk is $isOk");
         if(isOk){
           _sendEnquiry();
         }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 15),
          decoration: BoxDecoration(
            color: Colors.green,
            borderRadius: BorderRadius.circular(5)
          ),
          child: Text('SUBMIT',textAlign: TextAlign.center,style: TextStyle(fontSize: 14,color: Colors.white,fontWeight: FontWeight.w500)),
        ),
      ),
    ) ;
  }

  _sendEnquiry()async{
    progressDialog(context, "Please wait...");
    try{
      final name = _nameController.text;
      final email= _emailController.text;
      final company = _companyController.text;
      final mobileNo = _mobileController.text;
      final city = _cityController.text;
      final response = await ApiProvider().sendCorporateInquiry(name, email, mobileNo, company, city);
      hideProgressDialog(context);
      Utility.showCustomSnackBar(response.message, _scaffoldKey);
      //if(response.status == UrlConstants.SUCCESS)
    }catch(e){
      hideProgressDialog(context);
      myPrint(e.toString());
      Utility.showCustomSnackBar(SOMETHING_WRONG_TEXT, _scaffoldKey);
    }
  }
  bool _validate(){
    _isNameError = _nameController.text.isEmpty;
     _isEmailError = !RegExp(CustomRegex.email_regex).hasMatch(_emailController.text);
     _isMobileError = !RegExp(CustomRegex.mobile_regex).hasMatch(_mobileController.text);
     _isCompanyError =  _companyController.text.isEmpty;
     _isCityError = _cityController.text.isEmpty;
    setState(() {
   
 });
    // myPrint('$_isNameError & $_isEmailError & $_isMobileError & $_isCompanyError & $_isCityError');

     if(_isNameError & _isEmailError & _isMobileError & _isCompanyError & _isCityError){
       return false;
     }else{
       return true;
     }
   
  }

  Widget _textFeild(var title, var icon,var inputType,var controller,var error,var errorMsg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: Column(
        children: <Widget>[
          (title == "Name")
              ?SizedBox(
                  height: 10,
                )
              : SizedBox(
                  height: 25,
                ),
          Row(
            children: <Widget>[
             (title == "Mobile Number")?
             Container(
              child: Text('+91',style: TextStyle(color: textGrey,fontWeight: FontWeight.w700),), 
             )
             : Icon(
                icon,
                size: 18,
                color: textGrey,
              ),
              SizedBox(
                width: 20,
              ),
              Expanded(
                child: TextField(
                  controller: controller,
                  keyboardType: inputType,
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                  decoration: InputDecoration(
                    errorText: (error)?errorMsg:null,
                    errorStyle: TextStyle(color: red,fontSize: 10),
                    labelText: title,
                      border: UnderlineInputBorder(
                      borderSide: BorderSide(color: textGrey, width: 0.5)),
                  enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: textGrey, width: 0.5)),
                  focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: red, width: 0.5)),
                      focusedErrorBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: red, width: 0.7)),
                  contentPadding:
                      EdgeInsets.only(top: 10, bottom: 2, left: 0, right: 0),
                    labelStyle: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                  
                  ),
                  onChanged: (value){
                    if(title == "Email Id"){
                      bool isValid = RegExp(CustomRegex.email_regex).hasMatch(value);
                      setState(() {
                       _isEmailError = !isValid; 
                      });
                    }else if(title == "Mobile Number"){
                       bool isValid = RegExp(CustomRegex.mobile_regex).hasMatch(value);
                      setState(() {
                       _isMobileError = !isValid; 
                      });
                    }
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  get _getTopBanner {
    return Container(
      height: 180,
      width: double.infinity,
      child: 
      //Container()
      // Image.asset(
      //   'assets/corporate_order_new.jpg',
      //   fit: BoxFit.cover,
      // ),
      Image.network(
        'https://bikaji.com//pub/media/corporate-order-new1-1280.jpg',
        fit: BoxFit.cover,
      ),
    );
  }
}
