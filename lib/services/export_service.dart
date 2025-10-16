import 'dart:io';
import 'dart:convert';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import '../models/camion_decharge.dart';
import '../models/agraige_qualite_tests.dart';
import '../models/agraige_moul_tests.dart';
import '../repositories/local_repository.dart';

class ExportService {
  static final LocalRepository _localRepository = LocalRepository();

  static Future<String> exportToCSV({
    bool includeCamions = true,
    bool includeQualiteTests = true,
    bool includeMoulTests = true,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    try {
      List<List<String>> csvData = [];

      if (includeCamions) {
        csvData.addAll(await _exportCamionsToCSV(fromDate, toDate));
        csvData.add([]); // Empty row as separator
      }

      if (includeQualiteTests) {
        csvData.addAll(await _exportQualiteTestsToCSV(fromDate, toDate));
        csvData.add([]); // Empty row as separator
      }

      if (includeMoulTests) {
        csvData.addAll(await _exportMoulTestsToCSV(fromDate, toDate));
      }

      String csv = const ListToCsvConverter().convert(csvData);

      Directory directory = await getApplicationDocumentsDirectory();
      String timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      String filePath = '${directory.path}/fish_industry_export_$timestamp.csv';

      File file = File(filePath);
      await file.writeAsString(csv);

      return filePath;
    } catch (e) {
      throw ExportException('Failed to export CSV: $e');
    }
  }

  static Future<String> exportToJSON({
    bool includeCamions = true,
    bool includeQualiteTests = true,
    bool includeMoulTests = true,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    try {
      Map<String, dynamic> exportData = {
        'exportDate': DateTime.now().toIso8601String(),
        'dateRange': {
          'from': fromDate?.toIso8601String(),
          'to': toDate?.toIso8601String(),
        },
        'data': {},
      };

      if (includeCamions) {
        List<CamionDecharge> camions = await _localRepository.getAllCamionDecharges();
        if (fromDate != null || toDate != null) {
          camions = _filterByDateRange(camions, fromDate, toDate);
        }
        exportData['data']['camions'] = camions.map((c) => c.toJson()).toList();
      }

      if (includeQualiteTests) {
        List<AgraigeQualiteTests> tests = await _localRepository.getAllQualiteTests();
        if (fromDate != null || toDate != null) {
          tests = _filterQualiteTestsByDateRange(tests, fromDate, toDate);
        }
        exportData['data']['qualiteTests'] = tests.map((t) => t.toJson()).toList();
      }

      if (includeMoulTests) {
        List<AgraigeMoulTests> tests = await _localRepository.getAllMoulTests();
        if (fromDate != null || toDate != null) {
          tests = _filterMoulTestsByDateRange(tests, fromDate, toDate);
        }
        exportData['data']['moulTests'] = tests.map((t) => t.toJson()).toList();
      }

      String jsonString = const JsonEncoder.withIndent('  ').convert(exportData);

      Directory directory = await getApplicationDocumentsDirectory();
      String timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      String filePath = '${directory.path}/fish_industry_export_$timestamp.json';

      File file = File(filePath);
      await file.writeAsString(jsonString);

      return filePath;
    } catch (e) {
      throw ExportException('Failed to export JSON: $e');
    }
  }

  static Future<String> exportCompleteReport() async {
    try {
      final completeData = await _localRepository.getAllCompleteDechargeData();

      Map<String, dynamic> report = {
        'reportDate': DateTime.now().toIso8601String(),
        'summary': await _generateSummary(),
        'completeData': completeData.map((data) => {
          'camion': data['camion']?.toJson(),
          'qualiteTests': (data['qualiteTests'] as List<AgraigeQualiteTests>)
              .map((t) => t.toJson()).toList(),
          'moulTests': (data['moulTests'] as List<AgraigeMoulTests>)
              .map((t) => t.toJson()).toList(),
        }).toList(),
      };

      String jsonString = const JsonEncoder.withIndent('  ').convert(report);

      Directory directory = await getApplicationDocumentsDirectory();
      String timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      String filePath = '${directory.path}/fish_industry_complete_report_$timestamp.json';

      File file = File(filePath);
      await file.writeAsString(jsonString);

      return filePath;
    } catch (e) {
      throw ExportException('Failed to export complete report: $e');
    }
  }

  static Future<List<List<String>>> _exportCamionsToCSV(DateTime? fromDate, DateTime? toDate) async {
    List<CamionDecharge> camions = await _localRepository.getAllCamionDecharges();
    if (fromDate != null || toDate != null) {
      camions = _filterByDateRange(camions, fromDate, toDate);
    }

    List<List<String>> csvData = [
      ['=== CAMION DECHARGE DATA ==='],
      [
        'ID',
        'Mat Camion',
        'Bateau',
        'Maree',
        'Heure Decharge',
        'Heure Traitement',
        'Temperature',
        'Poids Decharge (kg)',
        'Nbr Agreage Qualite',
        'Nbr Agreage Moule',
        'Is Exported',
        'Date Creation',
        'Date Modification',
        'Is Synced',
        'Server ID'
      ]
    ];

    for (CamionDecharge camion in camions) {
      csvData.add([
        camion.idDecharge?.toString() ?? '',
        camion.matCamion,
        camion.bateau ?? '',
        camion.maree ?? '',
        camion.heureDecharge?.toIso8601String() ?? '',
        camion.heureTraitement?.toIso8601String() ?? '',
        camion.temperature?.toString() ?? '',
        camion.poisDecharge?.toString() ?? '',
        camion.nbrAgraigeQualite?.toString() ?? '',
        camion.nbrAgraigeMoule?.toString() ?? '',
        camion.isExported.toString(),
        camion.dateCreation.toIso8601String(),
        camion.dateModification.toIso8601String(),
        camion.isSynced.toString(),
        camion.serverId?.toString() ?? '',
      ]);
    }

    return csvData;
  }

  static Future<List<List<String>>> _exportQualiteTestsToCSV(DateTime? fromDate, DateTime? toDate) async {
    List<AgraigeQualiteTests> tests = await _localRepository.getAllQualiteTests();
    print('Total quality tests found: ${tests.length}');
    if (fromDate != null || toDate != null) {
      tests = _filterQualiteTestsByDateRange(tests, fromDate, toDate);
      print('Quality tests after date filtering: ${tests.length}');
    }

    List<List<String>> csvData = [
      ['=== AGREAGE QUALITE TESTS DATA ==='],
      [
        'ID',
        'Agreage A',
        'Agreage B',
        'Agreage C',
        'Agreage MAQ',
        'Agreage CHIN',
        'Agreage FP',
        'Agreage G',
        'Agreage Anchois',
        'Petit Caliber',
        'ID Camion Decharge',
        'Date Creation',
        'Date Modification',
        'Total Quantity',
        'Is Synced',
        'Server ID'
      ]
    ];

    for (AgraigeQualiteTests test in tests) {
      csvData.add([
        test.id?.toString() ?? '',
        test.agraigeA?.toString() ?? '',
        test.agraigeB?.toString() ?? '',
        test.agraigeC?.toString() ?? '',
        test.agraigeMAQ?.toString() ?? '',
        test.agraigeCHIN?.toString() ?? '',
        test.agraigeFP?.toString() ?? '',
        test.agraigeG?.toString() ?? '',
        test.agraigeAnchois?.toString() ?? '',
        test.petitCaliber?.toString() ?? '',
        test.idCamionDecharge.toString(),
        test.dateCreation.toIso8601String(),
        test.dateModification.toIso8601String(),
        test.totalQuantity.toString(),
        test.isSynced.toString(),
        test.serverId?.toString() ?? '',
      ]);
    }

    return csvData;
  }

  static Future<List<List<String>>> _exportMoulTestsToCSV(DateTime? fromDate, DateTime? toDate) async {
    List<AgraigeMoulTests> tests = await _localRepository.getAllMoulTests();
    print('Total mold tests found: ${tests.length}');
    if (fromDate != null || toDate != null) {
      tests = _filterMoulTestsByDateRange(tests, fromDate, toDate);
      print('Mold tests after date filtering: ${tests.length}');
    }

    List<List<String>> csvData = [
      ['=== AGREAGE MOUL TESTS DATA ==='],
      [
        'ID',
        'Moul 6-8',
        'Moul 8-10',
        'Moul 10-12',
        'Moul 12-16',
        'Moul 16-20',
        'Moul 20-26',
        'Moul >30',
        'ID Camion Decharge',
        'Date Creation',
        'Date Modification',
        'Total Quantity',
        'Is Synced',
        'Server ID'
      ]
    ];

    for (AgraigeMoulTests test in tests) {
      csvData.add([
        test.id?.toString() ?? '',
        test.moul6_8?.toString() ?? '',
        test.moul8_10?.toString() ?? '',
        test.moul10_12?.toString() ?? '',
        test.moul12_16?.toString() ?? '',
        test.moul16_20?.toString() ?? '',
        test.moul20_26?.toString() ?? '',
        test.moulGt30?.toString() ?? '',
        test.idCamionDecharge.toString(),
        test.dateCreation.toIso8601String(),
        test.dateModification.toIso8601String(),
        test.totalQuantity.toString(),
        test.isSynced.toString(),
        test.serverId?.toString() ?? '',
      ]);
    }

    return csvData;
  }

  static List<CamionDecharge> _filterByDateRange(
    List<CamionDecharge> camions,
    DateTime? fromDate,
    DateTime? toDate,
  ) {
    return camions.where((camion) {
      if (fromDate != null && camion.dateCreation.isBefore(fromDate)) {
        return false;
      }
      if (toDate != null && camion.dateCreation.isAfter(toDate)) {
        return false;
      }
      return true;
    }).toList();
  }

  static List<AgraigeQualiteTests> _filterQualiteTestsByDateRange(
    List<AgraigeQualiteTests> tests,
    DateTime? fromDate,
    DateTime? toDate,
  ) {
    return tests.where((test) {
      if (fromDate != null && test.dateCreation.isBefore(fromDate)) {
        return false;
      }
      if (toDate != null && test.dateCreation.isAfter(toDate)) {
        return false;
      }
      return true;
    }).toList();
  }

  static List<AgraigeMoulTests> _filterMoulTestsByDateRange(
    List<AgraigeMoulTests> tests,
    DateTime? fromDate,
    DateTime? toDate,
  ) {
    return tests.where((test) {
      if (fromDate != null && test.dateCreation.isBefore(fromDate)) {
        return false;
      }
      if (toDate != null && test.dateCreation.isAfter(toDate)) {
        return false;
      }
      return true;
    }).toList();
  }

  static Future<Map<String, dynamic>> _generateSummary() async {
    final counts = await _localRepository.getDataCounts();
    final camions = await _localRepository.getAllCamionDecharges();
    final qualiteTests = await _localRepository.getAllQualiteTests();
    final moulTests = await _localRepository.getAllMoulTests();

    double totalTemperature = 0;
    int temperatureCount = 0;
    for (CamionDecharge camion in camions) {
      if (camion.temperature != null) {
        totalTemperature += camion.temperature!;
        temperatureCount++;
      }
    }

    int totalQualiteQuantity = 0;
    for (AgraigeQualiteTests test in qualiteTests) {
      totalQualiteQuantity += test.totalQuantity;
    }

    int totalMoulQuantity = 0;
    for (AgraigeMoulTests test in moulTests) {
      totalMoulQuantity += test.totalQuantity;
    }

    return {
      'counts': counts,
      'averageTemperature': temperatureCount > 0 ? totalTemperature / temperatureCount : 0,
      'totalQualiteQuantity': totalQualiteQuantity,
      'totalMoulQuantity': totalMoulQuantity,
      'dateRange': {
        'earliest': camions.isNotEmpty
            ? camions.map((c) => c.dateCreation).reduce((a, b) => a.isBefore(b) ? a : b).toIso8601String()
            : null,
        'latest': camions.isNotEmpty
            ? camions.map((c) => c.dateCreation).reduce((a, b) => a.isAfter(b) ? a : b).toIso8601String()
            : null,
      },
    };
  }

  static Future<List<String>> getExportedFiles() async {
    try {
      Directory directory = await getApplicationDocumentsDirectory();
      List<FileSystemEntity> files = directory.listSync();

      return files
          .where((file) => file is File &&
                 (file.path.contains('fish_industry_export_') ||
                  file.path.contains('fish_industry_complete_report_')))
          .map((file) => file.path)
          .toList();
    } catch (e) {
      return [];
    }
  }

  static Future<bool> deleteExportedFile(String filePath) async {
    try {
      File file = File(filePath);
      if (await file.exists()) {
        await file.delete();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}

class ExportException implements Exception {
  final String message;

  ExportException(this.message);

  @override
  String toString() => 'ExportException: $message';
}