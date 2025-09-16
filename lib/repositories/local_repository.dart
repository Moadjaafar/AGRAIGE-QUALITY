import '../database/database_helper.dart';
import '../models/camion_decharge.dart';
import '../models/agraige_qualite_tests.dart';
import '../models/agraige_moul_tests.dart';

class LocalRepository {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;

  Future<int> insertCamionDecharge(CamionDecharge camion) async {
    return await _databaseHelper.insert(
      DatabaseHelper.tableCamionDecharge,
      camion.toDatabase(),
    );
  }

  Future<List<CamionDecharge>> getAllCamionDecharges() async {
    final maps = await _databaseHelper.queryAll(DatabaseHelper.tableCamionDecharge);
    return maps.map((map) => CamionDecharge.fromDatabase(map)).toList();
  }

  Future<CamionDecharge?> getCamionDechargeById(int id) async {
    final map = await _databaseHelper.queryById(DatabaseHelper.tableCamionDecharge, id);
    return map != null ? CamionDecharge.fromDatabase(map) : null;
  }

  Future<int> updateCamionDecharge(int id, CamionDecharge camion) async {
    final updatedCamion = camion.copyWith(
      dateModification: DateTime.now(),
    );
    return await _databaseHelper.update(
      DatabaseHelper.tableCamionDecharge,
      updatedCamion.toDatabase(),
      id,
    );
  }

  Future<int> deleteCamionDecharge(int id) async {
    await deleteQualiteTestsByDechargeId(id);
    await deleteMoulTestsByDechargeId(id);
    return await _databaseHelper.delete(DatabaseHelper.tableCamionDecharge, id);
  }

  Future<List<CamionDecharge>> getUnsyncedCamionDecharges() async {
    final maps = await _databaseHelper.getUnsyncedRecords(DatabaseHelper.tableCamionDecharge);
    return maps.map((map) => CamionDecharge.fromDatabase(map)).toList();
  }

  Future<int> markCamionDechargeAsSynced(int localId, int serverId) async {
    return await _databaseHelper.markAsSynced(
      DatabaseHelper.tableCamionDecharge,
      localId,
      serverId,
    );
  }

  Future<int> insertQualiteTest(AgraigeQualiteTests test) async {
    final result = await _databaseHelper.insert(
      DatabaseHelper.tableAgraigeQualite,
      test.toDatabase(),
    );
    // Update the count in camion_decharge
    await _updateCamionTestCounts(test.idCamionDecharge);
    return result;
  }

  Future<List<AgraigeQualiteTests>> getAllQualiteTests() async {
    final maps = await _databaseHelper.queryAll(DatabaseHelper.tableAgraigeQualite);
    return maps.map((map) => AgraigeQualiteTests.fromDatabase(map)).toList();
  }

  Future<List<AgraigeQualiteTests>> getQualiteTestsByDechargeId(int dechargeId) async {
    final maps = await _databaseHelper.getTestsByDechargeId(
      DatabaseHelper.tableAgraigeQualite,
      dechargeId,
    );
    return maps.map((map) => AgraigeQualiteTests.fromDatabase(map)).toList();
  }

  Future<AgraigeQualiteTests?> getQualiteTestById(int id) async {
    final map = await _databaseHelper.queryById(DatabaseHelper.tableAgraigeQualite, id);
    return map != null ? AgraigeQualiteTests.fromDatabase(map) : null;
  }

  Future<int> updateQualiteTest(int id, AgraigeQualiteTests test) async {
    final updatedTest = test.copyWith(
      dateModification: DateTime.now(),
    );
    final result = await _databaseHelper.update(
      DatabaseHelper.tableAgraigeQualite,
      updatedTest.toDatabase(),
      id,
    );
    // Update the count in camion_decharge
    await _updateCamionTestCounts(test.idCamionDecharge);
    return result;
  }

  Future<int> deleteQualiteTest(int id) async {
    // Get the camion ID before deleting
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> results = await db.query(
      DatabaseHelper.tableAgraigeQualite,
      columns: ['id_camion_decharge'],
      where: 'id = ?',
      whereArgs: [id],
    );

    int? camionId;
    if (results.isNotEmpty) {
      camionId = results.first['id_camion_decharge'];
    }

    final result = await _databaseHelper.delete(DatabaseHelper.tableAgraigeQualite, id);

    // Update the count if we found a camion ID
    if (camionId != null) {
      await _updateCamionTestCounts(camionId);
    }

    return result;
  }

  Future<int> deleteQualiteTestsByDechargeId(int dechargeId) async {
    final db = await _databaseHelper.database;
    return await db.delete(
      DatabaseHelper.tableAgraigeQualite,
      where: 'id_camion_decharge = ?',
      whereArgs: [dechargeId],
    );
  }

  Future<List<AgraigeQualiteTests>> getUnsyncedQualiteTests() async {
    final maps = await _databaseHelper.getUnsyncedRecords(DatabaseHelper.tableAgraigeQualite);
    return maps.map((map) => AgraigeQualiteTests.fromDatabase(map)).toList();
  }

  Future<int> markQualiteTestAsSynced(int localId, int serverId) async {
    return await _databaseHelper.markAsSynced(
      DatabaseHelper.tableAgraigeQualite,
      localId,
      serverId,
    );
  }

  Future<int> insertMoulTest(AgraigeMoulTests test) async {
    final result = await _databaseHelper.insert(
      DatabaseHelper.tableAgraigeMoul,
      test.toDatabase(),
    );
    // Update the count in camion_decharge
    await _updateCamionTestCounts(test.idCamionDecharge);
    return result;
  }

