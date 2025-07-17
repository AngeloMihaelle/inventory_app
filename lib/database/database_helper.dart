// database/database_helper.dart
import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/item.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  DatabaseHelper._internal();

  factory DatabaseHelper() => _instance;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'inventory.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE items(
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        quantity INTEGER NOT NULL,
        characteristics TEXT NOT NULL
      )
    ''');
  }

  Future<int> insertItem(Item item) async {
    final db = await database;
    return await db.insert('items', item.toMap());
  }

  Future<List<Item>> getAllItems() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('items');
    return List.generate(maps.length, (i) => Item.fromMap(maps[i]));
  }

  Future<int> updateItem(Item item) async {
    final db = await database;
    return await db.update(
      'items',
      item.toMap(),
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }

  Future<int> deleteItem(String id) async {
    final db = await database;
    return await db.delete(
      'items',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Item>> searchItems(String query) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'items',
      where: 'name LIKE ? OR characteristics LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
    );
    return List.generate(maps.length, (i) => Item.fromMap(maps[i]));
  }
}