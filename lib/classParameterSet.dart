
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart'; //generate code for language switch
import 'package:direction/draw_graph/models/feature.dart';
import 'dart:math';
import 'simulated_model.dart';



enum ParameterNames { RGR, potentialYield, iLA, istart, iend, fcThreshHold }
int num = 0;

extension ParameterNamesExtension on ParameterNames {
  double min() {
    switch (this) {
      default:
        return 0;
    }
  }

  double max() {
    switch (this) {
      case ParameterNames.RGR:
        return 0.04;
      case ParameterNames.potentialYield:
        return 80000;
      case ParameterNames.iLA:
        return 1000;
      case ParameterNames.istart:
        return 364;
      case ParameterNames.iend:
        return 365;
      case ParameterNames.fcThreshHold:
        return 100;
      default:
        return 100000;
    }
  }

  double unitConv(BuildContext context) {
    switch (this) {
      case ParameterNames.potentialYield:
        final Locale appLocale = Localizations.localeOf(context);
        if (appLocale == Locale("th")) {
          return 1 / 6.25;
        } else {
          return 1;
        }
      default:
        return 1;
    }
  }

  double defaultValue() {
    //make sure this is between min and max
    switch (this) {
      case ParameterNames.RGR:
        return 0.025;
      case ParameterNames.potentialYield:
        return 30000;
      case ParameterNames.iLA:
        return 100;
      case ParameterNames.istart:
        return 0;
      case ParameterNames.iend:
        return 300;
      default:
        return 0;
    }
  }

  String unit(BuildContext context) {
    switch (this) {
      case ParameterNames.RGR:
        return AppLocalizations.of(context)!.unitRGR;
      case ParameterNames.potentialYield:
        return AppLocalizations.of(context)!.unitYield;
      case ParameterNames.iLA:
        return AppLocalizations.of(context)!.unitLAI;
      case ParameterNames.istart:
        return AppLocalizations.of(context)!.unitTime;
      case ParameterNames.iend:
        return AppLocalizations.of(context)!.unitTime;
      case ParameterNames.fcThreshHold:
        return AppLocalizations.of(context)!.unitPercent;
      default:
        return AppLocalizations.of(context)!.noUnit;
    }
  }

  String prettyName(BuildContext context) {
    switch (this) {
      case ParameterNames.RGR:
        return AppLocalizations.of(context)!.parameterNameRGR;
      case ParameterNames.potentialYield:
        return AppLocalizations.of(context)!.parameterNamePotentialYield;
      case ParameterNames.iLA:
        return AppLocalizations.of(context)!.parameterNameInitialLeafArea;
      case ParameterNames.istart:
        return AppLocalizations.of(context)!.parameterNameStartingTime;
      case ParameterNames.iend:
        return AppLocalizations.of(context)!.parameterNameEndingTime;
      case ParameterNames.fcThreshHold:
        return AppLocalizations.of(context)!.parameterNameFieldCapacity;
      default:
        return AppLocalizations.of(context)!.parameterNameDefault;
    }
  }

//unique column names for the sql database, without spaces dots and other special characters
//note that the enum.value.toString() method might contain dots and spaces
  String colName() {
    switch (this) {
      case ParameterNames.RGR:
        return 'rgr';
      case ParameterNames.potentialYield:
        return 'ymax';
      case ParameterNames.iLA:
        return 'ila'; //unicode superscript 2 = '\u00B2'
      case ParameterNames.istart:
        return 'st';
      case ParameterNames.iend:
        return 'et';
      case ParameterNames.fcThreshHold:
        return 'fcThreshHold';
      default:
        return 'unnamed_variable';
    }
  }

}

class ParameterSet {
  static int _numberOfInstances = 0;
  final int id;
  String fieldName;
  //model parameters
  final _simPars = Map<ParameterNames, double>();
  //drawing
  late Color _color;
  //
  static final List<Color> _colors = [
    Colors.blue,
    Colors.green,
    Colors.yellow,
    Colors.orange,
    Colors.red,
    Colors.purple,
  ];
  //simulator
  late SimulationModel
      _simulationModel; //might later be overloaded and replaced by different models?

  //constructor
  ParameterSet({required this.fieldName}) : this.id = _numberOfInstances {
    //make color unique.
    int ci = _numberOfInstances;
    while (ci >= _colors.length) ci -= _colors.length;
    _color = _colors[
        ci]; //TODO check if this color is unique or present in fields, and otherwise choose another.
    //increment instance counter
    ++_numberOfInstances;
    //
    _simulationModel = SimulationModel(this);
  }



// //to and from map in order to store the parameters in a row of a table
// make sure both methods use same keys, in this case colName() is used.
// the constructor will work with an empty map in which case it constructs a default field with the name fieldxx
  ParameterSet.fromMap(Map<String, dynamic> map)
      : this.id = _numberOfInstances,
        fieldName = map['fn'] == null
            ? 'field' + _numberOfInstances.toString()
            : map['fn'] {
    if (map['col'] == null) {
      int ci = _numberOfInstances;
      while (ci >= _colors.length) ci -= _colors.length;
      _color = _colors[ci];
    } else {
      _color = new Color(map['col']).withOpacity(1);
    }
    ++_numberOfInstances;
    //load values
    map.forEach((key, value) {
      //map key to enum Parameternames and check the value is different from the default value.
      ParameterNames.values.forEach((pn) {
        if (pn.colName() == key && pn.defaultValue() != value) {
          //todo double comparison might easily fail.
          _simPars[pn] = value;
        }
      });
    });
    //instantiate model
    _simulationModel = SimulationModel(this);
  }
  // convenience method to create a Map from this Word object
  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{'id': id, 'fn': fieldName, 'col': _color.value};
    ParameterNames.values.forEach((element) {
      map[element.colName()] = _simPars[element] == null
          ? element.defaultValue()
          : _simPars[element];
    });
    return map;
  }

  // Delivers input for the sql schema that is used to read and write the map from the database
  static String sqlSchema() {
    //assert(Fields.databaseVersion == 14); //TODO should be compiletime check, not runtime check. All we want is that if this schema is updated, the version number is also updated.
    String schema = '''"id" INTEGER PRIMARY KEY,
                   "fn" TEXT NOT NULL,
                   "col" INTEGER NOT NULL''';
    ParameterNames.values.forEach((element) {
      schema += ''',"${element.colName()}" DOUBLE ''';
    });
    return schema;
  }

  // Implement toString to make it easier to see information about
  // each dog when using the print statement.
  @override
  String toString() {
    return 'ParameterSet{id: $id, field: $fieldName}';
  }

  // visualization
  Feature getFeature() {
    //explicit copy of results using [...]
    return Feature(
      data: List<double>.from(_simulationModel.getResults()),
      color: _color,
      title: fieldName,
    );
  }

  Feature getFeature2() {
    //explicit copy of results using [...]
    return Feature(
      data: List<double>.from(_simulationModel.getResults2()),
      color: _color,
      title: fieldName,
    );
  }

  double getDataMax() {
    return _simulationModel.getResults().reduce(max);
  }

  double getDataMax2() {
    return _simulationModel.getResults2().reduce(max);
  }

  Color getColor() {
    return _color;
  }

  List<Color> getColors() {
    return _colors;
  }

  void setColor(Color c) {
    _color = c;
  }

  double getSimulationParameter(ParameterNames key) {
    final v = _simPars[key];
    if (v == null) {
      return key.defaultValue();
    } else {
      return v;
    }
  }

  void setSimulationParameter(ParameterNames key, double value) {
    _simPars[key] = value;
  }

  int getNumberOfSimulationParameters() {
    return _simPars.length;
  }
}

