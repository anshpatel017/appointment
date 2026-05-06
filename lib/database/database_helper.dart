import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'package:path/path.dart';
import 'package:flutter/foundation.dart';
import '../models/appointment.dart';
import '../models/user.dart';
import '../utils/constants.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    if (kIsWeb) {
      // Use the web factory for persistence
      var factory = databaseFactoryFfiWeb;
      databaseFactory = factory;
      final path = 'appointments_persistent.db';
      return await factory.openDatabase(path, options: OpenDatabaseOptions(
        version: 3,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
      ));
    } else if (defaultTargetPlatform == TargetPlatform.windows || 
               defaultTargetPlatform == TargetPlatform.linux || 
               defaultTargetPlatform == TargetPlatform.macOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'appointments.db');
    return await openDatabase(path, version: 3, onCreate: _onCreate, onUpgrade: _onUpgrade);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 3) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS users (
          id TEXT PRIMARY KEY,
          name TEXT NOT NULL,
          email TEXT NOT NULL UNIQUE,
          password TEXT NOT NULL,
          role TEXT NOT NULL
        )
      ''');
    }
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE appointments (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        service_type TEXT NOT NULL,
        date TEXT NOT NULL,
        time_slot TEXT NOT NULL,
        status TEXT NOT NULL DEFAULT 'Scheduled',
        queue_position INTEGER NOT NULL DEFAULT 0,
        created_at TEXT NOT NULL,
        is_synced INTEGER NOT NULL DEFAULT 0
      )
    ''');
    await db.execute('''
      CREATE TABLE users (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL,
        role TEXT NOT NULL
      )
    ''');
    await db.execute('CREATE INDEX idx_date ON appointments(date)');
    await db.execute('CREATE INDEX idx_status ON appointments(status)');
  }

  // ─── CREATE ─────────────────────────────────────────────
  Future<int> insertAppointment(Appointment appointment) async {
    final db = await database;
    return await db.insert('appointments', appointment.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // ─── AUTHENTICATION ─────────────────────────────────────
  Future<AppUser?> loginUser(String email, String password) async {
    final db = await database;
    final maps = await db.query('users',
        where: 'email = ? AND password = ?', whereArgs: [email, password]);
    if (maps.isEmpty) return null;
    return AppUser.fromMap(maps.first);
  }

  Future<int> registerUser(AppUser user) async {
    final db = await database;
    return await db.insert('users', user.toMap(),
        conflictAlgorithm: ConflictAlgorithm.abort);
  }

  // ─── CREATE ─────────────────────────────────────────────
  Future<List<Appointment>> getAllAppointments() async {
    final db = await database;
    final maps = await db.query('appointments', orderBy: 'date ASC, time_slot ASC');
    return maps.map((m) => Appointment.fromMap(m)).toList();
  }

  Future<Appointment?> getAppointmentById(String id) async {
    final db = await database;
    final maps = await db.query('appointments', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return Appointment.fromMap(maps.first);
  }

  Future<List<Appointment>> getAppointmentsByDate(String date) async {
    final db = await database;
    final maps = await db.query('appointments',
        where: 'date = ?', whereArgs: [date], orderBy: 'queue_position ASC');
    return maps.map((m) => Appointment.fromMap(m)).toList();
  }

  Future<int> getSlotBookingCount(String date, String timeSlot) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM appointments WHERE date = ? AND time_slot = ? AND status != ?',
      [date, timeSlot, AppointmentStatus.cancelled],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<bool> isSlotAvailable(String date, String timeSlot) async {
    final count = await getSlotBookingCount(date, timeSlot);
    return count < TimeSlots.maxAppointmentsPerSlot;
  }

  Future<int> getNextQueuePosition(String date) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT MAX(queue_position) as max_pos FROM appointments WHERE date = ? AND status != ?',
      [date, AppointmentStatus.cancelled],
    );
    final maxPos = result.first['max_pos'] as int?;
    return (maxPos ?? 0) + 1;
  }

  Future<List<Appointment>> getUnsyncedAppointments() async {
    final db = await database;
    final maps = await db.query('appointments', where: 'is_synced = ?', whereArgs: [0]);
    return maps.map((m) => Appointment.fromMap(m)).toList();
  }

  Future<int> getUnsyncedCount() async {
    final db = await database;
    final r = await db.rawQuery('SELECT COUNT(*) as c FROM appointments WHERE is_synced = 0');
    return Sqflite.firstIntValue(r) ?? 0;
  }

  Future<List<Appointment>> searchAppointments(String query) async {
    final db = await database;
    final maps = await db.query('appointments',
        where: 'name LIKE ? OR id LIKE ?',
        whereArgs: ['%$query%', '%$query%'],
        orderBy: 'date DESC');
    return maps.map((m) => Appointment.fromMap(m)).toList();
  }

  Future<List<Appointment>> getFilteredAppointments({
    String? date, String? status, String? serviceType, String? searchQuery,
  }) async {
    final db = await database;
    final conds = <String>[];
    final args = <dynamic>[];
    if (date != null && date.isNotEmpty) { conds.add('date = ?'); args.add(date); }
    if (status != null && status.isNotEmpty) { conds.add('status = ?'); args.add(status); }
    if (serviceType != null && serviceType.isNotEmpty) { conds.add('service_type = ?'); args.add(serviceType); }
    if (searchQuery != null && searchQuery.isNotEmpty) {
      conds.add('(name LIKE ? OR id LIKE ?)');
      args.addAll(['%$searchQuery%', '%$searchQuery%']);
    }
    final where = conds.isNotEmpty ? conds.join(' AND ') : null;
    final maps = await db.query('appointments',
        where: where, whereArgs: args.isNotEmpty ? args : null);
    
    final appointments = maps.map((m) => Appointment.fromMap(m)).toList();
    
    // Sort by time slot index to ensure chronological order
    appointments.sort((a, b) {
      int idxA = TimeSlots.all.indexOf(a.timeSlot);
      int idxB = TimeSlots.all.indexOf(b.timeSlot);
      return idxA.compareTo(idxB);
    });
    
    return appointments;
  }

  Future<Map<String, int>> getStatusCounts() async {
    final db = await database;
    final result = await db.rawQuery(
        'SELECT status, COUNT(*) as count FROM appointments GROUP BY status');
    return {for (var r in result) r['status'] as String: r['count'] as int};
  }

  Future<List<Appointment>> getTodayQueue() async {
    final today = DateTime.now().toIso8601String().substring(0, 10);
    final db = await database;
    final maps = await db.query('appointments',
        where: 'date = ? AND status != ?',
        whereArgs: [today, AppointmentStatus.cancelled]);
        
    final appointments = maps.map((m) => Appointment.fromMap(m)).toList();
    
    // Sort by time slot index to ensure chronological order
    appointments.sort((a, b) {
      int idxA = TimeSlots.all.indexOf(a.timeSlot);
      int idxB = TimeSlots.all.indexOf(b.timeSlot);
      return idxA.compareTo(idxB);
    });
    
    return appointments;
  }

  // ─── UPDATE ─────────────────────────────────────────────
  Future<int> updateAppointment(Appointment appointment) async {
    final db = await database;
    return await db.update('appointments', appointment.toMap(),
        where: 'id = ?', whereArgs: [appointment.id]);
  }

  Future<int> updateStatus(String id, String status) async {
    final db = await database;
    return await db.update('appointments', {'status': status, 'is_synced': 0},
        where: 'id = ?', whereArgs: [id]);
  }

  Future<int> markAsSynced(String id) async {
    final db = await database;
    return await db.update('appointments', {'is_synced': 1},
        where: 'id = ?', whereArgs: [id]);
  }

  Future<int> markAllAsSynced() async {
    final db = await database;
    return await db.update('appointments', {'is_synced': 1},
        where: 'is_synced = ?', whereArgs: [0]);
  }

  // ─── DELETE ─────────────────────────────────────────────
  Future<int> deleteAppointment(String id) async {
    final db = await database;
    return await db.delete('appointments', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }
}
