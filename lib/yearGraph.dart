import 'dart:html';

import 'package:expense_diary_arsenel/diary.dart';
import 'package:expense_diary_arsenel/graphicView.dart';
import 'package:expense_diary_arsenel/models/unit_entry.dart';
import 'package:expense_diary_arsenel/utils/database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

class NestedMainGraph extends StatefulWidget {
  var currentyear;
  NestedMainGraph(this.currentyear);
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return YearGraphState(currentyear);
  }
}

class YearGraphState extends State<NestedMainGraph> {
  var currentyear;
  YearGraphState(this.currentyear);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(),
      body: Container(),
      bottomNavigationBar: BottomNavigationBar(),
    );
  }
}
