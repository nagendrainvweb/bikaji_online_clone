import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import 'package:bikaji/model/store.dart';
import 'package:bikaji/util/textStyle.dart';
import 'package:bikaji/util/utility.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class Stores extends StatefulWidget {
  @override
  _StoresState createState() => _StoresState();
}

class _StoresState extends State<Stores> {
  int _user;
  var cities = <String>[
    'Mumbai',
    'Mumbai',
    'Mumbai',
    'Mumbai',
    'Mumbai',
    'Mumbai' 'Delhi',
    'Pune',
    'Banglaore',
    'Gujrat'
  ];
  var locality = <StoreData>[];

  AutoCompleteTextField searchTextFeild;
  GlobalKey<AutoCompleteTextFieldState> key = GlobalKey();
  var location = 'All';

  @override
  void initState() {
    setCities();
    super.initState();
  }

  setCities(){
    //StoreData(
    // '1','Eastern Express Highway','Next to jupiter Hospital Thane(W) 400606 Mumbai','+91 4353335351','MON-FRI','11:00am - 7:00pm')
    locality.add(StoreData(
        id: '1',
        name: 'MANISH TRADING CO.',
        address: 'HB Road, Fancy Bazar',
        contact: ' : +91 9954400771',
        type: 'Retail',
        ownerName: 'Mr. Manish',
        location: 'ASSAM'));
    locality.add(StoreData(
        id: '2',
        name: 'KK TRADING',
        address: 'Singh Palace, Maruf Ganj, Patna City, Bihar 800008',
        contact: ' : +91 9801220000',
        type: 'Retail',
        ownerName: 'Mr. Harsh',
        location: 'BIHAR'));
    locality.add(StoreData(
        id: '3',
        name: 'SHREE BIKANER ENTERPRISES',
        address: '1439, Gali Arya Samaj, Sita Ram Bazar, Delhi-110006',
        contact: ' : +91 8826493593',
        type: 'Retail',
        ownerName: 'Mr. Rajender K Aggarwal',
        location: 'DELHI'));
    locality.add(StoreData(
        id: '4',
        name: 'VIRAT AGENCIES',
        address:
            'L1 India 909, Ground Floor, Bandh Road, Sangam Vihar Delhi - 62',
        contact: ' : +91 9599100347',
        type: 'Retail',
        ownerName: 'Mr. Pankaj Chhimpa',
        location: 'DELHI'));
    locality.add(StoreData(
        id: '5',
        name: 'KARNEE ENTERPRISES',
        address: 'Near Kalupura Railway Station,Ahemdabad',
        contact: ' : +91 9825041851',
        type: 'Retail',
        ownerName: 'Mr. Babulal-G',
        location: 'GUJARAT'));
    locality.add(StoreData(
        id: '6',
        name: 'JP SALES CORPORATION',
        address:
            'E-47/48 Laxmi Narayan Society,Brc Compound Near Laxmi Tempal Udhna,Surat.',
        contact: ' : +91 9726071597',
        type: 'Retail',
        ownerName: 'Mr. Pavan Saraf',
        location: 'GUJARAT'));
    locality.add(StoreData(
        id: '7',
        name: 'M/S RAS SAGAR SWEET HOUSE',
        address: 'Sagar Shopping Centre, Sahara Darwaja, Ring Road, Surat.',
        contact: ' : +91 9824143367',
        type: 'Retail',
        ownerName: 'Mr. Gopal Aggarwal',
        location: 'GUJARAT'));
    // locality.add(StoreData(
    //     id: '8',
    //     name: 'RAS SAGAR 2 SWEET HOUSE',
    //     address: 'Sagar Shopping Centre, Sahara Darwaja, Ring Road, Surat.',
    //     contact: ' : +91 9824143367',
    //     type: 'Retail',
    //     ownerName: 'Mr. Gopal Aggarwal',
    //     location: 'GUJARAT'));
    locality.add(StoreData(
        id: '9',
        name: 'DEV MARKETING',
        address: 'Baba Harish Chandra Marg, Ridhi Sidhi Complex,Jaipur.',
        contact: ' : +91 9529758051',
        type: 'Retail',
        ownerName: 'Mr. Pawan',
        location: 'RAJASTHAN'));
    locality.add(StoreData(
        id: '10',
        name: 'SHARMA ENTERPRIS',
        address:
            'Showroom No 1, Shop No.1/348, Near Chawla Sweets, Lane No. 1, Raja Park- 302004.',
        contact: ' : +91 9660803244',
        type: 'Retail',
        ownerName: 'Mr. Himanshu',
        location: 'RAJASTHAN'));
    // locality.add(StoreData(
    //     id: '11',
    //     name: 'BIKAJI FOODS INTERNATIONAL LTD',
    //     address: 'Domestic Airport, Jaipur.',
    //     contact: ' : +91 9636868806',
    //     type: 'Retail',
    //     ownerName: 'Mr. Sumit',
    //     location: 'RAJASTHAN'));
    locality.add(StoreData(
        id: '12',
        name: 'JK ENTERPRISES',
        address:
            '146-H Block, Radhy Shyam Kothi Road, Sriganganagar, Sri Ganganagar-Rajasthan - 335001.',
        contact: ' : (015)42477788',
        type: 'Retail',
        ownerName: 'Mr. Himanshu',
        location: 'RAJASTHAN'));
    locality.add(StoreData(
        id: '13',
        name: 'KALPATRU TRADE CENTER',
        address: 'Outside Jassusar Gate, Bikaner.',
        contact: ' : +91 9024588984',
        type: 'Retail',
        ownerName: 'Mr. Jai Kumar',
        location: 'RAJASTHAN'));
    locality.add(StoreData(
        id: '14',
        name: 'HANNU TRADERS',
        address: 'Ii-E/296, Jnv Colony, Bikaner.',
        contact: ' : +91 8963000811',
        type: 'Retail',
        ownerName: 'Mr. Deepesh Joshi',
        location: 'RAJASTHAN'));
    locality.add(StoreData(
        id: '15',
        name: 'UMA AGENCY',
        address: 'Nathusar Gate, Near Roshani Ghar, Bikaner.',
        contact: ' : +91 9829026128',
        type: 'Retail',
        ownerName: 'Mr. Gopal Ranga',
        location: 'RAJASTHAN'));
    locality.add(StoreData(
        id: '16',
        name: 'JAI BABA KI ICECREAM',
        address: 'Near Rani Bazar Post Office, Rani Bazar, Bikaner - 334001.',
        contact: ' : +91 9828121201',
        type: 'Retail',
        ownerName: 'Mr. Munish Kumar Sood',
        location: 'RAJASTHAN'));
    locality.add(StoreData(
        id: '17',
        name: 'RELISH',
        address: '1 Kha -6, Vigyan Nagar.',
        contact: ' : +91 7728982027',
        type: 'Retail',
        ownerName: 'Mr. Himadri Goyal',
        location: 'RAJASTHAN'));
    locality.add(StoreData(
        id: '18',
        name: 'SWAAD',
        address: 'Near Sophia School, Jaipur Road, Bikaner.',
        contact: ' : +91 9829217460, 8094499999',
        type: 'Retail',
        ownerName: 'Mr. Balkishan',
        location: 'RAJASTHAN'));
    locality.add(StoreData(
        id: '19',
        name: 'OM GANPATI AGENCY',
        address:
            'Shop No.2-3, Bhawani Place, Nanand Bhojai Market, Newaru Road, Jaipur ',
        contact: ' : +91 9314283872',
        type: 'Retail',
        ownerName: 'Mr.  Amar Singh',
        location: 'RAJASTHAN'));
    //
    locality.add(StoreData(
        id: '20',
        name: 'BIKANER NAMKEEN AND SWEETS',
        address: '112/12, Madhyam Marg, Agarwal Farm, Mansarover Jaipur.',
        contact: ' : +91 9414060435',
        type: 'Retail',
        ownerName: 'Mr. Santosh Kumar Harash',
        location: 'RAJASTHAN'));
    locality.add(StoreData(
        id: '21',
        name: 'MASTKIN FOODS PVT LTD (KOTEGATE)',
        address: 'Station Road, Bikaner.',
        contact: ' : +91 8209191393',
        type: 'Retail',
        ownerName: 'Mr. Deshbandhu Gupta',
        location: 'RAJASTHAN'));
    locality.add(StoreData(
        id: '22',
        name: 'KR AGENCIES',
        address: 'Plot No. 478, 5th B-Road, Sardarpura, Jodhpur, Rajasthan.',
        contact: ' : +91 9414133751',
        type: 'Retail',
        ownerName: 'Mr. Khandelwal G',
        location: 'RAJASTHAN'));
    locality.add(StoreData(
        id: '23',
        name: 'SHYAM VARIETY STORE',
        address: 'Durga Mandir Road, Hanumangarh.',
        contact: ' : +91 9414095056',
        type: 'Retail',
        ownerName: 'Mr. Shyam Agarwal',
        location: 'RAJASTHAN'));
    locality.add(StoreData(
        id: '24',
        name: 'KAMLA AGENCIES',
        address: '163/39, Industrial Area, Parbatpura, Ajmer.',
        contact: ' : +91 7737106936',
        type: 'Retail',
        ownerName: 'Mr. Sumit Thakuria',
        location: 'RAJASTHAN'));
    //
    locality.add(StoreData(
        id: '25',
        name: 'JAI BHAWANI MARKETING',
        address: 'Front Of Shri Gopal Gaushala, Station Road, Osian, Jodhpur.',
        contact: ' : +91 9950247415',
        type: 'Retail',
        ownerName: 'Mr. Prabhu Singh',
        location: 'RAJASTHAN'));
    locality.add(StoreData(
        id: '26',
        name: 'DINESH AGENCIES (RAJSHREE)',
        address: 'Main Jaipur-Delhi Road, Nh-8, Vill- Chandwaji, Jaipur. ',
        contact: ' : +91 8619148515',
        type: 'Retail',
        ownerName: 'Mr. Aditiya',
        location: 'RAJASTHAN'));
    locality.add(StoreData(
        id: '27',
        name: 'RAYAL ENTERPRISES',
        address: 'Nh-52, Vpo Rashidpura, Teh-Dhod, Dist-Sikar.',
        contact: ' : +91 9414835488',
        type: 'Retail + Depo',
        ownerName: 'Mr. Gaurdhan Singh',
        location: 'RAJASTHAN'));
    locality.add(StoreData(
        id: '28',
        name: 'NARAYAN SWEETS',
        address: 'Gumanpura Choraya, Rawat Bhata Road, Kota.',
        contact: ' : +91 9414286645',
        type: ' Retail + Depo',
        ownerName: 'Mr. Kamal G',
        location: 'RAJASTHAN'));
    locality.add(StoreData(
        id: '29',
        name: 'BIKANER FOODS',
        address: '224, 225 - Rt Street, Bengaluru-53.',
        contact: '',
        type: 'Retail + Depo',
        ownerName: 'Mr. Pukhraj Sipani',
        location: 'KARNATAKA'));
  }

