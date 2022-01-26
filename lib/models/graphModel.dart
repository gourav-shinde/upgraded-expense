import 'package:charts_flutter/flutter.dart' as charts;

class BarChartModel {
  String month;
  int total;
  final charts.Color color;

  BarChartModel(
    this.month,
    this.total,
    this.color,
  );
}

class MonthGraphModel {
  String date;
  int total;
  final charts.Color color;

  MonthGraphModel(
    this.date,
    this.total,
    this.color,
  );
}

class DayClassification {
  String classification;
  int total;
  final charts.Color color;

  DayClassification(
    this.classification,
    this.total,
    this.color,
  );
}
