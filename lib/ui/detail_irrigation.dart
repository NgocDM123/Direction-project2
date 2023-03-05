import 'package:flutter/material.dart';
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
  String selectedStartTime = '';
  String selectedEndTime = '';
  bool setStartTime = false;
  bool setEndTime = false;

  _DetailIrrigationState(this.field);

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    this.field.getGeneralDataFromDb();
    return Scaffold(
      appBar: AppBar(
        title: Text('${_appBarText()}'),
      ),
      body: _renderBody(),
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

  Widget _renderBody() {
    if (this.field.irrigationCheck)
      return _irrigatingBody();
    else
      return _notIrrigatingBody();
  }

  Widget _irrigatingBody() {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
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
              border: Border.all(color: Styles.blueColor)
            ),
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
                border: Border.all(color: Styles.blueColor)
            ),
          ),
          Container(
              child: Center(
            child: Lottie.asset('assets/animations/water-drop.json'),
          )),
        ],
      ),
    );
  }

  Widget _notIrrigatingBody() {
    if (this.field.customizedParameters.autoIrrigation)
      return _autoNotIrrigation();
    else
      return _manualNotIrrigation();
  }

  Widget _autoNotIrrigation() {
    return Container(
      child: Lottie.asset('assets/animations/energyshares-plant5.json'),
    );
  }

  Widget _manualNotIrrigation() {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            child: Lottie.asset('assets/animations/energyshares-plant5.json'),
            height: 300,
          ),
          Container(
            padding: EdgeInsets.only(top: 70),
              child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              OutlinedButton(
                child: Text(
                  'Choose irrigation start time',
                  style: Styles.timeTitle,
                ),
                onPressed: () => _displayTimeDialog(true),
              ),
              Text(
                'Start time: ${this.selectedStartTime}',
                style: Styles.timeTitle,
              )
            ],
          )),
          Container(
              child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              OutlinedButton(
                child: Text(
                  'Choose irrigation end time',
                  style: Styles.timeTitle,
                ),
                onPressed: () => _displayTimeDialog(false),
              ),
              Text(
                'End time: ${this.selectedEndTime}',
                style: Styles.timeTitle,
              )
            ],
          )),
          _renderConfirmButton(),
        ],
      ),
    );
  }

  Future<void> _displayTimeDialog(bool start) async {
    final TimeOfDay? time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
        initialEntryMode: TimePickerEntryMode.input);
    if (time != null) {
      TimeOfDay startT;
      TimeOfDay endT;
      setState(() {
        if (start) {
          assert(this.selectedStartTime.compareTo(TimeOfDay.now().toString()) < 0);
          this.selectedStartTime = time.format(context);
          this.setStartTime = true;
        } else {
          assert(this.selectedEndTime.compareTo(this.selectedStartTime) > 0);
          this.selectedEndTime = time.format(context);

          this.setEndTime = false;
        }
      });
    }
  }

  Widget _renderConfirmButton() {
    return Container(
      alignment: Alignment.bottomCenter,
      child: ElevatedButton(
        child: Text(
          'Confirm irrigation',
          style: Styles.timeTitle,
        ),
        onPressed: () => {
          this.field.startIrrigation = selectedStartTime,
          this.field.endIrrigation = selectedEndTime,
          this.field.updateGeneralDataToDb(),
        },
      ),
    );
  }
}
