import 'package:flutter/material.dart';

import '../model/field.dart';

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
     child: ElevatedButton(
       child: Text('Edit ${this.field.fieldName}'.toUpperCase()),
       onPressed: () => null, // todo onPressed => show edit Screen
     ),
   );
  }

  Widget _renderPredictYield() {
    return Container(
      child: ElevatedButton(
        child: Text('Predict Yield of ${this.field.fieldName} field'.toUpperCase()),
        onPressed: () => null, // todo show the predicted yield
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
