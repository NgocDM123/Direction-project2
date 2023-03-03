import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

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
  List<Field> fields = [];
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
            width: 500,
            alignment: Alignment.center,
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
    return FutureBuilder<DataSnapshot>(
      future: this.getFieldNameFromDb(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          fields = [];
          for (DataSnapshot child in snapshot.data!.children) {
            Field f = Field.newOne(child.key!);
            fields.add(f);
          }
        } else if (snapshot.connectionState == ConnectionState.waiting) {
          Center(
            child: CircularProgressIndicator(),
          );
        }
        return ListView.builder(
          itemCount: fields.length,
          itemBuilder: _listFieldBuilder,
        );
      },
    );
  }

  Widget _listFieldBuilder(BuildContext context, int index) {
    final field = fields[index];
    return GestureDetector(
        onTap: () => _navigateToFieldDetail(context, field),
        child: Container(
          child: Stack(
            children: [
              Text(
                field.fieldName,
                textAlign: TextAlign.left,
                style: Styles.locationTileTitleDark
              ),
              Container(
                child: PopupMenuButton(
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      child: Text('Delete'),
                      onTap: () => {
                        _deleteField(field.fieldName),
                      },
                    )
                  ],
                  color: Colors.white,
                ),
                alignment: Alignment.centerRight,
              ),
            ],
          ),
          height: 70,
          padding: EdgeInsets.fromLTRB(25.0, 15.0, 15.0, 15.0),
          color: Colors.blue,
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
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      alignment: Alignment.bottomRight,
      padding: EdgeInsets.only(bottom: 25.0, right: 25.0),
    );
    return result;
  }

  Widget _addField() {
    var result = TextField(
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
        labelText: 'Field name',
      ),
    );
    return result;
  }

  void _createDefaultField(String name) {
    final newPostKey = FirebaseDatabase.instance.ref().child(Constant.USER).push();
    final Map<String, dynamic> updates = {};
    DateTime date = DateTime.now();
    updates['${Constant.USER}/$name'] = {
     // name: "",
      "startTime": date.toLocal().toString()
    };
    //updates['$USER/$name'] = {"startTime": date};
    FirebaseDatabase.instance.ref().update(updates);
    setState(() {
      this._displayForm = false;
    });
  }

  Future<void> _deleteField(String fieldName) async{
    var a =  FirebaseDatabase.instance.ref("${Constant.USER}/${fieldName}");
    a.remove();
       setState(() {

    });
  }

  Future<DataSnapshot> getFieldNameFromDb() async {
    DataSnapshot a = await FirebaseDatabase.instance.ref(Constant.USER).get();
    return a;
  }
}
