import 'package:direction/ui/predicted_yield_page.dart';
import 'package:flutter/material.dart';

import '../constant.dart';
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
    //this.field.runModel();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(this.field.fieldName),
        ),
        body: _loadDataBeforeRenderBody(context, this.field));
  }

  Widget _loadDataBeforeRenderBody(BuildContext context, Field field) {
    return FutureBuilder(
      future: this.field.runModel(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text(
              '${snapshot.error} occurred',
              style: TextStyle(fontSize: 18),
            ),
          );
        } else if (snapshot.connectionState == ConnectionState.done) {
          return _renderBody(context, field);
        }
        return Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }

  Widget _renderBody(BuildContext context, Field field) {
    var result = <Widget>[];
    result.add(_renderPredictYield());
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


  Widget _renderEditField() {
    return Container(
        padding: EdgeInsets.only(left: 15, top: 10, right: 15, bottom: 15),
        child: SizedBox(
          height: 70,
          child: ElevatedButton(
            style: Styles.fieldDetailButtonStyle,
            // child: Text(
            //   "Edit ${this.field.fieldName}",
            //   style: Styles.fieldDetailButton,
            // ),
            child: Stack(
              children: [
                Container(
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.only(left: 10),
                  child: Text("Edit ${this.field.fieldName}",
                      style: Styles.fieldDetailButton),
                ),
                Container(
                  alignment: Alignment.centerRight,
                  child: Icon(Icons.arrow_forward_ios, color: Colors.blue,),
                ),
              ],
            ),
            onPressed: () =>
                _navigateToCustomizedParametersPage(context, this.field),
          ),
        ));
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
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: SizedBox(
          height: 70,
          child: ElevatedButton(
            style: Styles.fieldDetailButtonStyle,
            child: Stack(
              children: [
                Container(
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.only(left: 10),
                  child: Text('Predict the yield of ${this.field.fieldName}',
                      style: Styles.fieldDetailButton),
                ),
                Container(
                  alignment: Alignment.centerRight,
                  child: Icon(Icons.arrow_forward_ios, color: Colors.blue,),
                ),
              ],
            ),
            onPressed: () => _navigateToPredictedYieldPage(
                context, this.field), // todo show the predicted yield
          )),
    );
    //height: 100,
  }

  Widget _renderIrrigation() {
    return Container(
        padding: EdgeInsets.only(left: 15, top: 10, right: 15, bottom: 15),
        child: SizedBox(
          height: 70,
          child: ElevatedButton(
            style: Styles.fieldDetailButtonStyle,
              child: Stack(
                children: [
                  Container(
                    alignment: Alignment.centerLeft,
                    padding: EdgeInsets.only(left: 10),
                    child: Text("Monitoring irrigation",
                        style: Styles.fieldDetailButton),
                  ),
                  Container(
                    alignment: Alignment.centerRight,
                    child: Icon(Icons.arrow_forward_ios, color: Colors.blue,),
                  ),
                ],
              ),
            onPressed: () =>
                _navigateToDetailIrrigationPage(context, this.field),
          ),
        ));
  }

  void _navigateToDetailIrrigationPage(BuildContext context, Field field) {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => DetailIrrigation(field)));
  }

}
