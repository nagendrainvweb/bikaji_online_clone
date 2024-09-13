import 'dart:convert';

import 'package:bikaji/model/AddressData.dart';
import 'package:bikaji/model/PincodeResponse.dart';
import 'package:bikaji/model/StateData.dart';
import 'package:bikaji/model/UserData.dart';
import 'package:bikaji/prefrence_util/Prefs.dart';
import 'package:bikaji/repo/Repository.dart';
import 'package:bikaji/repo/api_provider.dart';
import 'package:bikaji/util/app_helper.dart';
import 'package:bikaji/util/custom_icons.dart';
import 'package:bikaji/util/custom_regex.dart';
import 'package:bikaji/util/textStyle.dart';
import 'package:bikaji/util/url_list.dart';
import 'package:bikaji/util/utility.dart';
import 'package:flutter/material.dart';
//import 'package:geocoder/geocoder.dart';
//import 'package:geolocator/geolocator.dart';

class AddEditAddress extends StatefulWidget {
  final AddressData addressData;
  AddEditAddress({this.addressData});
  @override
  _AddEditAddressState createState() => _AddEditAddressState();
}

class _AddEditAddressState extends State<AddEditAddress> with AppHelper {
  bool isChecked = false;
  var tag = "HOME";
  String _state_code = "";

  // all textFeild controller
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _mobileController = TextEditingController();
  final _locationController = TextEditingController();
  final _flatController = TextEditingController();
  final _streetController = TextEditingController();
  final _areaController = TextEditingController();
  final _landmarkController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _pincodeController = TextEditingController();

  // textfeild error boolean
  bool _isFirstNameError = false;
  bool _isLastNameError = false;
  bool _isEmailError = false;
  bool _isMobileError = false;
  bool _isLocationError = false;
  bool _isFlatError = false;
  bool _isStreetError = false;
  bool _isAreaError = false;
  bool _isLandmarkError = false;
  bool _isCityError = false;
  bool _isStateError = false;
  bool _isPincodeError = false;

  // scaffold key
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  List<StateData> stateList = List();

  @override
  void initState() {
    super.initState();

    _getStateList();
    

    if (widget.addressData != null) {
      _state_code = _getStateCodeByName(widget.addressData.state);
      final firstname = widget.addressData.firstName;
      final lastname = widget.addressData.lastName;
      final email = widget.addressData.emailId;
      final number = widget.addressData.number;
      final type = widget.addressData.type;
      final flat_no = widget.addressData.flatNo;
      final street_name = widget.addressData.streetName;
      final area = widget.addressData.area;
      final landmark = widget.addressData.landmark;
      final city = widget.addressData.city;
      final state = widget.addressData.state;
      final pincode = widget.addressData.pincode;

      setState(() {
        _firstNameController.text = firstname;
        _lastNameController.text = lastname;
        _emailController.text = email;
        _mobileController.text = number;
        _flatController.text = flat_no;
        _streetController.text = street_name;
        // _areaController.text = area;
        _landmarkController.text = landmark;
        _cityController.text = city;
        _stateController.text = state;
        _pincodeController.text = pincode;
        tag = type.toUpperCase();
        isChecked = widget.addressData.isDefault;
      });
    }
  }

  _getStateList() async {
    stateList.clear();
    final stateListResponse = await Prefs.stateList;
    final jsonResponse = json.decode(stateListResponse);
    for (var item in jsonResponse) {
      stateList.add(StateData.fromJson(item));
    }
  }

