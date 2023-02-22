import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:math';
import 'package:path_provider/path_provider.dart';
import 'package:direction/draw_graph/models/feature.dart';
import 'package:direction/classParameterSet.dart';

import 'simulated_model.dart';

//Fields is a singleton class that gives any widget access to the fields
class Fields {
  static final Fields _singleton = Fields._internal();

  static var _fieldList = [
    //ParameterSet(fieldName: 'Default Field'),
    //ParameterSet(fieldName: 'f2'),
  ];

  static int _selectedField = 0;
  static bool _dbread = false;
  static List<String> listField = [''];
  static List<int> rainDays = [];
  static List<double> rain = [];
  static List<int> numberDays = [];
  static List<int> DAP = [];
  static List<double> Th30 = [];
  static List<double> Th60 = [];
  static List<int> numDays = [];


  //for reading and writing to database so we can store values locally
  //
  // Increment this version when you need to change the schema.
  //TODO if you change the schema, you must implement the _onVersionChange method! Note that fromMap() is relatively robust to changes and will simply ignore, the error comes when writing records to a table that has a wrong schema
  // note at the moment this will simply create a new database with the increased number in the name.
  // note that the old database is not deleted.
  static final databaseVersion = 15;
  //
  //// This is the actual database filename that is saved in the docs directory.
  static final _databaseName = "parameterset.v$databaseVersion.sqlite.db";

  static final tableName = 'ParameterSet';
  // Only allow a single open connection to the database.
  static Database? _database;
  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  /// open the database//
  static _initDatabase() async {
    print('opening database');
    // The path_provider plugin gets the right directory for Android or iOS.
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    print('Connecting to database in ${documentsDirectory.path}');
    String path = join(documentsDirectory.path, _databaseName);
    // Open the database. Can also add an onUpdate callback parameter.
    return await openDatabase(
      path,
      version: databaseVersion,
      onCreate: _onCreate,
      onDowngrade: _onVersionChange,
      onUpgrade: _onVersionChange,
    );
  }

  /// SQL string to create the database //
  static Future _onCreate(Database db, int version) async {
    print("creating new database with version $version");
    await db.execute('''
              CREATE TABLE "$tableName" (
                ${ParameterSet.sqlSchema()}
              )
              ''');
  }

  static Future<void> _onVersionChange(
      Database db, int oldVersion, int newVersion) async {
    print("Conversion database necessary but not implemented");
    //todo rename table
    //todo create new table
    //todo migrate entries
    //todo delete renamed table
  }

  static Future toDisk() async {
    print("writing data to disk");
    Database db = await database;
    // for safety let's not try to update but simply replace all entries
    db.delete(tableName); //deletes all rows in the table
    var batch = db.batch();
    //todo what if table is not empty?
    _fieldList.forEach((e) async {
      //note db.insert return an int for the unique id
      batch.insert(
          tableName, e.toMap()); //inserts if not exists, otherwise replaces
    });
    await batch.commit(
      noResult: true,
    );
  }

  static Future fromDisk() async {
    if (!_dbread) {
      print("reading data from disk");
      //throw away any records
      _fieldList.clear();
      Database db = await database;
      List<Map<String, dynamic>> maps = await db.query(
        tableName,
        //where: 'id = ?',
      );
      maps.forEach((element) {
        _fieldList.insert(_fieldList.length, ParameterSet.fromMap(element));
      });
      _dbread = true;
    }
  }

  static ParameterSet getCurrentField() {
    return _fieldList[_selectedField];
  }

  static void setCurrentField(int i) {
    if (i < 0) i = 0;
    if (i > _fieldList.length - 1) i = _fieldList.length - 1;
    _selectedField = i;
    //toDisk();//this is called many times when sliding a slider
  }

  static int length() {
    return _fieldList.length;
  }

  static void insert(String fn) {
    if (fn.isEmpty) fn = "unnamed field";
    bool found = false;
    _fieldList.forEach((fe) => {if (fe.fieldName == fn) found = true});
    if (found) {
      //print(fn);
      insert(fn + '+');
    } else {
      //unique name
      _fieldList.insert(0, ParameterSet(fieldName: fn));
    }
    toDisk();
  }

  static ParameterSet removeAt(int i) {
    final removed = _fieldList.removeAt(i);
    toDisk();
    return removed;
  }

  static ParameterSet at(int i) {
    return _fieldList[i];
  }

  static List<Feature> getFeatures() {
    var rl = (List<Feature>.generate(
        _fieldList.length, (index) => _fieldList[index].getFeature()));
    double mv = 0;
    for (final e in rl) {
      mv = max(mv, e.data.reduce(max));
    }
    //need explicit copy here, as otherwise we scale the original data
    for (final e in rl) {
      for (int i = 0; i < e.data.length; i++) e.data[i] /= mv;
    }
    print('getFeatures is scaling with $mv');
    //print(rl[0].data);
    return (rl);
  }