  Future<List<AgraigeMoulTests>> getAllMoulTests() async {
    final maps = await _databaseHelper.queryAll(DatabaseHelper.tableAgraigeMoul);
    return maps.map((map) => AgraigeMoulTests.fromDatabase(map)).toList();
  }

  Future<List<AgraigeMoulTests>> getMoulTestsByDechargeId(int dechargeId) async {
    final maps = await _databaseHelper.getTestsByDechargeId(
      DatabaseHelper.tableAgraigeMoul,
      dechargeId,
    );
    return maps.map((map) => AgraigeMoulTests.fromDatabase(map)).toList();
  }

  Future<AgraigeMoulTests?> getMoulTestById(int id) async {
    final map = await _databaseHelper.queryById(DatabaseHelper.tableAgraigeMoul, id);
    return map != null ? AgraigeMoulTests.fromDatabase(map) : null;
  }

  Future<int> updateMoulTest(int id, AgraigeMoulTests test) async {
    final updatedTest = test.copyWith(
      dateModification: DateTime.now(),
    );
    final result = await _databaseHelper.update(
      DatabaseHelper.tableAgraigeMoul,
      updatedTest.toDatabase(),
      id,
    );
    // Update the count in camion_decharge
    await _updateCamionTestCounts(test.idCamionDecharge);
    return result;
  }

  Future<int> deleteMoulTest(int id) async {
    // Get the camion ID before deleting
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> results = await db.query(
      DatabaseHelper.tableAgraigeMoul,
      columns: ['id_camion_decharge'],
      where: 'id = ?',
      whereArgs: [id],
    );

    int? camionId;
    if (results.isNotEmpty) {
      camionId = results.first['id_camion_decharge'];
    }

    final result = await _databaseHelper.delete(DatabaseHelper.tableAgraigeMoul, id);

    // Update the count if we found a camion ID
    if (camionId != null) {
      await _updateCamionTestCounts(camionId);
    }

    return result;
  }

  Future<int> deleteMoulTestsByDechargeId(int dechargeId) async {
    final db = await _databaseHelper.database;
    return await db.delete(
      DatabaseHelper.tableAgraigeMoul,
      where: 'id_camion_decharge = ?',
      whereArgs: [dechargeId],
    );
  }

  Future<List<AgraigeMoulTests>> getUnsyncedMoulTests() async {
    final maps = await _databaseHelper.getUnsyncedRecords(DatabaseHelper.tableAgraigeMoul);
    return maps.map((map) => AgraigeMoulTests.fromDatabase(map)).toList();
  }

  Future<int> markMoulTestAsSynced(int localId, int serverId) async {
    return await _databaseHelper.markAsSynced(
      DatabaseHelper.tableAgraigeMoul,
      localId,
      serverId,
    );
  }

  Future<Map<String, dynamic>> getCompleteDechargeData(int dechargeId) async {
    final camion = await getCamionDechargeById(dechargeId);
    final qualiteTests = await getQualiteTestsByDechargeId(dechargeId);
    final moulTests = await getMoulTestsByDechargeId(dechargeId);

    return {
      'camion': camion,
      'qualiteTests': qualiteTests,
      'moulTests': moulTests,
    };
  }

  Future<List<Map<String, dynamic>>> getAllCompleteDechargeData() async {
    final camions = await getAllCamionDecharges();
    List<Map<String, dynamic>> completeData = [];

    for (CamionDecharge camion in camions) {
      final data = await getCompleteDechargeData(camion.idDecharge!);
      completeData.add(data);
    }

    return completeData;
  }

  Future<void> clearAllData() async {
    await _databaseHelper.deleteDatabase();
  }

  Future<Map<String, int>> getDataCounts() async {
    final camions = await getAllCamionDecharges();
    final qualiteTests = await getAllQualiteTests();
    final moulTests = await getAllMoulTests();
    final unsyncedCamions = await getUnsyncedCamionDecharges();
    final unsyncedQualiteTests = await getUnsyncedQualiteTests();
    final unsyncedMoulTests = await getUnsyncedMoulTests();

    return {
      'camions': camions.length,
      'qualiteTests': qualiteTests.length,
      'moulTests': moulTests.length,
      'unsyncedCamions': unsyncedCamions.length,
      'unsyncedQualiteTests': unsyncedQualiteTests.length,
      'unsyncedMoulTests': unsyncedMoulTests.length,
    };
  }

  Future<void> _updateCamionTestCounts(int camionDechargeId) async {
    final qualiteTests = await getQualiteTestsByDechargeId(camionDechargeId);
    final moulTests = await getMoulTestsByDechargeId(camionDechargeId);

    final db = await _databaseHelper.database;
    await db.update(
      DatabaseHelper.tableCamionDecharge,
      {
        'nbr_agraige_qualite': qualiteTests.length,
        'nbr_agraige_moule': moulTests.length,
        'date_modification': DateTime.now().toIso8601String(),
        'is_synced': 0, // Mark as unsynced since we modified it
      },
      where: 'id_decharge = ?',
      whereArgs: [camionDechargeId],
    );
  }

  Future<void> recalculateAllTestCounts() async {
    final camions = await getAllCamionDecharges();
    for (final camion in camions) {
      if (camion.idDecharge != null) {
        await _updateCamionTestCounts(camion.idDecharge!);
      }
    }
  }
}