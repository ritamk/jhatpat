import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:jhatpat/models/driver_model.dart';
import 'package:jhatpat/models/map_model.dart';
import 'package:jhatpat/permission.dart';
import 'package:jhatpat/services/database/database.dart';
import 'package:jhatpat/services/shared_pref.dart';
import 'package:jhatpat/shared/loading.dart';
import 'package:jhatpat/shared/snackbars.dart';
import 'package:jhatpat/shared/text_field_deco.dart';
import 'package:jhatpat/views/home/home_drawer.dart';
import 'package:jhatpat/views/home/location_services.dart';
import 'package:jhatpat/views/payment/ride_payment.dart';
import 'package:url_launcher/url_launcher.dart';

class RidePage extends StatefulWidget {
  const RidePage({
    Key? key,
    this.initialCameraPosition,
    this.mapModel,
    this.marker,
    this.rideDetail,
  }) : super(key: key);

  final CameraPosition? initialCameraPosition;
  final MapModel? mapModel;
  final Map<MarkerId, Marker>? marker;
  final RideDetail? rideDetail;

  @override
  State<RidePage> createState() => _RidePageState();
}

class _RidePageState extends State<RidePage> {
  bool _rideStarted = false;
  int _showingStatus = -1;
  bool _mapLoading = true;
  bool _routeLoaded = false;
  bool _error = false;
  GoogleMapController? _controller;

