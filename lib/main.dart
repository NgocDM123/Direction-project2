import 'package:direction/classFields.dart';
import 'package:flutter/material.dart';
//languages see https://docs.flutter.dev/development/accessibility-and-localization/internationalization
//TODO ios language support needs additional steps in xcode, see website above
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart'; //generate code for language switch

//database management
import 'dart:io' show Platform;
import 'dart:async';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite/sqflite.dart';
import 'package:firebase_core/firebase_core.dart';
//import 'package:path/path.dart';
//import 'package:sqflite/sqflite.dart';

//project files
import 'package:direction/page_welcome.dart';
import 'package:direction/page_userData.dart';
import 'package:direction/page_prognoses.dart';
import 'package:direction/field_list.dart';
//import 'package:direction/classFields.dart';
var readFile = 0;

Future main() async {
  if (Platform.isWindows || Platform.isLinux) {
    // Initialize FFI
    sqfliteFfiInit();
    // Change the default factory
    databaseFactory = databaseFactoryFfi;
  }

  runApp(MyApp());
  if (readFile == 0) {
    readFile++;
    await Fields.readCsvFile();
  }
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      //onGenerateTitle: (BuildContext context) =>
      //    {AppLocalizations.of(context).tab1},
      title: 'DIRECTION-cassava',
      locale: Locale('en'),
      localizationsDelegates: [
        AppLocalizations.delegate, // Add this line
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        Locale('en', ''), // English, no country code
        Locale('th', ''), // Thai, no country code
        Locale('vi', ''), // Thai, no country code
      ],
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      //home: MyHomePage(title: 'Cassava irrigation'),
      home: DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
              flexibleSpace: new Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                TabBar(
                  tabs: [
                    Tab(icon: Icon(Icons.agriculture)),
                    Tab(icon: Icon(Icons.table_chart_outlined)),
                    Tab(icon: Icon(Icons.analytics)),
                    Tab(icon: Icon(Icons.agriculture)),
                  ],
                ),
              ])),
          body: TabBarView(
            children: [
              MyHomePage(title: ""),
              UserDataPage(title: "user"),
              PrognosesPage(title: ""),
              FieldList(),
            ],
          ),
        ),
      ),
    );
  }
}
