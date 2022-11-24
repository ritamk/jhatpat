import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_google_places_hoc081098/flutter_google_places_hoc081098.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_api_headers/google_api_headers.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart' as gmwp;
import 'package:jhatpat/models/driver_model.dart';
import 'package:jhatpat/models/map_model.dart';
import 'package:jhatpat/services/database/database.dart';
import 'package:jhatpat/services/shared_pref.dart';
import 'package:jhatpat/shared/buttons.dart';
import 'package:jhatpat/shared/loading.dart';
import 'package:jhatpat/shared/snackbars.dart';
import 'package:jhatpat/views/home/home_drawer.dart';
import 'package:jhatpat/views/home/location_services.dart';
import 'package:jhatpat/views/home/ride.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _mapLoading = true;
  bool _myLocLoading = false;
  bool _mapMoving = false;
  bool _addressLoaded = true;
  bool _choosingDest = false;
  bool _pickupConfirmed = false;
  bool _destConfirmed = false;

  bool _bottomBar = false;
  bool _serviceAvailable = true;
  bool _choosingNone = false;

  bool _payOnline = true;

  final double _originSize = 37.5;
  final double _destSize = 21.5;
  final double _bottomBarHeight = 145.0;

  late GoogleMapController _controller;
  late LatLng _initCoord;
  Position? coord;

  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};
  final String _polyLineRouteId = "polyRoute";
  final String _destMarkerId = "DestinationMarker";
  LatLng? _pickupLatLng;
  final String _originMarkerId = "PickupMarker";
  LatLng? _dropoffLatLng;
  final double _initZoom = 14.0;
  final double _selectedZoom = 19.0;
  late CameraPosition _initCamPos;
  late CameraPosition _cameraPosn = _initCamPos;
  Map<PolylineId, Polyline> polylines = <PolylineId, Polyline>{};
  List<LatLng> polylineCoordinates = <LatLng>[];
  PolylinePoints polylinePoints = PolylinePoints();
  String _destString = "";
  String _originString = "";
  MapModel? _model;
  String _dist = "";
  String _distVal = "";
  String _durn = "";
  String _durnVal = "";
  final Color _bgCol = const Color.fromARGB(255, 86, 86, 86);

  int _rideTypeIndex = 0;

  List<DriverListModel>? _driverList = <DriverListModel>[];

  int cityId = 0;

  @override
  void initState() {
    super.initState();
    setInitCameraPos();
  }

  @override
  Widget build(BuildContext context) {
    if (!_mapLoading) {
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
          child: Scaffold(
            backgroundColor: Colors.white,
            body: Stack(
              alignment: Alignment.bottomCenter,
              children: <Widget>[
                GoogleMap(
                  mapType: MapType.normal,
                  initialCameraPosition: _initCamPos,
                  onMapCreated: (GoogleMapController controller) =>
                      _controller = controller,
                  onTap: (LatLng latLng) {
                    FocusManager.instance.primaryFocus?.unfocus();
                  },
                  markers: Set<Marker>.of(markers.values),
                  mapToolbarEnabled: false,
                  zoomControlsEnabled: false,
                  myLocationButtonEnabled: false,
                  myLocationEnabled: true,
                  compassEnabled: false,
                  polylines: <Polyline>{
                    if (_model != null)
                      Polyline(
                        points: _model!.polyLinePts
                            .map((PointLatLng e) =>
                                LatLng(e.latitude, e.longitude))
                            .toList(),
                        polylineId: PolylineId(_polyLineRouteId),
                        color: _bgCol,
                        width: 5,
                        startCap: Cap.roundCap,
                        endCap: Cap.roundCap,
                      ),
                  },
                  onCameraMove: (pos) {
                    _cameraPosn = pos;
                    if (!_mapMoving) {
                      _mapMoving = true;
                      if (!_pickupConfirmed && !_choosingDest) {
                        markers.remove(MarkerId(_originMarkerId));
                      }
                      if (!_destConfirmed && _choosingDest) {
                        markers.remove(MarkerId(_destMarkerId));
                      }
                      setState(() {});
                    }
                  },
                  onCameraIdle: () {
                    if (!_choosingDest) {
                      if (!_pickupConfirmed) {
                        _pickupLatLng = _cameraPosn.target;
                        addMarker(false, _pickupLatLng!, false);
                      }
                    } else {
                      if (!_destConfirmed) {
                        _dropoffLatLng = _cameraPosn.target;
                        addMarker(true, _dropoffLatLng!, false);
                      }
                    }
                    _mapMoving ? setState(() => _mapMoving = false) : null;
                  },
                ),
                // Pickup
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
                              child: InkWell(
                                onTap: () {
                                  _choosingDest = false;
                                  _pickupConfirmed = false;
                                  _autoCompletePlaces(_choosingDest);
                                  setState(() {});
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 12.0, horizontal: 8.0),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20.0),
                                      color: const Color.fromARGB(
                                          31, 133, 133, 133),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.max,
                                      children: <Widget>[
                                        Expanded(
                                          child: Text(
                                            _originString.isEmpty
                                                ? "Search pick-up point"
                                                : _originString,
                                            style: const TextStyle(
                                                color: Colors.black87,
                                                fontSize: 14.0,
                                                fontWeight: FontWeight.normal),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        IconButton(
                                          onPressed: () {
                                            _choosingDest = false;
                                            _choosingNone = false;
                                            _pickupConfirmed = false;
                                            setState(() {});
                                          },
                                          icon: Icon(
                                            Icons.location_on,
                                            color:
                                                !_choosingDest && !_choosingNone
                                                    ? Colors.black
                                                    : Colors.black26,
                                          ),
                                          visualDensity: VisualDensity.compact,
                                          padding: const EdgeInsets.all(0.0),
                                          constraints: const BoxConstraints
                                              .tightForFinite(),
                                          tooltip: "Mark pick-up on map",
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                if (markers.containsKey(
                                        MarkerId(_originMarkerId)) &&
                                    markers
                                        .containsKey(MarkerId(_destMarkerId))) {
                                  String tempStr = _destString;
                                  _destString = _originString;
                                  _originString = tempStr;
                                  LatLng tempLL = _dropoffLatLng!;
                                  _dropoffLatLng = _pickupLatLng;
                                  _pickupLatLng = tempLL;
                                  Marker tempMark =
                                      markers[MarkerId(_destMarkerId)]!;
                                  markers[MarkerId(_destMarkerId)] =
                                      markers[MarkerId(_originMarkerId)]!;

                                  setState(() =>
                                      markers[MarkerId(_originMarkerId)] =
                                          tempMark);
                                }
                              },
                              icon: markers.containsKey(
                                          MarkerId(_originMarkerId)) &&
                                      markers
                                          .containsKey(MarkerId(_destMarkerId))
                                  ? const Icon(Icons.swap_vert,
                                      color: Colors.black87)
                                  : const Icon(Icons.swap_vert,
                                      color: Colors.black12),
                              visualDensity: VisualDensity.compact,
                              tooltip: "Switch destination and pickup",
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                // Central marker
                if ((_mapMoving && !_choosingNone) || !_addressLoaded)
                  Positioned(
                    bottom: MediaQuery.of(context).size.height / 2.0 -
                        (!_choosingDest ? _originSize / 2.5 : 4.0 * _destSize),
                    child: !_choosingDest
                        ? _addressLoaded
                            ? Image.asset("assets/images/pin1.png",
                                width: _originSize, height: _originSize)
                            : const Loading(white: false)
                        : _addressLoaded
                            ? Image.asset("assets/images/marker1.png",
                                width: _destSize, height: _destSize)
                            : const Loading(white: false),
                  ),
              ],
            ),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerFloat,
            floatingActionButton: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Expanded(
                    child: (!_pickupConfirmed && !_choosingDest) ||
                            (!_destConfirmed && _choosingDest)
                        ? blackMaterialButtons(
                            () async {
                              if (_serviceAvailable) {
                                if (_choosingDest) {
                                  _destConfirmed = true;
                                  _choosingNone = true;
                                } else {
                                  await getDriversList();
                                  _pickupConfirmed = true;
                                  _choosingNone = true;
                                }
                                _bottomBar = true;
                                if (_destConfirmed && _pickupConfirmed) {
                                  getDirections()
                                      .whenComplete(() => showBott(context));
                                }
                                setState(() {});
                              }
                            },
                            _serviceAvailable
                                ? !_choosingDest
                                    ? const Text(
                                        "Confirm pickup",
                                        style: TextStyle(
                                            fontSize: 16.0,
                                            fontWeight: FontWeight.bold),
                                      )
                                    : const Text(
                                        "Confirm destination",
                                        style: TextStyle(
                                            fontSize: 16.0,
                                            fontWeight: FontWeight.bold),
                                      )
                                : const Text(
                                    "Service unavailable in area",
                                    style: TextStyle(
                                        fontSize: 14.0,
                                        color: Colors.redAccent,
                                        fontWeight: FontWeight.bold),
                                  ),
                            rad: 10.0,
                          )
                        : const SizedBox(),
                  ),
                  const SizedBox(width: 15.0),
                  FloatingActionButton(
                    onPressed: _goToCurrLocation,
                    elevation: 0.0,
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    tooltip: "Current location",
                    child: !_myLocLoading
                        ? const Icon(
                            Icons.my_location_rounded,
                          )
                        : const Loading(white: true),
                  )
                ],
              ),
            ),
            bottomNavigationBar: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: _bottomBar ? _bottomBarHeight : 0.0,
              child: _bottomBar
                  ? AnimatedContainer(
                      duration: const Duration(milliseconds: 20),
                      height: _bottomBar ? _bottomBarHeight : 0.0,
                      child: _bottomBar
                          ? Wrap(
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: <Widget>[
                                          MaterialButton(
                                            onPressed: () => setState(
                                                () => _rideTypeIndex = 0),
                                            child: Column(
                                              children: <Widget>[
                                                Container(
                                                  padding: const EdgeInsets.all(
                                                      12.0),
                                                  decoration: BoxDecoration(
                                                    color: _rideTypeIndex == 0
                                                        ? Colors.black87
                                                        : Colors.black38,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            15.0),
                                                  ),
                                                  child: const Icon(
                                                      Icons.local_taxi,
                                                      color: Colors.white),
                                                ),
                                                Text(
                                                  "Daily",
                                                  style: TextStyle(
                                                      fontWeight:
                                                          _rideTypeIndex == 0
                                                              ? FontWeight.bold
                                                              : FontWeight
                                                                  .normal),
                                                ),
                                              ],
                                            ),
                                          ),
                                          MaterialButton(
                                            onPressed: () => setState(
                                                () => _rideTypeIndex = 1),
                                            child: Column(
                                              children: <Widget>[
                                                Container(
                                                  padding: const EdgeInsets.all(
                                                      12.0),
                                                  decoration: BoxDecoration(
                                                      color: _rideTypeIndex == 1
                                                          ? Colors.black87
                                                          : Colors.black38,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              15.0)),
                                                  child: const Icon(
                                                      Icons.car_rental,
                                                      color: Colors.white),
                                                ),
                                                Text(
                                                  "Rental",
                                                  style: TextStyle(
                                                      fontWeight:
                                                          _rideTypeIndex == 1
                                                              ? FontWeight.bold
                                                              : FontWeight
                                                                  .normal),
                                                ),
                                              ],
                                            ),
                                          ),
                                          MaterialButton(
                                            onPressed: () => setState(
                                                () => _rideTypeIndex = 2),
                                            child: Column(
                                              children: <Widget>[
                                                Container(
                                                  padding: const EdgeInsets.all(
                                                      12.0),
                                                  decoration: BoxDecoration(
                                                      color: _rideTypeIndex == 2
                                                          ? Colors.black87
                                                          : Colors.black38,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              15.0)),
                                                  child: const Icon(
                                                      Icons.garage,
                                                      color: Colors.white),
                                                ),
                                                Text(
                                                  "Outstation",
                                                  style: TextStyle(
                                                      fontWeight:
                                                          _rideTypeIndex == 2
                                                              ? FontWeight.bold
                                                              : FontWeight
                                                                  .normal),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 10.0),
                                      // Destination
                                      InkWell(
                                        onTap: () {
                                          _choosingDest = true;
                                          _destConfirmed = false;
                                          _autoCompletePlaces(_choosingDest);
                                          setState(() {});
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 16.0, vertical: 4.0),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 12.0,
                                                horizontal: 8.0),
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(20.0),
                                              color: const Color.fromARGB(
                                                  31, 133, 133, 133),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.max,
                                              children: <Widget>[
                                                Expanded(
                                                  child: Text(
                                                    _destString.isEmpty
                                                        ? "Search destination point"
                                                        : _destString,
                                                    style: const TextStyle(
                                                        color: Colors.black87,
                                                        fontSize: 14.0,
                                                        fontWeight:
                                                            FontWeight.normal),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                                IconButton(
                                                  onPressed: () {
                                                    _choosingDest = true;
                                                    _choosingNone = false;
                                                    _dropoffLatLng == null
                                                        ? addMarker(
                                                            true,
                                                            _cameraPosn.target,
                                                            false)
                                                        : null;
                                                    _destConfirmed = false;
                                                    setState(() {});
                                                  },
                                                  icon: Icon(
                                                    Icons.location_on,
                                                    color: _choosingDest &&
                                                            !_choosingNone
                                                        ? Colors.red.shade700
                                                        : Colors.red.shade200,
                                                  ),
                                                  visualDensity:
                                                      VisualDensity.compact,
                                                  padding:
                                                      const EdgeInsets.all(0.0),
                                                  constraints:
                                                      const BoxConstraints
                                                          .tightForFinite(),
                                                  tooltip:
                                                      "Mark destination on map",
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            )
                          : Container(
                              color: Colors.white,
                              width: MediaQuery.of(context).size.width),
                    )
                  : Container(
                      color: Colors.white,
                      width: MediaQuery.of(context).size.width),
            ),
            drawer: const HomeDrawer(),
          ),
        ),
      );
    } else {
      return const Scaffold(
        body: Center(child: Loading(white: false, rad: 14.0)),
      );
    }
  }

  Future<void> getDriversList() async {
    try {
      _driverList = await DatabaseService().postDriversList(_pickupLatLng!);
      if (_driverList != null) {
        if (_driverList!.isNotEmpty) {
          for (int i = 0; i < _driverList!.length; i++) {
            addMarker(
              false,
              LatLng(double.parse(_driverList![i].lat!),
                  double.parse(_driverList![i].lng!)),
              false,
              car: true,
              carMarker: "carMarker$i",
            );
          }
        }
      }
    } catch (e) {
      commonSnackbar(e.toString(), context);
    }
  }

  /// Fetch route info from Google Directions API
  Future<void> getDirections() async {
    try {
      final directions =
          await GetDirections().getDirections(_pickupLatLng!, _dropoffLatLng!);
      setState(() => _model = directions);
      if (_model != null) {
        _controller
            .animateCamera(CameraUpdate.newLatLngBounds(_model!.bounds, 50.0));
        _dist = _model!.totalDist;
        _distVal = (int.parse(_model!.distVal) / 1000.0).toStringAsFixed(2);
        _durn = _model!.totalDur;
        final int time = int.parse(_model!.durVal);
        final String hr = Duration(seconds: time).inHours.toString();
        final String min =
            Duration(seconds: time).inMinutes.remainder(60).toString();
        final String sec =
            Duration(seconds: time).inSeconds.remainder(60).toString();
        _durnVal = (hr.length < 2 ? hr + "0" : hr) +
            ":" +
            (min.length < 2 ? min + "0" : min) +
            ":" +
            (sec.length < 2 ? sec + "0" : sec);
      } else {
        commonSnackbar("Something went wrong, couldn't load route", context);
      }
    } catch (e) {
      commonSnackbar(e.toString(), context);
    }
  }

  Future<void> showBott(BuildContext context) {
    bool _booking = false;
    int _bookingIndex = 0;

    return showModalBottomSheet<void>(
      constraints: BoxConstraints.tight(const Size(double.infinity, 400.0)),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topRight: Radius.circular(15.0), topLeft: Radius.circular(15.0))),
      context: context,
      builder: (context) => FutureBuilder<List<BookingPrices>?>(
        future: DatabaseService(token: UserSharedPreferences.getUserToken())
            .postBookingPriceList(cityId.toString(), _distVal),
        initialData: const [],
        builder: (BuildContext context, AsyncSnapshot snapshot) =>
            StatefulBuilder(
          builder: (BuildContext context, setState) {
            return snapshot.connectionState == ConnectionState.done
                ? !snapshot.hasError
                    ? snapshot.hasData
                        ? snapshot.data.isNotEmpty
                            ? Column(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  Material(
                                    type: MaterialType.transparency,
                                    child: Container(
                                      decoration: const BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(15.0),
                                            topRight: Radius.circular(15.0)),
                                        boxShadow: <BoxShadow>[
                                          BoxShadow(
                                            color: Colors.black26,
                                            offset: Offset(0.0, 2.0),
                                            blurRadius: 4.0,
                                            spreadRadius: 2.0,
                                          )
                                        ],
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: <Widget>[
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(4.0),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: <Widget>[
                                                  const Icon(Icons.circle,
                                                      color: Colors.black),
                                                  const SizedBox(width: 10.0),
                                                  Expanded(
                                                    child: Text(_originString,
                                                        style: const TextStyle(
                                                            fontSize: 15.0,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                        overflow: TextOverflow
                                                            .ellipsis),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(4.0),
                                              child: Row(
                                                children: <Widget>[
                                                  const Icon(Icons.move_down,
                                                      color: Colors.black26),
                                                  const SizedBox(width: 10.0),
                                                  Text("$_dist, $_durn"),
                                                ],
                                              ),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(4.0),
                                              child: Row(
                                                children: <Widget>[
                                                  Icon(Icons.circle,
                                                      color:
                                                          Colors.red.shade700),
                                                  const SizedBox(width: 10.0),
                                                  Expanded(
                                                    child: Text(_destString,
                                                        style: const TextStyle(
                                                            fontSize: 15.0,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                        overflow: TextOverflow
                                                            .ellipsis),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: SingleChildScrollView(
                                      physics: const BouncingScrollPhysics(
                                          parent:
                                              AlwaysScrollableScrollPhysics()),
                                      primary: false,
                                      child: Column(
                                        children: <Widget>[
                                          for (int i = 0;
                                              i < snapshot.data.length;
                                              i++)
                                            InkWell(
                                              onTap: () => setState(
                                                  () => _bookingIndex = i),
                                              child: Container(
                                                color: _bookingIndex == i
                                                    ? Colors.greenAccent
                                                    : Colors.white,
                                                child: Padding(
                                                  padding: const EdgeInsets
                                                          .symmetric(
                                                      vertical: 8.0,
                                                      horizontal: 24.0),
                                                  child: Row(
                                                    children: <Widget>[
                                                      const Icon(
                                                        Icons
                                                            .local_taxi_outlined,
                                                        size: 32.0,
                                                      ),
                                                      const SizedBox(
                                                          width: 10.0),
                                                      Expanded(
                                                        child: Text(
                                                          snapshot
                                                              .data[i].carType,
                                                          style: const TextStyle(
                                                              fontSize: 16.0,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                          width: 10.0),
                                                      const Icon(
                                                          Icons.currency_rupee),
                                                      const SizedBox(
                                                          width: 5.0),
                                                      Text(
                                                        snapshot.data[i]
                                                            .approxPrice,
                                                        style: const TextStyle(
                                                            fontSize: 15.0),
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
                                  Material(
                                    type: MaterialType.transparency,
                                    child: Container(
                                      decoration: const BoxDecoration(
                                        color: Colors.white,
                                        boxShadow: <BoxShadow>[
                                          BoxShadow(
                                            color: Colors.black26,
                                            offset: Offset(0.0, -2.0),
                                            blurRadius: 4.0,
                                            spreadRadius: 2.0,
                                          ),
                                        ],
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Column(
                                          children: <Widget>[
                                            blackMaterialButtons(
                                              () async {
                                                bool choice = false;

                                                await showCupertinoDialog(
                                                  context: context,
                                                  builder: (context) =>
                                                      CupertinoAlertDialog(
                                                    title: const Text(
                                                        "Book ride?"),
                                                    content: const Text(
                                                        "Once the ride is booked, you will not be able to cancel it"),
                                                    actions: <
                                                        CupertinoDialogAction>[
                                                      CupertinoDialogAction(
                                                          onPressed: () {
                                                            choice = true;
                                                            Navigator.of(
                                                                    context)
                                                                .pop();
                                                          },
                                                          child: const Text(
                                                              "Yes")),
                                                      CupertinoDialogAction(
                                                          onPressed: () {
                                                            choice = false;
                                                            Navigator.of(
                                                                    context)
                                                                .pop();
                                                          },
                                                          child:
                                                              const Text("No")),
                                                    ],
                                                  ),
                                                );
                                                if (choice) {
                                                  setState(
                                                      () => _booking = true);

                                                  try {
                                                    final BookingDetails?
                                                        bookingDetails =
                                                        await DatabaseService(
                                                                token: UserSharedPreferences
                                                                    .getUserToken()!)
                                                            .postBookingInitiate(
                                                      BookingDetails(
                                                        carId: snapshot
                                                            .data[_bookingIndex]
                                                            .carId,
                                                        cityId:
                                                            cityId.toString(),
                                                        pickupAdd:
                                                            _originString,
                                                        pickupLat:
                                                            _pickupLatLng!
                                                                .latitude
                                                                .toString(),
                                                        pickupLng:
                                                            _pickupLatLng!
                                                                .longitude
                                                                .toString(),
                                                        dropAdd: _destString,
                                                        dropLat: _dropoffLatLng!
                                                            .latitude
                                                            .toString(),
                                                        dropLng: _dropoffLatLng!
                                                            .longitude
                                                            .toString(),
                                                        dist: _distVal,
                                                        estTime: _durnVal,
                                                        estAmount: snapshot
                                                            .data[_bookingIndex]
                                                            .approxPrice,
                                                        payType: _payOnline
                                                            ? "online"
                                                            : "cash",
                                                      ),
                                                    );

                                                    if (bookingDetails !=
                                                        null) {
                                                      final RideDetail?
                                                          rideDetail =
                                                          await DatabaseService(
                                                                  token: UserSharedPreferences
                                                                      .getUserToken()!)
                                                              .postFindDriver(
                                                                  bookingDetails
                                                                      .bookingId!);

                                                      if (rideDetail != null) {
                                                        UserSharedPreferences
                                                                .setRideBool(
                                                                    true)
                                                            .whenComplete(() =>
                                                                UserSharedPreferences
                                                                    .setRideState(
                                                                        rideDetail
                                                                            .bookingId!))
                                                            .whenComplete(
                                                                () async {
                                                          final Map<MarkerId,
                                                                  Marker>
                                                              marker = markers;
                                                          if (marker.containsKey(
                                                              const MarkerId(
                                                                  "carMarker0"))) {
                                                            for (int i = 0;
                                                                i <
                                                                    _driverList!
                                                                        .length;
                                                                i++) {
                                                              marker.remove(
                                                                  MarkerId(
                                                                      "carMarker$i"));
                                                            }
                                                          }
                                                          Navigator.of(context)
                                                              .pushAndRemoveUntil(
                                                                  CupertinoPageRoute(
                                                                    builder:
                                                                        (context) =>
                                                                            RidePage(
                                                                      initialCameraPosition:
                                                                          _cameraPosn,
                                                                      mapModel:
                                                                          _model,
                                                                      marker:
                                                                          marker,
                                                                      rideDetail:
                                                                          rideDetail,
                                                                    ),
                                                                  ),
                                                                  (route) =>
                                                                      false);
                                                        });
                                                      } else {
                                                        Fluttertoast.showToast(
                                                          msg:
                                                              "No ${snapshot.data[_bookingIndex].carType.toLowerCase()} driver found nearby",
                                                          fontSize: 16.0,
                                                        );
                                                      }
                                                    } else {
                                                      Fluttertoast.showToast(
                                                        msg:
                                                            "No ${snapshot.data[_bookingIndex].carType.toLowerCase()} driver found nearby",
                                                        fontSize: 16.0,
                                                      );
                                                    }
                                                  } catch (e) {
                                                    commonSnackbar(
                                                        e.toString(), context);
                                                    Fluttertoast.showToast(
                                                      msg:
                                                          "No ${snapshot.data[_bookingIndex].carType.toLowerCase()} driver found nearby",
                                                      fontSize: 16.0,
                                                    );
                                                  }
                                                  setState(
                                                      () => _booking = false);
                                                }
                                              },
                                              !_booking
                                                  ? const Text(
                                                      "Confirm ride",
                                                      style: TextStyle(
                                                          fontSize: 18.0,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    )
                                                  : const Center(
                                                      child:
                                                          Loading(white: true)),
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceEvenly,
                                              children: <Widget>[
                                                Expanded(
                                                  child: MaterialButton(
                                                    onPressed: () => setState(
                                                        () =>
                                                            _payOnline = true),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceAround,
                                                      children: const <Widget>[
                                                        Icon(Icons.payment),
                                                        SizedBox(width: 5.0),
                                                        Text("Pay online"),
                                                      ],
                                                    ),
                                                    elevation: 0.0,
                                                    focusElevation: 0.0,
                                                    highlightElevation: 0.0,
                                                    color: _payOnline
                                                        ? Colors.black
                                                        : Colors.black26,
                                                    textColor: _payOnline
                                                        ? Colors.white
                                                        : Colors.black,
                                                    shape:
                                                        RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10.0)),
                                                  ),
                                                ),
                                                const SizedBox(width: 10.0),
                                                Expanded(
                                                  child: MaterialButton(
                                                    onPressed: () => setState(
                                                        () =>
                                                            _payOnline = false),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceAround,
                                                      children: const <Widget>[
                                                        Icon(Icons
                                                            .account_balance_wallet),
                                                        SizedBox(width: 5.0),
                                                        Text("Pay in cash"),
                                                      ],
                                                    ),
                                                    elevation: 0.0,
                                                    focusElevation: 0.0,
                                                    highlightElevation: 0.0,
                                                    color: !_payOnline
                                                        ? Colors.black
                                                        : Colors.black26,
                                                    textColor: !_payOnline
                                                        ? Colors.white
                                                        : Colors.black,
                                                    shape:
                                                        RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10.0)),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const <Widget>[
                                    Icon(Icons.error, color: Colors.red),
                                    SizedBox(width: 20.0),
                                    Text(
                                      "Could not load booking options",
                                      style: TextStyle(color: Colors.red),
                                    )
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
                              "Could not load booking options",
                              style: TextStyle(color: Colors.red),
                            )
                          ],
                        ),
                      )
                : const Center(child: Loading(white: false));
          },
        ),
      ),
    );
  }

  /// Initialise the position of the camera at the start of the application.
  /// If a previously stored instance of camera position is available on the
  /// device then it is used.
  Future<void> setInitCameraPos() async {
    Position? pos;
    determinePosition()
        .then((value) => pos = value)
        .whenComplete(() {
          _initCoord = LatLng(pos!.latitude, pos!.longitude);
          _initCamPos = CameraPosition(
            target: _initCoord,
            bearing: 0.0,
            tilt: 0.0,
            zoom: _initZoom,
          );
        })
        .whenComplete(() => addMarker(false, _initCoord, false))
        .whenComplete(() => setState(() => _mapLoading = false))
        .whenComplete(() async {
          try {
            await DatabaseService()
                .postCityId(LatLng(pos!.latitude, pos!.longitude))
                .then((value) => cityId = value);
          } catch (e) {
            setState(() => _serviceAvailable = false);
          }
        });
  }

  /// Moves camera to current location and marks it
  /// as the pickup point.
  void _goToCurrLocation() async {
    setState(() => _myLocLoading = true);
    try {
      coord = await determinePosition();
    } catch (e) {
      commonSnackbar(e.toString(), context);
    }
    if (coord != null) {
      _controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
        target: LatLng(coord!.latitude, coord!.longitude),
        bearing: 0.0,
        tilt: 0.0,
        zoom: _selectedZoom,
      )));
      addMarker(false, LatLng(coord!.latitude, coord!.longitude), false);
    } else {
      commonSnackbar("Cannot access current location", context);
    }
    setState(() => _myLocLoading = false);
  }

  /// Adds a blue marker for pickup location and
  /// a blue marker for drop-off location.
  Future<void> addMarker(bool destination, LatLng coordinate, bool searched,
      {bool car = false, String carMarker = ""}) async {
    if (!car) {
      try {
        await DatabaseService()
            .postCityId(LatLng(coordinate.latitude, coordinate.longitude))
            .then((value) {
          cityId = value;
          if (!_serviceAvailable) setState(() => _serviceAvailable = true);
        });
      } catch (e) {
        setState(() => _serviceAvailable = false);
      }

      if (!searched) {
        setState(() => _addressLoaded = false);
        final List<Placemark> placemarks = await placemarkFromCoordinates(
                coordinate.latitude, coordinate.longitude)
            .whenComplete(() => setState(() => _addressLoaded = true));
        final Placemark place = placemarks[0];

        if (destination) {
          _destString = "";
          if (place.name != null) {
            _destString = _destString + place.name!;
            if (place.subLocality != null) {
              _destString = _destString + ", " + place.subLocality!;
            }
            if (place.locality != null) {
              _destString = _destString + ", " + place.locality!;
            }
            if (place.administrativeArea != null) {
              _destString = _destString + ", " + place.administrativeArea!;
            }
          } else {
            _destString = "${coordinate.latitude.toStringAsFixed(3)},"
                " ${coordinate.longitude.toStringAsFixed(3)}";
          }
        } else {
          _originString = "";
          if (place.name != null) {
            _originString = _originString + place.name!;
            if (place.subLocality != null) {
              _originString = _originString + ", " + place.subLocality!;
            }
            if (place.locality != null) {
              _originString = _originString + ", " + place.locality!;
            }
            if (place.administrativeArea != null) {
              _originString = _originString + ", " + place.administrativeArea!;
            }
          } else {
            _originString = "${coordinate.latitude.toStringAsFixed(3)},"
                " ${coordinate.longitude.toStringAsFixed(3)}";
          }
        }
        setState(() {});
      } else {
        null;
      }

      String markerString = "";

      markerString = destination ? _destMarkerId : _originMarkerId;

      final MarkerId markerId = MarkerId(markerString);

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

      try {
        await UserSharedPreferences.setMapGeoLoc(
            coordinate.latitude, coordinate.longitude);
      } catch (e) {
        null;
      }

      markers[markerId] = marker;
      if (destination) {
        _dropoffLatLng = coordinate;
      } else {
        _pickupLatLng = coordinate;
      }
      setState(() {});
    } else {
      final MarkerId markerId = MarkerId(carMarker);

      final Marker marker = Marker(
        markerId: markerId,
        position: coordinate,
        icon: await BitmapDescriptor.fromAssetImage(
            const ImageConfiguration(size: Size(48.0, 48.0)),
            "assets/images/car.png"),
        infoWindow: const InfoWindow(title: "Jhatpat car marker"),
      );
      markers[markerId] = marker;
    }
  }

  /// Uses the Google Places API to generate search results for places.
  _autoCompletePlaces(bool dest) async {
    var place = await PlacesAutocomplete.show(
      context: context,
      apiKey: API_KEY,
      types: [],
      strictbounds: false,
      onError: (gmwp.PlacesAutocompleteResponse e) =>
          commonSnackbar(e.toString(), context),
      region: "in",
    );

    if (place != null) {
      setState(() => dest
          ? _destString = place.description.toString()
          : _originString = place.description.toString());

      final plist = gmwp.GoogleMapsPlaces(
        apiKey: API_KEY,
        apiHeaders: await const GoogleApiHeaders().getHeaders(),
      );

      String placeId = place.placeId ?? "0";
      final detail = await plist.getDetailsByPlaceId(placeId);
      final geometry = detail.result.geometry;
      final lat = geometry?.location.lat ?? _initCoord.latitude;
      final lang = geometry?.location.lng ?? _initCoord.longitude;
      var newlatlang = LatLng(lat, lang);

      _controller.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: newlatlang, zoom: _initZoom),
        ),
      );

      if (dest) {
        _dropoffLatLng = LatLng(lat, lang);
        addMarker(true, _dropoffLatLng!, true);
      } else {
        _pickupLatLng = LatLng(lat, lang);
        addMarker(false, _pickupLatLng!, true);
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
