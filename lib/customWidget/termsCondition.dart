
import 'package:bikaji/model/category_content.dart';
import 'package:bikaji/pages/home.dart';
import 'package:bikaji/repo/Repository.dart';
import 'package:bikaji/repo/api_provider.dart';
import 'package:bikaji/util/url_list.dart';
import 'package:bikaji/util/utility.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';

class TermsCondition extends StatefulWidget {

   final PolicyTag tag;

  TermsCondition(this.tag);
  @override
  _TermsConditionState createState() => _TermsConditionState();
}

class _TermsConditionState extends State<TermsCondition> {

   List<CategoryContent> list = List();
   //List<CategoryContent> policyList = List();
   var selectedIndex= -1;
   String data;
   bool isLoading = true;


  @override
  void initState() {
    super.initState();
    _getPolicies();
  }

  _getPolicies()async{
    String name ="";
    switch (widget.tag) {
      case PolicyTag.TERMS:
      name ="terms and conditions";
        break;
      case PolicyTag.PRIVACY:
      name ="privacy";
      break;
      case PolicyTag.CANCELLED_REFUND:
      name ="cancellation and refund";
      break;
      case PolicyTag.SHIPPING:
      name ="Shipping Policy";
      break;
      default:
      name ="privacy";
    }
    setState(() {
      isLoading = true;
    });
    try{
      final response = await ApiProvider().fetchPolicies(name);
      if(response.status == UrlConstants.SUCCESS){
        data = response.pageContent;
      }
      setState(() {
        isLoading = false;
      });
    }catch(e){
      setState(() {
        isLoading = false;
      });
      myPrint(e.toString());
    }
  }

