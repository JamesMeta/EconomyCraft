import 'package:economycraft/classes/pie_chart_data.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class PieChart1Widget extends StatelessWidget {
  final String title;
  final List<PieChartData> chartData;

  const PieChart1Widget({
    super.key,
    required this.chartData,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      child: SfCircularChart(
        title: ChartTitle(
          text: title,
          textStyle: TextStyle(fontWeight: FontWeight.bold),
        ),
        series: <CircularSeries>[
          PieSeries<PieChartData, String>(
            dataSource: chartData,
            pointColorMapper: (PieChartData data, _) => data.colour,
            xValueMapper: (PieChartData data, _) => data.categoryTitle,
            yValueMapper: (PieChartData data, _) => data.proportion,
            dataLabelMapper: (PieChartData data, _) => data.categoryTitle,
            explode: true,
            dataLabelSettings: DataLabelSettings(
              isVisible: true,
              labelPosition: ChartDataLabelPosition.outside,
            ),
          ),
        ],
      ),
    );
  }
}
