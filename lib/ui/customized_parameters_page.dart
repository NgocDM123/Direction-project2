import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../model/customized_parameters.dart';
import '../model/field.dart';
import 'detail_irrigation.dart';
import '../constant.dart';
import '../styles.dart';

const double _sliderHeight = 175;

class CustomizedParametersPage extends StatefulWidget {
  final Field field;

  CustomizedParametersPage(this.field);

  @override
  createState() => _CustomizedParametersPageState(this.field);
}

class _CustomizedParametersPageState extends State<CustomizedParametersPage> {
  final Field field;
  bool _displayConfirmButton = true;

  _CustomizedParametersPageState(this.field);

  @override
  void initState() {
    super.initState();
  }

  void _displayTimePicker() {
    setState(() {
      _displayConfirmButton = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit ${this.field.customizedParameters.fieldName}'),
      ),
      body: Stack(
        children: [
          _renderParameters(),
          if (_displayConfirmButton) _renderConfirmButton(),
        ],
      ),
    );
  }

  Widget _renderParameters() {
    List<Widget> result = [];
    result.add(_renderAcreageTextField());
    result.add(_renderIrrigationDurationSlider());
    result.add(_renderDripRateSlider());
    result.add(_renderNumberOfHoleTextField());
    result.add(_renderDistanceBetweenHolesSlider());
    result.add(_renderDistanceBetweenRowsSlider());
    result.add(_renderFieldCapacitySlider());
    result.add(_renderScaleRainSlider());
    result.add(_renderFertilizerLevelSlider());
    result.add(_renderAutoIrrigationSwitch());
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: result,
      ),
    );
  }

  Widget _renderAcreageTextField() {
    return Container(
      child: Column(
        children: [
          Text(
            'Acreage: ${this.field.customizedParameters.acreage} (m2)',
            style: Styles.locationTileTitleLight,
            textAlign: TextAlign.left,
          ),
          TextField(
            onSubmitted: (text) {
              this.field.customizedParameters.acreage = double.parse(text);
            },
            keyboardType: TextInputType.number,
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter(RegExp(r'[0-9.]'), allow: true)
            ],
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              hoverColor: Colors.blue,
              labelText: '${this.field.fieldName}',
              hintText: 'Enter acreage',
            ),
          ),
        ],
      ),
    );
  }

  Widget _renderNumberOfHoleTextField() {
    return Container(
      child: Column(
        children: [
          Text(
            '${Constant.NUMBER_OF_HOLES_DISPLAY}: ${this.field.customizedParameters.numberOfHoles} (holes)',
            style: Styles.locationTileTitleLight,
            textAlign: TextAlign.left,
          ),
          TextField(
            onSubmitted: (text) {
              this.field.customizedParameters.numberOfHoles = int.parse(text);
            },
            keyboardType: TextInputType.number,
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter(RegExp(r'[0-9]'), allow: true)
            ],
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              hoverColor: Colors.blue,
              labelText: '${this.field.fieldName}',
              hintText: 'Enter the number of drip holes',
            ),
          ),
        ],
      ),
    );
  }

  Widget _renderAutoIrrigationSwitch() {
    return Container(
      height: 150,
      child: Stack(
        children: [
          Row(
            children: [
              Container(
                child: Text(
                  '${Constant.AUT0_IRRIGATION_DISPLAY}',
                  style: Styles.locationTileTitleLight,
                ),
                padding: EdgeInsets.only(left: 23),
              ),
              Container(
                child: Switch(
                  value: this.field.customizedParameters.autoIrrigation,
                  onChanged: (bool value) {
                    setState(() {
                      this.field.customizedParameters.autoIrrigation = value;
                    });
                  },
                  activeColor: Colors.blue,
                ),
                alignment: Alignment.center,
                //padding: EdgeInsets.only(left: 100),
              ),
            ],
          ),
          Container(
            child: PopupMenuButton(
              itemBuilder: (context) => [
                PopupMenuItem(
                  child: TextButton(
                    child: Text('Go to the detail irrigation'),
                    onPressed: () =>
                        _navigateToDetailIrrigationPage(context, this.field),
                  ),
                )
              ],
            ),
            alignment: Alignment.centerRight,
          )
        ],
      ),
    );
  }

  Widget _renderFieldCapacitySlider() {
    return Container(
      child: Column(
        children: [
          Container(
            child: Text(
              '${Constant.FIELD_CAPACITY_DISPLAY}',
              style: Styles.locationTileTitleLight,
            ),
            padding: EdgeInsets.only(left: 23),
          ),
          Container(
            child: Text(
              '${this.field.customizedParameters.fieldCapacity}',
              style: Styles.locationTileTitleLight,
            ),
            padding: EdgeInsets.only(left: 23),
          ),
          Slider(
              value: this.field.customizedParameters.fieldCapacity,
              onChanged: (double value) {
                setState(() {
                  this.field.customizedParameters.fieldCapacity = value;
                });
              },
              min: 0,
              max: 100,
              divisions: 100,
              label: '${Constant.FIELD_CAPACITY_DISPLAY}'),
        ],
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
      ),
      height: 150,
      padding: EdgeInsets.only(bottom: 20, top: 10),
    );
  }

  Widget _renderIrrigationDurationSlider() {
    return Container(
      child: Column(
        children: [
          Container(
            child: Text(
              '${Constant.IRRIGATION_DURATION_DISPLAY}',
              style: Styles.locationTileTitleLight,
            ),
            padding: EdgeInsets.only(left: 23),
          ),
          Container(
            child: Text(
              '${this.field.customizedParameters.irrigationDuration}',
              style: Styles.locationTileTitleLight,
            ),
            padding: EdgeInsets.only(left: 23),
          ),
          Slider(
              value: this.field.customizedParameters.irrigationDuration,
              onChanged: (double value) {
                setState(() {
                  this.field.customizedParameters.irrigationDuration = value;
                });
              },
              min: 0,
              max: 24,
              divisions: 100,
              label: '${Constant.IRRIGATION_DURATION_DISPLAY}'),
        ],
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
      ),
      height: _sliderHeight,
      padding: EdgeInsets.only(bottom: 20, top: 10),
    );
  }

  Widget _renderDripRateSlider() {
    return Container(
      child: Column(
        children: [
          Container(
            child: Text(
              '${Constant.DRIP_RATE_DISPLAY}',
              style: Styles.locationTileTitleLight,
            ),
            padding: EdgeInsets.only(left: 23),
          ),
          Container(
            child: Text(
              '${this.field.customizedParameters.dripRate}',
              style: Styles.locationTileTitleLight,
            ),
            padding: EdgeInsets.only(left: 23),
          ),
          Slider(
              value: this.field.customizedParameters.dripRate,
              onChanged: (double value) {
                setState(() {
                  this.field.customizedParameters.dripRate = value;
                });
              },
              min: 0,
              max: 8,
              divisions: 100,
              label: '${Constant.DRIP_RATE_DISPLAY}'),
        ],
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
      ),
      height: _sliderHeight,
      padding: EdgeInsets.only(bottom: 20, top: 10),
    );
  }

  Widget _renderDistanceBetweenHolesSlider() {
    return Container(
      child: Column(
        children: [
          Container(
            child: Text(
              '${Constant.DISTANCE_BETWEEN_HOLES_DISPLAY}',
              style: Styles.locationTileTitleLight,
            ),
            padding: EdgeInsets.only(left: 23),
          ),
          Container(
            child: Text(
              '${this.field.customizedParameters.distanceBetweenHoles}',
              style: Styles.locationTileTitleLight,
            ),
            padding: EdgeInsets.only(left: 23),
          ),
          Slider(
              value: this.field.customizedParameters.distanceBetweenHoles,
              onChanged: (double value) {
                setState(() {
                  this.field.customizedParameters.distanceBetweenHoles = value;
                });
              },
              min: 0,
              max: 100,
              divisions: 100,
              label: '${Constant.DISTANCE_BETWEEN_HOLES_DISPLAY}'),
        ],
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
      ),
      height: _sliderHeight,
      padding: EdgeInsets.only(bottom: 20, top: 10),
    );
  }

  Widget _renderDistanceBetweenRowsSlider() {
    return Container(
      child: Column(
        children: [
          Container(
            child: Text(
              '${Constant.DISTANCE_BETWEEN_ROWS_DISPLAY}',
              style: Styles.locationTileTitleLight,
            ),
            padding: EdgeInsets.only(left: 23),
          ),
          Container(
            child: Text(
              '${this.field.customizedParameters.distanceBetweenRows}',
              style: Styles.locationTileTitleLight,
            ),
            padding: EdgeInsets.only(left: 23),
          ),
          Slider(
              value: this.field.customizedParameters.distanceBetweenRows,
              onChanged: (double value) {
                setState(() {
                  this.field.customizedParameters.distanceBetweenRows = value;
                });
              },
              min: 0,
              max: 100,
              divisions: 100,
              label: '${Constant.DISTANCE_BETWEEN_ROWS_DISPLAY}'),
        ],
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
      ),
      height: _sliderHeight,
      padding: EdgeInsets.only(bottom: 20, top: 10),
    );
  }

  Widget _renderScaleRainSlider() {
    return Container(
      child: Column(
        children: [
          Container(
            child: Text(
              '${Constant.SCALE_RAIN_DISPLAY}',
              style: Styles.locationTileTitleLight,
            ),
            padding: EdgeInsets.only(left: 23),
          ),
          Container(
            child: Text(
              '${this.field.customizedParameters.scaleRain}',
              style: Styles.locationTileTitleLight,
            ),
            padding: EdgeInsets.only(left: 23),
          ),
          Slider(
              value: this.field.customizedParameters.scaleRain,
              onChanged: (double value) {
                setState(() {
                  this.field.customizedParameters.scaleRain = value;
                });
              },
              min: 0,
              max: 100,
              divisions: 100,
              label: '${Constant.SCALE_RAIN_DISPLAY}'),
        ],
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
      ),
      height: _sliderHeight,
      padding: EdgeInsets.only(bottom: 20, top: 10),
    );
  }

  Widget _renderFertilizerLevelSlider() {
    return Container(
      child: Column(
        children: [
          Container(
            child: Text(
              '${Constant.FERTILIZATION_LEVEL_DISPLAY}',
              style: Styles.locationTileTitleLight,
            ),
            padding: EdgeInsets.only(left: 23),
          ),
          Container(
            child: Text(
              '${this.field.customizedParameters.fertilizationLevel}',
              style: Styles.locationTileTitleLight,
            ),
            padding: EdgeInsets.only(left: 23),
          ),
          Slider(
              value: this.field.customizedParameters.fertilizationLevel,
              onChanged: (double value) {
                setState(() {
                  this.field.customizedParameters.fertilizationLevel = value;
                });
              },
              min: 0,
              max: 100,
              divisions: 100,
              label: '${Constant.FERTILIZATION_LEVEL_DISPLAY}'),
        ],
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
      ),
      height: _sliderHeight,
      padding: EdgeInsets.only(bottom: 20, top: 10),
    );
  }

  void _navigateToDetailIrrigationPage(BuildContext context, Field field) {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => DetailIrrigation(field)));
  }

  Widget _renderConfirmButton() {
    return Container(
      child: Stack(
        children: [
          ElevatedButton(
            child: Text('Change'),
            onPressed: () => {
              setState(() {
                this.field.customizedParameters.updateDataToDb();
              })
            },
          ),
        ],
      ),
      alignment: Alignment.bottomCenter,
      padding: EdgeInsets.only(bottom: 20),
    );
  }
}
