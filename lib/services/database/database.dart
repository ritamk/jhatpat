import 'package:dio/dio.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:jhatpat/models/driver_model.dart';
import 'package:jhatpat/models/user_model.dart';

// ignore: constant_identifier_names
const String API_KEY = "AIzaSyAVveVNAsAKcU6lX9p53j6YBzCKrfoo_gk";

class DatabaseService {
  DatabaseService({this.token});
  final String? token;

  final String _sthWentWrong = "Something went wrong, please try again";

  final String _baseUrl = "https://dev.jhatpat.app/api/user/";

  final String _postLogRegUrl = "login_register";
  final String _postOtpVerification = "verifyOtp";
  final String _getResendOtp = "resendOtp";
  final String _postUpdateUserDetails = "updateUserDetails";
  final String _postGetUserDetails = "getUserProfileDetails";
  final String _postDriversList = "driversList";
  final String _getSubscriptionList = "subscriptionList";
  final String _postSubInit = "subscription_initiate";
  final String _postUpdateSubStatus = "update_subscription_status";
  final String _postCityId = "cityId";
  final String _postBookingPrices = "booking_prices";
  final String _postBookingInit = "booking_initiate";
  final String _postFindDriver = "findDriver";
  final String _postAllCoupon = "allCoupon";
  final String _postApplyCoupon = "applyCoupon";
  final String _postBookingStatus = "bookingStatus";
  final String _postPaymentInit = "paymentInitiate";
  final String _postUpdatePaymentStatus = "updatePaymentStatus";
  final String _postBookingHistory = "bookingHistory";
  final String _getSupportNum = "support";

  var dio = Dio();

  Future<UserLoginRegData?> postLoginRegister({String? phNum}) async {
    try {
      Response response = await dio.post(
        _baseUrl + _postLogRegUrl,
        data: {
          "phone_no": phNum!,
          "type": "1",
        },
      );
      print(response.data);
      final Map<String, dynamic> decodedResponse = response.data;
      if (decodedResponse["success"] == "1") {
        return UserLoginRegData(
          phone: decodedResponse["data"]["phone"],
          token: decodedResponse["data"]["token"],
        );
      } else {
        throw decodedResponse["message"];
      }
    } catch (e) {
      print("postLoginRegister: ${e.toString()}");
      throw e.toString();
    }
  }

  Future<bool> postVerifyOtp(String otp, String id) async {
    try {
      Response response = await dio.post(
        _baseUrl + _postOtpVerification,
        options: Options(headers: {
          "user-token": token,
        }),
        data: {
          "otp": otp,
          "deviceId": id,
        },
      );
      print(response.data);
      final Map<String, dynamic> decodedResponse = response.data;
      if (decodedResponse["success"] == "1") {
        return true;
      } else {
        throw decodedResponse["message"];
      }
    } catch (e) {
      print("postVerifyOtp: ${e.toString()}");
      throw e.toString();
    }
  }

  Future<bool> postResendOtp() async {
    try {
      Response response = await dio.post(
        _baseUrl + _getResendOtp,
        options: Options(headers: {
          "user-token": token,
        }),
      );
      print(response.data);
      final Map<String, dynamic> decodedResponse = response.data;
      if (decodedResponse["success"] == "1") {
        return true;
      } else {
        throw decodedResponse["message"];
      }
    } catch (e) {
      print("postResendOtp: ${e.toString()}");
      throw e.toString();
    }
  }

  Future<UserProfileData?> getProfileDetails() async {
    try {
      Response response = await dio.post(
        _baseUrl + _postGetUserDetails,
        options: Options(headers: {
          "user-token": token!,
        }),
      );
      print(response.data);
      final Map<String, dynamic> decodedResponse = response.data;
      if (decodedResponse["success"] == "1") {
        return UserProfileData(
          id: decodedResponse["data"]["User_Profile_Details"]["id"].toString(),
          phone: decodedResponse["data"]["User_Profile_Details"]["user_phone"],
          name: decodedResponse["data"]["User_Profile_Details"]["user_name"],
          email: decodedResponse["data"]["User_Profile_Details"]["user_email"],
          token: decodedResponse["data"]["User_Profile_Details"]["user_token"],
          image: decodedResponse["data"]["User_Profile_Details"]["user_image"]
              .toString(),
          accNum: decodedResponse["data"]["User_Profile_Details"]["account_no"],
          ifsc: decodedResponse["data"]["User_Profile_Details"]["ifsc"],
          branch: decodedResponse["data"]["User_Profile_Details"]["branch"],
          lat: decodedResponse["data"]["User_Profile_Details"]["lat"],
          lng: decodedResponse["data"]["User_Profile_Details"]["lng"],
          nameOnAcc: decodedResponse["data"]["User_Profile_Details"]
              ["name_on_account"],
          bankName: decodedResponse["data"]["User_Profile_Details"]
              ["bank_name"],
          subStatusId: decodedResponse["data"]["User_Profile_Details"]
              ["user_sub_status_id"],
          deviceId: decodedResponse["data"]["User_Profile_Details"]
              ["user_device_id"],
          created: decodedResponse["data"]["User_Profile_Details"]
              ["created_at"],
          modified: decodedResponse["data"]["User_Profile_Details"]
              ["updated_at"],
        );
      } else {
        throw decodedResponse["message"];
      }
    } catch (e) {
      print("getProfileDetails: ${e.toString()}");
      throw e.toString();
    }
  }

