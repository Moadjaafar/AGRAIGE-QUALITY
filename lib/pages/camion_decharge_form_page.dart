import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../models/camion_decharge.dart';
import '../models/bateau.dart';
import '../models/fournisseur.dart';
import '../models/usine.dart';
import '../repositories/local_repository.dart';
import 'bateau_form_page.dart';
import 'fournisseur_form_page.dart';
import 'usine_form_page.dart';

class CamionDechargeFormPage extends StatefulWidget {
  final CamionDecharge? camion;

  const CamionDechargeFormPage({super.key, this.camion});

  @override
  State<CamionDechargeFormPage> createState() => _CamionDechargeFormPageState();
}

class _CamionDechargeFormPageState extends State<CamionDechargeFormPage> {
  final _formKey = GlobalKey<FormState>();
  final LocalRepository _localRepository = LocalRepository();

  late final TextEditingController _matCamionController;
  late final TextEditingController _mareeController;
  late final TextEditingController _temperatureController;
  late final TextEditingController _poisDechargeController;

  DateTime? _heureDecharge;
  DateTime? _heureTraitement;
  bool _isLoading = false;

  List<Bateau> _bateaux = [];
  String? _selectedBateauName;
  List<Fournisseur> _fournisseurs = [];
  String? _selectedFournisseurName;
  List<Usine> _usines = [];
  String? _selectedUsineName;
  int? _selectedPoidsUnitaireCarton;

  bool get _isEditing => widget.camion != null;

  // Helper getters to ensure selected values exist in their respective lists
  String? get _validatedBateauName {
    if (_selectedBateauName == null) return null;
    final exists = _bateaux.any((b) => b.nomBateau == _selectedBateauName);
    return exists ? _selectedBateauName : null;
  }

  String? get _validatedFournisseurName {
    if (_selectedFournisseurName == null) return null;
    final exists = _fournisseurs.any((f) => f.nomFournisseur == _selectedFournisseurName);
    return exists ? _selectedFournisseurName : null;
  }

  String? get _validatedUsineName {
    if (_selectedUsineName == null) return null;
    final exists = _usines.any((u) => u.nomUsine == _selectedUsineName);
    return exists ? _selectedUsineName : null;
  }

  @override
  void initState() {
    super.initState();

    _matCamionController = TextEditingController(text: widget.camion?.matCamion ?? '');
    // Extract numeric part from maree (remove 'L' prefix if present)
    String mareeValue = widget.camion?.maree ?? '';
    if (mareeValue.startsWith('L')) {
      mareeValue = mareeValue.substring(1);
    }
    _mareeController = TextEditingController(text: mareeValue);
    _temperatureController = TextEditingController(
      text: widget.camion?.temperature?.toString() ?? '',
    );
    _poisDechargeController = TextEditingController(
      text: widget.camion?.poisDecharge?.toString() ?? '',
    );

    _heureDecharge = widget.camion?.heureDecharge;
    _heureTraitement = widget.camion?.heureTraitement;
    _selectedBateauName = widget.camion?.bateau;
    _selectedFournisseurName = widget.camion?.fournisseur;
    _selectedUsineName = widget.camion?.usine;
    _selectedPoidsUnitaireCarton = widget.camion?.poidsUnitaireCarton;

    _loadBateaux();
    _loadFournisseurs();
    _loadUsines();
  }

