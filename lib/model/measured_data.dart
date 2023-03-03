import 'package:firebase_database/firebase_database.dart';

import '../constant.dart';

class MeasuredData {
  String fieldName;
  double rainFall; //(measure)
  double humidity30; //(measure)
  double humidity60; //(measure)
  double temperature; //(measure) nhiet do khong khi
  double soilTemperature; //(measure)
  double windSpeed; //(measure)
  double Rn; //(measure) buc xa be mat cay trong

  // MeasuredData(
  //     {required this.fieldName,
  //     required this.rainFall,
  //     required this.humidity30,
  //     required this.humidity60,
  //     required this.temperature,
  //     required this.soilTemperature,
  //     required this.windSpeed,
  //     required this.Rn});

  MeasuredData(this.fieldName, this.rainFall, this.humidity30, this.humidity60,
      this.temperature, this.soilTemperature, this.windSpeed, this.Rn);

  MeasuredData.newOne(String name)
      : fieldName = name,
        rainFall = 0,
        humidity30 = 0,
        humidity60 = 0,
        temperature = 0,
        soilTemperature = 0,
        windSpeed = 0,
        Rn = 0;


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
      data = snapshot.children.elementAt(length - 3);
    } else {
      snapshot = await FirebaseDatabase.instance
          .ref('${Constant.USER}/${this.fieldName}/${Constant.MEASURED_DATA}')
          .get();
      var a = snapshot.children.last; // di den ngay muon nhat
      var length = a.children.length;
      var lastData = a.children.elementAt(length - 3);
      data = lastData;
    }
    this.humidity30 =
        double.parse(data.child('${Constant.HUMIDITY_30}').value.toString());
    this.humidity60 =
        double.parse(data.child('${Constant.HUMIDITY_60}').value.toString());
    this.temperature =
        double.parse(data.child('${Constant.TEMPERATURE}').value.toString());

  }

  String _format(int n) {
    if (n < 10)
      return '0$n';
    else
      return '$n';
  }
}
