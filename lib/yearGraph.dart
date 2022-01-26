import 'package:charts_flutter/flutter.dart';
import 'package:expense_diary_arsenel/diary.dart';
import 'package:expense_diary_arsenel/graphicView.dart';
import 'package:expense_diary_arsenel/models/graphModel.dart';
import 'package:expense_diary_arsenel/models/unit_entry.dart';
import 'package:expense_diary_arsenel/utils/database.dart';
import 'package:flutter/cupertino.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:math';
import 'package:flutter/painting.dart' as p;
import 'package:charts_flutter/src/text_element.dart' as TextElement;
import 'package:charts_flutter/src/text_style.dart' as style;
import 'package:intl/date_symbol_data_local.dart';

num clickedtotal;

class NestedMainGraph extends StatefulWidget {
  String currentyear, total;
  NestedMainGraph(this.currentyear, this.total);
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return YearGraphState(currentyear, total);
  }
}

class YearGraphState extends State<NestedMainGraph> {
  List<charts.Series<BarChartModel, String>> series1;
  int cash = 0;
  String currentyear, total;
  Future<List<charts.Series<BarChartModel, String>>> _yearExpenses;
  List<charts.Series<DayClassification, String>> series2;
  Future<List<charts.Series<DayClassification, String>>> _classification;
  YearGraphState(this.currentyear, this.total);
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _yearExpenses = getMonthexpenses(currentyear);
    _classification = getPieData(currentyear);
    getBifercation(currentyear);
  }

  Future<List<charts.Series<DayClassification, String>>> getPieData(
      String year) async {
    print("get pie data");
    final _data = await DBProvider.db.getClassificationYear(year);
    if (_data == null) {
      print("is null");
      return null;
    }
    print(_data);
    var length = (_data == null) ? 0 : _data.length;
    List<DayClassification> temp = [];
    for (int i = 0; i < length; i++) {
      DayClassification obj = DayClassification(_data[i]["classification"],
          _data[i]["SUM(amount)"], charts.ColorUtil.fromDartColor(Colors.blue));
      print(obj.classification + obj.total.toString() + obj.color.toString());
      temp.add(obj);
    }

    List<charts.Series<DayClassification, String>> series = [
      charts.Series(
        id: "What is this",
        data: temp,
        domainFn: (DayClassification series, _) => series.classification,
        measureFn: (DayClassification series, _) => series.total,
        labelAccessorFn: (DayClassification row, _) =>
            '${row.classification}: ₹ ${row.total}',
      )
    ];
    setState(() {
      series2 = series;
    });
    return series;
  }

  getBifercation(String year) async {
    final temp = await DBProvider.db.getCashOnline(year);
    setState(() {
      if (temp != null)
        cash = temp[0]["SUM(amount)"];
      else
        cash = 0;
    });
    print(temp);
  }

  Future<List<charts.Series<BarChartModel, String>>> getMonthexpenses(
      String year) async {
    var months = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
    final temp = await DBProvider.db.getYearGraph(year);
    print(temp.runtimeType);
    List typefinal = [{}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}];
    var length = (temp == null) ? 0 : temp.length;
    for (int i = 0; i < length; i++) {
      int month = int.parse(temp[i]["monthYear"]) - int.parse(year);
      month = month ~/ 10000;
      months[month] = 1;
      var temp2 = ((month < 10) ? "0" : "") + month.toString();
      typefinal[month - 1] = {"monthYear": temp2, "total": temp[i]["total"]};
      // print(month.toString() + " exists");
    }
    // print(months);
    for (int i = 1; i < 13; i++) {
      if (months[i] == 0) {
        var temp2 = ((i < 10) ? "0" : "") + i.toString();
        typefinal[i - 1] = {"monthYear": temp2, "total": 0};
      }
    }
    final returnfinal = typefinal;
    List<BarChartModel> monthlyExpenses = [];
    for (var u in returnfinal) {
      BarChartModel obj = BarChartModel(u["monthYear"], u["total"],
          charts.ColorUtil.fromDartColor(Colors.blue));
      monthlyExpenses.add(obj);
    }
    print(typefinal);
    List<charts.Series<BarChartModel, String>> series = [
      charts.Series(
          id: "What is this",
          data: monthlyExpenses,
          domainFn: (BarChartModel series, _) => series.month,
          measureFn: (BarChartModel series, _) => series.total,
          colorFn: (BarChartModel series, _) => series.color)
    ];
    setState(() {
      series1 = series;
    });
    return series;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          currentyear ?? "Error",
          style: p.TextStyle(color: Colors.black54, fontFamily: 'RobotoMono'),
        ),
        elevation: 0,
      ),
      body: Container(
        padding: EdgeInsets.all(8),
        child: SingleChildScrollView(
          child: Container(
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(10)),
                  child: ListTile(
                    title: Text(
                      "Total",
                      style: p.TextStyle(
                          color: Colors.grey,
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                    ),
                    trailing: Text(
                      "₹ " + total,
                      style: p.TextStyle(
                          color: Colors.grey,
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Container(
                    child: Container(
                  padding: EdgeInsets.all(10),
                  height: MediaQuery.of(context).size.height * 0.55,
                  child: (series1 != null)
                      ? charts.BarChart(
                          series1,
                          animate: true,
                          behaviors: [
                            charts.LinePointHighlighter(
                                symbolRenderer: CustomCircleSymbolRenderer())
                          ],
                          selectionModels: [
                            charts.SelectionModelConfig(
                                changedListener: (charts.SelectionModel model) {
                              if (model.hasDatumSelection)
                                setState(() {
                                  clickedtotal = model.selectedSeries[0]
                                      .measureFn(model.selectedDatum[0].index);
                                });

                              print(model.selectedSeries[0]
                                  .measureFn(model.selectedDatum[0].index));
                            })
                          ],
                        )
                      : Container(),
                )),
                SizedBox(
                  height: 10,
                ),
                Container(
                  padding: EdgeInsets.all(8),
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(10)),
                  child: Column(
                    children: [
                      SizedBox(
                        height: 5,
                      ),
                      Text(
                        "Payments",
                        style: p.TextStyle(
                            color: Colors.grey,
                            fontSize: 20,
                            fontWeight: FontWeight.bold),
                      ),
                      ListTile(
                        title: Text(
                          "Cash ",
                          style: p.TextStyle(
                              color: Colors.grey,
                              fontSize: 18,
                              fontWeight: FontWeight.bold),
                        ),
                        trailing: (cash != null)
                            ? Text(
                                "₹ " + cash.toString() + ".0",
                                style: p.TextStyle(
                                    color: Colors.grey,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold),
                              )
                            : Text(
                                "₹ 0.0",
                                style: p.TextStyle(
                                    color: Colors.grey,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold),
                              ),
                      ),
                      ListTile(
                        title: Text(
                          "Online ",
                          style: p.TextStyle(
                              color: Colors.grey,
                              fontSize: 18,
                              fontWeight: FontWeight.bold),
                        ),
                        trailing: (cash != null)
                            ? Text(
                                "₹ " + (double.parse(total) - cash).toString(),
                                style: p.TextStyle(
                                    color: Colors.grey,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold),
                              )
                            : Text(
                                "₹ 0.0",
                                style: p.TextStyle(
                                    color: Colors.grey,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold),
                              ),
                      ),
                      SizedBox(
                        height: 10,
                      )
                    ],
                  ),
                ),
                Container(
                  height: MediaQuery.of(context).size.height * 0.40,
                  child: (series2 != null)
                      ? charts.PieChart(series2,
                          animate: false,
                          defaultRenderer: new charts.ArcRendererConfig(
                              arcWidth: 120,
                              arcRendererDecorators: [
                                // <-- add this to the code
                                charts
                                    .ArcLabelDecorator() // <-- and this of course
                              ]))
                      : Container(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

//tool tips for selected bar
class CustomCircleSymbolRenderer extends charts.CircleSymbolRenderer {
  @override
  void paint(charts.ChartCanvas canvas, Rectangle<num> bounds,
      {List<int> dashPattern,
      Color fillColor,
      FillPatternType fillPattern,
      Color strokeColor,
      double strokeWidthPx}) {
    super.paint(canvas, bounds,
        dashPattern: dashPattern,
        fillColor: fillColor,
        fillPattern: fillPattern,
        strokeColor: strokeColor,
        strokeWidthPx: strokeWidthPx);
    canvas.drawRect(
        Rectangle(bounds.left - 5, bounds.top - 30, bounds.width + 10,
            bounds.height + 10),
        fill: Color.white);
    var textStyle = style.TextStyle();
    textStyle.color = Color.black;
    textStyle.fontSize = 15;
    canvas.drawText(
        TextElement.TextElement(clickedtotal.toString(), style: textStyle),
        (bounds.left).round(),
        (bounds.top - 28).round());
  }
}
