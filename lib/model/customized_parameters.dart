import 'package:firebase_database/firebase_database.dart';

import '../constant.dart';

class CustomizedParameters {
  String fieldName;
  double potentialYield;
  double iLA;
  double rgr;
  bool autoIrrigation;

  CustomizedParameters(this.fieldName, this.potentialYield, this.iLA, this.rgr,
      this.autoIrrigation);

  CustomizedParameters.newOne(name)
      : this.fieldName = name,
        this.potentialYield = 30000,
        this.iLA = 100,
        this.rgr = 0.025,
        this.autoIrrigation = true;

  Future<void> getPotentialYieldFromDb() async {
    DataSnapshot snapshot = await FirebaseDatabase.instance
        .ref(
            '${Constant.USER}/${this.fieldName}/${Constant.CUSTOMIZED_PARAMETERS}')
        .get();
    //snapshot.child('${Constant.POTENTIAL_YIELD}');
    var a = snapshot.child('${Constant.POTENTIAL_YIELD}');
    this.potentialYield = double.parse(a.value.toString());
  }

  Future<void> getILAFromDb() async {
    DataSnapshot snapshot = await FirebaseDatabase.instance
        .ref(
            '${Constant.USER}/${this.fieldName}/${Constant.CUSTOMIZED_PARAMETERS}')
        .get();
    var a = snapshot.child('${Constant.ILA}');
    this.iLA = double.parse(a.value.toString());
  }

  Future<void> getRGRFromDb() async {
    DataSnapshot snapshot = await FirebaseDatabase.instance
        .ref(
            '${Constant.USER}/${this.fieldName}/${Constant.CUSTOMIZED_PARAMETERS}')
        .get();
    var a = snapshot.child('${Constant.RGR}');
    this.rgr = double.parse(a.value.toString());
  }

  Future<void> getAutoIrrigationFromDb() async {
    DataSnapshot snapshot = await FirebaseDatabase.instance
        .ref(
            '${Constant.USER}/${this.fieldName}/${Constant.CUSTOMIZED_PARAMETERS}')
        .get();
    var a = snapshot.child('${Constant.AUTO_IRRIGATION}');
    String s = a.value.toString().toLowerCase();
    if (s == 'true')
      this.autoIrrigation = true;
    else
      this.autoIrrigation = false;
  }

  Future<void> getDataFromDb() async {
    DataSnapshot snapshot = await FirebaseDatabase.instance
        .ref(
            '${Constant.USER}/${this.fieldName}/${Constant.CUSTOMIZED_PARAMETERS}')
        .get();
    //snapshot.child('${Constant.POTENTIAL_YIELD}');
    var a = snapshot.child('${Constant.POTENTIAL_YIELD}');
    this.potentialYield = double.parse(a.value.toString());
    a = snapshot.child('${Constant.ILA}');
    this.iLA = double.parse(a.value.toString());
    a = snapshot.child('${Constant.RGR}');
    this.rgr = double.parse(a.value.toString());
    a = snapshot.child('${Constant.AUTO_IRRIGATION}');
    String s = a.value.toString().toLowerCase();
    if (s == 'true')
      this.autoIrrigation = true;
    else
      this.autoIrrigation = false;
  }

  Future<void> updatePotentialYieldToDb(double potentialYield) async {
    DatabaseReference ref = FirebaseDatabase.instance
        .ref('${Constant.USER}/${Constant.CUSTOMIZED_PARAMETERS}');
    await ref.update({
      "${Constant.POTENTIAL_YIELD}" : potentialYield,
    });
    this.potentialYield = potentialYield;
  }
}
