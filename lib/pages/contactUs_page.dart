import 'package:bikaji/repo/Repository.dart';
import 'package:bikaji/repo/api_provider.dart';
import 'package:bikaji/util/app_helper.dart';
import 'package:bikaji/util/custom_icons.dart';
import 'package:bikaji/util/custom_regex.dart';
import 'package:bikaji/util/textStyle.dart';
import 'package:bikaji/util/url_list.dart';
import 'package:bikaji/util/utility.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactUsPage extends StatefulWidget {
  @override
  _ContactUsPageState createState() => _ContactUsPageState();
}

class _ContactUsPageState extends State<ContactUsPage> with AppHelper{
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(45),
        child: AppBar(
          backgroundColor: red,
          elevation: 0,
          title: Text(
            'Contact us',
            style: toolbarStyle,
          ),
          leading: IconButton(
            icon: Icon(Icons.chevron_left),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
      ),
      body: Container(
          color: Colors.grey.shade100,
          child: ListView(
            children: <Widget>[
              Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  _getHeading('Bikaji Foods International Ltd.'),
                  SizedBox(
                    height: 1.5,
                  ),
                  _getContactDetails,
                  _getRegionalOffice,
                  SizedBox(
                    height: 8,
                  ),
                  _getHeading('Online Order Support'),
                  SizedBox(
                    height: 1.5,
                  ),
                  _getOnlineDetails,
                  SizedBox(
                    height: 8,
                  ),
                  _getHeading('Connect to us'),
                  SizedBox(
                    height: 1.5,
                  ),
                  _socialMediaView(),
                  SizedBox(
                    height: 24,
                  ),
                  MaterialButton(
                    onPressed: () {
                      _showContactUsSheet();
                    },
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5)),
                    color: red,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 25, vertical: 12),
                    textColor: white,
                    child: Text('Write us'),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                ],
              ),
            ],
          )),
    );
  }

  _showContactUsSheet() {
    showModalBottomSheet(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(25.0))),
        isScrollControlled: true,
        isDismissible: false,
        context: context,
        builder: (context) => ContactUsForm(onSubmitCliked: (name,email,number,desc){
          //myPrint("$name and $number");
          _sendQuery(name,email,number,desc);
        },));
  }
    void _sendQuery(name,email,number,desc) async {
    progressDialog(context, "Please wait...");
    try {
      final response = await ApiProvider()
          .sendQuery(name, email, number, desc);
      hideProgressDialog(context);
      if (response.status == UrlConstants.SUCCESS) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Message send successfully"),behavior: SnackBarBehavior.floating,));
      }else{
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Something went wrong,Please try again"),behavior: SnackBarBehavior.floating,));
      }
    } catch (e) {
      hideProgressDialog(context);
      myPrint(e.toString());
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Something went wrong,Please try again"),behavior: SnackBarBehavior.floating,));
    }
  }

  _socialMediaView() {
    var size = 18.0;
    var color = Colors.grey[700];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      color: white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          IconButton(
            icon: Icon(
              MyFlutterApp.youtube_play,
              size: size,
              color: color,
            ),
            onPressed: () {
              _launchURL(
                  'https://www.youtube.com/channel/UCfib-HxpT6c4pfziUopjWnA');
            },
          ),
          IconButton(
            icon: Icon(
              MyFlutterApp.twitter,
              size: size,
              color: color,
            ),
            onPressed: () {
              _launchURL('https://twitter.com/bikajifoodsbkn');
            },
          ),
          IconButton(
            icon: Icon(
              MyFlutterApp.facebook,
              size: size,
              color: color,
            ),
            onPressed: () {
              _launchURL('https://www.facebook.com/bikaji');
            },
          ),
          IconButton(
            icon: Icon(
              MyFlutterApp.instagram,
              size: size,
              color: color,
            ),
            onPressed: () {
              _launchURL('https://www.instagram.com/bikajifoods/');
            },
          ),
        ],
      ),
    );
  }

  _launchURL(url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  get _getOnlineDetails {
    return Container(
      color: white,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(
                Icons.mail_outline,
                size: 14,
                color: Colors.grey.shade700,
              ),
              SizedBox(
                width: 10,
              ),
              Expanded(
                child: InkWell(
                  onTap: () {
                    showModalBottomSheet(
                        context: context,
                        builder: (BuildContext context) {
                          return _bottomCallSheet(
                              'Are you sure, you want to mail to sales.bikaji@bikajionline.com ?',
                              'mailto:sales.bikaji@bikajionline.com?subject=Bikaji contact&body=New%20Text',
                              'MAIL');
                        });
                  },
                  child: Text('online@bikaji.com',
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 13,
                      )),
                ),
              ),
              // InkWell(
              //   onTap: () {},
              //   child: Container(
              //       padding: EdgeInsets.all(2),
              //       child: Icon(Icons.content_copy, color: red, size: 16)),
              // ),
            ],
          ),
          SizedBox(
            height: 12,
          ),
          Row(
            children: <Widget>[
              Icon(
                Icons.phone,
                size: 14,
                color: Colors.grey.shade700,
              ),
              SizedBox(
                width: 10,
              ),
              Expanded(
                child: InkWell(
                  onTap: () {
                    showModalBottomSheet(
                        context: context,
                        builder: (BuildContext context) {
                          return _bottomCallSheet(
                              'Are you sure, you want to call to 1800 102 9046 ?',
                              'tel:1800 102 9046',
                              'CALL');
                        });
                  },
                  child: Text('1800 102 9046',
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 13,
                      )),
                ),
              ),
              // InkWell(
              //   onTap: () {},
              //   child: Container(
              //       padding: EdgeInsets.all(2),
              //       child: Icon(Icons.content_copy, color: red, size: 16)),
              // ),
            ],
          ),
          SizedBox(
            height: 8,
          ),
          Text('(11:00 AM - 5:00 PM, Mon-Sat Only)', style: smallTextStyle),
        ],
      ),
    );
  }

  Widget _getHeading(data) {
    return Container(
      color: white,
      child: Row(
        children: <Widget>[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            child: Text(
              data,
              style: TextStyle(
                  color: red, fontSize: 13, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  get _getContactDetails {
    return Container(
      color: white,
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Head Office:',
            style: TextStyle(
                color: Colors.grey.shade700,
                fontSize: 14,
                fontWeight: FontWeight.w600),
          ),
          SizedBox(
            height: 10,
          ),
          Text(
            'F-196/197, Bichhwal Industrial Area, Bikaner - 334 006, Rajasthan, India',
            style: TextStyle(
                color: Colors.grey.shade700, fontSize: 13, height: 1.5),
          ),
          SizedBox(
            height: 10,
          ),
          Row(
            children: <Widget>[
              Icon(
                Icons.phone,
                size: 14,
                color: Colors.grey.shade700,
              ),
              SizedBox(
                width: 10,
              ),
              Expanded(
                child: InkWell(
                  onTap: () {
                    showModalBottomSheet(
                        context: context,
                        builder: (BuildContext context) {
                          return _bottomCallSheet(
                              'Are you sure, you want to call to +91 151229914 ?',
                              'tel:+91 151229914',
                              'CALL');
                        });
                  },
                  child: Text('+91-151-2259914 / 0588',
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 13,
                      )),
                ),
              ),
              // InkWell(
              //   onTap: () {},
              //   child: Container(
              //       padding: EdgeInsets.all(2),
              //       child: Icon(Icons.content_copy, color: red, size: 16)),
              // ),
            ],
          ),
                    SizedBox(
            height: 10,
          ),
          Row(
            children: <Widget>[
              Icon(
                Icons.phone,
                size: 14,
                color: Colors.grey.shade700,
              ),
              SizedBox(
                width: 10,
              ),
              Expanded(
                child: InkWell(
                  onTap: () {
                    showModalBottomSheet(
                        context: context,
                        builder: (BuildContext context) {
                          return _bottomCallSheet(
                              'Are you sure, you want to call to +91 1512251814 ?',
                              'tel:+91 1512251814',
                              'CALL');
                        });
                  },
                  child: Text('+91-151-2251814 / 1964',
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 13,
                      )),
                ),
              ),
              // InkWell(
              //   onTap: () {},
              //   child: Container(
              //       padding: EdgeInsets.all(2),
              //       child: Icon(Icons.content_copy, color: red, size: 16)),
              // ),
            ],
          ),
          // SizedBox(height: 5,),
          // Row(
          //   children: <Widget>[
          //     Icon(Icons.phone,size: 14,color: Colors.grey.shade700,),
          //     SizedBox(width: 10,),
          //     Expanded(
          //       child: Text('+91 151229914 / 1964',style:TextStyle( color: Colors.grey.shade700,
          //   fontSize: 13,)),
          //     )
          //   ],
          // )
        ],
      ),
    );
  }

  get _getRegionalOffice {
    return Container(
      color: white,
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Regional Office:',
            style: TextStyle(
                color: Colors.grey.shade700,
                fontSize: 14,
                fontWeight: FontWeight.w600),
          ),
          SizedBox(
            height: 10,
          ),
          Text(
            'Plot No. 39/40/41, Aroon Industrial Estate, Ramchandra Lane, Malad (West) Mumbai -400 064.India.',
            style: TextStyle(
                color: Colors.grey.shade700, fontSize: 13, height: 1.5),
          ),
          SizedBox(
            height: 10,
          ),
          Row(
            children: <Widget>[
              Icon(
                Icons.phone,
                size: 14,
                color: Colors.grey.shade700,
              ),
              SizedBox(
                width: 10,
              ),
              Expanded(
                child: InkWell(
                  onTap: () {
                    // _launchURL('tel:2228836701');
                    showModalBottomSheet(
                        context: context,
                        builder: (BuildContext context) {
                          return _bottomCallSheet(
                              'Are you sure, you want to call to +91 2228836701 ?',
                              'tel:+91 2228836701',
                              'CALL');
                        });
                  },
                  child: Text('+91 2228836701',
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 13,
                      )),
                ),
              ),
              // InkWell(
              //   onTap: () {},
              //   child: Container(
              //       padding: EdgeInsets.all(2),
              //       child: Icon(Icons.content_copy, color: red, size: 16)),
              // ),
            ],
          ),
        ],
      ),
    );
  }

  _bottomCallSheet(var title, var text, buttonText) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
            child: Column(
              children: <Widget>[
                Text(
                  title,
                  textAlign: TextAlign.start,
                  style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                      height: 1.5),
                ),
              ],
            ),
          ),
          Container(
            height: 0.5,
            color: Colors.grey.shade400,
          ),
          Container(
            child: Row(
              children: <Widget>[
                Expanded(
                  child: InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                          border: Border(
                              right: BorderSide(
                                  color: Colors.grey.shade300, width: 0.6))),
                      child: Text(
                        'CANCEL',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: red,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: InkWell(
                    onTap: () {
                      Navigator.pop(context);
                      _launchURL(text);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                          border: Border(
                              left: BorderSide(
                                  color: Colors.grey.shade300, width: 0.6))),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      child: Text(
                        buttonText,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: red,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}

class ContactUsForm extends StatefulWidget {
  const ContactUsForm({
    Key key,
    this.onSubmitCliked,
  }) : super(key: key);
  final Function onSubmitCliked;

  @override
  _ContactUsFormState createState() => _ContactUsFormState();
}

class _ContactUsFormState extends State<ContactUsForm> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _numberController = TextEditingController();
  final _descController = TextEditingController();
  bool _isNameError = false;
  bool _isEmailError = false;
  bool _isNumberError = false;
  bool _isDescError = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: MediaQuery.of(context).viewInsets,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
        child: ListView(
          shrinkWrap: true,
          children: <Widget>[
            Container(
              child: Row(
                children: <Widget>[
                  Expanded(
                      child: Text(
                    'Send us a note and we’ll get back to you as quickly as possible.',
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                  )),
                  IconButton(
                      icon: Icon(
                        Icons.close,
                        color: Colors.grey.shade600,
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      })
                ],
              ),
            ),
            SizedBox(height: 20),
            _formData('Name', TextInputType.text, MyFlutterApp.ic_profile,
                _nameController, _isNameError, "Please enter valid first name"),
            SizedBox(height: 12),
            _formData('Email', TextInputType.emailAddress, MyFlutterApp.ic_mail,
                _emailController, _isEmailError, "Please enter valid Email Id"),
            SizedBox(height: 12),
            _formData(
                'Mobile Number',
                TextInputType.number,
                MyFlutterApp.ic_profile,
                _numberController,
                _isNumberError,
                "Please enter valid Mobile Number"),
            SizedBox(height: 12),
            TextField(
              controller: _descController,
              keyboardType: TextInputType.multiline,
              maxLines: 3,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
              decoration: InputDecoration(
                  labelText: "What's on your mind?",
                  errorText: _isDescError ? "Please enter something" : null,
                  errorStyle: TextStyle(fontSize: 11, color: red),
                  border: UnderlineInputBorder(
                      borderSide: BorderSide(color: textGrey, width: 0.5)),
                  enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: textGrey, width: 0.5)),
                  focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: red, width: 0.5)),
                  contentPadding: const EdgeInsets.only(top: 1.0, bottom: 5.0),
                  icon: Container(
                      child: Text(
                    "abc",
                    style: TextStyle(
                        color: Colors.grey.shade500,
                        fontWeight: FontWeight.bold),
                  ))),
            ),
            SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                MaterialButton(
                  onPressed: () {
                    bool isValid = _validateForm();
                    if (isValid) {
                      Navigator.pop(context);
                      final name = _nameController.text;
                      final email = _emailController.text;
                      final number = _numberController.text;
                      final desc = _descController.text;
                      widget.onSubmitCliked(name,email,number,desc);
                      //_sendQuery();
                      // send details to server
                    }
                  },
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24)),
                  color: red,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                  textColor: white,
                  child: Text('SUBMIT'),
                ),
              ],
            ),
            SizedBox(height: 8),
            //),
          ],
        ),
      ),
    );
  }

  _validateForm() {
    setState(() {
      _isNameError = _nameController.text.isEmpty;
      _isEmailError =
          !RegExp(CustomRegex.email_regex).hasMatch(_emailController.text);
      _isNumberError =
          !RegExp(CustomRegex.mobile_regex).hasMatch(_numberController.text);
      _isDescError = _descController.text.isEmpty;
    });

    if (!_isNameError && !_isEmailError && !_isNumberError && !_isDescError) {
      return true;
    } else {
      return false;
    }
  }

  Widget _formData(
      var text, var type, var icons, var controller, var error, var errorText) {
    var style = TextStyle(fontSize: 13, color: Colors.grey.shade700);
    var errorStyle = TextStyle(fontSize: 11, color: red);

    var textFeild = TextField(
        controller: controller,
        keyboardType: type,
        textAlign: TextAlign.start,
        style: style,
        decoration: InputDecoration(
          //hintText: text,
          errorText: error ? errorText : null,
          errorStyle: errorStyle,
          border: UnderlineInputBorder(
              borderSide: BorderSide(color: textGrey, width: 0.5)),
          enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: textGrey, width: 0.5)),
          focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: red, width: 0.5)),
          labelText: text,
          contentPadding: const EdgeInsets.only(top: 1.0, bottom: 5.0),
        ));
    return Container(
      child: Row(
        children: <Widget>[
          (text != 'Mobile Number')
              ? Icon(
                  icons,
                  color: Colors.grey.shade500,
                  size: (text == "Name") ? 18 : 20,
                )
              : Text(
                  '+91',
                  style: TextStyle(
                      color: Colors.grey.shade500, fontWeight: FontWeight.bold),
                ),
          SizedBox(
            width: (text == "Name") ? 17 : 15,
          ),
          Expanded(child: textFeild)
        ],
      ),
    );
  }


}
