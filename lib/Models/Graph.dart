import 'package:fl_chart/fl_chart.dart' as charts;
import 'package:flutter/cupertino.dart';

class Graph {
  final String year;
  final int subscribers;
  final double count;
  final Color barColor;

  Graph({
    required this.year, 
    required this.subscribers,
    required this.count,
    required this.barColor,
  });
}
