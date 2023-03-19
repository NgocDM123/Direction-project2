import 'package:firebase_database/firebase_database.dart';

import '../constant.dart';

class MeasuredData {
  String fieldName;
  double rainFall; //(measure)
  double relativeHumidity; //(measure)
  double temperature; //(measure) nhiet do khong khi
  double windSpeed; //(measure)
  double radiation; //(measure) buc xa be mat cay trong

  // MeasuredData(
  //     {required this.fieldName,
  //     required this.rainFall,
  //     required this.humidity30,
  //     required this.humidity60,
  //     required this.temperature,
  //     required this.soilTemperature,
  //     required this.windSpeed,
  //     required this.Rn});

  MeasuredData(this.fieldName, this.rainFall, this.relativeHumidity,
      this.temperature, this.windSpeed, this.radiation);

  MeasuredData.newOne(String name)
      : fieldName = name,
        rainFall = 0,
        relativeHumidity = 0,
        temperature = 0,
        windSpeed = 0,
        radiation = 0;

  Future<void> getDataFromDb(DateTime time) async {
    DataSnapshot data;
    String dayPath =
        '${_format(time.year)}-${_format(time.month)}-${_format(time.day)}';
    // String timePath =
    //     '${_format(time.hour)}:${_format(time.minute)}:${_format(time.second)}';

    DataSnapshot snapshot = await FirebaseDatabase.instance
        .ref(
            '${Constant.USER}/${this.fieldName}/${Constant.MEASURED_DATA}/$dayPath')
        .get();
    if (snapshot.exists) {
      var length = snapshot.children.length;
      if (length > 3) {
        data = snapshot.children.elementAt(length - 3);
      } else {
        data = snapshot.children.elementAt(0);
      }
    } else {
      snapshot = await FirebaseDatabase.instance
          .ref('${Constant.USER}/${this.fieldName}/${Constant.MEASURED_DATA}')
          .get();
      var a = snapshot.children.last; // di den ngay muon nhat
      var length = a.children.length;
      var lastData = a.children.elementAt(length - 3);
      data = lastData;
    }
    this.relativeHumidity =
        double.parse(data.child('${Constant.RELATIVE_HUMIDITY}').value.toString());
    this.temperature =
        double.parse(data.child('${Constant.TEMPERATURE}').value.toString());
    this.rainFall =
        double.parse(data.child('${Constant.RAIN_FALL}').value.toString());
    this.windSpeed =
        double.parse(data.child('${Constant.WIND_SPEED}').value.toString());
    this.radiation = double.parse(data.child('${Constant.RADIATION}').value.toString());
  }

  Future<void> writeDataToDb() async {
    DatabaseReference ref = FirebaseDatabase.instance
        .ref('${Constant.USER}/${this.fieldName}/${Constant.MEASURED_DATA}');
    await ref.update({});
  }

  Future<List<double>> getAllRainfallFromDb() async {
    List<double> rainFall = [];
    DataSnapshot snapshot = await FirebaseDatabase.instance
        .ref('${Constant.USER}/${this.fieldName}/${Constant.MEASURED_DATA}')
        .get();
    for (DataSnapshot snapshotChild in snapshot.children) {
      for (DataSnapshot child in snapshotChild.children) {
        var value =
            double.parse(child.child('${Constant.RAIN_FALL}').value.toString());
        rainFall.add(value);
      }
    }
    // print (rainFall);
    return rainFall;
  }

  String _format(int n) {
    if (n < 10)
      return '0$n';
    else
      return '$n';
  }
}
