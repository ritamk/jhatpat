import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jhatpat/models/user_model.dart';
import 'package:jhatpat/services/database/database.dart';
import 'package:jhatpat/shared/loading.dart';
import 'package:jhatpat/shared/snackbars.dart';

class PromotionalsPage extends StatefulWidget {
  const PromotionalsPage({Key? key}) : super(key: key);

  @override
  State<PromotionalsPage> createState() => _PromotionalsPageState();
}

class _PromotionalsPageState extends State<PromotionalsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Promotional Codes"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: FutureBuilder<List<CouponsModel>?>(
          future: DatabaseService().postAllCouponsList(null, null),
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
                                  final List<CouponsModel> list = snapshot.data;
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 8.0),
                                    child: Card(
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(15.0)),
                                      child: ListTile(
                                        onTap: () {
                                          Clipboard.setData(ClipboardData(
                                              text: list[index].code));
                                          commonSnackbar(
                                              "Coupon code copied to clipboard",
                                              context);
                                        },
                                        title: Padding(
                                          padding: const EdgeInsets.all(16.0),
                                          child: Row(
                                            children: <Widget>[
                                              Expanded(
                                                child: Text(
                                                  list[index].code!,
                                                  style: const TextStyle(
                                                      fontSize: 18.0,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                              Text(
                                                "${list[index].discValue}% OFF!",
                                                style: TextStyle(
                                                    fontSize: 16.0,
                                                    fontStyle: FontStyle.italic,
                                                    fontWeight: FontWeight.bold,
                                                    color:
                                                        Colors.blue.shade800),
                                              ),
                                            ],
                                          ),
                                        ),
                                        subtitle: Padding(
                                          padding: const EdgeInsets.only(
                                              left: 16.0,
                                              right: 16.0,
                                              bottom: 16.0),
                                          child: Text(list[index].details!),
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
                                      "No promotional coupons available",
                                      style: TextStyle(
                                          color: Colors.red, fontSize: 16.0),
                                    )
                                  ],
                                ),
                              )
                        : const Center(child: Loading(white: false, rad: 14.0))
                    : Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const <Widget>[
                            Icon(Icons.error, color: Colors.red, size: 32.0),
                            SizedBox(width: 20.0),
                            Text(
                              "Could not load promotional coupons",
                              style:
                                  TextStyle(color: Colors.red, fontSize: 16.0),
                            )
                          ],
                        ),
                      )
                : const Center(child: Loading(white: false, rad: 14.0));
          },
        ),
      ),
    );
  }
}