  Future<bool> postUserDetails(UserProfileData data) async {
    try {
      Response response = await dio.post(
        _baseUrl + _postUpdateUserDetails,
        options: Options(headers: {
          "user-token": token!,
        }),
        data: {
          "user_name": data.name,
          "user_email": data.email,
          "bank_name": data.bankName,
          "name_on_account": data.nameOnAcc,
          "account_no": data.accNum,
          "ifsc": data.ifsc,
          "branch_name": data.branch,
          "user_device_id": data.deviceId,
        },
      );
      print(response.data);
      final Map<String, dynamic> decodedResponse = response.data;
      if (decodedResponse["success"] == "1") {
        return true;
      } else {
        throw decodedResponse["message"];
      }
    } catch (e) {
      print("postUserDetails: ${e.toString()}");
      throw e.toString();
    }
  }

  Future<bool> postUserImage(String img) async {
    try {
      Response response = await dio.post(
        _baseUrl + _postUpdateUserDetails,
        options: Options(headers: {
          "user-token": token!,
        }),
        data: {
          "user_image": img,
        },
      );
      print(response.data);
      final Map<String, dynamic> decodedResponse = response.data;
      if (decodedResponse["success"] == "1") {
        return true;
      } else {
        throw decodedResponse["message"];
      }
    } catch (e) {
      print("postUserImage: ${e.toString()}");
      throw e.toString();
    }
  }

  Future<List<DriverListModel>?> postDriversList(LatLng latLng) async {
    try {
      Response response = await dio.post(
        _baseUrl + _postDriversList,
        data: {
          "lat": latLng.latitude,
          "lng": latLng.longitude,
        },
      );
      print(response.data);
      final Map<String, dynamic> decodedResponse = response.data;
      if (decodedResponse["success"] == "1") {
        final List<dynamic> list = decodedResponse["data"];
        return list
            .map((e) => DriverListModel(
                  lat: e["current_latitude"],
                  lng: e["current_longitude"],
                  dist: e["distance"].toString(),
                ))
            .toList();
      } else {
        throw decodedResponse["message"];
      }
    } catch (e) {
      print("postDriversList: ${e.toString()}");
      throw e.toString();
    }
  }

  Future<List<SubscriptionList>?> getSubscriptionsList() async {
    try {
      Response response = await dio.get(
        _baseUrl + _getSubscriptionList,
      );
      print(response.data);
      final Map<String, dynamic> decodedResponse = response.data;
      if (decodedResponse["success"] == "1") {
        final List<dynamic> list = decodedResponse["data"];
        return list
            .map((e) => SubscriptionList(
                  id: e["id"],
                  name: e["subscription_name"],
                  fees: e["fees"],
                  validity: e["plan_valid_for"],
                  bookFees: e["booking_fees"],
                  freeBookings: e["no_of_free_booking_fees"].toString(),
                  freeBookingsValidity: e["no_of_free_booking_valid_for"],
                ))
            .toList();
      } else {
        throw decodedResponse["message"];
      }
    } catch (e) {
      print("getSubscriptionsList: ${e.toString()}");
      throw e.toString();
    }
  }

