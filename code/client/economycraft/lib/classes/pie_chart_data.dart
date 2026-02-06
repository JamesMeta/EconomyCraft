import 'package:flutter/material.dart';

class PieChartData {
  final String categoryTitle;
  final double proportion;
  final Color? colour;

  PieChartData({
    required this.categoryTitle,
    required this.proportion,
    this.colour,
  });
}
