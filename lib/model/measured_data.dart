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

  Future<void> getRainFallFromDb() async {
    DataSnapshot snapshot = await FirebaseDatabase.instance
        .ref('${Constant.USER}/${this.fieldName}/${Constant.MEASURED_DATA}')
        .get();
    var a = snapshot.child('${Constant.RAIN_FALL}');
    this.rainFall = double.parse(a.value.toString());
  }

  Future<void> getHumidity30FromDb() async {
    DataSnapshot snapshot = await FirebaseDatabase.instance
        .ref('${Constant.USER}/${this.fieldName}/${Constant.MEASURED_DATA}')
        .get();
    var a = snapshot.child('${Constant.HUMIDITY_30}');
    this.humidity30 = double.parse(a.value.toString());
  }

  Future<void> getHumidity60FromDb() async {
    DataSnapshot snapshot = await FirebaseDatabase.instance
        .ref('${Constant.USER}/${this.fieldName}/${Constant.MEASURED_DATA}')
        .get();
    var a = snapshot.child('${Constant.HUMIDITY_60}');
    this.humidity60 = double.parse(a.value.toString());
  }

  Future<void> getTemperatureFromDb() async {
    DataSnapshot snapshot = await FirebaseDatabase.instance
        .ref('${Constant.USER}/${this.fieldName}/${Constant.MEASURED_DATA}')
        .get();
    var a = snapshot.child('${Constant.TEMPERATURE}');
    this.temperature = double.parse(a.value.toString());
  }

  Future<void> getSoilTemperatureFromDb() async {
    DataSnapshot snapshot = await FirebaseDatabase.instance
        .ref('${Constant.USER}/${this.fieldName}/${Constant.MEASURED_DATA}')
        .get();
    var a = snapshot.child('${Constant.SOIL_TEMPERATURE}');
    this.soilTemperature = double.parse(a.value.toString());
  }

  Future<void> getWindSpeedFromDb() async {
    DataSnapshot snapshot = await FirebaseDatabase.instance
        .ref('${Constant.USER}/${this.fieldName}/${Constant.MEASURED_DATA}')
        .get();
    var a = snapshot.child('${Constant.WIND_SPEED}');
    this.windSpeed = double.parse(a.value.toString());
  }

  Future<void> getRnFromDb() async {
    DataSnapshot snapshot = await FirebaseDatabase.instance
        .ref('${Constant.USER}/${this.fieldName}/${Constant.MEASURED_DATA}')
        .get();
    var a = snapshot.child('${Constant.RN}');
    this.Rn = double.parse(a.value.toString());
  }

  Future<void> getDataFromDb(DateTime time) async {
    String dayPath =
        '${_format(time.year)}-${_format(time.month)}-${_format(time.day)}';
    String timePath =
        '${_format(time.hour)}:${_format(time.minute)}:${_format(time.second)}';

    DataSnapshot snapshot = await FirebaseDatabase.instance
        .ref(
            '${Constant.USER}/${this.fieldName}/${Constant.MEASURED_DATA}/$dayPath/$timePath')
        .get();
    print(snapshot.value);
    // var a = snapshot.child('${Constant.RAIN_FALL}');
    // this.rainFall = double.parse(a.value.toString());
    // a = snapshot.child('${Constant.HUMIDITY_30}');
    // this.humidity30 = double.parse(a.value.toString());
    // a = snapshot.child('${Constant.HUMIDITY_60}');
    // this.humidity60 = double.parse(a.value.toString());
    // a = snapshot.child('${Constant.TEMPERATURE}');
    // this.temperature = double.parse(a.value.toString());
    // a = snapshot.child('${Constant.SOIL_TEMPERATURE}');
    // this.soilTemperature = double.parse(a.value.toString());
    // a = snapshot.child('${Constant.WIND_SPEED}');
    // this.windSpeed = double.parse(a.value.toString());
    // a = snapshot.child('${Constant.RN}');
    // this.Rn = double.parse(a.value.toString());
  }

  String _format(int n) {
    if (n < 10)
      return '0$n';
    else
      return '$n';
  }
}