  Future<PaymentModel?> postSubscriptionInit(String id) async {
    try {
      Response response = await dio.post(
        _baseUrl + _postSubInit,
        options: Options(headers: {
          "user-token": token!,
        }),
        data: {
          "subscription_id": id,
        },
      );
      print(response.data);
      final Map<String, dynamic> decodedResponse = response.data;
      if (decodedResponse["body"]["resultInfo"]["resultStatus"] == "S") {
        return PaymentModel(
          signature: decodedResponse["head"]["signature"],
          txnToken: decodedResponse["body"]["txnToken"],
          orderId: decodedResponse["orderId"],
        );
      } else {
        throw _sthWentWrong;
      }
    } catch (e) {
      print("postSubscriptionInit: ${e.toString()}");
      throw e.toString();
    }
  }

  Future<bool> postUpdateSubStatus(PaymentStatus status) async {
    try {
      Response response = await dio.post(
        _baseUrl + _postUpdateSubStatus,
        options: Options(headers: {
          "user-token": token!,
        }),
        data: {
          "RESPMSG": status.RESPMSG,
          "CURRENCY": status.CURRENCY,
          "TXNID": status.TXNID,
          "ORDERID": status.ORDERID,
          "CHECKSUMHASH": status.CHECKSUMHASH,
          "TXNDATE": status.TXNDATE,
          "TXNAMOUNT": status.TXNAMOUNT,
          "PAYMENTMODE": status.PAYMENTMODE,
          "BANKNAME": status.BANKNAME,
          "RESPCODE": status.RESPCODE,
          "STATUS": status.STATUS,
          "BANKTXNID": status.BANKTXNID,
          "GATEWAYNAME": status.GATEWAYNAME,
          "MID": status.MID,
        },
      );
      print(response.data);
      final Map<String, dynamic> decodedResponse = response.data;
      if (decodedResponse["success"] == "1") {
        return true;
      } else {
        throw decodedResponse["message"];
      }
    } catch (e) {
      print("postUpdateSubStatus: ${e.toString()}");
      throw e.toString();
    }
  }

  Future<int> postCityId(LatLng latLng) async {
    try {
      Response response = await dio.post(
        _baseUrl + _postCityId,
        data: {
          "lat": latLng.latitude,
          "lng": latLng.longitude,
        },
      );
      print(response.data);
      final Map<String, dynamic> decodedResponse = response.data;
      if (decodedResponse["success"] == "1") {
        return decodedResponse["data"]["id"];
      } else {
        throw decodedResponse["message"];
      }
    } catch (e) {
      print("postCityId: ${e.toString()}");
      throw e.toString();
    }
  }

  Future<List<BookingPrices>?> postBookingPriceList(
      String cityId, String dist) async {
    try {
      Response response = await dio.post(
        _baseUrl + _postBookingPrices,
        options: Options(headers: {
          "user-token": token!,
        }),
        data: {
          "city_id": cityId,
          "distance": dist,
        },
      );
      print(response.data);
      final Map<String, dynamic> decodedResponse = response.data;
      if (decodedResponse["success"] == "1") {
        final List<dynamic> list = decodedResponse["data"];
        return list
            .map((e) => BookingPrices(
                  cityId: e["city_id"].toString(),
                  carId: e["car_id"].toString(),
                  carType: e["car_type"],
                  passengerNo: e["passenger_no"].toString(),
                  approxPrice: e["aprox_price"].toString(),
                ))
            .toList();
      } else {
        throw decodedResponse["message"];
      }
    } catch (e) {
      print("postBookingPriceList: ${e.toString()}");
      throw e.toString();
    }
  }

  Future<BookingDetails?> postBookingInitiate(BookingDetails details) async {
    try {
      Response response = await dio.post(_baseUrl + _postBookingInit,
          options: Options(headers: {
            "user-token": token!,
          }),
          data: {
            "car_id": details.carId,
            "city_id": details.cityId,
            "pickup_address": details.pickupAdd,
            "pickup_lat": details.pickupLat,
            "pickup_long": details.pickupLng,
            "drop_address": details.dropAdd,
            "drop_lat": details.dropLat,
            "drop_long": details.dropLng,
            "distance": details.dist,
            "estimated_time": details.estTime,
            "estimated_amount": details.estAmount,
            "pay_type": details.payType,
          }); /*
          data: {
            "car_id": "1",
            "city_id": "1",
            "pickup_address": "Kolkata",
            "pickup_lat": "23.1492493",
            "pickup_long": "88.1670727",
            "drop_address": "Nagar",
            "drop_lat": "23.1492493",
            "drop_long": "88.1670727",
            "distance": "0.9",
            "estimated_time": "00:05:00",
            "estimated_amount": "100.0",
          });*/
      print(response.data);
      final Map<String, dynamic> decodedResponse = response.data;
      if (decodedResponse["success"] == "1") {
        return BookingDetails(
          bookingId: decodedResponse["data"]["bookingDetails"]["booking_id"]
              .toString(),
          bookingCode: decodedResponse["data"]["bookingDetails"]["booking_code"]
              .toString(),
        );
      } else {
        throw decodedResponse["message"];
      }
    } catch (e) {
      print("postBookingInitiate: ${e.toString()}");
      throw e.toString();
    }
  }

