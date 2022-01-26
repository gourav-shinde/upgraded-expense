import 'package:expense_diary_arsenel/day_expenses.dart';
import 'package:expense_diary_arsenel/graphicView.dart';
import 'package:expense_diary_arsenel/main.dart';
import 'package:expense_diary_arsenel/month_list.dart';
import 'package:expense_diary_arsenel/yearGraph.dart';
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
                calendarStyle: CalendarStyle(
                  todayDecoration: BoxDecoration(
                      color: Colors.grey[350], shape: BoxShape.circle),
                  selectedDecoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.black45,
                  ),
                  todayTextStyle: TextStyle(color: Colors.black),
                  weekendTextStyle: TextStyle(color: Colors.red),
                ),
                firstDay: DateTime.utc(2000, 01, 01),
                lastDay: DateTime.utc(2050, 01, 01),
                focusedDay: date1,
                selectedDayPredicate: (day) => isSameDay(day, date1),
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    date1 = selectedDay;
                    print(convDateToString(date1));
                    date = convDateToString(date1);
                    month = date1.month.toString();
                    year = date1.year.toString();
                    mondisp = monthToMonth(month);
                    dayexpense = getdayExpense(date);
                  });
                },
                onPageChanged: (focusedDay) {
                  setState(() {
                    print(focusedDay);
                    date1 = focusedDay;
                    print(convDateToString(date1));
                    date = convDateToString(date1);
                    month = date1.month.toString();
                    year = date1.year.toString();
                    mondisp = monthToMonth(month);
                    dayexpense = getdayExpense(date);
                  });
                },
                onFormatChanged: (format) {},
                availableCalendarFormats: const {
                  CalendarFormat.twoWeeks: 'Minimal',
                  CalendarFormat.month: 'Moderate',
                  CalendarFormat.week: 'Full'
                },
              ),
              SizedBox(
                height: 10,
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
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    CupertinoPageRoute(
                                        builder: (context) => NestedMainGraph(
                                            year, snapshot.data['year'])),
                                  ).then((value) => setState(() {
                                        dayexpense = getdayExpense(date);
                                      }));
                                },
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
            BottomNavigationBarItem(icon: Icon(Icons.payment), label: "Records")
          ],
        ));
  }
}
