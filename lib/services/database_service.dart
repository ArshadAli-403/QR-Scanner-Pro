// lib/services/database_service.dart
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/qr_scan_model.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  static Database? _database;

  static const String _dbName = 'qr_scanner_pro.db';
  static const int _dbVersion = 1;
  static const String _tableName = 'qr_history';

  // Column names
  static const String colId = 'id';
  static const String colQrText = 'qrText';
  static const String colScanDate = 'scanDate';

  /// Get or initialize the database
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  /// Initialize the SQLite database
  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);

    return await openDatabase(
      path,
      version: _dbVersion,
      onCreate: _createTable,
      onUpgrade: _onUpgrade,
    );
  }

  /// Create the qr_history table
  Future<void> _createTable(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $_tableName (
        $colId INTEGER PRIMARY KEY AUTOINCREMENT,
        $colQrText TEXT NOT NULL,
        $colScanDate TEXT NOT NULL
      )
    ''');
  }

  /// Handle database upgrades
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < newVersion) {
      // Future migration logic here
    }
  }

  /// Insert a new QR scan record
  Future<int> insertScan(QrScanModel scan) async {
    final db = await database;
    return await db.insert(
      _tableName,
      scan.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Get all QR scan records (newest first)
  Future<List<QrScanModel>> getAllScans() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      _tableName,
      orderBy: '$colId DESC',
    );
    return maps.map((map) => QrScanModel.fromMap(map)).toList();
  }

  /// Search scans by text
  Future<List<QrScanModel>> searchScans(String query) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      _tableName,
      where: '$colQrText LIKE ?',
      whereArgs: ['%$query%'],
      orderBy: '$colId DESC',
    );
    return maps.map((map) => QrScanModel.fromMap(map)).toList();
  }

  /// Check if a QR text already exists (for duplicate prevention)
  Future<bool> scanExists(String qrText) async {
    final db = await database;
    final result = await db.query(
      _tableName,
      where: '$colQrText = ?',
      whereArgs: [qrText],
      limit: 1,
    );
    return result.isNotEmpty;
  }

  /// Delete a single scan by ID
  Future<int> deleteScan(int id) async {
    final db = await database;
    return await db.delete(
      _tableName,
      where: '$colId = ?',
      whereArgs: [id],
    );
  }

  /// Delete all scan records
  Future<int> deleteAllScans() async {
    final db = await database;
    return await db.delete(_tableName);
  }

  /// Get total scan count
  Future<int> getScanCount() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) FROM $_tableName');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  /// Close the database connection
  Future<void> closeDatabase() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}
