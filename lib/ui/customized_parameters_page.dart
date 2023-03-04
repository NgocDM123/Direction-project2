import 'package:flutter/material.dart';

import '../model/customized_parameters.dart';
import '../model/field.dart';
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

  //bool confirm = false;
  _CustomizedParametersPageState(this.field);

  @override
  void initState() {
    super.initState();
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
    result.add(_renderAutoIrrigationSwitch());
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
          this.field.customizedParameters.autoIrrigation
              ? Container()
              : Container(
                  child: PopupMenuButton(
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        child: Text('Set irrigation time'),
                        onTap: () => null,
                      )
                    ],
                  ),
                  alignment: Alignment.centerRight,
                )
        ],
      ),
    );
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
