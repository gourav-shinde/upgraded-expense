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

String clickedtotal;

class MonthGraph extends StatefulWidget {
  String currentyear, currentmonth, total;
  MonthGraph(this.currentyear, this.currentmonth, this.total);
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return MonthGraphState(currentyear, currentmonth, total);
  }
}

String monthToMonth(String mon) {
  switch (mon) {
    case '01':
      return "January";
      break;
    case '02':
      return "February";
      break;
    case '03':
      return "March";
      break;
    case '04':
      return "April";
      break;
    case '05':
      return "May";
      break;
    case '06':
      return "June";
      break;
    case '07':
      return "July";
      break;
    case '08':
      return "August";
      break;
    case '09':
      return "September";
      break;
    case '10':
      return "October";
      break;
    case '11':
      return "November";
      break;
    case '12':
      return "December";
      break;
  }
}

class MonthGraphState extends State<MonthGraph> {
  List<charts.Series<MonthGraphModel, String>> series1;
  int cash = 0;
  String currentyear, currentmonth, total;
  Future<List<charts.Series<MonthGraphModel, String>>> _monthExpenses;

  List<charts.Series<DayClassification, String>> series2;
  Future<List<charts.Series<DayClassification, String>>> _classification;
  MonthGraphState(this.currentyear, this.currentmonth, this.total);
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _monthExpenses = getMonthExpenese(currentyear, currentmonth);
    _classification = getPieData(currentyear, currentmonth);
    getCash(currentyear, currentmonth);
  }

  getCash(String year, String month) async {
    final _cash = await DBProvider.db.getCashOnlineMonth(year, month);
    setState(() {
      if (_cash != null)
        cash = _cash[0]["SUM(amount)"];
      else
        cash = 0;
    });
  }

  Future<List<charts.Series<DayClassification, String>>> getPieData(
      String year, String month) async {
    print("get pie data");
    final _data = await DBProvider.db.getClassificationMonth(year, month);
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

  Future<List<charts.Series<MonthGraphModel, String>>> getMonthExpenese(
      String year, String month) async {
    int monthlength =
        DateTime(int.parse(year), int.parse(month) + 1, 0).day + 1;
    final temp = await DBProvider.db.getMonthGraph(year, month);
    List finalLIst = List.filled(monthlength, 0);

    var length = (temp == null) ? 0 : temp.length;
    for (int i = 0; i < length; i++) {
      String date = temp[i]["date"].toString().substring(8);
      finalLIst[int.parse(date)] = {
        "date": date,
        "total": temp[i]["SUM(amount)"]
      };
    }
    for (int i = 1; i < monthlength; i++) {
      var temp = {};
      if (finalLIst[i] == 0) {
        String date = ((i < 10) ? "0" : "") + i.toString();
        finalLIst[i] = {"date": date, "total": 0};
      }
    }
    print(finalLIst);
    List<MonthGraphModel> monthlyExpenses = [];
    for (int i = 1; i < monthlength; i++) {
      MonthGraphModel obj = MonthGraphModel(finalLIst[i]["date"],
          finalLIst[i]["total"], charts.ColorUtil.fromDartColor(Colors.blue));
      monthlyExpenses.add(obj);
    }

    List<charts.Series<MonthGraphModel, String>> series = [
      charts.Series(
          id: "What is this",
          data: monthlyExpenses,
          domainFn: (MonthGraphModel series, _) => series.date,
          measureFn: (MonthGraphModel series, _) => series.total,
          colorFn: (MonthGraphModel series, _) => series.color)
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
          currentyear + " " + monthToMonth(currentmonth.toString()),
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
                    height: MediaQuery.of(context).size.height * 0.55,
                    padding: EdgeInsets.all(10),
                    child: (series1 != null)
                        ? SingleChildScrollView(
                            scrollDirection: p.Axis.horizontal,
                            child: Container(
                              width: 700,
                              child: charts.BarChart(
                                series1,
                                animate: true,
                                behaviors: [
                                  charts.LinePointHighlighter(
                                      symbolRenderer:
                                          CustomCircleSymbolRenderer())
                                ],
                                selectionModels: [
                                  charts.SelectionModelConfig(changedListener:
                                      (charts.SelectionModel model) {
                                    if (model.hasDatumSelection)
                                      setState(() {
                                        clickedtotal = " ₹ " +
                                            model.selectedSeries[0]
                                                .measureFn(model
                                                    .selectedDatum[0].index)
                                                .toString();
                                      });
                                  })
                                ],
                              ),
                            ))
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
                                  "₹ " +
                                      (double.parse(total) - cash).toString(),
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
          )),
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
        Rectangle(bounds.left + 5, bounds.top - 15, bounds.width + 20,
            bounds.height + 10),
        fill: Color.white);
    var textStyle = style.TextStyle();
    textStyle.color = Color.black;
    textStyle.fontSize = 15;
    canvas.drawText(
        TextElement.TextElement(clickedtotal.toString(), style: textStyle),
        (bounds.left + 5).round(),
        (bounds.top - 15).round());
  }
}
