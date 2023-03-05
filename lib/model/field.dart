import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import '../firebase_options.dart';
import 'dart:math';

import '../constant.dart';
import 'customized_parameters.dart';
import 'measured_data.dart';

const double _thr =
    0.0224; // residual water content // lượng nước bị giữ lại trong đất mà cây ko hấp thụ được
const double _depth = 1.2; // soil depth in m
const double _appi =
    0.80 * 1.00; // Area per plant (row x interrow spacing) (m2);
//const double _delta = 0.1; // tra bang [15] trong bao cao do an
const double _gamma = 0.067; //tra bang[15] trong bao cao do an

class Field {
  String fieldName;
  int dAP; //day after plant
  bool irrigationCheck; //(determined from model or adjust by user)
  double amountOfIrrigation; // luong nuoc tuoi tieu (mm/day)
  List<double> yields; // predicted by model
  String checkYieldDate; //
  CustomizedParameters customizedParameters;
  MeasuredData measuredData;
  String startIrrigation;
  String endIrrigation;

  Field(
      this.fieldName,
      this.dAP,
      this.irrigationCheck,
      this.amountOfIrrigation,
      this.yields,
      this.checkYieldDate,
      this.customizedParameters,
      this.measuredData,
      this.startIrrigation,
      this.endIrrigation);

  Field.newOne(String name)
      : fieldName = name,
        dAP = 0,
        irrigationCheck = false,
        amountOfIrrigation = 0,
        yields = [0],
        checkYieldDate = "",
        customizedParameters = CustomizedParameters.newOne(name),
        measuredData = MeasuredData.newOne(name),
        startIrrigation = '',
        endIrrigation = '';

  void setFieldName(String name) {
    this.fieldName = name;
  }

  /// todo getData
  Future<void> getPotentialYieldFromDb() async {
    await customizedParameters.getPotentialYieldFromDb();
  } //(done)

  Future<void> getILAFromDb() async {
    await customizedParameters.getILAFromDb();
  } //(done)

  Future<void> getRGRFromDb() async {
    await customizedParameters.getRGRFromDb();
  } //(done)

  Future<void> getAutoIrrigationFromDb() async {
    await customizedParameters.getAutoIrrigationFromDb();
  } //(done)

  Future<void> getCustomizedParametersFromDb() async {
    await customizedParameters.getDataFromDb();
  } //(done)

  Future<void> getMeasuredDataFromDb(DateTime time) async {
    await measuredData.getDataFromDb(time);
  }

  Future<void> getIrrigationCheckFromDb() async {
    DataSnapshot snapshot = await FirebaseDatabase.instance
        .ref('${Constant.USER}/${this.fieldName}/${Constant.IRRIGATION_CHECK}')
        .get();
    var a = snapshot.value.toString().toLowerCase();
    if (a == 'true')
      this.irrigationCheck = true;
    else
      this.irrigationCheck = false;
  }

  Future<void> getGeneralDataFromDb() async {
    DataSnapshot snapshot = await FirebaseDatabase.instance
        .ref('${Constant.USER}/${this.fieldName}')
        .get();
    var a = snapshot.child('${Constant.IRRIGATION_CHECK}').value;
    if (a.toString() == 'true')
      this.irrigationCheck = true;
    else
      this.irrigationCheck = false;
    a = snapshot.child('${Constant.START_IRRIGATION}').value;
    this.startIrrigation = a.toString();
    a = snapshot.child('${Constant.END_IRRIGATION}').value;
    this.endIrrigation = a.toString();
  }

  Future<void> getDataFromDb(DateTime time) async {
    await getCustomizedParametersFromDb();
    await getMeasuredDataFromDb(time);
  }

  Future<void> updateGeneralDataToDb() async {
    DatabaseReference ref =
        FirebaseDatabase.instance.ref('${Constant.USER}/${this.fieldName}');
    ref.update({
      "${Constant.START_IRRIGATION}": this.startIrrigation,
      "${Constant.END_IRRIGATION}": this.endIrrigation
    });
  }

  //todo predict yield of the field day by day
  Future<double> predictYield() async {
    if (this.yields.length < 1) {
      this.yields[0] = this.customizedParameters.iLA;
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
    var T = this.measuredData.temperature;
    var delta = 0.6108 * exp(17.27 * T / (T + 237.3));
    delta *= (4098 /
        ((T + 237.3) * (T + 237.3))); // cong thuc tra bang [15] trong report
    var G = this.measuredData.soilTemperature;
    var u2 = this.measuredData.windSpeed;
    var es = 4.719;

    ///? tuong ung voi nhiet do khoang 30 C
    var ea = 4.719;

    /// ?
    var ET0 = (0.408 * delta * (this.measuredData.Rn - G) +
            _gamma * (900 / (T + 273) * u2 * (es - ea))) /
        (delta + _gamma * (1 + 0.34 * u2));

    //todo calculate Kc
    var Kc =
        0.3 + 0.5 * max(this.dAP / 45, 1); // he so cay trong tai ngay thu dAP

    //todo calculate ETc
    var Vs = _depth * _appi * 1000; //cm3, the tich dat
    var swl30 = this.measuredData.humidity30 * Vs;
    var swl60 = this.measuredData.humidity60 * Vs;
    var swl = swl30 + swl60;
    var ETc = ET0 * Kc; // luong thoat hoi nuoc thuc te

    //todo calculate swc
    var swc =
        (this.amountOfIrrigation + this.measuredData.rainFall + swl - ETc) /
            Vs; // soil water content
    var waterStress = max(0, 1 - exp((swc - _thr) * (-40)));
    //todo calculate yn1
    yn1 = this.customizedParameters.rgr *
        yn *
        (1 - (yn / this.customizedParameters.potentialYield)) *
        waterStress;
    return yn1;
  }
}
