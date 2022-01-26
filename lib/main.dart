import 'package:expense_diary_arsenel/diary.dart';
import 'package:expense_diary_arsenel/graphicView.dart';
import 'package:expense_diary_arsenel/models/unit_entry.dart';
import 'package:expense_diary_arsenel/utils/database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  initializeDateFormatting().then((_) => runApp(MyApp()));
  //runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Expense',
      theme: ThemeData(
        primarySwatch: Colors.grey,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(),
      debugShowCheckedModeBanner: false,
      // home: MyHomePage(title: 'Tenant Manager'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

String convDateToString(DateTime value) {
  final DateFormat formatter = DateFormat('yyyy-MM-dd');
  final String formatted = formatter.format(value);
  return formatted;
}

class _MyHomePageState extends State<MyHomePage> {
  //variables
  TextEditingController valueController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  bool _cash = true;
  String classification = "Food";
  String date = convDateToString(DateTime.now());
  //functions
  void onTapFunc(int index) {
    setState(() {
      setState(() {
        switch (index) {
          case 0:
            {
              Navigator.pop(context);
              Navigator.push(context, CupertinoPageRoute(builder: (context) {
                return Diary();
              }));
            }
            break;
          case 1:
            {}
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

  //UI here
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: Text(
            "Arsenel Expense",
            style: TextStyle(color: Colors.black54, fontFamily: 'RobotoMono'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                _bottomSheetModel(context);
              },
              child: Icon(Icons.menu),
            )
          ],
          elevation: 0,
        ),
        body: SingleChildScrollView(
          child: Stack(
            children: [
              Container(
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width,
                    //date picker card
                    padding: EdgeInsets.all(15),
                    decoration:
                        BoxDecoration(borderRadius: BorderRadius.circular(60)),
                    child: Card(
                      color: Colors.white54,
                      shadowColor: Colors.black38,
                      child: Column(
                        children: [
                          Align(
                              alignment: Alignment.centerLeft,
                              child: Padding(
                                padding: EdgeInsets.fromLTRB(10, 8, 0, 5),
                                child: Text(
                                  "Date",
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w800),
                                ),
                              )),
                          Divider(
                            color: Colors.black,
                          ),
                          Align(
                            alignment: Alignment.center,
                            child: Container(
                              child: CupertinoDatePicker(
                                mode: CupertinoDatePickerMode.date,
                                onDateTimeChanged: (value) {
                                  date = convDateToString(value);
                                },
                              ),
                              height: 100,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.center,
                    child: Container(
                      width: 220,
                      alignment: Alignment.center,
                      padding: EdgeInsets.fromLTRB(50, 0, 50, 0),
                      child: TextField(
                        controller: valueController,
                        keyboardType: TextInputType.phone,
                        style: TextStyle(fontSize: 25),
                        textAlign: TextAlign.center,
                        decoration: InputDecoration(hintText: 'Amount'),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.center,
                    child: Container(
                      color: Colors.white,
                      padding: EdgeInsets.fromLTRB(0, 5, 0, 0),
                      width: 200,
                      child: Row(
                        children: [
                          Expanded(
                              child: TextButton(
                            onPressed: () {
                              setState(() {
                                _cash = true;
                              });
                              print("CashPayment");
                            },
                            child: Text('Cash'),
                            style: TextButton.styleFrom(
                                backgroundColor:
                                    _cash ? Colors.grey[350] : Colors.white,
                                primary: Colors.black,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(25))),
                          )),
                          Expanded(
                              child: TextButton(
                            onPressed: () {
                              setState(() {
                                _cash = false;
                              });
                              print("OnlinePayment");
                            },
                            child: Text('Online'),
                            style: TextButton.styleFrom(
                                backgroundColor:
                                    _cash ? Colors.white : Colors.grey[350],
                                primary: Colors.black,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(25))),
                          )),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    //classification card
                    width: MediaQuery.of(context).size.width,
                    padding: EdgeInsets.all(15),
                    decoration:
                        BoxDecoration(borderRadius: BorderRadius.circular(60)),
                    child: Card(
                      color: Colors.white54,
                      shadowColor: Colors.black38,
                      child: Column(
                        children: [
                          Align(
                              alignment: Alignment.centerLeft,
                              child: Padding(
                                padding: EdgeInsets.fromLTRB(10, 8, 0, 5),
                                child: Text(
                                  "Classification",
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w800),
                                ),
                              )),
                          Divider(
                            color: Colors.black,
                          ),
                          Align(
                            alignment: Alignment.center,
                            child: Container(
                              child: CupertinoPicker(
                                children: [
                                  Padding(
                                    padding: EdgeInsets.fromLTRB(0, 8, 0, 0),
                                    child: Text('Food'),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.fromLTRB(0, 8, 0, 0),
                                    child: Text('Electronics'),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.fromLTRB(0, 8, 0, 0),
                                    child: Text('Travel'),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.fromLTRB(0, 8, 0, 0),
                                    child: Text('Clothing'),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.fromLTRB(0, 8, 0, 0),
                                    child: Text('Miscellaneous'),
                                  ),
                                ],
                                itemExtent: 40,
                                looping: true,
                                onSelectedItemChanged: (value) {
                                  print(value);
                                  switch (value) {
                                    case 0:
                                      {
                                        classification = "Food";
                                      }
                                      break;
                                    case 1:
                                      {
                                        classification = "Electronics";
                                      }
                                      break;
                                    case 2:
                                      {
                                        classification = "Travel";
                                      }
                                      break;
                                    case 3:
                                      {
                                        classification = "Clothing";
                                      }
                                      break;
                                    case 4:
                                      {
                                        classification = "Miscellaneous";
                                      }
                                      break;
                                  }
                                },
                              ),
                              height: 100,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                      width: MediaQuery.of(context).size.width,
                      padding: EdgeInsets.fromLTRB(15, 0, 15, 15),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(60),
                      ),
                      child: Card(
                        color: Colors.grey[200],
                        child: TextField(
                          controller: descriptionController,
                          decoration: InputDecoration(
                              hintText: 'Description',
                              contentPadding: EdgeInsets.fromLTRB(10, 0, 0, 0)),
                        ),
                      )),
                  Align(
                    alignment: Alignment.center,
                    child: Container(
                      child: TextButton(
                        child: Text(
                          'SAVE',
                          style: TextStyle(fontSize: 20),
                        ),
                        onPressed: () {
                          final String amount = valueController.text;
                          final String description = descriptionController.text;
                          print("pressed");

                          print(date);
                          print(classification);
                          print(amount);
                          _cash ? print("cash") : print("online");
                          print(description);

                          String mode =
                              (_cash) ? 'CashPayment' : 'OnlinePayment';
                          if (amount != null && amount != "") {
                            var newEntry = Entry(date, classification, amount,
                                mode, description);
                            var stat = DBProvider.db.newEntry(newEntry);
                            print(stat);
                            //reset fields
                            setState(() {
                              _cash = true;
                              valueController.clear();
                              descriptionController.clear();
                            });
                            Navigator.of(context).push(DialogRoute(
                                context: context,
                                builder: (context) {
                                  return CupertinoAlertDialog(
                                    title: Text("Entry Saved"),
                                    actions: [
                                      CupertinoDialogAction(
                                        child: Text("OK"),
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                      )
                                    ],
                                  );
                                }));
                          }
                        },
                      ),
                    ),
                  ),
                ],
              ))
            ],
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: Colors.white,
          onTap: onTapFunc,
          currentIndex: 1,
          items: [
            BottomNavigationBarItem(icon: Icon(Icons.book), label: 'Diary'),
            BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
            BottomNavigationBarItem(icon: Icon(Icons.payment), label: "Records")
          ],
        ));
  }
}

void _bottomSheetModel(BuildContext context) {
  showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
            color: Color(0xFF737373),
            height: MediaQuery.of(context).size.height * 0.24,
            child: Container(
              decoration: BoxDecoration(
                  color: const Color.fromRGBO(255, 255, 255, 1),
                  borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(20),
                      topRight: const Radius.circular(20))),
              child: Column(
                children: [
                  SizedBox(
                    height: 5,
                  ),
                  ListTile(
                    title: Text("Backup"),
                  ),
                  ListTile(
                    title: Text("Restore"),
                  ),
                  ListTile(
                    title: Text("Add Category"),
                  )
                ],
              ),
            ));
      });
}
