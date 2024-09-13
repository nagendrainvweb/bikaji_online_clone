import 'dart:convert';
import 'dart:io';

import 'package:bikaji/model/UserData.dart';
import 'package:bikaji/prefrence_util/Prefs.dart';
import 'package:bikaji/repo/Repository.dart';
import 'package:bikaji/repo/api_provider.dart';
import 'package:bikaji/util/app_helper.dart';
import 'package:bikaji/util/constants.dart';
import 'package:bikaji/util/custom_icons.dart';
import 'package:bikaji/util/custom_regex.dart';
import 'package:bikaji/util/dialog_helper.dart';
import 'package:bikaji/util/textStyle.dart';
import 'package:bikaji/util/url_list.dart';
import 'package:bikaji/util/utility.dart';
import 'package:flutter/material.dart';
//import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class MyAccountPage extends StatefulWidget {
  final showAppBar;
  final number;
  MyAccountPage({this.showAppBar, this.number});
  @override
  _MyAccountPageState createState() => _MyAccountPageState();
}

class _MyAccountPageState extends State<MyAccountPage> with AppHelper {
  String _date = "";
  TextEditingController _dateController = TextEditingController(text: "");
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  var _image;

  // textFeild controller
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _mobileController = TextEditingController();
  final _lastNameController = TextEditingController();

  // textfeild error
  bool _isNameError = false;
  bool _isEmailError = false;
  bool _ismobileError = false;
  bool _isDobError = false;
  bool _isLastNameError = false;

  String fullName = '';
  @override
  void initState() {
    super.initState();
    setData();
  }

