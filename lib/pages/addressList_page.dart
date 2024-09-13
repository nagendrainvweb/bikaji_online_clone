import 'package:bikaji/bloc/address_bloc/AddressBloc.dart';
import 'package:bikaji/bloc/address_bloc/AddressEvent.dart';
import 'package:bikaji/bloc/address_bloc/AddressState.dart';
import 'package:bikaji/model/AddressData.dart';
import 'package:bikaji/prefrence_util/Prefs.dart';
import 'package:bikaji/repo/Repository.dart';
import 'package:bikaji/repo/api_provider.dart';
import 'package:bikaji/util/app_helper.dart';
import 'package:bikaji/util/dialog_helper.dart';
import 'package:bikaji/util/textStyle.dart';
import 'package:bikaji/util/url_list.dart';
import 'package:bikaji/util/utility.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'add_edit_address.dart';

class AddressListPage extends StatefulWidget {
  @override
  _AddressListPageState createState() => _AddressListPageState();
}

class _AddressListPageState extends State<AddressListPage> with AppHelper {
  AddressBloc _addressBloc;
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  List<AddressData> _addressList = null;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _setData();
  }

  _setData() async {
    final userId = await Prefs.id;
    _addressBloc = BlocProvider.of<AddressBloc>(context);
    _addressBloc.add(FetchAddressEvent(userId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(45),
        child: AppBar(
          backgroundColor: Colors.red.shade500,
          title: Text(
            'My Addresses',
            style: toolbarStyle,
          ),
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.chevron_left),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ),
      ),
      body: BlocBuilder<AddressBloc, AddressState>(
        builder: (context, state) {
          if (state is AddressLoadingSuccessState) {
            final List<AddressData> list = state.data;
            _addressList = list;
            return (_addressList.length > 0)
                ? Container(
                    color: Colors.grey.shade100,
                    child: Column(
                      children: <Widget>[
                        _getAddAddress,
                        Expanded(
                          child: ListView.builder(
                            itemCount: list.length,
                            itemBuilder: (context, index) {
                              return Column(
                                children: <Widget>[
                                  //SizedBox(height: 8,),
                                  _addressRow(_addressList[index]),
                                ],
                              );
                            },
                          ),
                        ),
                      ],
                    ))
                : NoAddressWidget(
                    onAddCliked: () {
                      Utility.pushToNext(
                              AddEditAddress(
                                addressData: null,
                              ),
                              context)
                          .then((value) async {
                        final userid = await Prefs.id;
                        _addressBloc.add(FetchAddressEvent(userid));
                      });
                    },
                  );
          } else if (state is AddressLoadingState) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else {
            return Container();
          }
        },
      ),
    );
  }

  get _getAddAddress {
    return InkWell(
      onTap: () {
        Utility.pushToNext(
                AddEditAddress(
                  addressData: null,
                ),
                context)
            .then((value) async {
          final userid = await Prefs.id;
          _addressBloc.add(FetchAddressEvent(userid));
        });
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: Colors.white,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
        child: Row(
          children: <Widget>[
            Icon(
              Icons.add_circle,
              color: Colors.red,
            ),
            SizedBox(
              width: 15,
            ),
            Text(
              'Add New Address',
              style: TextStyle(
                  color: textGrey, fontWeight: FontWeight.w500, fontSize: 16),
            )
          ],
        ),
      ),
    );
  }

  Widget _addressRow(AddressData addressData) {
    var addressStyle =
        TextStyle(color: textGrey, fontSize: 12, letterSpacing: 0.3);
    return new Container(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Icon(
                  Icons.home,
                  size: 18,
                  color: textGrey,
                ),
                SizedBox(
                  width: 12,
                ),
                Expanded(
                  flex: 3,
                  child: Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        SizedBox(
                          height: 2,
                        ),
                        Row(
                          children: <Widget>[
                            Text(
                              addressData.firstName +
                                  " " +
                                  addressData.lastName,
                              style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                        (addressData.isDefault)
                            ? Text(
                                'default',
                                style: TextStyle(
                                  fontStyle: FontStyle.italic,
                                  fontSize: 11,
                                  color: Colors.grey.shade600,
                                ),
                              )
                            : Container(),
                        SizedBox(
                          height: 15,
                        ),
                        Text(
                          addressData.number,
                          style: addressStyle,
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Text(
                          '${addressData.flatNo}, ${addressData.streetName}, ${addressData.landmark}',
                          style: addressStyle,
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Text(
                          '${addressData.city} - ${addressData.pincode}',
                          style: addressStyle,
                        ),
                        // SizedBox(
                        //   height: 5,
                        // ),
                        // Text('Rajasthan-334006',style: addressStyle,),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  width: 10,
                ),
                (addressData.type.isNotEmpty)
                    ? Expanded(
                        flex: 1,
                        child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 5),
                            decoration: BoxDecoration(
                                border: Border.all(
                                    color: Colors.grey.shade500,
                                    style: BorderStyle.solid,
                                    width: 0.7),
                                borderRadius: BorderRadius.circular(3)),
                            child: Text(
                              addressData.type,
                              style: TextStyle(
                                fontSize: 11,
                                color: red,
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.center,
                            )),
                      )
                    : Container(),
                SizedBox(
                  width: 10,
                ),
              ],
            ),
          ),
          // Container(
          //   height: 1,
          //   color: Colors.grey.shade300,
          // ),
          Container(
            color: Colors.grey.shade200,
            child: Row(
              children: <Widget>[
                Expanded(
                  child: InkWell(
                    onTap: () {
                      Utility.pushToNext(
                              AddEditAddress(
                                addressData: addressData,
                              ),
                              context)
                          .then((value) async {
                        final userid = await Prefs.id;
                        _addressBloc.add(FetchAddressEvent(userid));
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                          border: Border(
                              right:
                                  BorderSide(color: Colors.white, width: 0.7))),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Icon(
                            Icons.edit,
                            size: 16,
                            color: Colors.grey.shade600,
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(vertical: 12.0),
                            child: Text(
                              'EDIT',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 12,
                                  letterSpacing: 0.3,
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: InkWell(
                    onTap: () {
                      DialogHelper.showRemoveDialog(context, "Remove",
                          "Are want to remove this address?", 'REMOVE', () {
                        Navigator.pop(context);
                        _removeAddress(addressData);
                      });
                      //
                      //Utility.pushToNext(AddEditAddress(), context);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                          border: Border(
                              left:
                                  BorderSide(color: Colors.white, width: 0.7))),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Icon(
                            Icons.close,
                            size: 16,
                            color: Colors.grey.shade600,
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(vertical: 12.0),
                            child: Text(
                              'REMOVE',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 12,
                                  letterSpacing: 0.3,
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
          Container(
            height: 1,
            color: Colors.grey.shade300,
          ),
        ],
      ),
    );
  }

  _removeAddress(AddressData addressData) async {
    progressDialog(context, "Please wait...");
    try {
      final response = await ApiProvider()
          .deleteAddress(addressData.addressId);
      hideProgressDialog(context);
      if (response.status != UrlConstants.SUCCESS) {
        Utility.showCustomSnackBar(response.message, _scaffoldKey);
      } else {
        setState(() {
          _addressList.remove(addressData);
        });
      }
    } catch (e) {
      myPrint(e.toString());
      hideProgressDialog(context);
    }
  }
}

class NoAddressWidget extends StatelessWidget {
  const NoAddressWidget({Key key, this.onAddCliked}) : super(key: key);

  final Function onAddCliked;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.maxFinite,
      // height: double.maxFinite,
      margin: EdgeInsets.symmetric(horizontal: 50),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Icon(
            Icons.info_outline,
            color: Colors.grey.shade700,
            size: 70,
          ),
          SizedBox(
            height: 20,
          ),
          Text(
            "Empty list!",
            textAlign: TextAlign.center,
            style: extraBigTextStyle,
          ),
          SizedBox(
            height: 8,
          ),
          Text(
            "You have no addresses at this moment.",
            textAlign: TextAlign.center,
            style: smallTextStyle,
          ),
          SizedBox(
            height: 20,
          ),
          InkWell(
            onTap: () {
              onAddCliked();
              //Utility.pushToDashboard(context, 0);
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5), color: blackGrey),
              child: Text(
                'ADD ADDRESS',
                style: TextStyle(
                    fontSize: 11,
                    color: Colors.white,
                    fontWeight: FontWeight.bold),
              ),
            ),
          )
        ],
      ),
    );
  }
}
