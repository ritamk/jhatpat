// ignore_for_file: non_constant_identifier_names

class UserProfileData {
  final String? phone;
  final String? id;
  final String? deviceId;
  final String? token;
  final String? name;
  final String? email;
  final String? image;
  final String? bankName;
  final String? nameOnAcc;
  final String? accNum;
  final String? ifsc;
  final String? branch;
  final String? subStatusId;
  final String? lat;
  final String? lng;
  final String? created;
  final String? modified;

  UserProfileData({
    this.phone,
    this.id,
    this.deviceId,
    this.token,
    this.name,
    this.email,
    this.image,
    this.bankName,
    this.nameOnAcc,
    this.accNum,
    this.ifsc,
    this.branch,
    this.subStatusId,
    this.lat,
    this.lng,
    this.created,
    this.modified,
  });
}

class UserLoginRegData {
  final String phone;
  final String token;
  final String? otp;

  UserLoginRegData({
    required this.phone,
    required this.token,
    this.otp,
  });
}

class UserLocationData {
  final String? phone;
  final String token;
  final String lat;
  final String lon;

  UserLocationData({
    this.phone,
    required this.token,
    required this.lat,
    required this.lon,
  });
}

class SubscriptionList {
  final String? id;
  final String? name;
  final String? fees;
  final String? validity;
  final String? bookFees;
  final String? freeBookings;
  final String? freeBookingsValidity;

  SubscriptionList({
    this.id,
    this.name,
    this.fees,
    this.validity,
    this.bookFees,
    this.freeBookings,
    this.freeBookingsValidity,
  });
}

class PaymentModel {
  final String? signature;
  final String? txnToken;
  final String? orderId;

  PaymentModel({
    this.signature,
    this.txnToken,
    this.orderId,
  });
}

class PaymentStatus {
  final String? RESPMSG;
  final String? CURRENCY;
  final String? TXNID;
  final String? ORDERID;
  final String? CHECKSUMHASH;
  final String? TXNDATE;
  final String? TXNAMOUNT;
  final String? PAYMENTMODE;
  final String? BANKNAME;
  final String? RESPCODE;
  final String? STATUS;
  final String? BANKTXNID;
  final String? GATEWAYNAME;
  final String? MID;

  PaymentStatus({
    this.RESPMSG,
    this.CURRENCY,
    this.TXNID,
    this.ORDERID,
    this.CHECKSUMHASH,
    this.TXNDATE,
    this.TXNAMOUNT,
    this.PAYMENTMODE,
    this.BANKNAME,
    this.RESPCODE,
    this.STATUS,
    this.BANKTXNID,
    this.GATEWAYNAME,
    this.MID,
  });
}

class CouponsModel {
  final String? id;
  final String? code;
  final String? details;
  final String? payType;
  final String? minAmount;
  final String? discType;
  final String? discValue;

  CouponsModel({
    this.id,
    this.code,
    this.details,
    this.payType,
    this.minAmount,
    this.discType,
    this.discValue,
  });
}
