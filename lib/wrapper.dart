import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:jhatpat/models/driver_model.dart';
import 'package:jhatpat/permission.dart';
import 'package:jhatpat/services/database/database.dart';
import 'package:jhatpat/services/shared_pref.dart';
import 'package:jhatpat/shared/text_field_deco.dart';
import 'package:jhatpat/views/auth/auth_page.dart';

class WrapperPage extends StatefulWidget {
  const WrapperPage({Key? key}) : super(key: key);

  @override
  State<WrapperPage> createState() => _WrapperPageState();
}

class _WrapperPageState extends State<WrapperPage> {
  bool _riding = false;
  bool _error = false;
  final int _wrapperDuration = 2;

  @override
  void initState() {
    super.initState();
    splashMethod();
  }

  Future splashMethod() async {
    UserSharedPreferences.getLoggedInOrNot()
        ? await checkIfRiding().whenComplete(
            () async {
              if (_riding) {
                await UserSharedPreferences.setRideBool(true);
              }
              Navigator.of(context).pushAndRemoveUntil(
                  CupertinoPageRoute(
                      builder: (context) => const PermissionsPage()),
                  (route) => false);
            },
          )
        : Future.delayed(Duration(seconds: _wrapperDuration)).whenComplete(() =>
            Navigator.of(context).pushAndRemoveUntil(
                CupertinoPageRoute(
                    builder: (context) => const AuthenticationPage()),
                (route) => false));
  }

  Future<void> checkIfRiding() async {
    try {
      final BookingDetails bookingDetails =
          await DatabaseService(token: UserSharedPreferences.getUserToken()!)
              .postBookingStatus()
              .timeout(const Duration(seconds: 15), onTimeout: () {
        setState(() => _error = true);
        throw "Couldn't load data";
      });
      if (bookingDetails.pickupAdd != null) {
        if (bookingDetails.status == bookingStatusStates[0] ||
            bookingDetails.status == bookingStatusStates[2] ||
            bookingDetails.status == bookingStatusStates[3] ||
            bookingDetails.status == bookingStatusStates[4]) {
          setState(() => _riding = true);
        }
      }
    } catch (e) {
      null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: !_error
          ? Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Expanded(
                  child: Center(
                    child: Image.asset(
                      "assets/images/LogoWTxt.png",
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Image.asset(
                    "assets/images/SplashBottom.png",
                  ),
                ),
              ],
            )
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Image.asset(
                  "assets/images/LogoWTxt.png",
                ),
                const SizedBox(height: 40.0),
                Row(
                  children: <Widget>[
                    Icon(Icons.error, size: 38.0, color: Colors.red.shade800),
                    const SizedBox(width: 10.0),
                    Text(
                      "Couldn't connect to servers",
                      style:
                          TextStyle(fontSize: 16.0, color: Colors.red.shade800),
                    )
                  ],
                ),
              ],
            ),
    );
  }
}
