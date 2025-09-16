import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/camion_decharge.dart';
import '../repositories/local_repository.dart';

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
  late final TextEditingController _bateauController;
  late final TextEditingController _mareeController;
  late final TextEditingController _temperatureController;

  DateTime? _heureDecharge;
  DateTime? _heureTraitement;
  bool _isLoading = false;

  bool get _isEditing => widget.camion != null;

  @override
  void initState() {
    super.initState();

    _matCamionController = TextEditingController(text: widget.camion?.matCamion ?? '');
    _bateauController = TextEditingController(text: widget.camion?.bateau ?? '');
    _mareeController = TextEditingController(text: widget.camion?.maree ?? '');
    _temperatureController = TextEditingController(
      text: widget.camion?.temperature?.toString() ?? '',
    );

    _heureDecharge = widget.camion?.heureDecharge;
    _heureTraitement = widget.camion?.heureTraitement;
  }

  @override
  void dispose() {
    _matCamionController.dispose();
    _bateauController.dispose();
    _mareeController.dispose();
    _temperatureController.dispose();
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

      final camion = CamionDecharge(
        idDecharge: widget.camion?.idDecharge,
        matCamion: _matCamionController.text.trim(),
        bateau: _bateauController.text.trim().isEmpty ? null : _bateauController.text.trim(),
        maree: _mareeController.text.trim().isEmpty ? null : _mareeController.text.trim(),
        heureDecharge: _heureDecharge,
        heureTraitement: _heureTraitement,
        temperature: _temperatureController.text.trim().isEmpty
            ? null
            : double.tryParse(_temperatureController.text.trim()),
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
                      TextFormField(
                        controller: _bateauController,
                        decoration: const InputDecoration(
                          labelText: 'Nom du Bateau',
                          hintText: 'Saisir le nom du bateau',
                          prefixIcon: Icon(Icons.directions_boat),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _mareeController,
                        decoration: const InputDecoration(
                          labelText: 'Maree',
                          hintText: 'Enter Maree information',
                          prefixIcon: Icon(Icons.waves),
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