  Future<RideDetail?> postFindDriver(String bookId) async {
    try {
      Response response = await dio.post(
        _baseUrl + _postFindDriver,
        options: Options(headers: {
          "user-token": token!,
        }),
        data: {
          "booking_id": bookId,
        },
      );
      print(response.data);
      final Map<String, dynamic> decodedResponse = response.data;
      if (decodedResponse["success"] == "1") {
        return RideDetail(
          bookingId: decodedResponse["data"]["bookingDetails"]["booking_id"]
              .toString(),
          bookingCode: decodedResponse["data"]["bookingDetails"]
              ["booking_code"],
          cityId:
              decodedResponse["data"]["bookingDetails"]["city_id"].toString(),
          carId: decodedResponse["data"]["bookingDetails"]["car_id"].toString(),
          pickupAdd: decodedResponse["data"]["bookingDetails"]
              ["pickup_address"],
          pickupLat: decodedResponse["data"]["bookingDetails"]["pickup_lat"],
          pickupLng: decodedResponse["data"]["bookingDetails"]["pickup_long"],
          dropAdd: decodedResponse["data"]["bookingDetails"]["drop_address"],
          dropLat: decodedResponse["data"]["bookingDetails"]["drop_lat"],
          dropLng: decodedResponse["data"]["bookingDetails"]["drop_long"],
          dist:
              decodedResponse["data"]["bookingDetails"]["distance"].toString(),
          estTime: decodedResponse["data"]["bookingDetails"]["est_time"],
          estAmount: decodedResponse["data"]["bookingDetails"]["est_amount"]
              .toString(),
          status: decodedResponse["data"]["bookingDetails"]["status"],
          driverId:
              decodedResponse["data"]["driverDetails"]["driver_id"].toString(),
          driverName: decodedResponse["data"]["driverDetails"]["driver_name"],
          driverImg: decodedResponse["data"]["driverDetails"]["driver_image"],
          driverPhone: decodedResponse["data"]["driverDetails"]["driver_phone"],
          carImg: decodedResponse["data"]["driverDetails"]["car_image"],
          carNum: decodedResponse["data"]["driverDetails"]["car_no"].toString(),
          otp: decodedResponse["data"]["bookingDetails"]["otp"].toString(),
        );
      } else {
        throw decodedResponse["message"];
      }
    } catch (e) {
      print("postFindDriver: ${e.toString()}");
      throw e.toString();
    }
  }

  Future<List<CouponsModel>?> postAllCouponsList(
      String? amount, String? payType) async {
    try {
      Response? response;
      if (amount != null) {
        response = await dio.post(
          _baseUrl + _postAllCoupon,
          data: {
            "final_amount": amount,
            "pay_type": payType,
          },
        );
      } else {
        response = await dio.post(
          _baseUrl + _postAllCoupon,
        );
      }
      print(response.data);
      final Map<String, dynamic> decodedResponse = response.data;
      if (decodedResponse["success"] == "1") {
        final List<dynamic> list = decodedResponse["data"];
        return list
            .map((e) => CouponsModel(
                  id: e["id"].toString(),
                  code: e["coupon_code"],
                  details: e["details"],
                  payType: e["pay_type"],
                  minAmount: e["min_amount"].toString(),
                  discType: e["discount_type"],
                  discValue: e["discount_value"].toString(),
                ))
            .toList();
      } else {
        throw decodedResponse["message"];
      }
    } catch (e) {
      print("postAllCouponsList: ${e.toString()}");
      throw e.toString();
    }
  }

