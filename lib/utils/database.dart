import 'package:expense_diary_arsenel/models/unit_entry.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite/sqlite_api.dart';
import 'package:path/path.dart';

class DBProvider {
  DBProvider._();
  static final DBProvider db = DBProvider._();
  static Database _database;

  Future<Database> get database async {
    if (_database != null) return _database;

    _database = await initDB();
    return _database;
  }

  initDB() async {
    return await openDatabase(
        join(await getDatabasesPath(), 'arsenel_expense.db'),
        onCreate: (db, version) async {
      await db.execute('''
          CREATE TABLE unit_entry(
            id INTEGER PRIMARY KEY,
            date text not null,
            amount text not null,
            classification text not null,
            mode text not null,
            description text
          );
          ''');
      await db.execute('''
          CREATE TABLE day(
            date text PRIMARY KEY,
            total int default 0
          );
          ''');
      await db.execute('''
          CREATE TABLE month(
            monthYear text PRIMARY KEY,
            total int default 0
          );
          ''');
      await db.execute('''
          CREATE TABLE year(
            year text PRIMARY KEY,
            total int default 0
          );
          ''');
    }, version: 1);
  }

  newEntry(Entry newEntry) async {
    //add entry
    //print("async" + newEntry.date);
    final db = await database;
    var res = await db.rawInsert('''
    INSERT INTO unit_entry(date,amount,classification,mode,description)
    VALUES (?,?,?,?,?)
    ''', [
      newEntry.date,
      newEntry.amount,
      newEntry.classification,
      newEntry.mode,
      newEntry.description
    ]);
    String date = newEntry.date;
    String _grab = date;
    var listo = _grab.split("-");
    String month_year = listo[1] + listo[0];
    String year = listo[0];
    print(month_year);
    print(year);
    int amount = int.parse(newEntry.amount);
    //day table entry
    var val = await db.rawQuery(
      '''
    SELECT * from day
    WHERE date='$date';
    ''',
    );
    if (val.length == 0) {
      await db.execute('''
      INSERT INTO day(date,total)
      VALUES (?,?);
      ''', [
        newEntry.date,
        amount,
      ]);
    } else if (val.length == 1) {
      await db.execute('''
      UPDATE day SET total=total+$amount 
      WHERE date='$date';
      ''');
    }
    print(val);
    //month table entry
    val = await db.rawQuery(
      '''
    SELECT * from month
    WHERE monthYear='$month_year';
    ''',
    );
    print(val);
    if (val.length == 0) {
      await db.execute('''
      INSERT INTO month(monthYear,total)
      VALUES (?,?);
      ''', [
        month_year,
        amount,
      ]);
    } else if (val.length == 1) {
      await db.execute('''
      UPDATE month SET total=total+$amount 
      WHERE monthYear='$month_year';
      ''');
    }
    //year table entry
    val = await db.rawQuery(
      '''
    SELECT * from year
    WHERE year='$year';
    ''',
    );
    print(val);
    if (val.length == 0) {
      await db.execute('''
      INSERT INTO year(year,total)
      VALUES (?,?);
      ''', [
        year,
        amount,
      ]);
    } else if (val.length == 1) {
      await db.execute('''
      UPDATE year SET total=total+$amount 
      WHERE year='$year';
      ''');
    }

    //response
    return res;
  }

  Future<dynamic> getEntry() async {
    //get entries
    final db = await database;
    var res = await db.rawQuery("SELECT * from unit_entry ORDER BY id desc;");
    if (res.length == 0) {
      return null;
    } else {
      var resMap = res;
      //print(resMap.toString());
      return resMap.isNotEmpty ? resMap : Null; //returns just first
    }
  }

  Future<dynamic> getDayExpenses(String date) async {
    //gets day expenses
    var return_list = {};
    String _grab = date;
    var listo = _grab.split("-");
    String month_year = listo[1] + listo[0];
    String year = listo[0];
    final db = await database;
    //from day table
    var val = await db.rawQuery(
      '''
    SELECT * from day
    WHERE date='$date';
    ''',
    );
    if (val.length == 0) {
      return_list['day'] = "0.00";
    } else {
      return_list['day'] = val[0]['total'].toString();
    }
    //from month table
    val = await db.rawQuery(
      '''
    SELECT * from month
    WHERE monthYear='$month_year';
    ''',
    );
    if (val.length == 0) {
      return_list['month'] = "0.00";
    } else {
      return_list['month'] = val[0]['total'].toString();
    }
    //from year table
    val = await db.rawQuery(
      '''
    SELECT * from year
    WHERE year='$year';
    ''',
    );
    if (val.length == 0) {
      return_list['year'] = "0.00";
    } else {
      return_list['year'] = val[0]['total'].toString();
    }

    print(return_list);
    return return_list;
  }

