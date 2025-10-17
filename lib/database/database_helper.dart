import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static const _databaseName = "fish_industry.db";
  static const _databaseVersion = 6;

  static const tableCamionDecharge = 'camion_decharge';
  static const tableAgraigeQualite = 'agraige_qualite_tests';
  static const tableAgraigeMoul = 'agraige_moul_tests';
  static const tableBateau = 'bateau';
  static const tableFournisseur = 'fournisseur';
  static const tableUsine = 'usine';

  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  _initDatabase() async {
    String path = join(await getDatabasesPath(), _databaseName);
    return await openDatabase(path,
        version: _databaseVersion, onCreate: _onCreate, onUpgrade: _onUpgrade);
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
          CREATE TABLE $tableCamionDecharge (
            id_decharge INTEGER PRIMARY KEY AUTOINCREMENT,
            mat_camion TEXT NOT NULL,
            bateau TEXT,
            fournisseur TEXT,
            usine TEXT,
            maree TEXT,
            heure_decharge TEXT,
            heure_traitement TEXT,
            temperature REAL,
            pois_decharge REAL,
            poids_unitaire_carton INTEGER,
            nbr_agraige_qualite INTEGER,
            nbr_agraige_moule INTEGER,
            is_exported INTEGER DEFAULT 0,
            date_creation TEXT NOT NULL,
            date_modification TEXT NOT NULL,
            is_synced INTEGER DEFAULT 0,
            server_id INTEGER
          )
          ''');

    await db.execute('''
          CREATE TABLE $tableAgraigeQualite (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            agraige_a INTEGER,
            agraige_b INTEGER,
            agraige_c INTEGER,
            agraige_maq INTEGER,
            agraige_chin INTEGER,
            agraige_fp INTEGER,
            agraige_g INTEGER,
            agraige_anchois INTEGER,
            petit_caliber INTEGER,
            id_camion_decharge INTEGER NOT NULL,
            date_creation TEXT NOT NULL,
            date_modification TEXT NOT NULL,
            is_synced INTEGER DEFAULT 0,
            server_id INTEGER,
            FOREIGN KEY (id_camion_decharge) REFERENCES $tableCamionDecharge (id_decharge)
          )
          ''');

    await db.execute('''
          CREATE TABLE $tableAgraigeMoul (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            moul_6_8 INTEGER,
            moul_8_10 INTEGER,
            moul_10_12 INTEGER,
            moul_12_16 INTEGER,
            moul_16_20 INTEGER,
            moul_20_26 INTEGER,
            moul_gt_30 INTEGER,
            id_camion_decharge INTEGER NOT NULL,
            date_creation TEXT NOT NULL,
            date_modification TEXT NOT NULL,
            is_synced INTEGER DEFAULT 0,
            server_id INTEGER,
            FOREIGN KEY (id_camion_decharge) REFERENCES $tableCamionDecharge (id_decharge)
          )
          ''');

    await db.execute('''
          CREATE TABLE $tableBateau (
            id_bateau INTEGER PRIMARY KEY AUTOINCREMENT,
            nom_bateau TEXT NOT NULL UNIQUE,
            description TEXT,
            date_creation TEXT NOT NULL,
            date_modification TEXT NOT NULL,
            is_synced INTEGER DEFAULT 0,
            server_id INTEGER
          )
          ''');

    await db.execute('''
          CREATE TABLE $tableFournisseur (
            id_fournisseur INTEGER PRIMARY KEY AUTOINCREMENT,
            nom_fournisseur TEXT NOT NULL UNIQUE,
            telephone TEXT,
            adresse TEXT,
            email TEXT,
            description TEXT,
            date_creation TEXT NOT NULL,
            date_modification TEXT NOT NULL,
            is_synced INTEGER DEFAULT 0,
            server_id INTEGER
          )
          ''');

    await db.execute('''
          CREATE TABLE $tableUsine (
            id_usine INTEGER PRIMARY KEY AUTOINCREMENT,
            nom_usine TEXT NOT NULL UNIQUE,
            adresse TEXT,
            description TEXT,
            date_creation TEXT NOT NULL,
            date_modification TEXT NOT NULL,
            is_synced INTEGER DEFAULT 0,
            server_id INTEGER
          )
          ''');
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE $tableCamionDecharge ADD COLUMN pois_decharge REAL');
    }
    if (oldVersion < 3) {
      await db.execute('''
          CREATE TABLE $tableBateau (
            id_bateau INTEGER PRIMARY KEY AUTOINCREMENT,
            nom_bateau TEXT NOT NULL UNIQUE,
            description TEXT,
            date_creation TEXT NOT NULL,
            date_modification TEXT NOT NULL,
            is_synced INTEGER DEFAULT 0,
            server_id INTEGER
          )
          ''');
    }
    if (oldVersion < 4) {
      await db.execute('ALTER TABLE $tableCamionDecharge ADD COLUMN fournisseur TEXT');
      await db.execute('''
          CREATE TABLE $tableFournisseur (
            id_fournisseur INTEGER PRIMARY KEY AUTOINCREMENT,
            nom_fournisseur TEXT NOT NULL UNIQUE,
            telephone TEXT,
            adresse TEXT,
            email TEXT,
            description TEXT,
            date_creation TEXT NOT NULL,
            date_modification TEXT NOT NULL,
            is_synced INTEGER DEFAULT 0,
            server_id INTEGER
          )
          ''');
    }
    if (oldVersion < 5) {
      await db.execute('ALTER TABLE $tableCamionDecharge ADD COLUMN usine TEXT');
      await db.execute('''
          CREATE TABLE $tableUsine (
            id_usine INTEGER PRIMARY KEY AUTOINCREMENT,
            nom_usine TEXT NOT NULL UNIQUE,
            adresse TEXT,
            description TEXT,
            date_creation TEXT NOT NULL,
            date_modification TEXT NOT NULL,
            is_synced INTEGER DEFAULT 0,
            server_id INTEGER
          )
          ''');
    }
    if (oldVersion < 6) {
      await db.execute('ALTER TABLE $tableCamionDecharge ADD COLUMN poids_unitaire_carton INTEGER');
    }
  }

  Future<int> insert(String table, Map<String, dynamic> row) async {
    Database db = await instance.database;
    return await db.insert(table, row);
  }

  Future<List<Map<String, dynamic>>> queryAll(String table) async {
    Database db = await instance.database;
    return await db.query(table);
  }

  Future<List<Map<String, dynamic>>> queryWhere(String table, String where, List<dynamic> whereArgs) async {
    Database db = await instance.database;
    return await db.query(table, where: where, whereArgs: whereArgs);
  }

  Future<Map<String, dynamic>?> queryById(String table, int id) async {
    Database db = await instance.database;
    List<Map<String, dynamic>> result = await db.query(
      table,
      where: 'id = ? OR id_decharge = ? OR id_bateau = ? OR id_fournisseur = ? OR id_usine = ?',
      whereArgs: [id, id, id, id, id],
    );
    return result.isNotEmpty ? result.first : null;
  }

  Future<int> update(String table, Map<String, dynamic> row, int id) async {
    Database db = await instance.database;
    String idColumn = table == tableCamionDecharge
        ? 'id_decharge'
        : table == tableBateau
            ? 'id_bateau'
            : table == tableFournisseur
                ? 'id_fournisseur'
                : table == tableUsine
                    ? 'id_usine'
                    : 'id';
    return await db.update(table, row, where: '$idColumn = ?', whereArgs: [id]);
  }

  Future<int> delete(String table, int id) async {
    Database db = await instance.database;
    String idColumn = table == tableCamionDecharge
        ? 'id_decharge'
        : table == tableBateau
            ? 'id_bateau'
            : table == tableFournisseur
                ? 'id_fournisseur'
                : table == tableUsine
                    ? 'id_usine'
                    : 'id';
    return await db.delete(table, where: '$idColumn = ?', whereArgs: [id]);
  }

  Future<List<Map<String, dynamic>>> getUnsyncedRecords(String table) async {
    Database db = await instance.database;
    return await db.query(table, where: 'is_synced = ?', whereArgs: [0]);
  }

  Future<int> markAsSynced(String table, int localId, int serverId) async {
    Database db = await instance.database;
    String idColumn = table == tableCamionDecharge
        ? 'id_decharge'
        : table == tableBateau
            ? 'id_bateau'
            : table == tableFournisseur
                ? 'id_fournisseur'
                : table == tableUsine
                    ? 'id_usine'
                    : 'id';
    return await db.update(
      table,
      {'is_synced': 1, 'server_id': serverId},
      where: '$idColumn = ?',
      whereArgs: [localId]
    );
  }

  Future<List<Map<String, dynamic>>> getTestsByDechargeId(String table, int dechargeId) async {
    Database db = await instance.database;
    return await db.query(
      table,
      where: 'id_camion_decharge = ?',
      whereArgs: [dechargeId],
    );
  }

  Future<void> deleteDatabase() async {
    String path = join(await getDatabasesPath(), _databaseName);
    await databaseFactory.deleteDatabase(path);
    _database = null;
  }
}