  getPolicyData(){
    var list = List<CategoryContent>();
      list.add(CategoryContent(title: 'PRIVACY POLICY',
    content: 'Bikaji Foods International Limited respects your privacy. This Privacy Policy provides succinctly the manner your data is collected and used by BIKAJI FOODS INTERNATIONAL LIMITED on the Site. As a visitor to the Site/ Customer you are advised to please read the Privacy Policy carefully. By accessing the services provided by the Site you agree to the collection and use of your data by BIKAJI FOODS INTERNATIONAL LIMITED in the manner provided in this Privacy Policy.'))   ;

    list.add(CategoryContent(title: 'What information is, or may be, collected form you?',
    content: 'As part of the registration process on the Site, BIKAJI FOODS INTERNATIONAL LIMITED may collect the following personally identifiable information about you: Name including first and last name, alternate email address, mobile phone number and contact details, Postal code, Demographic profile (like your age, gender, occupation, education, address etc.) and information about the pages on the site you visit/access, the links you click on the site, the number of times you access the page and any such browsing information.'))   ;

    list.add(CategoryContent(title: "How do we Collect the Information ?",
    content: "BIKAJI FOODS INTERNATIONAL LIMITED will collect personally identifiable information about you only as part of a voluntary registration process, on-line survey or any combination thereof. The Site may contain links to other Web sites. BIKAJI FOODS INTERNATIONAL LIMITED is not responsible for the privacy practices of such Web sites which it does not own, manage or control. The Site and third-party vendors, including Google, use first-party cookies (such as the Google Analytics cookie) and third-party cookies (such as the DoubleClick cookie) together to inform, optimize, and serve ads based on someone's past visits to the Site."))   ;

    list.add(CategoryContent(title: 'How is information used ?',
    content: 'BIKAJI FOODS INTERNATIONAL LIMITED will use your personal information to provide personalized features to you on the Site and to provide for promotional offers to you through the Site and other channels. BIKAJI FOODS INTERNATIONAL LIMITED will also provide this information to its business associates and partners to get in touch with you when necessary to provide the services requested by you. BIKAJI FOODS INTERNATIONAL LIMITED will use this information to preserve transaction history as governed by existing law or policy. BIKAJI FOODS INTERNATIONAL LIMITED may also use contact information internally to direct its efforts for product improvement, to contact you as a survey respondent, to notify you if you win any contest; and to send you promotional materials from its contest sponsors or advertisers. BIKAJI FOODS INTERNATIONAL LIMITED will also use this information to serve various promotional and advertising materials to you via display advertisements through the Google Ad network on third party websites. You can opt out of Google Analytics for Display Advertising and customize Google Display network ads using the Ads Preferences Manager.'))   ;

    list.add(CategoryContent(title: 'With whom your information will be shared?',
    content: "BIKAJI FOODS INTERNATIONAL LIMITED will not use your financial information for any purpose other than to complete a transaction withyou. BIKAJI FOODS INTERNATIONAL LIMITED does not rent, sell or share your personal information and will not disclose any of your personally identifiable information to third parties. In cases where it has your permission to provide products or services you've requested and such information is necessary to provide these products or services the information may be shared with BIKAJI FOODS INTERNATIONAL LIMITED's business associates and partners. In addition BIKAJI FOODS INTERNATIONAL LIMITED may use this information for promotional offers, to help investigate, prevent or take action regarding unlawful and illegal activities, suspected fraud, potential threat to the safety or security of any person, violations of the Site's terms of use or to defend against legal claims; special circumstances such as compliance with subpoenas, court orders, requests/order from legal authorities or law enforcement agencies requiring such disclosure."))   ;

    list.add(CategoryContent(title: 'What Choice are available to you regarding collection, use and distribution of your information?',
    content: "To protect against the loss, misuse and alteration of the information under its control, BIKAJI FOODS INTERNATIONAL LIMITED has in place appropriate physical, electronic and managerial procedures. For example, BIKAJI FOODS INTERNATIONAL LIMITED servers are accessible only to authorized personnel and your information is shared with employees and authorised personnel on a need to know basis to complete the transaction and to provide the services requested by you. Although BIKAJI FOODS INTERNATIONAL LIMITED will endeavour to safeguard the confidentiality of your personally identifiable information, transmissions made by means of the Internet cannot be made absolutely secure. By using this site, you agree that BIKAJI FOODS INTERNATIONAL LIMITED will have no liability for disclosure of your information due to errors in transmission or unauthorized acts of third parties."))   ;

    list.add(CategoryContent(title: 'How can you correct inaccuracies in the information?',
    content: "To correct or update any information you have provided, the Site allows you to do it online. In the event of loss of access details you can send an e-mail to: bikajionline@gmail.com\nPolicy updates BIKAJI FOODS INTERNATIONAL LIMITED reserves the right to change or update this policy at any time. Such changes shall be effective immediately upon posting to the Site.")) ;


    list.add(CategoryContent(title: 'Cancellation and Returns\nCancellation by Site / Customer',
    content: "Order once placed cannot be cancelled post purchase. In case of any damage or returned goods we will refund any payments already made by you for the order after deducting fixed shipment charges. If we suspect any fraudulent transaction by any customer or any transaction which defies the terms & conditions of using the website, we at our sole discretion could cancel such orders. We will maintain a negative list of all fraudulent transactions and customers and would deny access to them or cancel any orders placed by them.\nBikaji does not take title to returned items. Any case of refund or cancellation is at sole discretion of Bikaji.\n10% cancellation charges will be applicable on order cancellations by customer."))   ;
    return list;
  }

  getCancelledRefund(){
    var list =List<CategoryContent>();

    list.add(CategoryContent(title: 'Returns and Refund Terms & Conditions:',content:"Bikaji does not take title to returned items. Any case of refund or cancellation is at sole discretion of Bikaji.10% cancellation charges will be applicable on order cancellations by customer."));
    return list;
  }

