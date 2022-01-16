import 'package:expense_diary_arsenel/day_expenses.dart';
import 'package:expense_diary_arsenel/graphicView.dart';
import 'package:expense_diary_arsenel/main.dart';
import 'package:expense_diary_arsenel/month_list.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:expense_diary_arsenel/utils/database.dart';

class Diary extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return DiaryState();
  }
}

class DiaryState extends State<Diary> {
  //variables
  CalendarController _calendarController;
  DateTime date1 = new DateTime.now();
  String date = "";
  String month = "", year = "", mondisp = "";
  Future dayexpense, monthexpense, yearexpense;

  //Functions
  String convDateToString(DateTime value) {
    final DateFormat formatter = DateFormat('yyyy-MM-dd');
    final String formatted = formatter.format(value);
    return formatted;
  }

  String monthToMonth(String mon) {
    switch (mon) {
      case '1':
        return "January";
        break;
      case '2':
        return "February";
        break;
      case '3':
        return "March";
        break;
      case '4':
        return "April";
        break;
      case '5':
        return "May";
        break;
      case '6':
        return "June";
        break;
      case '7':
        return "July";
        break;
      case '8':
        return "August";
        break;
      case '9':
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

  @override
  void initState() {
    super.initState();
    _calendarController = CalendarController();
    date = convDateToString(date1);
    month = DateTime.now().month.toString();
    year = DateTime.now().year.toString();
    mondisp = monthToMonth(month);
    dayexpense = getdayExpense(date);
    print(month);
    print(dayexpense);
    print("hmm");
  }

  getdayExpense(String date) async {
    print("1");
    final val = await DBProvider.db.getDayExpenses(date);
    print("hello");
    print(val);
    return val;
  }

  @override
  void dispose() {
    _calendarController.dispose();
    super.dispose();
  }

  void onTapFunc(int index) {
    setState(() {
      setState(() {
        switch (index) {
          case 0:
            {}
            break;
          case 1:
            {
              Navigator.pop(context);
              Navigator.push(context, CupertinoPageRoute(builder: (context) {
                return MyHomePage();
              }));
            }
            break;
          case 2:
            {
              Navigator.pop(context);
              Navigator.push(context, CupertinoPageRoute(builder: (context) {
                return Graph();
              }));
            }
            break;
        }
      });
    });
  }

  //UI
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          title: Text(
            "Diary",
            style: TextStyle(color: Colors.black54, fontFamily: 'RobotoMono'),
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              TableCalendar(
                calendarStyle: const CalendarStyle(
                    todayColor: Colors.black26,
                    weekendStyle: TextStyle(
                        color: Colors.black, fontWeight: FontWeight.w500),
                    selectedColor: Colors.black45),
                calendarController: _calendarController,
                onDaySelected: (day, events, holidays) {
                  setState(() {
                    print(convDateToString(day));
                    date = convDateToString(day);
                    month = day.month.toString();
                    year = day.year.toString();
                    mondisp = monthToMonth(month);
                    dayexpense = getdayExpense(date);
                  });
                },
                onVisibleDaysChanged: (first, last, format) {
                  print(DateFormat.M().format(first) + "helllo");
                  print(DateFormat.y().format(first));
                  var month2 = int.parse(DateFormat.M().format(first));
                  var year2 = int.parse(DateFormat.y().format(first));
                  if (month == 12) {
                    month2 = 1;
                    year2 = year2 + 1;
                  } else {
                    month2 = month2 + 1;
                  }
                  String monthString =
                      ((month2 < 10) ? "0" : "") + month2.toString();
                  DateTime day = DateTime.parse(
                      year2.toString() + "-" + monthString + "-01");
                  setState(() {
                    print(convDateToString(day));
                    date = convDateToString(day);
                    month = day.month.toString();
                    year = day.year.toString();
                    mondisp = monthToMonth(month);
                    dayexpense = getdayExpense(date);
                  });
                  //current month
                },
                availableCalendarFormats: const {
                  CalendarFormat.twoWeeks: 'Minimal',
                  CalendarFormat.month: 'Moderate',
                  CalendarFormat.week: 'Full'
                },
              ),
              FutureBuilder(
                future: dayexpense,
                builder: (context, snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.none:
                      return Container();
                      break;
                    case ConnectionState.waiting:
                      return Container();
                      break;
                    case ConnectionState.active:
                      return Container();
                      break;
                    case ConnectionState.done:
                      return Column(
                        children: [
                          Container(
                              margin: EdgeInsets.fromLTRB(15, 0, 15, 10),
                              decoration: BoxDecoration(
                                  color: Colors.grey[350],
                                  borderRadius: BorderRadius.circular(7)),
                              child: ListTile(
                                //tileColor: Colors.grey,
                                title: Text(date + " Expense"),
                                trailing: Text("₹ " + snapshot.data['day']),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    CupertinoPageRoute(
                                        builder: (context) => DayList(
                                            date, snapshot.data['day'])),
                                  ).then((value) => setState(() {
                                        dayexpense = getdayExpense(date);
                                      }));
                                  // Navigator.push(context,
                                  //     CupertinoPageRoute(builder: (context) {
                                  //   return DayList(date, snapshot.data['day']);
                                  // }));
                                },
                              )),
                          Container(
                              margin: EdgeInsets.fromLTRB(15, 0, 15, 10),
                              decoration: BoxDecoration(
                                  color: Colors.grey[350],
                                  borderRadius: BorderRadius.circular(7)),
                              child: ListTile(
                                title: Text(mondisp + " Expense"),
                                trailing: Text("₹ " + snapshot.data['month']),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    CupertinoPageRoute(
                                        builder: (context) => MonthList(
                                            month,
                                            year,
                                            snapshot.data['month'],
                                            mondisp + " " + year)),
                                  ).then((value) => setState(() {
                                        dayexpense = getdayExpense(date);
                                      }));
                                },
                              )),
                          Container(
                              margin: EdgeInsets.fromLTRB(15, 0, 15, 10),
                              decoration: BoxDecoration(
                                  color: Colors.grey[350],
                                  borderRadius: BorderRadius.circular(7)),
                              child: ListTile(
                                title: Text(year + " Expense"),
                                trailing: Text("₹ " + snapshot.data['year']),
                              )),
                        ],
                      );
                      break;
                  }
                },
              ),
            ],
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: Colors.white,
          onTap: onTapFunc,
          currentIndex: 0,
          items: [
            BottomNavigationBarItem(icon: Icon(Icons.book), label: 'Diary'),
            BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
            BottomNavigationBarItem(icon: Icon(Icons.payment), label: "Test")
          ],
        ));
  }
}
