import 'dart:io';

const STATUS_LOADING = "PAYMENT_LOADING";
const STATUS_SUCESSFUL = "PAYMENT_SUCESSFUL";
const STATUS_PENDING = "STATUS_PENDING";
const STATUS_FAILED = "STATUS_FAILED";
const STATUS_CHECKSUM_FAILED = "STATUS_CHECKSUM_FAILED";

class Constants {
  static final isLogin = "login";
  static final firstName = "first_name";
  static final lastName = "last_name";
  static final mobile_no = "mobile no";
  static final email = "email";
  static final token = "token";
  static final dob = "DOB";
  static final id = "id";
  static final imageUrl = "imageUrl";
  static final state = "state";
  static final city = "city";
  static final fcmToken = "fcm_token";
  static final isOtpVerirified = "isOtpVerirified";
  static final dashboardData = "DashboardData";
  static final categoryData = "CategoryData";
  static final cartData = "cartData";
  static final wishlistData = "WishlistData";
  static final cartCount = "cartCount";
  static final addressResponse = "addressResponse";
  static final offerResponse = "offerResponse";
  static final PAYMENT_SUCESS = "success";
  static final PAYMMENT_FAIED = "failed";
  static final stateList = "state_list";
  static final TIME = "time";

  static final OFFER = "offer";
  static final COUPON = "coupon";

  static final PAYTM_MID = "bikaji42116765280850";
  static final PAYTM_CHANNEL_ID = "WAP";
  static final PAYTM_INDUSTRY_TYPE_ID = "Retail";
  static final PAYTM_WEBSITE = "APPSTAGING";
  static final PAYTM_MERCHANT_KEY = "xOKlrHyzJBtq4LiF";
  static final PAYTM_TXN_AMOUNT = "TXN_AMOUNT";
  static final PAYTM_CUST_ID = "CUST_ID";

  static final AUTH = "authorization";
  static final CHECKSUM = "checksum";
  static final TOKEN = "token";
  static final VERSION_TAG = "appVersion";
  static final DEVICE_TAG = "device";
  static final ANDROID = 'android';
  static final IOS = 'ios';
  static final NOTIFICATION_DATE = "notification_date";
  static final NOTIFICATION_COUNT = "notification_count";

  static final success = "success";
  static final appversion = (Platform.isAndroid) ? androidVersion : iosVersion;

  static final androidVersion = "21"; // android version 2.1.5
  static final iosVersion = "21"; // ios version 2.0.9

}