  getShippingData(){
     var list = List<CategoryContent>();
     list.add(CategoryContent(title: 'Shipping Policy :',
    content: '1. If, any Order placed post 6:00 pm, will be processed for dispatch within 24 hours.\n2. Any order place on late weekend i.e. on Saturday post 6:00 pm, will be process for dispatch on Monday evening due to limited shelf life (as we have no pick up on Sunday from courier).\n3. Shipping address, pin code & contact information should be correct and any delay in delivery due to any incorrect information would be sole responsibility of customer\n* Within City - 3 Working days.\n* Within Zone - 4 Working days. * Within Metro cities - 5 to 7 Working days.\n* Tier 1, 2 ,3 cities - 6 to 7 Working days.\n* Special destinations - 8 to 9 Working days\n* For Liquid items - 8 working days.'));

    list.add(CategoryContent(title: "Zone Structure :",
    content: "Within City : Bikaner\nWithin Zone : Rajasthan\nMetro : MUMBAI, BANGALORE, CHENNAI, DELHI, KOLKATA\nRoI A (Rest of India A) : State Capitals, Tier 1 cities and Key Tier 2 cities\nRoI B (Rest of India B) : Tier 2 and Tier 3 cities\nSpecial Destinations : North East , Andaman and Nicobar, J & K."));
    return list;
  }

