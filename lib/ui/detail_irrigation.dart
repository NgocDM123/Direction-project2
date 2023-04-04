import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';

import '../model/field.dart';
import 'package:direction/styles.dart';
import '../constant.dart';

class DetailIrrigation extends StatefulWidget {
  final Field field;

  DetailIrrigation(this.field);

  @override
  createState() => _DetailIrrigationState(this.field);
}

class _DetailIrrigationState extends State<DetailIrrigation> {
  final Field field;
  DateTime selectedStartTime = DateTime.now();
  double amount = 0.0; //l/m2

  _DetailIrrigationState(this.field);

  @override
  void initState() {
    super.initState();
    this.field.getGeneralDataFromDb();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${_appBarText()}'),
      ),
      body: _loadDataBeforeRenderBody(),
    );
  }

  Widget _loadDataBeforeRenderBody() {
    return FutureBuilder(
      future: _loadData(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text(
              '${snapshot.error} occurred',
              style: TextStyle(fontSize: 18),
            ),
          );
        } else if (snapshot.connectionState == ConnectionState.done) {
          return _renderBody();
        } else
          return Center(
            child: CircularProgressIndicator(),
          );
      },
    );
  }

  Future<void> _loadData() async {
    await this.field.getGeneralDataFromDb();
    await this.field.getMeasuredDataFromDb();
    if (!this.field.irrigationCheck) {
      if (!this.field.customizedParameters.autoIrrigation) {
        DataSnapshot snapshot = await FirebaseDatabase.instance
            .ref(
                '${Constant.USER}/${this.field.fieldName}/${Constant.IRRIGATION_INFORMATION}')
            .get();
        if (!snapshot.exists) {
          final Map<String, dynamic> updates = {};
          updates["${Constant.IRRIGATION_INFORMATION}"] = {
            "time": this.selectedStartTime,
            "duration": this.amount *
                this.field.customizedParameters.acreage /
                this.field.customizedParameters.dripRate /
                this.field.customizedParameters.numberOfHoles
          };
          FirebaseDatabase.instance
              .ref('${Constant.USER}/${this.field.fieldName}')
              .update(updates);
        } else {
          var s = snapshot.child('time').value.toString();
          this.selectedStartTime = DateTime.parse(s);
          s = snapshot.child('duration').value.toString();
          var duration = double.parse(s);
          this.amount = duration *
              this.field.customizedParameters.dripRate /
              this.field.customizedParameters.acreage *
              this.field.customizedParameters.numberOfHoles;
        }
      }
    }
  }

  Widget _renderWeatherData() {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Radiation: ${this.field.measuredData.radiation}"),
          Text("Rain fall: ${this.field.measuredData.rainFall}"),
          Text(
              "Relative humidity: ${this.field.measuredData.relativeHumidity}"),
          Text("Temperature: ${this.field.measuredData.temperature}"),
          Text("Wind speed: ${this.field.measuredData.windSpeed}")
        ],
      ),
    );
  }

  String _appBarText() {
    String s = '';
    if (this.field.customizedParameters.autoIrrigation) {
      s = 'Auto irrigation';
    } else
      s = 'Manual irrigation';
    return s;
  }

  Widget _renderIrrigationAmountByModel() {
    return Container(
      child: Text(
          'The mount of irrigation today is ${this.field.nextIrrigationAmount()}'),
    );
  }

  Widget _renderBody() {
    return Container(
      child: Column(
        children: [
          (this.field.irrigationCheck)
              ? _irrigatingBody()
              : _notIrrigatingBody(),
          _renderWeatherData()
        ],
      ),
    );
  }

  //be irrigating
  Widget _irrigatingBody() {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          (this.field.customizedParameters.autoIrrigation)
              ? _renderIrrigationAmountByModel()
              : Container(),
          Container(
            child: Text(
              'Start irrigation time: ${this.field.startIrrigation}',
              style: Styles.timeTitle,
            ),
            height: 50,
            padding: const EdgeInsets.all(3.0),
            alignment: Alignment.center,
            decoration: BoxDecoration(
                borderRadius: new BorderRadius.circular(25),
                border: Border.all(color: Styles.blueColor)),
          ),
          Container(
            child: Text(
              'End irrigation time: ${this.field.endIrrigation}',
              style: Styles.timeTitle,
            ),
            height: 50,
            padding: const EdgeInsets.all(3.0),
            alignment: Alignment.center,
            decoration: BoxDecoration(
                borderRadius: new BorderRadius.circular(25),
                border: Border.all(color: Styles.blueColor)),
          ),
          Container(
              child: Center(
            child: Lottie.asset('assets/animations/water-drop.json'),
          )),
        ],
      ),
    );
  }

  //not be irrigating
  Widget _notIrrigatingBody() {
    if (this.field.customizedParameters.autoIrrigation)
      return _autoNotIrrigation();
    else
      return _manualNotIrrigation();
  }

  Widget _autoNotIrrigation() {
    return Container(
        width: 200,
        child: Column(
          children: [
            Lottie.asset('assets/animations/energyshares-plant5.json'),
            Text(
                "The amount of Irrigation for ${this.field.getIrrigationTime()}: ${this.field.getIrrigationAmount()} (l/m2)"),
          ],
        ));
  }

  Widget _manualNotIrrigation() {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            child: Lottie.asset('assets/animations/energyshares-plant5.json'),
            height: 200,
          ),
          Container(
              padding: EdgeInsets.only(top: 70),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text(
                    'Start time: ${this.selectedStartTime}',
                    style: Styles.timeTitle,
                  ),
                  OutlinedButton(
                    child: Text(
                      'Choose irrigation start time',
                      style: Styles.timeTitle,
                    ),
                    onPressed: () => _dateTimePickerWidget(context),
                  ),
                  Text(
                    "Amount of Irrigation: ${this.amount} (l/m2)",
                    style: Styles.timeTitle,
                  ),
                  _renderAmountOfIrrigationTextField()
                ],
              )),
          _renderConfirmButton(),
        ],
      ),
    );
  }

  // Future<void> _displayTimeDialog() async {
  //   final TimeOfDay? time = await showTimePicker(
  //     context: context,
  //     initialTime: TimeOfDay.now(),
  //     initialEntryMode: TimePickerEntryMode.input,
  //   );
  //   if (time != null) {
  //     setState(() {
  //       DatabaseReference ref = FirebaseDatabase.instance.ref(
  //           '${Constant.USER}/${this.field.fieldName}/${Constant.IRRIGATION_INFORMATION}');
  //       ref.update({
  //         "time":
  //             "${this.selectedStartTime.hour}:${this.selectedStartTime.minute}",
  //         "amount": 0.0
  //       });
  //     });
  //   }
  // }

  _dateTimePickerWidget(BuildContext context) async {
    return DatePicker.showDateTimePicker(
      context,
      //dateFormat: 'dd MMMM yyyy HH:mm',
      currentTime: DateTime.now(),
      minTime: DateTime(2018),
      maxTime: DateTime(2100),
      //onMonthChangeStartWithFirstDate: true,
      onConfirm: (dateTime) {
        // this.selectedStartTime = dateTime;
        this.selectedStartTime = dateTime;
        print(this.selectedStartTime);
      },
    );
  }

  Widget _renderAmountOfIrrigationTextField() {
    return Container(
      child: TextField(
        onSubmitted: (value) {
          this.amount = double.parse(value);
        },
        keyboardType: TextInputType.number,
        inputFormatters: <TextInputFormatter>[
          FilteringTextInputFormatter(RegExp(r'[0-9.]'), allow: true)
        ],
        decoration: InputDecoration(
          border: OutlineInputBorder(),
          hoverColor: Colors.blue,
          hintText: 'Enter amount of irrigation',
        ),
      ),
    );
  }

  double _toDouble(TimeOfDay myTime) => myTime.hour + myTime.minute / 60.0;

  Widget _renderConfirmButton() {
    return Container(
      alignment: Alignment.bottomCenter,
      child: ElevatedButton(
        child: Text(
          'Confirm irrigation',
          style: Styles.timeTitle,
        ),
        onPressed: () => {
          setState(() {
            final Map<String, dynamic> updates = {};
            updates["${Constant.IRRIGATION_INFORMATION}"] = {
              "time": this.selectedStartTime.toString(),
              "duration": this.amount *
                  this.field.customizedParameters.acreage /
                  this.field.customizedParameters.dripRate /
                  this.field.customizedParameters.numberOfHoles,
              // "${day}": tIrr
            };
            FirebaseDatabase.instance
                .ref('${Constant.USER}/${this.field.fieldName}')
                .update(updates);
          })
        },
      ),
    );
  }
}