  @override
  Widget build(BuildContext context) {

   
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(45),
        child: AppBar(
          title: Text('Stores', style: toolbarStyle),
          backgroundColor: red,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.chevron_left),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          actions: <Widget>[
            PopupMenuButton(
              onSelected: (String value) {
               setState(() {
                 location = value;
               });
              },
              child:Center(child: Container(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text('$location ▼'))),
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                const PopupMenuItem<String>(
                  value: 'All',
                  child: Text('All'),
                ),
                const PopupMenuItem<String>(
                  value: 'ASSAM',
                  child: Text('ASSAM'),
                ),
                const PopupMenuItem<String>(
                  value: 'BIHAR',
                  child: Text('BIHAR'),
                ),
                const PopupMenuItem<String>(
                  value: 'DELHI',
                  child: Text('DELHI'),
                ),
                const PopupMenuItem<String>(
                  value: 'RAJASTHAN',
                  child: Text('RAJASTHAN'),
                ),
                const PopupMenuItem<String>(
                  value: 'KARNATAKA',
                  child: Text('KARNATAKA'),
                ),
              ],
            )
            // FlatButton(
            //   child: Text('All',style: TextStyle(color: white),),
            //   onPressed: (){

            //   },
            // )
          ],
        ),
      ),
      body: Container(
        color: Colors.grey.shade100,
        child: Column(
          children: <Widget>[
            //_getAutoCompleteStore,
            Expanded(
                child: ListView.builder(
              itemCount: locality.length,
              itemBuilder: (context, index) {
                if(location == 'All' || location == locality[index].location){
                   return storeRow(index);
                }else{
                    return Container();
                }
               
              },
            ))
          ],
        ),
      ),
    );
  }

  storeRow(index) {
    StoreData store = locality[index];
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _getMainContent(store),
          Container(
            height: 1,
            color: grey,
          )
        ],
      ),
    );
  }

  _getMainContent(StoreData store) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 20, 5, 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(store.name,
                    style: TextStyle(
                        fontSize: 15, color: red, fontWeight: FontWeight.w600)),
                SizedBox(
                  height: 8,
                ),
                Text(
                  store.address,
                  style: smallTextStyle,
                ),
                SizedBox(
                  height: 5,
                ),
                Text('Store Type :  ' + store.type,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade800,
                    )),
                SizedBox(
                  height: 14,
                ),
                Text(store.ownerName + store.contact,
                    style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          SizedBox(
            width: 5,
          ),
          MaterialButton(
            child: Text(
              store.location,
              style: TextStyle(color: Colors.grey[800], fontSize: 12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 8),
            onPressed: () {
              // var lat = 19.161810;
              // var lon = 72.857590;
              // _launchMapsUrl(lat, lon);
            },
          ),
        ],
      ),
    );
  }

  void _launchMapsUrl(double lat, double lon) async {
    final url = 'https://www.google.com/maps/search/?api=1&query=$lat,$lon';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  get _getAutoCompleteStore {
    searchTextFeild = AutoCompleteTextField(
      key: key,
      suggestions: cities,
      clearOnSubmit: false,
      style: TextStyle(color: blackGrey, fontSize: 14),
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.fromLTRB(10.0, 15.0, 10, 15),
        hintText: "Enter City/Locality",
        hintStyle: TextStyle(color: Colors.grey.shade600),
        border: UnderlineInputBorder(
            borderSide: BorderSide(color: textGrey, width: 0.5)),
        enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: textGrey, width: 0.5)),
        focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: red, width: 0.5)),
        focusedErrorBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: red, width: 0.7)),
      ),
      itemFilter: (item, query) {
        return item.toString().toLowerCase().startsWith(query.toLowerCase());
      },
      itemSorter: (a, b) {
        return a.toString().compareTo(b);
      },
      itemSubmitted: (item) {
        setState(() {
          searchTextFeild.textField.controller.text = item;
        });
      },
      itemBuilder: (context, item) {
        // ui for the autoComplete row
        return customRow(item);
      },
    );

    return Container(
        margin: const EdgeInsets.symmetric(horizontal: 5),
        color: Colors.grey.shade200,
        child: searchTextFeild);
  }

  Widget customRow(item) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
      child: Text(
        item,
        style: TextStyle(fontSize: 14),
      ),
    );
  }
}
