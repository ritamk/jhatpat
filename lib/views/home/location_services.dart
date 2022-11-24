import 'package:dio/dio.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:jhatpat/models/map_model.dart';
import 'package:jhatpat/services/database/database.dart';
import 'package:location/location.dart' as loc;

Future<Position?> determinePosition() async {
  bool serviceEnabled;
  LocationPermission permission;

  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    await loc.Location.instance.requestService()
        ? null
        : throw 'Please enable location services.';
  }

  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      throw 'Please allow location permissions.';
    }
  }

  if (permission == LocationPermission.deniedForever) {
    throw 'Cannot request permissions, location permissions are permanently denied.';
  }

  try {
    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best);
  } catch (e) {
    return Geolocator.getLastKnownPosition();
  }
}

class GetDirections {
  static const String _baseUrl =
      "https://maps.googleapis.com/maps/api/directions/json?";

  Future<MapModel> getDirections(LatLng originLatLng, LatLng destLatLng) async {
    try {
      final Response response = await Dio().get(_baseUrl, queryParameters: {
        "origin": "${originLatLng.latitude},${originLatLng.longitude}",
        "destination": "${destLatLng.latitude},${destLatLng.longitude}",
        "key": API_KEY,
      });
      Map<String, dynamic> decodedResponse = response.data;

      if (decodedResponse["routes"].isEmpty) {
        throw "Something went wrong, please try again";
      }

      final Map<String, dynamic> routes =
          Map<String, dynamic>.from(decodedResponse["routes"][0]);
      final LatLng northeast = LatLng(routes["bounds"]["northeast"]["lat"],
          routes["bounds"]["northeast"]["lng"]);
      final LatLng southwest = LatLng(routes["bounds"]["southwest"]["lat"],
          routes["bounds"]["southwest"]["lng"]);
      final LatLngBounds bounds =
          LatLngBounds(southwest: southwest, northeast: northeast);
      String dist = "";
      String distnVal = "";
      String durn = "";
      String durnVal = "";
      if (routes["legs"].isNotEmpty) {
        final Map<String, dynamic> leg = routes["legs"][0];
        dist = leg["distance"]["text"];
        distnVal = leg["distance"]["value"].toString();
        durn = leg["duration"]["text"];
        durnVal = leg["duration"]["value"].toString();
      }

      return MapModel(
        bounds: bounds,
        polyLinePts: PolylinePoints()
            .decodePolyline(routes["overview_polyline"]["points"]),
        totalDist: dist,
        distVal: distnVal,
        totalDur: durn,
        durVal: durnVal,
      );
    } catch (e) {
      throw e.toString();
    }
  }
}
