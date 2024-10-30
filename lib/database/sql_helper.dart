import 'package:sqflite/sqflite.dart' as sql;

class SQLHelper {
  static Future<void> createTables(sql.Database database) async {
    // Create employee table
    await database.execute("""
      CREATE TABLE employee(
        id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, 
        name TEXT,
        email TEXT
      )
    """);

    await database.execute("""
      CREATE TABLE vehicle(
        id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, 
        name TEXT,
        licensePlate TEXT
      )
    """);
  }

  static Future<sql.Database> db() async {
    return sql.openDatabase(
      'database.db', 
      version: 1,
      onCreate: (sql.Database database, int version) async {
        await createTables(database);
      },
    );
  }

  // Employee operations
  static Future<int> addEmployee(String name, String email) async {
    final db = await SQLHelper.db();
    final data = {'name': name, 'email': email};
    return await db.insert('employee', data);
  }

  static Future<List<Map<String, dynamic>>> getEmployee() async {
    final db = await SQLHelper.db();
    return db.query('employee');
  }

  static Future<int> editEmployee(int id, String name, String email) async {
    final db = await SQLHelper.db();
    final data = {'name': name, 'email': email};
    return await db.update('employee', data, where: "id = ?", whereArgs: [id]);
  }

  static Future<int> deleteEmployee(int id) async {
    final db = await SQLHelper.db();
    return await db.delete('employee', where: "id = ?", whereArgs: [id]);
  }

  // Vehicle operations
  static Future<int> addVehicle(String name, String licensePlate) async {
    final db = await SQLHelper.db();
    final data = {'name': name, 'licensePlate': licensePlate};
    return await db.insert('vehicle', data);
  }

  static Future<List<Map<String, dynamic>>> getVehicle() async {
    final db = await SQLHelper.db();
    return db.query('vehicle');
  }

  static Future<int> editVehicle(int id, String name, String licensePlate) async {
    final db = await SQLHelper.db();
    final data = {'name': name, 'licensePlate': licensePlate};
    return await db.update('vehicle', data, where: "id = ?", whereArgs: [id]);
  }

  static Future<int> deleteVehicle(int id) async {
    final db = await SQLHelper.db();
    return await db.delete('vehicle', where: "id = ?", whereArgs: [id]);
  }
}