  CameraPosition? _initialCameraPosition;
  MapModel? _mapModel;
  Map<MarkerId, Marker>? _marker;
  RideDetail? _rideDetail;

  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _initialCameraPosition = widget.initialCameraPosition;
    _mapModel = widget.mapModel;
    _marker = widget.marker ?? <MarkerId, Marker>{};
    _rideDetail = widget.rideDetail;
    initMap()
        .whenComplete(() => setState(() => _mapLoading = false))
        .whenComplete(() => getDirections())
        .whenComplete(() => setState(() => _routeLoaded = true));
    _timer = Timer.periodic(
        const Duration(seconds: 15), (timer) => getBookingStatus());
  }

  Future<void> initMap() async {
    if (_initialCameraPosition == null) {
      try {
        _rideDetail =
            await DatabaseService(token: UserSharedPreferences.getUserToken()!)
                .postFindDriver(UserSharedPreferences.getRideState()!);
        _initialCameraPosition = CameraPosition(
            target: LatLng(double.parse(_rideDetail!.pickupLat!),
                double.parse(_rideDetail!.pickupLng!)),
            zoom: 14.0);
        await addMarker(
            false,
            LatLng(double.parse(_rideDetail!.pickupLat!),
                double.parse(_rideDetail!.pickupLng!)),
            false);
        await addMarker(
            true,
            LatLng(double.parse(_rideDetail!.dropLat!) + 0.001,
                double.parse(_rideDetail!.dropLng!) + 0.001),
            false);
        await DatabaseService(token: UserSharedPreferences.getUserToken())
            .postBookingStatus()
            .then((value) => value.status == bookingStatusStates[1] ||
                    value.status == bookingStatusStates[5] ||
                    value.status == bookingStatusStates[6]
                ? UserSharedPreferences.setRideBool(false).whenComplete(() =>
                    Navigator.pushAndRemoveUntil(
                        context,
                        CupertinoPageRoute(
                            builder: (context) => const PermissionsPage()),
                        (route) => false))
                : null);
      } catch (e) {
        setState(() => _error = true);
      }
    }
  }

  Future<String> getBookingStatus() async {
    try {
      final BookingDetails bookingDetails =
          await DatabaseService(token: UserSharedPreferences.getUserToken())
              .postBookingStatus();
      final String status = bookingDetails.status!;
      addMarker(
        false,
        LatLng(double.parse(bookingDetails.lat!),
            double.parse(bookingDetails.lng!)),
        false,
        car: true,
        carMarker: "carMarker",
      );
      if (status == bookingStatusStates[1]) {
        if (_showingStatus != 1) {
          showCupertinoDialog(
            context: context,
            builder: (context) => WillPopScope(
              onWillPop: () async => false,
              child: CupertinoAlertDialog(
                title: const Text("Ride rejected"),
                actions: <CupertinoDialogAction>[
                  CupertinoDialogAction(
                    child: const Text("Leave ride screen"),
                    onPressed: () async {
                      await UserSharedPreferences.setRideBool(false);
                      Navigator.of(context).pop;
                      Navigator.of(context).pushAndRemoveUntil(
                          CupertinoPageRoute(
                              builder: (context) => const PermissionsPage()),
                          (route) => false);
                    },
                  ),
                ],
              ),
            ),
          );
        }
        _showingStatus = 1;
      }
      if (status == bookingStatusStates[2]) {
        if (_showingStatus != 2) {
          showCupertinoDialog(
            context: context,
            barrierDismissible: true,
            builder: (context) => const CupertinoAlertDialog(
              title: Text("Ride accepted by driver"),
            ),
          );
        }
        _showingStatus = 2;
      }
      if (status == bookingStatusStates[3]) {
        if (_showingStatus != 3) {
          _rideStarted = true;
          showCupertinoDialog(
            context: context,
            barrierDismissible: true,
            builder: (context) => const CupertinoAlertDialog(
              title: Text("Ride started"),
            ),
          );
        }
        _showingStatus = 3;
      }
      if (status == bookingStatusStates[4]) {
        if (_showingStatus != 4) {
          showCupertinoDialog(
            context: context,
            builder: (context) => WillPopScope(
              onWillPop: () async => false,
              child: CupertinoAlertDialog(
                title: const Text("Ride completed"),
                actions: <CupertinoDialogAction>[
                  CupertinoDialogAction(
                    child: bookingDetails.payType == "cash"
                        ? const Text("Leave ride page")
                        : const Text("Pay"),
                    onPressed: () async {
                      if (bookingDetails.payType == "cash") {
                        await UserSharedPreferences.setRideBool(false);
                        Navigator.of(context).pushAndRemoveUntil(
                            CupertinoPageRoute(
                                builder: (context) => const PermissionsPage()),
                            (route) => false);
                      } else {
                        Navigator.of(context).pushAndRemoveUntil(
                            CupertinoPageRoute(
                                builder: (context) => RidePaymentPage(
                                    bookingDetails: bookingDetails)),
                            (route) => false);
                      }
                    },
                  ),
                ],
              ),
            ),
          );
        }
        _showingStatus = 4;
      }
      if (status == bookingStatusStates[5]) {
        if (_showingStatus != 5) {
          showCupertinoDialog(
            context: context,
            builder: (context) => WillPopScope(
              onWillPop: () async => false,
              child: CupertinoAlertDialog(
                title: const Text("Payment done"),
                actions: <CupertinoDialogAction>[
                  CupertinoDialogAction(
                    child: const Text("Leave ride screen"),
                    onPressed: () async {
                      await UserSharedPreferences.setRideBool(false);
                      Navigator.of(context).pop;
                      Navigator.of(context).pushAndRemoveUntil(
                          CupertinoPageRoute(
                              builder: (context) => const PermissionsPage()),
                          (route) => false);
                    },
                  ),
                ],
              ),
            ),
          );
        }
        _showingStatus = 5;
      }
      if (status == bookingStatusStates[6]) {
        if (_showingStatus != 6) {
          showCupertinoDialog(
              context: context,
              builder: (context) => WillPopScope(
                    onWillPop: () async => false,
                    child: CupertinoAlertDialog(
                      title: const Text("Ride cancelled"),
                      actions: <CupertinoDialogAction>[
                        CupertinoDialogAction(
                          child: const Text("Leave ride screen"),
                          onPressed: () async {
                            await UserSharedPreferences.setRideBool(false);
                            Navigator.of(context).pop;
                            Navigator.of(context).pushAndRemoveUntil(
                                CupertinoPageRoute(
                                    builder: (context) =>
                                        const PermissionsPage()),
                                (route) => false);
                          },
                        ),
                      ],
                    ),
                  ));
        }
        _showingStatus = 6;
      }
      return bookingDetails.status!;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        showCupertinoDialog<bool>(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: const Text("Do you want to exit the app?"),
            actions: <CupertinoDialogAction>[
              CupertinoDialogAction(
                child: const Text("Yes"),
                onPressed: () => exit(0),
              ),
              CupertinoDialogAction(
                child: const Text("No"),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        );
        return true;
      },
      child: SafeArea(
        child: !_mapLoading
            ? Scaffold(
                body: Stack(
                  children: <Widget>[
                    GoogleMap(
                      mapType: MapType.normal,
                      initialCameraPosition: _initialCameraPosition!,
                      onMapCreated: (controller) => _controller = controller,
                      mapToolbarEnabled: false,
                      zoomControlsEnabled: false,
                      myLocationButtonEnabled: false,
                      myLocationEnabled: true,
                      compassEnabled: false,
                      markers: Set<Marker>.of(_marker!.values),
                      polylines: _routeLoaded
                          ? <Polyline>{
                              Polyline(
                                points: _mapModel!.polyLinePts
                                    .map((PointLatLng e) =>
                                        LatLng(e.latitude, e.longitude))
                                    .toList(),
                                polylineId: const PolylineId("polyRoute"),
                                color: const Color.fromARGB(255, 86, 86, 86),
                                width: 5,
                                startCap: Cap.roundCap,
                                endCap: Cap.roundCap,
                              ),
                            }
                          : <Polyline>{},
                    ),
                    Positioned(
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Card(
                            elevation: 6.0,
                            shadowColor: Colors.black38,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15.0)),
                            child: Row(
                              children: <Widget>[
                                Builder(
                                  builder: ((context) => IconButton(
                                        onPressed: () =>
                                            Scaffold.of(context).openDrawer(),
                                        icon: const Icon(Icons.menu_rounded,
                                            color: Colors.black87),
                                      )),
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 12.0, horizontal: 8.0),
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(20.0),
                                        color: const Color.fromARGB(
                                            31, 133, 133, 133),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: <Widget>[
                                          Row(
                                            children: <Widget>[
                                              const Icon(Icons.circle,
                                                  color: Colors.black),
                                              const SizedBox(width: 10.0),
                                              Expanded(
                                                child: Text(
                                                    _rideDetail!.pickupAdd!,
                                                    style: const TextStyle(
                                                        fontSize: 15.0,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                    overflow:
                                                        TextOverflow.ellipsis),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 5.0),
                                          Row(
                                            children: <Widget>[
                                              const Icon(Icons.move_down,
                                                  color: Colors.black26),
                                              const SizedBox(width: 10.0),
                                              Expanded(
                                                child: Text(
                                                  "${_rideDetail!.dist!}, ${(_rideDetail!.estTime!).substring(0, 2)}:${(_rideDetail!.estTime!).substring(3, 5)}:${(_rideDetail!.estTime!).substring(6, 8)}",
                                                  // "${_rideDetail!.dist!} km, ${(_rideDetail!.estTime!).substring(0, 2)} hr,  ${(_rideDetail!.estTime!).substring(3, 5)} min,  ${(_rideDetail!.estTime!).substring(6, 8)} sec",
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 5.0),
                                          Row(
                                            children: <Widget>[
                                              Icon(Icons.circle,
                                                  color: Colors.red.shade700),
                                              const SizedBox(width: 10.0),
                                              Expanded(
                                                child: Text(
                                                    _rideDetail!.dropAdd!,
                                                    style: const TextStyle(
                                                        fontSize: 15.0,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                    overflow:
                                                        TextOverflow.ellipsis),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
                bottomNavigationBar: BottomSheet(
                  onClosing: () {},
                  enableDrag: false,
                  shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(15.0),
                          topRight: Radius.circular(15.0))),
                  builder: (context) => !_error
                      ? !_mapLoading
                          ? Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      CircleAvatar(
                                        maxRadius: 32.0,
                                        backgroundImage: _rideDetail!
                                                    .driverImg !=
                                                null
                                            ? Image.network(
                                                "https://dev.jhatpat.app/storage/images/users/" +
                                                    _rideDetail!.driverImg!,
                                                frameBuilder: (context,
                                                        child,
                                                        frame,
                                                        wasSynchronouslyLoaded) =>
                                                    frame != null
                                                        ? child
                                                        : const Loading(
                                                            white: false),
                                                loadingBuilder: (context, child,
                                                        loadingProgress) =>
                                                    loadingProgress != null
                                                        ? child
                                                        : const Loading(
                                                            white: false),
                                              ).image
                                            : Image.asset(
                                                    "assets/images/UserProfileDefault.png")
                                                .image,
                                      ),
                                      const SizedBox(width: 10.0),
                                      Expanded(
                                        child: Center(
                                          child: Text(
                                            _rideDetail!.driverName ?? "",
                                            style: const TextStyle(
                                                fontSize: 20.0,
                                                fontWeight: FontWeight.bold),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 10.0),
                                      IconButton(
                                        onPressed: () async {
                                          try {
                                            await launchUrl(Uri(
                                                scheme: "tel",
                                                path:
                                                    _rideDetail!.driverPhone ??
                                                        ""));
                                          } catch (e) {
                                            Clipboard.setData(ClipboardData(
                                                text:
                                                    _rideDetail!.driverPhone!));
                                            commonSnackbar(
                                                "Couldn't call driver, number copied to clipboard",
                                                context);
                                          }
                                        },
                                        icon: const Icon(Icons.call),
                                        color: Colors.green,
                                        iconSize: 32.0,
                                      )
                                    ],
                                  ),
                                  Row(
                                    children: <Widget>[
                                      _rideDetail!.carImg != null
                                          ? Container(
                                              height: 100.0,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(15.0),
                                                image: DecorationImage(
                                                  image: Image.network(
                                                          "https://dev.jhatpat.app/storage/images/users/" +
                                                              _rideDetail!
                                                                  .carImg!)
                                                      .image,
                                                  fit: BoxFit.fitHeight,
                                                ),
                                              ),
                                            )
                                          : const SizedBox(),
                                      const SizedBox(width: 10.0),
                                      Text(
                                        "Regn No: ${_rideDetail!.carNum}",
                                        style: const TextStyle(fontSize: 16.0),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: <Widget>[
                                      for (int i = 0;
                                          i < _rideDetail!.otp!.length;
                                          i++)
                                        Container(
                                          height: 60.0,
                                          width: 60.0,
                                          padding: const EdgeInsets.all(8.0),
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(10.0),
                                            color: const Color.fromARGB(
                                                31, 133, 133, 133),
                                          ),
                                          child: Center(
                                            child: Text(
                                              _rideDetail!.otp![i],
                                              style: const TextStyle(
                                                  fontSize: 20.0,
                                                  fontWeight: FontWeight.bold),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        )
                                    ],
                                  ),
                                ],
                              ),
                            )
                          : const Center(child: Loading(white: false))
                      : Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const <Widget>[
                              Icon(Icons.error, color: Colors.red),
                              SizedBox(width: 20.0),
                              Text(
                                "Could not load driver details",
                                style: TextStyle(color: Colors.red),
                              )
                            ],
                          ),
                        ),
                ),
                drawer: const HomeDrawer(),
              )
            : const Scaffold(
                body: Center(child: Loading(white: false, rad: 14.0)),
              ),
      ),
    );
  }

  Future<void> addMarker(bool destination, LatLng coordinate, bool searched,
      {bool car = false, String carMarker = ""}) async {
    if (!car) {
      final MarkerId markerId =
          MarkerId(destination ? "destMarker" : "originMarker");

      final Marker marker = Marker(
        markerId: markerId,
        position: coordinate,
        icon: !destination
            ? await BitmapDescriptor.fromAssetImage(
                const ImageConfiguration(size: Size(48.0, 48.0)),
                "assets/images/pin1.png")
            : await BitmapDescriptor.fromAssetImage(
                const ImageConfiguration(size: Size(48.0, 48.0)),
                "assets/images/marker1.png"),
        infoWindow: InfoWindow(
            title: destination ? "Destination marker" : "Pick-up marker"),
      );

      _marker![markerId] = marker;
      setState(() {});
    } else {
      final MarkerId markerId = MarkerId(carMarker);

      final Marker marker = Marker(
        markerId: markerId,
        position: coordinate,
        icon: await BitmapDescriptor.fromAssetImage(
            const ImageConfiguration(size: Size(48.0, 48.0)),
            "assets/images/car.png"),
        infoWindow: const InfoWindow(title: "Car marker"),
      );

      _marker![markerId] = marker;
      setState(() {});
    }
  }

  Future<void> getDirections() async {
    try {
      final directions = await GetDirections().getDirections(
        LatLng(double.parse(_rideDetail!.pickupLat!),
            double.parse(_rideDetail!.pickupLng!)),
        LatLng(double.parse(_rideDetail!.dropLat!),
            double.parse(_rideDetail!.dropLng!)),
      );
      setState(() => _mapModel = directions);
      if (_mapModel != null) {
        _controller!.animateCamera(
            CameraUpdate.newLatLngBounds(_mapModel!.bounds, 50.0));
      } else {
        commonSnackbar("Something went wrong, couldn't load route", context);
      }
    } catch (e) {
      commonSnackbar(e.toString(), context);
    }
  }

  @override
  void dispose() {
    _controller!.dispose();
    _timer?.cancel();
    super.dispose();
  }
}
