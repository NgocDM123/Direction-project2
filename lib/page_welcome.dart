import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key) {}

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white54,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.tab1),
        automaticallyImplyLeading: false, //jp added because of graph
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(
              AppLocalizations.of(context)!.welcomeMessage,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
            Text(
              AppLocalizations.of(context)!.instructionMessage,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.normal,
                letterSpacing: 1,
              ),
            ),
            Container(
              child: Image.asset(
                "assets/images/VNU-UET.jpg",
                width: 150,
                height: 150,
              ),
              padding: EdgeInsets.only(top: 20),
              alignment: Alignment.center,
            ),
            Image.asset(
              "assets/images/logoFZJ.png",
              width: 200,
              height: 200,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 64.0),
              child: Text(
                AppLocalizations.of(context)!.disclaimerMessage,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.normal,
                  letterSpacing: 1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
