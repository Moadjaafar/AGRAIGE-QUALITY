import 'package:flutter/material.dart';
import '../models/agraige_qualite_tests.dart';
import '../models/camion_decharge.dart';
import '../repositories/local_repository.dart';

class AgraigeQualiteFormPage extends StatefulWidget {
  final AgraigeQualiteTests? test;

  const AgraigeQualiteFormPage({super.key, this.test});

  @override
  State<AgraigeQualiteFormPage> createState() => _AgraigeQualiteFormPageState();
}

class _AgraigeQualiteFormPageState extends State<AgraigeQualiteFormPage> {
  final _formKey = GlobalKey<FormState>();
  final LocalRepository _localRepository = LocalRepository();

  late final TextEditingController _agraigeAController;
  late final TextEditingController _agraigeBController;
  late final TextEditingController _agraigeCController;
  late final TextEditingController _agraigeMAQController;
  late final TextEditingController _agraigeCHINController;
  late final TextEditingController _agraigeFPController;
  late final TextEditingController _agraigeGController;
  late final TextEditingController _agraigeAnchoisController;
  late final TextEditingController _petitCaliberController;

  List<CamionDecharge> _camions = [];
  int? _selectedCamionId;
  bool _isLoading = false;
  bool _isLoadingCamions = true;
  int _currentTotal = 0;

  bool get _isEditing => widget.test != null;

  int _calculateTotal() {
    return (_parseIntOrNull(_agraigeAController.text) ?? 0) +
           (_parseIntOrNull(_agraigeBController.text) ?? 0) +
           (_parseIntOrNull(_agraigeCController.text) ?? 0) +
           (_parseIntOrNull(_agraigeMAQController.text) ?? 0) +
           (_parseIntOrNull(_agraigeCHINController.text) ?? 0) +
           (_parseIntOrNull(_agraigeFPController.text) ?? 0) +
           (_parseIntOrNull(_agraigeGController.text) ?? 0) +
           (_parseIntOrNull(_agraigeAnchoisController.text) ?? 0) +
           (_parseIntOrNull(_petitCaliberController.text) ?? 0);
  }

  void _updateTotal() {
    setState(() {
      _currentTotal = _calculateTotal();
    });
  }

  @override
  void initState() {
    super.initState();

    _agraigeAController = TextEditingController(text: widget.test?.agraigeA?.toString() ?? '');
    _agraigeBController = TextEditingController(text: widget.test?.agraigeB?.toString() ?? '');
    _agraigeCController = TextEditingController(text: widget.test?.agraigeC?.toString() ?? '');
    _agraigeMAQController = TextEditingController(text: widget.test?.agraigeMAQ?.toString() ?? '');
    _agraigeCHINController = TextEditingController(text: widget.test?.agraigeCHIN?.toString() ?? '');
    _agraigeFPController = TextEditingController(text: widget.test?.agraigeFP?.toString() ?? '');
    _agraigeGController = TextEditingController(text: widget.test?.agraigeG?.toString() ?? '');
    _agraigeAnchoisController = TextEditingController(text: widget.test?.agraigeAnchois?.toString() ?? '');
    _petitCaliberController = TextEditingController(text: widget.test?.petitCaliber?.toString() ?? '');

    _selectedCamionId = widget.test?.idCamionDecharge;

    // Add listeners to update total in real-time
    _agraigeAController.addListener(_updateTotal);
    _agraigeBController.addListener(_updateTotal);
    _agraigeCController.addListener(_updateTotal);
    _agraigeMAQController.addListener(_updateTotal);
    _agraigeCHINController.addListener(_updateTotal);
    _agraigeFPController.addListener(_updateTotal);
    _agraigeGController.addListener(_updateTotal);
    _agraigeAnchoisController.addListener(_updateTotal);
    _petitCaliberController.addListener(_updateTotal);

    _updateTotal(); // Initialize total
    _loadCamions();
  }

  @override
  void dispose() {
    _agraigeAController.dispose();
    _agraigeBController.dispose();
    _agraigeCController.dispose();
    _agraigeMAQController.dispose();
    _agraigeCHINController.dispose();
    _agraigeFPController.dispose();
    _agraigeGController.dispose();
    _agraigeAnchoisController.dispose();
    _petitCaliberController.dispose();
    super.dispose();
  }