  setData() async {
    if (widget.showAppBar) {
      final number = await Prefs.mobileNumber;
      final firstName = await Prefs.firstName;
      final lastName = await Prefs.lastName;
      final email = await Prefs.email;
      final dob = await Prefs.dob;
      final image = await Prefs.imageUrl;
      _image = image.isEmpty ? null : image;
      // _image  = base64Decode(image);
      _mobileController.text = number;
      _nameController.text = firstName;
      _lastNameController.text = lastName;
      _emailController.text = email;
      fullName = firstName.isEmpty?"Customer Name":firstName + " " + lastName;
      if (dob.isNotEmpty && dob != "1970-01-01") {
        DateFormat dateFormat = DateFormat("yyyy-MM-dd");
        DateTime dateTime = dateFormat.parse(dob);
        String formattedDate = DateFormat('dd-MM-yyyy').format(dateTime);
        _dateController.text = formattedDate;
      }
    } else {
      _mobileController.text = widget.number;
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        backgroundColor: grey,
        appBar: (widget.showAppBar)
            ? PreferredSize(
                preferredSize: Size.fromHeight(45),
                child: AppBar(
                  backgroundColor: Colors.red.shade500,
                  elevation: 0,
                  title: Text(
                    'Profile Details',
                    style: toolbarStyle,
                  ),
                  leading: IconButton(
                    icon: Icon(Icons.chevron_left),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ),
              )
            : null,
        body: Container(
            child: Stack(
          children: <Widget>[
            _getBackView,
            _getTopView,
            //_getTopDetailsText,
          ],
        )));
  }

  get _getTopDetailsText {
    return (!widget.showAppBar && MediaQuery.of(context).viewInsets.bottom == 0)
        ? Container(
            margin: const EdgeInsets.fromLTRB(20, 0, 20, 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  "Mobile number is not registered with Bikaji\nPlease Register Your details.",
                  textScaleFactor: 1.1,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey.shade600, height: 1.3),
                ),
              ],
            ),
          )
        : Container();
  }

  get _getTopView {
    final topvalue = (widget.showAppBar) ? 100 : 140;
    //  myPrint(_mainKey.currentContext.size.height);
    return Container(
      //  margin: const EdgeInsets.only(left: 15,right: 15,bottom: 10,top: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Expanded(
            child: ListView(
              shrinkWrap: true,
              children: <Widget>[
                Container(
                  height: 250,
                  child: Stack(
                    children: <Widget>[
                      //_getTopDetailsText,
                      Container(
                        margin: EdgeInsets.only(
                            left: 15,
                            right: 15,
                            bottom: 10,
                            top: topvalue.toDouble()),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.white),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          (!widget.showAppBar)
                              ? SizedBox(height: 15)
                              : Container(),
                          (!widget.showAppBar)
                              ? _getTopDetailsText
                              : Container(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              _topProfile(),
                            ],
                          ),
                          SizedBox(
                            height: 8,
                          ),
                          Text(
                            fullName,
                            style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 16,
                                fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  //flex: 1,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                    child: _formWidget(),
                  ),
                ),
                // SizedBox(
                //   height: 10,
                // ),
              ],
            ),
          ),
          InkWell(
            onTap: () async {
              _validate();
            },
            child: Container(
              width: double.infinity,
              //margin: EdgeInsets.only(left: 5, right: 5),
              decoration: BoxDecoration(
                color: blackGrey,
                // borderRadius: BorderRadius.circular(5)
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: new Text(
                  (widget.showAppBar) ? 'SAVE DETAILS' : "REGISTER NOW",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  _validate() {
    setState(() {
      // _isNameError =
      //     !(RegExp(CustomRegex.name_regex).hasMatch(_nameController.text.trim()));
      // _isLastNameError =
      //     !(RegExp(CustomRegex.name_regex).hasMatch(_lastNameController.text.trim()));
      _isEmailError =
          !(RegExp(CustomRegex.email_regex).hasMatch(_emailController.text.trim()));
      _ismobileError =
          !(RegExp(CustomRegex.mobile_regex).hasMatch(_mobileController.text.trim()));
      //_isDobError = _dateController.text.isEmpty;

      if (!_isNameError &&
          !_isLastNameError &&
          !_isEmailError &&
          !_ismobileError &&
          !_isDobError) {
        if (widget.showAppBar) {
          _updateUser();
        } else {
          _registerUser();
          //_updateUser();
        }
        myPrint('all ok');
      } else {
        myPrint('not OK');
      }
    });
  }

  _updateUser() async {
    progressDialog(context, 'Please wait...');
    final firstName = _nameController.text;
    final lastName = _lastNameController.text;
    final email = _emailController.text;
    final number = _mobileController.text;
    final dob = _dateController.text;
    final userid = await Prefs.id;
    var imageBase64 = '';

    try {
      myPrint("${_image.runtimeType}");
      if (_image != null && _image is File) {
        List<int> imageBytes = await testCompressFile(_image);
        imageBase64 = base64Encode(imageBytes);
      }
      final preFirstName = await Prefs.firstName;
      final preLastName = await Prefs.lastName;
      final preEmail = await Prefs.email;
      final preDob = await Prefs.dob;
      final preImage = await Prefs.imageUrl;
      DateFormat dateFormat = DateFormat("yyyy-MM-dd");
      DateTime dateTime;
      String formattedDate;
      myPrint('preDob is $preDob');
      if(preDob.isNotEmpty){
       dateTime  = dateFormat.parse(preDob);
       formattedDate = DateFormat('dd-MM-yyyy').format(dateTime);
      }
      

      myPrint("$firstName == $preFirstName");
      myPrint("$lastName == $preLastName");
      myPrint("$email == $preEmail");
      myPrint("$dob == $formattedDate");
      myPrint("$preImage == $_image");
      if (firstName == preFirstName &&
          lastName == preLastName &&
          email == preEmail &&
          dob == formattedDate &&
          _image is String && _image == preImage) {
            myPrint("there is no changes");
            hideProgressDialog(context);
      } else {
        final response = await ApiProvider()
            .updateProfileDetails(
                firstName,
                lastName,
                number,
                 dob,
                email,
                 '',
                imageBase64);
        //hideProgressDialog(context);
        if (response.status == Constants.success) {
          final userResponse = await ApiProvider()
              .fetchProfileDetails(userid);
          hideProgressDialog(context);
          if (userResponse.status == UrlConstants.SUCCESS) {
            final user = userResponse.data;
            Prefs.setImageUrl(user.profile_pic);
            Prefs.setFirstName(user.firstName);
            Prefs.setLastName(user.lastName);
            Prefs.setDob(user.dob);
            Prefs.setEmail(user.emailId);
            Utility.showCustomSnackBar(response.message, _scaffoldKey);
            setState(() {
            _image = user.profile_pic;
            });
          } else {
            Utility.showCustomSnackBar(userResponse.message, _scaffoldKey);
          }
          //Prefs.setImageUrl(imageBase64);

        } else {
          hideProgressDialog(context);
          DialogHelper.showErrorDialog(context, 'Error', response.message,
              showTitle: true, onOkClicked: () {
            Navigator.pop(context);
          });
        }
      }
    } catch (e) {
      myPrint(e.toString());
      hideProgressDialog(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
            'Something went wrong, Please check your internet connection or try again'),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
            label: 'RETRY',
            onPressed: () {
              _updateUser();
            }),
      ));
    }
  }

  Future<List<int>> testCompressFile(File file) async {
    // var result = await FlutterImageCompress.compressWithFile(
    //   file.absolute.path,
    //   minWidth: 1200,
    //   minHeight: 1200,
    //   quality: 90,
    //   rotate: 0,
    // );
    // myPrint("${file.lengthSync()}");
    // myPrint("${result.length}");
    return null;
  }

  _registerUser() async {
    progressDialog(context, 'Please wait...');
    final firstName = _nameController.text;
    final lastName = _lastNameController.text;
    final email = _emailController.text;
    final number = _mobileController.text;
    final dob = _dateController.text;
    final imageBase64 = '';
    try {
      final response = await ApiProvider()
          .registerUser(
              firstName,
              lastName,
              number,
              dob,
              email,
              '',
              imageBase64);
      hideProgressDialog(context);
      if (response.status == Constants.success) {
        final user = response.data;
        saveData(user);
      } else {
        DialogHelper.showErrorDialog(context, 'Error', response.message,
            showTitle: true, onOkClicked: () {
          Navigator.pop(context);
        });
      }
    } catch (e) {
      myPrint(e.toString());
      hideProgressDialog(context);
     ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
            'Something went wrong, Please check your internet connection or try again'),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
            label: 'RETRY',
            onPressed: () {
              _registerUser();
            }),
      ));
    }
  }

  saveData(User user) async {
    Prefs.setId(user.id);
    Prefs.setToken(user.accessToken);
    Prefs.setFirstName(user.firstName);
    Prefs.setLastName(user.lastName);
    Prefs.setEmail(user.emailId);
    Prefs.setMobileNumber(user.mobileNumber);
    Prefs.setDob(user.dob);
    Prefs.setImageUrl(user.profile_pic);
    Prefs.setLogin(true);
    Navigator.pop(context,true);
   // Utility.pushToDashboard(context, 0);
    //
  }

  get _getBackView {
    final topHeight = MediaQuery.of(context).size.height * 0.30;
    final bottomHeight = MediaQuery.of(context).size.height * 0.70;
    return Container(
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          Flexible(
            flex: 1,
            child: Container(
              color: Colors.grey.shade300,
            ),
          ),
          Flexible(
            flex: 2,
            child: Container(
              color: Colors.white,
            ),
          )
        ],
      ),
    );
  }

  Widget _formWidget() {
    return Container(
      color: Colors.white,
      margin: EdgeInsets.only(bottom: 50),
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 25),
      child: ListView(
        physics: ClampingScrollPhysics(),
        shrinkWrap: true,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: _formData(
                    'First Name (optional)',
                    TextInputType.text,
                    false,
                    MyFlutterApp.ic_profile,
                    _nameController,
                    _isNameError,
                    "Please enter valid first name"),
              ),
              SizedBox(
                width: 8,
              ),
              Expanded(
                child: _formData(
                    'Last Name (optional)',
                    TextInputType.text,
                    false,
                    MyFlutterApp.ic_profile,
                    _lastNameController,
                    _isLastNameError,
                    "Please enter valid last name"),
              ),
            ],
          ),
          SizedBox(
            height: 20,
          ),
          _formData(
              'Email Id',
              TextInputType.emailAddress,
              false,
              MyFlutterApp.ic_mail,
              _emailController,
              _isEmailError,
              "Please enter valid email"),
          SizedBox(
            height: 20,
          ),
          _formData(
              'Mobile Number',
              TextInputType.number,
              false,
              Icons.mobile_screen_share,
              _mobileController,
              _ismobileError,
              "Please enter valid mobile no"),
          SizedBox(
            height: 20,
          ),
          _formData('DOB (optional)', TextInputType.text, true, MyFlutterApp.ic_dob,
              _dateController, _isDobError, "Please enter DOB"),
        ],
      ),
    );
  }

  Widget _formData(var text, var type, var isdate, var icons, var controller,
      var error, var errorText) {
    var style = TextStyle(fontSize: 13, color: Colors.grey.shade700);
    var errorStyle = TextStyle(fontSize: 11, color: red);

    var textFeild = TextField(
        controller: controller,
        keyboardType: type,
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
          Expanded(
            child: (!isdate && text != 'Mobile Number')
                ? textFeild
                : (text == 'Mobile Number')
                    ? IgnorePointer(
                        child: textFeild,
                      )
                    : InkWell(
                        onTap: () async {
                          FocusScope.of(context)
                              .requestFocus(new FocusNode()); //rem
                          DateTime date = DateTime.now();
                          DateTime picked = await showDatePicker(
                              context: context,
                              initialDate: new DateTime(
                                  date.year, date.month, date.day - 1),
                              firstDate: new DateTime(1920),
                              lastDate: new DateTime(
                                  date.year, date.month, date.day));
                          if (picked != null) {
                            String formattedDate =
                                DateFormat('dd-MM-yyyy').format(picked);
                            setState(() {
                              _dateController.text = formattedDate;
                            });
                          }
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            IgnorePointer(
                              child: TextField(
                                  controller: _dateController,
                                  keyboardType: type,
                                  style: style,
                                  enabled: false,
                                  decoration: InputDecoration(
                                    // errorText: error ? errorText:null,
                                    // errorStyle:errorStyle ,
                                    border: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                            color: textGrey, width: 0.5)),
                                    enabledBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                            color: green, width: 0.5)),
                                    focusedBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                            color: green, width: 0.5)),
                                    hintText: text,
                                    labelText: text,
                                    contentPadding: const EdgeInsets.only(
                                        top: 1.0, bottom: 5.0),
                                  )),
                            ),
                            Container(
                              height: 0.8,
                              color: Colors.grey,
                            ),
                            (SizedBox(
                              height: 5,
                            )),
                            (error)
                                ? Text(
                                    errorText,
                                    style: errorStyle,
                                    textAlign: TextAlign.start,
                                  )
                                : Container()
                          ],
                        )),
          )
        ],
      ),
    );
  }

  Widget _topProfile() {
    return Container(
      height: 160,
      //color:Colors.blue,
      child: Stack(
        children: <Widget>[
          Align(
            alignment: Alignment.center,
            child: Container(
              height: 3,
              color: Colors.grey.shade300,
            ),
          ),
          Center(
            child: new Container(
              margin: EdgeInsets.only(top: 8),
              height: 120,
              width: 120,
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: white,
                  image: DecorationImage(
                      image: (_image == null)
                          ? AssetImage(
                              'assets/user_pic.png',
                            )
                          : (_image is File)
                              ? FileImage(_image)
                              : NetworkImage(_image),
                      fit: BoxFit.cover),
                  border: Border.all(
                      color: Colors.grey.shade300,
                      style: BorderStyle.solid,
                      width: 2)),
            ),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: InkWell(
              onTap: () {
                _showGalleryDialog();
              },
              child: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: Colors.white,
                        width: 1.2,
                        style: BorderStyle.solid)),
                margin: EdgeInsets.only(bottom: 10, left: 90),
                child: Icon(
                  Icons.edit,
                  color: Colors.white,
                  size: 12,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  _showGalleryDialog() {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            contentPadding: EdgeInsets.all(0),
            content: Container(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  ListTile(
                    leading: Icon(Icons.camera),
                    title: Text('Camera'),
                    onTap: () async {
                      _getImage(1);
                      Navigator.of(context).pop();
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.collections),
                    title: Text('Gallery'),
                    onTap: () {
                      _getImage(2);
                      Navigator.of(context).pop();
                    },
                  ),
                  // ListTile(
                  //   leading: Icon(Icons.remove_circle),
                  //   title: Text('Remove'),
                  //   onTap: () {
                  //     setState(() {
                  //       _image = null;
                  //       Navigator.of(context).pop();
                  //     });
                  //   },
                  // ),
                ],
              ),
            ),
          );
        });
  }

  _getImage(var tag) async {
    var image;
    if (tag == 1) {
      image = await ImagePicker().pickImage(source: ImageSource.camera);
    } else {
      image = await ImagePicker().pickImage(source: ImageSource.gallery);
    }
    setState(() {
      _image = image;
    });
  }
}
