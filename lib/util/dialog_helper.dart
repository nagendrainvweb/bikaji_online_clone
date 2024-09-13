import 'package:bikaji/model/BasicResponse.dart';
import 'package:bikaji/prefrence_util/Prefs.dart';
import 'package:bikaji/util/textStyle.dart';
import 'package:bikaji/util/utility.dart';
import 'package:flutter/material.dart';
import 'package:store_redirect/store_redirect.dart';

import 'dialog_inset_defeat.dart';

class DialogHelper{

  static showRemoveDialog(BuildContext context, var title,var desc, var positiveBtnText, Function() positiveClick){
    showDialog(
      context: context,
      builder: (context){
        return AlertDialog(
          shape: RoundedRectangleBorder(
           borderRadius: BorderRadius.circular(6) 
          ),
          contentPadding: EdgeInsets.symmetric(vertical: 0),
          content: Container(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SizedBox(height: 20,),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Text(title,style: TextStyle(color: Colors.grey.shade800,fontSize: 15,fontWeight: FontWeight.w700,letterSpacing: 0.3,),overflow: TextOverflow.ellipsis,),
              ),
              SizedBox(height: 10,),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 24,vertical: 5),
                child: Text(desc,style:TextStyle(fontSize: 13,color: Colors.grey.shade600)),
              ),
               SizedBox(height: 10,),
               Container(
                 padding: EdgeInsets.symmetric(horizontal: 10),
                 child: Row(
                   mainAxisAlignment: MainAxisAlignment.end,
                   children: <Widget>[
                     TextButton(
                       child: Text('CANCEL',style: TextStyle(fontSize: 12,color: red,fontWeight: FontWeight.w700),),
                       onPressed:(){
                         Navigator.pop(context);
                       } ,
                     ),
                     TextButton(
                       child: Text(positiveBtnText,style: TextStyle(fontSize: 12,color: red,fontWeight: FontWeight.w700,),),
                       onPressed:positiveClick ,
                     ),
                     SizedBox(width: 5,),
                     
                   ],
                 ),
               ),
               SizedBox(height: 5,),
            ],
          ),
        ),
        );
        
      }
    );
  }

  static showUpdateDialog(BuildContext context,BasicResponse response){
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context){
        return WillPopScope(
          onWillPop: ()async{
            return false;
          },
          child: AlertDialog(
            contentPadding: EdgeInsets.fromLTRB(20, 20, 20, 5),
            actionsPadding: EdgeInsets.symmetric(horizontal: 10,vertical: 10),
            title: Text('New version available'),
            shape: RoundedRectangleBorder(
             borderRadius: BorderRadius.circular(6) 
            ),
            content: Container(
              child: Text('Please, Update app to new version to continue.',style: TextStyle(fontSize: 15,color: Colors.grey.shade600),),
            ),
            actions: <Widget>[
              TextButton(
                child: Text('Update',style: TextStyle(fontSize: 14),),
                onPressed: ()async{
                  if(response.isForce??false){
                    Prefs.clear();
                  }
                  //Navigator.pop(context);
                  StoreRedirect.redirect();
                },
              ),
              
            ],
          ),
        );
      }
    );
  }

  static showLogoutDialog(BuildContext context,Function() onClick){
    showDialogWithInsets(
      context: context,
      builder: (context){
        return AlertDialog(
          contentPadding: EdgeInsets.fromLTRB(20, 20, 20, 5),
          actionsPadding: EdgeInsets.symmetric(horizontal: 10,vertical: 10),
          title: Text('Logout'),
          shape: RoundedRectangleBorder(
           borderRadius: BorderRadius.circular(6) 
          ),
          content: Container(
            child: Text('Are you sure you want to logout ?',style: TextStyle(fontSize: 15,color: Colors.grey.shade600),),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('CANCEL',style: TextStyle(fontSize: 14),),
              onPressed: (){
                Navigator.pop(context);
              },
            ),
            TextButton(
              child: Text('LOG OUT',style: TextStyle(fontSize: 14)),
              onPressed: onClick,
            ),
          ],
        );
      }
    );
  }
    static showErrorDialog(BuildContext context,title, content, {bool showTitle=false, Function() onOkClicked}) {
    showDialogWithInsets(
        edgeInsets: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
        context: context,
        builder: (context) {
          return WillPopScope(
            onWillPop: () async {
              return false;
            },
            child: AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6)),
              title: (showTitle)
                  ? Text(
                      title,
                      style: TextStyle(fontSize: 17),
                    )
                  : Container(),
              content: Text(
                content,
                style: TextStyle(
                    fontWeight: FontWeight.normal,
                    fontSize: 15,
                    color: grey_dark_text_color),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: onOkClicked??(){
                    Navigator.pop(context);
                  },
                  child: Text('OK',style: TextStyle(color: red),),
                  
                )
              ],
            ),
          );
        });
  }

  showNoInternetDialog(BuildContext context){
    showDialog(
      context: context,
      builder: (context){
        return WillPopScope(
          onWillPop: ()async{
            return false;
          },
          child: AlertDialog(
            contentPadding: EdgeInsets.fromLTRB(20, 20, 20, 0),
            content: Container(
              child: Text('No internet connection. Make sure that Wi-Fi or mobile data is turned on, then try again.'),
            ),
            actions: <Widget>[
              TextButton(
                child: Text('OK'),
                onPressed: (){
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
              )
            ],
          ),
        );
      }
    );
  }
}