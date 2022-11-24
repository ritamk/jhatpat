import 'dart:async';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jhatpat/models/user_model.dart';
import 'package:jhatpat/services/database/database.dart';
import 'package:jhatpat/services/shared_pref.dart';
import 'package:jhatpat/shared/loading.dart';
import 'package:jhatpat/services/providers.dart';
import 'package:jhatpat/shared/snackbars.dart';
import 'package:jhatpat/views/home/home.dart';
import 'package:pinput/pinput.dart';
import 'package:platform_device_id/platform_device_id.dart';

class OTPVerificationField extends StatefulWidget {
  const OTPVerificationField({Key? key}) : super(key: key);

  @override
  State<OTPVerificationField> createState() => OTPVerificationFieldState();
}

class OTPVerificationFieldState extends State<OTPVerificationField> {
  final GlobalKey<FormState> _otpGlobalKey = GlobalKey<FormState>();
  String _otp = "";
  final TextEditingController _otpController = TextEditingController();
  final FocusNode _otpFocusNode = FocusNode();
  late Timer _timer;

  int _secsRem = 30;
  bool _canResendOtp = false;
  bool loading = false;
  bool resendOtpLoading = false;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      if (_secsRem != 0) {
        setState(() => _secsRem--);
      } else {
        setState(() => _canResendOtp = true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _otpGlobalKey,
      child: Column(
        children: <Widget>[
          SizedBox(
            width: double.infinity,
            child: Stack(
              children: <Widget>[
                const Center(
                  child: Text(
                    "OTP Verification",
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
                Positioned(
                  top: 0.0,
                  bottom: 0.0,
                  left: 0.0,
                  child: Consumer(builder: (context, ref, _) {
                    return IconButton(
                      padding: const EdgeInsets.all(0.0),
                      visualDensity: VisualDensity.compact,
                      onPressed: () =>
                          ref.read(otpScreenBoolProvider.state).state = false,
                      icon:
                          const Icon(Icons.arrow_back_ios, color: Colors.black),
                    );
                  }),
                ),
              ],
            ),
          ),
          Consumer(
            builder: (context, ref, __) {
              return Text(
                "\nPlease check your messages for the OTP"
                "\nthat has been sent to +91${ref.watch(phoneNumProvider)}",
                style: const TextStyle(color: Colors.black45),
                textAlign: TextAlign.center,
              );
            },
          ),
          const SizedBox(height: 30.0, width: 0.0),
          Consumer(builder: (context, ref, __) {
            return Pinput(
              focusNode: _otpFocusNode,
              controller: _otpController,
              onChanged: (val) => _otp = val,
              onCompleted: (val) => verifyButton(context, ref),
              onSubmitted: (val) => verifyButton(context, ref),
              validator: (val) => validation(val),
              androidSmsAutofillMethod:
                  AndroidSmsAutofillMethod.smsUserConsentApi,
              listenForMultipleSmsOnAndroid: true,
              autofocus: true,
            );
          }),
          const SizedBox(height: 5.0, width: 0.0),
          Align(
            alignment: Alignment.centerRight,
            child: _canResendOtp
                ? Consumer(
                    builder: (context, ref, __) {
                      return TextButton(
                        style: ButtonStyle(
                            padding: MaterialStateProperty.all(
                                const EdgeInsets.all(0.0))),
                        onPressed: () => resendOtpButton(context, ref),
                        child: !resendOtpLoading
                            ? const Text(
                                "Resend OTP",
                                style: TextStyle(
                                    fontSize: 15.0,
                                    color: Colors.black54,
                                    fontWeight: FontWeight.bold),
                              )
                            : const Loading(white: false),
                      );
                    },
                  )
                : Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: RichText(
                      text: TextSpan(
                        children: <TextSpan>[
                          const TextSpan(text: "Request OTP again after "),
                          TextSpan(
                            text: _secsRem.toString(),
                            style: const TextStyle(
                                fontSize: 14.0,
                                color: Colors.black54,
                                fontWeight: FontWeight.bold),
                          ),
                          const TextSpan(text: " seconds"),
                        ],
                        style: const TextStyle(
                            fontSize: 13.0, color: Colors.black54),
                      ),
                    ),
                  ),
          ),
          const SizedBox(height: 5.0, width: 0.0),
          Consumer(
            builder: (context, ref, __) {
              return MaterialButton(
                onPressed: () => verifyButton(context, ref),
                child: !loading
                    ? const Text(
                        "Verify",
                        style: TextStyle(fontSize: 16.0),
                      )
                    : const Loading(white: true),
                minWidth: double.infinity,
                elevation: 0.0,
                focusElevation: 0.0,
                highlightElevation: 0.0,
                color: Colors.black,
                textColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5.0)),
              );
            },
          ),
        ],
      ),
    );
  }

  void resendOtpButton(BuildContext context, WidgetRef ref) async {
    setState(() => resendOtpLoading = true);

    try {
      final UserLoginRegData? result = await DatabaseService()
          .postLoginRegister(phNum: ref.watch(phoneNumProvider));
      if (result.runtimeType == UserLoginRegData) {
        commonSnackbar("OTP resent successfully", context);
        ref.read(tokenProvider.state).state = result?.token;
        setState(() {
          _secsRem = 30;
          _canResendOtp = false;
        });
      } else {
        commonSnackbar("Something went wrong, please try again", context);
      }
    } catch (e) {
      commonSnackbar("e.toString()", context);
      setState(() => loading = false);
    }
    setState(() => resendOtpLoading = false);
  }

  verifyButton(BuildContext context, WidgetRef ref) async {
    final String? token = ref.watch(tokenProvider);

    if (_otpGlobalKey.currentState!.validate()) {
      setState(() => loading = true);

      if (token != null) {
        try {
          final String? id = await PlatformDeviceId.getDeviceId;
          final bool verifiedOrNot = await DatabaseService(token: token)
              .postVerifyOtp(_otp, id ?? "")
              .whenComplete(() {
            setState(() => loading = false);
          });

          if (verifiedOrNot) {
            await UserSharedPreferences.setLoggedInOrNot(true)
                .whenComplete(() async =>
                    await UserSharedPreferences.setUserPhoneNum(
                        ref.watch(phoneNumProvider)))
                .whenComplete(
                    () async => await UserSharedPreferences.setUserToken(token))
                .whenComplete(() async {
              var deviceInfo = DeviceInfoPlugin();
              String id = "";
              if (Platform.isIOS) {
                var iosDeviceInfo = await deviceInfo.iosInfo;
                id = iosDeviceInfo.identifierForVendor!;
              } else if (Platform.isAndroid) {
                var androidDeviceInfo = await deviceInfo.androidInfo;
                id = androidDeviceInfo.id!;
              }
              await UserSharedPreferences.setDeviceInfo(id);
            }).whenComplete(() {
              ref.read(phoneNumProvider.state).state = "";
              ref.read(tokenProvider.state).state = "";
            }).whenComplete(
              () => Navigator.pushAndRemoveUntil(
                  context,
                  CupertinoPageRoute(builder: (context) => const HomePage()),
                  (route) => false),
            );
          } else {
            await UserSharedPreferences.setLoggedInOrNot(false).whenComplete(
                () => commonSnackbar("OTP does not match", context));
            _otp = "";
            _otpController.clear();
          }
        } catch (e) {
          commonSnackbar("Something went wrong, please try again", context);
        }
      } else {
        commonSnackbar("No phone number provided", context);
        setState(() => loading = false);
      }
    }
  }

  String? validation(val) {
    if (val != null) {
      if (val.isEmpty) {
        return "Please enter the OTP";
      } else if (val.isNotEmpty &&
          (val.length < 4 ||
              val.length > 4 ||
              !val.contains(RegExp("[0-9]")))) {
        return "Please enter a valid OTP";
      } else {
        return null;
      }
    } else {
      return "Please enter the OTP";
    }
  }

  @override
  void dispose() {
    _otpController.dispose();
    _otpFocusNode.dispose();
    _timer.cancel();
    super.dispose();
  }
}