  static List<Feature> getFeatures2() {
    var rl = (List<Feature>.generate(
        _fieldList.length, (index) => _fieldList[index].getFeature2()));
    double mv = 0;
    for (final e in rl) {
      mv = max(mv, e.data.reduce(max));
    }
    //need explicit copy here, as otherwise we scale the original data
    for (final e in rl) {
      for (int i = 0; i < e.data.length; i++) e.data[i] /= mv;
    }
    print('getFeatures is scaling with $mv');
    //print(rl[0].data);
    return (rl);
  }

  static double getStartTime() {
    double st = ParameterNames.istart.max();
    _fieldList.forEach((element) {
      st = min(element.getSimulationParameter(ParameterNames.istart), st);
    });
    return st;
  }

  static double getEndTime() {
    double st = ParameterNames.iend.min();
    _fieldList.forEach((element) {
      st = max(element.getSimulationParameter(ParameterNames.iend), st);
    });
    //st += Fields.getStartTime();
    return st;
  }

  static List<String> getFeaturesX() {
    final dt = (Fields.getEndTime() - Fields.getStartTime()) /
        (SimulationModel.printSize - 1).toDouble();
    return (List<String>.generate(SimulationModel.printSize, (index) {
      if (index % (SimulationModel.printSize ~/ 5) == 0) {
        final xv = Fields.getStartTime() + index.toDouble() * dt;
        return xv.toStringAsFixed(0);
      } else {
        return '';
      }
    }));
  }

  static List<String> getFeaturesY() {
    final rl = (List<double>.generate(
        _fieldList.length, (index) => _fieldList[index].getDataMax()));
    double mv = rl.reduce(max);
    print('getFeaturesY max is $mv');
    int r = mv < 4
        ? 2
        : mv < 10
            ? 1
            : 0;

    return [
      (0.25 * mv).toStringAsFixed(r),
      (0.5 * mv).toStringAsFixed(r),
      (0.75 * mv).toStringAsFixed(r),
      mv.toStringAsFixed(r)
    ];
  }

  static List<String> getFeaturesY2() {
    final rl = (List<double>.generate(
        _fieldList.length, (index) => _fieldList[index].getDataMax2()));
    double mv = rl.reduce(max);
    print('getFeaturesY2 max is $mv');
    int r = mv < 4
        ? 2
        : mv < 10
            ? 1
            : 0;

    return [
      (0.25 * mv).toStringAsFixed(r),
      (0.5 * mv).toStringAsFixed(r),
      (0.75 * mv).toStringAsFixed(r),
      mv.toStringAsFixed(r)
    ];
  }

  static Future<File?> downloadFile(String url, String name) async {
    final appStorage = await getApplicationDocumentsDirectory();
    final filePath = '${appStorage.path}/$name';
    final file = File(filePath);

    final dio = Dio();

    try {
      Response response = await dio.get(
        url,
        options: Options(
          responseType: ResponseType.bytes,
          followRedirects: false,
          receiveTimeout: 0,
        ),
      );

      final raf = file.openSync(mode: FileMode.write);
      raf.writeFromSync(response.data);
      await raf.close();

      print("karinadsvjbksjfvbkj: $file");
      return file;
    } catch(e) {
      return null;
    }
  }

