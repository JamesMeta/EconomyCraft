import 'package:economycraft/classes/price_vs_time.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class Linegraph2Widget extends StatelessWidget {
  final String title;
  final String? subtitle;
  final List<PriceVsTime> data;
  final String? xAxisLabel;
  final String? yAxisLabel;

  const Linegraph2Widget({
    super.key,
    required this.title,
    this.subtitle,
    required this.data,
    this.xAxisLabel,
    this.yAxisLabel,
  });

  @override
  Widget build(BuildContext context) {
    return SfCartesianChart(
      primaryXAxis: DateTimeAxis(),
      primaryYAxis: NumericAxis(),
      tooltipBehavior: TooltipBehavior(enable: true),
      series: <CartesianSeries>[
        LineSeries<PriceVsTime, DateTime>(
          dataSource: data,
          xValueMapper: (PriceVsTime data, _) => data.time,
          yValueMapper: (PriceVsTime data, _) => data.price,
          name: subtitle ?? 'Price',
          markerSettings: const MarkerSettings(isVisible: true),
          dataLabelSettings: const DataLabelSettings(isVisible: true),
        ),
      ],
    );
  }
}
