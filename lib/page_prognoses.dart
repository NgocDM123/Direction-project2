

import 'package:flutter/material.dart';
import 'package:direction/draw_graph/draw_graph.dart'; //mit license
import 'package:direction/classFields.dart';
import 'simulated_model.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart'; //generate code for language switch

class PrognosesPage extends StatefulWidget {
  PrognosesPage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _PrognosesPageState createState() => _PrognosesPageState();
}

class _PrognosesPageState extends State<PrognosesPage> {
  @override
  Widget build(BuildContext context) {
    SimulationModel.setConversionFactors(context);
    return Scaffold(
      backgroundColor: Colors.white54,
      appBar: AppBar(
        title: Text(widget.title),
        automaticallyImplyLeading: false, //jp added because of graph
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.center,
              //mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                if (Fields.length() < 1)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 64.0),
                    child: Text(
                      AppLocalizations.of(context)!.pleaseAddField,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                        color: Colors.red,
                      ),
                    ),
                  ),
                if (Fields.length() > 0)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 64.0),
                    child: Text(
                      AppLocalizations.of(context)!.simulationResults,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                if (Fields.length() > 0)
                  LineGraph(
                    features: Fields.getFeatures(),
                    size: Size(420, 400),
                    labelX: Fields.getFeaturesX(),
                    labelY: Fields.getFeaturesY(),
                    xlab: AppLocalizations.of(context)!.xlabTime,
                    ylab: AppLocalizations.of(context)!.ylabYield,
                    showDescription: true, //shows legend
                    graphColor: Colors.black87,
                  ),
                SizedBox(
                  height: 150,
                ),
                if (Fields.length() > 0)
                  LineGraph(
                    features: Fields.getFeatures2(),
                    size: Size(420, 400),
                    labelX: Fields.getFeaturesX(),
                    labelY: Fields.getFeaturesY2(),
                    xlab: AppLocalizations.of(context)!.xlabTime,
                    ylab: AppLocalizations.of(context)!.ylabTheta,
                    showDescription: true, //shows legend
                    graphColor: Colors.black87,
                  ),
                SizedBox(
                  height: 50,
                )
              ]),
        ),
      ),
    );
  }
}
