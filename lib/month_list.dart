import 'package:expense_diary_arsenel/diary.dart';
import 'package:expense_diary_arsenel/graphicView.dart';
import 'package:expense_diary_arsenel/main.dart';
import 'package:expense_diary_arsenel/utils/database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MonthList extends StatefulWidget {
  String monthYear, total;
  MonthList(this.monthYear, this.total);
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return MonthlistState(monthYear, total);
  }
}

class MonthlistState extends State<MonthList> {
  String monthYear, total;
  MonthlistState(this.monthYear, this.total);
  //variables
  Future _entryFuture;
  //Functions
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _entryFuture = getList(monthYear);
  }

  getList(String monthYear) async {
    final _entrydata = await DBProvider.db.getDayList(monthYear);
    return _entrydata;
  }

  void onTapFunc(int index) {
    setState(() {
      setState(() {
        switch (index) {
          case 0:
            {
              Navigator.pop(context);
            }
            break;
          case 1:
            {
              Navigator.pop(context);
              Navigator.pop(context);
              Navigator.push(context, CupertinoPageRoute(builder: (context) {
                return MyHomePage();
              }));
            }
            break;
          case 2:
            {
              Navigator.pop(context);
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
            "month year here" + " Expenses",
            style: TextStyle(color: Colors.black54, fontFamily: 'RobotoMono'),
          ),
        ),
        body: FutureBuilder(
          future: _entryFuture,
          builder: (context, entryData) {
            switch (entryData.connectionState) {
              case ConnectionState.none:
                return Container();

              case ConnectionState.waiting:
                return Container();

              case ConnectionState.active:
                return Container();

              case ConnectionState.done:
                return entryData.data == null
                    ? Container(
                        child: Text("empty"),
                      )
                    : ListView.builder(
                        itemCount: entryData.data.length,
                        itemBuilder: (context, index) {
                          print(entryData.data[index]);
                          return ListTile(
                            title: Text((entryData.data[index]
                                        ["classification"] ??
                                    "hello") +
                                " " +
                                (entryData.data[index]['mode'] ?? "null")),
                            trailing: Text("₹ " +
                                (entryData.data[index]["amount"] ?? "hello")),
                            onTap: () {
                              Navigator.of(context).push(DialogRoute(
                                  context: context,
                                  builder: (context) {
                                    print(entryData.data[index]["id"]);
                                    return CupertinoAlertDialog(
                                      title: Text("Details"),
                                      content: Column(
                                        children: [
                                          SizedBox(
                                            height: 10,
                                          ),
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  entryData.data[index]
                                                          ['date'] ??
                                                      "null",
                                                  style:
                                                      TextStyle(fontSize: 15),
                                                ),
                                              ),
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  "₹ " +
                                                          entryData.data[index]
                                                              ['amount'] ??
                                                      "null",
                                                  style:
                                                      TextStyle(fontSize: 18),
                                                ),
                                              ),
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  entryData.data[index]
                                                          ['mode'] ??
                                                      "null",
                                                  style:
                                                      TextStyle(fontSize: 15),
                                                ),
                                              ),
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  entryData.data[index]
                                                          ['classification'] ??
                                                      "null",
                                                  style:
                                                      TextStyle(fontSize: 15),
                                                ),
                                              ),
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  entryData.data[index]
                                                          ['description'] ??
                                                      "null",
                                                  style:
                                                      TextStyle(fontSize: 15),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      actions: [
                                        CupertinoDialogAction(
                                          child: Text("OK"),
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                        ),
                                        CupertinoDialogAction(
                                          child: Text("Edit"),
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                        ),
                                        CupertinoDialogAction(
                                          child: Text("Delete"),
                                          onPressed: () async {
                                            await DBProvider.db.deleteEntry(
                                                entryData.data[index]['id'],
                                                entryData.data[index]['amount'],
                                                entryData.data[index]
                                                    ['classification'],
                                                entryData.data[index]['mode'],
                                                entryData.data[index]['date']);
                                            Navigator.pop(context);
                                            _entryFuture = getList(monthYear);
                                            setState(() {});
                                          },
                                        )
                                      ],
                                    );
                                  }));
                            },
                          );
                        });
            }
            return Container();
          },
        ),
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: Colors.white,
          onTap: onTapFunc,
          currentIndex: 2,
          items: [
            BottomNavigationBarItem(icon: Icon(Icons.book), label: 'Diary'),
            BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
            BottomNavigationBarItem(icon: Icon(Icons.payment), label: "Test")
          ],
        ));
  }
}
