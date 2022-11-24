import 'package:paytm_allinonesdk/paytm_allinonesdk.dart';

Future<Map<dynamic, dynamic>> payTmPG(
    String amount, String orderId, String txnToken) async {
  const String mid = "YOUNGS41543881579809";
  final String callbackUrl =
      "https://securegw.paytm.in/theia/paytmCallback?ORDER_ID=$orderId";
  const bool isStaging = false;
  const bool restrictAppInvoke = false;
  Map<dynamic, dynamic>? map;
  try {
    map = await AllInOneSdk.startTransaction(
      mid,
      orderId,
      amount.trim(),
      txnToken,
      callbackUrl,
      isStaging,
      restrictAppInvoke,
    );
  } catch (e) {
    throw "Something went wrong, payment not processed";
  }
  if (map != null) {
    return map;
  } else {
    throw "Could not complete payment";
  }
}