  Future<void> _loadBateaux() async {
    try {
      final bateaux = await _localRepository.getAllBateaux();
      setState(() {
        _bateaux = bateaux;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading boats: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _loadFournisseurs() async {
    try {
      final fournisseurs = await _localRepository.getAllFournisseurs();
      setState(() {
        _fournisseurs = fournisseurs;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading suppliers: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _loadUsines() async {
    try {
      final usines = await _localRepository.getAllUsines();
      setState(() {
        _usines = usines;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading factories: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _matCamionController.dispose();
    _mareeController.dispose();
    _temperatureController.dispose();
    _poisDechargeController.dispose();
    super.dispose();
  }

  Future<void> _selectDateTime(BuildContext context, bool isDecharge) async {
    final date = await showDatePicker(
      context: context,
      initialDate: (isDecharge ? _heureDecharge : _heureTraitement) ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );

    if (date != null && mounted) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(
          (isDecharge ? _heureDecharge : _heureTraitement) ?? DateTime.now(),
        ),
      );

      if (time != null) {
        final dateTime = DateTime(
          date.year,
          date.month,
          date.day,
          time.hour,
          time.minute,
        );

        setState(() {
          if (isDecharge) {
            _heureDecharge = dateTime;
          } else {
            _heureTraitement = dateTime;
          }
        });
      }
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final now = DateTime.now();

      // Format maree with 'L' prefix
      String? mareeValue;
      if (_mareeController.text.trim().isNotEmpty) {
        final numericValue = _mareeController.text.trim().padLeft(3, '0');
        mareeValue = 'L$numericValue';
      }

      final camion = CamionDecharge(
        idDecharge: widget.camion?.idDecharge,
        matCamion: _matCamionController.text.trim(),
        bateau: _selectedBateauName,
        fournisseur: _selectedFournisseurName,
        usine: _selectedUsineName,
        maree: mareeValue,
        heureDecharge: _heureDecharge,
        heureTraitement: _heureTraitement,
        temperature: _temperatureController.text.trim().isEmpty
            ? null
            : double.tryParse(_temperatureController.text.trim()),
        poisDecharge: _poisDechargeController.text.trim().isEmpty
            ? null
            : double.tryParse(_poisDechargeController.text.trim()),
        poidsUnitaireCarton: _selectedPoidsUnitaireCarton,
        nbrAgraigeQualite: widget.camion?.nbrAgraigeQualite,
        nbrAgraigeMoule: widget.camion?.nbrAgraigeMoule,
        isExported: widget.camion?.isExported ?? false,
        dateCreation: widget.camion?.dateCreation ?? now,
        dateModification: now,
        isSynced: false,
        serverId: widget.camion?.serverId,
      );

      if (_isEditing) {
        await _localRepository.updateCamionDecharge(widget.camion!.idDecharge!, camion);
      } else {
        await _localRepository.insertCamionDecharge(camion);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isEditing
                  ? 'Truck discharge updated successfully'
                  : 'Truck discharge created successfully',
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
        title: Text(_isEditing ? 'Modifier Déchargement Camion' : 'Nouveau Déchargement Camion'),
        backgroundColor: Colors.blue[700],
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
      body: Form(
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
                        'Basic Information',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _matCamionController,
                        decoration: const InputDecoration(
                          labelText: 'Immatriculation Camion *',
                          hintText: 'Saisir le numéro d\'immatriculation du camion',
                          prefixIcon: Icon(Icons.local_shipping),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'L\'immatriculation du camion est requise';
                          }
                          if (value.trim().length > 20) {
                            return 'L\'immatriculation doit comporter 20 caractères ou moins';
                          }
                          return null;
                        },
                        textCapitalization: TextCapitalization.characters,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _validatedBateauName,
                              decoration: const InputDecoration(
                                labelText: 'Nom du Bateau',
                                hintText: 'Select a boat',
                                prefixIcon: Icon(Icons.directions_boat),
                              ),
                              items: [
                                const DropdownMenuItem<String>(
                                  value: null,
                                  child: Text('-- No boat selected --'),
                                ),
                                ..._bateaux.map((bateau) {
                                  return DropdownMenuItem<String>(
                                    value: bateau.nomBateau,
                                    child: Text(bateau.nomBateau),
                                  );
                                }),
                              ],
                              onChanged: (value) {
                                setState(() {
                                  _selectedBateauName = value;
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.add_circle),
                            color: Colors.blue[700],
                            tooltip: 'Add new boat',
                            onPressed: () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const BateauFormPage(),
                                ),
                              );
                              if (result == true) {
                                await _loadBateaux();
                              }
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _validatedFournisseurName,
                              decoration: const InputDecoration(
                                labelText: 'Fournisseur',
                                hintText: 'Select a supplier',
                                prefixIcon: Icon(Icons.business),
                              ),
                              items: [
                                const DropdownMenuItem<String>(
                                  value: null,
                                  child: Text('-- No supplier selected --'),
                                ),
                                ..._fournisseurs.map((fournisseur) {
                                  return DropdownMenuItem<String>(
                                    value: fournisseur.nomFournisseur,
                                    child: Text(fournisseur.nomFournisseur),
                                  );
                                }),
                              ],
                              onChanged: (value) {
                                setState(() {
                                  _selectedFournisseurName = value;
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.add_circle),
                            color: Colors.blue[700],
                            tooltip: 'Add new supplier',
                            onPressed: () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const FournisseurFormPage(),
                                ),
                              );
                              if (result == true) {
                                await _loadFournisseurs();
                              }
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _validatedUsineName,
                              decoration: const InputDecoration(
                                labelText: 'Usine',
                                hintText: 'Select a factory',
                                prefixIcon: Icon(Icons.factory),
                              ),
                              items: [
                                const DropdownMenuItem<String>(
                                  value: null,
                                  child: Text('-- No factory selected --'),
                                ),
                                ..._usines.map((usine) {
                                  return DropdownMenuItem<String>(
                                    value: usine.nomUsine,
                                    child: Text(usine.nomUsine),
                                  );
                                }),
                              ],
                              onChanged: (value) {
                                setState(() {
                                  _selectedUsineName = value;
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.add_circle),
                            color: Colors.blue[700],
                            tooltip: 'Add new factory',
                            onPressed: () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const UsineFormPage(),
                                ),
                              );
                              if (result == true) {
                                await _loadUsines();
                              }
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _mareeController,
                        decoration: const InputDecoration(
                          labelText: 'Maree',
                          hintText: '000',
                          prefixIcon: Icon(Icons.waves),
                          prefix: Text('L ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(3),
                        ],
                        onEditingComplete: () {
                          // Auto-format with leading zeros when user finishes editing
                          if (_mareeController.text.isNotEmpty) {
                            final formatted = _mareeController.text.padLeft(3, '0');
                            setState(() {
                              _mareeController.text = formatted;
                            });
                          }
                        },
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
                      Text(
                        'Time Information',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ListTile(
                        leading: const Icon(Icons.schedule),
                        title: const Text('Discharge Time'),
                        subtitle: Text(
                          _heureDecharge != null
                              ? DateFormat('MMM dd, yyyy HH:mm').format(_heureDecharge!)
                              : 'Not set',
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (_heureDecharge != null)
                              IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  setState(() {
                                    _heureDecharge = null;
                                  });
                                },
                              ),
                            IconButton(
                              icon: const Icon(Icons.calendar_today),
                              onPressed: () => _selectDateTime(context, true),
                            ),
                          ],
                        ),
                        onTap: () => _selectDateTime(context, true),
                      ),
                      const Divider(),
                      ListTile(
                        leading: const Icon(Icons.schedule),
                        title: const Text('Treatment Time'),
                        subtitle: Text(
                          _heureTraitement != null
                              ? DateFormat('MMM dd, yyyy HH:mm').format(_heureTraitement!)
                              : 'Not set',
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (_heureTraitement != null)
                              IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  setState(() {
                                    _heureTraitement = null;
                                  });
                                },
                              ),
                            IconButton(
                              icon: const Icon(Icons.calendar_today),
                              onPressed: () => _selectDateTime(context, false),
                            ),
                          ],
                        ),
                        onTap: () => _selectDateTime(context, false),
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
                      Text(
                        'Measurements',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _temperatureController,
                        decoration: const InputDecoration(
                          labelText: 'Temperature (°C)',
                          hintText: 'Enter temperature',
                          prefixIcon: Icon(Icons.thermostat),
                          suffixText: '°C',
                        ),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        validator: (value) {
                          if (value != null && value.trim().isNotEmpty) {
                            final temp = double.tryParse(value.trim());
                            if (temp == null) {
                              return 'Please enter a valid number';
                            }
                            if (temp < -50 || temp > 50) {
                              return 'Temperature must be between -50°C and 50°C';
                            }
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _poisDechargeController,
                        decoration: const InputDecoration(
                          labelText: 'Poids Décharge (kg)',
                          hintText: 'Enter discharge weight',
                          prefixIcon: Icon(Icons.scale),
                          suffixText: 'kg',
                        ),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        validator: (value) {
                          if (value != null && value.trim().isNotEmpty) {
                            final weight = double.tryParse(value.trim());
                            if (weight == null) {
                              return 'Please enter a valid number';
                            }
                            if (weight < 0) {
                              return 'Weight must be a positive number';
                            }
                            if (weight > 999999.999) {
                              return 'Weight cannot exceed 999,999.999 kg';
                            }
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<int>(
                        value: _selectedPoidsUnitaireCarton,
                        decoration: const InputDecoration(
                          labelText: 'Poids unitaire carton',
                          hintText: 'Select carton unit weight',
                          prefixIcon: Icon(Icons.inventory_2),
                        ),
                        items: const [
                          DropdownMenuItem<int>(
                            value: null,
                            child: Text('-- No weight selected --'),
                          ),
                          DropdownMenuItem<int>(
                            value: 12,
                            child: Text('12 kg'),
                          ),
                          DropdownMenuItem<int>(
                            value: 20,
                            child: Text('20 kg'),
                          ),
                          DropdownMenuItem<int>(
                            value: 24,
                            child: Text('24 kg'),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedPoidsUnitaireCarton = value;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _save,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.blue[700],
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
                          _isEditing ? 'UPDATE TRUCK DISCHARGE' : 'CREATE TRUCK DISCHARGE',
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
}