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
        children: [
          Container(
            padding: EdgeInsets.only(top: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _decoratedContainer(
                    "Radiation",
                    "${this.field.measuredData.radiation.toString()} [MJm^(-2)h^(-1)]",
                    100,
                    150),
                _decoratedContainer("Rain fall",
                    this.field.measuredData.rainFall.toString(), 100, 150)
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.only(top: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _decoratedContainer(
                    "Relative humidity",
                    "${this.field.measuredData.relativeHumidity.toString()} [%]",
                    100,
                    150),
                _decoratedContainer(
                    "Temperature",
                    "${this.field.measuredData.temperature.toString()} [℃]",
                    100,
                    150)
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.only(top: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _decoratedContainer(
                    "Wind speed",
                    "${this.field.measuredData.windSpeed.toString()} [m s^(-1)]",
                    100,
                    150),
                Container(
                  width: 150,
                  height: 100,
                  decoration: Styles.boxDecoration,
                  child: (this.field.irrigationCheck)
                      ? Lottie.asset('assets/animations/water-drop.json')
                      : Lottie.asset(
                          'assets/animations/energyshares-plant5.json'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _decoratedContainer(
      String title, String value, double height, double width) {
    return Container(
      height: height,
      width: width,
      alignment: Alignment.center,
      decoration: Styles.boxDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("$title"),
          Text("$value"),
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
      height: 50,
      width: 335,
      margin: EdgeInsets.only(top: 20),
      alignment: Alignment.center,
      decoration: Styles.boxDecoration,
      child: Text(
          'The mount of irrigation today is ${this.field.nextIrrigationAmount()}'),
    );
  }

  Widget _renderBody() {
    return SingleChildScrollView(
        child: Container(
      child: Column(
        children: [
          _renderWeatherData(),
          (this.field.irrigationCheck)
              ? _irrigatingBody()
              : _notIrrigatingBody(),
        ],
      ),
    ));
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
            margin: EdgeInsets.only(top: 30, bottom: 10),
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
        child: Column(
      children: [
        Container(
          height: 100,
          width: 330,
          padding: EdgeInsets.only(left: 10),
          margin: EdgeInsets.only(top: 30),
          decoration: Styles.boxDecoration,
          alignment: Alignment.center,
          child: Text(
            "The amount of irrigation for ${this.field.getIrrigationTime()}: ${this.field.getIrrigationAmount()} (l/m2)",
            style: Styles.textDefault,
          ),
        ),
      ],
    ));
  }

  // "The amount of Irrigation for ${this.field.getIrrigationTime()}",
  // "${this.field.getIrrigationAmount()} (l/m2)",

  Widget _manualNotIrrigation() {
    return Container(
      height: 400,
      width: 330,
      padding: EdgeInsets.only(left: 10),
      margin: EdgeInsets.only(top: 30),
      decoration: Styles.boxDecoration,
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: EdgeInsets.only(top: 20, bottom: 10),
            alignment: Alignment.center,
            child: Text(
              'Start time: ${this.selectedStartTime}',
              style: Styles.timeTitle,
            ),
          ),
          Container(
            height: 100,
            width: 150,
            alignment: Alignment.center,
            padding: EdgeInsets.only(bottom: 20),
            child: SizedBox(
              height: 60,
              width: 230,
              child: OutlinedButton(
                child: Text(
                  'Choose irrigation start time',
                  style: Styles.timeTitle,
                ),
                onPressed: () => _dateTimePickerWidget(context),
              ),
            ),
          ),
          Container(
            alignment: Alignment.center,
            padding: EdgeInsets.only(bottom: 10),
            child: Text(
              "Amount of Irrigation: ${this.amount} (l/m2)",
              style: Styles.timeTitle,
            ),
          ),
          _renderAmountOfIrrigationTextField(),
          _renderConfirmButton(),
        ],
      ),
    );
  }

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
      alignment: Alignment.center,
      child: SizedBox(
        width: 250,
        height: 50,
        child: TextField(
          onSubmitted: (value) {
            if (value.isNotEmpty) this.amount = double.parse(value);
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
      ),
    );
  }

  Widget _renderConfirmButton() {
    return Container(
      alignment: Alignment.bottomCenter,
      padding: EdgeInsets.only(top: 20),
      child: ElevatedButton(
        style: ButtonStyle(
            padding: MaterialStateProperty.all<EdgeInsets>(EdgeInsets.all(15)),
            backgroundColor: MaterialStateProperty.all<Color>(Colors.white),
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ))),
        child: Text(
          'Confirm irrigation',
          style: Styles.locationTileTitleLight,
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