  getTermsListData(){

    var list = List<CategoryContent>();
    list.add(CategoryContent(title: 'TERMS AND CONDITIONS :',
    content: 'Please review our Privacy Policy, which also governs your use of all information (whether personal or public).'))   ;

    list.add(CategoryContent(title: 'PRIVACY :',
    content: 'Bikaji and/or its affiliates ("Bikaji") provides website features and other products and services to you when you visit or shop at www.bikajionline.com, to use our products or services. Bikaji provides the services subject to the following terms and conditions. By using Products or Services through www.bikajonline.com, you wilfully out of free will unconditionally agree to these below conditions.'))   ;

    list.add(CategoryContent(title: 'ELECTRONIC COMMUNICATIONS :',
    content: 'When you use any of Bikaji service, or send e-mails to us, you are communicating with us electronically. You consent to receive communications from us electronically. We will communicate with you by e-mail / text message. You agree that all agreements, notices, disclosures and other communications that we provide to you electronically satisfy any legal requirement that such communications be in writing.'))   ;

    list.add(CategoryContent(title: 'COPYRIGHT :',
    content: 'All content included in or made available through any of the availed service, such as text, graphics, logos, button icons, images, audio clips and data compilations is the property of Bikaji or its content suppliers and shall be protected and governed by laws of the land in India. All unwarranted copies of content is strictly prohibited and illegal.'))   ;

    list.add(CategoryContent(title: 'TRADEMARKS :',
    content: 'In addition, graphics, logos, page headers, button icons, scripts, and service names included in or made available through any service are trademarks or service mark of Bikaji or its affiliates or its content suppliers but you by availing of the services do not get any right for copying or using the same.'))   ;

    list.add(CategoryContent(title: 'YOUR LOGIN ACCOUNT :',
    content: 'If you register yourself with the portal, you are responsible for maintaining the confidentiality of your account information and password and for restricting access to your computer. You agree to accept responsibility of authenticity of the information and for all activities that occur under your account or password. However, Bikaji reserves the right to refuse service, terminate accounts, remove or edit content, or cancel orders in its sole discretion with no damage or demure payable to you.'))   ;

    list.add(CategoryContent(title: 'RISK OF LOSS :',
    content: 'All items purchased through electronic mode through this website are made pursuant to a shipment contract. This means that the risk of loss and title for such items pass to you upon our delivery to the carrier (shipping partner) for dispatch.'))   ;

    list.add(CategoryContent(title: 'SHIPPING POLICY :',
    content: '1. If, any Order placed post 6:00 pm, will be processed for dispatch within 24 hours.\n2. Any order place on late weekend i.e. on Saturday post 6:00 pm, will be process for dispatch on Monday evening due to limited shelf life (as we have no pick up on Sunday from courier)\n3. Shipping address, pin code & contact information should be correct and any delay in delivery due to any incorrect information would be sole responsibility of customer\n* Within City - 3  Working days.\n* Within Zone - 4  Working days.\n* Within Metro cities - 5 to 7 Working days.\n* Tier 1, 2 ,3 cities -  6 to 7 Working days.\n* Special destinations - 8 to 9 Working days\n* For Liquid items - 8 working days.'))   ;

    list.add(CategoryContent(title: 'Zone Structure :',
    content: 'Within City : Bikaner\nWithin Zone : Rajasthan\nMetro : MUMBAI, BANGALORE, CHENNAI, DELHI, KOLKATA\nRoI A (Rest of India A) : State Capitals, Tier 1 cities and Key Tier 2 cities\nRoI B (Rest of India B) : Tier 2 and Tier 3 cities\nSpecial Destinations : North East , Andaman and Nicobar, J & K.'))   ;

    list.add(CategoryContent(title: 'RETURNS, REFUNDS AND TITLE :',
    content: 'Bikaji will take the return of product in case of only expired product or above shelf life. In this case we will refund entire amount deducting the fixed shipment charges into your store credit for future purchase.\nAny kind of return regarding product quality and packaging will be sole discretion of Bikaji and will be considered only after proper checking and required proofs submitted by customer. Anykind of complaint regarding the product and shipment will be sent on bikajifoodsonline@gmail.com with product details, shipment details, payment details and necessary photographs.\nAll the queries will be questioned and answered via email on bikajifoodsonline@gmail.com.'))   ;

        list.add(CategoryContent(title: 'DISCLAIMER OF WARRANTIES AND LIMITATION OF LIABILITY :',
    content: 'THE BIKAJI SERVICES AND ALL INFORMATION, CONTENT, MATERIALS, PRODUCTS (INCLUDING SOFTWARE) AND OTHER SERVICES INCLUDED ON OR OTHERWISE MADE AVAILABLE TO YOU THROUGH THE WEBSITE SERVICES ARE PROVIDED BY BIKAJI ON AN "AS IS" AND "AS AVAILABLE" BASIS, UNLESS OTHERWISE SPECIFIED IN WRITING. BIKAJI MAKES NO REPRESENTATIONS OR WARRANTIES OF ANY KIND, EXPRESS OR IMPLIED, AS TO THE OPERATION OF THE BIKAJI SERVICES, OR THE INFORMATION, CONTENT, MATERIALS, PRODUCTS (INCLUDING SOFTWARE) OR OTHER SERVICES INCLUDED ON OR OTHERWISE MADE AVAILABLE TO YOU THROUGH THE BIKAJI SERVICES, UNLESS OTHERWISE SPECIFIED IN WRITING. YOU EXPRESSLY AGREE THAT YOUR USE OF THE BIKAJI SERVICES IS AT YOUR SOLE RISK.\nTO THE FULL EXTENT PERMISSIBLE BY APPLICABLE LAW, BIKAJI DISCLAIMS ALL WARRANTIES, EXPRESS OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. BIKAJI DOES NOT WARRANT THAT THE BIKAJI SERVICES, INFORMATION, CONTENT, MATERIALS, PRODUCTS (INCLUDING SOFTWARE) OR OTHER SERVICES INCLUDED ON OR OTHERWISE MADE AVAILABLE TO YOU THROUGH THE BIKAJI SERVICES, BIKAJI SERVERS OR ELECTRONIC COMMUNICATIONS SENT FROM BIKAJI ARE FREE OF VIRUSES OR OTHER HARMFUL COMPONENTS. BIKAJI WILL NOT BE LIABLE FOR ANY DAMAGES OF ANY KIND ARISING FROM THE USE OF ANY BIKAJI SERVICE, OR FROM ANY INFORMATION, CONTENT, MATERIALS, PRODUCTS (INCLUDING SOFTWARE) OR OTHER SERVICES INCLUDED ON OR OTHERWISE MADE AVAILABLE TO YOU THROUGH ANY BIKAJI SERVICE, INCLUDING, BUT NOT LIMITED TO DIRECT, INDIRECT, INCIDENTAL, PUNITIVE, AND CONSEQUENTIAL DAMAGES, UNLESS OTHERWISE SPECIFIED IN WRITING.'))   ;

    list.add(CategoryContent(title: 'DISPUTES :',
    content: 'Any dispute or claim relating in any way to your use of any BIKAJI Products / Service, or to any products or services sold or distributed by BIKAJI or through www.bikajionline.com will be subject to exclusive jurisdiction of court of Bikaner.\nWe each agree that any dispute resolution proceedings will be conducted only on an individual basis and not in a class, consolidated or representative action.'))   ;

    list.add(CategoryContent(title: 'Minimum order :',
    content: 'Any order of 220 Rs and above will be accepted only. It is inclusive of all taxes and packaging. We Currently ship products free of charge, but on COD method, cash handling charges of Rs. 35/- per order are charged in addition to the product value.\nShipping Policy\Currently we do not charge anything for Shipping. Its free !!\nDelivery Schedule :\n* Within City - 3 to 4 Working days.\n* Within Zone - 4 to 5 Working days.\n* Within Metro cities - 5 to 6 Working days.\n* Tier 1, 2 ,3 cities - 6 to 7 Working days.\n* Special destinations - 8 to 9 Working days\n* For Liquid items - 9 to 10 working days.'))   ;

    list.add(CategoryContent(title: 'PAYMENTS :',
    content: "We support the following payment options at bikajionline.com:\n1. Credit Card\n2. Debit Card\n3. Net banking\n4. Cash-On-Delivery (Rs. 35 applicable on every order)\n\nThere are no hidden charges. You pay only the amount that you see in your order summary at the time of check out.\nIf you see any charges on your credit/debit card for purchases made but you have never created an account or signed up, please check with your family members or business colleagues authorized to make purchases on your behalf. If you're still unable to recognize the charge, please report the unauthorized purchase within 30 days of the transaction so that we can look into it. Please email us at bikajionline@gmail.com\nIn case of a payment failure, please retry ensuring: Information passed on to payment gateway is accurate i.e. account details, billing address, password (for net banking), etc. Kindly also check if your Internet connection has been disrupted in the process.\nIf your account has been debited after a payment failure, it is normally rolled back to your account within 7 business days. You can email us on bikajionline@gmail.com with your order number for any clarification."))   ;

    // terms and  conditio
    return list;
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        height: double.maxFinite,
        child: (isLoading)?
        Center(child:CircularProgressIndicator())
        :(data == null)?
        HomeErrorWidget(message: SOMETHING_WRONG_TEXT,onRetryCliked: (){
          _getPolicies();
        },)
        :Container(
          child: SingleChildScrollView(child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 15,vertical: 15),
            child: HtmlWidget(data))),
        )
      ),
    );
    // AnimatedContainer(
    //   duration: Duration(milliseconds: 800),
    //   color: Colors.grey.shade100,
    //   child: ListView.builder(
    //     itemCount: list.length,
    //     itemBuilder: (context,index){
    //       return CustomRow(list[index],(){
    //         setState(() {
    //           if(selectedIndex == index){
    //             selectedIndex = -1;
    //           }else{
    //             this.selectedIndex=index; 
    //           }
              
    //         });
    //       },index,selectedIndex);
    //     },
    //   ),
    // );
  }
}

