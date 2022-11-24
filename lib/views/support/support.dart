import 'package:flutter/material.dart';
import 'package:jhatpat/services/database/database.dart';
import 'package:jhatpat/shared/loading.dart';
import 'package:url_launcher/url_launcher.dart';

class SupportPage extends StatelessWidget {
  const SupportPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Support")),
      body: FutureBuilder<String>(
        future: DatabaseService().getSupportNum(),
        initialData: "",
        builder: (context, snapshot) => snapshot.connectionState ==
                ConnectionState.done
            ? !snapshot.hasError
                ? snapshot.hasData
                    ? snapshot.data!.isNotEmpty
                        ? Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                const Text(
                                  "Contact support:",
                                  style: TextStyle(fontSize: 20.0),
                                ),
                                const SizedBox(width: 5.0),
                                IconButton(
                                    onPressed: () => launchUrl(Uri(
                                        scheme: "tel", path: snapshot.data)),
                                    icon: const Icon(Icons.phone,
                                        color: Colors.green, size: 32.0))
                              ],
                            ),
                          )
                        : Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const <Widget>[
                                Icon(Icons.error,
                                    color: Colors.red, size: 32.0),
                                SizedBox(width: 20.0),
                                Text(
                                  "Could not contact support",
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
                          "Could not contact support",
                          style: TextStyle(color: Colors.red, fontSize: 16.0),
                        )
                      ],
                    ),
                  )
            : const Center(child: Loading(white: false, rad: 14.0)),
      ),
    );
  }
}
