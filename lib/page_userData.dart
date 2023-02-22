//import 'package:direction/fieldEntryForm.dart';
//import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart'; //generate code for language switch
import 'package:direction/classFields.dart';
import 'package:direction/classParameterSet.dart';
//import 'package:direction/classParameterSet.dart';
//import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:direction/colorPickerWidget.dart';

//jp sqflite imports to store data locally
//import 'dart:async';
//import 'package:path/path.dart';
//import 'package:sqflite/sqflite.dart';

//package for pop-up form
//import 'package:rflutter_alert/rflutter_alert.dart';

//import 'package:direction/classParameterSet.dart';

class UserDataPage extends StatefulWidget {
  UserDataPage({Key? key, required this.title}) : super(key: key) {
    //print("constructor UserDataPage called");
    Fields.fromDisk();
  }

  final String title;

  @override
  _UserDataPageState createState() => _UserDataPageState();
}

class _UserDataPageState extends State<UserDataPage> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController nameController = TextEditingController();

  int updateTrigger = -1;
  double slv1 = 0.0;

  void addItemToList() {
    setState(() {
      Fields.insert(nameController.text);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (Fields.length() < 1)
      Fields.insert(AppLocalizations.of(context)!.hintFieldName);

    return Scaffold(
      //backgroundColor: Colors.white54,
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Column(children: <Widget>[

        Expanded(
          child: ListView.builder(
              scrollDirection: Axis.vertical,
              padding: const EdgeInsets.all(8),
              itemCount: Fields.length(),
              itemBuilder: (BuildContext context, int index) {
                final item = Fields.at(index);
                return Dismissible(
                  // Each Dismissible must contain a Key. Keys allow Flutter to
                  // uniquely identify widgets.
                  key: Key(item.id.toString()),
                  // Provide a function that tells the app
                  // what to do after an item has been swiped away.
                  onDismissed: (direction) {
                    // Remove the item from the data source.
                    setState(() {
                      Fields.removeAt(index);
                    });

                    // Then show a snackbar.
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(AppLocalizations.of(context)!
                            .fieldNameDismissed(item.fieldName))));
                  },
                  // Show a red background as the item is swiped away.
                  background: Container(color: Colors.red),
                  child: Card(
                    child: ListTile(
                      onTap: () {
                        setState(() {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => FieldEditingForm(
                                index: index,
                                onUpdate: () {
                                  setState(() {
                                    this.updateTrigger++;
                                    Fields.toDisk();
                                  });
                                },
                              ),
                            ),
                          );
                        });
                      },
                      leading: Icon(
                        Icons.stop,
                        color: item.getColor(),
                      ),
                      //tileColor: item.getColor(),
                      title: Text('${item.fieldName}'),
                      trailing: Icon(Icons.more_vert),
                    ),
                  ),
                  //onTap: () => print("ListTile is tapped")
                );
              }),
        ),
        //
        //
        //
        //
      ]),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        backgroundColor: Colors.blue,
        onPressed: () {
          if (Fields.length() < 5) {
            showDialog(
              context: context,
              barrierDismissible: false, // user must tap button!
              builder: (BuildContext context) {
                return AlertDialog(
                  content: Stack(
                    children: <Widget>[
                      //
                      //
                      Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.all(8.0),
                              child: TextFormField(
                                autofocus: true,
                                decoration: InputDecoration(
                                  hintText: AppLocalizations.of(context)!
                                      .hintFieldName,
                                ),
                                controller: nameController,
                                //..text = 'myCassavaField1',
                                //onChanged: (text) => {Fields.insert(text)},
                                validator: (value) {
                                  //todo look for unique name. Now the Fields class add's '+' to the name if it is not unique
                                  if (value == null || value.isEmpty) {
                                    return AppLocalizations.of(context)!
                                        .pleaseEnterUniqueFieldName;
                                  }
                                  return null;
                                },
                                onFieldSubmitted: (text) {
                                  // Validate returns true if the form is valid, or false otherwise.
                                  if (_formKey.currentState!.validate()) {
                                    // If the form is valid, display a snackbar. In the real world,
                                    // you'd often call a server or save the information in a database.
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                            content: Text(
                                                AppLocalizations.of(context)!
                                                    .addingField)));
                                    addItemToList();
                                    Navigator.pop(context);
                                  }
                                },
                              ),
                            ),
                            Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(right: 8.0),
                                      child: ElevatedButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        child: Text(
                                            AppLocalizations.of(context)!
                                                .cancel),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 8.0),
                                      child: ElevatedButton(
                                        onPressed: () {
                                          // Validate returns true if the form is valid, or false otherwise.
                                          if (_formKey.currentState!
                                              .validate()) {
                                            // If the form is valid, display a snackbar. In the real world,
                                            // you'd often call a server or save the information in a database.
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(SnackBar(
                                                    content: Text(
                                                        AppLocalizations.of(
                                                                context)!
                                                            .addingField)));
                                            addItemToList();
                                            Navigator.pop(context);
                                          }
                                        },
                                        child: Text(
                                            AppLocalizations.of(context)!
                                                .submit),
                                      ),
                                    ),
                                  ],
                                )),
                          ],
                        ),
                      ),
                      //
                      //
                    ],
                  ),
                );
              },
            );
          } else {
            showDialog<void>(
              context: context,
              barrierDismissible: false, // user must tap button!
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Row(children: <Widget>[
                    Icon(
                      Icons.error,
                      color: Colors.red,
                    ),
                    Text(AppLocalizations.of(context)!.error)
                  ]),
                  content: SingleChildScrollView(
                    child: ListBody(
                      children: <Widget>[
                        Text(AppLocalizations.of(context)!.tooManyFields),
                        Text(AppLocalizations.of(context)!.pleaseRemoveField),
                      ],
                    ),
                  ),
                  actions: <Widget>[
                    TextButton(
                      child: Text(AppLocalizations.of(context)!.returnMsg),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                );
              },
            );
          }
        },
      ),
    );
  }
}