  static Future readCsvFile() async {
    print('length: ${_fieldList.length}');
    String url = 'https://firebasestorage.googleapis.com/v0/b/direction-cc9b5.appspot.com/o/';
    String fileName = 'getUrl.csv';
    await downloadFile(url, fileName);

    int check = 0;

    final directory = await getApplicationDocumentsDirectory();
    final fileUrl = File('${directory.path}/getUrl.csv');
    String textUrl = await fileUrl.readAsString();
    final getLine = textUrl.split('\n');

    for (var line in getLine) {
      if (line.contains('\"name\":')) {
        final path = line.split('\"');
        final str = path[3].split('/');
        var test = 0;

        for (int k = 0; k < Fields.listField.length; k++) {
          if (str[0] == Fields.listField[k]) {
            test |= 1;
          }
        }
        if (test == 0) {
          Fields.listField.add(str[0]);
        }
      }
    }
    listField.removeAt(0);

//----------------------------------Get Rain Days-----------------------------------
    for (int k = 0; k < Fields.listField.length; k++) {
      String url = 'https://firebasestorage.googleapis.com/v0/b/direction-cc9b5.appspot.com/o/'
          '${listField[k]}%2FBRR2021-Y1_WeatherStationData.csv?alt=media&token=';
      String fileName = '${listField[k]}_BRR2021-Y1_WeatherStationData.csv';
      await downloadFile(url, fileName);

      final file = File('${directory.path}/$fileName');
      String text = await file.readAsString();
      final lines = text.split('\n');
      final sd = DateTime.parse('2021-04-02');

      lines.removeAt(0);

      final value = lines[0].split(',');
      var datetime = value[0].split('T');
      final startDay = DateTime.parse(datetime[0]);
      final difference = startDay.difference(sd).inDays;
      String diff = difference.toString();
      int day = int.parse(diff);

      List<String> days = [''];
      for (var line in lines) {

        final values = line.split(',');
        var date = values[0].split('T');
        check = 0;

        for (int m = 0; m < days.length; m++) {
          if (date[0] == days[m]) {
            check |= 1;
          }
        }
        if (check == 0) {
          days.add(date[0]);
        }
      }

      days.removeAt(0);
      List<double> tempRain = List<double>.filled(days.length, 0.00);
      var number = List<int>.filled(days.length, 0);
      for (var line in lines) {
        final values = line.split(',');
        var date = values[0].split('T');
        for (int n = 0; n < days.length; n++) {
          if (date[0] == days[n]) {
            if (double.parse(values[1]) != 0.0) {
              tempRain[n] += double.parse(values[1]);
              number[n]++;
            }
          }
        }
      }

      int a = tempRain.length;
      for (int p = 0; p < tempRain.length; p++) {
        if (number[p] != 0) {
          tempRain[p] /= number[p];
        }
      }

      List<int> tempRainDays = [0];
      tempRainDays[0] = day;
      for (int q = 1; q < tempRain.length; q++) {
        tempRainDays.add(tempRainDays[0] + q);
      }

      Fields.rainDays.addAll(tempRainDays);
      Fields.rain.addAll(tempRain);
      Fields.numberDays.add(a);
      print('karinaalengthTh60: ${Fields.numberDays.length}');
      print('karinaDAP: ${Fields.numberDays}');

    }
//-------------------------------Get Soil Water Content Days-----------------------------------
    for (int ki = 0; ki < Fields.listField.length; ki++) {
      String url = 'https://firebasestorage.googleapis.com/v0/b/direction-cc9b5.appspot.com/o/'
          '${listField[ki]}%2FmeanSoilMoistureData.csv?alt=media&token=';
      String fileName = '${listField[ki]}_meanSoilMoistureData.csv';
      await downloadFile(url, fileName);
      final file = File('${directory.path}/$fileName');
      String text = await file.readAsString();
      final lines = text.split('\n');
      lines.removeAt(0);

      List<int> days = [-1];
      for (var line in lines) {
        final values = line.split(',');
        final date = values[0].split('.');
        check = 0;
        //print('Th60: ${date[0]}');
        for (int mi = 0; mi < days.length; mi++) {
          if (date[0].length > 0 && int.parse(date[0]) == days[mi]) {
            check |= 1;
          }
        }
        if (check == 0 && date[0].length > 0) {
          days.add(int.parse(date[0]));
        }
      }
      days.removeAt(0);
      List<double> tempTh30 = List<double>.filled(days.length, 0.00);
      List<double> tempTh60 = List<double>.filled(days.length, 0.00);
      var number = List<int>.filled(days.length, 0);
      for (var line in lines) {
        final values = line.split(',');
        var date = values[0].split('.');
        for (int ni = 0; ni < days.length; ni++) {
          if (date[0].length > 0 && int.parse(date[0]) == days[ni]) {
            if (values[1] != 'NA' && values[2] != 'NA') {
              tempTh30[ni] += double.parse(values[1]);
              tempTh60[ni] += double.parse(values[2]);
              number[ni]++;
            }
          }
        }
      }

      for (int pi = 0; pi < days.length; pi++) {
        if (number[pi] != 0) {
          tempTh30[pi] /= number[pi];
          tempTh60[pi] /= number[pi];
        }
      }

      Fields.DAP.addAll(days);
      Fields.Th30.addAll(tempTh30);
      Fields.Th60.addAll(tempTh60);
      Fields.numDays.add(days.length);

    }
    // print('karinalength: ${Fields.rainDays.length}');
    // print('karinaalength: ${Fields.rain.length}');
    // print('karina: ${Fields.rainDays}');
    // print('karinaa: ${Fields.rain}');
    // print('karinalengthDAP: ${Fields.DAP.length}');
    // print('karinaalengthTh30: ${Fields.Th30.length}');
    // print('karinaalengthTh60: ${Fields.Th60.length}');
    // print('karinaDAP: ${Fields.DAP}');
    // print('karinaaTh30: ${Fields.Th30}');
    // print('Th60: ${Fields.Th60}');
    print('karinaalengthTh60: ${Fields.listField.length}');
    print('karinaDAP: ${Fields.listField}');
    print('karinaalengthTh60: ${Fields.numberDays.length}');
    print('karinaDAP: ${Fields.numberDays}');

  }

  factory Fields() {
    return _singleton;
  }

  Fields._internal();
}
