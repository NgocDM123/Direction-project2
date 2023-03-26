import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../model/field.dart';
import 'package:flutter/material.dart';

class PredictedYieldPage extends StatefulWidget {
  final Field field;

  PredictedYieldPage(this.field);

  @override
  createState() => _PredictedYieldPageState(this.field);
}

class _PredictedYieldPageState extends State<PredictedYieldPage> {
  final Field field;
  late Future<List<double>> data;
  TooltipBehavior _tooltipBehavior = TooltipBehavior(enable: false);

  _PredictedYieldPageState(this.field);

  @override
  void initState() {
    // TODO: implement initState
    data = this.field.predictYield();
    _tooltipBehavior = TooltipBehavior(enable: true);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Predicted yield of ${this.field.fieldName}'),
      ),
      body: _renderBody(),
    );
  }

  Widget _renderBody() {
    return Container(
        child: Column(
      children: [
        FutureBuilder<List<double>?>(
          future: data,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Text('Something went wrong!');
            } else if (snapshot.hasData) {
              List<double>? data = snapshot.data;
              return _renderChart(data);
            } else {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
          },
        ),
        _renderWeatherDataTable()
      ],
    ));
  }

  Widget _renderChart(List<double>? data) {
    final List<ChartData> chartData = [];
    if (data != null) {
      for (var index = 0; index < data.length; index++) {
        chartData.add(ChartData(index, data.elementAt(index)));
      }
    }
    return Container(
        child: Column(
      children: [
        Text('$data'),
        Container(
          child: SfCartesianChart(
            title: ChartTitle(text: 'Yield of ${this.field.fieldName}'),
            tooltipBehavior: _tooltipBehavior,
            legend: Legend(isVisible: true),
            primaryXAxis:
                NumericAxis(edgeLabelPlacement: EdgeLabelPlacement.shift),
            primaryYAxis: NumericAxis(
                numberFormat: NumberFormat.simpleCurrency(decimalDigits: 0),
                labelFormat: '{value}kg/ha'),
            series: [
              LineSeries<ChartData, int>(
                  name: 'Yield',
                  dataSource: chartData,
                  xValueMapper: (ChartData data, _) => data.x,
                  yValueMapper: (ChartData data, _) => data.y,
                  dataLabelSettings: DataLabelSettings(isVisible: true),
                  enableTooltip: true)
            ],
          ),
          padding: EdgeInsets.only(left: 10, top: 20, right: 10, bottom: 20),
        ),
      ],
    ));
  }

  List<List<dynamic>> _testData = [];

  Widget _renderWeatherDataTable() {
    return Container(
      child: FutureBuilder(
        future: this.field.writeWeatherDataToCsvFile(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            this.field.loadAllWeatherDataFromCsvFile().then((value) => {
                  print('========================================'),
                  print(value.length),
                  print(value),
                  print('========================================'),
                  _testData.add(value)
                });
          }
          return Container(
            //child: Text('$_testData}'),
          );
        },
      ),
    );
  }
}

class ChartData {
  final int x;
  final double y;

  ChartData(this.x, this.y);
}
