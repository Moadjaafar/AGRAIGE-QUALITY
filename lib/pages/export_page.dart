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
import '../services/api_service.dart';

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
    sheet.cell(CellIndex.indexByString('C1')).value = TextCellValue('Marée');
    sheet.cell(CellIndex.indexByString('D1')).value = TextCellValue('Heure Déchargement');
    sheet.cell(CellIndex.indexByString('E1')).value = TextCellValue('Heure Traitement');
    sheet.cell(CellIndex.indexByString('F1')).value = TextCellValue('Température (°C)');
    sheet.cell(CellIndex.indexByString('G1')).value = TextCellValue('Date Création');

    int currentRow = 2;

    for (CamionDecharge camion in _selectedCamions) {
      // Camion data
      sheet.cell(CellIndex.indexByString('A$currentRow')).value = TextCellValue(camion.matCamion);
      sheet.cell(CellIndex.indexByString('B$currentRow')).value = TextCellValue(camion.bateau ?? '');
      sheet.cell(CellIndex.indexByString('C$currentRow')).value = TextCellValue(camion.maree ?? '');
      sheet.cell(CellIndex.indexByString('D$currentRow')).value = TextCellValue(
        camion.heureDecharge != null
          ? DateFormat('dd/MM/yyyy HH:mm').format(camion.heureDecharge!)
          : ''
      );
      sheet.cell(CellIndex.indexByString('E$currentRow')).value = TextCellValue(
        camion.heureTraitement != null
          ? DateFormat('dd/MM/yyyy HH:mm').format(camion.heureTraitement!)
          : ''
      );
      sheet.cell(CellIndex.indexByString('F$currentRow')).value = TextCellValue(
        camion.temperature?.toString() ?? ''
      );
      sheet.cell(CellIndex.indexByString('G$currentRow')).value = TextCellValue(
        DateFormat('dd/MM/yyyy HH:mm').format(camion.dateCreation)
      );

      currentRow++;

      // Add quality tests
      final qualiteTests = await _localRepository.getQualiteTestsByDechargeId(camion.idDecharge!);
      if (qualiteTests.isNotEmpty) {
        sheet.cell(CellIndex.indexByString('A$currentRow')).value = TextCellValue('--- Tests de Qualité ---');
        currentRow++;

        sheet.cell(CellIndex.indexByString('A$currentRow')).value = TextCellValue('Agraige A');
        sheet.cell(CellIndex.indexByString('B$currentRow')).value = TextCellValue('Agraige B');
        sheet.cell(CellIndex.indexByString('C$currentRow')).value = TextCellValue('Agraige C');
        sheet.cell(CellIndex.indexByString('D$currentRow')).value = TextCellValue('Agraige MAQ');
        sheet.cell(CellIndex.indexByString('E$currentRow')).value = TextCellValue('Agraige CHIN');
        sheet.cell(CellIndex.indexByString('F$currentRow')).value = TextCellValue('Agraige FP');
        sheet.cell(CellIndex.indexByString('G$currentRow')).value = TextCellValue('Agraige G');
        sheet.cell(CellIndex.indexByString('H$currentRow')).value = TextCellValue('Agraige Anchois');
        sheet.cell(CellIndex.indexByString('I$currentRow')).value = TextCellValue('Petit Caliber');
        sheet.cell(CellIndex.indexByString('J$currentRow')).value = TextCellValue('Total');
        currentRow++;

        for (AgraigeQualiteTests test in qualiteTests) {
          sheet.cell(CellIndex.indexByString('A$currentRow')).value = IntCellValue(test.agraigeA ?? 0);
          sheet.cell(CellIndex.indexByString('B$currentRow')).value = IntCellValue(test.agraigeB ?? 0);
          sheet.cell(CellIndex.indexByString('C$currentRow')).value = IntCellValue(test.agraigeC ?? 0);
          sheet.cell(CellIndex.indexByString('D$currentRow')).value = IntCellValue(test.agraigeMAQ ?? 0);
          sheet.cell(CellIndex.indexByString('E$currentRow')).value = IntCellValue(test.agraigeCHIN ?? 0);
          sheet.cell(CellIndex.indexByString('F$currentRow')).value = IntCellValue(test.agraigeFP ?? 0);
          sheet.cell(CellIndex.indexByString('G$currentRow')).value = IntCellValue(test.agraigeG ?? 0);
          sheet.cell(CellIndex.indexByString('H$currentRow')).value = IntCellValue(test.agraigeAnchois ?? 0);
          sheet.cell(CellIndex.indexByString('I$currentRow')).value = IntCellValue(test.petitCaliber ?? 0);
          sheet.cell(CellIndex.indexByString('J$currentRow')).value = IntCellValue(test.totalQuantity);
          currentRow++;
        }
      }

      // Add mold tests
      final moulTests = await _localRepository.getMoulTestsByDechargeId(camion.idDecharge!);
      if (moulTests.isNotEmpty) {
        sheet.cell(CellIndex.indexByString('A$currentRow')).value = TextCellValue('--- Tests de Moule ---');
        currentRow++;

        sheet.cell(CellIndex.indexByString('A$currentRow')).value = TextCellValue('6-8mm');
        sheet.cell(CellIndex.indexByString('B$currentRow')).value = TextCellValue('8-10mm');
        sheet.cell(CellIndex.indexByString('C$currentRow')).value = TextCellValue('10-12mm');
        sheet.cell(CellIndex.indexByString('D$currentRow')).value = TextCellValue('12-16mm');
        sheet.cell(CellIndex.indexByString('E$currentRow')).value = TextCellValue('16-20mm');
        sheet.cell(CellIndex.indexByString('F$currentRow')).value = TextCellValue('20-26mm');
        sheet.cell(CellIndex.indexByString('G$currentRow')).value = TextCellValue('>30mm');
        currentRow++;

        for (AgraigeMoulTests test in moulTests) {
          sheet.cell(CellIndex.indexByString('A$currentRow')).value = IntCellValue(test.moul6_8 ?? 0);
          sheet.cell(CellIndex.indexByString('B$currentRow')).value = IntCellValue(test.moul8_10 ?? 0);
          sheet.cell(CellIndex.indexByString('C$currentRow')).value = IntCellValue(test.moul10_12 ?? 0);
          sheet.cell(CellIndex.indexByString('D$currentRow')).value = IntCellValue(test.moul12_16 ?? 0);
          sheet.cell(CellIndex.indexByString('E$currentRow')).value = IntCellValue(test.moul16_20 ?? 0);
          sheet.cell(CellIndex.indexByString('F$currentRow')).value = IntCellValue(test.moul20_26 ?? 0);
          sheet.cell(CellIndex.indexByString('G$currentRow')).value = IntCellValue(test.moulGt30 ?? 0);
          currentRow++;
        }
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

  Future<void> _exportToServer() async {
    if (_selectedCamions.isEmpty) {
      _showErrorMessage('Veuillez sélectionner au moins un déchargement');
      return;
    }

    setState(() {
      _isExporting = true;
    });

    try {
      int successCount = 0;
      int errorCount = 0;

      for (CamionDecharge camion in _selectedCamions) {
        try {
          // Export camion if not synced
          if (!camion.isSynced) {
            final serverCamion = await ApiService.createCamionDecharge(camion);
            await _localRepository.markCamionDechargeAsSynced(
              camion.idDecharge!,
              serverCamion.idDecharge!
            );
          }

          // Export quality tests
          final qualiteTests = await _localRepository.getQualiteTestsByDechargeId(camion.idDecharge!);
          for (AgraigeQualiteTests test in qualiteTests) {
            if (!test.isSynced) {
              final serverTest = await ApiService.createQualiteTest(test);
              await _localRepository.markQualiteTestAsSynced(test.id!, serverTest.id!);
            }
          }

          // Export mold tests
          final moulTests = await _localRepository.getMoulTestsByDechargeId(camion.idDecharge!);
          for (AgraigeMoulTests test in moulTests) {
            if (!test.isSynced) {
              final serverTest = await ApiService.createMoulTest(test);
              await _localRepository.markMoulTestAsSynced(test.id!, serverTest.id!);
            }
          }

          successCount++;
        } catch (e) {
          errorCount++;
          debugPrint('Erreur pour le camion ${camion.matCamion}: $e');
        }
      }

      if (mounted) {
        setState(() {
          _isExporting = false;
        });

        if (successCount > 0) {
          _showSuccessMessage(
            'Exportation réussie: $successCount déchargements exportés${errorCount > 0 ? ', $errorCount erreurs' : ''}'
          );
          _loadCamions(); // Refresh to show sync status
        } else {
          _showErrorMessage('Aucun déchargement n\'a pu être exporté');
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isExporting = false;
        });
        _showErrorMessage('Erreur lors de l\'exportation serveur: $e');
      }
    }
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
                                    Row(
                                      children: [
                                        Icon(
                                          camion.isSynced ? Icons.cloud_done : Icons.cloud_off,
                                          size: 16,
                                          color: camion.isSynced ? Colors.green : Colors.orange,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          camion.isSynced ? 'Synchronisé' : 'Non synchronisé',
                                          style: TextStyle(
                                            color: camion.isSynced ? Colors.green : Colors.orange,
                                          ),
                                        ),
                                      ],
                                    ),
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
                // Export buttons
                if (_selectedCamions.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      border: Border(top: BorderSide(color: Colors.grey[300]!)),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
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
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: _isExporting ? null : _exportToServer,
                                icon: _isExporting
                                    ? const SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(strokeWidth: 2),
                                      )
                                    : const Icon(Icons.cloud_upload),
                                label: const Text('Exporter Serveur'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue[600],
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (_isExporting)
                          const Padding(
                            padding: EdgeInsets.only(top: 8.0),
                            child: Text(
                              'Exportation en cours...',
                              style: TextStyle(fontStyle: FontStyle.italic),
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