  Future<void> _loadCamions() async {
    try {
      final camions = await _localRepository.getAllCamionDecharges();
      setState(() {
        _camions = camions;
        _isLoadingCamions = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingCamions = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading trucks: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  int? _parseIntOrNull(String value) {
    if (value.trim().isEmpty) return null;
    return int.tryParse(value.trim());
  }

  int _getTotalQuantity() {
    return (_parseIntOrNull(_agraigeAController.text) ?? 0) +
        (_parseIntOrNull(_agraigeBController.text) ?? 0) +
        (_parseIntOrNull(_agraigeCController.text) ?? 0) +
        (_parseIntOrNull(_agraigeMAQController.text) ?? 0) +
        (_parseIntOrNull(_agraigeCHINController.text) ?? 0) +
        (_parseIntOrNull(_agraigeFPController.text) ?? 0) +
        (_parseIntOrNull(_agraigeGController.text) ?? 0) +
        (_parseIntOrNull(_agraigeAnchoisController.text) ?? 0) +
        (_parseIntOrNull(_petitCaliberController.text) ?? 0);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedCamionId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez sélectionner un camion'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Validate total must equal exactly 100
    int total = _calculateTotal();
    if (total != 100) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Le total des valeurs doit être exactement 100 (actuel: $total)'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final now = DateTime.now();

      final test = AgraigeQualiteTests(
        id: widget.test?.id,
        agraigeA: _parseIntOrNull(_agraigeAController.text),
        agraigeB: _parseIntOrNull(_agraigeBController.text),
        agraigeC: _parseIntOrNull(_agraigeCController.text),
        agraigeMAQ: _parseIntOrNull(_agraigeMAQController.text),
        agraigeCHIN: _parseIntOrNull(_agraigeCHINController.text),
        agraigeFP: _parseIntOrNull(_agraigeFPController.text),
        agraigeG: _parseIntOrNull(_agraigeGController.text),
        agraigeAnchois: _parseIntOrNull(_agraigeAnchoisController.text),
        petitCaliber: _parseIntOrNull(_petitCaliberController.text),
        idCamionDecharge: _selectedCamionId!,
        dateCreation: widget.test?.dateCreation ?? now,
        dateModification: now,
        isSynced: false,
        serverId: widget.test?.serverId,
      );

      if (_isEditing) {
        await _localRepository.updateQualiteTest(widget.test!.id!, test);
      } else {
        await _localRepository.insertQualiteTest(test);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isEditing
                  ? 'Quality test updated successfully'
                  : 'Quality test created successfully',
            ),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Quality Test' : 'New Quality Test'),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            )
          else
            TextButton(
              onPressed: _save,
              child: const Text(
                'SAVE',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
      body: _isLoadingCamions
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Truck Selection',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            DropdownButtonFormField<int>(
                              decoration: const InputDecoration(
                                labelText: 'Select Truck *',
                                prefixIcon: Icon(Icons.local_shipping),
                                border: OutlineInputBorder(),
                              ),
                              value: _selectedCamionId,
                              items: _camions.map((camion) {
                                String displayText = camion.matCamion;
                                if (camion.bateau != null && camion.bateau!.isNotEmpty) {
                                  displayText += ' - ${camion.bateau}';
                                }
                                if (camion.maree != null && camion.maree!.isNotEmpty) {
                                  displayText += ' (${camion.maree})';
                                }
                                return DropdownMenuItem<int>(
                                  value: camion.idDecharge,
                                  child: Text(displayText),
                                );
                              }).toList(),
                              onChanged: _isEditing
                                  ? null
                                  : (value) {
                                      setState(() {
                                        _selectedCamionId = value;
                                      });
                                    },
                              validator: (value) {
                                if (value == null) {
                                  return 'Please select a truck';
                                }
                                return null;
                              },
                            ),
                            if (_isEditing)
                              Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(
                                  'Truck cannot be changed when editing',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    'Quality Measurements',
                                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.green[100],
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    'Total: ${_getTotalQuantity()}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green[800],
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            GridView.count(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              crossAxisCount: 2,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                              childAspectRatio: 2.5,
                              children: [
                                _buildNumberField('Agreage A', _agraigeAController),
                                _buildNumberField('Agreage B', _agraigeBController),
                                _buildNumberField('Agreage C', _agraigeCController),
                                _buildNumberField('Agreage MAQ', _agraigeMAQController),
                                _buildNumberField('Agreage CHIN', _agraigeCHINController),
                                _buildNumberField('Agreage FP', _agraigeFPController),
                                _buildNumberField('Agreage G', _agraigeGController),
                                _buildNumberField('Agreage Anchois', _agraigeAnchoisController),
                                _buildNumberField('Petit Caliber', _petitCaliberController, fullWidth: true),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Card(
                      color: _currentTotal == 100 ? Colors.green[50] : Colors.red[50],
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Text(
                                'Total des valeurs:',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '$_currentTotal / 100',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                                color: _currentTotal == 100 ? Colors.green[700] : Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (_currentTotal != 100)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          _currentTotal < 100
                            ? 'Il manque ${100 - _currentTotal} pour atteindre 100'
                            : 'Le total dépasse de ${_currentTotal - 100} (doit être exactement 100)',
                          style: TextStyle(
                            color: Colors.red[700],
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _save,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: Colors.green[700],
                          foregroundColor: Colors.white,
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : Text(
                                _isEditing ? 'UPDATE QUALITY TEST' : 'CREATE QUALITY TEST',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildNumberField(String label, TextEditingController controller, {bool fullWidth = false}) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      keyboardType: TextInputType.number,
      validator: (value) {
        if (value != null && value.trim().isNotEmpty) {
          final number = int.tryParse(value.trim());
          if (number == null || number < 0) {
            return 'Invalid number';
          }
        }
        return null;
      },
      onChanged: (value) {
        setState(() {
          // Trigger rebuild to update total
        });
      },
    );
  }
}