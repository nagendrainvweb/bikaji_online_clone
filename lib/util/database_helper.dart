
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite/sqlite_api.dart';

class DatabaseHelper {

    static final _databaseName = "BikajiDatabase.db";
    static final _databaseVersion = 4;

    static final table = "cart_table";
    static final wishlist_table = "wishList";
    
    static final columnId = "_id";
    static final columnProductId = 'product_id';
    static final columnName  = 'name';
    static final columnImage = 'image';
    static final columnPrice = 'price';
    static final columnAcutalPrice = 'actual_price';
    static final columnSize = 'size';
    static final columnQty = 'qty';
    static final columnOffer = 'offer';
    static final columnCreatedOn = 'createdOn';
    

    // Singleton class
    DatabaseHelper._privateConstructor();
    
    static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

    // refrence to database
    static Database _database;
    Future<Database> get database async{

      if (_database != null) return _database;
      // lazily instantiate the db the first time it is accessed
      _database = await _initDatabase();
      return _database;
    }

    // this opens the database (and creates it if it doesn't exist)
    _initDatabase() async {
      Directory documentDirectory = await getApplicationDocumentsDirectory();
      String path = join(documentDirectory.path,_databaseName);

      return await openDatabase(path,
      version: _databaseVersion,
      onCreate: _onCreate);
    }

    // SQL code to create the database table
    Future _onCreate(Database db, int version) async{

      await db.execute('''
          CREATE TABLE $table (
            $columnId INTEGER PRIMARY KEY,
            $columnProductId TEXT,
            $columnName TEXT NOT NULL,
            $columnImage TEXT,
            $columnPrice TEXT,
            $columnAcutalPrice TEXT,
            $columnSize TEXT,
            $columnQty TEXT,
            $columnOffer TEXT
          )
          ''');

          await db.execute('''
          CREATE TABLE $wishlist_table (
            $columnId INTEGER PRIMARY KEY,
            $columnProductId TEXT,
            $columnName TEXT NOT NULL,
            $columnImage TEXT,
            $columnPrice TEXT,
            $columnAcutalPrice TEXT,
            $columnSize TEXT,
            $columnQty TEXT,
            $columnOffer TEXT
          )
          ''');
    }

    // Helper methods

    // Inserts a row in the database where each key in the Map is a column name
    // and the value is the column value. The return value is the id of the
    // inserted row.

    Future<int> insert(Map<String,dynamic> row,var table) async{
      Database db = await instance.database;
      return await db.insert(table, row);
    }

    // All of the rows are returned as a list of maps, where each map is 
  // a key-value list of columns.

  Future<List<Map<String,dynamic>>> queryAllRow(var table) async{
    Database db= await instance.database;
    return await db.query(table);
  }

   // All of the methods (insert, query, update, delete) can also be done using
  // raw SQL commands. This method uses a raw query to give the row count.
  Future<int> queryConvertWishlistToCart(Map<String,dynamic> data) async{
    var id  = data[columnId];
    //data.remove(columnId);
    var value  = await insert(data, table);
    delete(id, wishlist_table);
    return value;

  }

  // All of the methods (insert, query, update, delete) can also be done using
  // raw SQL commands. This method uses a raw query to give the row count.
  Future<int> queryRowCount(var table) async {
    Database db = await instance.database;
    return Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM $table'));
  }

  // We are assuming here that the id column in the map is set. The other 
  // column values will be used to update the row.
  Future<int> update(Map<String, dynamic> row,var table) async {
    Database db = await instance.database;
    int id = row[columnId];
    return await db.update(table, row, where: '$columnId = ?', whereArgs: [id]);
  }

   // Deletes the row specified by the id. The number of affected rows is 
  // returned. This should be 1 as long as the row exists.
  Future<int> delete(int id,var table) async {
    Database db = await instance.database;
    return await db.delete(table, where: '$columnId = ?', whereArgs: [id]);
  }

  }