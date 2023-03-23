import 'package:firebase_database/firebase_database.dart';

import '../constant.dart';

class MeasuredData {
  String fieldName;
  double rainFall; //(measure)
  double relativeHumidity; //(measure) do am khong khi
  double temperature; //(measure) nhiet do khong khi
  double windSpeed; //(measure)
  double radiation; //(measure) buc xa be mat cay trong


  MeasuredData(this.fieldName, this.rainFall, this.relativeHumidity,
      this.temperature, this.windSpeed, this.radiation);

  MeasuredData.newOne(String name)
      : fieldName = name,
        rainFall = 0,
        relativeHumidity = 0,
        temperature = 0,
        windSpeed = 0,
        radiation = 0;


  Future<void> updateDataFromDb() async{ // co data tai time thi tra ve khong thi tim time o gan nhat
    DateTime time = DateTime.now();
    MeasuredData.getWeatherDataFromDb(Constant.USER, this.fieldName, time).then((value)  {
      this.radiation = value[0];
      this.rainFall = value[1];
      this.relativeHumidity = value[2];
      this.temperature = value[3];
      this.windSpeed = value[4];
    });
  }

  static Future<List<double>> getWeatherDataFromDb(String userName, String fieldName, DateTime time) async{
    List<double> weather = [];
    DataSnapshot data;
    String dayPath =
        '${Constant.format(time.year)}-${Constant.format(time.month)}-${Constant.format(time.day)}';
    String timePath =
        '${Constant.format(time.hour)}:${Constant.format(time.minute)}:${Constant.format(time.second)}';

    DataSnapshot snapshot = await FirebaseDatabase.instance
        .ref(
        '$userName/$fieldName/${Constant.MEASURED_DATA}/$dayPath/$timePath')
        .get();
    if (snapshot.exists) {
      data = snapshot;
    }

    snapshot = await FirebaseDatabase.instance
        .ref(
        '$userName/$fieldName/${Constant.MEASURED_DATA}/$dayPath')
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
          .ref('$userName/$fieldName/${Constant.MEASURED_DATA}')
          .get();
      var a = snapshot.children.last; // di den ngay muon nhat
      var length = a.children.length;
      if (length > 2) {
        var lastData = a.children.elementAt(length - 3);
        data = lastData;
      } else
        data = a.children.elementAt(0);
    }
    var relativeHumidity = double.parse(
        data.child('${Constant.RELATIVE_HUMIDITY}').value.toString());
    var temperature =
        double.parse(data.child('${Constant.TEMPERATURE}').value.toString());
    var rainFall =
        double.parse(data.child('${Constant.RAIN_FALL}').value.toString());
    var windSpeed =
        double.parse(data.child('${Constant.WIND_SPEED}').value.toString());
    var radiation =
        double.parse(data.child('${Constant.RADIATION}').value.toString());
    weather.add(radiation);
    weather.add(rainFall);
    weather.add(relativeHumidity);
    weather.add(temperature);
    weather.add(windSpeed);
    return weather;
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

  
}