  Future<List<BookingDetails>?> postBookingHistory() async {
    try {
      Response response = await dio.post(_baseUrl + _postBookingHistory,
          options: Options(headers: {
            "user-token": token,
          }));
      print(response.data);
      final Map<String, dynamic> decodedResponse = response.data;
      if (decodedResponse["success"] == "1") {
        final List<dynamic> list = decodedResponse["data"];
        return list
            .map((e) => BookingDetails(
                  bookingId: e["id"].toString(),
                  carId: e["car_id"].toString(),
                  cityId: e["city_id"].toString(),
                  bookingCode: e["booking_code"],
                  bookingDate: e["booking_date"],
                  pickupAdd: e["pickup_address"],
                  pickupLat: e["pickup_lat"],
                  pickupLng: e["pickup_long"],
                  dropAdd: e["drop_address"],
                  dropLat: e["drop_lat"],
                  dropLng: e["drop_long"],
                  dist: e["distance"].toString(),
                  finalTime: e["final_time"],
                  extraTime: e["extra_time"],
                  extraAmount: e["extra_fees"].toString(),
                  convenienceFee: e["convenience_fees"].toString(),
                  finalDistFee: e["final_distance_fees"].toString(),
                  payType: e["pay_type"],
                  couponCode: e["coupon_code"],
                  disc: e["discount"].toString(),
                  payableAmount: e["payble_amount"].toString(),
                  status: e["status"],
                ))
            .toList();
      } else {
        throw decodedResponse["message"];
      }
    } catch (e) {
      print("postBookingHistory: ${e.toString()}");
      throw e.toString();
    }
  }

  Future<BookingDetails> postBookingStatus() async {
    try {
      Response response = await dio.post(_baseUrl + _postBookingStatus,
          options: Options(headers: {
            "user-token": token!,
          }));
      print(response.data);
      final Map<String, dynamic> decodedResponse = response.data;
      if (decodedResponse["success"] == "1") {
        return BookingDetails(
          bookingId: decodedResponse["data"]["bookingDetails"]["booking_id"]
              .toString(),
          carId: decodedResponse["data"]["bookingDetails"]["car_id"].toString(),
          cityId:
              decodedResponse["data"]["bookingDetails"]["city_id"].toString(),
          bookingCode: decodedResponse["data"]["bookingDetails"]
              ["booking_code"],
          pickupAdd: decodedResponse["data"]["bookingDetails"]
              ["pickup_address"],
          pickupLat: decodedResponse["data"]["bookingDetails"]["pickup_lat"],
          pickupLng: decodedResponse["data"]["bookingDetails"]["pickup_long"],
          dropAdd: decodedResponse["data"]["bookingDetails"]["drop_address"],
          dropLat: decodedResponse["data"]["bookingDetails"]["drop_lat"],
          dropLng: decodedResponse["data"]["bookingDetails"]["drop_long"],
          dist:
              decodedResponse["data"]["bookingDetails"]["distance"].toString(),
          finalTime: decodedResponse["data"]["bookingDetails"]["final_time"],
          extraTime: decodedResponse["data"]["bookingDetails"]["extra_time"],
          extraAmount: decodedResponse["data"]["bookingDetails"]["extra_fees"]
              .toString(),
          convenienceFee: decodedResponse["data"]["bookingDetails"]
                  ["convenience_fees"]
              .toString(),
          finalDistFee: decodedResponse["data"]["bookingDetails"]
                  ["final_distance_fees"]
              .toString(),
          payType: decodedResponse["data"]["bookingDetails"]["pay_type"],
          payableAmount: decodedResponse["data"]["bookingDetails"]
                  ["payble_amount"]
              .toString(),
          status: decodedResponse["data"]["bookingDetails"]["status"],
          lat: decodedResponse["data"]["driverDetails"]["current_latitude"],
          lng: decodedResponse["data"]["driverDetails"]["current_longitude"],
        );
      } else {
        throw decodedResponse["message"];
      }
    } catch (e) {
      print("postBookingStatus: ${e.toString()}");
      throw e.toString();
    }
  }

  Future<PaymentModel?> postPaymentInit(String bookId) async {
    try {
      Response response = await dio.post(
        _baseUrl + _postPaymentInit,
        options: Options(headers: {
          "user-token": token!,
        }),
        data: {
          "booking_id": bookId,
        },
      );
      print(response.data);
      final Map<String, dynamic> decodedResponse = response.data;
      if (decodedResponse["body"]["resultInfo"]["resultStatus"] == "S") {
        return PaymentModel(
          signature: decodedResponse["head"]["signature"],
          txnToken: decodedResponse["body"]["txnToken"],
          orderId: decodedResponse["orderId"],
        );
      } else {
        throw _sthWentWrong;
      }
    } catch (e) {
      print("postPaymentInit: ${e.toString()}");
      throw e.toString();
    }
  }

