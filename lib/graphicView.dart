import 'package:expense_diary_arsenel/diary.dart';
import 'package:expense_diary_arsenel/main.dart';
import 'package:expense_diary_arsenel/utils/database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Graph extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return GraphState();
  }
}

class GraphState extends State<Graph> {
  //variables
  Map<String, String> newEntry = {};
  Future _entryFuture;
  //Functions
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _entryFuture = getEntry();
  }

  getEntry() async {
    final _entrydata = await DBProvider.db.getEntry();
    return _entrydata;
  }

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
            {
              Navigator.pop(context);
              Navigator.push(context, CupertinoPageRoute(builder: (context) {
                return MyHomePage();
              }));
            }
            break;
          case 2:
            {}
            break;
        }
      });
    });
  }

  final TextEditingController searchController = TextEditingController();
  String searchString = "";
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
            "All Records",
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
                return Container(
                  child: Center(
                    child: CupertinoActivityIndicator(),
                  ),
                );

              case ConnectionState.active:
                return Container();

              case ConnectionState.done:
                return entryData.data == null
                    ? Container(
                        child: Center(
                          child: Icon(
                            Icons.folder_open_outlined,
                            size: 60,
                          ),
                        ),
                      )
                    : Column(
                        children: [
                          Container(
                            padding: EdgeInsets.fromLTRB(18, 0, 8, 5),
                            child: Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: searchController,
                                    decoration: InputDecoration(
                                      prefixIcon: Icon(Icons.search),
                                    ),
                                    onChanged: (value) {
                                      setState(() {
                                        searchString = value;
                                      });
                                    },
                                  ),
                                ),
                                IconButton(
                                    onPressed: () {
                                      setState(() {
                                        searchController.clear();
                                        searchString = "";
                                      });
                                    },
                                    icon: Icon(Icons.cancel_outlined))
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Expanded(
                              child: ListView.builder(
                                  itemCount: entryData.data.length,
                                  itemBuilder: (context, index) {
                                    print(entryData.data[index]);
                                    return searchString != null &&
                                            ((entryData.data[index]
                                                        ["classification"])
                                                    .toLowerCase()
                                                    .contains(searchString
                                                        .toLowerCase()) ||
                                                (entryData.data[index]
                                                        ["description"])
                                                    .toLowerCase()
                                                    .contains(searchString
                                                        .toLowerCase()))
                                        ? ListTile(
                                            onLongPress: () {
                                              Navigator.of(context)
                                                  .push(DialogRoute(
                                                      context: context,
                                                      builder: (context) {
                                                        return CupertinoAlertDialog(
                                                          title: Text(
                                                              "Do you want to Delete Record?"),
                                                          actions: [
                                                            CupertinoDialogAction(
                                                              child: Text("No"),
                                                              onPressed: () {
                                                                Navigator.pop(
                                                                    context);
                                                              },
                                                            ),
                                                            CupertinoDialogAction(
                                                              isDefaultAction:
                                                                  true,
                                                              child:
                                                                  Text("Yes"),
                                                              onPressed:
                                                                  () async {
                                                                await DBProvider.db.deleteEntry(
                                                                    entryData.data[
                                                                            index][
                                                                        'id'],
                                                                    entryData.data[
                                                                            index]
                                                                        [
                                                                        'amount'],
                                                                    entryData.data[
                                                                            index]
                                                                        [
                                                                        'classification'],
                                                                    entryData.data[
                                                                            index]
                                                                        [
                                                                        'mode'],
                                                                    entryData.data[
                                                                            index]
                                                                        [
                                                                        'date']);
                                                                Navigator.pop(
                                                                    context);
                                                                _entryFuture =
                                                                    getEntry();
                                                                setState(() {});
                                                              },
                                                            )
                                                          ],
                                                        );
                                                      }));
                                            },
                                            title: Card(
                                              shadowColor: Colors.black,
                                              color: Colors.grey[200],
                                              child: Padding(
                                                padding: EdgeInsets.fromLTRB(
                                                    8, 8, 8, 5),
                                                child: Column(
                                                  children: [
                                                    Row(
                                                      children: [
                                                        Align(
                                                          alignment:
                                                              Alignment.topLeft,
                                                          child: Title(
                                                              color:
                                                                  Colors.black,
                                                              child: Text(
                                                                entryData.data[
                                                                            index]
                                                                        [
                                                                        "date"] ??
                                                                    "hello",
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        15,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500),
                                                              )),
                                                        ),
                                                        Expanded(
                                                          child: Align(
                                                            alignment: Alignment
                                                                .topRight,
                                                            child: Title(
                                                                color: Colors
                                                                    .green,
                                                                child: Text(
                                                                  "₹ " +
                                                                          entryData.data[index]
                                                                              [
                                                                              "amount"] ??
                                                                      "hello",
                                                                  style:
                                                                      TextStyle(
                                                                    fontSize:
                                                                        20,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500,
                                                                  ),
                                                                )),
                                                          ),
                                                        )
                                                      ],
                                                    ),
                                                    Row(
                                                      children: [
                                                        Align(
                                                          alignment:
                                                              Alignment.topLeft,
                                                          child: Title(
                                                              color:
                                                                  Colors.black,
                                                              child: Text(
                                                                entryData.data[
                                                                            index]
                                                                        [
                                                                        "classification"] ??
                                                                    "hello",
                                                                style:
                                                                    TextStyle(
                                                                  fontSize: 15,
                                                                ),
                                                              )),
                                                        ),
                                                        Expanded(
                                                          child: Align(
                                                            alignment: Alignment
                                                                .topRight,
                                                            child: Title(
                                                                color: Colors
                                                                    .green,
                                                                child: Text(
                                                                  entryData.data[
                                                                              index]
                                                                          [
                                                                          "mode"] ??
                                                                      "hello",
                                                                  style:
                                                                      TextStyle(
                                                                    color: Colors
                                                                        .grey,
                                                                  ),
                                                                )),
                                                          ),
                                                        )
                                                      ],
                                                    ),
                                                    entryData.data[index][
                                                                    "description"] ==
                                                                null ||
                                                            entryData.data[
                                                                        index][
                                                                    "description"] ==
                                                                ""
                                                        ? Text(
                                                            "None",
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .grey),
                                                          )
                                                        : Text(entryData
                                                                .data[index]
                                                            ["description"]),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          )
                                        : Container();
                                    // ListTile(
                                    //   title: Text("Date :" +
                                    //       (entryData.data[index]["date"] ?? "hello")),
                                    //   trailing: Text("Amount :" +
                                    //       (entryData.data[index]["amount"] ?? "hello")),
                                    // );
                                  }))
                        ],
                      );
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
            BottomNavigationBarItem(icon: Icon(Icons.payment), label: "Records")
          ],
        ));
  }
}