  Future<dynamic> getDayList(String date) async {
    final db = await database;
    var val = await db.rawQuery(
      '''
    SELECT * from unit_entry
    WHERE date='$date';
    ''',
    );
    if (val.length == 0) {
      return null;
    } else {
      print(val);
      return val;
    }
  }

  Future<dynamic> deleteEntry(int id, String amount, String classification,
      String mode, String date) async {
    final db = await database;
    String _grab = date;
    var listo = _grab.split("-");
    String month_year = listo[1] + listo[0];
    String year = listo[0];
    var fin = await db.rawDelete('''
    DELETE FROM unit_entry WHERE id=$id;
    ''');
    //remove amount from day expenses
    await db.execute('''
      UPDATE day SET total=total-$amount 
      WHERE date='$date';
      ''');
    //remove amount from month expenses
    await db.execute('''
      UPDATE month SET total=total-$amount 
      WHERE monthYear='$month_year';
      ''');
    //remove amount from year expenses
    await db.execute('''
      UPDATE year SET total=total-$amount 
      WHERE year='$year';
      ''');

    //final
    return fin;
  }

  Future<dynamic> getmonthlist(String month) async {
    print(month + "in await");
    month = month + "___";
    final db = await database;
    var val = await db.rawQuery(
      '''
    SELECT * from unit_entry
    WHERE date LIKE '$month' ORDER BY date desc;
    ''',
    );
    if (val.length == 0) {
      return null;
    } else {
      print(val);
      return val;
    }
  }

  Future<dynamic> getyearlist(String year) async {
    print(year + "in await");
    year = year + "_____";
    final db = await database;
    var val = await db.rawQuery(
      '''
    SELECT * from unit_entry
    WHERE date LIKE '$year';
    ''',
    );
    if (val.length == 0) {
      return null;
    } else {
      print(val);
      return val;
    }
  }

  Future<dynamic> getYearGraph(String year) async {
    print(year + "in await");

    final db = await database;
    var val = await db.rawQuery(
      '''
    SELECT * from month
    WHERE monthyear LIKE '__$year';
    ''',
    );
    if (val.length == 0) {
      return null;
    } else {
      print(val);
      return val;
    }
  }

  Future<dynamic> getCashOnline(String year) async {
    print(year + "in await");

    final db = await database;
    var val = await db.rawQuery(
      '''
    SELECT SUM(amount) from unit_entry
    WHERE date LIKE '$year%' and mode='CashPayment';
    ''',
    );
    if (val.length == 0) {
      return null;
    } else {
      print(val);
      return val;
    }
  }

  Future<dynamic> getMonthGraph(String year, String month) async {
    String searchterm = year + "-" + month;

    final db = await database;
    var val = await db.rawQuery(
      '''
    SELECT date,SUM(amount) from unit_entry
    WHERE date LIKE '$searchterm%' GROUP By date;
    ''',
    );
    if (val.length == 0) {
      return null;
    } else {
      print(val);
      return val;
    }
  }

  Future<dynamic> getCashOnlineMonth(String year, String month) async {
    String searchterm = year + "-" + month;

    final db = await database;
    var val = await db.rawQuery(
      '''
    SELECT SUM(amount) from unit_entry
    WHERE date LIKE '$searchterm%' and mode='CashPayment';
    ''',
    );
    if (val.length == 0) {
      return null;
    } else {
      print(val);
      return val;
    }
  }

  Future<dynamic> getPieDay(String date) async {
    final db = await database;
    var val = await db.rawQuery(
      '''
    SELECT classification,SUM(amount) from unit_entry
    WHERE date ='$date' GROUP by classification;
    ''',
    );
    if (val.length == 0) {
      return null;
    } else {
      print(val);
      return val;
    }
  }

  Future<dynamic> getCashOnlineDay(String date) async {
    final db = await database;
    var val = await db.rawQuery(
      '''
    SELECT SUM(amount) from unit_entry
    WHERE date = '$date' and mode='CashPayment';
    ''',
    );
    if (val.length == 0) {
      return null;
    } else {
      print(val);
      return val;
    }
  }

  Future<dynamic> getClassificationMonth(String year, String month) async {
    String searchterm = year + "-" + month;
    final db = await database;
    var val = await db.rawQuery(
      '''
    SELECT classification,SUM(amount) from unit_entry
    WHERE date LIKE '$searchterm%' GROUP by classification;
    ''',
    );
    if (val.length == 0) {
      return null;
    } else {
      print(val);
      return val;
    }
  }

  Future<dynamic> getClassificationYear(String year) async {
    final db = await database;
    var val = await db.rawQuery(
      '''
    SELECT classification,SUM(amount) from unit_entry
    WHERE date LIKE '$year%' GROUP BY classification;
    ''',
    );
    if (val.length == 0) {
      return null;
    } else {
      print(val);
      return val;
    }
  }
}