  String _getStateCodeByName(String name) {
    String code = "";
    for (StateData data in stateList) {
      if (data.name == name) {
        code = data.code;
        break;
      }
    }
    return code;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(45),
        child: AppBar(
          title: Text(
            'Add Address',
            style: toolbarStyle,
          ),
          backgroundColor: red,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.chevron_left),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ),
      ),
      body: Container(
          color: whiteGrey,
          child: Column(
            children: <Widget>[
              _getFromView,
              InkWell(
                onTap: () {
                  bool value = _validateForm();
                  if (value) {
                    _addEditAddress();
                    // to add update
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(15),
                  color: blackGrey,
                  width: double.infinity,
                  child: Text(
                    (widget.addressData == null)
                        ? 'SAVE DETAILS'
                        : "UPDATE DETAILS",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w400),
                  ),
                ),
              )
            ],
          )),
    );
  }

  _addEditAddress() async {
    progressDialog(context, "Please wait...");
    final id = (widget.addressData != null) ? widget.addressData.addressId : '';
    final firstName = _firstNameController.text;
    final lastName = _lastNameController.text;
    final email = _emailController.text;
    final mobile = _mobileController.text;
    final flatNo = _flatController.text;
    final streetName = _streetController.text;
    //final area = _areaController.text;
    final landmark = _landmarkController.text;
    final city = _cityController.text;
    final state = _stateController.text;
    final state_id = _state_code;
    final pincode = _pincodeController.text;

    final user = AddressData(
        addressId: id,
        firstName: firstName,
        lastName: lastName,
        emailId: email,
        number: mobile,
        isDefault: isChecked,
        type: tag,
        flatNo: flatNo,
        streetName: streetName,
        area: "",
        state_id: state_id,
        landmark: landmark,
        city: city,
        state: state,
        pincode: pincode);

    try {
      final response = await ApiProvider()
          .addUpdateAddress(user);
      hideProgressDialog(context);
      if (response.status == UrlConstants.SUCCESS) {
        Navigator.pop(context);
      } else {
        Utility.showCustomSnackBar(response.message, _scaffoldKey);
      }
    } catch (e) {
      myPrint(e.toString());
      hideProgressDialog(context);
      Utility.showCustomSnackBar(SOMETHING_WRONG_TEXT, _scaffoldKey);
    }
  }

  bool _validateForm() {
    setState(() {
      _isFirstNameError = _firstNameController.text.isEmpty;
      _isLastNameError = _lastNameController.text.isEmpty;
      // _isEmailError =
      //     !RegExp(CustomRegex.email_regex).hasMatch(_emailController.text);
      _isMobileError =
          !RegExp(CustomRegex.mobile_regex).hasMatch(_mobileController.text);
      _isFlatError = _flatController.text.isEmpty;
      _isStreetError = _streetController.text.isEmpty;
      _isLandmarkError = _landmarkController.text.isEmpty;
      _isCityError = _cityController.text.isEmpty;
      _isStateError = _state_code.isEmpty;
      _isPincodeError =
          !RegExp(r"^[1-9][0-9]{5}$").hasMatch(_pincodeController.text);

      myPrint('${(_isFirstNameError &&
          _isLastNameError &&
          _isEmailError &&
          _isMobileError &&
          _isFlatError &&
          _isStreetError &&
          _isLandmarkError &&
          _isCityError &&
          _isStateError &&
          _isPincodeError)}');

      //  myPrint('$_isNameError $_isEmailError $_isMobileError $_isFlatError $_isStreetError $_isLandmarkError $_isCityError $_isStateError $_isPincodeError');

      // _scaffoldKey.currentState.showSnackBar(
      //   SnackBar(
      //     content: Text('Please Select Address Type'),
      //   )
      // );
    });
    if (!_isFirstNameError &&
        !_isLastNameError &&
        !_isEmailError &&
        !_isMobileError &&
        !_isFlatError &&
        !_isStreetError &&
        !_isLandmarkError &&
        !_isCityError &&
        !_isStateError &&
        !_isPincodeError) {
      return true;
      // Navigator.pop(context);
    } else {
      return false;
    }
  }

  _getLocation() async {
    // Position position = await Geolocator()
    //     .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    // debugPrint('location: ${position.latitude}');
    // final coordinates = new Coordinates(position.latitude, position.longitude);
    // var addresses =
    //     await Geocoder.local.findAddressesFromCoordinates(coordinates);
    // var first = addresses.first;
    // var state = first.adminArea;
    // var city = first.locality;
    // var pincode = first.postalCode;

    // setState(() {
    //   _locationController.text = first.addressLine;
    //   _pincodeController.text = pincode;
    //   _stateController.text = state;
    //   _cityController.text = city;
    // });
    // myPrint("${first.featureName} : ${first.addressLine}");
  }

  get _getFromView {
    return Expanded(
      child: Container(
        padding:
            const EdgeInsets.only(top: 12, bottom: 12, left: 20, right: 40),
        child: ListView(
          shrinkWrap: true,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: _textFeild(
                      'First Name',
                      MyFlutterApp.ic_profile,
                      _firstNameController,
                      _isFirstNameError,
                      "Please enter first name"),
                ),
                SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: _textFeild(
                      'Last Name',
                      MyFlutterApp.ic_profile,
                      _lastNameController,
                      _isLastNameError,
                      "Please enter last name"),
                ),
              ],
            ),
            // _textFeild('Email id', MyFlutterApp.ic_mail, _emailController,
            //     _isEmailError, "Please enter Email"),
            _textFeild('Mobile Number', MyFlutterApp.ic_coupon,
                _mobileController, _isMobileError, "Please enter Mobile"),
            //  SizedBox(height: 10),
            // _locationAddress(MyFlutterApp.ic_detect, _locationController),
            SizedBox(
              height: 30,
            ),
            _addressType(),
            SizedBox(height: 2),
            // _textFeild('Flat no/House no', MyFlutterApp.ic_my_addresses,
            //     _flatController, _isFlatError, "Please enter Flat no"),
            // _textFeild('street name', MyFlutterApp.ic_my_addresses,
            //     _streetController, _isStreetError, "Please enter street"),
            // _textFeild('Area name', MyFlutterApp.ic_my_addresses,
            //     _areaController, _isAreaError, "Please enter Area"),
            _textFeild('Address line 1', MyFlutterApp.ic_my_addresses,
                _flatController, _isFlatError, "Please enter Flat no"),
            _textFeild('Address line 2', MyFlutterApp.ic_my_addresses,
                _streetController, _isStreetError, "Please enter street"),
            // _textFeild('Address line 3', MyFlutterApp.ic_my_addresses,
            //     _areaController, _isAreaError, "Please enter Area"),
            _textFeild('Landmark', MyFlutterApp.ic_landmark,
                _landmarkController, _isLandmarkError, "Please enter landmark"),
            _textFeild('Pincode', MyFlutterApp.ic_city, _pincodeController,
                _isPincodeError, "Please enter pincode"),
            _textFeild('City', MyFlutterApp.ic_city, _cityController,
                _isCityError, "Please enter city"),
            _textFeild('State', MyFlutterApp.ic_city, _stateController,
                _isStateError, "Please enter correct state"),

            SizedBox(
              height: 20,
            ),
            Row(
              children: <Widget>[
                Checkbox(
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  value: isChecked,
                  onChanged: (value) {
                    setState(() {
                      isChecked = !isChecked;
                    });
                  },
                ),
                Text(
                  'Make Default',
                  style: TextStyle(
                      color: textGrey,
                      fontWeight: FontWeight.w500,
                      fontSize: 14),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _locationAddress(var icon, var controller) {
    return Container(
      width: 100,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          Expanded(
              child: _textFeild('location', icon, controller, _isLocationError,
                  "Please enter location")),
          SizedBox(
            width: 10,
          ),
          InkWell(
            onTap: () async {
              myPrint("Detact Location");
              _checkGps();
              //  Geolocator().isLocationServiceEnabled().then((value){
              //    myPrint(value);
              //    if(value){
              //       _getLocation();
              //    }else{
              //      _checkGps();
              //    }

              //  });
              //  if(result){
              //    _getLocation();
              //  }else{
              //    myPrint('Location is missing');
              //  }
            },
            child: Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(3), color: textGrey),
              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 20),
              child: Row(
                children: <Widget>[
                  Text(
                    'Detect',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Future _checkGps() async {
    // if (!(await Geolocator().isLocationServiceEnabled())) {
    //   if (Theme.of(context).platform == TargetPlatform.android) {
    //     showDialog(
    //       context: context,
    //       builder: (BuildContext context) {
    //         return AlertDialog(
    //           // title: Text("Can not get current location"),
    //           contentPadding: const EdgeInsets.only(
    //               left: 20, right: 20, top: 20, bottom: 0),
    //           content: Text(
    //             'For a better experience, turn on device location, click OK to turn on location',
    //             style: TextStyle(
    //                 fontSize: 13, color: Colors.grey[600], height: 1.5),
    //           ),
    //           actions: <Widget>[
    //             FlatButton(
    //               child: Text('NO,THANKS'),
    //               onPressed: () {
    //                 Navigator.of(context, rootNavigator: true).pop();
    //               },
    //             ),
    //             FlatButton(
    //               child: Text('Ok'),
    //               onPressed: () {
    //                 // final AndroidIntent intent = new AndroidIntent(
    //                 //     action: 'android.settings.LOCATION_SOURCE_SETTINGS');

    //                 //  intent.launch();
    //                 Navigator.of(context, rootNavigator: true).pop();
    //                 //AppSettings.openLocationSettings();
    //               },
    //             ),
    //           ],
    //         );
    //       },
    //     );
    //   }
    // } else {
    //   _getLocation();
    // }
  }

  Widget _addressType() {
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            width: 15,
          ),
          InkWell(
            onTap: () {
              _changeState("HOME");
            },
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 6, horizontal: 18),
              decoration: BoxDecoration(
                  border: Border.all(
                      color: (tag == "HOME") ? red : Colors.grey.shade400,
                      width: 1,
                      style: BorderStyle.solid),
                  borderRadius: BorderRadius.circular(3)),
              child: Text(
                'HOME',
                style: TextStyle(
                    color: (tag == "HOME") ? red : textGrey,
                    fontSize: 11,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
          SizedBox(
            width: 15,
          ),
          InkWell(
            onTap: () {
              _changeState("WORK");
            },
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 6, horizontal: 18),
              decoration: BoxDecoration(
                  border: Border.all(
                      color: (tag == "WORK") ? red : Colors.grey,
                      width: 1,
                      style: BorderStyle.solid),
                  borderRadius: BorderRadius.circular(3)),
              child: Text(
                'WORK',
                style: TextStyle(
                    color: (tag == "WORK") ? red : textGrey,
                    fontSize: 11,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
          SizedBox(
            width: 15,
          ),
          InkWell(
            onTap: () {
              _changeState("OTHER");
            },
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 6, horizontal: 18),
              decoration: BoxDecoration(
                  border: Border.all(
                      color: (tag == "OTHER") ? red : Colors.grey,
                      width: 1,
                      style: BorderStyle.solid),
                  borderRadius: BorderRadius.circular(3)),
              child: Text(
                'OTHER',
                style: TextStyle(
                    color: (tag == "OTHER") ? red : textGrey,
                    fontSize: 11,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  _changeState(var tag) {
    setState(() {
      this.tag = tag;
    });
  }

  Widget _textFeild(
      var title, var icon, var controller, var isError, var errorText) {
    var style = TextStyle(fontSize: 13, color: Colors.grey.shade700);
    var errorStyle = TextStyle(fontSize: 11, color: red);
    return Column(
      children: <Widget>[
        (title == "Name")
            ? Container()
            : SizedBox(
                height: 20,
              ),
        Row(
          children: <Widget>[
            SizedBox(
              width: 10,
            ),
            (title == "Mobile Number")
                ? Text(
                    '+91',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
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
              child: InkWell(
                onTap: () async {
                  if (title == "State") {
                    showModalBottomSheet(
                        context: context,
                        builder: (context) {
                          return Container(
                            child: ListView.builder(
                                itemCount: stateList.length,
                                shrinkWrap: true,
                                itemBuilder: (context, index) {
                                  return Column(
                                    children: [
                                      ListTile(
                                        leading: Icon(Icons.location_city,
                                            color: Colors.grey.shade400),
                                        title: Text(stateList[index].name),
                                        onTap: () {
                                          Navigator.pop(context);
                                          _state_code = _getStateCodeByName(
                                              stateList[index].name);
                                          myPrint(_state_code);
                                          setState(() {
                                            _stateController.text =
                                                stateList[index].name;
                                          });
                                        },
                                      ),
                                      // Divider()
                                      Container(
                                        height: 0.5,
                                        color: grey,
                                      ),
                                    ],
                                  );
                                }),
                          );
                        });
                  }
                },
                child: TextField(
                  controller: controller,
                  style: style,
                  enabled: (title != "State"),
                  onChanged: (value) {
                    if (title == "Pincode") {
                      RegExp regExp = new RegExp(
                        r"^[1-9][0-9]{5}$",
                      );
                      if (regExp.hasMatch(value)) {
                        _setPincode(value);
                      }
                    }
                  },
                  decoration: InputDecoration(
                    labelText: title,
                    errorText: isError ? errorText : null,
                    errorStyle: errorStyle,
                    border: UnderlineInputBorder(
                        borderSide: BorderSide(color: textGrey, width: 0.5)),
                    enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: textGrey, width: 0.5)),
                    focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: red, width: 0.5)),
                    contentPadding:
                        EdgeInsets.only(top: 10, bottom: 2, left: 0, right: 0),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  _setPincode(String code) async {
    progressDialog(context, "Please wait...");
    try {
      final response =
          await ApiProvider().fetchPincode(code);
      hideProgressDialog(context);
      final list = response.postOffice;
      if (list.length > 0) {
        PostOffice office = list[0];
        setState(() {
          _stateController.text = office.state;
          _state_code = _getStateCodeByName(office.state);
          _cityController.text = office.district;
        });
      }
    } catch (e) {
      hideProgressDialog(context);
      myPrint(e.toString());
    }
  }
}
