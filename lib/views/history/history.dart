import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:jhatpat/models/driver_model.dart';
import 'package:jhatpat/services/database/database.dart';
import 'package:jhatpat/services/shared_pref.dart';
import 'package:jhatpat/shared/loading.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({Key? key}) : super(key: key);

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Ride History")),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: FutureBuilder<List<BookingDetails>?>(
          future: DatabaseService(token: UserSharedPreferences.getUserToken()!)
              .postBookingHistory(),
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
                                  final List<BookingDetails> list =
                                      snapshot.data;
                                  try {
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8.0),
                                      child: Card(
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(15.0)),
                                        child: ListTile(
                                          title: Card(
                                            elevation: 0.0,
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        15.0)),
                                            child: Row(
                                              children: <Widget>[
                                                Expanded(
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: Container(
                                                      padding: const EdgeInsets
                                                              .symmetric(
                                                          vertical: 12.0,
                                                          horizontal: 8.0),
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(20.0),
                                                        color: const Color
                                                                .fromARGB(
                                                            31, 133, 133, 133),
                                                      ),
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: <Widget>[
                                                          Row(
                                                            children: <Widget>[
                                                              const Icon(
                                                                  Icons.circle,
                                                                  color: Colors
                                                                      .black),
                                                              const SizedBox(
                                                                  width: 10.0),
                                                              Expanded(
                                                                child: Text(
                                                                    list[index]
                                                                        .pickupAdd!,
                                                                    style: const TextStyle(
                                                                        fontSize:
                                                                            15.0,
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .bold),
                                                                    overflow:
                                                                        TextOverflow
                                                                            .ellipsis),
                                                              ),
                                                            ],
                                                          ),
                                                          const SizedBox(
                                                              height: 5.0),
                                                          Row(
                                                            children: <Widget>[
                                                              const Icon(
                                                                  Icons
                                                                      .move_down,
                                                                  color: Colors
                                                                      .black26),
                                                              const SizedBox(
                                                                  width: 10.0),
                                                              Text(
                                                                  "${list[index].dist!} km, ${(list[index].finalTime!).substring(0, 2)}:${(list[index].finalTime!).substring(3, 5)}:${(list[index].finalTime!).substring(6, 8)}"),
                                                            ],
                                                          ),
                                                          const SizedBox(
                                                              height: 5.0),
                                                          Row(
                                                            children: <Widget>[
                                                              Icon(Icons.circle,
                                                                  color: Colors
                                                                      .red
                                                                      .shade700),
                                                              const SizedBox(
                                                                  width: 10.0),
                                                              Expanded(
                                                                child: Text(
                                                                    list[index]
                                                                        .dropAdd!,
                                                                    style: const TextStyle(
                                                                        fontSize:
                                                                            15.0,
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .bold),
                                                                    overflow:
                                                                        TextOverflow
                                                                            .ellipsis),
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
                                          subtitle: Column(
                                            children: <Widget>[
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: <Widget>[
                                                  const Text(
                                                    "Ride Fee: ",
                                                  ),
                                                  Text(
                                                    "₹ ${list[index].finalDistFee ?? ""}",
                                                  ),
                                                ],
                                              ),
                                              if (list[index].convenienceFee !=
                                                  null)
                                                const SizedBox(height: 5.0),
                                              if (list[index].convenienceFee !=
                                                  null)
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: <Widget>[
                                                    const Text(
                                                      "Convenience Fee: ",
                                                    ),
                                                    Text(
                                                      "+ ₹ ${list[index].convenienceFee ?? ""}",
                                                    ),
                                                  ],
                                                ),
                                              if (list[index].extraAmount !=
                                                  null)
                                                const SizedBox(height: 5.0),
                                              if (list[index].extraAmount !=
                                                  null)
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: <Widget>[
                                                    const Text(
                                                      "Extra Fee: ",
                                                    ),
                                                    Text(
                                                      "+ ₹ ${list[index].extraAmount ?? ""}",
                                                    ),
                                                  ],
                                                ),
                                              if (list[index].disc != null)
                                                const SizedBox(height: 5.0),
                                              if (list[index].disc != null)
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: <Widget>[
                                                    const Text(
                                                      "Discount: ",
                                                    ),
                                                    Text(
                                                      "- ₹ ${list[index].disc ?? ""}",
                                                    ),
                                                  ],
                                                ),
                                              const SizedBox(height: 5.0),
                                              Container(
                                                width: double.infinity,
                                                height: 2.0,
                                                decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10.0),
                                                    color: Colors.black38),
                                              ),
                                              const SizedBox(height: 5.0),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: <Widget>[
                                                  const Text(
                                                    "Grand Total: ",
                                                    style: TextStyle(
                                                        fontSize: 16.0,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                  const Text("----"),
                                                  Text(
                                                    "₹ ${list[index].payableAmount ?? ""}",
                                                    style: const TextStyle(
                                                        fontSize: 16.0,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 5.0),
                                              Container(
                                                width: double.infinity,
                                                height: 2.0,
                                                decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10.0),
                                                    color: Colors.black38),
                                              ),
                                              const SizedBox(height: 10.0),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: <Widget>[
                                                  Text(
                                                      DateFormat("dd/MM/yy")
                                                          .format(DateTime
                                                              .parse(list[index]
                                                                  .bookingDate!))
                                                          .toString(),
                                                      textAlign:
                                                          TextAlign.center),
                                                  const SizedBox(width: 10.0),
                                                  const Text("•"),
                                                  const SizedBox(width: 10.0),
                                                  Text(list[index].status!,
                                                      textAlign:
                                                          TextAlign.center),
                                                ],
                                              ),
                                              const SizedBox(height: 10.0),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  } catch (e) {
                                    return const SizedBox();
                                  }
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
                                      "No user history available",
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
                              "Could not load user history",
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
