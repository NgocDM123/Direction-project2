import 'package:flutter/material.dart';

import '../model/field.dart';
import 'customized_parameters_page.dart';
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
    //field.getDataFromDb(DateTime.now().toLocal());
    return Scaffold(
      appBar: AppBar(
        title: Text(this.field.fieldName),
      ),
      body: _renderBody(context, this.field),
    );
  }

  Widget _renderBody(BuildContext context, Field field) {
    var result = <Widget>[];
    result.add(_renderEditField());
    result.add(_renderPredictYield());
    result.add(_renderIrrigation());
    result.add(_renderViewIrrigationState());
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
      child: GestureDetector(
        child: Container(
          child: Text('Edit ${this.field.fieldName}',
              style: Styles.locationTileTitleDark),
          height: 60,
          width: 500,
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

  Widget _renderPredictYield() {
    return Container(
      child: ElevatedButton(
        child: Text(
            'Predict Yield of ${this.field.fieldName} field'.toUpperCase()),
        onPressed: () => _navigateToCustomizedParametersPage(
            context, field), // todo show the predicted yield
      ),
      height: 100,
    );
  }

  Widget _renderIrrigation() {
    return Container(
      child: ElevatedButton(
        child: Text('Irrigation Record'.toUpperCase()),
        onPressed: () => null, // todo show irrigation record
      ),
    );
  }

  Widget _renderViewIrrigationState() {
    return Container(); // todo show auto or manual irrigation
  }
}
