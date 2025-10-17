import 'package:flutter/material.dart';
import '../models/agraige_moul_tests.dart';
import '../models/camion_decharge.dart';
import '../repositories/local_repository.dart';

class AgraigeMoulFormPage extends StatefulWidget {
  final AgraigeMoulTests? test;

  const AgraigeMoulFormPage({super.key, this.test});

  @override
  State<AgraigeMoulFormPage> createState() => _AgraigeMoulFormPageState();
}

class _AgraigeMoulFormPageState extends State<AgraigeMoulFormPage> {
  final _formKey = GlobalKey<FormState>();
  final LocalRepository _localRepository = LocalRepository();

  late final TextEditingController _moul6_8Controller;
  late final TextEditingController _moul8_10Controller;
  late final TextEditingController _moul10_12Controller;
  late final TextEditingController _moul12_16Controller;
  late final TextEditingController _moul16_20Controller;
  late final TextEditingController _moul20_26Controller;
  late final TextEditingController _moulGt30Controller;

  List<CamionDecharge> _camions = [];
  int? _selectedCamionId;
  bool _isLoading = false;
  bool _isLoadingCamions = true;
  int _currentTotal = 0;

  bool get _isEditing => widget.test != null;

  int _calculateTotal() {
    return (_parseIntOrNull(_moul6_8Controller.text) ?? 0) +
           (_parseIntOrNull(_moul8_10Controller.text) ?? 0) +
           (_parseIntOrNull(_moul10_12Controller.text) ?? 0) +
           (_parseIntOrNull(_moul12_16Controller.text) ?? 0) +
           (_parseIntOrNull(_moul16_20Controller.text) ?? 0) +
           (_parseIntOrNull(_moul20_26Controller.text) ?? 0) +
           (_parseIntOrNull(_moulGt30Controller.text) ?? 0);
  }

  void _updateTotal() {
    setState(() {
      _currentTotal = _calculateTotal();
    });
  }

  @override
  void initState() {
    super.initState();

    _moul6_8Controller = TextEditingController(text: widget.test?.moul6_8?.toString() ?? '');
    _moul8_10Controller = TextEditingController(text: widget.test?.moul8_10?.toString() ?? '');
    _moul10_12Controller = TextEditingController(text: widget.test?.moul10_12?.toString() ?? '');
    _moul12_16Controller = TextEditingController(text: widget.test?.moul12_16?.toString() ?? '');
    _moul16_20Controller = TextEditingController(text: widget.test?.moul16_20?.toString() ?? '');
    _moul20_26Controller = TextEditingController(text: widget.test?.moul20_26?.toString() ?? '');
    _moulGt30Controller = TextEditingController(text: widget.test?.moulGt30?.toString() ?? '');

    _selectedCamionId = widget.test?.idCamionDecharge;

    // Add listeners to update total in real-time
    _moul6_8Controller.addListener(_updateTotal);
    _moul8_10Controller.addListener(_updateTotal);
    _moul10_12Controller.addListener(_updateTotal);
    _moul12_16Controller.addListener(_updateTotal);
    _moul16_20Controller.addListener(_updateTotal);
    _moul20_26Controller.addListener(_updateTotal);
    _moulGt30Controller.addListener(_updateTotal);

    _updateTotal(); // Initialize total
    _loadCamions();
  }

  @override
  void dispose() {
    _moul6_8Controller.dispose();
    _moul8_10Controller.dispose();
    _moul10_12Controller.dispose();
    _moul12_16Controller.dispose();
    _moul16_20Controller.dispose();
    _moul20_26Controller.dispose();
    _moulGt30Controller.dispose();
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
    return (_parseIntOrNull(_moul6_8Controller.text) ?? 0) +
        (_parseIntOrNull(_moul8_10Controller.text) ?? 0) +
        (_parseIntOrNull(_moul10_12Controller.text) ?? 0) +
        (_parseIntOrNull(_moul12_16Controller.text) ?? 0) +
        (_parseIntOrNull(_moul16_20Controller.text) ?? 0) +
        (_parseIntOrNull(_moul20_26Controller.text) ?? 0) +
        (_parseIntOrNull(_moulGt30Controller.text) ?? 0);
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

      final test = AgraigeMoulTests(
        id: widget.test?.id,
        moul6_8: _parseIntOrNull(_moul6_8Controller.text),
        moul8_10: _parseIntOrNull(_moul8_10Controller.text),
        moul10_12: _parseIntOrNull(_moul10_12Controller.text),
        moul12_16: _parseIntOrNull(_moul12_16Controller.text),
        moul16_20: _parseIntOrNull(_moul16_20Controller.text),
        moul20_26: _parseIntOrNull(_moul20_26Controller.text),
        moulGt30: _parseIntOrNull(_moulGt30Controller.text),
        idCamionDecharge: _selectedCamionId!,
        dateCreation: widget.test?.dateCreation ?? now,
        dateModification: now,
        isSynced: false,
        serverId: widget.test?.serverId,
      );

      if (_isEditing) {
        await _localRepository.updateMoulTest(widget.test!.id!, test);
      } else {
        await _localRepository.insertMoulTest(test);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isEditing
                  ? 'Mold test updated successfully'
                  : 'Mold test created successfully',
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
        title: Text(_isEditing ? 'Edit Mold Test' : 'New Mold Test'),
        backgroundColor: Colors.orange[700],
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
                                    'Mold Size Measurements',
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
                                    color: Colors.orange[100],
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    'Total: ${_getTotalQuantity()}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.orange[800],
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Enter quantities for each size range:',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Column(
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildSizeField('6-8mm', _moul6_8Controller, Colors.blue[100]!),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: _buildSizeField('8-10mm', _moul8_10Controller, Colors.green[100]!),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildSizeField('10-12mm', _moul10_12Controller, Colors.yellow[100]!),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: _buildSizeField('12-16mm', _moul12_16Controller, Colors.orange[100]!),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildSizeField('16-20mm', _moul16_20Controller, Colors.red[100]!),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: _buildSizeField('20-26mm', _moul20_26Controller, Colors.purple[100]!),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                SizedBox(
                                  width: double.infinity,
                                  child: _buildSizeField('>30mm', _moulGt30Controller, Colors.grey[200]!),
                                ),
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
                          backgroundColor: Colors.orange[700],
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
                                _isEditing ? 'UPDATE MOLD TEST' : 'CREATE MOLD TEST',
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

  Widget _buildSizeField(String label, TextEditingController controller, Color backgroundColor) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          filled: true,
          fillColor: backgroundColor,
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
      ),
    );
  }
}