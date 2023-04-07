import 'package:direction/styles.dart';
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
//N status (ratio to optimal)
  Widget _renderBody() {
    List<Widget> result = [];
    var xData = this.field.getDoy();
    result.add(_renderChart("Yield (kg/ha)", xData, this.field.predictYield()));
    result.add(_renderChart("Irrigation (m^2/ha)", xData, this.field.getIrrigation()));
    result.add(_renderChart("Leaf area index", xData, this.field.getLai()));
    result.add(_renderChart("Labile carbon (%)", xData, this.field.getCLab()));
    result.add(_renderChart("Topsoil Wetness (%field capacity)", xData, this.field.getTopSoilWetness()));
    result.add(_renderChart("photosynthesis (g carbon)", xData, this.field.getPhotoSynthesis()));
    result.add(_renderChart("topsoil N content (mg/kg)", xData, this.field.getTopsoilNContent()));
    result.add(_renderChart("N status (ratio to optimal)", xData, this.field.getNStatus()));
    return Container(
      margin: EdgeInsets.symmetric(vertical: 30, horizontal: 20),
      child: SingleChildScrollView(
         child: Column(
           children: result,
         ),
      ),
    );
  }

  Widget _renderChart(String title, List<double> xData, List<double> yData) {
    var points = getChartPoints(xData, yData);
    return Container(
      margin: EdgeInsets.only(bottom: 30, left: 5, right: 5),
      padding: EdgeInsets.all(20),
      decoration: Styles.boxDecoration,
      child: Column(
        children: [
          Container(
            child: Text(title, style: Styles.predictPageTitle,),
          ),
          SizedBox(
            height: 250,
            width: 400,
            child: AspectRatio(
              aspectRatio: 1/3,
              child: LineChart(LineChartData(lineBarsData: [
                LineChartBarData(
                  spots: points.map((point) => FlSpot(point.x, point.y)).toList(),
                  isCurved: false,
                  dotData: FlDotData(
                    show: false,
                  ),
                  color: Colors.green,
                  belowBarData: BarAreaData(
                    show: true,
                    color: Colors.green.withOpacity(0.2)
                  ),
                ),
              ], borderData: FlBorderData(
                border: const Border(bottom: BorderSide(), left: BorderSide()),
              ),
                // minX: 0,
                // minY: 0,
                gridData: FlGridData(show: false),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
              )),
            ),
          ),
        ],
      ),
    );
  }



  List<ChartPoint> getChartPoints(List<double> xData, List<double> yData) {
    assert(xData.length == yData.length);
    List<ChartPoint> points = [];
    for (int i = 0; i < xData.length; i++) {
      ChartPoint tmp = ChartPoint(x: xData[i], y: yData[i]);
      points.add(tmp);
    }
    return points;
  }
}

// Widget _renderBody() {
//   return Container(
//       child: Column(
//     children: [
//       FutureBuilder<List<double>?>(
//         future: data,
//         builder: (context, snapshot) {
//           if (snapshot.hasError) {
//             return Text('Something went wrong!');
//           } else if (snapshot.hasData) {
//             List<double>? data = snapshot.data;
//             return _renderChart(data, 'Yield of ${this.field.fieldName}');
//           } else {
//             return Center(
//               child: CircularProgressIndicator(),
//             );
//           }
//         },
//       ),
//     ],
//   ));
// }
//
//
//
// Widget _renderChart(List<double>? data, String title) {
//   final List<ChartData> chartData = [];
//   if (data != null) {
//     for (var index = 0; index < data.length; index++) {
//       chartData.add(ChartData(index, data.elementAt(index)));
//     }
//   }
//   return Container(
//       child: Column(
//     children: [
//       Container(
//         child: SfCartesianChart(
//           title: ChartTitle(text: title),
//           tooltipBehavior: _tooltipBehavior,
//           //legend: Legend(isVisible: true),
//           primaryXAxis:
//               NumericAxis(edgeLabelPlacement: EdgeLabelPlacement.shift),
//           primaryYAxis: NumericAxis(
//               numberFormat: NumberFormat.simpleCurrency(decimalDigits: 0),
//               labelFormat: '{value}kg/ha'),
//           series: [
//             LineSeries<ChartData, int>(
//                 name: 'Yield',
//                 dataSource: chartData,
//                 xValueMapper: (ChartData data, _) => data.x,
//                 yValueMapper: (ChartData data, _) => data.y,
//                 dataLabelSettings: DataLabelSettings(isVisible: true),
//                 enableTooltip: true)
//           ],
//         ),
//         //padding: EdgeInsets.only(left: 10, top: 20, right: 10, bottom: 20),
//       ),
//     ],
//   ));
// }

class ChartPoint {
  final double x;
  final double y;

  ChartPoint({required this.x, required this.y});
}
