import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:jhatpat/services/shared_pref.dart';
import 'package:jhatpat/shared/buttons.dart';
import 'package:jhatpat/shared/loading.dart';
import 'package:jhatpat/views/home/home.dart';
import 'package:jhatpat/views/home/location_services.dart';
import 'package:jhatpat/views/home/ride.dart';

class PermissionsPage extends StatefulWidget {
  const PermissionsPage({Key? key}) : super(key: key);

  @override
  State<PermissionsPage> createState() => _PermissionsPageState();
}

class _PermissionsPageState extends State<PermissionsPage> {
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    getLoc().whenComplete(() => setState(() => _loading = false));
  }

  Future<void> getLoc() async {
    determinePosition().then((value) => value.runtimeType == Position
        ? UserSharedPreferences.getRideBool()
            ? Navigator.of(context).pushAndRemoveUntil(
                CupertinoPageRoute(builder: (context) => const RidePage()),
                (route) => false)
            : Navigator.of(context).pushAndRemoveUntil(
                CupertinoPageRoute(builder: (context) => const HomePage()),
                (route) => false)
        : null);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: !_loading
            ? Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    const Icon(Icons.location_on,
                        size: 48.0, color: Colors.black54),
                    const SizedBox(height: 15.0),
                    const Text(
                      "Location permission required",
                      style: TextStyle(
                          fontSize: 18.0,
                          color: Colors.black54,
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20.0),
                    blackMaterialButtons(
                      () {
                        setState(() => _loading = true);
                        getLoc().whenComplete(
                            () => setState(() => _loading = false));
                      },
                      const Text("Retry", style: TextStyle(fontSize: 16.0)),
                    ),
                  ],
                ),
              )
            : const Loading(white: false, rad: 14.0),
      ),
    );
  }
}
