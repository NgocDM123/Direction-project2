import 'package:flutter/material.dart';
import 'firebase_options.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:math';

import 'draw_graph/models/feature.dart';
import 'simulated_model.dart';

const double _thr =
    0.0224; // residual water content // lượng nước bị giữ lại trong đất mà cây ko hấp thụ được
const double _depth = 1.2; // soil depth in m
const double _appi =
    0.80 * 1.00; // Area per plant (row x interrow spacing) (m2);
//const double _delta = 0.1; // tra bang [15] trong bao cao do an
const double _gamma = 0.067; //tra bang[15] trong bao cao do an

class Field {
  String fieldName;

  //final double Vs; // soil volume
  double rainFall; //(measure)
  int dAP; //day after plant
  double humidity30; //(measure)
  double humidity60; //(measure)
  double temperature; //(measure) nhiet do khong khi
  double soilTemperature; //(measure)
  double windSpeed; //(measure)
  double Rn; //(measure) buc xa be mat cay trong
  bool irrigation; //(determined from model)
  double amountOfIrrigation; // luong nuoc tuoi tieu (mm/day)
  double potentialYield; // (adjust by user)
  double iLA; //Leaf area index (adjust by user)
  double rgr; //relative growth rate (adjust by user)
  List<double> yields; // predicted by model
  String checkYieldDate; //
  bool autoIrrigation;

  Field({
    required this.fieldName,
    //required this.Vs,
    required this.rainFall,
    required this.dAP,
    required this.humidity30,
    required this.humidity60,
    required this.temperature,
    required this.soilTemperature,
    required this.windSpeed,
    required this.Rn,
    required this.irrigation,
    required this.amountOfIrrigation,
    required this.potentialYield,
    required this.iLA,
    required this.rgr,
    required this.yields,
    required this.checkYieldDate,
    required this.autoIrrigation,
  });

  Field.newOne(String name)
      : fieldName = name,
        rainFall = 0,
        dAP = 0,
        humidity30 = 0,
        humidity60 = 0,
        temperature = 0,
        soilTemperature = 0,
        windSpeed = 0,
        Rn = 0,
        irrigation = false,
        amountOfIrrigation = 0,
        potentialYield = 0,
        iLA = 0,
        rgr = 0,
        yields = [0],
        checkYieldDate = "",
        autoIrrigation = true;

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      "fieldName": fieldName,
      "rainFall": rainFall,
      "dAP": dAP,
      "humidity30": humidity30,
      "humidity60": humidity60,
      "temperature": temperature,
      "soilTemperature": soilTemperature,
      "windSpeed": windSpeed,
      "Rn": Rn,
      "irrigation": irrigation,
      "amountOfIrrigation": amountOfIrrigation,
      "potentialYield": potentialYield,
      "iLA": iLA,
      "rgr": rgr,
      "yields": yields,
      "checkYieldDate": checkYieldDate,
      "autoIrrigation": autoIrrigation,
    };
    return map;
  }

  fromMap(Map<String, dynamic> map) {
    fieldName = map['fieldName'];
    rainFall = map['rainFall'];
    dAP = map['dAP'];
    humidity30 = map['humidity30'];
    humidity60 = map['humidity60'];
    temperature = map['temperature'];
    soilTemperature = map['soilTemperature'];
    windSpeed = map['windSpeed'];
    Rn = map['Rn'];
    irrigation = map['irrigation'];
    amountOfIrrigation = map['amountOfIrrigation'];
    potentialYield = map['potentialYield'];
    iLA = map['iLA'];
    rgr = map['rgr'];
    yields = map['yields'];
    checkYieldDate = map['checkYieldDate'];
    autoIrrigation = map['autoIrrigation'];
  }

  //todo predict yield of the field day by day
  Future<double> predictYield() async {
    if (this.yields.length < 1) {
      this.yields[0] = this.iLA;
    }

    List<double> k; // coefficients of the equation
    var y = this.yields[this.yields.length - 1];

    var nextY;
    return nextY;
  }

  //todo calculate the yield for each time of day
  double ode(double yn) {
    var yn1 = yn;
    //todo tinh ET0
    var T = this.temperature;
    var delta = 0.6108 * exp(17.27 * T / (T + 237.3));
    delta *= (4098 /
        ((T + 237.3) * (T + 237.3))); // cong thuc tra bang [15] trong report
    var G = this.soilTemperature;
    var u2 = this.windSpeed;
    var es = 4.719;

    ///? tuong ung voi nhiet do khoang 30 C
    var ea = 4.719;

    /// ?
    var ET0 = (0.408 * delta * (this.Rn - G) +
            _gamma * (900 / (T + 273) * u2 * (es - ea))) /
        (delta + _gamma * (1 + 0.34 * u2));

    //todo calculate Kc
    var Kc =
        0.3 + 0.5 * max(this.dAP / 45, 1); // he so cay trong tai ngay thu dAP

    //todo calculate ETc
    var Vs = _depth * _appi * 1000; //cm3, the tich dat
    var swl30 = this.humidity30 * Vs;
    var swl60 = this.humidity60 * Vs;
    var swl = swl30 + swl60;
    var ETc = ET0 * Kc; // luong thoat hoi nuoc thuc te

    //todo calculate swc
    var swc = (this.amountOfIrrigation + this.rainFall + swl - ETc) /
        Vs; // soil water content
    var waterStress = max(0, 1 - exp((swc - _thr) * (-40)));
    //todo calculate yn1
    yn1 = this.rgr * yn * (1 - (yn / this.potentialYield)) * waterStress;
    return yn1;
  }
}