  Future<bool> postUpdatePaymentStatus(PaymentStatus status) async {
    try {
      Response response = await dio.post(
        _baseUrl + _postUpdatePaymentStatus,
        options: Options(headers: {
          "user-token": token!,
        }),
        data: {
          "RESPMSG": status.RESPMSG,
          "CURRENCY": status.CURRENCY,
          "TXNID": status.TXNID,
          "ORDERID": status.ORDERID,
          "CHECKSUMHASH": status.CHECKSUMHASH,
          "TXNDATE": status.TXNDATE,
          "TXNAMOUNT": status.TXNAMOUNT,
          "PAYMENTMODE": status.PAYMENTMODE,
          "BANKNAME": status.BANKNAME,
          "RESPCODE": status.RESPCODE,
          "STATUS": status.STATUS,
          "BANKTXNID": status.BANKTXNID,
          "GATEWAYNAME": status.GATEWAYNAME,
          "MID": status.MID,
        },
      );
      print(response.data);
      final Map<String, dynamic> decodedResponse = response.data;
      if (decodedResponse["success"] == "1") {
        return true;
      } else {
        throw decodedResponse["message"];
      }
    } catch (e) {
      print("postUpdatePaymentStatus: ${e.toString()}");
      throw e.toString();
    }
  }

  Future<BookingDetails> postApplyCoupon(String bookId, String couponId) async {
    try {
      Response response = await dio.post(
        _baseUrl + _postApplyCoupon,
        data: {
          "booking_id": bookId,
          "coupon_id": couponId,
        },
      );
      print(response.data);
      final Map<String, dynamic> decodedResponse = response.data;
      if (decodedResponse["success"] == "1") {
        return BookingDetails(
          bookingId: decodedResponse["data"]["bookingDetails"]["booking_id"]
              .toString(),
          bookingCode: decodedResponse["data"]["bookingDetails"]
              ["booking_code"],
          cityId:
              decodedResponse["data"]["bookingDetails"]["city_id"].toString(),
          carId: decodedResponse["data"]["bookingDetails"]["car_id"].toString(),
          pickupAdd: decodedResponse["data"]["bookingDetails"]
              ["pickup_address"],
          pickupLat: decodedResponse["data"]["bookingDetails"]["pickup_lat"],
          pickupLng: decodedResponse["data"]["bookingDetails"]["pickup_long"],
          dropAdd: decodedResponse["data"]["bookingDetails"]["drop_address"],
          dropLat: decodedResponse["data"]["bookingDetails"]["drop_lat"],
          dropLng: decodedResponse["data"]["bookingDetails"]["drop_long"],
          dist:
              decodedResponse["data"]["bookingDetails"]["distance"].toString(),
          estTime: decodedResponse["data"]["bookingDetails"]["est_time"],
          estAmount: decodedResponse["data"]["bookingDetails"]["est_amount"]
              .toString(),
          finalTime: decodedResponse["data"]["bookingDetails"]["final_time"],
          extraTime: decodedResponse["data"]["bookingDetails"]["extra_time"],
          extraAmount: decodedResponse["data"]["bookingDetails"]["extra_fees"]
              .toString(),
          convenienceFee: decodedResponse["data"]["bookingDetails"]
                  ["convenience_fees"]
              .toString(),
          finalDistFee: decodedResponse["data"]["bookingDetails"]
                  ["final_distance_fees"]
              .toString(),
          disc:
              decodedResponse["data"]["bookingDetails"]["discount"].toString(),
          payType: decodedResponse["data"]["bookingDetails"]["pay_type"],
          payableAmount: decodedResponse["data"]["bookingDetails"]
                  ["payble_amount"]
              .toString(),
          status: decodedResponse["data"]["bookingDetails"]["status"],
          couponCode: decodedResponse["data"]["couponDetails"]["coupon_code"],
          couponId:
              decodedResponse["data"]["couponDetails"]["coupon_id"].toString(),
        );
      } else {
        throw decodedResponse["message"];
      }
    } catch (e) {
      print("postApplyCoupon: ${e.toString()}");
      throw e.toString();
    }
  }

  Future<String> getSupportNum() async {
    try {
      Response response = await dio.get(
        _baseUrl + _getSupportNum,
      );
      print(response.data);
      final Map<String, dynamic> decodedResponse = response.data;
      if (decodedResponse["success"] == "1") {
        return decodedResponse["data"]["support_contact"];
      } else {
        throw _sthWentWrong;
      }
    } catch (e) {
      print("getSupportNum: ${e.toString()}");
      throw e.toString();
    }
  }
}
