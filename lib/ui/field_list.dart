import 'dart:async';
import 'dart:io';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../model/field.dart';
import '../styles.dart';
import 'field_detail.dart';
import '../constant.dart';

// const String USER = 'user1';
// const String TEST_USER = 'testUser';

class FieldList extends StatefulWidget {
  @override
  createState() => _FieldListState();
}

class _FieldListState extends State<FieldList> {
  List<Field> _fields = [];
  bool _displayForm = false;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Fields of ${Constant.USER}",
        ),
      ),
      body: Stack(
        children: [
          _renderFieldList(context),
          _renderButtonAdd(),
          _displayForm
              ? Container(
                  child: _addField(),
                  height: 500,
                  alignment: Alignment.center,
                  padding: EdgeInsets.only(left: 30, right: 30),
                  color: Styles.blueColor.withOpacity(0.5),
                )
              : Container(),
        ],
      ),
    );
  }

  _form() {
    setState(() {
      this._displayForm = true;
    });
  }

  Widget _renderFieldList(BuildContext context) {
    // _fields.add(Field.newOne('test'));
    // _fields.elementAt(0).test = true;
    return Container(
      child: FutureBuilder<DataSnapshot>(
        future: this.getFieldNameFromDb(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            _fields = [];
            for (DataSnapshot child in snapshot.data!.children) {
              Field f = Field.newOne(child.key!);
              _fields.add(f);
            }
          } else if (snapshot.connectionState == ConnectionState.waiting) {
            Center(
              child: CircularProgressIndicator(),
            );
          }
          return ListView.builder(
            itemCount: _fields.length,
            itemBuilder: _listFieldBuilder,
          );
        },
      ),
      padding: EdgeInsets.only(top: 20.0),
    );
  }

  Widget _listFieldBuilder(BuildContext context, int index) {
    final field = _fields[index];
    return GestureDetector(
        onTap: () => _navigateToFieldDetail(context, field),
        child: Container(
          decoration: Styles.boxDecoration,
          height: 70,
          padding: EdgeInsets.fromLTRB(25.0, 15.0, 15.0, 15.0),
          margin: EdgeInsets.only(top: 20.0, left: 15, right: 15),
          child: Stack(
            children: [
             Container(
               alignment: Alignment.centerLeft,
               child:  Text(field.fieldName, style: Styles.fieldName),
             ),
              Container(
                alignment: Alignment.centerRight,
                child: PopupMenuButton(
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      child: Container(
                        alignment: Alignment.center,
                        child: Text(AppLocalizations.of(context)!.delete),
                      ),
                      onTap: () => {
                        _deleteField(field.fieldName),
                      },
                    )
                  ],
                ),
              ),
            ],
          ),

        ));
  }

  void _navigateToFieldDetail(BuildContext context, Field field) {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => FieldDetail(field)));
  }

  Widget _renderButtonAdd() {
    var result = Container(
      child: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () => {_form()},
        backgroundColor: Styles.addButtonColor,
        foregroundColor: Colors.white,
      ),
      alignment: Alignment.bottomRight,
      padding: EdgeInsets.only(bottom: 25.0, right: 25.0),
    );
    return result;
  }

  Widget _addField() {

    var result = Container(
      child:  TextField(
        //keyboardType: ,
        onSubmitted: (String text) {
          if (text == '') {
            setState(() {
              this._displayForm = false;
            });
          } else
            _createDefaultField(text);
        },
        autofocus: true,
        decoration: InputDecoration(
          border: OutlineInputBorder(),
          labelText: AppLocalizations.of(context)!.labelTextAddField,
          hintText: AppLocalizations.of(context)!.hintFieldName,
        ),
      ),
      color: Colors.white,
      height: 100,
      alignment: Alignment.center,
      padding: EdgeInsets.only(left: 10, right: 10),

    );
    return result;
  }

  Future<void> _createDefaultField(String name) async{
    Field newField = Field.newOne(name);
    final Map<String, dynamic> updates = {};
    updates['${Constant.USER}/$name'] = {
      "${Constant.START_TIME}": newField.startTime,
      "${Constant.START_IRRIGATION}": "",
      "${Constant.END_IRRIGATION}": "",
      "${Constant.IRRIGATION_CHECK}": "false",
      "${Constant.MEASURED_DATA}": "",
      "${Constant.CUSTOMIZED_PARAMETERS}": ""
    };
    FirebaseDatabase.instance.ref().update(updates);
    await newField.customizedParameters.updateDataToDb();
    await newField.createWeatherDataFile();
    setState(() {
      this._displayForm = false;
    });

  }

  Future<void> _deleteField(String fieldName) async {
    var a = FirebaseDatabase.instance.ref("${Constant.USER}/$fieldName");
    a.remove();
    final String directory = (await getApplicationSupportDirectory()).path;
    final path = "$directory/${Constant.USER}/$fieldName.csv";
    //final csvFile = new File(path).delete();
    await File(path).delete();
    setState(() {});
  }

  Future<DataSnapshot> getFieldNameFromDb() async {
    DataSnapshot a = await FirebaseDatabase.instance.ref(Constant.USER).get();
    return a;
  }
}
