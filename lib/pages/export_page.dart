import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:excel/excel.dart' hide Border;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/camion_decharge.dart';
import '../models/agraige_qualite_tests.dart';
import '../models/agraige_moul_tests.dart';
import '../repositories/local_repository.dart';

class ExportPage extends StatefulWidget {
  const ExportPage({super.key});

  @override
  State<ExportPage> createState() => _ExportPageState();
}

class _ExportPageState extends State<ExportPage> {
  final LocalRepository _localRepository = LocalRepository();
  List<CamionDecharge> _camions = [];
  List<CamionDecharge> _selectedCamions = [];
  bool _isLoading = true;
  bool _isExporting = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadCamions();
  }

  Future<void> _loadCamions() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final camions = await _localRepository.getAllCamionDecharges();
      setState(() {
        _camions = camions;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        _showErrorMessage('Erreur lors du chargement: $e');
      }
    }
  }

  List<CamionDecharge> get _filteredCamions {
    if (_searchQuery.isEmpty) {
      return _camions;
    }
    return _camions.where((camion) {
      return camion.matCamion.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (camion.bateau?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);
    }).toList();
  }

  void _toggleSelection(CamionDecharge camion) {
    setState(() {
      if (_selectedCamions.contains(camion)) {
        _selectedCamions.remove(camion);
      } else {
        _selectedCamions.add(camion);
      }
    });
  }

  void _selectAll() {
    setState(() {
      _selectedCamions = List.from(_filteredCamions);
    });
  }

  void _clearSelection() {
    setState(() {
      _selectedCamions.clear();
    });
  }

  Future<void> _exportToExcel() async {
    if (_selectedCamions.isEmpty) {
      _showErrorMessage('Veuillez sélectionner au moins un déchargement');
      return;
    }

    setState(() {
      _isExporting = true;
    });

    try {
      final filePath = await _generateExcelFile();

      if (mounted) {
        setState(() {
          _isExporting = false;
        });

        _showExportSuccessDialog(filePath);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isExporting = false;
        });
        _showErrorMessage('Erreur lors de l\'exportation Excel: $e');
      }
    }
  }

  Future<String> _generateExcelFile() async {
    final excel = Excel.createExcel();
    final sheet = excel['Déchargements'];

    // Headers
    sheet.cell(CellIndex.indexByString('A1')).value = TextCellValue('Immatriculation Camion');
    sheet.cell(CellIndex.indexByString('B1')).value = TextCellValue('Bateau');
    sheet.cell(CellIndex.indexByString('C1')).value = TextCellValue('Fournisseur');
    sheet.cell(CellIndex.indexByString('D1')).value = TextCellValue('Usine');
    sheet.cell(CellIndex.indexByString('E1')).value = TextCellValue('Marée');
    sheet.cell(CellIndex.indexByString('F1')).value = TextCellValue('Heure Déchargement');
    sheet.cell(CellIndex.indexByString('G1')).value = TextCellValue('Heure Traitement');
    sheet.cell(CellIndex.indexByString('H1')).value = TextCellValue('Température (°C)');
    sheet.cell(CellIndex.indexByString('I1')).value = TextCellValue('Poids Décharge (kg)');
    sheet.cell(CellIndex.indexByString('J1')).value = TextCellValue('Poids unitaire carton');
    sheet.cell(CellIndex.indexByString('K1')).value = TextCellValue('Date Création');

    int currentRow = 2;

    for (CamionDecharge camion in _selectedCamions) {
      // Camion data
      sheet.cell(CellIndex.indexByString('A$currentRow')).value = TextCellValue(camion.matCamion);
      sheet.cell(CellIndex.indexByString('B$currentRow')).value = TextCellValue(camion.bateau ?? '');
      sheet.cell(CellIndex.indexByString('C$currentRow')).value = TextCellValue(camion.fournisseur ?? '');
      sheet.cell(CellIndex.indexByString('D$currentRow')).value = TextCellValue(camion.usine ?? '');
      sheet.cell(CellIndex.indexByString('E$currentRow')).value = TextCellValue(camion.maree ?? '');
      sheet.cell(CellIndex.indexByString('F$currentRow')).value = TextCellValue(
        camion.heureDecharge != null
          ? DateFormat('dd/MM/yyyy HH:mm').format(camion.heureDecharge!)
          : ''
      );
      sheet.cell(CellIndex.indexByString('G$currentRow')).value = TextCellValue(
        camion.heureTraitement != null
          ? DateFormat('dd/MM/yyyy HH:mm').format(camion.heureTraitement!)
          : ''
      );
      sheet.cell(CellIndex.indexByString('H$currentRow')).value = TextCellValue(
        camion.temperature?.toString() ?? ''
      );
      sheet.cell(CellIndex.indexByString('I$currentRow')).value = TextCellValue(
        camion.poisDecharge?.toString() ?? ''
      );
      sheet.cell(CellIndex.indexByString('J$currentRow')).value = TextCellValue(
        camion.poidsUnitaireCarton != null ? '${camion.poidsUnitaireCarton} kg' : ''
      );
      sheet.cell(CellIndex.indexByString('K$currentRow')).value = TextCellValue(
        DateFormat('dd/MM/yyyy HH:mm').format(camion.dateCreation)
      );

      currentRow++;

      // Add tests side by side (quality tests on left, mold tests on right)
      final qualiteTests = await _localRepository.getQualiteTestsByDechargeId(camion.idDecharge!);
      final moulTests = await _localRepository.getMoulTestsByDechargeId(camion.idDecharge!);

      if (qualiteTests.isNotEmpty || moulTests.isNotEmpty) {
        // Headers for both test types
        sheet.cell(CellIndex.indexByString('A$currentRow')).value = TextCellValue('--- Tests de Qualité ---');
        sheet.cell(CellIndex.indexByString('G$currentRow')).value = TextCellValue('--- Tests de Moule ---');
        currentRow++;

        int testRowStart = currentRow;
        int maxQualiteRows = 0;
        int maxMoulRows = 0;

        // Add quality tests (vertical in columns A-B)
        if (qualiteTests.isNotEmpty) {
          int qualiteRow = testRowStart;

          // Calculate averages for quality tests
          double avgA = qualiteTests.map((t) => t.agraigeA ?? 0).reduce((a, b) => a + b) / qualiteTests.length;
          double avgB = qualiteTests.map((t) => t.agraigeB ?? 0).reduce((a, b) => a + b) / qualiteTests.length;
          double avgC = qualiteTests.map((t) => t.agraigeC ?? 0).reduce((a, b) => a + b) / qualiteTests.length;
          double avgMAQ = qualiteTests.map((t) => t.agraigeMAQ ?? 0).reduce((a, b) => a + b) / qualiteTests.length;
          double avgCHIN = qualiteTests.map((t) => t.agraigeCHIN ?? 0).reduce((a, b) => a + b) / qualiteTests.length;
          double avgFP = qualiteTests.map((t) => t.agraigeFP ?? 0).reduce((a, b) => a + b) / qualiteTests.length;
          double avgG = qualiteTests.map((t) => t.agraigeG ?? 0).reduce((a, b) => a + b) / qualiteTests.length;
          double avgAnchois = qualiteTests.map((t) => t.agraigeAnchois ?? 0).reduce((a, b) => a + b) / qualiteTests.length;
          double avgPetitCaliber = qualiteTests.map((t) => t.petitCaliber ?? 0).reduce((a, b) => a + b) / qualiteTests.length;
          double avgTotal = qualiteTests.map((t) => t.totalQuantity).reduce((a, b) => a + b) / qualiteTests.length;

          for (AgraigeQualiteTests test in qualiteTests) {
            sheet.cell(CellIndex.indexByString('A$qualiteRow')).value = TextCellValue('Agreage A');
            sheet.cell(CellIndex.indexByString('B$qualiteRow')).value = IntCellValue(test.agraigeA ?? 0);
            qualiteRow++;

            sheet.cell(CellIndex.indexByString('A$qualiteRow')).value = TextCellValue('Agreage B');
            sheet.cell(CellIndex.indexByString('B$qualiteRow')).value = IntCellValue(test.agraigeB ?? 0);
            qualiteRow++;

            sheet.cell(CellIndex.indexByString('A$qualiteRow')).value = TextCellValue('Agreage C');
            sheet.cell(CellIndex.indexByString('B$qualiteRow')).value = IntCellValue(test.agraigeC ?? 0);
            qualiteRow++;

            sheet.cell(CellIndex.indexByString('A$qualiteRow')).value = TextCellValue('Agreage MAQ');
            sheet.cell(CellIndex.indexByString('B$qualiteRow')).value = IntCellValue(test.agraigeMAQ ?? 0);
            qualiteRow++;

            sheet.cell(CellIndex.indexByString('A$qualiteRow')).value = TextCellValue('Agreage CHIN');
            sheet.cell(CellIndex.indexByString('B$qualiteRow')).value = IntCellValue(test.agraigeCHIN ?? 0);
            qualiteRow++;

            sheet.cell(CellIndex.indexByString('A$qualiteRow')).value = TextCellValue('Agreage FP');
            sheet.cell(CellIndex.indexByString('B$qualiteRow')).value = IntCellValue(test.agraigeFP ?? 0);
            qualiteRow++;

            sheet.cell(CellIndex.indexByString('A$qualiteRow')).value = TextCellValue('Agreage G');
            sheet.cell(CellIndex.indexByString('B$qualiteRow')).value = IntCellValue(test.agraigeG ?? 0);
            qualiteRow++;

            sheet.cell(CellIndex.indexByString('A$qualiteRow')).value = TextCellValue('Agreage Anchois');
            sheet.cell(CellIndex.indexByString('B$qualiteRow')).value = IntCellValue(test.agraigeAnchois ?? 0);
            qualiteRow++;

            sheet.cell(CellIndex.indexByString('A$qualiteRow')).value = TextCellValue('Petit Caliber');
            sheet.cell(CellIndex.indexByString('B$qualiteRow')).value = IntCellValue(test.petitCaliber ?? 0);
            qualiteRow++;

            sheet.cell(CellIndex.indexByString('A$qualiteRow')).value = TextCellValue('Total');
            sheet.cell(CellIndex.indexByString('B$qualiteRow')).value = IntCellValue(test.totalQuantity);
            qualiteRow++;

            qualiteRow++; // Empty row between test records
          }

          // Add averages section for quality tests
          if (qualiteTests.length > 1) {
            sheet.cell(CellIndex.indexByString('A$qualiteRow')).value = TextCellValue('=== MOYENNES QUALITÉ ===');
            qualiteRow++;

            sheet.cell(CellIndex.indexByString('A$qualiteRow')).value = TextCellValue('Moyen Agreage A');
            sheet.cell(CellIndex.indexByString('B$qualiteRow')).value = DoubleCellValue(double.parse(avgA.toStringAsFixed(2)));
            qualiteRow++;

            sheet.cell(CellIndex.indexByString('A$qualiteRow')).value = TextCellValue('Moyen Agreage B');
            sheet.cell(CellIndex.indexByString('B$qualiteRow')).value = DoubleCellValue(double.parse(avgB.toStringAsFixed(2)));
            qualiteRow++;

            sheet.cell(CellIndex.indexByString('A$qualiteRow')).value = TextCellValue('Moyen Agreage C');
            sheet.cell(CellIndex.indexByString('B$qualiteRow')).value = DoubleCellValue(double.parse(avgC.toStringAsFixed(2)));
            qualiteRow++;

            sheet.cell(CellIndex.indexByString('A$qualiteRow')).value = TextCellValue('Moyen Agreage MAQ');
            sheet.cell(CellIndex.indexByString('B$qualiteRow')).value = DoubleCellValue(double.parse(avgMAQ.toStringAsFixed(2)));
            qualiteRow++;

            sheet.cell(CellIndex.indexByString('A$qualiteRow')).value = TextCellValue('Moyen Agreage CHIN');
            sheet.cell(CellIndex.indexByString('B$qualiteRow')).value = DoubleCellValue(double.parse(avgCHIN.toStringAsFixed(2)));
            qualiteRow++;

            sheet.cell(CellIndex.indexByString('A$qualiteRow')).value = TextCellValue('Moyen Agreage FP');
            sheet.cell(CellIndex.indexByString('B$qualiteRow')).value = DoubleCellValue(double.parse(avgFP.toStringAsFixed(2)));
            qualiteRow++;

            sheet.cell(CellIndex.indexByString('A$qualiteRow')).value = TextCellValue('Moyen Agreage G');
            sheet.cell(CellIndex.indexByString('B$qualiteRow')).value = DoubleCellValue(double.parse(avgG.toStringAsFixed(2)));
            qualiteRow++;

            sheet.cell(CellIndex.indexByString('A$qualiteRow')).value = TextCellValue('Moyen Agreage Anchois');
            sheet.cell(CellIndex.indexByString('B$qualiteRow')).value = DoubleCellValue(double.parse(avgAnchois.toStringAsFixed(2)));
            qualiteRow++;

            sheet.cell(CellIndex.indexByString('A$qualiteRow')).value = TextCellValue('Moyen Petit Caliber');
            sheet.cell(CellIndex.indexByString('B$qualiteRow')).value = DoubleCellValue(double.parse(avgPetitCaliber.toStringAsFixed(2)));
            qualiteRow++;

            sheet.cell(CellIndex.indexByString('A$qualiteRow')).value = TextCellValue('Moyen Total');
            sheet.cell(CellIndex.indexByString('B$qualiteRow')).value = DoubleCellValue(double.parse(avgTotal.toStringAsFixed(2)));
            qualiteRow++;
          }

          maxQualiteRows = qualiteRow - testRowStart;
        }

        // Add mold tests (vertical in columns G-H)
        if (moulTests.isNotEmpty) {
          int moulRow = testRowStart;

          // Calculate averages for mold tests
          double avg6_8 = moulTests.map((t) => t.moul6_8 ?? 0).reduce((a, b) => a + b) / moulTests.length;
          double avg8_10 = moulTests.map((t) => t.moul8_10 ?? 0).reduce((a, b) => a + b) / moulTests.length;
          double avg10_12 = moulTests.map((t) => t.moul10_12 ?? 0).reduce((a, b) => a + b) / moulTests.length;
          double avg12_16 = moulTests.map((t) => t.moul12_16 ?? 0).reduce((a, b) => a + b) / moulTests.length;
          double avg16_20 = moulTests.map((t) => t.moul16_20 ?? 0).reduce((a, b) => a + b) / moulTests.length;
          double avg20_26 = moulTests.map((t) => t.moul20_26 ?? 0).reduce((a, b) => a + b) / moulTests.length;
          double avgGt30 = moulTests.map((t) => t.moulGt30 ?? 0).reduce((a, b) => a + b) / moulTests.length;
          double avgMoulTotal = moulTests.map((t) => t.totalQuantity).reduce((a, b) => a + b) / moulTests.length;

          for (AgraigeMoulTests test in moulTests) {
            sheet.cell(CellIndex.indexByString('G$moulRow')).value = TextCellValue('Moul 6-8mm');
            sheet.cell(CellIndex.indexByString('H$moulRow')).value = IntCellValue(test.moul6_8 ?? 0);
            moulRow++;

            sheet.cell(CellIndex.indexByString('G$moulRow')).value = TextCellValue('Moul 8-10mm');
            sheet.cell(CellIndex.indexByString('H$moulRow')).value = IntCellValue(test.moul8_10 ?? 0);
            moulRow++;

            sheet.cell(CellIndex.indexByString('G$moulRow')).value = TextCellValue('Moul 10-12mm');
            sheet.cell(CellIndex.indexByString('H$moulRow')).value = IntCellValue(test.moul10_12 ?? 0);
            moulRow++;

            sheet.cell(CellIndex.indexByString('G$moulRow')).value = TextCellValue('Moul 12-16mm');
            sheet.cell(CellIndex.indexByString('H$moulRow')).value = IntCellValue(test.moul12_16 ?? 0);
            moulRow++;

            sheet.cell(CellIndex.indexByString('G$moulRow')).value = TextCellValue('Moul 16-20mm');
            sheet.cell(CellIndex.indexByString('H$moulRow')).value = IntCellValue(test.moul16_20 ?? 0);
            moulRow++;

            sheet.cell(CellIndex.indexByString('G$moulRow')).value = TextCellValue('Moul 20-26mm');
            sheet.cell(CellIndex.indexByString('H$moulRow')).value = IntCellValue(test.moul20_26 ?? 0);
            moulRow++;

            sheet.cell(CellIndex.indexByString('G$moulRow')).value = TextCellValue('Moul >30mm');
            sheet.cell(CellIndex.indexByString('H$moulRow')).value = IntCellValue(test.moulGt30 ?? 0);
            moulRow++;

            sheet.cell(CellIndex.indexByString('G$moulRow')).value = TextCellValue('Total');
            sheet.cell(CellIndex.indexByString('H$moulRow')).value = IntCellValue(test.totalQuantity);
            moulRow++;

            moulRow++; // Empty row between test records
          }

          // Add averages section for mold tests
          if (moulTests.length > 1) {
            sheet.cell(CellIndex.indexByString('G$moulRow')).value = TextCellValue('=== MOYENNES MOULE ===');
            moulRow++;

            sheet.cell(CellIndex.indexByString('G$moulRow')).value = TextCellValue('Moyen Moul 6-8mm');
            sheet.cell(CellIndex.indexByString('H$moulRow')).value = DoubleCellValue(double.parse(avg6_8.toStringAsFixed(2)));
            moulRow++;

            sheet.cell(CellIndex.indexByString('G$moulRow')).value = TextCellValue('Moyen Moul 8-10mm');
            sheet.cell(CellIndex.indexByString('H$moulRow')).value = DoubleCellValue(double.parse(avg8_10.toStringAsFixed(2)));
            moulRow++;

            sheet.cell(CellIndex.indexByString('G$moulRow')).value = TextCellValue('Moyen Moul 10-12mm');
            sheet.cell(CellIndex.indexByString('H$moulRow')).value = DoubleCellValue(double.parse(avg10_12.toStringAsFixed(2)));
            moulRow++;

            sheet.cell(CellIndex.indexByString('G$moulRow')).value = TextCellValue('Moyen Moul 12-16mm');
            sheet.cell(CellIndex.indexByString('H$moulRow')).value = DoubleCellValue(double.parse(avg12_16.toStringAsFixed(2)));
            moulRow++;

            sheet.cell(CellIndex.indexByString('G$moulRow')).value = TextCellValue('Moyen Moul 16-20mm');
            sheet.cell(CellIndex.indexByString('H$moulRow')).value = DoubleCellValue(double.parse(avg16_20.toStringAsFixed(2)));
            moulRow++;

            sheet.cell(CellIndex.indexByString('G$moulRow')).value = TextCellValue('Moyen Moul 20-26mm');
            sheet.cell(CellIndex.indexByString('H$moulRow')).value = DoubleCellValue(double.parse(avg20_26.toStringAsFixed(2)));
            moulRow++;

            sheet.cell(CellIndex.indexByString('G$moulRow')).value = TextCellValue('Moyen Moul >30mm');
            sheet.cell(CellIndex.indexByString('H$moulRow')).value = DoubleCellValue(double.parse(avgGt30.toStringAsFixed(2)));
            moulRow++;

            sheet.cell(CellIndex.indexByString('G$moulRow')).value = TextCellValue('Moyen Total');
            sheet.cell(CellIndex.indexByString('H$moulRow')).value = DoubleCellValue(double.parse(avgMoulTotal.toStringAsFixed(2)));
            moulRow++;
          }

          maxMoulRows = moulRow - testRowStart;
        }

        // Move currentRow to after the longest column
        currentRow = testRowStart + (maxQualiteRows > maxMoulRows ? maxQualiteRows : maxMoulRows);
      }

      currentRow++; // Empty row between camions
    }

    // Save file
    final directory = await getApplicationDocumentsDirectory();
    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final fileName = 'dechargements_export_$timestamp.xlsx';
    final filePath = '${directory.path}/$fileName';

    final file = File(filePath);
    await file.writeAsBytes(excel.encode()!);

    return filePath;
  }


  void _showExportSuccessDialog(String filePath) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exportation Réussie'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Fichier Excel créé avec succès:'),
            const SizedBox(height: 8),
            Text(
              filePath.split('/').last,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text('Voulez-vous partager le fichier?'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fermer'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).pop();
              _shareToWhatsApp(filePath);
            },
            icon: const Icon(Icons.message, color: Colors.green),
            label: const Text('WhatsApp'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).pop();
              _shareToGmail(filePath);
            },
            icon: const Icon(Icons.email, color: Colors.red),
            label: const Text('Gmail'),
          ),
        ],
      ),
    );
  }

  Future<void> _shareToWhatsApp(String filePath) async {
    try {
      await Share.shareXFiles(
        [XFile(filePath)],
        text: 'Exportation des déchargements - ERP Industrie Poissonnière',
      );
    } catch (e) {
      _showErrorMessage('Erreur lors du partage WhatsApp: $e');
    }
  }

  Future<void> _shareToGmail(String filePath) async {
    try {
      // First try to open Gmail specifically
      if (await canLaunchUrl(Uri.parse('gmail:'))) {
        await launchUrl(Uri.parse('gmail:'));
      } else {
        // Fallback to general email share
        await Share.shareXFiles(
          [XFile(filePath)],
          text: 'Exportation des déchargements - ERP Industrie Poissonnière',
          subject: 'Exportation des déchargements',
        );
      }
    } catch (e) {
      _showErrorMessage('Erreur lors du partage Gmail: $e');
    }
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Exportation des Déchargements'),
        backgroundColor: Colors.purple[700],
        foregroundColor: Colors.white,
        actions: [
          if (_selectedCamions.isNotEmpty)
            TextButton(
              onPressed: _clearSelection,
              child: const Text(
                'Tout Désélectionner',
                style: TextStyle(color: Colors.white),
              ),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Search and selection controls
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      TextField(
                        decoration: const InputDecoration(
                          hintText: 'Rechercher par camion ou bateau...',
                          prefixIcon: Icon(Icons.search),
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (value) {
                          setState(() {
                            _searchQuery = value;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          ElevatedButton.icon(
                            onPressed: _selectAll,
                            icon: const Icon(Icons.select_all),
                            label: const Text('Tout Sélectionner'),
                          ),
                          const SizedBox(width: 16),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.purple[100],
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '${_selectedCamions.length} sélectionné(s)',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.purple[800],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // List of camions
                Expanded(
                  child: _filteredCamions.isEmpty
                      ? const Center(
                          child: Text('Aucun déchargement trouvé'),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          itemCount: _filteredCamions.length,
                          itemBuilder: (context, index) {
                            final camion = _filteredCamions[index];
                            final isSelected = _selectedCamions.contains(camion);

                            return Card(
                              margin: const EdgeInsets.only(bottom: 8.0),
                              color: isSelected ? Colors.purple[50] : null,
                              child: CheckboxListTile(
                                value: isSelected,
                                onChanged: (value) => _toggleSelection(camion),
                                title: Text(
                                  camion.matCamion,
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (camion.bateau != null) Text('Bateau: ${camion.bateau}'),
                                    Text('Créé: ${DateFormat('dd/MM/yyyy HH:mm').format(camion.dateCreation)}'),
                                  ],
                                ),
                                secondary: Icon(
                                  Icons.local_shipping,
                                  color: isSelected ? Colors.purple : Colors.grey,
                                ),
                              ),
                            );
                          },
                        ),
                ),
                // Export button
                if (_selectedCamions.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      border: Border(top: BorderSide(color: Colors.grey[300]!)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ElevatedButton.icon(
                          onPressed: _isExporting ? null : _exportToExcel,
                          icon: _isExporting
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Icon(Icons.table_chart),
                          label: const Text('Exporter Excel'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green[600],
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                        if (_isExporting)
                          const Padding(
                            padding: EdgeInsets.only(top: 8.0),
                            child: Text(
                              'Exportation en cours...',
                              style: TextStyle(fontStyle: FontStyle.italic),
                              textAlign: TextAlign.center,
                            ),
                          ),
                      ],
                    ),
                  ),
              ],
            ),
    );
  }
}