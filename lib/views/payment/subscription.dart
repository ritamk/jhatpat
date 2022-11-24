import 'package:flutter/material.dart';
import 'package:jhatpat/models/user_model.dart';
import 'package:jhatpat/services/database/database.dart';
import 'package:jhatpat/services/shared_pref.dart';
import 'package:jhatpat/shared/buttons.dart';
import 'package:jhatpat/shared/loading.dart';
import 'package:jhatpat/shared/snackbars.dart';
import 'package:jhatpat/views/payment/paytm.dart';

class SubscriptionPage extends StatefulWidget {
  const SubscriptionPage({Key? key}) : super(key: key);

  @override
  State<SubscriptionPage> createState() => _SubscriptionPageState();
}

class _SubscriptionPageState extends State<SubscriptionPage> {
  bool _paying = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Subscriptions"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: FutureBuilder<List<SubscriptionList>?>(
          future: DatabaseService().getSubscriptionsList(),
          initialData: const [],
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            return snapshot.connectionState == ConnectionState.done
                ? !snapshot.hasError
                    ? snapshot.hasData
                        ? snapshot.data.isNotEmpty
                            ? ListView.builder(
                                physics: const BouncingScrollPhysics(
                                    parent: AlwaysScrollableScrollPhysics()),
                                itemCount: snapshot.data.length,
                                itemBuilder: (BuildContext context, int index) {
                                  final List<SubscriptionList> list =
                                      snapshot.data;
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 8.0),
                                    child: Card(
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(15.0)),
                                      child: ListTile(
                                        contentPadding:
                                            const EdgeInsets.all(8.0),
                                        title: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: <Widget>[
                                            Text(
                                              list[index].name!,
                                              style: const TextStyle(
                                                  fontSize: 18.0,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            Text(
                                              "₹ ${list[index].fees!}",
                                              style: const TextStyle(
                                                  fontSize: 16.0,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black54),
                                            ),
                                          ],
                                        ),
                                        subtitle: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: <Widget>[
                                            const SizedBox(height: 10.0),
                                            Flexible(
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: <Widget>[
                                                  const Icon(Icons.mood),
                                                  const SizedBox(width: 5.0),
                                                  Text(
                                                      "Fee less bookings: ${list[index].freeBookings}"
                                                      "\n(valid for: ${list[index].freeBookingsValidity})"),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(height: 5.0),
                                            Flexible(
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: <Widget>[
                                                  const Icon(
                                                      Icons.monetization_on),
                                                  const SizedBox(width: 5.0),
                                                  Text(
                                                      "Booking fees: ${list[index].bookFees}"),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(height: 5.0),
                                            Flexible(
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: <Widget>[
                                                  const Icon(
                                                      Icons.calendar_month),
                                                  const SizedBox(width: 5.0),
                                                  Text(
                                                      "Plan validity: ${list[index].validity}"),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(height: 10.0),
                                            blackMaterialButtons(
                                              () => pay(
                                                list[index].id!,
                                                list[index].fees!,
                                              ),
                                              const Text(
                                                "Buy Plan",
                                                style: TextStyle(
                                                    fontSize: 16.0,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              )
                            : Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const <Widget>[
                                    Icon(Icons.error,
                                        color: Colors.red, size: 32.0),
                                    SizedBox(width: 20.0),
                                    Text(
                                      "Could not load subscription plans",
                                      style: TextStyle(
                                          color: Colors.red, fontSize: 16.0),
                                    )
                                  ],
                                ),
                              )
                        : const Center(
                            child: Loading(white: false, rad: 14.0),
                          )
                    : Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const <Widget>[
                            Icon(Icons.error, color: Colors.red, size: 32.0),
                            SizedBox(width: 20.0),
                            Text(
                              "Could not load subscription plans",
                              style:
                                  TextStyle(color: Colors.red, fontSize: 16.0),
                            )
                          ],
                        ),
                      )
                : const Center(
                    child: Loading(white: false, rad: 14.0),
                  );
          },
        ),
      ),
    );
  }

  Future<void> pay(String id, String fees) async {
    setState(() => _paying = true);
    try {
      final PaymentModel? subscriptionModel =
          await DatabaseService(token: UserSharedPreferences.getUserToken()!)
              .postSubscriptionInit(id);
      if (subscriptionModel != null) {
        final Map<dynamic, dynamic> map = await payTmPG(fees,
            subscriptionModel.orderId ?? "", subscriptionModel.txnToken ?? "");
        commonSnackbar("Payment successful", context);
        await DatabaseService(token: UserSharedPreferences.getUserToken()!)
            .postUpdateSubStatus(PaymentStatus(
              RESPMSG: map["RESPMSG"],
              CURRENCY: map["CURRENCY"],
              TXNID: map["TXNID"],
              ORDERID: map["ORDERID"],
              CHECKSUMHASH: map["CHECKSUMHASH"],
              TXNDATE: map["TXNDATE"],
              TXNAMOUNT: map["TXNAMOUNT"],
              PAYMENTMODE: map["PAYMENTMODE"],
              BANKNAME: map["BANKNAME"],
              RESPCODE: map["RESPCODE"],
              STATUS: map["STATUS"],
              BANKTXNID: map["BANKTXNID"],
              GATEWAYNAME: map["GATEWAYNAME"],
              MID: map["MID"],
            ))
            .then((value) => value
                ? commonSnackbar("Subscription status updated", context)
                : commonSnackbar(
                    "Couldn't update subscription status", context));
      }
    } catch (e) {
      commonSnackbar(e.toString(), context);
    }
    setState(() => _paying = false);
  }
}
