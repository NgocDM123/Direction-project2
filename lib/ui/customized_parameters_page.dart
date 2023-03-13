import 'package:flutter/material.dart';

import '../model/customized_parameters.dart';
import '../model/field.dart';
import 'detail_irrigation.dart';
import '../constant.dart';
import '../styles.dart';

enum ParameterNames { potentialYield, iLA, rgr, autoIrrigation }

class CustomizedParametersPage extends StatefulWidget {
  final Field field;

  CustomizedParametersPage(this.field);

  @override
  createState() => _CustomizedParametersPageState(this.field);
}

class _CustomizedParametersPageState extends State<CustomizedParametersPage> {
  final Field field;
  bool timePicker = false;

  _CustomizedParametersPageState(this.field);

  @override
  void initState() {
    super.initState();
  }

  void _displayTimePicker() {
    setState(() {
      this.timePicker = true;
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
          _renderConfirmButton(),
        ],
      ),
    );
  }

  Widget _renderParameters() {
    List<Widget> result = [];
    result.add(_renderRGRSlider());
    result.add(_renderILASlider());
    result.add(_renderPotentialYield());
    result.add(_renderFieldCapacitySlider());
    result.add(_renderAutoIrrigationSwitch());
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: result,
      ),
    );
  }

  Widget _renderRGRSlider() {
    return Container(
      child: Column(
        children: [
          Container(
            child: Text(
              '${Constant.RGR_DISPLAY}',
              style: Styles.locationTileTitleLight,
            ),
            padding: EdgeInsets.only(left: 23),
          ),
          Container(
            child: Text(
              '${this.field.customizedParameters.rgr}',
              style: Styles.locationTileTitleLight,
            ),
            padding: EdgeInsets.only(left: 23),
          ),
          Slider(
              value: this.field.customizedParameters.rgr,
              onChanged: (double value) {
                setState(() {
                  this.field.customizedParameters.rgr = value;
                });
              },
              min: 0,
              max: 0.04,
              divisions: 100,
              label: '${Constant.RGR_DISPLAY}'),
        ],
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
      ),
      height: 150,
      padding: EdgeInsets.only(bottom: 20, top: 10),
    );
  }

  Widget _renderILASlider() {
    return Container(
      child: Column(
        children: [
          Container(
            child: Text(
              '${Constant.ILA_DISPLAY}',
              style: Styles.locationTileTitleLight,
            ),
            padding: EdgeInsets.only(left: 23),
          ),
          Container(
            child: Text(
              '${this.field.customizedParameters.iLA}',
              style: Styles.locationTileTitleLight,
            ),
            padding: EdgeInsets.only(left: 23),
          ),
          Slider(
              value: this.field.customizedParameters.iLA,
              onChanged: (double value) {
                setState(() {
                  this.field.customizedParameters.iLA = value;
                });
              },
              min: 0,
              max: 1000,
              divisions: 100,
              label: '${Constant.ILA_DISPLAY}'),
        ],
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
      ),
      height: 150,
      padding: EdgeInsets.only(bottom: 20, top: 10), //ILA
    );
  }

  Widget _renderPotentialYield() {
    return Container(
      child: Column(
        children: [
          Container(
            child: Text(
              '${Constant.POTENTIAL_YIELD_DISPLAY}',
              style: Styles.locationTileTitleLight,
            ),
            padding: EdgeInsets.only(left: 23),
          ),
          Container(
            child: Text(
              '${this.field.customizedParameters.potentialYield}',
              style: Styles.locationTileTitleLight,
            ),
            padding: EdgeInsets.only(left: 23),
          ),
          Slider(
              value: this.field.customizedParameters.potentialYield,
              onChanged: (double value) {
                setState(() {
                  this.field.customizedParameters.potentialYield = value;
                });
              },
              min: 0,
              max: 80000,
              divisions: 100,
              label: '${Constant.POTENTIAL_YIELD_DISPLAY}'),
        ],
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
      ),
      height: 150,
      padding: EdgeInsets.only(bottom: 20, top: 10), //ILA
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

  Widget _renderSlider(CustomizedParameters customizedParameters) {
    return ListView.builder(
      itemCount: 4,
        itemBuilder: _listViewItemBuilder
    );
  }

  Widget _listViewItemBuilder (BuildContext context, int index) {
    return Container(

    );
  }

  Widget _renderFieldCapacitySlider () {
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
