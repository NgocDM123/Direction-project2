import 'package:direction/ui/predicted_yield_page.dart';
import 'package:flutter/material.dart';

import '../model/field.dart';
import 'customized_parameters_page.dart';
import 'detail_irrigation.dart';
import '../styles.dart';

class FieldDetail extends StatefulWidget {
  final Field field;

  FieldDetail(this.field);

  @override
  createState() => _FieldDetailState(this.field);
}

class _FieldDetailState extends State<FieldDetail> {
  final Field field;

  _FieldDetailState(this.field);

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(this.field.fieldName),
      ),
      body: _loadDataBeforeRenderBody(context, this.field)
    );
  }

  Widget _loadDataBeforeRenderBody(BuildContext context, Field field) {
    return FutureBuilder(
      future: this.field.getDataFromDb(),
      builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text(
                '${snapshot.error} occurred',
                style: TextStyle(fontSize: 18),
              ),
            );
          } else if (true) {
            return _renderBody(context, field);
          }
      },
    );
  }

  Widget _renderBody(BuildContext context, Field field) {
    var result = <Widget>[];
    //result.add(_renderRainFall());
    result.add(_customizeContainer(_renderPredictYield()));
    result.add(_renderIrrigation());
    result.add(_renderEditField());
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: result,
      ),
    );
  }

  Widget _customizeContainer(Widget child) {
    return Container(
      decoration: BoxDecoration(
          borderRadius: new BorderRadius.circular(10),
          //border: Border.all(color: Styles.blueColor),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
                blurRadius: 5.0, offset: Offset(0, 2), color: Styles.blueColor),
          ]),
      height: 70,
      padding: EdgeInsets.fromLTRB(25.0, 15.0, 15.0, 15.0),
      margin: EdgeInsets.only(top: 20.0, left: 15, right: 15),
      child: child,
    );
  }

  Widget _renderEditField() {
    return Container(
      child: GestureDetector(
        child: Container(
          child: Text('Edit ${this.field.fieldName}',
              style: Styles.locationTileTitleDark),
          // height: 60,
          // width: 500,
          color: Colors.blue,
          alignment: Alignment.center,
        ),
        onTap: () {
          _navigateToCustomizedParametersPage(context, field);
        },
      ),
      padding: EdgeInsets.only(left: 15, top: 10, right: 15, bottom: 15),
    );
  }

  Future<void> _navigateToCustomizedParametersPage(
      BuildContext context, Field field) async {
    await field.customizedParameters.getDataFromDb();
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => CustomizedParametersPage(this.field)));
  }

  void _navigateToPredictedYieldPage(BuildContext context, Field field) {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => PredictedYieldPage(field)));
  }

  Widget _renderPredictYield() {
    return Container(
        child: ElevatedButton(
      style: ButtonStyle(),
      child:
          Text('Predict Yield of ${this.field.fieldName} field'.toUpperCase()),
      onPressed: () => _navigateToPredictedYieldPage(
          context, this.field), // todo show the predicted yield
    ));
    //height: 100,
  }

  Widget _renderIrrigation() {
    return Container(
        padding: EdgeInsets.only(left: 15, top: 10, right: 15, bottom: 15),
        child: GestureDetector(
          child: Container(
            child: Text('Monitoring irrigation',
                style: Styles.locationTileTitleDark),
            height: 60,
            width: 500,
            color: Colors.blue,
            alignment: Alignment.center,
          ),
          onTap: () => _navigateToDetailIrrigationPage(context, this.field),
        ));
  }

  void _navigateToDetailIrrigationPage(BuildContext context, Field field) {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => DetailIrrigation(field)));
  }

  Widget _renderRainFall() {
    var result;
    this.field.measuredData.getAllRainfallFromDb().then((value) {
      result = value;
      print('------------------$result');
    });
    return Container(
      child: ElevatedButton(
        child: Text('Rain Fall'),
        onPressed: () => null,
      ),
    );
  }
}
