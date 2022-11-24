class DriverListModel {
  final String? lat;
  final String? lng;
  final String? dist;

  DriverListModel({
    this.lat,
    this.lng,
    this.dist,
  });
}

class BookingPrices {
  final String? cityId;
  final String? carId;
  final String? carType;
  final String? passengerNo;
  final String? approxPrice;

  BookingPrices({
    this.cityId,
    this.carId,
    this.carType,
    this.passengerNo,
    this.approxPrice,
  });
}

class BookingDetails {
  final String? bookingId;
  final String? bookingCode;
  final String? bookingDate;
  final String? pickupAdd;
  final String? pickupLat;
  final String? pickupLng;
  final String? dropAdd;
  final String? dropLat;
  final String? dropLng;
  final String? lat;
  final String? lng;
  final String? dist;
  final String? estTime;
  final String? estAmount;
  final String? status;
  final String? carId;
  final String? cityId;
  final String? payType;
  final String? finalTime;
  final String? extraTime;
  final String? extraAmount;
  final String? convenienceFee;
  final String? finalDistFee;
  final String? couponId;
  final String? couponCode;
  final String? disc;
  final String? payableAmount;

  BookingDetails({
    this.bookingId,
    this.bookingCode,
    this.bookingDate,
    this.pickupAdd,
    this.pickupLat,
    this.pickupLng,
    this.dropAdd,
    this.dropLat,
    this.dropLng,
    this.lat,
    this.lng,
    this.dist,
    this.estTime,
    this.estAmount,
    this.status,
    this.carId,
    this.cityId,
    this.payType,
    this.finalTime,
    this.extraTime,
    this.extraAmount,
    this.convenienceFee,
    this.finalDistFee,
    this.couponId,
    this.couponCode,
    this.disc,
    this.payableAmount,
  });
}

class RideDetail {
  final String? bookingId;
  final String? bookingCode;
  final String? pickupAdd;
  final String? pickupLat;
  final String? pickupLng;
  final String? dropAdd;
  final String? dropLat;
  final String? dropLng;
  final String? dist;
  final String? estTime;

  final String? estAmount;
  final String? status;
  final String? carId;
  final String? cityId;
  final String? driverId;
  final String? driverName;
  final String? driverImg;
  final String? driverPhone;
  final String? carImg;
  final String? carNum;
  final String? otp;

  RideDetail({
    this.bookingId,
    this.bookingCode,
    this.pickupAdd,
    this.pickupLat,
    this.pickupLng,
    this.dropAdd,
    this.dropLat,
    this.dropLng,
    this.dist,
    this.estTime,
    this.estAmount,
    this.status,
    this.carId,
    this.cityId,
    this.driverId,
    this.driverName,
    this.driverImg,
    this.driverPhone,
    this.carImg,
    this.carNum,
    this.otp,
  });
}
