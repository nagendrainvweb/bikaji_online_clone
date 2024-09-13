import 'package:bikaji/model/OrderDetailsData.dart';
import 'package:bikaji/util/utility.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TrackView extends StatefulWidget {
  final Status status;
  TrackView({@required this.status});
  @override
  _TrackViewState createState() => _TrackViewState();
}

class _TrackViewState extends State<TrackView> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: _getTackView,
    );
  }
  get _getTackView {
    return Container(
      color: white,
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
      child: Stack(
        children: <Widget>[
          //_getBackView,
          _getTopView,
        ],
      ),
    );
  }

  get _getTopView {
    DateFormat dateFormat = DateFormat("dd/MM/yyyy hh:mm:ss");
    DateTime dateTime = dateFormat.parse(widget.status.orderDate);
    DateTime statusDateTime = dateFormat.parse(widget.status.statusDate);
    String formattedOrderDate = DateFormat('dd MMM yyyy dd:mm').format(dateTime);
    String formattedStatusDate =
        DateFormat('dd MMM yyyy dd:mm').format(statusDateTime);
    return Column(
      children: <Widget>[
        _orderTrackRow(Colors.green,Colors.green,
            "Ordered And Approved", "$formattedOrderDate","Your Order has been placed.",isLast:false,isDesc:true),
        
        // _orderTrackRow(grey,Colors.grey, "${widget.status.status}",
        //     "$formattedStatusDate","Your order has pending status",isLast:false,isDesc:true),
        // _orderTrackRow(
        //     Colors.green, Colors.green, "Shipped", "Mon, 7th Aug'19","Your item is out for delivery",isLast:false,isDesc:true),
        // _orderTrackRow(
        //     grey, Colors.green, "Completed", "Mon, 7th Aug'19","Your item is out for delivery",isLast:false,isDesc:true),
        _orderTrackRow(white,(widget.status.status=="pending")?grey: Colors.green, "${widget.status.status}", "$formattedStatusDate","",isLast:true,isDesc:false),
      ],
    );
  }

  _orderTrackRow(var firstColor, var bulletColor, var text,
      var secondText,var desc,{var isLast,var isDesc}) {
    return Container(
      child: Stack(
        children: <Widget>[
          AnimatedContainer(
            duration: Duration(milliseconds: 500),
            margin: EdgeInsets.only(left: 4),
            padding: EdgeInsets.only(bottom:(isLast)?0: 30),
            decoration: BoxDecoration(
              border: Border(left: BorderSide(color:firstColor,width: 2))
            ),
            child: Container(
              margin: const EdgeInsets.only(left: 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        child: Text(text,
                            style: TextStyle(
                                color: Colors.grey.shade800,
                                fontSize: 13,
                                fontWeight: FontWeight.w600)),
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      Container(
                        child: Text(secondText,
                            style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 13,
                            )),
                      ),
                    ],
                  ),
                 (isDesc)? SizedBox(height: 8,):Container(),
                  (isDesc)?Container(
                        child: Text(desc,
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 11,
                            )),
                      ):Container(),
                ],
              ),
            ),
          ),
          Container(
            child: Column(
              children: <Widget>[
                Container(
                  child: _getBullet(bulletColor),
                ),
              //  (isLast)?Container(): Container(
              //    height: 50,
              //     child:  _getLine(firstColor, secondColor),
              //   )
               // ,
              ],
            ),
          ),
          // _getTrackDetails
        ],
      ),
    );
  }

  _getLine(var firstColor, var secondColor) {
    return Center(
      child: Container(
        width: 2.5,
        color: red,
      ),
    );
  }

  _getBullet(var bulletColor) {
    return Container(
      child: Container(
        height: 10,
        width: 10,
        decoration: BoxDecoration(shape: BoxShape.circle, color: bulletColor),
      ),
    );
  }

  get _getTrackDetails {
    return Expanded(
      child: Container(
        height: 50,
        color: green,
      ),
    );
  }
}