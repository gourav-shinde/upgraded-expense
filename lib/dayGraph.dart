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

class DayGraph extends StatefulWidget {
  String date, total;
  DayGraph(this.date, this.total);
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return DayGraphState(date, total);
  }
}

class DayGraphState extends State<DayGraph> {
  String date, total;
  int cash;
  DayGraphState(this.date, this.total);
  List<charts.Series<DayClassification, String>> series1;
  Future<List<charts.Series<DayClassification, String>>> _dayclassification;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _dayclassification = getPieData(date);
    getCash(date);
  }

  getCash(String dart) async {
    final _cash = await DBProvider.db.getCashOnlineDay(date);
    setState(() {
      if (_cash != null)
        cash = _cash[0]["SUM(amount)"];
      else
        cash = 0;
    });
  }

  Future<List<charts.Series<DayClassification, String>>> getPieData(
      String date) async {
    final _data = await DBProvider.db.getPieDay(date);
    if (_data == null) return null;
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
          date ?? "",
          style: p.TextStyle(color: Colors.black54, fontFamily: 'RobotoMono'),
        ),
        elevation: 0,
      ),
      body: Container(
        padding: EdgeInsets.all(8),
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
            Expanded(
              child: Container(
                // height: MediaQuery.of(context).size.height * 0.40,
                child: (series1 != null)
                    ? charts.PieChart(series1,
                        animate: true,
                        defaultRenderer: new charts.ArcRendererConfig(
                            arcWidth: 120,
                            arcRendererDecorators: [
                              // <-- add this to the code
                              charts
                                  .ArcLabelDecorator() // <-- and this of course
                            ]))
                    : Container(),
              ),
            ),
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
            )
          ],
        ),
      ),
    );
  }
}