class FieldEditingForm extends StatefulWidget {
  //must be stateful for sliders otherwise not redrawn.
  FieldEditingForm({Key? key, required this.index, required this.onUpdate})
      : super(key: key);

  final int index;
  final Function onUpdate; //callback function which will triger an update

  @override
  _FieldEditingFormState createState() =>
      _FieldEditingFormState(index: index, onUpdate: onUpdate);
}

class _FieldEditingFormState extends State<FieldEditingForm> {
  // Declare a field that holds the Todo.
  final int index;
  final Function onUpdate; //callback function which will triger an update

  // In the constructor, require a Todo.
  _FieldEditingFormState({required this.index, required this.onUpdate});

  @override
  Widget build(BuildContext context) {
    // Use the Todo to create the UI.
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!
            .editFieldName(Fields.at(index).fieldName)),
      ),
      body: Padding(
        padding: EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Row(
                children: <Widget>[
                  Text(
                    AppLocalizations.of(context)!.fieldName,
                  ),
                ],
              ),
            ),

            Padding(
              padding: EdgeInsets.all(8.0),
              child: TextField(
                onChanged: (String newString) {
                  Fields.at(index).fieldName = newString;
                  this.onUpdate();
                },
                //onEditingComplete:(String newString) => print('complete'),
                //onSubmitted: (String newString) => print('update'),
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: Fields.at(index).fieldName,
                ),
              ),
            ),

            //
            //
            //
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Row(
                children: <Widget>[
                  Text(
                    AppLocalizations.of(context)!.fieldColor,
                  ),
                ],
              ),
            ),
            // Icon(
            //   Icons.stop,
            //   color: Fields.at(index).getColor(),
            // ),
            // SizedBox(height: 30),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: MyColorPicker(
                  onSelectColor: (value) {
                    Fields.at(index).setColor(value);
                    this.onUpdate();
                  },
                  availableColors: Fields.at(index).getColors(),
                  initialColor: Fields.at(index).getColor()),
            ),
            //
            //
            //
            // Padding(
            //   padding: EdgeInsets.all(8.0),
            //   child: Row(
            //     children: <Widget>[
            //       Text(
            //         'Relative Growth Rate (RGR)',
            //       ),
            //     ],
            //   ),
            // ),

            // Padding(
            //   padding: EdgeInsets.all(8.0),
            //   child:
            // RepaintBoundary(
            //   child: Slider(
            //     value: Fields.at(index).getRGR(),
            //     min: 0.1 * Fields.at(index).getRGR(),
            //     max: 10 * Fields.at(index).getRGR(),
            //     divisions: 100,
            //     label: Fields.at(index).getRGR().toStringAsFixed(4),
            //     onChanged: (double value) {
            //       setState(() {
            //         Fields.at(index).setRGR(value);
            //       });
            //       //print(value);
            //       //sv1 = value;

            //       //Fields.at(index).setRGR(value);
            //     },
            //   ),
            // ),
            // TextField(
            //   onChanged: (String newString) {
            //     Fields.at(index).fieldName = newString;
            //     this.onUpdate();
            //   },
            //   //onEditingComplete:(String newString) => print('complete'),
            //   //onSubmitted: (String newString) => print('update'),
            //   decoration: InputDecoration(
            //     border: OutlineInputBorder(),
            //     labelText: Fields.at(index).getRGR().toString(),
            //   ),
            // ),
            // ),
            Expanded(
              child: ListView.builder(
                  scrollDirection: Axis.vertical,
                  padding: const EdgeInsets.all(8),
                  itemCount: ParameterNames.values
                      .length, //.at(index).getNumberOfSimulationParameters(),
                  itemBuilder: (BuildContext context, int i) {
                    final item = ParameterNames.values[i];
                    final double cv = item.unitConv(context);
                    final double minv = item.min() * cv;
                    final double maxv = item.max() * cv;
                    return new Column(
                      children: <Widget>[
                        new ListTile(
                          title: new Text(
                              "${item.prettyName(context)} (${item.unit(context)})"),
                          subtitle: new Text(
                              "${cv * Fields.at(index).getSimulationParameter(item)}"),
                        ),
                        new Divider(
                          height: 2.0,
                        ),
                        RepaintBoundary(
                          child: Slider(
                            value: (cv *
                                Fields.at(index).getSimulationParameter(item)),
                            min: minv,
                            max: maxv,
                            divisions: 100,
                            label: (cv *
                                    Fields.at(index)
                                        .getSimulationParameter(item))
                                .toStringAsFixed(4),
                            onChanged: (double value) {
                              setState(() {
                                Fields.at(index)
                                    .setSimulationParameter(item, value / cv);
                              });
                              //print(value);
                              //sv1 = value;

                              //Fields.at(index).setRGR(value);
                            },
                          ),
                        ),
                        new Divider(
                          height: 2.0,
                        ),
                      ],
                    );
                  }),
            ),
//
////
          ],
        ),
      ),
    );
  }
}
