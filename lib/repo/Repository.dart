import 'package:bikaji/model/AccountModal.dart';
import 'package:bikaji/model/AddressData.dart';
import 'package:bikaji/model/BasicResponse.dart';
import 'package:bikaji/model/CategoryData.dart';
import 'package:bikaji/model/DashboardData.dart';
import 'package:bikaji/model/NotificationData.dart';
import 'package:bikaji/model/OfferResponse.dart';
import 'package:bikaji/model/OrderDetailsData.dart';
import 'package:bikaji/model/PastOrderData.dart';
import 'package:bikaji/model/PincodeResponse.dart';
import 'package:bikaji/model/ProductData.dart';
import 'package:bikaji/model/ProductListResponse.dart';
import 'package:bikaji/model/ReviewListResponse.dart';
import 'package:bikaji/model/SearchData.dart';
import 'package:bikaji/model/UserData.dart';
import 'package:bikaji/model/product.dart';
import 'package:bikaji/model/updateCartResponse.dart';
import 'package:bikaji/model/wishlist_response.dart';
import 'package:bikaji/repo/api_provider.dart';

class Repository {  

  final ApiProvider appApiProvider;
  Repository({this.appApiProvider});
  

//   Future<BasicResponse<String>> sendOtp({var number,var otp}) => appApiProvider.sendOtp(number,otp);
//   Future<BasicResponse<String>> fetchUpdate() => appApiProvider.fetchUpdate();
//   Future<BasicResponse<String>> fetchToken(String number) => appApiProvider.fetchToken(number);
//   Future<BasicResponse<User>> fetchUserlogin(String number) => appApiProvider.fetchUserlogin(number);
//   Future<BasicResponse<User>> registerUser({firstName,lastName,mobileNumber,dob,email,password,imagebase64}) => appApiProvider.registerUser(firstName,lastName,mobileNumber,dob,email,password,imagebase64);
//   Future<BasicResponse<DashboardData>> fetchDashboard() => appApiProvider.fetchDashboard();
//   Future<BasicResponse<String>> addToWishlist(String userid, String productId) => appApiProvider.addToWishlist(userid,productId);
//   Future<BasicResponse<List<CategoryData>>> fetchCategoryList(String userid) => appApiProvider.fetchCategoryList(userid);
//   Future<BasicResponse<List<CategoryData>>> fetchSubCategoryList(String categoryId) => appApiProvider.fetchSubCategoryList(categoryId);
//   Future<BasicResponse<WishListResponse>> fetchWishList(var pageNo) => appApiProvider.fetchWishList(pageNo);
//   Future<BasicResponse<String>> addToCart(String productId, var qty, var size) => appApiProvider.addToCart(productId,qty,size);
//   Future<BasicResponse<String>> removeFromWishlist(String userid, String productId) => appApiProvider.removeFromWishlist(userid,productId);
//   Future<BasicResponse<ProductListResponse>> fetchProductList(String userid, var pageNo, var categoryId) => appApiProvider.fetchProductList(userid,pageNo,categoryId);
//     Future<BasicResponse<ProductListResponse>> fetchProductByType(String userid, var pageNo, var type) => appApiProvider.fetchProductByType(userid,pageNo,type);
//   Future<BasicResponse<ProductListResponse>> fetchFilteredProductList(String userid,var pageNo,var category_id,var type,var price1,var price2) => appApiProvider.fetchFilteredProductList(userid,pageNo,category_id,type,price1,price2);
//   Future<BasicResponse<String>> submitReview(String userid, String productId,
//       String rating, String reviewTitle, String review) => appApiProvider.submitReview(userid,productId,rating,reviewTitle,review);
//   Future<BasicResponse<WishListResponse>> fetchAllReviews(String userid, var pageNo, var productId) => appApiProvider.fetchAllReviews(userid,pageNo,productId);
//   Future<BasicResponse<User>> fetchProfileDetails(String userid) => appApiProvider.fetchProfileDetails(userid);
//   Future<BasicResponse<String>> updateProfileDetails({firstName,lastName,mobileNumber,dob,email,password,imagebase64}) => 
//   appApiProvider.updateProfileDetails(firstName,lastName,mobileNumber,dob,email,password,imagebase64);
//   Future<BasicResponse<List<AddressData>>> fetchAddress(String userid) => appApiProvider.fetchAddress(userid);
//   Future<BasicResponse<String>> deleteAddress(var addressId) => appApiProvider.deleteAddress(addressId);
//   Future<BasicResponse<String>> addUpdateAddress(AddressData data)=> appApiProvider.addUpdateAddress(data);
//   Future<BasicResponse<AccountModel>> bulkOrderRequest(String userid, var name,
//       var number, var email_id, var company, var city) => appApiProvider.bulkOrderRequest(userid,name,number,email_id,company,city);
//   Future<BasicResponse<List<SearchData>>> fetchSearchData(var searchText) => appApiProvider.fetchSearchData(searchText);
//   Future<BasicResponse<List<PastOrderData>>> fetchPastOrders() => appApiProvider.fetchPastOrders();
//   Future<BasicResponse<OrderDetailsData>> fetchOrderDetails(var orderId) => appApiProvider.fetchOrderDetails(orderId);
//   Future<BasicResponse<List<Product>>> fetchCartDetails() => appApiProvider.fetchCartDetails();
//   Future<BasicResponse<String>> removeFromCart(var productId,var sizeId) => appApiProvider.removeFromCart(productId,sizeId);
//   Future<BasicResponse<String>> moveFromCartToWishlist(var productId,var sizeId) => appApiProvider.moveFromCartToWishlist(productId,sizeId);
//   Future<BasicResponse<ProductData>> fetchProductDetails(String productId) => appApiProvider.fetchProductDetails(productId);
//   Future<BasicResponse<String>> addReview(var productId,var rating,var reviewTitle,var review) => appApiProvider.addReview(productId,rating,reviewTitle,review);
// Future<BasicResponse<ReviewListResponse>> fetchReview(String productId,String pageNo) => appApiProvider.fetchReview(productId,pageNo);
//   Future<PincodeResponse> fetchPincode(String pincode) => appApiProvider.fetchPincode(pincode);
//   Future<BasicResponse<String>> sendCorporateInquiry(String name,String email,String mobileNo,String company,String city) => appApiProvider.sendCorporateInquiry(name,email,mobileNo,company,city);
//   Future<BasicResponse<OfferResponse>> fetchOffers() => appApiProvider.fetchOffers(); 
//   Future<BasicResponse<List<Offers>>> fetchCoupons() => appApiProvider.fetchCoupons(); 
//   Future<BasicResponse<Offers>> verifyCoupon(String code,String amount) => appApiProvider.verifyCoupons(code,amount); 
//   Future<BasicResponse<UpdateCartResponse>> updateCart(List<Product> cartList,String coupon_title,String total_amount) => appApiProvider.updateCart(cartList,coupon_title,total_amount);
//   Future<BasicResponse<Map<String,dynamic>>> placeOrder(String billing_address_id,String shipping_address_id,String coupon_code,String offer_type ,String discount_amount) => appApiProvider.placeOrder(billing_address_id,shipping_address_id,coupon_code,offer_type,discount_amount);
//   Future<BasicResponse<OrderDetailsData>> updatePayment(String order_id,String transaction_id,String paymentStatus,String payment_amount,String coupon_code) => appApiProvider.updatePayment(order_id,transaction_id,paymentStatus,payment_amount,coupon_code);
//   Future<BasicResponse<String>> sendQuery(name,email,number,desc) => appApiProvider.sendQuery(name,email,number,desc);
//   Future<BasicResponse<List<NotificationData>>> fetchNotifications() => appApiProvider.fetchNotifications();
//   Future<BasicResponse<String>> fetchPolicies(String name) => appApiProvider.fetchPolicies(name);
}