class CustomRow extends StatefulWidget {

  CategoryContent data;
  Function onTitleClick;
  var index;
  var selectedIndex;
  CustomRow(this.data,this.onTitleClick,this.index,this.selectedIndex);
  @override
  _CustomRowState createState() => _CustomRowState();
}

class _CustomRowState extends State<CustomRow> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child:  Column(
        children: <Widget>[
          Container(
            color: white,
            child: Column(
                children: <Widget>[
                  InkWell(
                    onTap: widget.onTitleClick,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Expanded(child: Text(widget.data.title,style: TextStyle(fontSize: 12,color: blackGrey,fontWeight: FontWeight.w600),textAlign: TextAlign.start,)),
                        ],
                      ),
                    ),
                  ),
                // (widget.selectedIndex == widget.index)? 
                 Container(height: 1,color: Colors.grey.shade200,),
                 //:Container(),
                 // (widget.selectedIndex == widget.index)? 
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 8),
                    child: Text(widget.data.content,style: TextStyle(fontSize: 11,color: Colors.grey.shade600,fontWeight: FontWeight.w600,height: 1.5),),
                  )
                  //:Container(),
              ],
            ),
          ),
          SizedBox(height: 8,)
        ],
      ),
    );
  }
}
enum PolicyTag{
  TERMS,
  PRIVACY,
  CANCELLED_REFUND,
  SHIPPING,
  QUALITY
}